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

## Gotchas learned the hard way

- Ephemeral extmarks with `virt_text_pos = 'inline'` inside a decoration
  provider are silently **not rendered** — inline virtual text must join line
  layout before `on_line` runs. Use persistent extmarks recomputed on
  `TextChanged` (see `links.decorate()`).
- `startinsert { bang = true }` moves the cursor to end-of-line, so spec
  assertions on cursor position must expect EOL columns, not 0.
