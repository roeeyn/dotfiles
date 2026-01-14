# For loading local binaries
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

export LANG=en_US.UTF-8

export EDITOR=vim

# Vim keybindings in shell
set -o vi

# Set PATH, MANPATH, etc., for Homebrew.
eval "$(/opt/homebrew/bin/brew shellenv)"

## Files & sizes (matches OMZ defaults)
HISTFILE=${HISTFILE:-$HOME/.zsh_history}
HISTSIZE=50000
SAVEHIST=10000

### Core history behavior
setopt EXTENDED_HISTORY         # store :epoch:elapsed;command in $HISTFILE
setopt HIST_EXPIRE_DUPS_FIRST   # when trimming, drop older duplicates first
setopt HIST_IGNORE_DUPS         # ignore a command if it's identical to the previous one
setopt HIST_IGNORE_SPACE        # don't store commands that start with a space
setopt HIST_REDUCE_BLANKS      # normalize whitespace so dup detection is consistent
setopt HIST_VERIFY              # after "!" expansion, load back into the editor instead of running
setopt SHARE_HISTORY            # merge history across terminals & append incrementally


# Load aliases from separate file
if [ -f "$HOME/.config/zsh/aliases.zsh" ]; then
  source "$HOME/.config/zsh/aliases.zsh"
fi

# Personal aliases
alias lg=lazygit
alias ldo=lazydocker
alias cl=claude
alias cls="claude --dangerously-skip-permissions"
alias cx=codex
alias ca=cursor-agent
alias oc=opencode

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

source "$HOME/.alert_media.zsh"

# Initialize completion system
autoload -Uz compinit
# Check if .zcompdump is older than 24 hours
if [[ -f ${ZDOTDIR:-$HOME}/.zcompdump && -n $(find ${ZDOTDIR:-$HOME}/.zcompdump -mtime +1 2>/dev/null) ]]; then
  compinit
else
  compinit -C
fi

# Shopify Hydrogen alias to local projects
alias h2='$(npm prefix -s)/node_modules/.bin/shopify hydrogen'
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/roeeyn/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions
# Added by Antigravity
export PATH="/Users/roeeyn/.antigravity/antigravity/bin:$PATH"
