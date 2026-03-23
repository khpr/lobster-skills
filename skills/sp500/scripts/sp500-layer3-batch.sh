#!/bin/bash
# sp500-layer3-batch.sh — Layer 3 批次驗質，支援斷點續跑
# 用法：
#   跑下一批（預設 5 個）：bash sp500-layer3-batch.sh
#   指定數量：bash sp500-layer3-batch.sh --limit 3
#   看進度：bash sp500-layer3-batch.sh --status
#   重置進度：bash sp500-layer3-batch.sh --reset

SKILL_DIR="$HOME/.openclaw/skills/sp500"
CANDIDATES="$SKILL_DIR/data/candidates.md"
SOURCES="$SKILL_DIR/data/sources.md"
PROGRESS="$SKILL_DIR/data/layer3-progress.json"
RESULTS="$SKILL_DIR/data/layer3-results.md"
LIMIT=5

# 初始化進度檔
if [ ! -f "$PROGRESS" ]; then
  echo '{"processed":[],"passed":[],"failed":[]}' > "$PROGRESS"
fi

# 指令解析
case "$1" in
  --status)
    TOTAL=$(grep -c "^- 2026" "$CANDIDATES" 2>/dev/null || echo 0)
    DONE=$(python3 -c "import json; d=json.load(open('$PROGRESS')); print(len(d['processed']))" 2>/dev/null || echo 0)
    PASS=$(python3 -c "import json; d=json.load(open('$PROGRESS')); print(len(d['passed']))" 2>/dev/null || echo 0)
    FAIL=$(python3 -c "import json; d=json.load(open('$PROGRESS')); print(len(d['failed']))" 2>/dev/null || echo 0)
    echo "=== Layer 3 進度 ==="
    echo "候選總數：$TOTAL"
    echo "已處理：$DONE（通過：$PASS / 不通過：$FAIL）"
    echo "剩餘：$(( TOTAL - DONE ))"
    exit 0
    ;;
  --reset)
    echo '{"processed":[],"passed":[],"failed":[]}' > "$PROGRESS"
    echo "進度已重置"
    exit 0
    ;;
  --limit)
    LIMIT="$2"
    ;;
esac

# 讀取已處理清單
PROCESSED=$(python3 -c "import json; d=json.load(open('$PROGRESS')); print('\n'.join(d['processed']))" 2>/dev/null)

# 從 candidates.md 取出待審核條目
COUNT=0
while IFS= read -r line; do
  # 只處理 "待審核" 行
  [[ "$line" =~ ^-\ 2026 ]] || continue
  [[ "$line" =~ 待審核 ]] || continue

  # 提取 domain（第二欄）
  DOMAIN=$(echo "$line" | awk -F'|' '{print $2}' | xargs)
  [[ -z "$DOMAIN" ]] && continue

  # 跳過已處理
  echo "$PROCESSED" | grep -q "^$DOMAIN$" && continue

  # 提取資訊
  NAME=$(echo "$line" | awk -F'|' '{print $3}' | xargs)
  URL=$(echo "$line" | awk -F'|' '{print $4}' | xargs | sed 's/https:\/\///;s/http:\/\///')
  FULL_URL=$(echo "$line" | awk -F'|' '{print $4}' | xargs)
  RSS=$(echo "$line" | awk -F'|' '{print $5}' | xargs | sed 's/RSS: //')
  CATEGORY=$(echo "$line" | awk -F'|' '{print $6}' | xargs)

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▶ 驗質：$NAME ($DOMAIN)"
  echo "  分類：$CATEGORY"
  echo "  RSS：$RSS"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # 標記為已處理（先寫，防止 timeout 重跑）
  python3 -c "
import json
d = json.load(open('$PROGRESS'))
if '$DOMAIN' not in d['processed']:
    d['processed'].append('$DOMAIN')
json.dump(d, open('$PROGRESS','w'))
"

  # 輸出結果 stub（讓 agent 填）
  echo "  → 需要 agent 執行 web_fetch 驗質"
  echo "  DOMAIN=$DOMAIN NAME=$NAME URL=$FULL_URL CATEGORY=$CATEGORY RSS=$RSS"

  COUNT=$(( COUNT + 1 ))
  [ "$COUNT" -ge "$LIMIT" ] && break

done < "$CANDIDATES"

echo ""
echo "=== 本批次完成 $COUNT 個 ==="
bash "$SKILL_DIR/scripts/sp500-layer3-batch.sh" --status
