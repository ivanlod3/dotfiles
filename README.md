# dotfiles

Portable bash dotfiles for Linux, macOS and WSL.

## Goals

- Keep the interactive shell on `bash`.
- Make scripts stay portable and POSIX-friendly.
- Layer personal config on top of host defaults instead of replacing them outright.
- Add modern shell UX with optional tools instead of shell-specific frameworks.

## Features

- `bash-completion` for richer command completion
- `ble.sh` for autosuggestions and syntax highlighting
- `fzf` for fuzzy completion and history search
- `zoxide` for smarter directory jumping
- `starship` as an optional cross-platform prompt
- conditional `nvm` loading only inside your `dev` container

## Install

Clone the repo and run:

```bash
git clone https://github.com/ivanlod3/dotfiles.git ~/.dotfiles
~/.dotfiles/install.sh
```

Quick copy/paste:

```bash
git clone https://github.com/ivanlod3/dotfiles.git ~/.dotfiles && ~/.dotfiles/install.sh
```

The installer does not replace your shell files with symlinks.
Instead it appends a managed bootstrap block to:

- `~/.bashrc`
- `~/.bash_profile`

That bootstrap then loads:

- `~/.dotfiles/shell/bashrc.local`
- `~/.dotfiles/shell/bash_profile.local`

Existing host files are preserved, and the first pre-dotfiles version is saved as:

- `~/.bashrc.pre-dotfiles`
- `~/.bash_profile.pre-dotfiles`

By default the installer also installs `ble.sh` into `~/.local/share/blesh` if `curl` and `tar` are available.

## Uninstall

Run:

```bash
~/.dotfiles/uninstall.sh
```

That removes only the managed bootstrap block, leaving any later manual edits in place.
It also removes `~/.local/share/blesh`.

If you want to restore the original host files saved during first install:

```bash
RESTORE_BACKUP=1 ~/.dotfiles/uninstall.sh
```

That restores:

- `~/.bashrc.pre-dotfiles`
- `~/.bash_profile.pre-dotfiles`

If you want to keep `ble.sh` installed:

```bash
KEEP_BLESH=1 ~/.dotfiles/uninstall.sh
```

## Recommended packages

Linux:

```bash
sudo apt install bash-completion fzf zoxide curl tar
```

macOS:

```bash
brew install bash bash-completion@2 fzf zoxide starship bat eza gnu-tar
```

WSL:

Use the Linux instructions for your distro inside WSL.

## Notes

- The repo follows a `layer` model: keep host defaults, then load your personal config.
- Set `INSTALL_BLESH=0` if you want to skip the automatic `ble.sh` install.
- `uninstall.sh` removes only the managed block by default; use `RESTORE_BACKUP=1` for full rollback.
- `uninstall.sh` removes `ble.sh` by default; use `KEEP_BLESH=1` to leave it installed.
- `starship`, `bat` and `eza` are optional. The shell config only enables them when present.
