# How to use

This is for setting up a new Macos Computer, based on the [Strap Project](https://github.com/MikeMcQuaid/strap).
For setting up your computer:
1. You need to save the files in the same folder structure as this project, and name the repo `dotfiles`.
2. Access the page of [Strap](https://strap.mikemcquaid.com/) and download the `strap.sh` file, which is customized with the GitHub Token.
3. Execute that file, and see the magic happens, you may add the `--debug` flag in case something goes wrong.

Happy coding!

## Lazygit configuration

Lazygit uses separate configurations depending on how it is launched:

- `dot/Library/Application Support/lazygit/config.yml` is the main macOS config used by `lazygit` and the `lg` alias.
- `dot/.config/lazygit/config.yml` is loaded explicitly by `lazygit.nvim`. Its `nvim-remote` editor preset opens files in the parent Neovim instance instead of starting a nested editor.

The setup script creates `~/Library/Application Support/lazygit` before running Stow. This makes Stow symlink only the tracked `config.yml`; lazygit's mutable `state.yml` remains a local file outside the repository.

Verify the terminal config location with:

```sh
lazygit --print-config-dir
```
