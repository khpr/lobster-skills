#!/usr/bin/env bash
# system-restart.sh — 全系統 session 清除 + gateway restart
# 只能由 openclaw agent 內部呼叫，不接受外部參數
# 安全：觸發端（AGENTS.md）負責驗證 userId

set -euo pipefail

AGENTS_DIR="$HOME/.openclaw/agents"
BACKUP_DIR="$HOME/.openclaw/session-backups/$(date +%Y%m%d-%H%M%S)"
LOG="$BACKUP_DIR/restart.log"

mkdir -p "$BACKUP_DIR"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] System restart initiated" | tee "$LOG"

# Step 1: 備份所有 sessions.json
echo "Step 1: Backing up session stores..." | tee -a "$LOG"
for store in "$AGENTS_DIR"/*/sessions/sessions.json; do
  if [ -f "$store" ]; then
    agent=$(echo "$store" | sed "s|$AGENTS_DIR/||;s|/sessions/sessions.json||")
    count=$(python3 -c "import json; print(len(json.load(open('$store'))))" 2>/dev/null || echo "?")
    cp "$store" "$BACKUP_DIR/${agent}-sessions.json"
    echo "  $agent: $count sessions backed up" | tee -a "$LOG"
  fi
done

# Step 2: 清空所有 sessions.json 並移動 jsonl 到 .deleted/
echo "Step 2: Clearing all session stores and moving jsonl files..." | tee -a "$LOG"
for store in "$AGENTS_DIR"/*/sessions/sessions.json; do
  if [ -f "$store" ]; then
    agent_sess_dir=$(dirname "$store")
    agent=$(echo "$store" | sed "s|$AGENTS_DIR/||;s|/sessions/sessions.json||")
    
    # 清空 sessions.json
    echo '{}' > "$store"
    
    # 移動所有 .jsonl 相關檔案到 .deleted/
    mkdir -p "$agent_sess_dir/.deleted"
    count=0
    # 使用 find 匹配所有 .jsonl 開頭的檔案（包含 .lock, .deleted.xxx 等 legacy 檔）
    while IFS= read -r -d '' jf; do
      mv "$jf" "$agent_sess_dir/.deleted/"
      count=$((count + 1))
    done < <(find "$agent_sess_dir" -maxdepth 1 -name "*.jsonl*" -print0)
    
    echo "  $agent: cleared ($count files moved to .deleted/)" | tee -a "$LOG"
  fi
done

# Step 3: Gateway restart
echo "Step 3: Restarting gateway..." | tee -a "$LOG"
openclaw gateway restart 2>&1 | tee -a "$LOG"

# Step 4: 清理 30 天前的備份
find "$HOME/.openclaw/session-backups" -maxdepth 1 -type d -mtime +30 -exec rm -rf {} \; 2>/dev/null || true

echo "[$(date '+%Y-%m-%d %H:%M:%S')] System restart complete" | tee -a "$LOG"
echo "Backup: $BACKUP_DIR"
