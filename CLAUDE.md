# CLAUDE.md

See `AGENTS.md` for the repository's general development instructions.

## Lazygit configurations

Keep the two lazygit configurations separate:

- `dot/Library/Application Support/lazygit/config.yml` configures standalone `lazygit` and `lg` sessions on macOS.
- `dot/.config/lazygit/config.yml` is passed explicitly by `lazygit.nvim` and may contain Neovim-specific behavior such as `editPreset: nvim-remote`.

Do not move the Neovim editor settings into the standalone config without confirming that nested editor behavior is desired. Do not symlink the entire `~/Library/Application Support/lazygit` directory because lazygit writes machine-local state to `state.yml`; only `config.yml` should be managed by Stow.
