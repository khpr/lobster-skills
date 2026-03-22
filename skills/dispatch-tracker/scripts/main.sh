#!/usr/bin/env bash
set -euo pipefail

STORE="$HOME/.openclaw/workspace/tasks/dispatch-tracker.json"
mkdir -p "$(dirname "$STORE")"
[ -f "$STORE" ] || echo '{"items":[]}' > "$STORE"

usage() {
  echo "usage:" >&2
  echo "  $0 add <text>" >&2
  echo "  $0 done <id>" >&2
  echo "  $0 list" >&2
  echo "  $0 show <id>" >&2
}

cmd=${1:-}
shift || true

case "$cmd" in
  add)
    text=${1:-}
    if [[ -z "$text" ]]; then echo "missing text" >&2; usage; exit 2; fi
    python3 - <<PY
import json,uuid,datetime,os
p=os.path.expanduser("$STORE")
obj=json.load(open(p))
item={"id":str(uuid.uuid4())[:8],"text":"""%s"""%json.loads(json.dumps("""%s"""%text)) if False else text,"status":"open","created":datetime.datetime.utcnow().isoformat()+"Z"}
obj.setdefault('items',[]).append(item)
json.dump(obj, open(p,'w'), indent=2)
print(item['id'])
PY
    ;;
  done)
    id=${1:-}
    if [[ -z "$id" ]]; then echo "missing id" >&2; usage; exit 2; fi
    python3 - <<PY
import json,datetime,os,sys
p=os.path.expanduser("$STORE")
obj=json.load(open(p))
for it in obj.get('items',[]):
  if it.get('id')=="$id":
    it['status']='done'
    it['done_at']=datetime.datetime.utcnow().isoformat()+"Z"
    json.dump(obj, open(p,'w'), indent=2)
    print('ok')
    sys.exit(0)
print('not found', file=sys.stderr)
sys.exit(1)
PY
    ;;
  list)
    python3 - <<PY
import json,os
p=os.path.expanduser("$STORE")
obj=json.load(open(p))
for it in obj.get('items',[]):
  print(f"{it.get('id')}\t{it.get('status')}\t{it.get('text')}")
PY
    ;;
  show)
    id=${1:-}
    if [[ -z "$id" ]]; then echo "missing id" >&2; usage; exit 2; fi
    python3 - <<PY
import json,os,sys
p=os.path.expanduser("$STORE")
obj=json.load(open(p))
for it in obj.get('items',[]):
  if it.get('id')=="$id":
    print(json.dumps(it, ensure_ascii=False, indent=2))
    sys.exit(0)
print('not found', file=sys.stderr)
sys.exit(1)
PY
    ;;
  -h|--help|help|"") usage; exit 0 ;;
  *) echo "unknown cmd: $cmd" >&2; usage; exit 2 ;;
esac
