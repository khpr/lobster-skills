---
name: youtube-batch
description: 批次摘要 YouTube 播放清單/頻道影片，產出 Obsidian 筆記 + MOC 索引。字幕優先、Flash 2.5 API、自動 retry。
metadata: {"clawdbot":{"emoji":"🎬"}}
---

# YouTube 批次摘要

腳本：`bash ~/.openclaw/workspace/scripts/yt-channel-summarize.sh`

## 用法

```bash
bash ~/.openclaw/workspace/scripts/yt-channel-summarize.sh <播放清單URL> <資料夾名> [--limit N] [--parallel N]
```

### 參數

| 參數 | 說明 | 預設 |
|------|------|------|
| playlist_url | YouTube 播放清單或頻道 URL | 必填 |
| folder_name | Obsidian 00_Inbox 下的子資料夾名 | 必填 |
| --limit N | 只處理前 N 部 | 全部 |
| --parallel N | 並行數 | 2 |
| --batch N | 每批幾部後冷卻 90 秒 | 15 |

### 範例

```bash
# 摘要整個頻道上傳清單
bash yt-channel-summarize.sh "https://www.youtube.com/@SomeChannel/videos" "SomeChannel" --parallel 2

# 只跑前 10 部測試
bash yt-channel-summarize.sh "https://youtube.com/playlist?list=PLxxx" "TestRun" --limit 10
```

## 運作方式

1. yt-dlp 抓播放清單
2. 每部影片先嘗試抓字幕（zh-TW/zh/en）
   - 有字幕 → 送文本給 Flash（省 token、更準）
   - 沒字幕 → fileData 直傳 URL 給 Flash 分析
3. 模型固定 `gemini-2.5-flash`，溫度 0.3
4. 失敗自動 retry 3 次（指數 backoff 10s→20s→40s）
5. 第一輪跑完後，失敗的冷卻 30 秒自動二輪重試
6. 已存在的筆記自動跳過（斷點續跑）

## 產出

- `00_Inbox/<folder_name>/` 下每部影片一個 .md
- `_MOC-<folder_name>.md` 索引檔（含成功/失敗標記）
- frontmatter 含 mode（subtitle-mode / url-mode）方便追蹤

## 前置需求

- `GEMINI_API_KEY` 環境變數
- yt-dlp、jq、curl
