# Initialize completion system
autoload -Uz compinit && compinit

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

source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Great history tool
eval "$(mcfly init zsh)"

# Fast move between folders
eval "$(zoxide init zsh --cmd cd)"

# Nice terminal prompt
eval "$(starship init zsh)"

# Tmux sessionizer keybindings
bindkey -s ^f "tmux-sessionizer -c\n"
bindkey -s ^o "tmux-sessionizer\n"
