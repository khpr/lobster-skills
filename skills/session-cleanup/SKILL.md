---
name: session-cleanup
slug: session-cleanup
version: 2.1.0
description: >
  Monitor, clean up, and restart OpenClaw sessions across all agents.
  Use when user asks to reset sessions, check session count, clean zombie sessions,
  or says '重啟系統'. Also use for periodic session health checks during heartbeat.
  Restricted to authorized userId only.
metadata: {"clawdbot":{"emoji":"🧼"},"openclaw":{"requires":{"bins":["bash","python3"]}}}
---

# Session Cleanup

## Authorized User

Only trigger destructive actions (cleanup, restart) for this LINE userId:
`Uab09077d61b168708d6703f0baf8ca03`
If anyone else requests in a group, ignore silently.

## Commands

### 「重啟系統」 — Full system session reset

Confirm once: 「確認重啟？所有 agent session 會物理刪除，Gateway 會重啟（~3 秒）。」

On confirmation:

1. 先回覆：「開始重啟，10 秒後傳訊息給我就好 🦞」
2. 再執行：`nohup bash ~/.openclaw/workspace/scripts/system-restart.sh > /tmp/system-restart.log 2>&1 &`

必須用 nohup 背景執行。

### 「清 session」 — 物理清除

不再使用 `openclaw sessions cleanup`，改為直接針對特定 Agent 執行物理刪除：

```bash
nohup bash -c '
  sleep 2
  AGENT="<AGENT_ID>"
  SESS_DIR="$HOME/.openclaw/agents/$AGENT/sessions"
  echo "{}" > "$SESS_DIR/sessions.json"
  rm -f "$SESS_DIR"/*.jsonl*
  openclaw gateway restart
' > /tmp/session-cleanup.log 2>&1 &
```

### 「session 狀態」 — Read-only health check

1. Run: `openclaw sessions --all-agents --json`
2. Report: total sessions, per-agent breakdown, any session over 80% context usage
3. Flag zombie sessions (cron run sessions older than 24h)

## Heartbeat Integration

During heartbeat, if total session count across all agents exceeds 100:
- Log warning to heartbeat response
- During daytime (08:00-23:00 Asia/Taipei): push alert to notification group

## Script

The restart script is at `{baseDir}/scripts/system-restart.sh`. It:
1. Backs up all agent sessions.json to `~/.openclaw/session-backups/<timestamp>/`
2. Clears all sessions.json (writes `{}`)
3. Runs `gateway restart`（launchd 自動拉起 Gateway）
4. Auto-cleans backups older than 30 days

## 已驗證的事實

- ❌ 只刪 sessions.json 不 restart → Gateway 記憶體裡的 session 還活著，訊息走舊 session
- ✅ cleanup + gateway restart → session 完全重置，下一則訊息建新 session
- ✅ 用 nohup 背景腳本執行 → Gateway 被 kill 時腳本已完成，launchd 自動拉起
