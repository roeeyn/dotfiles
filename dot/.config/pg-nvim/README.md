# pg-nvim

`pg-nvim` is a separate Neovim app meant to be psql's `\e` query editor — a
SQL-aware sibling of `slim-nvim`.

It uses `NVIM_APPNAME=pg-nvim`, so it has its own config, plugin install path,
state, and cache, isolated from both the main `nvim` setup and `slim-nvim`.

## How it wires into psql

psql resolves the `\e` / `\edit` editor from `$PSQL_EDITOR` before
`$EDITOR`/`$VISUAL`. Two pieces set that up:

- **`~/.psqlrc`** runs on every psql start and owns the editor + history. Its
  `\setenv PSQL_EDITOR 'pg-nvim'` **wins over the environment**, so this — not a
  shell export — is the source of truth for which editor `\e` uses.
- **The `db` wrapper** (`dot/.config/zsh/db.zsh`) exports `PG_NVIM_SERVICE` so
  pg-nvim knows which service the buffer belongs to (for schema completion).
  `PGPASSWORD` (from `pass`) is also already in psql's env and is inherited by
  pg-nvim.

So pressing `\e` inside a `db <service>` session opens the current query buffer
in pg-nvim. On save, psql re-parses and runs whatever the buffer contains.

## What it includes

- `everforest-nvim` — distinct green colorscheme, so pg-nvim is recognizable at
  a glance vs gruvbox (slim-nvim) and tokyonight (main nvim)
- `eyeliner.nvim` — fast motion hints
- `nvim-treesitter` — SQL syntax highlighting (`sql` parser auto-installed;
  pinned to the `master` branch, see Notes)
- `nvim-cmp` + `vim-dadbod-completion` (+ `vim-dadbod`) — schema-aware
  table/column completion
- `copilot.lua` + `copilot-cmp` — GitHub Copilot suggestions inside the cmp menu
  (mirrors main nvim; reuses the shared `~/.config/github-copilot` auth)
- `lspkind.nvim` — cmp menu icons (incl. the Copilot glyph)

Completion triggers with `<C-n>` / `<C-p>` (they open the menu when it's closed,
then navigate), `<C-y>` confirms — mirroring main nvim. `<C-Space>` is also bound
but macOS intercepts it, so the `<C-n>` overload is the working trigger.

## Schema-aware completion

`config/vim.lua` sets `b:db = 'postgresql:///?service=' .. $PG_NVIM_SERVICE` on
SQL buffers. The empty-host service URL defers host/db/user resolution to
`~/.pg_service.conf`, and `PGPASSWORD` is inherited from psql — so no credentials
are duplicated. `vim-dadbod-completion` introspects that connection once and
caches the schema for the session (`:DBCompletionClearCache` to refresh); it
opens no connection until you actually trigger completion. The service's
`default_transaction_read_only=on` keeps introspection read-only.

## Formatting

