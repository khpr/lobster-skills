#!/usr/bin/env bash
set -euo pipefail

# Skill wrapper around workspace/scripts/publish-gist.sh
# Usage: publish.sh <file> [--public] [--new]

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
exec "$ROOT/scripts/publish-gist.sh" "$@"
