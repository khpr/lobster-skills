---
name: memory-handoff-sync
description: >
  把 BOOT/交接摘要自動整理進 MEMORY.md，讓重啟後的主 agent 能快速接續上下文。
  目標是「不靠腦記、靠檔案交接」，並且做到可重複執行（idempotent）。
trigger_phrases:
  - 記憶交接
  - 同步記憶
  - handoff sync
requires:
  bins: [python3]
  env: [OPENCLAW_WORKSPACE]
owner: xiaxia
complexity: M
version: "0.2"
created: "2026-03-22"
updated: "2026-03-23"
---

# memory-handoff-sync

## 這個技能能幹嘛（白話）

OpenClaw 有 BOOT/交接紙條（例如 BOOT.md），裡面通常有「上一輪的摘要」。

依照 Walkpod 的記憶分層規則：
- `memory/YYYY-MM-DD.md` 是「日常流水」
- `MEMORY.md` 是「長期精選（教訓/決策/原則）」

所以這個技能預設只做：
- **把 BOOT 的交接摘要寫進當日 daily 檔（不污染 MEMORY.md）**
- **同一份摘要不會重複寫入（去重）**

另外保留彈性：
- 你明確要求時，才把某次交接摘要「晉升」進 `MEMORY.md`

## 做法
1) 從 `$OPENCLAW_WORKSPACE/BOOT.md` 擷取摘要區塊（找不到就整份當摘要）
2) Append 到 `$OPENCLAW_WORKSPACE/memory/YYYY-MM-DD.md`
3) 用 marker 去重：同一份摘要不會一直重複追加

## 使用方式
- 寫入 daily（預設）：
  - `OPENCLAW_WORKSPACE=~/.openclaw/workspace bash scripts/main.sh`
- 晉升到 MEMORY（可選、明確操作）：
  - `OPENCLAW_WORKSPACE=~/.openclaw/workspace bash scripts/main.sh --promote`

## 安全等級
green（只會寫入你本機的記憶檔案，不會對外發送）

## 權限建議
- `MEMORY.md` 建議鎖權限（例如 600），避免被其他流程誤讀/誤改。

## 相關檔案
- 腳本：`scripts/main.sh`
