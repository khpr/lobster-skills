# SP500 規模目標與擴張路線（2026-07 更新）

## 上限
5000 個來源（不是盡快達到，是長期天花板）

## 第一階段：語言基線（各語言 100 個）
- 英文：tech / finance / culture / humanities（目前最完整）
- 繁體中文：台灣媒體 + 創作者（iThome、報導者、天下等已入庫）
- 日文：科技 + 娛樂 + 財經（電撃、東洋経済、ITmedia 已入庫）
- 韓文：待補（娛樂產業 / 半導體 / 文化）

## 第二階段：主題縱深擴張
各語言基線達標後，按興趣領域橫向延伸（心理 / 漫畫 / 遊戲…）

## Podcast 納入方式
Podcast 本身就是 RSS 協議——直接加進 sources.md，分類用 `podcast`。
L2 抓 episode 標題 + description，不抓音訊。
需要逐集摘要 → 觸發 openai-whisper-api 或 yt-summarizer 按需處理。

## YouTube 納入方式
每個頻道都有 RSS：
https://www.youtube.com/feeds/videos.xml?channel_id=CHANNEL_ID
L2 抓影片標題 + 連結，分類用 `youtube`。
需要摘要 → 觸發 youtube-summarizer skill 按需處理。

這樣 Podcast / YouTube 和一般文章用同一套 L2 收割 + buffer 架構，
差別只在 L3 播放時有不同的「深加工」路徑。

## 收割頻率
cron：每 12 小時（00:00 / 12:00 Asia/Taipei）
ID：1f65c766-9ab3-4f04-8a04-e8e49c724e44
