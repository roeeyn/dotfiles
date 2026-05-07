############# AlertMedia #############

export SERVERLESS_LICENSE_KEY=not_relevant

ee() {
  local profile=""
  local cluster=""
  local service=""
  local container=""
  local command="/bin/bash"
  arnList=()
  while (("$#")); do
    case "$1" in
    --container)
      container=$2
      shift 2
      ;;
    --command)
      command=$2
      shift 2
      ;;
    *)
      if [ -z "$profile" ]; then
        profile=$1
        env=${profile%%/*}
      elif [ -z "$cluster" ]; then
        cluster=$1
      elif [ -z "$service" ]; then
        service=$1
      else
        echo "Unknown option: $1"
        return 1
      fi
      shift
      ;;
    esac
  done

  if (
    [ -z "$env" ] || [ -z "$cluster" ] || [ -z "$service" ]
  ); then
    echo "env, cluster, and service must all be defined"
    echo "Usage: ee <environment> <cluster> <service> --container <optional container> --command <optional command>"
    return 1
  fi

  . assume $profile

  arnList=($(aws ecs list-tasks --cluster "$env"-"$cluster" --service "$env"-"$service"-service --desired-status 'RUNNING' --output text --query 'taskArns'))
  taskList=($(for arn in "${arnList[@]}"; do echo "$arn" | awk 'BEGIN{ FS = "/" } ; {print $3}'; done))
  len=${#taskList[@]}

  if ((len > 1)); then
    select task in "${taskList[@]}"; do
      echo "Connecting to "$env"-"$cluster"-"$service"'s "${container:-$service}" container, task ID $task"
      aws ecs execute-command --cluster "$env"-"$cluster" --task "$task" --container "${container:-$service}" --interactive --command "${command}"
      break
    done
  else
    echo "Connecting to "$env"-"$cluster"-"$service"'s "${container:-$service}" container, task ID $task"
    aws ecs execute-command --cluster "$env"-"$cluster" --task "${taskList[@]:0:1}" --container "${container:-$service}" --interactive --command "${command}"
  fi

  . assume --unset
}

# Change this any time you need a different default
DEFAULT_ASSUME_PROFILE="int/readonly"

LOCAL_DEV_DOCKC_HELPERS="$HOME/src/local_dev/shell/functions/dockc-helpers.sh"
if [[ -f "$LOCAL_DEV_DOCKC_HELPERS" ]]; then
  source "$LOCAL_DEV_DOCKC_HELPERS"
fi