`config/vim.lua` sets `formatprg = 'pg_format -'` on SQL buffers, so Vim's `gq`
pipes a motion/selection through [pgFormatter](https://github.com/darold/pgFormatter)
and swaps in the result. It's an in-buffer filter — **no write, so psql never
runs**. Select just your query and `gq`; the scissors history block stays
untouched because it's outside the selection. Requires `pg_format` on `PATH`
(`brew install pgformatter`) — no nvim plugin involved.

## Query-history block (the `\e` scissors)

On opening a psql edit buffer (`psql.edit.*.sql`), pg-nvim appends a block of
your recent queries below a scissors line, newest first, for quick recall:

```sql
-- ───────────────── 8< ─────────────────
-- Recent queries (newest first). This block is removed on save.
```

The history is read from the single shared `~/.psql_history` by
`pg-recent-queries`, which decodes libedit's `_HiStOrY_V2_` octal-escaped
format (macOS psql links libedit, not GNU readline) and dedupes globally.

`BufWritePre` strips the scissors line and everything below before the buffer is
written, so psql only ever runs your actual query — never the recalled history.
The cut line is matched on the box-drawing fragment `─ 8< ─` (U+2500 dashes,
never typed in real SQL), so SQL like `WHERE n > 8` is never mistaken for it.

## Setup from scratch

pg-nvim depends on a few files **outside this directory**. To stand it up on a
fresh machine (in this dotfiles repo everything is live via the `~/.config` and
`~/.local` symlinks, so there's nothing to stow):

### 1. `~/.local/bin/` scripts (must be on `PATH`)

- `pg-nvim` — launcher; sets `NVIM_APPNAME=pg-nvim` and `exec nvim "$@"`.
- `pg-recent-queries` — reads/decodes `~/.psql_history` for the scissors block.

Both must be executable (`chmod +x`) and on `PATH` (`~/.local/bin` is exported in
`dot/.zshrc`).

### 2. `~/.psqlrc` — point `\e` at pg-nvim + centralize history

```psqlrc
-- psql checks PSQL_EDITOR before EDITOR/VISUAL; \setenv wins over the env.
\setenv PSQL_EDITOR 'pg-nvim'

-- Single shared, deduped history — pg-nvim's \e recall reads this one file.
\set HISTFILE ~/.psql_history
\set HISTCONTROL ignoredups
\set HISTSIZE 5000
```

(Do **not** template `HISTFILE` per-database, e.g. `~/.psql_history-:DBNAME` —
that splits history into per-DB files and the recall block would read a stale
central file.)

### 3. The `db` wrapper — export `PG_NVIM_SERVICE`

In `dot/.config/zsh/db.zsh`, the interactive psql call passes the service name:

```sh
PGPASSWORD="$pw" PG_NVIM_SERVICE="$svc" psql "service=$svc" "$@"
```

`PG_NVIM_SERVICE` is the only pg-nvim-specific thing here; editor and history
live in `~/.psqlrc`.

### 4. `~/.pg_service.conf` — connection profiles (for completion)

Schema completion connects via `postgresql:///?service=<name>`, so each service
must be defined here, ideally read-only:

```ini
[test03-nc-rr]
host=...
port=5432
user=...
dbname=notify_me_db
options=-c default_transaction_read_only=on
```

### 5. SQL formatting (optional)

```sh
brew install pgformatter   # provides `pg_format` (Perl; no nvim plugin needed)
```

`config/vim.lua` sets `formatprg = 'pg_format -'` for `sql` buffers, so `gq`
formats a selection in place.

### 6. Copilot prerequisites

- **Node.js** on `PATH` (any recent LTS; copilot.lua shells out to it).
- **Auth**: run `:Copilot auth` once in any nvim — the token lives in the shared
  `~/.config/github-copilot/` (not `NVIM_APPNAME`-scoped), so pg-nvim reuses it.

### 7. First launch

`lazy.nvim` bootstraps and installs plugins on first start. The `sql` treesitter
parser auto-installs; if highlighting is missing, run `:TSInstallSync sql`.

## Entry point

The launcher script lives at `~/.local/bin/pg-nvim`, on `PATH` via `dot/.zshrc`.

## Layout

- `init.lua` loads core config and plugin bootstrap
- `lua/config/vim.lua` — editor options, the `\e` scissors autocmds, and the
  `b:db` service wiring
- `lua/config/lazy.lua` — bootstraps `lazy.nvim`
- `lua/plugins/*.lua` — one file per plugin
- `~/.local/bin/pg-recent-queries` — psql history decoder/deduper

## Notes

- plugins for this app install under `~/.local/share/pg-nvim`
- history is global on purpose (queries are reusable across services); only
  per-service concerns (e.g. schema completion) are isolated by `PG_NVIM_SERVICE`
- `nvim-treesitter` follows the `main` rewrite (the frozen `master` branch
  crashes on Neovim 0.12): `sql` is installed via `require('nvim-treesitter').install`
  and highlighting is started by a `FileType` autocmd (`vim.treesitter.start()`),
  since the rewrite has no `.configs` API
