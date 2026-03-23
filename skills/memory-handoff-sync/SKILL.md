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
你要的是：
- **把摘要放進長期記憶（MEMORY.md）**
- **不要重複貼同一份摘要**
- 重啟後我才不會失憶、也不會讓 MEMORY.md 變成垃圾堆

這個技能就是做「交接摘要 → 長期記憶」的同步。

## 做法
- 從 `$OPENCLAW_WORKSPACE/BOOT.md` 擷取「摘要區塊」（找得到就取，找不到就整份當摘要）
- 以 `## 交接摘要 @ YYYY-MM-DD` 的格式 append 到 `$OPENCLAW_WORKSPACE/MEMORY.md`
- 會在 MEMORY.md 寫入一個去重 marker（同一份摘要不會重複追加）

## 使用方式
- `OPENCLAW_WORKSPACE=~/.openclaw/workspace bash scripts/main.sh`

## 安全等級
green（只會寫入你本機的記憶檔案，不會對外發送）

## 相關檔案
- 腳本：`scripts/main.sh`
