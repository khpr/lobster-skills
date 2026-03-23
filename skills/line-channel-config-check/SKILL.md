---
name: line-channel-config-check
description: >
  檢查 OpenClaw 的 LINE Channel 設定與實際收發狀態，避免被 CLI 的 stopped / restart loop 誤報嚇到。
  會把「顯示問題」和「真的收不到訊息」分開判斷，並輸出一份白話的健康報告。
trigger_phrases:
  - LINE 狀態
  - LINE 健檢
  - 檢查 LINE
  - line channel check
requires:
  bins: [openclaw, python3]
  env: []
owner: xiaxia
complexity: M
version: "0.2"
created: "2026-03-22"
updated: "2026-03-23"
---

# line-channel-config-check

## 這個技能能幹嘛（白話）

你只要說「LINE 狀態 / LINE 健檢」，我會做三件事：

1) **看 OpenClaw 目前怎麼認 LINE**（有沒有設定、token probe 是否過、最近有沒有收到 webhook）
2) **把誤報過濾掉**：例如你明明收得到訊息，但 `channels status` 卻顯示 stopped 這種 CLI/監控誤判
3) **給你一句可行動的結論**：
   - 「功能正常，只是顯示誤判」
   - 或「真的有問題，問題點在 token / webhook / gateway」

## 產出
- 一份健康報告（OK / WARN / FAIL）
- 若偵測到典型誤報（stopped 但 inbound 正常）會明確標注：**可忽略，勿驚慌**

## 檢查內容（目前版本）
- `openclaw channels status --json --probe`（probe 會實際驗證 credential；超時預設 10s）
- `openclaw gateway status`（gateway 有沒有在跑）
-（可選）顯示最近 channel logs 摘要（不會洗版）

## 使用方式
- 直接執行：
  - `bash scripts/main.sh`
- JSON 輸出（給自動化/監控用）：
  - `bash scripts/main.sh --json`

## 安全等級
green（純讀取，不改設定）

## 限制
- 只能判斷「OpenClaw 端的設定/狀態」。如果 LINE 官方端封鎖/網路斷線，只能看到現象，無法直接修。

## 相關檔案
- 腳本：`scripts/main.sh`
