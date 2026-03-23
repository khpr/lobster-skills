#!/usr/bin/env bash
# memory-handoff-sync: append BOOT.md handoff summary into MEMORY.md (idempotent)
set -euo pipefail

WS="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
BOOT="$WS/BOOT.md"
MEM="$WS/MEMORY.md"

[ -f "$BOOT" ] || { echo "memory-handoff-sync: BOOT.md not found: $BOOT" >&2; exit 2; }
[ -f "$MEM" ] || { echo "memory-handoff-sync: MEMORY.md not found: $MEM" >&2; exit 2; }

python3 - "$BOOT" "$MEM" <<'PY'
import hashlib, re, sys
from datetime import datetime

boot_path=sys.argv[1]
mem_path=sys.argv[2]

def read(p):
  with open(p,'r',encoding='utf-8') as f:
    return f.read()

boot=read(boot_path).strip()
mem=read(mem_path)

# Try to extract the 50-turn summary block if present.
# Heuristic: look for a heading containing 'summary' or '摘要'
summary=boot
m=re.search(r"(?is)(?:^|\n)#+\s*(?:50.*?summary|交接摘要|摘要)\b.*?\n(.*)", boot)
if m:
  summary=m.group(1).strip()

if not summary:
  print('memory-handoff-sync: empty summary; skip')
  sys.exit(0)

h=hashlib.sha256(summary.encode('utf-8')).hexdigest()[:12]
marker=f"<!-- handoff:{h} -->"
if marker in mem:
  print('memory-handoff-sync: already synced; skip')
  sys.exit(0)

today=datetime.now().strftime('%Y-%m-%d')
block=(
  f"\n\n## 交接摘要 @ {today}\n"
  f"{marker}\n"
  f"\n{summary.strip()}\n"
)

with open(mem_path,'a',encoding='utf-8') as f:
  f.write(block)

print(f"memory-handoff-sync: appended {h}")
PY
