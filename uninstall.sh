#!/usr/bin/env bash

set -euo pipefail

KEEP_BLESH="${KEEP_BLESH:-0}"
RESTORE_BACKUP="${RESTORE_BACKUP:-0}"
MANAGED_START="# >>> dotfiles bootstrap >>>"
MANAGED_END="# <<< dotfiles bootstrap <<<"

strip_managed_block() {
  local target_file=$1
  local tmp_file

  if [ ! -e "$target_file" ]; then
    return
  fi

  tmp_file=$(mktemp)
  awk -v start="$MANAGED_START" -v end="$MANAGED_END" '
    $0 == start { skip=1; next }
    $0 == end { skip=0; next }
    skip != 1 { print }
  ' "$target_file" > "$tmp_file"

  mv "$tmp_file" "$target_file"
}

restore_backup_if_present() {
  local target_file=$1
  local backup_file="${target_file}.pre-dotfiles"

  if [ -e "$backup_file" ]; then
    cp "$backup_file" "$target_file"
  else
    strip_managed_block "$target_file"
  fi
}

remove_blesh_if_installed() {
  if [ "$KEEP_BLESH" != "1" ]; then
    rm -rf "$HOME/.local/share/blesh"
  fi
}

main() {
  if [ "$RESTORE_BACKUP" = "1" ]; then
    restore_backup_if_present "$HOME/.bashrc"
    restore_backup_if_present "$HOME/.bash_profile"
  else
    strip_managed_block "$HOME/.bashrc"
    strip_managed_block "$HOME/.bash_profile"
  fi
  remove_blesh_if_installed
  echo "Dotfiles bootstrap removed."
}

main "$@"
