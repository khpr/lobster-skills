#!/usr/bin/env bash
# sp500-stats.sh - S&P 500 來源池統計報告 (v2)
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
echo "  S&P 500 來源池統計報告 (v2)"
echo "  $DATE_STR"
echo "=========================================="
echo ""

# --- 總來源數 ---
total_sources=$(grep -c "^- \[" "$SOURCES_FILE" || echo 0)

echo "## 總覽"
echo ""
printf "  %-20s %d\n" "信任來源總數:" "$total_sources"

# --- 候選池狀態 (假設暫不變) ---
pending=$(grep -c "^- " "$CANDIDATES_FILE" 2>/dev/null || echo 0)
printf "  %-20s %d\n" "候選池待審核:" "$pending"
echo ""

# --- 分類分布 ---
echo "## 分類分布"
echo ""
grep "^- \[" "$SOURCES_FILE" | cut -d'|' -f3 | xargs -I{} echo {} | sort | uniq -c | sort -rn | \
  awk '{count=$1; $1=""; cat=substr($0,2); printf "  %-20s %d\n", cat":", count}'
echo ""

# --- 評分統計 ---
echo "## 評分分佈"
echo ""
python3 -c "
import sys
scores = []
with open('$SOURCES_FILE', 'r', encoding='utf-8') as f:
    for line in f:
        if not line.startswith('- ['): continue
        parts = line.split('|')
        if len(parts) < 4: continue
        try:
            s = [int(x) for x in parts[3].strip().split(',')]
            total = (s[0]*0.25 + s[1]*0.15 + s[2]*0.15 + s[3]*0.20 + s[4]*0.25) * 10
            scores.append(total)
        except: pass

if scores:
    print(f'  平均分數: {sum(scores)/len(scores):.1f}')
    print(f'  最高分數: {max(scores):.1f}')
    print(f'  最低分數: {min(scores):.1f}')
    
    tier1 = len([s for s in scores if s >= 400])
    tier2 = len([s for s in scores if 250 <= s < 400])
    tier3 = len([s for s in scores if s < 250])
    print(f'  Tier 1 (400+): {tier1}')
    print(f'  Tier 2 (250-400): {tier2}')
    print(f'  Tier 3 (<250): {tier3}')
"
echo ""

# --- RSS 覆蓋率 ---
echo "## RSS 覆蓋率"
echo ""
has_rss=$(grep "^- \[" "$SOURCES_FILE" | cut -d'|' -f2 | grep -vE "none|N/A|^[[:space:]]*$" | wc -l | tr -d ' ')
no_rss=$((total_sources - has_rss))

if [[ "$total_sources" -gt 0 ]]; then
  rss_pct=$(( has_rss * 100 / total_sources ))
else
  rss_pct=0
fi
printf "  %-20s %d (%d%%)\n" "有 RSS:" "$has_rss" "$rss_pct"
printf "  %-20s %d\n" "無 RSS (web_fetch):" "$no_rss"
echo ""

echo "=========================================="
echo "  提示：執行 sp500-rank.sh 查看排名"
echo "=========================================="
