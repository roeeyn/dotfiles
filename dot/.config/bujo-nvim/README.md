# bujo-nvim

A lightweight, isolated Neovim app for markdown daily notes with BuJo-style
task migration. Launched via `bujo-nvim` (in `~/.local/bin`, tracked at
`dot/.local/bin/bujo-nvim`), which sets `NVIM_APPNAME=bujo-nvim`, cds into the
notes root, and lands directly in today's note. Kanagawa *lotus* (the light
variant) on purpose — the notes app should never be mistaken for a code
editor.

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

## Priority (`lua/bujo/priority.lua`)

A `!` immediately after the checkbox marks a task important:

```markdown
- [ ] !renew the passport
```

The `!` lives in the task *text*, not in the brackets, so it is orthogonal
to state: migration copies the line verbatim (the marker follows the task
across days), `:BujoToggle` works unchanged, and a done important task is
just `- [x] !...`. A bang anywhere else in the text is plain punctuation.

Rendering (via extmark *overlay*, so line width and soft-wrap are
unaffected):

- **pending** `- [ ] !` — the `!` is painted over with a warning icon and
  the task text is highlighted (`BujoPriority`: bold lotusOrange, overridden
  in `lua/plugins/kanagawa.lua`; the module default links `DiagnosticWarn`);
- **done/irrelevant** `- [x]` / `- [-]` — only a muted icon remains
  (`BujoPriorityMuted` → `NonText`); the strikethrough takes over, so
  finished work stops shouting;
- **migrated/scheduled** `- [>]` / `- [<]` — currently undecorated (the raw
  `!` stays visible); the treatment is an open decision in the `styles`
  table at the top of `lua/bujo/priority.lua`.

`<leader>ft` (pending tasks picker) floats `!` tasks to the top of the list.

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
| `:BujoShortenLinks` | rewrite `[MSG-1234](url)` / `[repo#56](url)` links into bare refs (see below) |

## Keymaps (`<leader>` = space)

| Keys | Action |
| ---- | ------ |
| `<leader>d` | **d**aily: `:BujoToday` |
| `<leader>h` / `<leader>l` | previous / next daily note (vim-directional: h = back in time) |
| `<leader>x` / `<leader>;l` | toggle checkbox (normal: current line; visual: range); `;l` mirrors the main-nvim comment-line binding |
| `<leader>a` | **a**dd task: insert `- [ ]` below the cursor (same indent), insert mode |
| `<leader>nn` | **n**ew **n**ote: `:BujoNew` |
| `<leader>fd` | **f**ind **d**aily notes, newest first |
| `<leader>fg` | **f**ind by **g**rep across all of `~/notes` |
| `<leader>ft` | **f**ind **t**asks: pending `- [ ]` lines, last ~30 days, `!` tasks first |
| `<leader>fs` / `<leader>fS` | save current buffer / save all (mirrors main nvim) |
| `<leader>b{b,n,p,l,d,x,D}` | buffers: telescope list, next, prev, last, delete, force-delete, close others |
| `-` / `<leader>po` | oil file browser (`<leader>po` mirrors main nvim) |
| `<leader>?` | which-key: buffer-local keymaps (pressing `<leader>` and waiting shows all) |
| `<leader>q1` / `<leader>qq` | force quit / soft quit (mirrors main nvim) |
| `gx` / `<leader>o` | **o**pen ticket/PR ref or URL under cursor in the browser |
| `za` | collapse / expand the subtasks of the task under the cursor (see below) |

## Folding (`lua/bujo/fold.lua`)

`za` on a task collapses its subtasks — the natural gesture when a parent is
finished and its children are just history:

```
▾ - [ ] plan the offsite
      - [ ] send invites
      - [ ] book the room

▸ - [ ] plan the offsite·······································
```

A collapsed task is marked three ways at once: the `▸` in the gutter (`▾`
when it is open, blank on tasks with nothing to collapse), the `Folded`
background, and the `·` run trailing the text. `foldtext` is empty on
purpose, so the folded line keeps its checkbox icon, its strikethrough and
its `!` marker instead of turning into `+--  3 lines: - [ ] …`.

The folds themselves come from tree-sitter's markdown queries, so a "task
with subtasks" is a list item containing a nested list. `za` only ever
toggles a fold that *starts on the cursor line*: pressed on a task with no
subtasks it does nothing, rather than collapsing the whole day (which is
what the built-in `za` does there). Everything else is stock Vim — `zc`
closes the fold you are inside, `zR` / `zM` open / close all, and notes
always open fully expanded.

## Insert-mode column

While typing, the cursor's **column** lights up (`cursorcolumn`, on for
Insert and Replace only). The terminal cursor is easy to lose on the pale
lotus background and its color can't be set per-mode from here — zellij
swallows the OSC 12 escape — so the position is signalled by the row
(`cursorline`, always on) crossing the column band. The band uses kanagawa
lotus's own `CursorColumn`; to make it louder, set a `CursorColumn`
highlight in `lua/plugins/kanagawa.lua` next to `BujoPriority`.

## Ticket/PR references (`lua/bujo/links.lua`)

Neovim wraps on raw buffer columns even when text is concealed
(neovim/neovim#14409), so tasks carrying full markdown links wrap weirdly
under render-markdown. Instead, lines carry bare refs — `MSG-1234`,
`repo#56` — and the URL is reconstructed on demand:

- `MSG-1234` → Jira; `repo#56` → GitHub under `alertmediainc` (aliases:
  `nr` = `notification_router`); repos listed in `bitbucket_repos`
  (currently `notify_me`) → Bitbucket. Edit the table at the top of
  `lua/bujo/links.lua` (or pass `setup { links = ... }`) to add aliases or
  drop a repo once it migrates off Bitbucket.
- Refs are decorated in place with render-markdown's link look (icon +
  underline) via extmarks; the raw text is just the ref, so wrap stays
  correct.
- `:BujoShortenLinks` converts existing ref-labeled markdown links in the
  buffer; prose-labeled or foreign links are left alone.
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
