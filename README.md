# How to use

This is for setting up a new Macos Computer, based on the [Strap Project](https://github.com/MikeMcQuaid/strap).
For setting up your computer:
1. You need to save the files in the same folder structure as this project, and name the repo `dotfiles`.
2. Access the page of [Strap](https://strap.mikemcquaid.com/) and download the `strap.sh` file, which is customized with the GitHub Token.
3. Execute that file, and see the magic happens, you may add the `--debug` flag in case something goes wrong.

Happy coding!

## TEMPORARY — testing `new-main` on the personal machine

> Delete this section once both machines run this branch.

```sh
cd ~/.dotfiles
cp dot/.codex/config.toml /tmp/codex-backup.toml   # untracked on this branch
git fetch origin
git checkout -- dot/.codex/config.toml 2>/dev/null || true
git checkout new-main
cp /tmp/codex-backup.toml dot/.codex/config.toml   # restore; gitignored now
./script/setup                                     # defaults to the personal profile
```

Verify (all four must pass):

```sh
git config user.email                    # rodrigo.medina.neri@gmail.com
git config commit.gpgsign                # true
ssh -G github.com | grep identityfile    # ~/.ssh/id_ed25519
ls -l ~/.gitconfig.local ~/.ssh/config.d/personal ~/.Brewfile.local ~/.gnupg/gpg-agent.conf
```

Then reconcile Homebrew:

```sh
brew bundle --global             # installs shared promotions (tlrc, bruno, zed, ...)
brew bundle cleanup --global     # review the "Would uninstall" list, then add --force
```

Also open a NEW terminal and confirm zsh starts silently (no missing-file
errors) and git/ssh/lazygit feel normal. If ssh grabs the wrong key or a
symlink above is missing, stop and report — do not force anything.

Rollback if needed: `git checkout master && ./script/setup` is NOT enough
(master predates profiles); instead `git checkout master`, then manually
`stow --restow dot/ files/` and re-check `git config user.email`.

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

## Updating the Brewfiles

`dot/.Brewfile` declares the shared packages and includes `~/.Brewfile.local`,
which the stowed profile provides. **Do not run `brew bundle dump --global
--force`** — it would overwrite the shared file with this machine's flat
package list. Instead:

```sh
script/brew-sync           # report drift between installed and declared
script/brew-sync --apply   # append new packages to this machine's .Brewfile.local
```

New packages land in the profile's `.Brewfile.local`; move a line into
`dot/.Brewfile` when both machines should have it. To remove a package,
delete its line and run `brew bundle cleanup --global` to uninstall strays.

## Lazygit configuration

Lazygit uses separate configurations depending on how it is launched:

- `dot/Library/Application Support/lazygit/config.yml` is the main macOS config used by `lazygit` and the `lg` alias.
- `dot/.config/lazygit/config.yml` is loaded explicitly by `lazygit.nvim`. Its `nvim-remote` editor preset opens files in the parent Neovim instance instead of starting a nested editor.

The setup script creates `~/Library/Application Support/lazygit` before running Stow. This makes Stow symlink only the tracked `config.yml`; lazygit's mutable `state.yml` remains a local file outside the repository.

Verify the terminal config location with:

```sh
lazygit --print-config-dir
```
