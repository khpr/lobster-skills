# CHANGELOG — telegram-output

## v1.0.0 (2026-03-19)

初始版本。

### 新增
- 完整 Telegram 輸出格式選擇指南
- HTML 格式化（粗體/斜體/連結/code block）說明
- Inline Keyboard 按鈕：必須用 `openclaw message send --buttons` CLI，不是 `[[buttons:]]`
- 語音回覆：`[[audio_as_voice]]` tag 用法
- 圖片/檔案上傳：支援本地路徑（不需公開 URL）與 URL
- 影片/Video Note 說明
- Poll 投票 CLI 用法
- Streaming 預覽說明（預設啟用，不需手動送「處理中」）
- Reply threading：`[[reply_to_current]]` 與 `[[reply_to:<id>]]`
- Reaction ACK 說明
- 4000 字 chunk limit 提醒（LINE 是 5000）
- 格式選擇速查表

### 設計決策
- 不做 editMessage feedback（~5 秒延遲，體驗差）
- `[[buttons:]]` 明確標示為 LINE 專用語法，Telegram 不支援
- Flex Message / Quick Reply 屬 LINE 概念，不適用於 Telegram
- Telegram 原生支援 code block，不需要特殊處理（與 LINE 不同）
