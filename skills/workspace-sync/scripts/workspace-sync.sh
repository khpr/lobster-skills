#!/bin/bash
# workspace-sync.sh — 跨 agent workspace 文件同步
# 用法：workspace-sync.sh [diff|sync|check]

set -euo pipefail

ACTION="${1:-diff}"
LOBSTER_WS="$HOME/.openclaw/workspace-lobster"
LOBSTER_AGENTS="$LOBSTER_WS/AGENTS.md"

# 非 worker 的 agent workspace
AGENT_WORKSPACES=(
  "$HOME/.openclaw/workspace-eng-ui"
  "$HOME/.openclaw/workspace-pm"
  "$HOME/.openclaw/workspace-redteam"
  "$HOME/.openclaw/workspace-market-social"
  "$HOME/.openclaw/workspace-sales-bizdev"
)

# 要同步的區塊標題（正則）
SYNC_SECTIONS=(
  "## Session 啟動"
  "## 安全線"
  "## 絕對禁令"
)

# 從 AGENTS.md 擷取指定區塊（到下一個 ## 為止）
extract_section() {
  local file="$1"
  local header="$2"
  # 用 awk 擷取從 header 到下一個 ## 之間的內容
  awk -v h="$header" '
    $0 ~ h { found=1; print; next }
    found && /^## / { exit }
    found { print }
  ' "$file"
}

# ── diff 模式 ──
do_diff() {
  local has_diff=0

  for ws in "${AGENT_WORKSPACES[@]}"; do
    local agent_name=$(basename "$ws" | sed 's/workspace-//')
    local agent_file="$ws/AGENTS.md"

    if [[ ! -f "$agent_file" ]]; then
      echo "⚠️  $agent_name: 沒有 AGENTS.md，跳過"
      continue
    fi

    for section in "${SYNC_SECTIONS[@]}"; do
      local lobster_content=$(extract_section "$LOBSTER_AGENTS" "$section")
      local agent_content=$(extract_section "$agent_file" "$section")

      if [[ -z "$lobster_content" ]]; then
        continue  # lobster 沒有這個區塊
      fi

      if [[ -z "$agent_content" ]]; then
        echo "❌ $agent_name: 缺少「$section」區塊"
        has_diff=1
      elif [[ "$lobster_content" != "$agent_content" ]]; then
        echo "🔄 $agent_name: 「$section」與 lobster 不同"
        has_diff=1
      fi
    done
  done

  if [[ $has_diff -eq 0 ]]; then
    echo "✅ 所有 agent 的共用區塊與 lobster 一致"
  fi

  return $has_diff
}

# ── sync 模式 ──
do_sync() {
  echo "📋 先跑 diff 確認差異..."
  echo ""

  # 先 diff，沒差異就不動
  if do_diff; then
    echo ""
    echo "無需同步"
    return 0
  fi

  echo ""
  echo "🔄 開始同步..."

  for ws in "${AGENT_WORKSPACES[@]}"; do
    local agent_name=$(basename "$ws" | sed 's/workspace-//')
    local agent_file="$ws/AGENTS.md"

    if [[ ! -f "$agent_file" ]]; then
      continue
    fi

    local changed=0

    for section in "${SYNC_SECTIONS[@]}"; do
      local lobster_content=$(extract_section "$LOBSTER_AGENTS" "$section")

      if [[ -z "$lobster_content" ]]; then
        continue
      fi

      local agent_content=$(extract_section "$agent_file" "$section")

      if [[ "$lobster_content" == "$agent_content" ]]; then
        continue
      fi

      # 備份
      if [[ $changed -eq 0 ]]; then
        mkdir -p "$ws/.agents-md-backup"
        cp "$agent_file" "$ws/.agents-md-backup/AGENTS.md.$(date +%Y%m%d-%H%M%S)"
        changed=1
      fi

      if [[ -z "$agent_content" ]]; then
        # 區塊不存在，附加到檔案末尾
        echo "" >> "$agent_file"
        echo "$lobster_content" >> "$agent_file"
        echo "  ✅ $agent_name: 新增「$section」"
      else
        # 區塊存在但不同，用 python 替換
        python3 -c "
import re, sys

with open(sys.argv[1], 'r') as f:
    content = f.read()

old_section = sys.argv[2]
new_section = sys.argv[3]

# Find the section and replace it
if old_section in content:
    content = content.replace(old_section, new_section)
    with open(sys.argv[1], 'w') as f:
        f.write(content)
    print(f'  ✅ {sys.argv[4]}: 更新「{sys.argv[5]}」')
else:
    print(f'  ⚠️  {sys.argv[4]}: 找不到區塊，跳過')
" "$agent_file" "$agent_content" "$lobster_content" "$agent_name" "$section"
      fi
    done
  done

  echo ""
  echo "✅ 同步完成"
}

# ── check 模式（靜默，給 cron 用）──
do_check() {
  local has_diff=0

  for ws in "${AGENT_WORKSPACES[@]}"; do
    local agent_file="$ws/AGENTS.md"
    [[ ! -f "$agent_file" ]] && continue

    for section in "${SYNC_SECTIONS[@]}"; do
      local lobster_content=$(extract_section "$LOBSTER_AGENTS" "$section")
      local agent_content=$(extract_section "$agent_file" "$section")

      [[ -z "$lobster_content" ]] && continue

      if [[ "$lobster_content" != "$agent_content" ]]; then
        has_diff=1
        break 2
      fi
    done
  done

  exit $has_diff
}

# ── 主流程 ──
case "$ACTION" in
  diff)  do_diff ;;
  sync)  do_sync ;;
  check) do_check ;;
  *)
    echo "用法：workspace-sync.sh [diff|sync|check]"
    exit 1
    ;;
esac
