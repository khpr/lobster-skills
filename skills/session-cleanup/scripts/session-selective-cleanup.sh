#!/usr/bin/env bash
# session-selective-cleanup.sh — 選擇性清理 session（key + jsonl）
# 用法：
#   --agent <agentId>     必填，目標 agent
#   --session <sessionId> 選填，不填=清該 agent 全部非活躍 session
#   --restart             選填，清完後 gateway restart

set -euo pipefail

AGENTS_DIR="$HOME/.openclaw/agents"
AGENT=""
SESSION=""
RESTART=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --agent) AGENT="$2"; shift 2 ;;
    --session) SESSION="$2"; shift 2 ;;
    --restart) RESTART=true; shift ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

if [ -z "$AGENT" ]; then
  echo "❌ --agent is required"
  exit 1
fi

SESS_DIR="$AGENTS_DIR/$AGENT/sessions"
STORE="$SESS_DIR/sessions.json"

if [ ! -f "$STORE" ]; then
  echo "❌ sessions.json not found: $STORE"
  exit 1
fi

mkdir -p "$SESS_DIR/.deleted"

# Use python3 to remove keys and collect sessionIds to delete
RESULT=$(python3 -c "
import json, sys, os

store_path = '$STORE'
target_session = '$SESSION'
sess_dir = '$SESS_DIR'

with open(store_path) as f:
    data = json.load(f)

original_count = len(data)
to_delete_ids = []

if target_session:
    # Delete specific session
    keys_to_remove = []
    for k, v in data.items():
        sid = v.get('sessionId', '') if isinstance(v, dict) else ''
        if sid == target_session or target_session in k:
            keys_to_remove.append(k)
            if sid:
                to_delete_ids.append(sid)
    for k in keys_to_remove:
        del data[k]
else:
    # Delete all sessions for this agent
    to_delete_ids = []
    for k, v in data.items():
        sid = v.get('sessionId', '') if isinstance(v, dict) else ''
        if sid:
            to_delete_ids.append(sid)
    data = {}

with open(store_path, 'w') as f:
    json.dump(data, f, indent=2)

removed_keys = original_count - len(data)
print(f'KEYS_REMOVED={removed_keys}')
print(f'SESSION_IDS={\"|\".join(to_delete_ids)}')
")

KEYS_REMOVED=$(echo "$RESULT" | grep KEYS_REMOVED | cut -d= -f2)
SESSION_IDS=$(echo "$RESULT" | grep SESSION_IDS | cut -d= -f2)

# Move jsonl files to .deleted/
JSONL_MOVED=0
if [ -n "$SESSION_IDS" ]; then
  IFS='|' read -ra IDS <<< "$SESSION_IDS"
  for sid in "${IDS[@]}"; do
    if [ -f "$SESS_DIR/$sid.jsonl" ]; then
      mv "$SESS_DIR/$sid.jsonl" "$SESS_DIR/.deleted/"
      JSONL_MOVED=$((JSONL_MOVED + 1))
    fi
  done
elif [ -z "$SESSION" ]; then
  # No session IDs in store but clean all jsonl anyway
  while IFS= read -r -d '' jf; do
    mv "$jf" "$SESS_DIR/.deleted/"
    JSONL_MOVED=$((JSONL_MOVED + 1))
  done < <(find "$SESS_DIR" -maxdepth 1 -name "*.jsonl" -print0)
fi

echo "✅ $AGENT: removed $KEYS_REMOVED keys, moved $JSONL_MOVED jsonl to .deleted/"

if $RESTART; then
  echo "🔄 Restarting gateway..."
  openclaw gateway restart 2>&1
fi
