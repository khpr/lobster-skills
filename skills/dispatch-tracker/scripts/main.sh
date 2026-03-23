#!/usr/bin/env bash
# dispatch-tracker: simple dispatch list tracker (bash 3.2)
# Commands: add/done/list/check
set -euo pipefail

WS="${OPENCLAW_WORKSPACE:-$HOME/.openclaw/workspace}"
LOG_DIR="$WS/memory"
BOOK="$LOG_DIR/pending-dispatches.md"

mkdir -p "$LOG_DIR"

usage() {
  echo "usage:" >&2
  echo "  $0 add  <agent> <summary> [cardId]" >&2
  echo "  $0 done <keyword>" >&2
  echo "  $0 list" >&2
  echo "  $0 check" >&2
  echo >&2
  echo "env:" >&2
  echo "  OPENCLAW_WORKSPACE  default workspace path (e.g. ~/.openclaw/workspace-lobster)" >&2
}

die(){ echo "dispatch-tracker: $*" >&2; exit 2; }

init_book() {
  if [ ! -f "$BOOK" ]; then
    cat > "$BOOK" <<'EOF'
# Pending Dispatches

格式：
- [ ] <ISO_DATE> | <agent> | <summary> | <cardId?>
EOF
  fi
}

cmd=${1:-}
shift || true

init_book

case "$cmd" in
  add)
    agent=${1:-}; summary=${2:-}; card=${3:-}
    [ -n "$agent" ] || die "missing agent"
    [ -n "$summary" ] || die "missing summary"
    iso=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    if [ -n "$card" ]; then
      echo "- [ ] ${iso} | ${agent} | ${summary} | ${card}" >> "$BOOK"
    else
      echo "- [ ] ${iso} | ${agent} | ${summary}" >> "$BOOK"
    fi
    echo "✅ 已登記：${agent}｜${summary}"
    ;;

  done)
    kw=${1:-}
    [ -n "$kw" ] || die "missing keyword"
    # mark first matching unchecked line as done
    tmp=$(mktemp)
    marked=0
    while IFS= read -r line; do
      if [ $marked -eq 0 ] && echo "$line" | grep -q "^- \[ \]" && echo "$line" | grep -qi "$kw"; then
        echo "${line/\[ \]/[x]}" >> "$tmp"
        marked=1
      else
        echo "$line" >> "$tmp"
      fi
    done < "$BOOK"
    mv "$tmp" "$BOOK"

    if [ $marked -eq 1 ]; then
      echo "✅ 已完成：${kw}"
    else
      echo "⚠️ 找不到可完成項目：${kw}"
    fi
    ;;

  list)
    cat "$BOOK"
    ;;

  check)
    # count unchecked
    cnt=$(grep -c "^- \[ \]" "$BOOK" 2>/dev/null || true)
    if [ "${cnt:-0}" -gt 0 ]; then
      echo "⚠️ 尚有未完成派工：${cnt} 筆（見 ${BOOK}）"
    fi
    ;;

  -h|--help|help|"")
    usage
    exit 0
    ;;

  *)
    die "unknown command: $cmd"
    ;;
esac
