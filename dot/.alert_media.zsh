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

# Usage:
#   local-assume                  # uses DEFAULT_ASSUME_PROFILE
#   local-assume test03/dev-power-user   # override profile for this call
#   ASSUME_PROFILE=int/readonly local-dev-nerd   # env override for compose
#   local-dev-nerd               # full stack (union of services)
#   local-dev-nerd-min           # lean stack
#   local-dev-nerds              # alias to local-dev-nerd

local-assume() {
  # Pick profile from arg, env, or default
  local profile="${1:-${ASSUME_PROFILE:-$DEFAULT_ASSUME_PROFILE}}"
  export ASSUME_PROFILE="$profile"

  # Assume the role (requires your `assume` tool)
  assume "$ASSUME_PROFILE" -ex

  # Mirror the chosen profile's credentials into [default]
  local cred_file="$HOME/.aws/credentials"
  if [[ ! -f "$cred_file" ]]; then
    echo "ERROR: $cred_file not found"
    return 1
  fi

  # Backup before editing
  cp "$cred_file" "$cred_file.bak.$(date +%Y%m%d%H%M%S)" || return 1

  # Extract the body of the chosen section (until next [section])
  local body
  body="$(awk -v section="$profile" '
    $0 ~ "^\\["section"\\]$" { in=1; next }
    in && /^\[/ { in=0 }
    in { print }
  ' "$cred_file")"

  if [[ -z "${body:-}" ]]; then
    echo "ERROR: could not find section [$profile] in $cred_file"
    return 1
  fi

  # Rebuild: new [default] + all other sections except [default] and [$profile]
  awk -v section="$profile" -v body="$body" '
    BEGIN {
      print "[default]"
      # Print the extracted lines exactly as-is
      if (length(body)) {
        n = split(body, lines, /\n/);
        for (i=1; i<=n; i++) print lines[i]
      }
      print ""
    }
    /^\[default\]$/ { skip=1; next }
    $0 ~ "^\\["section"\\]$" { skip=1; next }
    skip && /^\[/ { skip=0 }
    !skip { print }
  ' "$cred_file" >"${cred_file}.tmp" && mv "${cred_file}.tmp" "$cred_file"

  echo "Set AWS [default] credentials from [$profile] (backup created)."
}

local-dev-nerd() {
  # Use selected profile (env or default)
  local-assume "${ASSUME_PROFILE:-}"

  # Full set = union of both versions (includes ncweb, sns/sqs, nc-celery, ml-callback, etc.)
  local -a services=(
    sns sqs
    nc ncweb nr mp
    nc-celery nc-celery-crit
    ml ml-callback mss
    outbox sendgrid-mock
  )
  dockc up -d "${services[@]}"
}

local-dev-nerd-min() {
  # Lean set from v1
  local-assume "${ASSUME_PROFILE:-}"
  local -a services=(nc ncweb nr mp nc-celery-crit ml mss)
  dockc up -d "${services[@]}"
}

alias local-dev-nerds="local-dev-nerd"
