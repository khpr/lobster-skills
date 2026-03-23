#!/usr/bin/env bash
# sp500-rank.sh — 根據評分對 S&P 500 來源進行排序
# 用法：
#   sp500-rank.sh [category] [--limit N]

set -euo pipefail

SOURCES_FILE="$HOME/.openclaw/workspace/sp500-sources-v2.md"
LIMIT=20
CATEGORY=""

while [[ $# -gt 0 ]]; do
  case $1 in
    --limit)
      LIMIT="$2"
      shift 2
      ;;
    *)
      CATEGORY="$1"
      shift
      ;;
  esac
done

if [[ ! -f "$SOURCES_FILE" ]]; then
    echo "錯誤：找不到來源檔案 $SOURCES_FILE"
    exit 1
fi

python3 -c "
import sys, re

limit = int('$LIMIT')
target_category = '$CATEGORY'

# 權重設定
W_O = 0.25
W_F = 0.15
W_S = 0.15
W_C = 0.20
W_A = 0.25

results = []

with open('$SOURCES_FILE', 'r', encoding='utf-8') as f:
    for line in f:
        line = line.strip()
        if not line.startswith('- ['):
            continue
        
        # 解析格式: - [名稱](URL) | RSS | 分類 | O,F,S,C,A | 備註
        parts = [p.strip() for p in line[2:].split('|')]
        if len(parts) < 4:
            continue
            
        name_url = parts[0]
        rss = parts[1]
        category = parts[2]
        scores_raw = parts[3]
        note = parts[4] if len(parts) > 4 else ''
        
        if target_category and category != target_category:
            continue
            
        try:
            scores = [int(s) for s in scores_raw.split(',')]
            if len(scores) != 5: continue
            
            total_score = (scores[0]*W_O + scores[1]*W_F + scores[2]*W_S + scores[3]*W_C + scores[4]*W_A) * 10
            results.append({
                'name_url': name_url,
                'category': category,
                'score': total_score,
                'note': note
            })
        except:
            continue

# 排序
results.sort(key=lambda x: x['score'], reverse=True)

# 輸出
print(f'排名 | 分數 | 名稱 | 分類 | 備註')
print(f'---|---|---|---|---')
for i, r in enumerate(results[:limit]):
    print(f\"{i+1} | {r['score']:.1f} | {r['name_url']} | {r['category']} | {r['note']}\")
"
