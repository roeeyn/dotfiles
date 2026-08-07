# CLAUDE.md

See `AGENTS.md` for the repository's general development instructions.

## Profile system — invariants for agents

One branch (`main`) serves both of Rodrigo's machines via GNU Stow packages;
README.md has the human-level map ("Repository layout", "Profiles"). The
rules below are the ones an agent must not violate:

- **This repo is PUBLIC.** Never commit work-identifying content (AlertMedia
  hostnames, internal repo/product names, brand strings, tokens). Work
  config belongs in the PRIVATE overlay at `profiles/work/` — a separate
  nested git repo (`roeeyn/dotfiles-work`, gitignored here). Changing files
  under `profiles/work/` means committing and pushing IN that repo.
- **`~/.config` and `~/.local` are folded Stow symlinks into `dot/`.**
  Profile packages must NEVER ship files under those paths (cross-stow-dir
  conflict aborts setup); profile-owned files are root-level dotfiles:
  `~/.gitconfig.local`, `~/.mcp.json`, `~/.opencode-profile.jsonc`,
  `~/.Brewfile.local`, `~/.alert_media.zsh`, `~/.ssh/config.d/*`.
  Corollary: edits to `dot/` files are live on this machine immediately.
- **`script/setup` is the only stow entrypoint** and is idempotent — safe to
  re-run anytime. Profile resolution: CLI arg > `$DOTFILES_PROFILE` >
  `~/.dotfiles-profile` marker > `personal`; switching unstows the old
  profile first. Per-profile provisioning hooks: `profiles/<name>/hooks/setup`.
- **Machine-local mutable state stays gitignored — never track it**:
  `dot/.codex/config.toml`, `dot/.config/opencode/opencode.json`,
  `~/.claude.json` (user-scope MCPs), raycast/copilot state dirs. Their
  drift is by design; do not "fix" it by committing.
- **Secrets live only in `dot/env/.env`** (gitignored; `.example.env` is the
  key-name contract). History is public and once carried encrypted private
  keys — everything in it was rotated in 2026-08. Never commit a secret.
- **Never run `brew bundle dump --global --force`** — it flattens the
  shared/profile Brewfile split. Reconcile with `script/brew-sync`
  (ledger) and `brew bundle --global` / `cleanup --global` (enforcement).
- **Two GitHub identities.** `gh` on the work machine is the EMU account:
  it cannot touch personal repos and must never register personal SSH keys
  (setup guards this — keep the guard). Personal-repo remotes go through
  the `github-personal` ssh alias. SSH keys are per machine, never in the
  repo; commits are SSH-signed (`gpg.format = ssh`), key per profile.
- **MCP servers have a documented map** (README "MCP servers"): Claude Code
  reads the profile's `~/.mcp.json` whole-file; opencode deep-merges the
  profile's `~/.opencode-profile.jsonc` on top of the shared
  `opencode.jsonc` via `$OPENCODE_CONFIG`. Adding a server usually means
  touching both tools' files.

## Lazygit configurations

Keep the two lazygit configurations separate:

- `dot/Library/Application Support/lazygit/config.yml` configures standalone `lazygit` and `lg` sessions on macOS.
- `dot/.config/lazygit/config.yml` is passed explicitly by `lazygit.nvim` and may contain Neovim-specific behavior such as `editPreset: nvim-remote`.

Do not move the Neovim editor settings into the standalone config without confirming that nested editor behavior is desired. Do not symlink the entire `~/Library/Application Support/lazygit` directory because lazygit writes machine-local state to `state.yml`; only `config.yml` should be managed by Stow.
