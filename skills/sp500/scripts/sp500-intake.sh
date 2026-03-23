#!/bin/bash
#
# sp500-intake.sh - 收錄新來源
#
# 用法：bash sp500-intake.sh <URL>
#
# 流程：
# 1. 提取 domain（去 www.）
# 2. 對照 blocklist
# 3. 查重 sources.md + candidates.md
# 4. 都不在 → append 到 candidates.md
# 5. 輸出結果

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$SKILL_DIR/data"

SOURCES="$DATA_DIR/sources.md"
CANDIDATES="$DATA_DIR/candidates.md"

# 聚合站黑名單
BLOCKLIST=(
    "news.google.com"
    "news.yahoo.com"
    "news.yahoo.co.jp"
    "smartnews.com"
    "flipboard.com"
    "apple.news"
    "line.me"
    "msn.com"
    "feedly.com"
    "news.livedoor.com"
)

# 提取 domain
extract_domain() {
    local url="$1"
    # 移除協議
    url="${url#http://}"
    url="${url#https://}"
    # 移除路徑
    url="${url%%/*}"
    # 移除 www.
    url="${url#www.}"
    echo "$url"
}

# 檢查是否在黑名單
is_blocked() {
    local domain="$1"
    for blocked in "${BLOCKLIST[@]}"; do
        if [[ "$domain" == "$blocked" ]] || [[ "$domain" == *".$blocked" ]]; then
            return 0
        fi
    done
    return 1
}

# 檢查是否已存在
exists_in_sources() {
    local domain="$1"
    grep -q "$domain" "$SOURCES" 2>/dev/null || return 1
}

exists_in_candidates() {
    local domain="$1"
    grep -q "$domain" "$CANDIDATES" 2>/dev/null || return 1
}

# 加入候選池
add_candidate() {
    local url="$1"
    local domain="$2"
    local timestamp=$(date +%Y-%m-%d)

    # 確保 candidates.md 有 ## 待審核 區塊
    if ! grep -q "^## 待審核" "$CANDIDATES" 2>/dev/null; then
        cat > "$CANDIDATES" << 'EOF'
# S&P 500 候選來源

## 待審核

EOF
    fi

    # append 到待審核區塊
    echo "- $timestamp | $domain | $url | 待審核" >> "$CANDIDATES"
    echo "✅ 已加入候選池：$domain"
}

# 主流程
main() {
    if [ $# -eq 0 ]; then
        echo "用法：bash $0 <URL>"
        exit 1
    fi

    local url="$1"
    local domain

    domain=$(extract_domain "$url")

    # 檢查黑名單
    if is_blocked "$domain"; then
        echo "⛔ 已封鎖：$domain（聚合站）"
        exit 0
    fi

    # 檢查重複
    if exists_in_sources "$domain"; then
        echo "⚠️ 已存在於來源池：$domain"
        exit 0
    fi

    if exists_in_candidates "$domain"; then
        echo "⚠️ 已存在於候選池：$domain"
        exit 0
    fi

    # 加入候選池
    add_candidate "$url" "$domain"
}

main "$@"
