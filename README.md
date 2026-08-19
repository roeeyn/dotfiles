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
| an MCP server | see "MCP servers" below |

## Never do this

- `brew bundle dump --global --force` — flattens the shared/profile
  Brewfile split (use `script/brew-sync`).
- Commit secrets or work-identifying content here — **this repo is public**
  (work config → private overlay; secrets → `.env`).
- Ship profile files under `.config/` or `.local/` — those are folded
  symlinks owned by `dot/`; setup will abort on the stow conflict.

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

## zj-radar (Zellij agent sidebar)

The shared Zellij config expects [zj-radar](https://github.com/marktoda/zj-radar):
`config.kdl` carries the managed `radar` alias and `layouts/default.kdl` pins the
rail. The CLI binary and the wasm are per-machine artifacts (gitignored), so a
new machine bootstraps them by hand:

```sh
# CLI — ZJ_RADAR_BIN_DIR keeps the binary out of the stowed ~/.local/bin
curl --proto '=https' --tlsv1.2 -LsSf \
  https://github.com/marktoda/zj-radar/releases/latest/download/install.sh \
  | ZJ_RADAR_BIN_DIR="$HOME/bin" sh
zj-radar setup zellij --download --yes   # wasm + permission grant (config/layout already stowed)
zj-radar setup claude --yes              # Claude Code producer (marketplace plugin)
zj-radar setup --check zellij claude     # doctor — everything should be ok
```

Pin a release with `ZJ_RADAR_VERSION=vX.Y.Z` on the first two commands if the
machines should match versions.

## Lazygit configuration

Lazygit uses separate configurations depending on how it is launched:

- `dot/Library/Application Support/lazygit/config.yml` is the main macOS config used by `lazygit` and the `lg` alias.
- `dot/.config/lazygit/config.yml` is loaded explicitly by `lazygit.nvim`. Its `nvim-remote` editor preset opens files in the parent Neovim instance instead of starting a nested editor.

The setup script creates `~/Library/Application Support/lazygit` before running Stow. This makes Stow symlink only the tracked `config.yml`; lazygit's mutable `state.yml` remains a local file outside the repository.

Verify the terminal config location with:

```sh
lazygit --print-config-dir
```
