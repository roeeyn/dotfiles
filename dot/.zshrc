# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/rodrigom/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-autosuggestions zsh-syntax-highlighting docker)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#####################################################
######## Aquí empieza el desvergue viejón! ##########
#####################################################

# For homebrew
export PATH="/opt/homebrew/bin:$PATH"

export LANG=en_US.UTF-8
set -o vi

# This removes from history the commands starting with a space
setopt HIST_IGNORE_SPACE

alias gnp='git --no-pager'
alias gnpb='git --no-pager branch'
alias gnps='git --no-pager stash list'
alias gbd='git branch -d $(git --no-pager branch | fzf --height 80% --border --layout reverse)'
alias gbD='git branch -D $(git --no-pager branch | fzf --height 80% --border --layout reverse)'
alias gb='git branch | fzf'
alias gba='git branch -a | fzf'
alias gwl='git worktree list'
alias gwa='git worktree add'
alias gwp='git worktree prune'
alias rgi=rogit
alias rgim='rogit -m'
alias dsr='docker stop $(docker ps | awk '\''{print $1}'\'' | grep -v CONTAINER)'
alias hcr='heroku container:release web -a'
alias hcp='heroku container:push web -a'
alias sayv='say -v Paulina'

# Tmux sessionizer
bindkey -s ^f "tmux-sessionizer -c\n"
bindkey -s ^o "tmux-sessionizer\n"

# For FZF
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
fi

# Enable history in IEX through Erlang(OTP)
export ERL_AFLAGS="-kernel shell_history enabled"

# For dotfiles scripts
export PATH="/Users/rodrigom/.local/bin:$PATH"

# For golang
export GOPATH="/Users/roeeyn/go"
export PATH="$GOPATH/bin:$PATH"

# For virtualenvwrapper
export PATH="/usr/local/opt/python/libexec/bin:/usr/local/sbin:$PATH"
export PATH="/Users/rodrigom/Library/Python/3.8/bin:$PATH"
export PATH="/usr/local/bin:usr/local/share/python:$PATH"

# For john stuff
## For intel processor
export PATH="$PATH:/usr/local/share/john"
## For M1 processor
export PATH="$PATH:/opt/homebrew/share/john"

# For ping and another brew commands
export PATH="/opt/homebrew/sbin:/opt/homebrew/bin:$PATH"

# The next line updates PATH for the Google Cloud SDK.
# source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
# source "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"

if [ ! "$TMUX" = "" ]; then export TERM=xterm-256color; fi

export OPENSSL_ROOT_DIR="$(brew --prefix openssl)"

# For pyenv
eval "$(pyenv init -)"
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$(pyenv root)/shims:/$(pyenv root)/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# For pyenv virtual env
eval "$(pyenv virtualenv-init -)"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Python venv automatic activation
eval "$(aactivator init)"

export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# For ruby stuff
if [ -d "/opt/homebrew/opt/ruby/bin" ]; then
  export PATH=/opt/homebrew/opt/ruby/bin:$PATH
  export PATH=`gem environment gemdir`/bin:$PATH
fi

eval "$(/Users/rodrigom/src/idl/idldev-tool/bin/idldev init -)"
