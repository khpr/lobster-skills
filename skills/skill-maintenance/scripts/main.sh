#!/usr/bin/env bash
# skill-maintenance/scripts/main.sh
# Phase S3 implementation — run skill maintenance pipeline + parse report
# bash 3.2 compatible
set -euo pipefail

SCRIPT_PATH="$HOME/.openclaw/workspace/scripts/skill-maintenance.sh"
LOG_FILE="/tmp/skill-maintenance-$(date +%Y%m%d-%H%M%S).log"

usage() {
  echo "Usage: $0 [--dry-run]"
  echo "  --dry-run   只檢查前置條件，不實際執行"
  exit 1
}

DRY_RUN=0
while [ $# -gt 0 ]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    -h|--help) usage ;;
    *) echo "Unknown argument: $1" >&2; usage ;;
  esac
  shift
done

# 前置條件檢查
if [ ! -f "$SCRIPT_PATH" ]; then
  echo "ERROR: skill-maintenance.sh 不在預期路徑: $SCRIPT_PATH" >&2
  exit 1
fi

if [ $DRY_RUN -eq 1 ]; then
  echo "DRY_RUN: 前置條件 OK，實際執行跳過"
  exit 0
fi

# 執行維護腳本，捕獲輸出
echo "=== skill-maintenance 開始 $(date -u +%Y-%m-%dT%H:%M:%SZ) ===" | tee "$LOG_FILE"
OUTPUT=$(bash "$SCRIPT_PATH" 2>&1 | tee -a "$LOG_FILE") || true

echo "=== 腳本執行完畢 ===" | tee -a "$LOG_FILE"

# 解析 SKILL_MAINTENANCE_REPORT 區塊
REPORT_SECTION=$(echo "$OUTPUT" | awk '/^SKILL_MAINTENANCE_REPORT/{found=1; next} found{print}' || true)

if [ -z "$REPORT_SECTION" ]; then
  echo "WARN: 未找到 SKILL_MAINTENANCE_REPORT，輸出原始 log" >&2
  REPORT_SECTION="$OUTPUT"
fi

# 從 report 提取各欄位
SYNC_STATUS=$(echo "$REPORT_SECTION" | grep "^sync:" | sed 's/^sync: //' || echo "unknown")
HEALTH_STATUS=$(echo "$REPORT_SECTION" | grep "^health:" | sed 's/^health: //' || echo "unknown")
FEEDBACK_STATUS=$(echo "$REPORT_SECTION" | grep "^feedback:" | sed 's/^feedback: //' || echo "unknown")
STATS_STATUS=$(echo "$REPORT_SECTION" | grep "^stats:" | sed 's/^stats: //' || echo "unknown")

# 判斷是否有 fail
FAIL_NUM=$(echo "$HEALTH_STATUS" | grep -o "[0-9]* fail" | grep -o "[0-9]*" || echo "0")

# 輸出人類可讀摘要
echo "---"
echo "【Skill 維護完成】$(date '+%Y-%m-%d %H:%M')"
echo "同步：$SYNC_STATUS"
echo "健檢：$HEALTH_STATUS"
echo "反饋：$FEEDBACK_STATUS"
echo "統計：$STATS_STATUS"

if [ "${FAIL_NUM:-0}" -gt 0 ] 2>/dev/null; then
  echo ""
  echo "⚠️ 發現 $FAIL_NUM 個 skill 失敗，請人工介入"
  echo "詳細 log：$LOG_FILE"
  exit 2
fi

echo "LOG: $LOG_FILE"
exit 0
