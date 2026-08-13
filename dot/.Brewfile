# Official Amazon AWS command-line interface
brew "awscli"
# Pyright fork with various improvements and built-in pylance features
brew "basedpyright"
# Language Server for Bash
brew "bash-language-server"
# Clone of cat(1) with syntax highlighting and Git integration
brew "bat"
# Python code formatter
brew "black"
# GNU File, Shell, and Text utilities
brew "coreutils"
# Securely send things from one computer to another
brew "croc"
# Secure runtime for JavaScript and TypeScript
brew "deno"
# Language service for Docker Compose documents
brew "docker-compose-langserver"
# Language server for Dockerfiles powered by Node, TypeScript, and VSCode
brew "dockerfile-language-server"
# Language Server and Debugger for Elixir
brew "elixir-ls"
# Simple, fast and user-friendly alternative to find
brew "fd"
# Play, record, convert, and stream select audio and video codecs
brew "ffmpeg"
# Command-line fuzzy finder written in Go
brew "fzf"
# GitHub command-line tool
brew "gh"
# Syntax-highlighting pager for git and diff output
brew "git-delta"
# Git extension for versioning large files
brew "git-lfs"
# GNU Privacy Guard (OpenPGP)
brew "gnupg"
# Task is a task runner/build tool that aims to be simpler and easier to use
brew "go-task"
# Improved top (interactive process viewer)
brew "htop"
# Lightweight and flexible command-line JSON processor
brew "jq"
# Lazier way to manage everything docker
brew "lazydocker"
# Simple terminal UI for git commands
brew "lazygit"
# Postgres C API library
brew "libpq", link: true
# Powerful, lightweight programming language
brew "lua"
# Language Server for the Lua language
brew "lua-language-server"
# Just-In-Time Compiler (JIT) for the Lua programming language
brew "luajit"
# Package manager for the Lua programming language
brew "luarocks"
# CLI for Node.js style checker and lint tool for Markdown files
brew "markdownlint-cli"
# Mac App Store command-line interface
brew "mas"
# Fly through your shell history
brew "mcfly"
# Polyglot runtime manager (asdf rust clone)
brew "mise"
# Ambitious Vim-fork focused on extensibility and agility
brew "neovim"
# Display directories as trees (with optional color/HTML output)
brew "tree"
# Password manager
brew "pass"
# CLI for Postgres with auto-completion and syntax highlighting
brew "pgcli"
# Pinentry for GPG on Mac
brew "pinentry-mac"
# Fast, disk space efficient package manager
brew "pnpm"
# Object-relational database system
brew "postgresql@15"
# Framework for managing multi-language pre-commit hooks
brew "pre-commit"
# Code formatter for JavaScript, CSS, JSON, GraphQL, Markdown, YAML
brew "prettier"
# Pack repository contents into a single AI-friendly file
brew "repomix"
# Search tool like grep and The Silver Searcher
brew "ripgrep"
# Extremely fast Python linter, written in Rust
brew "ruff"
# Static analysis and lint tool, for (ba)sh scripts
brew "shellcheck"
# Autoformat shell script source code
brew "shfmt"
# Cross-shell prompt for astronauts
brew "starship"
# Organize software neatly under a single directory tree (e.g. /usr/local)
brew "stow"
# Opinionated Lua code formatter
brew "stylua"
# LSP for TailwindCSS
brew "tailwindcss-language-server"
# Terraform Language Server
brew "terraform-ls"
# Official tldr client written in Rust
brew "tlrc"
# Parser generator tool
brew "tree-sitter-cli"
# Extremely fast Python package installer and resolver, written in Rust
brew "uv"
# Vi 'workalike' with many additional features
brew "vim"
# Internet file retriever
brew "wget"
# JavaScript package manager
brew "yarn"
# Pluggable terminal workspace, with terminal multiplexer as the base feature
brew "zellij"
# Shell extension to navigate your filesystem faster
brew "zoxide"
# Fish-like fast/unobtrusive autosuggestions for zsh
brew "zsh-autosuggestions"
# Zsh port of Fish shell's history search
brew "zsh-history-substring-search"
# Fish shell like syntax highlighting for zsh
brew "zsh-syntax-highlighting"
# Web browser focusing on privacy
cask "brave-browser"
# Open source IDE for exploring and testing APIs
cask "bruno"
# OpenAI's official ChatGPT desktop app
cask "chatgpt"
# Anthropic's official Claude AI desktop app
cask "claude"
# Terminal-based AI coding assistant
cask "claude-code@latest"
# OpenAI's coding agent that runs in your terminal
cask "codex"
# Universal database tool and SQL client
cask "dbeaver-community"
# App to build and share containerised applications and microservices
cask "docker-desktop"
# Web browser
cask "firefox@developer-edition"
cask "font-fira-code"
cask "font-hack-nerd-font"
cask "font-jetbrains-mono"
cask "font-symbols-only-nerd-font"
# Terminal emulator that uses platform-native UI and GPU acceleration
cask "ghostty"
# Web browser
cask "google-chrome"
# Keyboard customiser
cask "karabiner-elements"
# Reverse proxy, secure introspectable tunnels to localhost
cask "ngrok"
# Knowledge base that works on top of a local folder of plain text Markdown files
cask "obsidian"
# Client program for the OpenVPN Access Server
cask "openvpn-connect"
# Quick Look generator for Markdown files
cask "qlmarkdown"
# Control your tools with a few keystrokes
cask "raycast"
# Team communication and collaboration software
cask "slack"
# Music streaming service
cask "spotify"
# Open-source code editor
cask "visual-studio-code"
# Multiplayer code editor
cask "zed"
# Video communication and virtual meeting platform
cask "zoom"
vscode "bierner.markdown-mermaid"
vscode "bradlc.vscode-tailwindcss"
vscode "docker.docker"
vscode "eamodio.gitlens"
vscode "esbenp.prettier-vscode"
vscode "jakebecker.elixir-ls"
vscode "kamikillerto.vscode-colorize"
vscode "mechatroner.rainbow-csv"
vscode "ms-azuretools.vscode-containers"
vscode "ms-azuretools.vscode-docker"
vscode "ms-python.debugpy"
vscode "ms-python.python"
vscode "ms-python.vscode-pylance"
vscode "ms-vscode-remote.remote-containers"
vscode "ms-vsliveshare.vsliveshare"
vscode "phoenixframework.phoenix"
vscode "phplasma.csv-to-table"
vscode "rickaym.manim-sideview"
vscode "ritwickdey.liveserver"
vscode "vscode-icons-team.vscode-icons"
vscode "vscodevim.vim"
go "cmd/go"
go "cmd/gofmt"
npm "@tobilu/qmd"
npm "corepack"

# Machine-specific packages provided by the stowed profile (work overlay or
# profiles/personal). Brewfiles are Ruby, so this include keeps Strap's
# single `brew bundle --global` covering both.
local_brewfile = File.join(Dir.home, ".Brewfile.local")
instance_eval(File.read(local_brewfile), local_brewfile) if File.exist?(local_brewfile)
