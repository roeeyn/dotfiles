# bujo-nvim

A lightweight, isolated Neovim app for markdown daily notes with BuJo-style
task migration. Launched via `bujo-nvim` (in `~/.local/bin`, tracked at
`dot/.local/bin/bujo-nvim`), which sets `NVIM_APPNAME=bujo-nvim`, cds into the
notes root, and lands directly in today's note. Kanagawa *wave* on purpose —
the notes app should never be mistaken for a code editor.

The notes root is `~/notes` (`$BUJO_NOTES_DIR` overrides it, which is also how
the e2e tests point the app at a sandbox):

```
~/notes/
  2026/
    07/
      2026-07-10.md           daily notes: YYYY/MM/YYYY-MM-DD.md
      2026-07-11.md
  notes/
    elixir-broadway-tips.md   free-form named notes (:BujoNote)
    2026-07-11 Note 1.md      quick captures (:BujoNew)
```

## Task states

| Marker | Meaning |
| ------ | ------- |
| `- [ ]` | open — the only state that migrates |
| `- [x]` | done |
| `- [>]` | migrated to a later daily note |
| `- [<]` | scheduled |
| `- [-]` | irrelevant |

## Migration (`:BujoToday` on a fresh day)

If today's note doesn't exist yet, the **nearest previous existing** daily
note (not calendar-yesterday — weekends and vacations leave gaps) is scanned:

- Every line whose first non-whitespace content is `- [ ]` becomes a
  migration root. Its block — all subsequent lines with strictly deeper
  indentation: nested tasks of any state, `- ` note bullets, free text — is
  copied into today in source order, root at column 0, children keeping
  their relative indentation.
- Every copied `- [ ]` (root or nested child) becomes `- [>]` in the source.
  Nothing is deleted; the previous day stays a truthful record.
- A `- [ ]` nested under a resolved parent (`[x]`/`[-]`/`[>]`) is still
  pending: it migrates as its own root, dedented to column 0.

The logic is a pure function in `lua/bujo/migrate.lua`; the semantics above
are pinned by `tests/migrate_spec.lua`. Opening an existing today-note never
re-runs migration.

## Commands

| Command | Action |
| ------- | ------ |
| `:BujoToday` | open today's note, creating + migrating if it's new |
| `:BujoPrev` / `:BujoNext` | nearest *existing* daily note before/after the current one |
| `:BujoToggle` | toggle `- [ ]` ↔ `- [x]` on the line or range (never touches `>` `<` `-`) |
| `:BujoNote <name>` | create/open `notes/<kebab-case-name>.md` with a `# Title` (tab-completes existing notes) |
| `:BujoNew` | quick-capture `notes/YYYY-MM-DD Note <n>.md`, auto-incrementing `<n>` |

## Keymaps (`<leader>` = space)

| Keys | Action |
| ---- | ------ |
| `<leader>d` | **d**aily: `:BujoToday` |
| `<leader>h` / `<leader>l` | previous / next daily note (vim-directional: h = back in time) |
| `<leader>x` | toggle checkbox (normal: current line; visual: range) |
| `<leader>a` | **a**dd task: append `- [ ]` to today's note, insert mode |
| `<leader>nn` | **n**ew **n**ote: `:BujoNew` |
| `<leader>fd` | **f**ind **d**aily notes, newest first |
| `<leader>fg` | **f**ind by **g**rep across all of `~/notes` |
| `<leader>ft` | **f**ind **t**asks: pending `- [ ]` lines, last ~30 days |
| `-` / `<leader>po` | oil file browser (`<leader>po` mirrors main nvim) |
| `<leader>?` | which-key: buffer-local keymaps (pressing `<leader>` and waiting shows all) |
| `<leader>w{h,j,k,l,v,s,c,0}` | window nav/split/close/equalize (mirrors slim-nvim) |
| `<leader>y` (visual) | yank to system clipboard |

Entering an **empty** buffer whose path matches the daily-note pattern
prefills the `# <Weekday>, YYYY-MM-DD` template for *that file's* date, so
back-filling a missed day by hand works too.

## Tests

```sh
cd ~/.config/bujo-nvim
NVIM_APPNAME=bujo-nvim nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
```

## Non-goals

No git automation (the repo is managed by hand), no sync, no daemon, no
agenda views, no wikilinks.
