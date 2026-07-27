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
`gx`/`<leader>o` reconstructs the URL; `:BujoShortenLinks` converts old links;
extmarks give refs the render-markdown link look.

**Adding a repo alias** (label ≠ GitHub repo name): add it to `aliases` in
`M.config` at the top of `links.lua`, and pin it in `tests/links_spec.lua`
(resolve + shorten cases). Symptom of a missing alias: `:BujoShortenLinks`
skips the link — by design, since a bare ref with an unknown alias would
reconstruct a nonexistent repo URL. When `notify_me` migrates from Bitbucket
to GitHub, delete its `bitbucket_repos` entry — that's the whole migration.

The `/morning` skill (`~/notes/.claude/skills/morning/SKILL.md`) writes bare
refs into daily notes and cites the alias table — keep the two in sync.

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
