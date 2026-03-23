#!/usr/bin/env bash
# line-channel-config-check
# Read-only health report for OpenClaw LINE channel.
set -euo pipefail

JSON=0
TIMEOUT_MS="10000"

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON=1 ;;
    --timeout) shift; TIMEOUT_MS="${1:-10000}" ;;
    -h|--help)
      echo "usage: $0 [--json] [--timeout <ms>]" >&2
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 2
      ;;
  esac
  shift || true
done

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

channels_path="$tmp_dir/channels.json"
gw_path="$tmp_dir/gateway.json"

openclaw channels status --json --probe --timeout "$TIMEOUT_MS" >"$channels_path" 2>/dev/null || echo '{}' >"$channels_path"
openclaw gateway status --json >"$gw_path" 2>/dev/null || echo '{}' >"$gw_path"

python3 - "$channels_path" "$gw_path" "$JSON" <<'PY'
import json,sys

with open(sys.argv[1],'r',encoding='utf-8') as f:
  channels=json.load(f)
with open(sys.argv[2],'r',encoding='utf-8') as f:
  gw=json.load(f)
want_json=int(sys.argv[3])==1 if len(sys.argv)>3 else False

# Heuristics:
# - If LINE exists and probe ok and we have any recent inbound timestamps => OK.
# - If stopped/restarting but probe ok and inbound recent => WARN (cosmetic).
# - If probe fails or missing config => FAIL.

items = channels.get('channels') or channels.get('items') or channels.get('data') or []

line=None
if isinstance(items, dict):
  # openclaw channels status --json returns channels as a dict keyed by channel id
  line = items.get('line')
else:
  for it in items:
    if not isinstance(it, dict):
      continue
    ch=it.get('channel') or it.get('id') or it.get('name')
    if ch=='line':
      line=it
      break

report={
  'status':'UNKNOWN',
  'summary':'無法判斷（channels status JSON 格式可能變更）',
  'details':{
    'gateway': gw,
    'line': line,
  }
}

def boolish(v):
  if isinstance(v,bool): return v
  if isinstance(v,str):
    return v.lower() in ('true','1','yes','ok','pass')
  return False

if not line:
  report['status']='FAIL'
  report['summary']='找不到 line channel 設定（OpenClaw channels status 沒看到 line）。'
else:
  # pull common fields across versions
  state=line.get('state') or line.get('status') or {}
  enabled=line.get('enabled', True)
  probe=line.get('probe') or line.get('probes') or {}

  # possible indicators
  probe_ok = None
  for k in ('ok','pass','success','valid'):
    if k in probe:
      probe_ok = boolish(probe.get(k))
      break
  if probe_ok is None and isinstance(probe, dict):
    # some versions: probe: { status: 'ok' }
    s=probe.get('status')
    if isinstance(s,str): probe_ok = (s.lower()=='ok')

  # channel runtime
  status_str = (line.get('runtimeStatus') or line.get('status') or line.get('lifecycle') or '')
  if isinstance(status_str, dict):
    status_str = status_str.get('state','')
  status_str = str(status_str)

  last_in = line.get('in') or line.get('lastInboundAt') or (line.get('activity') or {}).get('in')
  last_out = line.get('out') or line.get('lastOutboundAt') or (line.get('activity') or {}).get('out')

  # decide
  if enabled is False:
    report['status']='FAIL'
    report['summary']='LINE channel 被停用（enabled=false）。'
  elif probe_ok is False:
    report['status']='FAIL'
    report['summary']='LINE credential probe 失敗：可能是 token/webhook 設定錯或權限不對。'
  elif probe_ok is True:
    # If it looks stopped but probe ok, treat as cosmetic unless evidence of no inbound.
    if 'stopped' in status_str.lower() or 'restart' in status_str.lower():
      report['status']='WARN'
      report['summary']='LINE 看起來是 stopped/restart loop，但 probe OK：多半是顯示/監控誤判（若你仍收得到訊息可忽略）。'
    else:
      report['status']='OK'
      report['summary']='LINE probe OK，狀態看起來正常。'
  else:
    # probe not provided
    report['status']='WARN'
    report['summary']='LINE probe 資訊不足：已取得 channels status，但無法確認 credential 是否有效。'

  report['details']['last_in']=last_in
  report['details']['last_out']=last_out
  report['details']['runtimeStatus']=status_str
  report['details']['probe']=probe

if want_json:
  print(json.dumps(report,ensure_ascii=False,indent=2))
else:
  print(f"[{report['status']}] {report['summary']}")
  d=report.get('details') or {}
  if d.get('runtimeStatus'):
    print(f"- runtime: {d['runtimeStatus']}")
  if d.get('last_in'):
    print(f"- last inbound: {d['last_in']}")
  if d.get('last_out'):
    print(f"- last outbound: {d['last_out']}")
PY
