#!/usr/bin/env bash

set -euo pipefail

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/ivanlod3/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
INSTALL_BLESH="${INSTALL_BLESH:-1}"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
MANAGED_START="# >>> dotfiles bootstrap >>>"
MANAGED_END="# <<< dotfiles bootstrap <<<"

ensure_repo_in_place() {
  if [ "$SCRIPT_DIR" = "$DOTFILES_DIR" ]; then
    return
  fi

  if [ -d "$DOTFILES_DIR/.git" ]; then
    return
  fi

  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
}

backup_file_if_needed() {
  local target_file=$1

  if [ -e "$target_file" ] && [ ! -e "${target_file}.pre-dotfiles" ]; then
    cp "$target_file" "${target_file}.pre-dotfiles"
  fi
}

write_managed_block() {
  local target_file=$1
  local body=$2
  local tmp_file

  mkdir -p "$(dirname "$target_file")"
  touch "$target_file"
  backup_file_if_needed "$target_file"

  tmp_file=$(mktemp)
  awk -v start="$MANAGED_START" -v end="$MANAGED_END" '
    $0 == start { skip=1; next }
    $0 == end { skip=0; next }
    skip != 1 { print }
  ' "$target_file" > "$tmp_file"

  {
    cat "$tmp_file"
    printf '\n%s\n%s\n%s\n' "$MANAGED_START" "$body" "$MANAGED_END"
  } > "$target_file"

  rm -f "$tmp_file"
}

install_bash_bootstrap() {
  local bashrc_body bash_profile_body

  bashrc_body="[ -f \"$DOTFILES_DIR/shell/bashrc.local\" ] && . \"$DOTFILES_DIR/shell/bashrc.local\""

  bash_profile_body="[ -f \"$DOTFILES_DIR/shell/bash_profile.local\" ] && . \"$DOTFILES_DIR/shell/bash_profile.local\""

  write_managed_block "$HOME/.bashrc" "$bashrc_body"
  write_managed_block "$HOME/.bash_profile" "$bash_profile_body"
}

install_blesh() {
  local target_dir="${HOME}/.local/share"
  local tmpdir

  if [ "$INSTALL_BLESH" != "1" ]; then
    return
  fi

  if [ -r "${target_dir}/blesh/ble.sh" ]; then
    return
  fi

  if ! command -v curl >/dev/null 2>&1 || ! command -v tar >/dev/null 2>&1; then
    echo "Skipping ble.sh install: curl and tar are required."
    return
  fi

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' RETURN

  curl -fsSL https://github.com/akinomyoga/ble.sh/releases/download/nightly/ble-nightly.tar.xz \
    | tar -xJf - -C "$tmpdir"
  bash "$tmpdir/ble-nightly/ble.sh" --install "$target_dir"
}

detect_platform() {
  local uname_out
  uname_out=$(uname -s)
  case "$uname_out" in
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl"
      else
        echo "linux"
      fi
      ;;
    Darwin) echo "macos" ;;
    *) echo "unknown" ;;
  esac
}

print_next_steps() {
  local platform=$1
  cat <<EOF
Dotfiles bootstrap installed into:
  $HOME/.bashrc
  $HOME/.bash_profile

Recommended packages for $platform:
  bash-completion
  ble.sh
  fzf
  zoxide
  starship (optional)
  bat (optional)
  eza (optional)

Open a new shell or run:
  source ~/.bashrc
EOF
}

main() {
  ensure_repo_in_place
  install_bash_bootstrap
  install_blesh
  print_next_steps "$(detect_platform)"
}

main "$@"
