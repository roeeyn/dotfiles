# AGENTS.md

This file guides agentic coding in this repo. `CLAUDE.md` is a symlink to this
file, so both names resolve to the same instructions — edit this one. Always
target `AGENTS.md` with Write/Edit tools: writing through the `CLAUDE.md` path
fails with "Refusing to write through symlink".

## Scope
- Repository: dotfiles (macOS setup + editor configs).
- Primary languages: Lua (Neovim), Shell (bash), TOML/YAML.
- Formatting enforced by pre-commit and Stylua.

## Repo Layout
- `dot/`: shared Stow package (every machine). Notable: `dot/.config/nvim/`
  (Neovim, Lua), `dot/.local/bin/` (bash scripts), `dot/.config/opencode/`,
  `dot/.Brewfile` (shared Homebrew ledger).
- `profiles/personal/`, `profiles/work/`: per-machine overlays — see
  README "Repository layout" and "Profile system — invariants for agents"
  below for the rules (`profiles/work/` is a separate PRIVATE repo; never put
  work content in this public one).
- `script/setup`: the idempotent installer; `script/brew-sync`: Brewfile
  reconciliation; `script/git-hooks/`: tracked git hooks, symlinked into
  `.git/hooks` by setup (never set `core.hooksPath` — pre-commit owns
  `.git/hooks/pre-commit`).
- `.pre-commit-config.yaml`: formatting hooks.

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

## Tooling Rules
- Pre-commit hooks are the primary lint/format entrypoint.
- Stylua configuration lives in `.stylua.toml`.
- No Cursor or Copilot rules were found in this repo.

## Build / Lint / Test Commands

### Lint / Format (repository-wide)
- `pre-commit run --all-files`
- `stylua .` (if Stylua is installed locally)

### Lint / Format (single file)
- `pre-commit run stylua --files path/to/file.lua`
- `pre-commit run trailing-whitespace --files path/to/file`
- `pre-commit run end-of-file-fixer --files path/to/file`
- `pre-commit run check-yaml --files path/to/file.yaml`

### Build
- No build system is defined for this dotfiles repo.
- If you add build steps, document them here.

### Tests
- bujo-nvim has a plenary spec suite: run it FROM `dot/.config/bujo-nvim/`
  (its `CLAUDE.md` documents the exact headless-nvim command and gotchas).
- Single spec file: same command with `PlenaryBustedFile tests/<name>.lua`.
- Elsewhere: no test suite; if you introduce one, document it here.

## Pre-commit Hooks
- `check-yaml` for YAML sanity.
- `end-of-file-fixer` to ensure trailing newline.
- `trailing-whitespace` to trim extra spaces.
- `stylua` for Lua formatting.

## Formatting Rules
- Use 4-space indentation in Lua (from `.stylua.toml`).
- Prefer single quotes in Lua when possible.
- Max line width is 160 columns (Stylua).
- Use Unix line endings.
- Favor `no_call_parentheses = true` in Lua (Stylua).

## Multiple Neovim configs — fan-out rule

There are five parallel nvim app configs under `dot/.config/`: `nvim`,
`bujo-nvim`, `pg-nvim`, `nvim-eyeliner`, `slim-nvim`. After any plugin
add/fix/upgrade in one of them, ALWAYS ask whether to apply the same change
to the sibling configs — never fan out automatically (some plugins belong in
every config, others are deliberately config-specific). When fanning out,
commit one config per commit.

## Lua Style (Neovim)
- Keep plugin configs small and focused per file.
- Prefer `local` for module/function references.
- Use `snake_case` for local functions and variables.
- Keep `vim.api.nvim_create_autocmd` blocks grouped by feature.
- Use `vim.keymap.set` with `desc` for mappings.
- Group leader mappings in `which-key` plugin file.
- Avoid adding inline comments unless requested.

## Lua Imports / Requires
- Use `local mod = require 'mod'` (single quotes).
- Require modules close to their usage.
- Avoid unused `require` statements.

## Lua Error Handling
- Prefer early returns for invalid state.
- Use `pcall` only when failure is expected/handled.
- Keep errors surfaced rather than silenced.

## Shell Script Style
- Use `#!/bin/bash` shebang in `dot/.local/bin/*` scripts.
- Quote variables (`"$var"`) and paths.
- Use `set -euo pipefail` only if the script is safe for it.
- Prefer readable `if` blocks over dense one-liners.
- Match indentation style of the file (2 or 4 spaces).

## Naming Conventions
- Files: follow existing naming scheme.
- Lua functions: `snake_case`.
- Lua tables: descriptive nouns (e.g., `opts`, `config`).
- Autocmd groups: lowercase or kebab-case names.

## Configuration Patterns
- Keep globals minimal; prefer `vim.opt`/`vim.o`.
- Group related settings with a short comment header.
- When moving behavior, update both the source and target file.

## Error Handling / Safety
- Prefer non-destructive changes (avoid `rm` in scripts unless required).
- Ensure scripts handle empty inputs (e.g., `fzf` canceled).
- Validate assumptions before invoking tmux commands.

## Documentation
- Update `README.md` only when setup steps change.
- Use concise comments to explain why a config exists.

## Common Tasks
- Add a new keymap: update `dot/.config/nvim/lua/plugins/which-key.lua`.
- Add a plugin: create a Lua file under `dot/.config/nvim/lua/plugins/`.
- Adjust editor defaults: modify `dot/.config/nvim/lua/config/vim.lua`.

## File-Specific Notes
- `dot/.config/nvim/lua/config/vim.lua`: global editor options + autocmds.
- `dot/.config/nvim/lua/plugins/*.lua`: plugin specs for lazy.nvim.
- `dot/.local/bin/*`: user scripts; keep them small and task-focused.

## Formatting Workflow
- Run `pre-commit run stylua --files path/to/file.lua` after Lua edits.
- Run `pre-commit run trailing-whitespace --files path/to/file` after edits.
- Consider `pre-commit run --all-files` before large changes.

## Conventions for PRs/Commits
- Not enforced in this repo; follow personal conventions.
- Keep changes minimal and scoped.

## When Uncertain
- Search for similar patterns before creating new ones.
- Keep style consistent with nearby files.
- Ask the user if a new tool or workflow is acceptable.

## Explicit Non-Requirements
- No mandated test runner.
- No required build step.
- No Cursor/Copilot rules to merge.

## Future Extensions
- If you add tests, document: `run all` + `run single test`.
- If you add linting (e.g., shellcheck), include the command here.
- If you add CI, summarize workflow names and entrypoints.

## Quick Reference
- Format Lua: `pre-commit run stylua --files file.lua`
- Format all: `pre-commit run --all-files`
- Hooks file: `.pre-commit-config.yaml`
- Stylua config: `.stylua.toml`

## Notes on Opencode
- Opencode UI behavior lives in `config/vim.lua`.
- Keymaps live in `plugins/which-key.lua` under the `Opencode` group.

## Keep This Updated
- If you add tooling, update this file.
- If a command changes, adjust the examples.
- Keep this doc around ~210 lines.
