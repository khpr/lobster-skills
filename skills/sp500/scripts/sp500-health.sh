#!/usr/bin/env bash
# sp500-health.sh - 全池健檢：掃 sources.md 所有 URL，測可達性與 RSS 有效性
# 用法: bash sp500-health.sh
# 建議排程: 每月 1 日 10:00 Asia/Taipei

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$SKILL_DIR/data"
SOURCES_FILE="$DATA_DIR/sources.md"

TIMEOUT=15
HEALTH_LOG_DIR="$SKILL_DIR/../../../workspace/logs"
DATE_STR="$(date +%Y-%m-%d)"
REPORT_FILE="$SKILL_DIR/../../../workspace/logs/skill-health-${DATE_STR}.md"

# 統計
total=0
alive=0
dead=0
rss_ok=0
rss_fail=0
manual_review=0

echo "=== S&P 500 全池健檢 $DATE_STR ===" | tee "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

if [[ ! -f "$SOURCES_FILE" ]]; then
  echo "錯誤：找不到 $SOURCES_FILE" >&2
  exit 1
fi

echo "## 健檢結果" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 讀 sources.md 的 `- ` 行，格式：- 名稱 | URL | RSS | 分類 | 日期 | 備註
while IFS= read -r line; do
  [[ ! "$line" =~ ^-[[:space:]] ]] && continue
  [[ "$line" =~ ^#+ ]] && continue

  # 解析欄位
  name="$(echo "$line" | sed 's/^- //' | cut -d'|' -f1 | xargs)"
  url="$(echo "$line" | cut -d'|' -f2 | xargs)"
  rss="$(echo "$line" | cut -d'|' -f3 | xargs)"

  [[ -z "$url" ]] && continue
  ((total++)) || true

  echo -n "  [$name] $url ... " >&2

  # 測 HTTP status
  http_status="$(curl -sI --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")"

  if [[ "$http_status" == "200" || "$http_status" == "301" || "$http_status" == "302" ]]; then
    status_str="✅ alive ($http_status)"
    ((alive++)) || true
  elif [[ "$http_status" == "403" || "$http_status" == "401" ]]; then
    status_str="⚠️  auth_required ($http_status)"
    ((manual_review++)) || true
  elif [[ "$http_status" == "000" ]]; then
    status_str="❌ timeout/unreachable"
    ((dead++)) || true
  else
    status_str="❌ dead ($http_status)"
    ((dead++)) || true
  fi

  echo "$status_str" >&2

  # RSS 健檢
  rss_str="N/A"
  if [[ -n "$rss" && "$rss" != "none" && "$rss" != "N/A" ]]; then
    rss_status="$(curl -sI --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "$rss" 2>/dev/null || echo "000")"
    if [[ "$rss_status" == "200" ]]; then
      # 確認是 XML
      content_type="$(curl -sI --max-time "$TIMEOUT" "$rss" 2>/dev/null | grep -i "content-type" | head -1 || true)"
      if echo "$content_type" | grep -qi "xml\|rss\|atom"; then
        rss_str="✅ rss_ok"
        ((rss_ok++)) || true
      else
        rss_str="⚠️  rss_not_xml"
        ((rss_fail++)) || true
      fi
    else
      rss_str="❌ rss_fail ($rss_status)"
      ((rss_fail++)) || true
    fi
  fi

  # 寫報告行
  printf "- **%s** | %s | RSS: %s | URL: %s\n" "$name" "$status_str" "$rss_str" "$url" >> "$REPORT_FILE"

done < "$SOURCES_FILE"

# 摘要
echo "" | tee -a "$REPORT_FILE"
echo "## 摘要" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"
printf "| 項目            | 數量 |\n" | tee -a "$REPORT_FILE"
printf "|-----------------|------|\n" | tee -a "$REPORT_FILE"
printf "| 總來源數        | %d   |\n" "$total" | tee -a "$REPORT_FILE"
printf "| 存活            | %d   |\n" "$alive" | tee -a "$REPORT_FILE"
printf "| 死亡/無法連線   | %d   |\n" "$dead" | tee -a "$REPORT_FILE"
printf "| 需人工確認      | %d   |\n" "$manual_review" | tee -a "$REPORT_FILE"
printf "| RSS 正常        | %d   |\n" "$rss_ok" | tee -a "$REPORT_FILE"
printf "| RSS 失效        | %d   |\n" "$rss_fail" | tee -a "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

if [[ "$dead" -gt 0 ]]; then
  echo "⚠️  有 $dead 個來源無法連線，建議人工確認後考慮降級或移除。" | tee -a "$REPORT_FILE"
fi
if [[ "$rss_fail" -gt 0 ]]; then
  echo "⚠️  有 $rss_fail 個 RSS 失效，建議更新 RSS URL 或改為 web_fetch。" | tee -a "$REPORT_FILE"
fi

echo "" | tee -a "$REPORT_FILE"
echo "健檢報告已寫入: $REPORT_FILE" >&2
echo "完成時間: $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$REPORT_FILE"
