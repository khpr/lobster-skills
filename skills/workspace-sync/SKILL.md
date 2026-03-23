---
name: workspace-sync
description: 跨 agent workspace 文件同步。偵測 lobster AGENTS.md 的關鍵區塊變更，自動同步到所有 agent workspace。觸發詞：同步、sync workspace、同步 agent。
---

# Workspace Sync — 跨 Agent 文件同步

## 用途

lobster 是主控 agent，AGENTS.md 裡的共用區塊（啟動流程、安全線、禁令等）改動後，需要同步到所有其他 agent 的 AGENTS.md。手動改七份容易漏，這個技能自動化這件事。

## 使用方式

```bash
bash ~/.openclaw/skills/workspace-sync/scripts/workspace-sync.sh [動作]
```

### 動作

| 動作 | 說明 |
|------|------|
| `diff` | 比對所有 agent 的關鍵區塊，列出差異（預設，不寫入） |
| `sync` | 把 lobster 的共用區塊同步到所有 agent（會先 diff 確認） |
| `check` | 靜默檢查，有差異回傳非零 exit code（給 cron 用） |

### 同步的區塊

以下區塊以 lobster 為準，同步到所有非 worker agent：

1. **啟動流程**：`## Session 啟動` 區塊（glob 寫法、強制語氣）
2. **安全線**：`## 安全線` 區塊（紅線/黃線/綠線）
3. **絕對禁令**：`## 絕對禁令` 區塊
4. **回覆規範**：字數限制、禁 Markdown 等共用規則

### 不同步的區塊

每個 agent 保留自己的：
- 角色邊界（職責描述）
- 產出規範（各自不同）
- 按需讀取（各自的參考文件）
- SOUL.md、IDENTITY.md（各自人格）

## 注意事項

- 只同步有 AGENTS.md 的 workspace（跳過 worker）
- 同步前自動備份原檔到 `.agents-md-backup`
- dry-run（diff）是預設行為，sync 才真正寫入
- 🔴 紅線：不同步 openclaw.json，只處理 workspace 文件
