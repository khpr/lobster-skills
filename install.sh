#!/usr/bin/env bash
# install.sh <skill-name>
# 把指定 skill 複製到 ~/.openclaw/skills/
set -euo pipefail
SKILL=${1:-}
if [[ -z "$SKILL" ]]; then
  echo "usage: $0 <skill-name>" >&2
  echo "available: $(ls skills/)" >&2
  exit 2
fi
SRC="$(cd "$(dirname "$0")/skills/$SKILL" && pwd)"
DEST=~/.openclaw/skills/$SKILL
if [[ ! -d "$SRC" ]]; then
  echo "❌ skill 不存在：$SKILL" >&2
  exit 1
fi
cp -r "$SRC" "$DEST"
echo "✅ 安裝完成：$DEST"
echo "驗證：openclaw skills 2>/dev/null | grep '$SKILL'"
