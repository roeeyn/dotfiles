# How to use

This is for setting up a new Macos Computer, based on the [Strap Project](https://github.com/MikeMcQuaid/strap).
For setting up your computer:
1. You need to save the files in the same folder structure as this project, and name the repo `dotfiles`.
2. Access the page of [Strap](https://strap.mikemcquaid.com/) and download the `strap.sh` file, which is customized with the GitHub Token.
3. Execute that file, and see the magic happens, you may add the `--debug` flag in case something goes wrong.
4. On a work machine, pick the profile once: `./script/setup work`
   (personal is the default; the choice sticks via `~/.dotfiles-profile`).
5. To register the machine's SSH key with GitHub (setup generates it):
   `gh auth login`, then
   `gh auth refresh -h github.com -s admin:public_key,admin:ssh_signing_key`,
   then re-run `./script/setup` — it registers the key (auth + signing) and
   converges anything a fresh run couldn't do yet. It's idempotent; re-run
   it whenever in doubt.

Happy coding!

## Repository layout

```
dot/        shared Stow package, stowed to ~ on every machine.
            ~/.config and ~/.local are FOLDED symlinks into it, so edits
            here are live immediately — and profile packages can never
            ship files under those two paths.
files/      second shared package (plain top-level files).
profiles/
  personal/ personal-only overlay (lives in this repo).
  work/     work-only overlay — a PRIVATE repo (roeeyn/dotfiles-work)
            cloned here by script/setup and gitignored, so work config
            never touches this public repo. Commit/push work changes
            inside that folder, not here.
script/
  setup             the only install entrypoint: stows shared + one
                    profile, scaffolds ~/.ssh + dot/env/.env, generates
                    and registers the machine SSH key, runs the profile's
                    hooks/setup. Idempotent.
  strap-after-setup Strap's post-dependencies hook: re-runs setup and
                    converges brew.
  brew-sync         Brewfile ledger reconciliation (see below).
  brave-sync        extract/apply Brave's shortcuts, theme and layout
                    (Brave cannot be stowed — it rewrites its own prefs).
  git-hooks/        tracked git hooks; setup symlinks them into
                    .git/hooks (post-merge: Brewfile-change reminder).
```

Where does a change go?

| You want to add… | Put it in |
| --- | --- |
| a tool/config for both machines | `dot/` — commit here; other machine runs `git pull && ./script/setup` |
| personal-only config | `profiles/personal/` (this repo) — **root-level paths only** |
| work-only config | `profiles/work/` (the private repo — commit + push there) — root-level only |
| a secret / API key | `dot/env/.env` (gitignored, per machine); add the key *name* to `.example.env` |
| a Homebrew package | install it, then `script/brew-sync --apply` (see Brewfiles) |
| a Brave shortcut, theme or layout tweak | set it in Brave, then `script/brave-sync` and commit the dump |
| an MCP server | see "MCP servers" below |

## Never do this

- `brew bundle dump --global --force` — flattens the shared/profile
  Brewfile split (use `script/brew-sync`).
- Commit secrets or work-identifying content here — **this repo is public**
  (work config → private overlay; secrets → `.env`).
- Ship profile files under `.config/` or `.local/` — those are folded
  symlinks owned by `dot/`; setup will abort on the stow conflict.
- Stow anything inside a Brave profile directory, or dump Brave's `Web Data`
  into this repo — see Brave settings below.

## Profiles

One branch serves every machine. `dot/` and `files/` are the shared Stow
packages; `profiles/<name>/` overlays machine-specific files on top:

- `profiles/personal/` lives in this repo.
- `profiles/work/` is gitignored here and cloned by `script/setup` from a
  private repo, so work config never touches this public one.

`script/setup` picks the profile as: CLI arg > `DOTFILES_PROFILE` env >
`~/.dotfiles-profile` marker > `personal`, and unstows the previous profile
before stowing a new one. First run on a work machine: `script/setup work`
(sticky afterwards).

SSH keys are per machine and never enter the repo: setup generates
`~/.ssh/id_ed25519` on first run and registers it with GitHub (auth +
signing) when `gh` is authenticated as the personal account — otherwise it
prints the commands to do it. Commits are signed with that same key via
SSH signing (`gpg.format = ssh`); GPG is no longer involved in git.

## MCP servers (Claude Code + opencode)

Both AI tools follow the same rule as everything else here: **shared servers
live in shared files, machine-specific servers live in the stowed profile.**
The two tools read different files, so the profile ships one file per tool:

| Tool | Shared servers | Profile servers (stowed to `~`) |
| --- | --- | --- |
| Claude Code | — (no shared file) | `profiles/<name>/.mcp.json` → `~/.mcp.json` (the complete list per profile) |
| opencode | `dot/.config/opencode/opencode.jsonc` (`mcp` block) | `profiles/<name>/.opencode-profile.jsonc` → `~/.opencode-profile.jsonc` |

How each tool picks the profile servers up:

- **Claude Code** reads `~/.mcp.json` directly; whichever profile is stowed
  owns that symlink. Because JSON has no include, each profile's file lists
  its complete set (the two shared entries are duplicated by design).
- **opencode** deep-merges config sources: the shared
  `~/.config/opencode/opencode.jsonc` loads first, then the file pointed to
  by `OPENCODE_CONFIG` merges on top. `.zshrc` exports
  `OPENCODE_CONFIG=~/.opencode-profile.jsonc` only when that file exists, so
  the profile fragment only needs the *additions*, never a copy of the
  shared config.

To add a server: for everyone → opencode's shared `mcp` block, plus BOTH
profiles' `.mcp.json`; for one profile → that profile's two files
(`.mcp.json` and `.opencode-profile.jsonc`). Machine-local one-offs for
Claude can also use `claude mcp add -s user` (lives in `~/.claude.json`,
never versioned). Profile switching needs no extra care: `script/setup`
unstows the old profile's files before stowing the new ones.

## Updating the Brewfiles

Two files declare what a machine installs: `dot/.Brewfile` (shared by every
machine) plus `~/.Brewfile.local` (stowed by the profile: work extras or
personal extras). Strap's `brew bundle --global` reads both through the
`~/.Brewfile` symlink.

**Never run `brew bundle dump --global --force`** — it rewrites `~/.Brewfile`
with this machine's flat package list, destroying the shared/profile split.

Two tools with two distinct jobs:

- **`script/brew-sync` edits the ledger.** It compares what is *installed*
  against what is *declared* (shared + local) and reports the drift in both
  directions. It NEVER installs or uninstalls anything.
- **`brew bundle cleanup --global` enforces the ledger.** It uninstalls
  packages that are installed but declared nowhere. (`brew bundle --global`
  is the other half of enforcement: it installs what is declared but
  missing.)

Day-to-day recipes:

| You did / want | Run |
| --- | --- |
| `brew install`ed something new and want to keep it | `script/brew-sync --apply` — appends it to this machine's `.Brewfile.local` |
| Want that new package on BOTH machines | after `--apply`, move its line from `.Brewfile.local` into `dot/.Brewfile` |
| Stop wanting a package | delete its line from whichever file declares it, then `brew bundle cleanup --global` (review, then `--force`) |
| Fresh machine / after a pull | `brew bundle --global` installs anything newly declared |
| Just checking for drift | `script/brew-sync` (dry-run is the default; changes nothing) |

A `post-merge` git hook (tracked in `script/git-hooks/`, symlinked into
`.git/hooks` by `script/setup`) prints a `brew bundle --global` reminder
whenever a pull changes any Brewfile. Reminder only — it never runs brew.
Since `.git/hooks` is never synced by git, a machine picks the hook up on
its next `script/setup` run, not on pull.

Why new packages default into the *profile* local: only the machine you ran
it on is known to want them — promotion to everyone is a deliberate one-line
move, never automatic.

## Brave settings (`script/brave-sync`)

Brave cannot be stowed. Chromium writes `Preferences` as
write-temp-then-`rename()`, so a symlink is *replaced* by a real file on the
first write — and that file is ~150 KB of volatile state (engagement scores,
per-site counters, telemetry). So it is extract/apply instead, same idiom as
`brew-sync`: dump by default, `--apply` to write back.

Tracked in `dot/.config/brave/brave-settings.json` (shared — these are personal
browser preferences, and the file carries nothing work-identifying):

| | how it is stored | applies? |
| --- | --- | --- |
| Keyboard shortcuts | a **diff** against Brave's own `default_accelerators` | yes |
| Theme | `#RRGGBB` accent + Material variant + theme id | yes |
| Layout / toolbar | the explicit `UI_PREFS` allowlist in the script | yes |
| Default search engine | `short_name` + `keyword` | **no — checked only** |

Shortcuts are stored as a diff, not a snapshot, because Brave adds command IDs
every release: each machine keeps its own stock map and only the handful of
real overrides travel. `--apply` **reconstructs** — this machine's own
`default_accelerators` plus the tracked diff — so the machines converge instead
of drifting.

The **default engine cannot be written**. `default_search_provider.guid` in
plain `Preferences` is only a pointer; Brave rebuilds it on launch from the
HMAC-protected `template_url_data` in `Secure Preferences` (verified
2026-09-04 — pointing it at DuckDuckGo and relaunching put it straight back to
Google, with `reset_occurred` still false). `--apply` reports the mismatch and
you change it by hand in Settings → Search engine. Do not try to work around
this by writing or deleting the protected value — that is anti-hijacking
machinery, and the one-time manual step is the accepted trade.

Custom search engines (`Web Data`) are deliberately **not** tracked — that
SQLite table holds work site-searches and this repo is public. Splitting them
between `dot/` and `profiles/work/` is a separate, still-unbuilt stage.

Day-to-day recipes:

| You did / want | Run |
| --- | --- |
| Changed a shortcut, theme or layout pref in Brave | `script/brave-sync`, then commit the artifact |
| Push those settings to the other machine | commit + push here; on the other machine `git pull`, quit Brave, `script/brave-sync --apply` |
| See what a machine would lose before applying | `script/brave-sync` (dumps *its* values), read `git diff`, then `git checkout dot/.config/brave/` to restore the incoming ones |
| Track one more UI pref | add its dotted path to `UI_PREFS` at the top of the script, re-dump |
| Just checking for drift | `script/brave-sync` — it only ever writes the repo file, never Brave |

**The first `--apply` on a machine is the destructive one.** Reconstruct wipes
any shortcut that machine customized but never dumped. `--apply` prints those
before writing and keeps a timestamped `Preferences` backup, but the real guard
is the preview row above — the dump is harmless to Brave, so run it, read the
diff, then `git checkout` it away. `--apply` also refuses to run while Brave is
up, because Brave rewrites `Preferences` on exit and would undo the whole thing.

There is no merge: a dump overwrites the artifact wholesale, so whichever
machine you dump on wins. Change settings in one place, dump there, apply on
the other.

Three things stay per-machine: `brave.dark_mode` is deliberately untracked, so
each machine follows its own OS appearance; `vertical_tabs_expanded_width` is
in pixels, so drop it from `UI_PREFS` if the screens differ; and the script
targets Brave's `Default` profile only.

Why `UI_PREFS` is an explicit allowlist rather than "everything under
`brave.*`": only the accelerators ship a `default_*` baseline to diff against.
Chromium omits any pref left at its default, so there is nothing to compare the
rest to — and that same subtree holds the `p3a_*` telemetry counters and
`bandwidth_saved_bytes`. Naming the keys is what keeps this a settings file
instead of a state file.

## zj-radar (Zellij agent sidebar)

The shared Zellij config expects [zj-radar](https://github.com/marktoda/zj-radar):
`config.kdl` carries the managed `radar` alias and `layouts/default.kdl` pins the
rail. The CLI binary and the wasm are per-machine artifacts (gitignored), so a
new machine bootstraps them by hand. The same steps upgrade an existing machine.

```sh
# 1. CLI — ZJ_RADAR_BIN_DIR keeps the binary out of the stowed ~/.local/bin
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/marktoda/zj-radar/releases/latest/download/install.sh \
  | ZJ_RADAR_BIN_DIR="$HOME/bin" sh

# 2. wasm — BY HAND. `setup zellij` will NOT install it here; see below.
V="v$(zj-radar --version | awk '{print $2}')"
mkdir -p ~/.config/zellij/plugins
cd "$(mktemp -d)"
curl -sSLO "https://github.com/marktoda/zj-radar/releases/download/$V/zj_radar.wasm"
curl -sSLO "https://github.com/marktoda/zj-radar/releases/download/$V/zj_radar.wasm.sha256"
shasum -a 256 -c zj_radar.wasm.sha256   # must print "zj_radar.wasm: OK"
install -m 644 zj_radar.wasm ~/.config/zellij/plugins/zj_radar.wasm

# 3. permission grant + layout rail (config/layout already stowed) — writes
#    ~/Library/Caches/org.Zellij-Contributors.Zellij/permissions.kdl
zj-radar setup zellij --yes

# 4. Claude Code producer — setup only WIRES it; the version comes from the
#    plugin manager, so upgrades need both lines
zj-radar setup claude --yes
claude plugin marketplace update zj-radar && claude plugin update zj-radar-claude

# 5. doctor — everything should be ok
zj-radar setup --check zellij claude
```

Pin a release with `ZJ_RADAR_VERSION=vX.Y.Z` on step 1 (and the matching tag in
step 2) if the machines should match versions.

**Why step 2 is manual** (upstream bug, confirmed against v0.4.1): in
`crates/cli/src/setup/zellij.rs` the wasm copy is a side effect of the
`config.kdl` write, so it only runs when that file actually changes. Our
`config.kdl` ships the managed alias already, so setup always takes the "config
already up to date" path — it downloads the wasm, prints `checksum verified`,
exits 0, and never installs it. `--download`, `--wasm <path>` and `--force` all
short-circuit the same way.

What the doctor reports depends on what is already on disk: a fresh machine gets
a truthful `missing wasm`, but on an upgrade `setup --check` only checks that *a*
wasm exists, not which version — so a stale sidebar still reports `ok`. After any
upgrade, confirm the file really moved:

```sh
shasum -a 256 ~/.config/zellij/plugins/zj_radar.wasm   # must match the release's .sha256
```

Restart Zellij afterwards — running sessions keep the old wasm in memory. The
rail is live on the next `zellij` launch (existing sessions pick it up on a new
tab or a restart); the Claude producer only attaches to *new* Claude Code
sessions.

## Lazygit configuration

Lazygit uses separate configurations depending on how it is launched:

- `dot/Library/Application Support/lazygit/config.yml` is the main macOS config used by `lazygit` and the `lg` alias.
- `dot/.config/lazygit/config.yml` is loaded explicitly by `lazygit.nvim`. Its `nvim-remote` editor preset opens files in the parent Neovim instance instead of starting a nested editor.

The setup script creates `~/Library/Application Support/lazygit` before running Stow. This makes Stow symlink only the tracked `config.yml`; lazygit's mutable `state.yml` remains a local file outside the repository.

Verify the terminal config location with:

```sh
lazygit --print-config-dir
```
