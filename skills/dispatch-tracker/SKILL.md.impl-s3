---
name: dispatch-tracker
description: >
  追蹤派工狀態。每個 turn 啟動時自動呼叫 check，確認是否有未完成派工。
  支援 add（登記新派工）、done（標記完成）、list（列出所有）、check（啟動健檢）。
  觸發情境：派工前後、session 啟動、派工追蹤、查有沒有未完成工作、check dispatch、
  登記派工、標記派工完成、查派工簿。
  Owner: shared；腳本已存在於 ~/.openclaw/workspace/scripts/dispatch-tracker.sh。
requires:
  bins: [bash, grep, sed]
  env: []
  config: []
owner: shared
complexity: S
version: "1.0"
created: "2026-03-22"
---

## 概述

封裝 `dispatch-tracker.sh`，讓 agent 在每個 turn 開頭自動檢查未完成派工，
以及在派工前後維護追蹤簿，避免任務遺失。

## 前置條件

- `~/.openclaw/workspace/scripts/dispatch-tracker.sh` 必須存在（已存在）
- 追蹤簿路徑：`~/.openclaw/workspace-lobster/memory/pending-dispatches.md`

## 流程

### 每個 Turn 啟動

```bash
bash ~/.openclaw/workspace/scripts/dispatch-tracker.sh check
```

有輸出（未完成派工）→ 主動報告給使用者，並用 `subagents list` 查進度。

### 派工前

```bash
bash ~/.openclaw/workspace/scripts/dispatch-tracker.sh add "<agent>" "<任務摘要>" [V卡ID]
```

### 收到結果後

```bash
bash ~/.openclaw/workspace/scripts/dispatch-tracker.sh done "<agent>" "<關鍵字>"
```

### 查看派工簿

```bash
bash ~/.openclaw/workspace/scripts/dispatch-tracker.sh list
```

## 輸出規範

- `check`：有未完成時輸出警告 + 筆數；無則靜默（exit 0）
- `add` / `done`：輸出 ✅ 確認訊息
- `list`：表格格式顯示所有未完成派工

## 錯誤處理

- 追蹤簿不存在 → 腳本自動建立
- `done` 找不到關鍵字 → 輸出 ⚠️ 警告，不 crash

## 安全等級

🟢 green — 只讀寫本機 markdown 檔，無網路呼叫，無外部 API

## 參考文件

- `references/usage-examples.md` — 常見使用情境範例
