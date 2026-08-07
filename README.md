# How to use

This is for setting up a new Macos Computer, based on the [Strap Project](https://github.com/MikeMcQuaid/strap).
For setting up your computer:
1. You need to save the files in the same folder structure as this project, and name the repo `dotfiles`.
2. Access the page of [Strap](https://strap.mikemcquaid.com/) and download the `strap.sh` file, which is customized with the GitHub Token.
3. Execute that file, and see the magic happens, you may add the `--debug` flag in case something goes wrong.

Happy coding!

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

Why new packages default into the *profile* local: only the machine you ran
it on is known to want them — promotion to everyone is a deliberate one-line
move, never automatic.

## Lazygit configuration

Lazygit uses separate configurations depending on how it is launched:

- `dot/Library/Application Support/lazygit/config.yml` is the main macOS config used by `lazygit` and the `lg` alias.
- `dot/.config/lazygit/config.yml` is loaded explicitly by `lazygit.nvim`. Its `nvim-remote` editor preset opens files in the parent Neovim instance instead of starting a nested editor.

The setup script creates `~/Library/Application Support/lazygit` before running Stow. This makes Stow symlink only the tracked `config.yml`; lazygit's mutable `state.yml` remains a local file outside the repository.

Verify the terminal config location with:

```sh
lazygit --print-config-dir
```
