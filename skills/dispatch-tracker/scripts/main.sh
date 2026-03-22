#!/bin/bash
# dispatch-tracker skill wrapper
# Usage: main.sh <action> [args...]
# Actions: add, done, list, check
set -uo pipefail

SCRIPT="$HOME/.openclaw/workspace/scripts/dispatch-tracker.sh"

if [ ! -f "$SCRIPT" ]; then
  echo "ERROR: dispatch-tracker.sh not found at $SCRIPT" >&2
  exit 1
fi

ACTION="${1:-list}"
shift || true

bash "$SCRIPT" "$ACTION" "$@"
