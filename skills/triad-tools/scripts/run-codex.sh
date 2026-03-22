#!/usr/bin/env bash
set -euo pipefail

# run-codex.sh <dir> <prompt>
# Minimal wrapper: uses codex exec with -C, logs output.

DIR=${1:-}
PROMPT=${2:-}

if [[ -z "$DIR" || -z "$PROMPT" ]]; then
  echo "usage: $0 <dir> <prompt>" >&2
  exit 2
fi

mkdir -p logs
TS=$(date +%Y%m%d-%H%M%S)
LOG="logs/triad-codex-${TS}.txt"

codex exec -C "$DIR" "$PROMPT" 2>&1 | tee -a "$LOG"
