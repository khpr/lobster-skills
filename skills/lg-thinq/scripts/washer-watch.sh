#!/bin/bash
# washer-watch.sh — 洗衣機狀態輪詢，洗完推 LINE 通知
# 用法：由 cron 每 5 分鐘觸發一次
# 狀態檔：/tmp/washer-last-state.txt

set -euo pipefail

STATE_FILE="/tmp/washer-last-state.txt"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PYTHON="/tmp/thinq-venv/bin/python3"

# 取得當前狀態
RESULT=$($PYTHON "$SCRIPT_DIR/washer-status.py" --json 2>/dev/null) || {
  echo "API 查詢失敗"
  exit 0
}

CURRENT_STATE=$(echo "$RESULT" | python3 -c "
import json, sys
for line in sys.stdin:
    try:
        d = json.loads(line)
        print(d.get('runState',{}).get('currentState','UNKNOWN'))
        break
    except: pass
" 2>/dev/null || echo "UNKNOWN")

LAST_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo "UNKNOWN")

# 寫入當前狀態
echo "$CURRENT_STATE" > "$STATE_FILE"

# 狀態轉換偵測
if [[ "$LAST_STATE" =~ ^(RUNNING|RINSING|SPINNING|DRYING|STEAM_SOFTENING|COOL_DOWN)$ ]] && [[ "$CURRENT_STATE" == "END" ]]; then
  echo "🧺 洗衣完成！推送通知..."
  # 回報給 cron caller，由 agent 決定推送方式
  echo "WASHER_DONE"
elif [[ "$CURRENT_STATE" =~ ^(RUNNING|RINSING|SPINNING|DRYING)$ ]]; then
  REMAIN=$($PYTHON "$SCRIPT_DIR/washer-status.py" 2>/dev/null | grep "剩餘" || echo "")
  echo "WASHER_RUNNING|$REMAIN"
else
  echo "WASHER_IDLE|$CURRENT_STATE"
fi
