#!/bin/bash
# sp500-harvest.sh — Layer 2 RSS 收割腳本 v2
# 用法：bash sp500-harvest.sh [--limit N] [--category tech]

SKILL_DIR="$HOME/.openclaw/skills/sp500"
BUFFER_DIR="$HOME/.openclaw/skills/sp500/buffer"
VAULT="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault"
INBOX="$BUFFER_DIR"  # L2 先落 buffer，不直接進 Vault
LIMIT=50
CATEGORY=""

while [[ "$#" -gt 0 ]]; do
  case $1 in
    --limit) LIMIT="$2"; shift ;;
    --category) CATEGORY="$2"; shift ;;
  esac
  shift
done

mkdir -p "$INBOX"

export _SP500_SKILL_DIR="$SKILL_DIR"
export _SP500_INBOX="$INBOX"
export _SP500_LIMIT="$LIMIT"
export _SP500_CATEGORY="$CATEGORY"

python3 << 'PYEOF'
import re, hashlib, subprocess, os, sys
from datetime import datetime

SOURCES = os.path.expanduser(os.environ["_SP500_SKILL_DIR"] + "/data/sources.md")
SEEN_DB = os.path.expanduser(os.environ["_SP500_SKILL_DIR"] + "/data/harvest-seen.txt")
INBOX   = os.path.expanduser(os.environ["_SP500_INBOX"])
TODAY   = datetime.now().strftime("%Y-%m-%d")
OUTFILE = os.path.join(INBOX, f"{TODAY}.md")
LIMIT   = int(os.environ["_SP500_LIMIT"])
CAT_FILTER = os.environ.get("_SP500_CATEGORY", "")

# 讀已見
if os.path.exists(SEEN_DB):
    with open(SEEN_DB) as f:
        seen = set(f.read().splitlines())
else:
    seen = set()

# 初始化輸出
if not os.path.exists(OUTFILE):
    with open(OUTFILE, "w") as f:
        f.write(f"# SP500 Inbox — {TODAY}\n\n")

new_seen = []
scanned = 0
total_new = 0

with open(SOURCES) as f:
    for line in f:
        line = line.strip()
        if not line.startswith("- "):
            continue
        parts = [p.strip() for p in line[2:].split("|")]
        if len(parts) < 4:
            continue
        name, homepage, rss, category = parts[0], parts[1], parts[2], parts[3]
        
        # 過濾
        if not rss.startswith("http"):
            continue
        if "待校正" in rss or "none" in rss.lower():
            continue
        if CAT_FILTER and category != CAT_FILTER:
            continue
        if scanned >= LIMIT:
            break
        
        scanned += 1
        
        # 抓 RSS
        try:
            result = subprocess.run(
                ["curl", "-s", "--max-time", "8", "-L", rss],
                capture_output=True, text=True, timeout=10
            )
            content = result.stdout
        except:
            continue
        
        if not content:
            continue
        
        # 解析 item / entry
        items = re.findall(r'<item[^>]*>(.*?)</item>', content, re.DOTALL)
        if not items:
            items = re.findall(r'<entry[^>]*>(.*?)</entry>', content, re.DOTALL)
        items = items[:3]
        
        lines_out = []
        for item in items:
            title_m = re.search(r'<title[^>]*>(?:<!\[CDATA\[)?\s*(.*?)\s*(?:\]\]>)?</title>', item, re.DOTALL)
            link_m  = re.search(r'<link[^>]*>(https?://[^\s<]+)', item)
            if not link_m:
                link_m = re.search(r'<link[^>]+href="(https?://[^"]+)"', item)
            
            if not title_m or not link_m:
                continue
            
            title = re.sub(r'<[^>]+>', '', title_m.group(1)).strip()
            url   = link_m.group(1).strip()
            uhash = hashlib.md5(url.encode()).hexdigest()[:8]
            
            if uhash in seen:
                continue
            
            lines_out.append(f"- [{title}]({url}) `{category}`")
            seen.add(uhash)
            new_seen.append(uhash)
            total_new += 1
        
        if lines_out:
            with open(OUTFILE, "a") as f:
                f.write(f"\n## {name}\n")
                f.write("\n".join(lines_out) + "\n")

# 寫回 seen db
with open(SEEN_DB, "a") as f:
    for h in new_seen:
        f.write(h + "\n")

print(f"掃描來源：{scanned} 個")
print(f"新文章：{total_new} 篇")
print(f"落地：{OUTFILE}")
PYEOF
