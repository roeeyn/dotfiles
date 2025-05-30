# Profiling
# zmodload zsh/zprof

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/roeeyn/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

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
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

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

export LANG=en_US.UTF-8
set -o vi

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

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
alias sayv='say -v Paulina'
alias lg='lazygit'

# Copilot
# gh auth login
# gh extension install github/gh-copilot
noglob alias ??='gh copilot suggest -t shell'
noglob alias git?='gh copilot suggest -t git'
noglob alias gh?='gh copilot suggest -t gh'

# Tmux sessionizer
bindkey -s ^f "tmux-sessionizer -c\n"
bindkey -s ^o "tmux-sessionizer\n"

# For FZF
if type rg &> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files'
fi

# EDITOR variable for gh and git
export EDITOR="nvim"
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"

# Enable history in IEX through Erlang(OTP)
export ERL_AFLAGS="-kernel shell_history enabled"

# For dotfiles scripts
export PATH="/Users/roeeyn/.local/bin:$PATH"

# For golang
export GOPATH="/Users/roeeyn/go"
export GOTOOLDIR="$GOPATH/bin/"
export PATH="$GOTOOLDIR:$PATH"

# For john the ripper
export PATH="/opt/homebrew/Cellar/john-jumbo/1.9.0_1/share/john:$PATH"

# For pyenv
# export PYENV_ROOT="$HOME/.pyenv"
# command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init -)"

# For pyenv virtual env
# eval "$(pyenv virtualenv-init -)"
# export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# Python venv automatic activation
eval "$(aactivator init)"

# For n (node version manager)
export N_PREFIX="/Users/roeeyn/"
export PATH="/Users/roeeyn/bin:$PATH"

# For postgres 15
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# McFly
export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
eval "$(mcfly init zsh)"

# Starting starship
eval "$(starship init zsh)"

## Profiling
# zprof

# Start zoxide
eval "$(zoxide init zsh --cmd cd)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"

# Added by Windsurf
export PATH="/Users/roeeyn/.codeium/windsurf/bin:$PATH"

# Local composer for the CFDI stuff in FiscaLink
export PATH="$HOME/.composer/vendor/bin:$PATH"

# ASDF package manager
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/roeeyn/.docker/completions $fpath)
fpath=(${ASDF_DATA_DIR:-$HOME/.asdf}/completions $fpath)
autoload -Uz compinit && compinit

# End of Docker CLI completions