#!/usr/bin/env bash
set -euo pipefail

# run-gemini.sh <prompt> [--json]
# Minimal wrapper: logs output to logs/triad-gemini-*.txt

PROMPT=${1:-}
MODE=${2:-}

if [[ -z "$PROMPT" ]]; then
  echo "usage: $0 <prompt> [--json]" >&2
  exit 2
fi

mkdir -p logs
TS=$(date +%Y%m%d-%H%M%S)
LOG="logs/triad-gemini-${TS}.txt"

if [[ "$MODE" == "--json" ]]; then
  gemini --output-format json "$PROMPT" 2>&1 | tee -a "$LOG"
else
  gemini "$PROMPT" 2>&1 | tee -a "$LOG"
fi
