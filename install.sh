#!/usr/bin/env bash
# install.sh — lobster-skills installer (symlink based)
#
# Commands:
#   ./install.sh list
#   ./install.sh status
#   ./install.sh install <skill-name>
#   ./install.sh uninstall <skill-name>
#   ./install.sh update <skill-name>
#
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_DIR="$ROOT/skills"
DEST_DIR="$HOME/.openclaw/skills"

usage() {
  echo "usage: $0 <list|status|install|uninstall|update> [skill-name]" >&2
}

list_skills() {
  ls "$SRC_DIR" 2>/dev/null || true
}

status() {
  mkdir -p "$DEST_DIR"
  echo "managed skills dir: $DEST_DIR"
  echo
  for s in $(list_skills); do
    local dest="$DEST_DIR/$s"
    if [[ -L "$dest" ]]; then
      local target
      target=$(readlink "$dest" || true)
      echo "✓ $s -> $target"
    elif [[ -d "$dest" ]]; then
      echo "! $s (installed as directory, not symlink)"
    else
      echo "· $s (not installed)"
    fi
  done
}

install_skill() {
  local s=${1:-}
  if [[ -z "$s" ]]; then usage; exit 2; fi
  local src="$SRC_DIR/$s"
  local dest="$DEST_DIR/$s"
  if [[ ! -d "$src" ]]; then
    echo "❌ skill 不存在：$s" >&2
    echo "available: $(list_skills)" >&2
    exit 1
  fi
  mkdir -p "$DEST_DIR"

  # If a real directory exists (not a symlink), move it aside to avoid nested links.
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    local ts
    ts=$(date +%Y%m%d-%H%M%S)
    local trash="$HOME/.openclaw/_trash/skills"
    mkdir -p "$trash"
    mv "$dest" "$trash/${s}-${ts}"
    echo "⚠️ moved existing directory to: $trash/${s}-${ts}" >&2
  fi

  ln -sf "$src" "$dest"
  echo "✅ 安裝完成（symlink）：$dest -> $(readlink "$dest")"
}

uninstall_skill() {
  local s=${1:-}
  if [[ -z "$s" ]]; then usage; exit 2; fi
  local dest="$DEST_DIR/$s"
  if [[ -L "$dest" ]]; then
    rm "$dest"
    echo "✅ 已移除 symlink：$dest"
  else
    echo "(no symlink) $dest" >&2
  fi
}

update_skill() {
  local s=${1:-}
  if [[ -z "$s" ]]; then usage; exit 2; fi
  # symlink mode: update == reinstall (re-point link)
  install_skill "$s"
}

cmd=${1:-}
shift || true

case "$cmd" in
  list) list_skills ;;
  status) status ;;
  install) install_skill "${1:-}" ;;
  uninstall) uninstall_skill "${1:-}" ;;
  update) update_skill "${1:-}" ;;
  -h|--help|help|"") usage; exit 0 ;;
  *) usage; exit 2 ;;
esac
