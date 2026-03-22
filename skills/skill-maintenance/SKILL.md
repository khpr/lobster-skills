---
name: skill-maintenance
description: >
  每週定期維護 Skill Store：同步 index、健檢所有 skill、掃描 FEEDBACK.md 未處理反饋、統計使用頻率。
  觸發詞：skill 維護、健檢 skill、skill store 同步、每週維護、skill 使用統計、清理 skill、skill 反饋。
  每週一 03:00 由 cron 自動觸發，或人類說「跑一下 skill 維護」。
  四層流程：sync → health-check → feedback → usage-stats。
requires:
  bins: [bash, python3, jq]
  env: []
  config: []
owner: shared
complexity: M
version: "1.0"
created: "2026-03-22"
---

## 概述

`skill-maintenance` 封裝原有的 `skill-maintenance.sh` 腳本，賦予其可被 agent 正確觸發的 skill 包裝。
主要功能：
1. **Sync**：同步 skill store index（`skill-store-sync.sh`）
2. **Health**：全量健檢已安裝 skill（`skill-health-check.sh`）
3. **Feedback**：掃描所有 `FEEDBACK.md`，統計未處理反饋數
4. **Stats**：統計過去 7 天 skill 使用頻率，存入 `skill-store/usage-stats.json`

## 前置條件

- `~/.openclaw/workspace/scripts/skill-maintenance.sh` 存在且可執行
- `~/.openclaw/workspace/scripts/skill-store-sync.sh` 存在
- `~/.openclaw/workspace/skill-store/` 目錄存在
- Python 3 可用（統計層需要）

## 流程

### Step 1：執行維護腳本

```bash
bash ~/lobster-skills/skills/skill-maintenance/scripts/main.sh 2>&1
```

腳本內部會：
1. 確認 `skill-maintenance.sh` 存在
2. 執行 `skill-maintenance.sh`，捕獲全部輸出到 `/tmp/skill-maintenance-<ts>.log`
3. 解析 `SKILL_MAINTENANCE_REPORT` 區塊，提取 sync/health/feedback/stats
4. 輸出人類可讀摘要；如有 fail → exit 2

### Step 2：解析結果

main.sh 已自動解析，直接讀取 stdout 最後幾行：
- `同步：<sync_status>`
- `健檢：<N> fail, <N> warn`
- `反饋：<N> unhandled`
- `統計：<stats_summary>`

### Step 3：回報

回覆使用者摘要（繁體中文，不超過 200 字）：
- 健檢結果（有問題列出 skill 名稱）
- 未處理反饋數
- 使用統計亮點（使用率最高/最低的 skill）
- 如有 fail → 提示需要人工介入

### Step 4：記錄

如果健檢有 fail，寫入 memory：
```
日期 skill-maintenance 發現 X 個 fail：<skill 名稱列表>，待修復
```

## 輸出規範

- 正常完成 → 純文字摘要，Reply
- 有 fail → 文字摘要 + 提示人工介入，Reply
- 腳本不存在 → 報錯 + 提示路徑，Reply

## 錯誤處理

| 錯誤 | 處理 |
|------|------|
| 腳本不存在 | 報錯：`skill-maintenance.sh 不在預期路徑` |
| Python3 不可用 | 跳過統計層，繼續 L1-L3 |
| sync 失敗 | 繼續後續層，最後報告 sync 失敗 |
| health-check 腳本不存在 | Skip，輸出 SKIP 說明 |

## 安全等級

green — 只讀腳本 + 本機統計寫檔，不對外發送，不修改 skill 檔案

## 排程

cron：每週一 03:00 自動執行（由 OpenClaw cron 管理）

## 參考文件

- `scripts/skill-maintenance.sh`：主腳本原始碼
- `~/.openclaw/workspace/skill-store/usage-stats.json`：統計輸出
