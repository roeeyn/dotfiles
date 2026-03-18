# slim-nvim

`slim-nvim` is a separate Neovim app meant for fast `$EDITOR` usage.

It uses `NVIM_APPNAME=slim-nvim`, so it has its own config, plugin install path, state, and cache. That keeps it isolated from the main `nvim` setup and lets it stay lean for prompt editing and other quick editor flows.

## What it includes

- `eyeliner.nvim` for fast motion hints
- `gruvbox.nvim` for a lightweight, popular colorscheme
- `nvim-treesitter` for markdown highlighting
- `nvim-treesitter-context` for sticky section context
- `nvim-cmp` with `cmp-path` for path completion

## Entry point

The launcher script lives at `~/.local/bin/slim-nvim`, which is on `PATH` through `dot/.zshrc`.

That script sets:

```bash
NVIM_APPNAME=slim-nvim
```

and then runs:

```bash
nvim "$@"
```

## Layout

- `init.lua` loads core config and plugin bootstrap
- `lua/config/vim.lua` contains editor options and autocmds
- `lua/config/lazy.lua` bootstraps `lazy.nvim`
- `lua/plugins/*.lua` contains one file per plugin

## Notes

- unknown files default to `markdown` in this setup so prompt buffers get markdown behavior by default
- actual files with known extensions still keep their detected filetypes
- plugins for this app install under `~/.local/share/slim-nvim`
