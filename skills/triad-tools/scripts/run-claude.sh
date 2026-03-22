#!/usr/bin/env bash
set -euo pipefail

# run-claude.sh <dir>
# Starts Claude Code in the target directory, logs to logs/triad-claude-*.txt
# Note: Claude Code is interactive; best run in a TTY.

DIR=${1:-}
if [[ -z "$DIR" ]]; then
  echo "usage: $0 <dir>" >&2
  exit 2
fi

mkdir -p logs
TS=$(date +%Y%m%d-%H%M%S)
LOG="logs/triad-claude-${TS}.txt"

cd "$DIR"
claude 2>&1 | tee -a "$LOG"
