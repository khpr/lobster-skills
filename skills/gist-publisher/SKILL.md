---
name: gist-publisher
description: Publish or update a GitHub Gist from a local file (typically docs/specs/summaries). Use when the user says publish gist / 上傳 gist / 同步到 gist / 分享給別人, or when we need a shareable URL for a workspace document. Uses gh CLI (account khpr) and maintains gist-index/map.json to update existing gists by file.
---

# Gist Publisher（把檔案發布/更新到 GitHub Gist）

目標：把 workspace 裡的文件（例如 docs/、specs/、摘要）快速變成可分享 URL；同一份檔案預設「更新既有 gist」避免 gist 爆量。

## 安全規則（必遵守）
- **不要發布 secrets**（token、client_secret、openclaw.json 內容、任何私密資訊）。
- 預設用 **secret gist**；除非使用者明確要求 public。

## 快速流程
1) 確認檔案路徑（建議用 workspace 相對路徑）
2) 執行腳本發布
3) 回傳 URL

## 指令
- 發布/更新（預設 secret，若已存在會更新）：
  - `scripts/publish-gist.sh <file>`
- 強制開新 gist：
  - `scripts/publish-gist.sh <file> --new`
- 發 public gist（需使用者明確要求）：
  - `scripts/publish-gist.sh <file> --public`

## 需要細節時
- 讀：`references/gist-publisher.md`
