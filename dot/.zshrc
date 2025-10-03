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
alias ldo=lazydocker
alias cl=claude
alias cx=codex
alias ca=cursor-agent

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source $(brew --prefix)/share/zsh-history-substring-search/zsh-history-substring-search.zsh

# For similar prefixed commands
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Great history tool
eval "$(mcfly init zsh)"

# Fast move between folders
eval "$(zoxide init zsh --cmd cd)"

# Nice terminal prompt
eval "$(starship init zsh)"

# tool version activation
eval "$(mise activate bash)"

# GPG configuration for signing commits
export GPG_TTY=$(tty)

# Tmux sessionizer keybindings
bindkey -s ^f "tmux-sessionizer -c\n"
bindkey -s ^o "tmux-sessionizer\n"

# Initialize completion system
autoload -Uz compinit
# Check if .zcompdump is older than 24 hours
if [[ -f ${ZDOTDIR:-$HOME}/.zcompdump && -n $(find ${ZDOTDIR:-$HOME}/.zcompdump -mtime +1 2>/dev/null) ]]; then
  compinit
else
  compinit -C
fi
