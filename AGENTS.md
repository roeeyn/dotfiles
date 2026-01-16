# AGENTS.md

This file guides agentic coding in this repo.

## Scope
- Repository: dotfiles (macOS setup + editor configs).
- Primary languages: Lua (Neovim), Shell (bash), TOML/YAML.
- Formatting enforced by pre-commit and Stylua.

## Repo Layout
- `dot/.config/nvim/`: Neovim configuration (Lua).
- `dot/.local/bin/`: user scripts (bash).
- `dot/.config/opencode/`: opencode plugin setup (package.json).
- `dot/.Brewfile`: Homebrew bundle definitions.
- `.pre-commit-config.yaml`: formatting hooks.

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
- No test suite is defined in this repository.
- Single-test execution: not applicable.
- If you introduce tests, add the command and a single-test example.

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
- Keep this doc around ~150 lines.
