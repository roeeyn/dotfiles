# Login-shell environment. Runs for every login shell, interactive or not, so
# commands started as `zsh -l -c …` (Rex layout commands, GUI-launched tools)
# get the same PATH as an interactive terminal. Interactive-only setup
# (prompt, plugins, keybindings, completion) stays in .zshrc.

# Drop duplicate PATH entries; .zshrc may prepend again in login shells.
typeset -U PATH path

# For loading local binaries
export PATH="$HOME/.local/bin:$HOME/bin:$PATH"

# Set PATH, MANPATH, etc., for Homebrew. After ~/.local/bin on purpose: brew
# ends up first, which decides the claude/node/npm/npx name collisions.
eval "$(/opt/homebrew/bin/brew shellenv)"

export LANG=en_US.UTF-8

export EDITOR=slim-nvim
export VISUAL=slim-nvim

# mise tools for non-interactive shells; .zshrc's `mise activate` takes over
# in interactive ones.
eval "$(mise activate zsh --shims)"

# Profile-specific opencode MCP servers: opencode deep-merges this file on
# top of the shared ~/.config/opencode/opencode.jsonc.
[[ -f "$HOME/.opencode-profile.jsonc" ]] && export OPENCODE_CONFIG="$HOME/.opencode-profile.jsonc"

# Added by Obsidian
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
