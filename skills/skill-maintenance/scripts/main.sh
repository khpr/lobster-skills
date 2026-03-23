#!/usr/bin/env bash
# skill-maintenance: scan a skills directory and report common problems.
set -euo pipefail

SKILLS_DIR="${SKILLS_DIR:-}"
JSON=0

while [ $# -gt 0 ]; do
  case "$1" in
    --json) JSON=1 ;;
    -h|--help)
      echo "usage: SKILLS_DIR=/path/to/skills $0 [--json]" >&2
      exit 0
      ;;
    *)
      echo "unknown arg: $1" >&2
      exit 2
      ;;
  esac
  shift || true
done

[ -n "$SKILLS_DIR" ] || { echo "skill-maintenance: set SKILLS_DIR" >&2; exit 2; }
[ -d "$SKILLS_DIR" ] || { echo "skill-maintenance: not a dir: $SKILLS_DIR" >&2; exit 2; }

python3 - "$SKILLS_DIR" "$JSON" <<'PY'
import json, os, re, sys

skills_dir=sys.argv[1]
want_json=int(sys.argv[2])==1

required_frontmatter=['name','description','version']

results=[]

def read(p):
  with open(p,'r',encoding='utf-8') as f:
    return f.read()

def parse_frontmatter(md:str):
  # super-light parser: only checks key presence in the top --- block
  m=re.match(r"(?s)^---\n(.*?)\n---\n", md)
  if not m:
    return None
  block=m.group(1)
  keys=set()
  for line in block.splitlines():
    if re.match(r"^[A-Za-z0-9_\-]+\s*:\s*", line):
      keys.add(line.split(':',1)[0].strip())
  return keys

for name in sorted(os.listdir(skills_dir)):
  sp=os.path.join(skills_dir,name)
  if not os.path.isdir(sp):
    continue

  item={
    'skill': name,
    'path': sp,
    'ok': True,
    'issues': []
  }

  skill_md=os.path.join(sp,'SKILL.md')
  if not os.path.isfile(skill_md):
    item['ok']=False
    item['issues'].append('missing SKILL.md')
    results.append(item)
    continue

  md=read(skill_md)
  fm=parse_frontmatter(md)
  if fm is None:
    item['ok']=False
    item['issues'].append('missing YAML frontmatter (--- ... ---)')
  else:
    missing=[k for k in required_frontmatter if k not in fm]
    if missing:
      item['ok']=False
      item['issues'].append('frontmatter missing keys: '+', '.join(missing))

  scripts=os.path.join(sp,'scripts')
  if os.path.isdir(scripts):
    for fn in os.listdir(scripts):
      if not fn.endswith('.sh'):
        continue
      fp=os.path.join(scripts,fn)
      try:
        st=os.stat(fp)
        if (st.st_mode & 0o111)==0:
          item['ok']=False
          item['issues'].append(f'script not executable: scripts/{fn}')
      except Exception as e:
        item['ok']=False
        item['issues'].append(f'cannot stat scripts/{fn}: {e}')

  results.append(item)

summary={
  'skills': len([r for r in results if os.path.isdir(r['path'])]),
  'pass': len([r for r in results if r['ok']]),
  'fail': len([r for r in results if not r['ok']]),
}

if want_json:
  print(json.dumps({'summary':summary,'results':results},ensure_ascii=False,indent=2))
else:
  print(f"SKILL 健檢：總數 {summary['skills']}｜Pass {summary['pass']}｜Fail {summary['fail']}")
  for r in results:
    if not r['ok']:
      print(f"- {r['skill']}: " + '; '.join(r['issues']))
PY
