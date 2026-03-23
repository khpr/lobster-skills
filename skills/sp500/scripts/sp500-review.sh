#!/usr/bin/env bash
# sp500-review.sh - 批量審核候選來源，偵測 RSS，輸出結構化 JSON 供 agent 評分
# 用法:
#   bash sp500-review.sh                    # 審核所有待審核條目
#   bash sp500-review.sh --domain example.com  # 只審核指定 domain

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DATA_DIR="$SKILL_DIR/data"
CANDIDATES_FILE="$DATA_DIR/candidates.md"
SOURCES_FILE="$DATA_DIR/sources.md"

TIMEOUT=10
TARGET_DOMAIN=""

# RSS 候選路徑
RSS_PATHS=("/feed" "/rss" "/atom.xml" "/feed.xml" "/rss.xml" "/index.xml" "/feeds/posts/default")

usage() {
  echo "用法: $0 [--domain <domain>]" >&2
  exit 1
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --domain) TARGET_DOMAIN="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "未知參數: $1" >&2; usage ;;
  esac
done

# 讀取待審核 domains
get_pending_domains() {
  if [[ ! -f "$CANDIDATES_FILE" ]]; then
    echo "錯誤：找不到 $CANDIDATES_FILE" >&2
    exit 1
  fi

  # 擷取 ## 待審核 區段（到下一個 ## 或 EOF）
  awk '/^## 待審核/{found=1; next} /^## /{if(found) exit} found && /^- /{print}' "$CANDIDATES_FILE" \
    | sed -E 's/^- [0-9]{4}-[0-9]{2}-[0-9]{2} \| ([^ |]+) \|.*/\1/'
}

# 測試 URL 可達性，回傳 HTTP status code
check_reachable() {
  local url="$1"
  curl -sI --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "$url" 2>/dev/null || echo "000"
}

# 嘗試偵測 RSS URL
detect_rss() {
  local domain="$1"
  local base_url="https://${domain}"

  for path in "${RSS_PATHS[@]}"; do
    local rss_url="${base_url}${path}"
    local status
    status="$(curl -sI --max-time "$TIMEOUT" -o /dev/null -w "%{http_code}" "$rss_url" 2>/dev/null || echo "000")"
    if [[ "$status" == "200" || "$status" == "301" || "$status" == "302" ]]; then
      # 確認是 XML/RSS 格式
      local content_type
      content_type="$(curl -sI --max-time "$TIMEOUT" "$rss_url" 2>/dev/null | grep -i "content-type" | head -1 || true)"
      if echo "$content_type" | grep -qi "xml\|rss\|atom"; then
        echo "$rss_url"
        return
      fi
    fi
  done
  echo "none"
}

# 取得首頁 title 和 meta description
get_page_meta() {
  local domain="$1"
  local base_url="https://${domain}"
  local html
  html="$(curl -sL --max-time "$TIMEOUT" "$base_url" 2>/dev/null | head -c 8192 || true)"

  local title
  title="$(echo "$html" | grep -oiE '<title[^>]*>[^<]+</title>' | head -1 | sed -E 's/<[^>]+>//g' | tr -d '\n' | xargs || echo "")"

  local desc
  desc="$(echo "$html" | grep -oiE '<meta[^>]+name="description"[^>]*>' | head -1 | grep -oiE 'content="[^"]+"' | sed 's/content="//;s/"$//' | xargs || echo "")"

  echo "{\"title\": $(printf '%s' "$title" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""'), \"description\": $(printf '%s' "$desc" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""')}"
}

# 輸出單一 domain 的 JSON 報告
review_domain() {
  local domain="$1"
  echo "--- 審核: $domain ---" >&2

  local base_url="https://${domain}"
  local http_status
  http_status="$(check_reachable "$base_url")"

  local reachable="false"
  if [[ "$http_status" == "200" || "$http_status" == "301" || "$http_status" == "302" || "$http_status" == "403" ]]; then
    reachable="true"
  fi

  local rss_url
  rss_url="$(detect_rss "$domain")"

  local meta
  meta="$(get_page_meta "$domain")"
  local title
  title="$(echo "$meta" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d["title"])' 2>/dev/null || echo "")"
  local description
  description="$(echo "$meta" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(d["description"])' 2>/dev/null || echo "")"

  python3 -c "
import json
print(json.dumps({
  'domain': '$domain',
  'url': 'https://$domain',
  'http_status': '$http_status',
  'reachable': $reachable,
  'rss': '$rss_url',
  'title': $(printf '%s' "$title" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""'),
  'description': $(printf '%s' "$description" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))' 2>/dev/null || echo '""'),
  'review_date': '$(date +%Y-%m-%d)',
  'next_step': 'agent_scoring_required'
}, ensure_ascii=False, indent=2))
"
}

# 主流程
echo "=== S&P 500 來源審核 $(date '+%Y-%m-%d %H:%M') ===" >&2
echo "" >&2

if [[ -n "$TARGET_DOMAIN" ]]; then
  review_domain "$TARGET_DOMAIN"
else
  domains="$(get_pending_domains)"
  if [[ -z "$domains" ]]; then
    echo "候選池無待審核條目。" >&2
    exit 0
  fi

  count=0
  echo "[" # JSON array start
  first=true
  while IFS= read -r domain; do
    [[ -z "$domain" ]] && continue
    if [[ "$first" == "true" ]]; then
      first=false
    else
      echo ","
    fi
    review_domain "$domain"
    ((count++)) || true
  done <<< "$domains"
  echo "]" # JSON array end

  echo "" >&2
  echo "=== 審核完成：共 $count 個 domain ===" >&2
  echo "請 agent 根據 references/scoring-guide.md 進行五維評分後，決定是否寫入 sources.md。" >&2
fi
