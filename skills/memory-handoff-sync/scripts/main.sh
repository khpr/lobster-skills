#!/usr/bin/env bash
# memory-handoff-sync: append BOOT.md handoff summary into daily memory file (idempotent)
# Optional: --promote to also append into MEMORY.md (curated memory)
set -euo pipefail

WS="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
BOOT="$WS/BOOT.md"
MEM_CURATED="$WS/MEMORY.md"
MEM_DAILY_DIR="$WS/memory"

PROMOTE=0

while [ $# -gt 0 ]; do
  case "$1" in
    --promote) PROMOTE=1 ;;
    -h|--help)
      echo "usage: OPENCLAW_WORKSPACE=... $0 [--promote]" >&2
      exit 0
      ;;
    *)
      echo "memory-handoff-sync: unknown arg: $1" >&2
      exit 2
      ;;
  esac
  shift || true
done

[ -f "$BOOT" ] || { echo "memory-handoff-sync: BOOT.md not found: $BOOT" >&2; exit 2; }
mkdir -p "$MEM_DAILY_DIR"

python3 - "$BOOT" "$MEM_CURATED" "$MEM_DAILY_DIR" "$PROMOTE" <<'PY'
import hashlib, os, re, sys
from datetime import datetime

boot_path=sys.argv[1]
curated_path=sys.argv[2]
daily_dir=sys.argv[3]
promote=int(sys.argv[4])==1

with open(boot_path,'r',encoding='utf-8') as f:
  boot=f.read().strip()

# Try to extract a summary block if present.
summary=boot
m=re.search(r"(?is)(?:^|\n)#+\s*(?:50.*?summary|交接摘要|摘要)\b.*?\n(.*)", boot)
if m:
  summary=m.group(1).strip()

if not summary.strip():
  print('memory-handoff-sync: empty summary; skip')
  sys.exit(0)

h=hashlib.sha256(summary.encode('utf-8')).hexdigest()[:12]
marker=f"<!-- handoff:{h} -->"

today=datetime.now().strftime('%Y-%m-%d')
daily_path=os.path.join(daily_dir, f"{today}.md")

def already_in(path:str)->bool:
  if not os.path.exists(path):
    return False
  try:
    with open(path,'r',encoding='utf-8') as f:
      return marker in f.read()
  except Exception:
    return False

block=(
  f"\n\n## 交接摘要 @ {today}\n"
  f"{marker}\n"
  f"\n{summary.strip()}\n"
)

# 1) daily
if already_in(daily_path):
  print('memory-handoff-sync: daily already synced; skip')
else:
  with open(daily_path,'a',encoding='utf-8') as f:
    f.write(block)
  print(f"memory-handoff-sync: appended to daily {today} ({h})")

# 2) curated (optional)
if promote:
  if not os.path.exists(curated_path):
    print(f"memory-handoff-sync: MEMORY.md not found: {curated_path}")
    sys.exit(2)
  if already_in(curated_path):
    print('memory-handoff-sync: curated already synced; skip')
  else:
    with open(curated_path,'a',encoding='utf-8') as f:
      f.write(block)
    print(f"memory-handoff-sync: promoted into MEMORY.md ({h})")
PY
