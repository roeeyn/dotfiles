echo "Loading .zshrc..."

# For loading local binaries
export PATH="$HOME/.local/bin:$PATH"

export LANG=en_US.UTF-8

# Vim keybindings in shell
set -o vi

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

# This removes from history the commands starting with a space
setopt HIST_IGNORE_SPACE

# aliases
alias lg=lazygit

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Great history tool
eval "$(mcfly init zsh)"

# Fast move between folders
eval "$(zoxide init zsh --cmd cd)"

# Nice terminal prompt
eval "$(starship init zsh)"
