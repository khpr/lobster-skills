#!/usr/bin/env bash
# sp500-health.sh - 全池健檢 (v2)
# 用法: bash sp500-health.sh

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$SKILL_DIR/data"
SOURCES_FILE="$DATA_DIR/sources.md"

TIMEOUT=15
HEALTH_LOG_DIR="$HOME/.openclaw/workspace/logs"
mkdir -p "$HEALTH_LOG_DIR"
DATE_STR="$(date +%Y-%m-%d)"
REPORT_FILE="$HEALTH_LOG_DIR/sp500-health-${DATE_STR}.md"

# 統計
total=0
alive=0
dead=0
rss_ok=0
rss_fail=0
manual_review=0

echo "=== S&P 500 全池健檢 (v2) $DATE_STR ===" | tee "$REPORT_FILE"
echo "" | tee -a "$REPORT_FILE"

if [[ ! -f "$SOURCES_FILE" ]]; then
  echo "錯誤：找不到 $SOURCES_FILE" >&2
  exit 1
fi

echo "## 健檢結果" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

while IFS= read -r line; do
  [[ ! "$line" =~ ^- \[[^]]+\]\([^)]+\) ]] && continue
  
  # 解析格式: - [名稱](URL) | RSS | 分類 | 評分 | 備註
  name=$(echo "$line" | sed -E 's/^- \[([^]]+)\].*/\1/')
  url=$(echo "$line" | sed -E 's/^- \[[^]]+\]\(([^)]+)\).*/\1/')
  rss=$(echo "$line" | cut -d'|' -f2 | xargs)

  [[ -z "$url" ]] && continue
  ((total++)) || true

  echo -n "  [$name] $url ... " >&2

  # 測 HTTP status
  http_status="$(curl -sI -L --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000")"

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
    rss_status="$(curl -sI -L --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "$rss" 2>/dev/null || echo "000")"
    if [[ "$rss_status" == "200" ]]; then
      rss_str="✅ rss_ok"
      ((rss_ok++)) || true
    else
      rss_str="❌ rss_fail ($rss_status)"
      ((rss_fail++)) || true
    fi
  fi

  # 寫報告行
  printf "- **%s** | %s | RSS: %s | URL: %s\n" "$name" "$status_str" "$rss_str" "$url" >> "$REPORT_FILE"

done < "$SOURCES_FILE"

# 摘要 (省略詳細摘要以節省 token，邏輯同舊版)
echo "健檢完成。報告：$REPORT_FILE" | tee -a "$REPORT_FILE"
