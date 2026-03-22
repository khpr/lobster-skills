#!/usr/bin/env bash
# install.sh — lobster-skills 管理工具
# 支援：install / uninstall / update / list / status
# bash 3.2 相容（macOS 內建）
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$REPO_DIR/skills"
MANAGED="$HOME/.openclaw/skills"

CMD="${1:-}"
SKILL="${2:-}"

usage() {
  cat <<EOF
usage: $0 <command> [skill-name]

commands:
  install <skill>    symlink skill 到 ~/.openclaw/skills/
  uninstall <skill>  移除 symlink（不刪 repo 原檔）
  update <skill>     重新 link（git pull 後用）
  list               列出所有可安裝的 skill
  status             列出目前已安裝的 skill
EOF
  exit 2
}

check_skill() {
  if [[ -z "$SKILL" ]]; then
    echo "❌ 需要指定 skill 名稱" >&2
    usage
  fi
  if [[ ! -d "$SKILLS_DIR/$SKILL" ]]; then
    echo "❌ skill 不存在：$SKILL" >&2
    echo "可用：$(ls "$SKILLS_DIR/")" >&2
    exit 1
  fi
}

cmd_install() {
  check_skill
  SRC="$SKILLS_DIR/$SKILL"
  DEST="$MANAGED/$SKILL"
  if [[ -e "$DEST" ]] || [[ -L "$DEST" ]]; then
    echo "⚠️  已存在：$DEST（用 update 重新 link）"
    exit 1
  fi
  ln -sf "$SRC" "$DEST"
  echo "✅ 安裝完成（symlink）：$DEST → $SRC"
}

cmd_uninstall() {
  check_skill
  DEST="$MANAGED/$SKILL"
  if [[ ! -L "$DEST" ]] && [[ ! -e "$DEST" ]]; then
    echo "⚠️  未安裝：$SKILL"
    exit 1
  fi
  rm -f "$DEST"
  echo "✅ 已卸載：$SKILL（repo 原檔保留）"
}

cmd_update() {
  check_skill
  DEST="$MANAGED/$SKILL"
  SRC="$SKILLS_DIR/$SKILL"
  rm -f "$DEST"
  ln -sf "$SRC" "$DEST"
  echo "✅ 已更新 symlink：$DEST → $SRC"
}

cmd_list() {
  echo "=== 可安裝的 skill ==="
  for d in "$SKILLS_DIR"/*/; do
    name="$(basename "$d")"
    owner=""
    if [[ -f "$d/SKILL.md" ]]; then
      owner=$(grep "^owner:" "$d/SKILL.md" 2>/dev/null | head -1 | sed 's/owner: *//' | tr -d '"' || true)
    fi
    if [[ -n "$owner" ]]; then
      echo "  $name  [$owner]"
    else
      echo "  $name"
    fi
  done
}

cmd_status() {
  echo "=== 已安裝的 skill ==="
  for link in "$MANAGED"/*/; do
    [[ -d "$link" ]] || continue
    name="$(basename "$link")"
    if [[ -L "$link" ]]; then
      target="$(readlink "$link")"
      echo "  ✅ $name  → $target"
    else
      echo "  📦 $name  (非 symlink)"
    fi
  done
}

case "$CMD" in
  install)   cmd_install ;;
  uninstall) cmd_uninstall ;;
  update)    cmd_update ;;
  list)      cmd_list ;;
  status)    cmd_status ;;
  *)         usage ;;
esac
