#!/usr/bin/env bash
# line-channel-config-check/scripts/main.sh
# Diagnose and guide repair of LINE channel configuration issues
# Version: 1.0  Created: 2026-03-23
# Compatible: bash 3.2+

set -euo pipefail

OPENCLAW_JSON="$HOME/.openclaw/openclaw.json"

usage() {
  echo "Usage: $0 [diagnose|token-check|webhook-check|full]" >&2
  echo "  diagnose     - Run full diagnosis (default)" >&2
  echo "  token-check  - Check token validity only" >&2
  echo "  webhook-check - Check webhook endpoint only" >&2
  echo "  full         - All checks with verbose output" >&2
  exit 1
}

check_deps() {
  for bin in jq curl; do
    if ! command -v "$bin" >/dev/null 2>&1; then
      echo "ERROR: required binary '$bin' not found" >&2
      exit 2
    fi
  done
}

check_json_readable() {
  if [ ! -r "$OPENCLAW_JSON" ]; then
    echo "ERROR: cannot read $OPENCLAW_JSON — check file permissions" >&2
    exit 2
  fi
}

step1_status() {
  echo "=== Step 1: openclaw status (LINE) ==="
  openclaw status 2>&1 | grep -A2 "LINE" || echo "(no LINE entry found)"
  echo ""

  echo "=== LINE config fields present ==="
  jq '.channels.line | keys' "$OPENCLAW_JSON" 2>/dev/null || echo "(could not parse openclaw.json)"
  echo ""
}

step2_token_length() {
  echo "=== Step 2: Token format check ==="
  TOKEN_LEN=$(jq '.channels.line.channelAccessToken | length' "$OPENCLAW_JSON" 2>/dev/null || echo 0)
  echo "channelAccessToken length: $TOKEN_LEN"
  if [ "$TOKEN_LEN" -eq 0 ]; then
    echo "WARN: token is empty or null — needs re-issue" >&2
  elif [ "$TOKEN_LEN" -lt 100 ]; then
    echo "WARN: token length looks too short (expected 170+)" >&2
  else
    echo "OK: token length looks normal"
  fi
  echo ""
}

step3_token_api() {
  echo "=== Step 3: Token validity (API call) ==="
  TOKEN=$(jq -r '.channels.line.channelAccessToken // empty' "$OPENCLAW_JSON" 2>/dev/null)
  if [ -z "$TOKEN" ]; then
    echo "SKIP: token is empty, cannot call API" >&2
    return 0
  fi
  HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" \
    -H "Authorization: Bearer $TOKEN" \
    https://api.line.me/v2/bot/info 2>&1)
  echo "API response code: $HTTP_CODE"
  if [ "$HTTP_CODE" = "200" ]; then
    echo "OK: token is valid"
  elif [ "$HTTP_CODE" = "401" ] || [ "$HTTP_CODE" = "403" ]; then
    echo "WARN: token invalid or expired (HTTP $HTTP_CODE) — re-issue required" >&2
  else
    echo "WARN: unexpected response ($HTTP_CODE)" >&2
  fi
  echo ""
}

step4_webhook() {
  echo "=== Step 4: Webhook endpoint check ==="
  TOKEN=$(jq -r '.channels.line.channelAccessToken // empty' "$OPENCLAW_JSON" 2>/dev/null)
  if [ -z "$TOKEN" ]; then
    echo "SKIP: token is empty, cannot call webhook API" >&2
    return 0
  fi
  RESULT=$(curl -s \
    -H "Authorization: Bearer $TOKEN" \
    https://api.line.me/v2/bot/channel/webhook/endpoint 2>&1)
  echo "$RESULT" | jq . 2>/dev/null || echo "$RESULT"
  ACTIVE=$(echo "$RESULT" | jq -r '.active // "unknown"' 2>/dev/null)
  WH_URL=$(echo "$RESULT" | jq -r '.webhookEndpointUrl // "unknown"' 2>/dev/null)
  echo "Webhook active: $ACTIVE"
  echo "Webhook URL:    $WH_URL"
  echo ""
}

main() {
  MODE="${1:-diagnose}"
  check_deps
  check_json_readable

  case "$MODE" in
    diagnose|full)
      step1_status
      step2_token_length
      step3_token_api
      step4_webhook
      ;;
    token-check)
      step2_token_length
      step3_token_api
      ;;
    webhook-check)
      step4_webhook
      ;;
    *)
      usage
      ;;
  esac

  echo "=== Diagnosis complete ==="
  echo "For repair steps, refer to SKILL.md Step 5."
}

main "$@"
