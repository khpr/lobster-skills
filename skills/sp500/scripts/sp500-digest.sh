#!/bin/bash
# sp500-digest.sh — 從 buffer 選出今日 Top 文章，輸出給晨報
# 用法：bash sp500-digest.sh [--per-category N] [--days N]
# 輸出：每分類最多 N 篇，只取最近 N 天的 buffer

BUFFER="$HOME/.openclaw/skills/sp500/buffer"
PER_CAT=3
DAYS=1

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --per-category) PER_CAT="$2"; shift ;;
    --days) DAYS="$2"; shift ;;
  esac
  shift
done

python3 << PYEOF
import os, re, glob
from datetime import datetime, timedelta
from collections import defaultdict

BUFFER = os.path.expanduser("$BUFFER")
PER_CAT = int("$PER_CAT")
DAYS = int("$DAYS")

cutoff = datetime.now() - timedelta(days=DAYS)
results = defaultdict(list)

# 掃描 buffer 內最近 N 天的 md 檔
for md_file in sorted(glob.glob(f"{BUFFER}/*.md"), reverse=True):
    fname = os.path.basename(md_file)
    try:
        fdate = datetime.strptime(fname[:10], "%Y-%m-%d")
    except:
        continue
    if fdate < cutoff:
        continue
    
    with open(md_file) as f:
        current_source = ""
        for line in f:
            line = line.rstrip()
            if line.startswith("## "):
                current_source = line[3:]
            elif line.startswith("- ["):
                # 提取 category tag
                cat_m = re.search(r'`([^`]+)`', line)
                cat = cat_m.group(1) if cat_m else "misc"
                if len(results[cat]) < PER_CAT:
                    results[cat].append((current_source, line))

# 輸出
print(f"=== SP500 每日精選 ({datetime.now().strftime('%Y-%m-%d')}) ===\n")
for cat, items in sorted(results.items()):
    if not items:
        continue
    print(f"【{cat}】")
    for source, line in items:
        print(f"  {line.strip()}")
    print()

total = sum(len(v) for v in results.values())
print(f"共 {total} 篇，來自 {len(results)} 個分類")
PYEOF
