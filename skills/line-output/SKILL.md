---
name: line-output
description: Choose LINE reply format. Plain text for chat, Flex Message cards for structured results, TTS for voice, image generation for pictures.
metadata: {"clawdbot":{"emoji":"📤"}}
---

# LINE 輸出能力邊界（line-output）

> 觸發時機：需要選擇最適合的 LINE 回覆方式時（文字 / 圖片 / 語音 / Flex / 影片）

---

## LINE 能做 ✅ 和不能做 ❌

| 能做 | 不能做 |
|------|--------|
| 文字訊息 | PDF 附件 |
| 圖片（URL 公開可存取）| 自定義貼圖 |
| 音訊（URL 公開可存取，m4a/mp3）| 確認已讀 |
| 影片（URL，最大 200MB）| 取得使用者 LINE ID（隱私）|
| Flex Message（結構化卡片）| Markdown 格式（LINE 不渲染）|
| Quick Reply 按鈕 | Code block / stack trace |
| Loading Animation | 超過 5 個 message object |

---

## 輸出方式選擇原則

**簡短回答（< 500 字）→ 純文字**

**結構化資訊（行程 / 清單 / 比較 / 卡片）→ Flex Message**
使用 curl 打 LINE Messaging API push endpoint（`[[buttons:]]` 等 OpenClaw 指令在 LINE 群組不生效）。各媒體類型的 Flex 模板見對應 Skill 的 references/ 資料夾。

**使用者要求「唸給我聽」或語音更自然的場景 → TTS**
工具：`bash ~/.openclaw/workspace/scripts/voice-reply.sh "<文字>"`
⚠️ 必須用 exec(background=true) 執行！
音檔存放：`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/90_System/Deliverables/media/`
公開 URL：`https://vault.life-os.work/90_System/Deliverables/media/{檔名}`
回覆方式：文字回覆底部附 🔊 vault URL（一則搞定，零 Push）

**使用者要求「畫 / 生成圖片」→ Imagen 4 / DALL-E 3**
工具：`bash ~/.openclaw/workspace/scripts/image-gen.sh "<描述>" "<LABEL>"`
⚠️ 必須用 exec(background=true) 執行！
圖片存放：`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/90_System/Inbox/gen-{日期}-{label}.png`
公開 URL：`https://vault.life-os.work/90_System/Inbox/{檔名}`
回覆方式：存 pending-result（type=mediaplayer）→ 下一則使用者訊息用 reply token 送 [[media_player:]]

**STT（語音轉文字）**
工具：OpenAI Whisper API（curl，不需要裝套件或 CLI）
```bash
source ~/.openclaw/.env
curl -s https://api.openai.com/v1/audio/transcriptions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -F model="whisper-1" -F file="@/tmp/stt-input.wav" -F language="zh"
```

**長任務通用原則：**
所有長任務使用 exec(background=true) + shell 腳本，呼叫 REST API。
不依賴 Gemini CLI（只能處理純文字，不能處理音檔/圖檔）。
產出物存 Vault（Inbox 或 Deliverables），拿公開 URL。零 Push，全走 Reply。

**Postback 按鈕通用規則（強制）：**
所有 Flex 卡片中的 postback 按鈕，必須加 `"displayText": "<按鈕 label 文字>"`。
沒有 displayText = 按下後聊天室靜默，用戶不知道有沒有按到 = 輸出格式錯誤。

**絕對不在 LINE 輸出：**
- Markdown code block（\`\`\`）
- JSON 原始格式
- Stack trace / 錯誤堆疊
- 表格（用 Flex 代替）
- 超過 2000 字的回覆（分段或用 Gist）

---

## 回覆方式與推播額度

| 方式 | 成本 | 限制 |
|------|------|------|
| Reply（用 replyToken）| 免費 | replyToken 約 60 秒過期，只能用一次 |
| Push（主動推播）| 計入月額度 | 免費方案 200 則/月 |

**原則：能用 reply 就用 reply**

---

## 3 秒原則 + Loading Animation

任何操作超過 3 秒，先發文字確認：
```
"處理中，請稍候..."
```

或呼叫 LINE Loading Animation API：
```bash
TOKEN=$(python3 -c "import json; d=json.load(open('$HOME/.openclaw/openclaw.json')); print(d['channels']['line']['channelAccessToken'])")
curl -s -X POST https://api.line.me/v2/bot/chat/loading/start \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"chatId":"<GROUP_OR_USER_ID>","loadingSeconds":20}'
```

---

## 常用 GROUP ID

- 主對話群組：`C5fc2e8b0e688d45b03f877655bf2d191`
- 系統通知群組：`C2567447db59c0fa572c3be519b77079a`

---

## 完整參考文件（references/）

- `references/SKILL-tts-reply.md` — TTS 語音輸出完整流程（含 catbox.moe 說明）
- `references/SKILL-image-gen.md` — Imagen 4 生圖完整流程
- `references/SKILL-flex-templates.md` — 16 種 Flex 訊息模板
- `references/SKILL-task-manager.md` — 非同步長任務推播策略

原始位置：`~/.openclaw/workspace/scripts/`

---

## 任務狀態尾巴（純文字 reply 專用）

每次回覆純文字訊息前，讀取 task-queue.json：
路徑：~/.openclaw/workspace/scripts/task-queue.json

組裝規則：
- 有任何任務（running / 未 acked 的 done / failed / cancelled）→ 在回覆結尾加狀態列
- 完全沒有任務 → 不加，保持乾淨

狀態列格式：
─────────────
🔄 [任務名稱] ← running，每次都顯示
✅ [任務名稱] ← done，acked: false 時顯示一次
❌ [任務名稱] ← failed，acked: false 時顯示一次
⛔ [任務名稱] ← cancelled，acked: false 時顯示一次

附加後，將本次顯示的 done / failed / cancelled 項目標記 acked: true。

限制：
- 只適用於純文字 reply，Flex 回覆不加
- 狀態列不超過 5 筆（優先顯示 running，其次依 createdAt 排序）

## Gotchas
- 執行前先確認前置檔案/旗標存在；缺少時直接回報並停止，不要硬做。
- 需要改檔時先備份（.bak），避免錯誤覆寫不可回復。
- 回覆外部訊息前，先完成核心產出檔落地，避免「只說完成但無檔案」。
- 若模型或 API 出現 rate limit / 400 錯誤，改用備援模型並重跑，不要把空跑當成功。
