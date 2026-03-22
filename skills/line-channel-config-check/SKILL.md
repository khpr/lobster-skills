---
name: line-channel-config-check
description: >
  檢查 LINE Channel 設定狀態並修復常見問題的 SOP skill。
  觸發情境：openclaw status 顯示 LINE WARN、LINE token 失效、LINE 無法收發訊息、
  LINE channel access token not configured、LINE webhook 無回應、
  LINE 頻道設定、LINE token 檢查、LINE 設定修復、line channel、line token warn。
  涵蓋：token 設定驗證、webhook URL 確認、channel secret 檢查、設定修復步驟。
requires:
  bins: [jq, curl]
  env: []
  config: [line.channelAccessToken, line.channelSecret]
owner: xiaxia
complexity: M
version: "1.0"
created: "2026-03-23"
---

## 概述

當 `openclaw status` 顯示 LINE 頻道 WARN 或 ERROR，或 LINE 無法正常收發訊息時，
此 skill 提供逐步檢查與修復 SOP，從設定診斷到修復驗證。

## 前置條件

- `openclaw` CLI 可用
- 有 LINE Developers Console 存取權限（人工步驟）
- `jq` 已安裝

## 流程

### Step 1：診斷當前狀態

```bash
# 查看整體狀態
openclaw status 2>&1 | grep -A2 "LINE"

# 查看 openclaw.json 的 LINE 設定（只看欄位名稱，不印值）
cat ~/.openclaw/openclaw.json | jq '.channels.line | keys'
```

確認哪個欄位是空的或 null：
- `channelAccessToken` → Token 未設定
- `channelSecret` → Secret 未設定
- `webhookUrl` → Webhook 未設定

### Step 2：確認 Token 格式（不印明文）

```bash
# 確認 token 長度（正常 token 約 170+ 字元）
cat ~/.openclaw/openclaw.json | jq '.channels.line.channelAccessToken | length'

# 如果長度為 0 或 null → 需要重新產生 token
```

### Step 3：驗證 Token 有效性（API 呼叫）

```bash
TOKEN=$(cat ~/.openclaw/openclaw.json | jq -r '.channels.line.channelAccessToken')
curl -s -o /dev/null -w "%{http_code}" \
  -H "Authorization: Bearer $TOKEN" \
  https://api.line.me/v2/bot/info
# 200 = 有效；401/403 = token 無效或過期
```

### Step 4：檢查 Webhook 設定

```bash
TOKEN=$(cat ~/.openclaw/openclaw.json | jq -r '.channels.line.channelAccessToken')
curl -s \
  -H "Authorization: Bearer $TOKEN" \
  https://api.line.me/v2/bot/channel/webhook/endpoint | jq .
# 確認 webhookUrl 與 openclaw.json 一致
# 確認 active: true
```

### Step 5：修復（依錯誤類型）

**Token 未設定 / 過期**（人工步驟）：
1. 登入 LINE Developers Console → https://developers.line.biz/
2. 選擇對應 Channel → Messaging API
3. 產生新的 Channel access token（長期）
4. 複製後告知龍蝦：「LINE token 是 <token>」
5. 由龍蝦更新 openclaw.json（🔴 需人類確認）：
   ```
   ⚠️ 風險：修改 openclaw.json 屬紅線操作，需人類明確授權。
   確認後執行：openclaw config set channels.line.channelAccessToken "<token>"
   ```

**Webhook 設定錯誤**（人工步驟）：
1. 在 LINE Developers Console → Webhook URL 填入：
   `https://bot.life-os.work/webhook/line`（或目前的 Cloudflare Tunnel URL）
2. 點「Verify」確認連通
3. 確認「Use webhook」已啟用

### Step 6：修復後驗證

```bash
# 重新檢查 openclaw status
openclaw status 2>&1 | grep -A2 "LINE"
# 應顯示 OK，不再顯示 WARN
```

發送測試訊息給 LINE bot，確認能正常收到回覆。

## 輸出規範

- 診斷結果：純文字說明哪個環節有問題
- 修復步驟：列出需要人工操作的步驟（TOKEN 操作屬紅線）
- 最終狀態：openclaw status LINE 欄位應顯示 OK

## 錯誤處理

| 錯誤 | 處理方式 |
|------|---------|
| openclaw.json 無法讀取 | 停止，提示確認檔案權限 |
| Token API 回 401 | 確認 token 已過期，引導人工重新產生 |
| Webhook verify 失敗 | 確認 Cloudflare Tunnel 是否正常運作 |
| openclaw status 仍顯示 WARN | 嘗試 `openclaw gateway restart`（黃線，說一句再做）|

## 安全等級

- 讀取診斷：🟢 green（直接執行）
- openclaw.json 修改：🔴 red（需人類明確授權）
- gateway restart：🟡 yellow（說一句再做）
- TOKEN 相關 curl 呼叫：🟡 yellow（不印明文，只印 http_code）

## 參考文件

- LINE Developers Console: https://developers.line.biz/console/
- LINE Bot API - Webhook: https://developers.line.biz/en/reference/messaging-api/#webhooks
- openclaw.json 設定欄位說明：`openclaw config --help`
