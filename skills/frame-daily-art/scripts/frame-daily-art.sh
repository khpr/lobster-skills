#!/usr/bin/env bash
# frame-daily-art.sh — 主入口
# 流程：Artvee 抓圖 → PIL 合成 → Frame TV 上傳 → 記錄 → LINE Flex
# Version: 2.0 | Created: 2026-03-23

set -euo pipefail

SKILL_DIR="$HOME/lobster-skills/skills/frame-daily-art"
LINE_USER="${LINE_PUSH_USER:-Uab09077d61b168708d6703f0baf8ca03}"
USED_LOG="$SKILL_DIR/data/used-artworks.json"
TODAY=$(date +%Y-%m-%d)
VAULT_DIR="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault"
OUTPUT_PATH="$VAULT_DIR/90_System/Deliverables/frame-art/${TODAY}.jpg"
TMP_RAW="/tmp/frame-art-raw-${TODAY}.jpg"
TMP_META="/tmp/frame-art-meta-${TODAY}.json"

log() { echo "[frame-daily-art] $*" >&2; }
die() { log "ERROR: $*"; exit 1; }

# Lock
LOCK="/tmp/frame-daily-art.lock"
if [ -f "$LOCK" ]; then
  log "Already running (lock exists). Exit."
  exit 0
fi
echo $$ > "$LOCK"
trap 'rm -f "$LOCK"' EXIT

log "Starting frame-daily-art for $TODAY"

# Step 1: Fetch from Artvee
log "Step 1: Fetching artwork from Artvee..."
python3 "$SKILL_DIR/scripts/fetch-artvee.py" \
  --min-px 1200 \
  --portrait-ratio 1.2 \
  --exclude-log "$USED_LOG" \
  --output "$TMP_RAW" \
  --meta "$TMP_META" \
  || die "fetch-artvee.py failed"

# Read meta
TITLE=$(python3 -c "import json,sys; d=json.load(open('$TMP_META')); print(d.get('title','Untitled'))")
ARTIST=$(python3 -c "import json,sys; d=json.load(open('$TMP_META')); print(d.get('artist','Unknown'))")
YEAR=$(python3 -c "import json,sys; d=json.load(open('$TMP_META')); print(d.get('year',''))")
log "Artwork: $TITLE by $ARTIST ($YEAR)"

# Step 2: Compose poster
log "Step 2: Composing poster..."
mkdir -p "$(dirname "$OUTPUT_PATH")"
python3 "$SKILL_DIR/scripts/compose-poster.py" \
  --input "$TMP_RAW" \
  --meta "$TMP_META" \
  --output "$OUTPUT_PATH" \
  || die "compose-poster.py failed"

# Step 3: Upload to Frame TV
log "Step 3: Uploading to Frame TV..."
UPLOAD_SCRIPT="$HOME/.openclaw/skills/samsung-smartthings/scripts/upload_to_frame.py"
if [ -f "$UPLOAD_SCRIPT" ]; then
  python3 "$UPLOAD_SCRIPT" "$OUTPUT_PATH" 2>&1 || log "WARN: Frame TV upload failed (TV may be offline)"
else
  log "WARN: upload_to_frame.py not found, skipping TV upload"
fi

# Step 4: Record used artwork
log "Step 4: Recording used artwork..."
mkdir -p "$SKILL_DIR/data"
TMPJSON=$(mktemp)
python3 - <<PYEOF
import json, os
path = "$USED_LOG"
data = []
if os.path.exists(path):
    try:
        with open(path) as f:
            data = json.load(f)
        if not isinstance(data, list):
            data = []
    except Exception:
        data = []
data.append({"date":"$TODAY","title":"$TITLE","artist":"$ARTIST"})
with open("$TMPJSON", "w") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)
PYEOF
mv "$TMPJSON" "$USED_LOG"

# Step 5: Push LINE Flex
log "Step 5: Pushing LINE Flex..."
PUBLIC_URL="https://vault.life-os.work/90_System/Deliverables/frame-art/${TODAY}.jpg"
SEND_SCRIPT="$HOME/.openclaw/workspace/scripts/send-frame-flex.py"
if [ -f "$SEND_SCRIPT" ]; then
  python3 "$SEND_SCRIPT" "$PUBLIC_URL" "$TITLE" "$ARTIST — $YEAR" "$LINE_USER" 2>&1 \
    || log "WARN: LINE Flex push failed"
else
  log "WARN: send-frame-flex.py not found, skipping LINE push"
fi

log "Done. Poster at: $OUTPUT_PATH"
log "Public URL: $PUBLIC_URL"

# Cleanup
rm -f "$TMP_RAW" "$TMP_META"
