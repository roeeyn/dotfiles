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

### Round 2 on the personal laptop — per-machine keys + SSH signing

After pulling the latest `new-main`:

```sh
cd ~/.dotfiles && git pull
# Deliberate rotation: the current id_ed25519 is the OLD shared key whose
# encrypted blob sits in public git history. Move it aside so setup mints
# a fresh per-machine key:
mv ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.old
mv ~/.ssh/id_ed25519.pub ~/.ssh/id_ed25519.old.pub
# default gh scopes cannot manage keys — grant once:
gh auth refresh -h github.com -s admin:public_key,admin:ssh_signing_key
./script/setup      # generates + auto-registers with GitHub (gh must be
                    # authenticated as roeeyn; re-run after gh auth login if not)
```

Verify, in this order, BEFORE deleting anything on GitHub:

```sh
ssh -T git@github.com          # greets roeeyn using the NEW key
git -C ~/.dotfiles pull        # ssh transport still works
git commit --allow-empty -m "test: ssh signing" && git push
# -> the commit shows "Verified" on GitHub (SSH signing, no GPG involved)
```

Only then clean up (GitHub → Settings → SSH and GPG keys): remove the OLD
ssh key entry, and delete GPG key 615B67D406A71EC5 (old commits flip to
"Unverified" — accepted; the key must die because its encrypted secret is
public). Finally `rm ~/.ssh/id_ed25519.old*`.

### Key rotation checklist (from the public .enc blobs)

Everything below sat encrypted-with-ansible-vault in public git history;
treat all of it as compromised-if-the-vault-password-was-guessable.

| Secret | Where to rotate |
| --- | --- |
| SSH `id_ed25519` (active!) | GitHub personal (after new keys registered); Bitbucket AlertMedia account (work profile auths bitbucket.org with it — upload the work machine's new key); old servers `66.179.243.39` / `74.208.197.109` root authorized_keys if still alive; audit anywhere else the pubkey was pasted |
| SSH `id_rsa` (legacy) | Azure DevOps (`ssh.dev.azure.com` — personal profile still points `id_rsa` at it; replace key or delete the host entry if dead) |
| GPG `615B67D406A71EC5` | GitHub GPG keys → delete. Verified: the work `pass` store encrypts to a DIFFERENT key (`F450...93C5`) and is NOT affected; if the personal machine has its own `~/.password-store`, check its `.gpg-id` too |
| Unsplash API key | unsplash.com developer dashboard → regenerate |
| WakaTime API key | wakatime.com/settings → regenerate |
| The vault password itself | if `ansible_password.txt`'s password was ever reused as a real account password, rotate those accounts — it was the master secret for all of the above |

### Reviewing the migration (draft PR)

Create the draft PR from the personal machine (the work gh account is EMU
and cannot act on this repo), or via
<https://github.com/roeeyn/dotfiles/compare/master...new-main>:

```sh
gh pr create --draft --base master --head new-main \
  --title "Profile-based single-branch migration" \
  --body "Review-only draft; will be closed, not merged. Review commit by commit."
```

Do NOT review the whole Files-changed diff — it drags in ~99 already-lived-in
work-branch commits. Review these migration commits, in order (Commits tab,
one at a time):

| Commit | What to look at |
| --- | --- |
| `28ddd2d` | merge baseline — only the union .Brewfile resolution is new |
| `a6ae18e` | Phase 0: profiles/ skeleton, idempotent setup rewrite |
| `2e5bf98` | profile-switch semantics, strap-after-setup convergence pass |
| `e175829` | Phase 1: gitconfig include seam, ssh config.d split, alert_media out |
| `7caed8c` | .gitkeep collision fix, ~/.ssh fold guard |
| `deba83d` | select_profile implementation |
| `d62d393` | Phase 2: search-roots env seam, codex untrack, gpg-agent seam |
| `9dec42f` | Phase 4: Brewfile split (shared + .Brewfile.local include) |
| `42a8309` | prune: stale backups, work-only taps relocation |
| `c680ad6` | prune: dep removals per review |
| `d8f967b` | brew-sync script + docs |
| `d0bb807` | tlrc/bruno/zed promoted to shared |
| `55cbd2d` | sync-mcps retirement |

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
