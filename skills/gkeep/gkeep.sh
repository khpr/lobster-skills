#!/usr/bin/env bash
# gkeep.sh — Google Keep CLI wrapper via gkeepapi
# Usage: gkeep.sh <command> [args]
#   list [--pinned] [--limit N]
#   search <query> [--limit N]
#   read <note_id>
#   create <title> [body]
#   create-list <title> <item1,item2,...>
#   labels
#   pin <note_id>
#   unpin <note_id>
#   color <note_id> <color>

set -euo pipefail

TOKEN_FILE="$HOME/.config/gkeep/token.json"

if [ ! -f "$TOKEN_FILE" ]; then
  echo "ERROR: Token file not found at $TOKEN_FILE" >&2
  exit 1
fi

CMD="${1:-help}"
shift 2>/dev/null || true

python3 - "$CMD" "$@" << 'PYEOF'
import sys, json, gkeepapi, os
from datetime import datetime

def load_keep():
    token_file = os.path.expanduser("~/.config/gkeep/token.json")
    with open(token_file) as f:
        creds = json.load(f)
    keep = gkeepapi.Keep()
    keep.authenticate(creds["email"], creds["token"])
    keep.sync()
    return keep

def fmt_note(n, brief=True):
    ts = n.timestamps.updated.strftime("%Y-%m-%d %H:%M") if n.timestamps.updated else "?"
    labels = ", ".join(l.name for l in n.labels.all()) if n.labels.all() else ""
    pin = "📌 " if n.pinned else ""
    color = f"[{n.color.name}]" if n.color and n.color.name != "White" else ""
    
    header = f"{pin}{n.title or '(untitled)'} {color}"
    if labels:
        header += f" #{labels}"
    header += f"  ({ts})"
    header += f"\n  id: {n.id}"
    
    if brief:
        text = (n.text or "")[:100]
        if len(n.text or "") > 100:
            text += "..."
        if text:
            header += f"\n  {text}"
    else:
        header += f"\n{n.text or ''}"
    
    # Handle list items
    if hasattr(n, 'items') and callable(getattr(n, 'items', None)):
        pass
    elif hasattr(n, 'checked') or hasattr(n, 'unchecked'):
        try:
            unchecked = n.unchecked
            checked = n.checked
            for item in unchecked:
                header += f"\n  ☐ {item.text}"
            for item in checked:
                header += f"\n  ☑ {item.text}"
        except:
            pass
    
    return header

def main():
    args = sys.argv[1:]
    cmd = args[0] if args else "help"
    rest = args[1:]
    
    if cmd == "help":
        print("""gkeep.sh — Google Keep CLI
Commands:
  list [--pinned] [--limit N]    List notes
  search <query> [--limit N]     Search notes
  read <note_id>                 Read full note
  create <title> [body]          Create note
  create-list <title> <items>    Create checklist (comma-separated)
  labels                         List all labels
  pin <note_id>                  Pin a note
  unpin <note_id>                Unpin a note
  color <note_id> <color>        Set note color""")
        return
    
    keep = load_keep()
    
    if cmd == "list":
        pinned_only = "--pinned" in rest
        limit = 20
        for i, a in enumerate(rest):
            if a == "--limit" and i+1 < len(rest):
                limit = int(rest[i+1])
        
        notes = list(keep.all())
        if pinned_only:
            notes = [n for n in notes if n.pinned]
        notes = [n for n in notes if not n.trashed]
        
        print(f"Total: {len(notes)} notes" + (" (pinned)" if pinned_only else ""))
        print("---")
        for n in notes[:limit]:
            print(fmt_note(n))
            print()
    
    elif cmd == "search":
        if not rest:
            print("ERROR: search requires a query", file=sys.stderr)
            sys.exit(1)
        query = rest[0]
        limit = 10
        for i, a in enumerate(rest):
            if a == "--limit" and i+1 < len(rest):
                limit = int(rest[i+1])
        
        results = list(keep.find(query=query))
        results = [n for n in results if not n.trashed]
        print(f"Found {len(results)} notes matching '{query}'")
        print("---")
        for n in results[:limit]:
            print(fmt_note(n))
            print()
    
    elif cmd == "read":
        if not rest:
            print("ERROR: read requires a note_id", file=sys.stderr)
            sys.exit(1)
        note_id = rest[0]
        note = keep.get(note_id)
        if not note:
            print(f"ERROR: Note {note_id} not found", file=sys.stderr)
            sys.exit(1)
        print(fmt_note(note, brief=False))
    
    elif cmd == "create":
        if not rest:
            print("ERROR: create requires a title", file=sys.stderr)
            sys.exit(1)
        title = rest[0]
        body = rest[1] if len(rest) > 1 else ""
        note = keep.createNote(title, body)
        keep.sync()
        print(f"Created: {note.title} (id: {note.id})")
    
    elif cmd == "create-list":
        if len(rest) < 2:
            print("ERROR: create-list requires title and items", file=sys.stderr)
            sys.exit(1)
        title = rest[0]
        items = [(item.strip(), False) for item in rest[1].split(",")]
        note = keep.createList(title, items)
        keep.sync()
        print(f"Created list: {note.title} (id: {note.id})")
    
    elif cmd == "labels":
        for label in keep.labels():
            print(f"  {label.name}")
    
    elif cmd == "pin":
        if not rest:
            print("ERROR: pin requires a note_id", file=sys.stderr)
            sys.exit(1)
        note = keep.get(rest[0])
        if not note:
            print(f"ERROR: Note not found", file=sys.stderr)
            sys.exit(1)
        note.pinned = True
        keep.sync()
        print(f"Pinned: {note.title}")
    
    elif cmd == "unpin":
        if not rest:
            print("ERROR: unpin requires a note_id", file=sys.stderr)
            sys.exit(1)
        note = keep.get(rest[0])
        if not note:
            print(f"ERROR: Note not found", file=sys.stderr)
            sys.exit(1)
        note.pinned = False
        keep.sync()
        print(f"Unpinned: {note.title}")
    
    elif cmd == "color":
        if len(rest) < 2:
            print("ERROR: color requires note_id and color name", file=sys.stderr)
            sys.exit(1)
        note = keep.get(rest[0])
        if not note:
            print(f"ERROR: Note not found", file=sys.stderr)
            sys.exit(1)
        color_map = {
            "white": gkeepapi.node.ColorValue.White,
            "red": gkeepapi.node.ColorValue.Red,
            "orange": gkeepapi.node.ColorValue.Orange,
            "yellow": gkeepapi.node.ColorValue.Yellow,
            "green": gkeepapi.node.ColorValue.Green,
            "teal": gkeepapi.node.ColorValue.Teal,
            "blue": gkeepapi.node.ColorValue.Blue,
            "cerulean": gkeepapi.node.ColorValue.DarkBlue,
            "purple": gkeepapi.node.ColorValue.Purple,
            "pink": gkeepapi.node.ColorValue.Pink,
            "brown": gkeepapi.node.ColorValue.Brown,
            "gray": gkeepapi.node.ColorValue.Gray,
        }
        c = color_map.get(rest[1].lower())
        if not c:
            print(f"Available colors: {', '.join(color_map.keys())}", file=sys.stderr)
            sys.exit(1)
        note.color = c
        keep.sync()
        print(f"Color set: {note.title} → {rest[1]}")
    
    else:
        print(f"Unknown command: {cmd}", file=sys.stderr)
        sys.exit(1)

main()
PYEOF
