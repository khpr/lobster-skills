#!/usr/bin/env bash
# handoff.sh — memory-handoff-sync
# Version: 1.1  Last modified: 2026-03-23
# Usage: bash handoff.sh [--summary "摘要文字"] [--no-reset]
# Writes BOOT.md handoff card + archives to memory/YYYY-MM-DD.md
# Optionally triggers session-reset.sh unless --no-reset is given

# Bash 3.2 compatible (no declare -A, no <<<)

WORKSPACE="$HOME/.openclaw/workspace-lobster"
BOOT_MD="$WORKSPACE/BOOT.md"
MEMORY_DIR="$WORKSPACE/memory"
RESET_SCRIPT="$HOME/.openclaw/workspace/scripts/session-reset.sh"
DONE_FLAG="/tmp/memory-handoff-done.json"
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
TODAY=$(date +"%Y-%m-%d")

SUMMARY=""
DO_RESET=0

# Parse arguments
while [ $# -gt 0 ]; do
  case "$1" in
    --summary)
      SUMMARY="$2"
      shift 2
      ;;
    --reset)
      DO_RESET=1
      shift
      ;;
    --no-reset)
      DO_RESET=0
      shift
      ;;
    *)
      # Positional: treat as summary
      SUMMARY="$1"
      shift
      ;;
  esac
done

# --- 確保 memory 目錄存在 ---
if [ ! -d "$MEMORY_DIR" ]; then
  mkdir -p "$MEMORY_DIR"
  echo "[handoff] memory/ 目錄已建立" >&2
fi

# --- 確認 BOOT.md 可寫 ---
if ! touch "$BOOT_MD" 2>/dev/null; then
  echo "[handoff] ERROR: BOOT.md 不可寫入：$BOOT_MD" >&2
  exit 1
fi

# --- 準備摘要內容 ---
if [ -z "$SUMMARY" ]; then
  SUMMARY="(無摘要，由自動觸發產生，時間：$TS)"
fi

# --- 寫 BOOT.md 交接卡（覆寫） ---
printf '# BOOT.md — 交接卡\ngenerated: %s\nsource: memory-handoff-sync/scripts/handoff.sh\n\n## HANDOFF 摘要\n\n%s\n\n## 歸檔路徑\n\nmemory/%s.md\n' \
  "$TS" "$SUMMARY" "$TODAY" > "$BOOT_MD"

echo "[handoff] BOOT.md 已寫入：$BOOT_MD" >&2

# --- 歸檔到 memory/YYYY-MM-DD.md（append） ---
MEMORY_FILE="$MEMORY_DIR/$TODAY.md"
printf '\n## HANDOFF %s\n\n%s\n\n' "$TS" "$SUMMARY" >> "$MEMORY_FILE"
echo "[handoff] 已歸檔到：$MEMORY_FILE" >&2

# --- 寫 done flag ---
printf '{"phase":"handoff","skill":"memory-handoff-sync","ts":"%s"}\n' "$TS" > "$DONE_FLAG"
echo "[handoff] done flag 寫入：$DONE_FLAG" >&2

# --- 確認寫入 ---
echo "[handoff] BOOT.md 前 5 行：" >&2
head -5 "$BOOT_MD" >&2

# --- 可選：觸發 session-reset ---
if [ "$DO_RESET" = "1" ]; then
  if [ -f "$RESET_SCRIPT" ]; then
    echo "[handoff] 觸發 session-reset.sh..." >&2
    bash "$RESET_SCRIPT"
  else
    echo "[handoff] WARN: session-reset.sh 不存在，跳過重啟步驟" >&2
  fi
fi

echo "[handoff] 完成。" >&2
exit 0
