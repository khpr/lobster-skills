---
name: memory-handoff-sync
description: >
  一鍵完成重啟交接流程：備份當前 session 記憶 → 寫 BOOT.md 交接卡 → 歸檔到
  memory/YYYY-MM-DD.md → 可選觸發 session-reset.sh。
  觸發關鍵詞：重啟交接、備份記憶、交接卡、handoff sync、session 即將重啟、
  重啟前備份、memory handoff、session handoff、記憶交接。
  適用情境：token 快滿、主動重啟 session 前、緊急重啟前。
requires:
  bins: [bash]
  env: []
  config: []
owner: xiaxia
complexity: M
version: "1.1"
created: "2026-03-23"
---

## 概述

重啟交接是高頻且容易漏步的操作。此 skill 將以下步驟一鍵化：

1. Agent 整理本輪 session 關鍵摘要
2. 執行 `handoff.sh` 寫 BOOT.md 並歸檔至 memory/
3. 確認寫入
4. 可選：觸發 session-reset.sh（需使用者確認）

---

## 前置條件

- `~/.openclaw/workspace-lobster/BOOT.md` 可寫入
- `~/.openclaw/workspace-lobster/memory/` 目錄存在（腳本自動建立）
- `~/.openclaw/workspace/scripts/session-reset.sh` 存在（可選）

---

## 流程

### Step 1：收集交接資料

Agent 先整理本輪 session 的關鍵摘要，包含：
- 正在進行的任務（未完成）
- 關鍵決策與變更
- 待追蹤事項

### Step 2：執行備份腳本

```bash
bash ~/lobster-skills/skills/memory-handoff-sync/scripts/handoff.sh --summary "摘要文字"
```

腳本動作：
- 覆寫 BOOT.md（含 generated 時間戳、摘要、歸檔路徑）
- 將摘要 append 到 memory/YYYY-MM-DD.md
- 寫 done flag：`/tmp/memory-handoff-done.json`

### Step 3：確認寫入

```bash
head -5 ~/.openclaw/workspace-lobster/BOOT.md
ls -la ~/.openclaw/workspace-lobster/memory/$(date +%Y-%m-%d).md
```

### Step 4：觸發 session-reset（使用者確認後）

若使用者確認要重啟：
```bash
bash ~/lobster-skills/skills/memory-handoff-sync/scripts/handoff.sh --summary "摘要文字" --reset
```

或直接呼叫：
```bash
bash ~/.openclaw/workspace/scripts/session-reset.sh
```

---

## 輸出規範

- 成功：純文字，列出已完成步驟 + BOOT.md 前三行
- 失敗：標出哪個步驟失敗 + 原因

---

## 錯誤處理

| 錯誤 | 處理方式 |
|------|---------|
| BOOT.md 不可寫 | 輸出錯誤，exit 1 |
| memory/ 目錄不存在 | 自動建立 |
| session-reset.sh 不存在 | 跳過 Step 4，輸出 WARN，繼續完成備份 |
| 無摘要提供 | 自動填入時間戳佔位摘要，不中斷 |

---

## 安全等級

- Step 1-3：green（寫檔，無副作用）
- Step 4：yellow（觸發重啟，說一句再做，60 秒無回應視為拒絕）

---

## 參考文件

- `references/boot-md-format.md`：BOOT.md 格式說明
