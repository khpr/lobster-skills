#!/usr/bin/env bash
# sp500-stats.sh - S&P 500 來源池統計報告
# 用法: bash sp500-stats.sh

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$SKILL_DIR/data"
SOURCES_FILE="$DATA_DIR/sources.md"
CANDIDATES_FILE="$DATA_DIR/candidates.md"

DATE_STR="$(date '+%Y-%m-%d %H:%M')"

if [[ ! -f "$SOURCES_FILE" ]]; then
  echo "錯誤：找不到 $SOURCES_FILE" >&2
  exit 1
fi

echo "=========================================="
echo "  S&P 500 來源池統計報告"
echo "  $DATE_STR"
echo "=========================================="
echo ""

# --- 總來源數 ---
total_sources=0
while IFS= read -r line; do
  [[ "$line" =~ ^-[[:space:]] ]] || continue
  ((total_sources++)) || true
done < "$SOURCES_FILE"

echo "## 總覽"
echo ""
printf "  %-20s %d\n" "信任來源總數:" "$total_sources"

# --- 候選池狀態 ---
pending=0
rejected=0
if [[ -f "$CANDIDATES_FILE" ]]; then
  in_pending_section=false
  in_rejected_section=false
  while IFS= read -r line; do
    if [[ "$line" =~ ^##[[:space:]]待審核 ]]; then
      in_pending_section=true
      in_rejected_section=false
      continue
    fi
    if [[ "$line" =~ ^##[[:space:]]Rejected ]]; then
      in_rejected_section=true
      in_pending_section=false
      continue
    fi
    if [[ "$line" =~ ^##[[:space:]] ]]; then
      in_pending_section=false
      in_rejected_section=false
      continue
    fi
    if [[ "$in_pending_section" == true && "$line" =~ ^-[[:space:]] ]]; then
      ((pending++)) || true
    fi
    if [[ "$in_rejected_section" == true && "$line" =~ ^-[[:space:]] ]]; then
      ((rejected++)) || true
    fi
  done < "$CANDIDATES_FILE"
fi

printf "  %-20s %d\n" "候選池待審核:" "$pending"
printf "  %-20s %d\n" "候選池已拒絕:" "$rejected"
echo ""

# --- 分類分布 ---
echo "## 分類分布"
echo ""
grep "^- " "$SOURCES_FILE" | cut -d'|' -f4 | xargs -I{} echo {} | sort | uniq -c | sort -rn | \
  awk '{count=$1; $1=""; cat=substr($0,2); printf "  %-20s %d\n", cat":", count}'
echo ""

# --- 語系分布（從分類或 URL 推斷）---
echo "## 語系分布"
echo ""
zh_tw=0
ja=0
en=0
other=0

while IFS= read -r line; do
  [[ "$line" =~ ^-[[:space:]] ]] || continue
  url="$(echo "$line" | cut -d'|' -f2 | xargs)"
  remark="$(echo "$line" | cut -d'|' -f6 | xargs)"
  if echo "$url $remark" | grep -qiE "ithome|diamond\.jp|nomura|smd-am|nikkei|yahoo\.co\.jp|livedoor|chunichi|sankei|asahi"; then
    if echo "$url $remark" | grep -qiE "\.jp|日|ダイヤ|三井|野村|日経"; then
      ((ja++)) || true
    else
      ((zh_tw++)) || true
    fi
  elif echo "$url $remark" | grep -qiE "ithome|tw\.|taiwan|繁體|中文"; then
    ((zh_tw++)) || true
  else
    ((en++)) || true
  fi
done < "$SOURCES_FILE"

printf "  %-20s %d\n" "英文 (en):" "$en"
printf "  %-20s %d\n" "繁體中文 (zh-TW):" "$zh_tw"
printf "  %-20s %d\n" "日文 (ja):" "$ja"
[[ "$other" -gt 0 ]] && printf "  %-20s %d\n" "其他:" "$other"
echo ""

# --- RSS 覆蓋率 ---
echo "## RSS 覆蓋率"
echo ""
has_rss=0
no_rss=0
while IFS= read -r line; do
  [[ "$line" =~ ^-[[:space:]] ]] || continue
  rss="$(echo "$line" | cut -d'|' -f3 | xargs)"
  if [[ -z "$rss" || "$rss" == "none" || "$rss" == "N/A" ]]; then
    ((no_rss++)) || true
  else
    ((has_rss++)) || true
  fi
done < "$SOURCES_FILE"

if [[ "$total_sources" -gt 0 ]]; then
  rss_pct=$(( has_rss * 100 / total_sources ))
else
  rss_pct=0
fi
printf "  %-20s %d (%d%%)\n" "有 RSS:" "$has_rss" "$rss_pct"
printf "  %-20s %d\n" "無 RSS (web_fetch):" "$no_rss"
echo ""

# --- 最近驗證日期分布 ---
echo "## 驗證時效"
echo ""
today_epoch="$(date +%s)"
stale_90=0
fresh=0
while IFS= read -r line; do
  [[ "$line" =~ ^-[[:space:]] ]] || continue
  verify_date="$(echo "$line" | cut -d'|' -f5 | xargs)"
  [[ -z "$verify_date" || "$verify_date" == "N/A" ]] && continue
  if date -j -f "%Y-%m-%d" "$verify_date" +%s &>/dev/null 2>&1; then
    verify_epoch="$(date -j -f "%Y-%m-%d" "$verify_date" +%s 2>/dev/null || echo 0)"
    age_days=$(( (today_epoch - verify_epoch) / 86400 ))
    if [[ "$age_days" -gt 90 ]]; then
      ((stale_90++)) || true
    else
      ((fresh++)) || true
    fi
  fi
done < "$SOURCES_FILE"

printf "  %-20s %d\n" "90天內驗證:" "$fresh"
printf "  %-20s %d\n" "超過90天未驗證:" "$stale_90"
echo ""
echo "=========================================="
echo "  提示：執行 sp500-health.sh 進行完整健檢"
echo "=========================================="
