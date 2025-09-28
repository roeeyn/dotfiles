# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Architecture

This is a macOS dotfiles repository designed for complete system setup and configuration management using **GNU Stow** for symlink management and the **Strap Project** for automated macOS setup.

### Directory Structure

- **`dot/`**: Contains all dotfiles that will be symlinked to `$HOME` via stow
  - `.Brewfile`: Homebrew package definitions with descriptions
  - `.zshrc`: Main shell configuration with mise activation, vi mode, and tool integrations
  - `.config/`: Application-specific configurations (nvim, git, mise, lazygit, etc.)
  - `.tool-versions`: Version specifications for mise (version manager)
  - Other dotfiles (`.tmux.conf`, `.vimrc`, `.gitignore`, etc.)

- **`files/`**: Contains files to be copied (not symlinked) to `$HOME`
  - Currently minimal, mainly placeholder files

- **`script/`**: Setup automation scripts
  - `setup`: Main setup script that installs stow and creates symlinks
  - `strap-after-setup`: Post-Strap setup hook (minimal implementation)

### Key Technologies & Tools

- **Version Management**: `mise` (replaces asdf) - manages Elixir, Erlang, Node.js, Terraform, etc.
- **Package Management**: Homebrew with comprehensive Brewfile
- **Shell**: Zsh with extensive git aliases, vi mode, and modern CLI tools
- **Editor**: Neovim with Lua configuration and lazy.nvim plugin manager
- **Terminal Multiplexer**: tmux with custom configuration
- **Git Workflow**: Extensive git aliases similar to Oh My Zsh conventions

## Common Commands

### Initial Setup (New Machine)
```bash
# Download and run Strap (customized with GitHub token)
# This automatically clones dotfiles and runs setup scripts
```

### Dotfiles Management
```bash
# Apply dotfile changes (from repository root)
stow dot/ --target=$HOME

# Update Brewfile after installing/removing packages
brew bundle dump --file=~/.Brewfile --describe --force

# Install all Homebrew packages
brew bundle install --file=~/.Brewfile

# Install/update tool versions via mise
mise install          # Installs from .tool-versions
mise upgrade          # Updates to latest versions
```

### Development Environment
```bash
# Lint and format Lua code (Neovim configs)
stylua . --check      # Check formatting
stylua .              # Format files

# Pre-commit hooks
pre-commit install    # Set up hooks
pre-commit run --all-files  # Run all hooks manually
```

### Version Management (mise)
- Configuration: `~/.config/mise/config.toml` (additional tools) + `~/.tool-versions` (project versions)
- The shell automatically activates the correct versions via `eval "$(mise activate bash)"`
- Global tools: Node.js (latest), Terraform (1.5.5), Terragrunt (0.32.3), TFLint (latest)
- Project-specific: Elixir (1.18.3), Erlang (27.3.4)

## Architecture Notes

### Stow-based Symlink Management
- The `dot/` directory structure mirrors the target `$HOME` structure
- Running `stow dot/ --target=$HOME` creates symlinks from `~/.config/nvim/` → `~/.dotfiles/dot/.config/nvim/`
- Files in `files/` are copied, not symlinked (use for files that shouldn't be symlinked)

### Shell Configuration
- `.zshrc` loads additional aliases from `~/.config/zsh/aliases.zsh`
- Extensive git aliases following Oh My Zsh conventions (g, ga, gco, etc.)
- Modern CLI tools integrated: bat, exa, zoxide, mcfly, starship, fzf
- Vi mode enabled for command line editing

### Development Tools Integration
- GitHub CLI (`gh`) with copilot integration
- Raycast extensions for macOS productivity
- Neovim with Lazy.nvim package manager and extensive plugin ecosystem
- Tmux with custom key bindings and sessionizer integration

### Code Quality
- StyLua for Lua code formatting (column width: 160, spaces, no call parentheses)
- Pre-commit hooks for YAML validation, trailing whitespace, and Lua formatting
- Git hooks integration for consistent code style

## Important Patterns

### Tool Version Management
- Always use `.tool-versions` for project-specific versions
- Use `~/.config/mise/config.toml` for global tool preferences
- The `idiomatic_version_file_enable_tools` setting enables automatic version detection for Node.js

### Brewfile Management
- Use `brew bundle dump` to regenerate Brewfile after manual installations
- Include `--describe` flag to maintain helpful comments
- The Brewfile includes taps, formulae, casks, mas apps, and VS Code extensions

### Git Workflow
- Extensive alias system mirrors Oh My Zsh git plugin
- Helper functions detect main branch name (main/master/trunk)
- Branch-aware push/pull operations via `ggp`/`ggl` functions

## Security Considerations
- API keys stored in separate files (`.unsplash_api_key`, `.wakatime.cfg`)
- GPG configuration for signing commits
- SSH configuration managed via dotfiles
- Sensitive files should be added to `.gitignore` and managed separately
