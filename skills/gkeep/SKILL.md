---
name: gkeep
description: Read and manage Google Keep notes via gkeep.sh CLI wrapper (gkeepapi). Use when asked to list, search, read, create, or organize Keep notes. Triggers on keep, notes, memo, sticky note, google keep keywords.
metadata: {"clawdbot":{"emoji":"📝","requires":{"python":["gkeepapi"]}}}
---

# Google Keep Integration

Read and manage Google Keep notes via `gkeep.sh` CLI wrapper.

## CLI Usage

Script: `~/.openclaw/skills/gkeep/gkeep.sh`

```bash
# List notes (default 20)
bash ~/.openclaw/skills/gkeep/gkeep.sh list
bash ~/.openclaw/skills/gkeep/gkeep.sh list --pinned
bash ~/.openclaw/skills/gkeep/gkeep.sh list --limit 5

# Search
bash ~/.openclaw/skills/gkeep/gkeep.sh search "購物"

# Read full note
bash ~/.openclaw/skills/gkeep/gkeep.sh read <note_id>

# Create note / checklist
bash ~/.openclaw/skills/gkeep/gkeep.sh create "Title" "Body text"
bash ~/.openclaw/skills/gkeep/gkeep.sh create-list "Shopping" "milk,eggs,bread"

# Labels
bash ~/.openclaw/skills/gkeep/gkeep.sh labels

# Pin/unpin
bash ~/.openclaw/skills/gkeep/gkeep.sh pin <note_id>
bash ~/.openclaw/skills/gkeep/gkeep.sh unpin <note_id>

# Color
bash ~/.openclaw/skills/gkeep/gkeep.sh color <note_id> blue
```

## Authentication

Master token at `~/.config/gkeep/token.json` (walkpod@gmail.com personal account).
Token obtained via gpsoauth (Android device simulation).
If BadAuthentication → regenerate at myaccount.google.com/apppasswords.

## Notes

- gkeepapi is unofficial; official Keep API requires Workspace enterprise
- 236 notes synced as of 2026-03-06
- Token refresh needed if Google revokes master token

## Gotchas
- 執行前先確認前置檔案/旗標存在；缺少時直接回報並停止，不要硬做。
- 需要改檔時先備份（.bak），避免錯誤覆寫不可回復。
- 回覆外部訊息前，先完成核心產出檔落地，避免「只說完成但無檔案」。
- 若模型或 API 出現 rate limit / 400 錯誤，改用備援模型並重跑，不要把空跑當成功。
