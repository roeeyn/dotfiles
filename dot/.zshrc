# For loading local binaries
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"


export LANG=en_US.UTF-8

# Vim keybindings in shell
set -o vi

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# This removes from history the commands starting with a space
setopt HIST_IGNORE_SPACE

# Load aliases from separate file
if [ -f "$HOME/.config/zsh/aliases.zsh" ]; then
    source "$HOME/.config/zsh/aliases.zsh"
fi

# Personal aliases
alias lg=lazygit

export SERVERLESS_LICENSE_KEY=not_relevant

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Great history tool
eval "$(mcfly init zsh)"

# Fast move between folders
eval "$(zoxide init zsh --cmd cd)"

# Nice terminal prompt
eval "$(starship init zsh)"

# tool version activation
eval "$(mise activate bash)"

# Tmux sessionizer keybindings
bindkey -s ^f "tmux-sessionizer -c\n"
bindkey -s ^o "tmux-sessionizer\n"

# Initialize completion system
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

ee() {
    local profile=""
    local cluster=""
    local service=""
    local container=""
    local command="/bin/bash"
    arnList=()
    while (( "$#" ))
    do
            case "$1" in
                    (--container) container=$2
                            shift 2 ;;
                    (--command) command=$2
                            shift 2 ;;
                    (*) if [ -z "$profile" ]
                            then
                                    profile=$1
                                    env=${profile%%/*}
                            elif [ -z "$cluster" ]
                            then
                                    cluster=$1
                            elif [ -z "$service" ]
                            then
                                    service=$1
                            else
                                    echo "Unknown option: $1"
                                    return 1
                            fi
                            shift ;;
            esac
    done
    if (
                    [ -z "$env" ] || [ -z "$cluster" ] || [ -z "$service" ]
            )
    then
            echo "env, cluster, and service must all be defined"
            echo "Usage: ee <environment> <cluster> <service> --container <optional container> --command <optional command>"
            return 1
    fi
    . assume $profile
    arnList=($(aws ecs list-tasks --cluster "$env"-"$cluster" --service "$env"-"$service"-service --desired-status 'RUNNING' --output text --query 'taskArns'))
    taskList=($(for arn in "${arnList[@]}"; do echo "$arn" | awk 'BEGIN{ FS = "/" } ; {print $3}'; done))
    len=${#taskList[@]}
    if ((len > 1))
    then
            select task in "${taskList[@]}"
            do
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
