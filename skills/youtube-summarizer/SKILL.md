---
name: youtube-summarizer
description: Summarize a single YouTube video by URL. Use yt-summary.sh to fetch transcript and generate summary via Gemini CLI. Triggers on YouTube URL sharing or requests to summarize/transcribe a video.
---

# YouTube 單影片摘要

腳本：`bash ~/.openclaw/workspace/scripts/yt-summary.sh "<YouTube URL>"`

> ⚠️ 原版 skill（clawhub: youtube-summarizer）依賴 `/root/clawd/mcp-server-youtube-transcript` Linux 路徑，已不適用本機。
> 本版本改走本機 `yt-summary.sh`（字幕優先 → Gemini CLI fallback → LINE Push）。

## 觸發條件

- 使用者分享 YouTube URL（youtube.com/watch、youtu.be、youtube.com/shorts）
- 使用者要求摘要或轉錄 YouTube 影片

## 使用方式

```bash
bash ~/.openclaw/workspace/scripts/yt-summary.sh "<YouTube URL>"
```

- 腳本自動完成：字幕下載 → Gemini 摘要 → LINE Push 回傳
- 結果由 `pending-result.sh` 推送給使用者
- 無需額外參數

## 運作流程

1. `yt-dlp` 抓影片標題與時長
2. 嘗試下載字幕（zh-Hant / zh-Hans / zh / en / ja）
   - 有字幕 → 清理後送 Gemini CLI 摘要
   - 無字幕 → 直接用 `gemini -p` 分析影片 URL（fileData 模式）
3. 摘要格式：繁體中文，3-4 段，400-600 字
4. 透過 `pending-result.sh` Push 到 LINE

## 批次摘要

多部影片或播放清單 → 改用 `youtube-batch` skill：
```bash
bash ~/.openclaw/workspace/scripts/yt-channel-summarize.sh <播放清單URL> <資料夾名>
```

## 錯誤處理

- 影片無字幕且 Gemini 無法存取 → 回報「無法取得逐字稿」
- `yt-dlp` 失敗 → 確認 yt-dlp 版本（`yt-dlp -U`）
- Gemini 429 → 等候後重試，或改用 API key

## 依賴

- `yt-dlp`（本機已安裝）
- `gemini` CLI（Google OAuth，走訂閱制）
- `pending-result.sh`（LINE Push）

## Gotchas
- 執行前先確認前置檔案/旗標存在；缺少時直接回報並停止，不要硬做。
- 需要改檔時先備份（.bak），避免錯誤覆寫不可回復。
- 回覆外部訊息前，先完成核心產出檔落地，避免「只說完成但無檔案」。
- 若模型或 API 出現 rate limit / 400 錯誤，改用備援模型並重跑，不要把空跑當成功。
