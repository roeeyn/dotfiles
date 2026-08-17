# bujo-nvim

Dedicated Neovim app-config (`NVIM_APPNAME=bujo-nvim`) for BuJo daily notes in
`~/notes`. The local plugin lives in `lua/bujo/`; migration semantics are owned
by `lua/bujo/migrate.lua` and pinned by specs — never reimplement them by hand.

## Running tests

Run **from this directory** — from anywhere else, headless nvim can't find
`tests/minimal_init.lua`, prints an error, and hangs forever on an invisible
hit-enter prompt (headless mode still prompts). There is no Makefile despite
old comments saying `make test`; the command is:

```sh
NVIM_APPNAME=bujo-nvim nvim --headless -u tests/minimal_init.lua \
  -c "PlenaryBustedDirectory tests/ { minimal_init = 'tests/minimal_init.lua' }"
```

## Ticket/PR refs (`lua/bujo/links.lua`)

Daily notes carry bare refs (`MSG-1234`, `repo#56`), never full markdown
links: Neovim computes soft-wrap from raw buffer columns even under conceal
(neovim/neovim#14409, open), so concealed URLs make lines wrap weirdly.
`gx`/`<leader>o` reconstructs the URL (and opens `[[wikilinks]]`, see below);
`:BujoShortenLinks` converts old links;
extmarks give refs the render-markdown link look. Bare `https://` URLs are a
fourth ref kind (`url`, 󰌹 icon, opened verbatim) — bare because tree-sitter
only parses `<url>` autolinks (render-markdown owns those, so links.lua masks
them), never naked URLs.

`[[wikilinks]]` are a fifth kind (`note`) and the one that opens **inside**
nvim (`vim.cmd.edit`) instead of the browser. They are deliberately **not
decorated** here: unlike bare refs, `[[...]]` is a real tree-sitter node, so
render-markdown already draws it (`link.wiki` — 󱗖 icon, brackets concealed),
exactly like `<autolinks>`. `decorate()` skips any kind missing from `ICONS`;
adding a `note` entry would double the icon.

`note_path()` resolves against a **directory listing, never a stat on a built
path** — APFS is case-insensitive, so stat-ing `load testing guide.md` succeeds
for `Load Testing Guide.md` and returns a name no file actually has. The ladder
is verbatim title → `slug()` stem → case-folded, plus `[[YYYY-MM-DD]]` → the
daily note under `YYYY/MM/`. `slug()` is shared with `open_named_note`
(`:BujoNote`), which creates the files it resolves — do not fork it. A
dangling link **warns and creates nothing** (the vault already has one, and
guessing a naming style from a navigation keystroke is the surprising branch).

Bash test expressions (`[[ -n "$x" ]]`) are the false positive that matters —
the vault's how-to notes are full of them. `[[` is a shell keyword, so it
always has a space after it; `refs()` rejects any `[[...]]` padded with
whitespace. Pinned in `tests/links_spec.lua` with real lines from the vault.

**Adding a repo alias** (label ≠ GitHub repo name): add it to `aliases` in
`M.config` at the top of `links.lua`, and pin it in `tests/links_spec.lua`
(resolve + shorten cases). Symptom of a missing alias: `:BujoShortenLinks`
skips the link — by design, since a bare ref with an unknown alias would
reconstruct a nonexistent repo URL. When `notify_me` migrates from Bitbucket
to GitHub, delete its `bitbucket_repos` entry — that's the whole migration.

The `/morning` skill (`~/notes/.claude/skills/morning/SKILL.md`) writes bare
refs into daily notes and cites the alias table — keep the two in sync.

## @-mention note picker (`lua/bujo/mention.lua`)

Typing `@` in insert mode (markdown buffers) opens a Telescope picker over
vault notes and inserts `[[stem]]` at the cursor — the `@` itself is never
written; it's only the trigger key. The inserted stem is always the **on-disk
filename stem**, which `links.note_path` resolves on its first ladder rung —
never slug it (a slugged link resolves via rung 2 and diverges from what the
buffer shows). Quick-capture filenames (`YYYY-MM-DD Note N`) are opaque, so
the picker display leads with the note's H1 title; named notes sort by mtime
(newest first — the just-captured idea is the likeliest target), then dailies
newest first.

Mechanics pinned by hard-won constraints: the `@` mapping is `expr = true`
and therefore runs under **textlock** — it captures `(buf, row, col)`,
schedules the picker, and returns `''`/`'@'`; never re-read the cursor after
Telescope closes (leaving insert mode shifts it). Insertion resumes typing
via "park on last inserted byte + feedkeys `a`", not `startinsert`, which
lands one column short at EOL — the common case. Cancelling inserts nothing;
`should_trigger` owns the literal-`@` policy — fire only at line start or
after whitespace/`(` — so emails never open the picker (pinned in
`tests/mention_spec.lua`).

## Strikethrough (`lua/bujo/strike.lua`)

Done `[x]` and irrelevant `[-]` blocks are struck by this module, **not** by
render-markdown's `checkbox.scope_highlight` — that option draws one extmark
across the item's whole multi-line inline node, striking through the leading
indentation of child lines (no upstream option to trim it; checked at commit
f422cb5). strike.lua instead places one extmark per line from the first
non-blank column (the bullet) to EOL. Don't reintroduce `scope_highlight` in
`lua/plugins/render-markdown.lua`; you'd get a doubled, indent-crossing
strike.

A task's block (which lines strike with it) uses the **same rule as
`migrate.lua`**: subsequent deeper-indented lines, ended by a blank line or
a line at/above the task's indent. If one module's block rule ever changes,
change both — the specs pin each side. `[>]`/`[<]` are never struck: they
point to work that still exists elsewhere.

Strikes render only outside Insert/Replace mode: `decorate()` bails (after
clearing) when `nvim_get_mode()` reports `i`/`R`, and `InsertEnter`/
`InsertLeave` share the `TextChanged*` callback. The mode check lives in
`decorate()` on purpose — a `TextChangedI` recompute can never re-add marks
mid-insert.

## Priority marker (`lua/bujo/priority.lua`)

`- [ ] !task` marks a task important. The `!` is task **text**, deliberately
NOT a bracket state like `[!]`: the bracket char is a state machine owned by
migrate.lua (only `[ ]` migrates), `toggle` (only `[ ]`↔`[x]`), and
`pick_tasks` (only `[ ]` listed) — a `[!]` state would have to be taught to
all three and would be lost the moment the task toggles to `[x]`. As text,
the marker migrates verbatim across days and composes with every state
(`- [x] !...` = done important task). Don't "upgrade" it to a checkbox state.

The `!` is decorated with `virt_text_pos = 'overlay'`, not conceal — overlay
paints over the cell without changing line width, so soft-wrap stays honest
(conceal doesn't: neovim/neovim#14409, the same reason links are bare refs).
The icon in `M.config` must stay **one cell wide** or it paints over the
first letter of the task.

Per-state treatment lives in the `styles` table at the top of the module:
pending shouts (`BujoPriority` — default-linked to `DiagnosticWarn`, but
overridden to bold lotusOrange in `lua/plugins/kanagawa.lua` because lotus
maps DiagnosticWarn to a washed-out amber), `[x]`/`[-]` keep only a muted
icon (strike.lua owns the line), `[>]`/`[<]` are an open TODO — they render
the raw `!` untouched until decided. Pin any change in
`tests/priority_spec.lua`.

Same Insert-mode rule as strike.lua: `decorate()` clears then bails when the
mode is `i`/`R`, so the raw `!` is editable while typing.

## Folding (`lua/bujo/fold.lua`)

Folds come from **tree-sitter's markdown `folds.scm`**, not from a bujo rule:
`(list_item (list))` is already "a task with subtasks". Neovim bundles that
query with the markdown parser and it is byte-identical to nvim-treesitter's,
so the specs fold exactly what the app folds without putting the plugin on
the test rtp.

This is the one module that deliberately **does not share migrate.lua's block
rule**. A tree-sitter `list_item` can swallow a blank line (loose lists), so a
fold may cover a line migration would leave behind. Do not "fix" that: folding
decides what is hidden on screen, migration decides what moves between days.
The repo's usual "change both" instinct does not apply here.

`za` is remapped to `M.toggle`, which only touches a fold **starting on the
cursor line** (`M.starts_fold`, pinned by `tests/fold_spec.lua`). Native `za`
on a task with *no* subtasks closes the innermost fold containing the cursor —
the enclosing `(section (list))` — i.e. the entire day's note. `starts_fold`
asks `vim.treesitter.foldexpr(lnum)` for its `>N` form instead of comparing
`foldlevel()` across neighbouring lines, because two sibling tasks that both
have subtasks sit at the same level and the comparison misses the second one.

The gutter arrow is drawn by `M.gutter()` through **`statuscolumn`, never
`foldcolumn`**: at `auto:1` Neovim prints the fold *level digit* on any line
deeper than the column is wide, so every child line and every one-liner task
grows a stray `2`/`3`; `auto:3` trades that for three mostly-blank columns and
a doubled `▾▾` where two folds start on one line. Because the statuscolumn is
window-local and set on `FileType markdown`, `gutter()` keeps a filetype guard
— a window that switches to oil would otherwise run tree-sitter per line.

## Gotchas learned the hard way

- Ephemeral extmarks with `virt_text_pos = 'inline'` inside a decoration
  provider are silently **not rendered** — inline virtual text must join line
  layout before `on_line` runs. Use persistent extmarks recomputed on
  `TextChanged` (see `links.decorate()`).
- `startinsert { bang = true }` moves the cursor to end-of-line, so spec
  assertions on cursor position must expect EOL columns, not 0.
- You cannot genuinely enter Insert mode inside a headless spec:
  `:startinsert` is deferred until the main loop, and
  `nvim_feedkeys('i', 'x!', false)` kills the runner mid-file (the spec's
  output just stops, no failure, no summary). Stub `nvim_get_mode` instead
  (see the Insert-mode spec in `tests/strike_spec.lua`).
- On a **closed fold** with `foldtext = ''`, only *overlay* extmarks are
  painted — end-of-line virtual text is not (the fold fill takes the rest of
  the line). So render-markdown's icons and priority.lua's `!` survive a
  collapse, but a "N lines hidden" suffix via `virt_text` cannot be built
  that way; the trailing `fillchars` `fold:·` run is the tail signal instead.
- Headless Neovim still keeps a **screen grid**: `vim.fn.screenstring(row,
  col)` after `vim.cmd 'redraw'` returns what a line actually renders as.
  That is how the fold-gutter and extmark questions above were settled, and
  it beats reasoning about drawing order.
- `migrate.lua` is pure, so durability is the **caller's** job: `open_today`
  must commit today's note to disk *before* rewriting the source with `[>]`
  marks — reversed order turns any interruption into silent task loss.
  `tests/open_today_spec.lua` pins the write order.
