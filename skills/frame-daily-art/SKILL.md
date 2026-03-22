---
name: frame-daily-art
description: >
  每日從 Artvee 抓取世界名畫，合成黑框 InfoBar 海報，上傳 Frame TV 並推 LINE Flex 預覽。
  觸發詞：frame art、今日畫作、換海報、frame tv、幫我換畫、daily art、換一張名畫。
  cron 模式：每日 08:00 Asia/Taipei 自動觸發。
  不觸發：查電視狀態（samsung-smartthings）、播音樂（sonoscli）、AI 生圖（nano-banana-2）。
requires:
  bins: [curl, jq, python3]
  python: [Pillow, requests, beautifulsoup4]
  env: []
  config: []
owner: dema
complexity: M
version: "2.0"
created: "2026-03-23"
---

# frame-daily-art

每日 Artvee 名畫 → PIL 合成黑框海報 → Frame TV 上傳 → LINE Flex 推播。

## 設計動機

舊版 CAPABILITY-MATRIX 標 error/timeout，因為：(1) Met Museum API 不穩定，(2) Nano Banana 生圖佔 token。
新版改用 Artvee（免費高解析名畫），本地 PIL 合成，無外部 API 依賴。

## 前置條件

- Python3 + Pillow（合成用）
- requests + beautifulsoup4（Artvee 抓圖用）
- `samsung-smartthings` skill 的 upload_to_frame.py
- Frame TV 與 Mac 同一局域網

## Step 1：從 Artvee 取今日畫作

```bash
cd ~/lobster-skills/skills/frame-daily-art
python3 scripts/fetch-artvee.py \
  --min-px 2000 \
  --portrait-ratio 1.3 \
  --exclude-log data/used-artworks.json \
  --output /tmp/frame-art-raw.jpg \
  --meta /tmp/frame-art-meta.json
```

fetch-artvee.py 流程：
1. 隨機抓 Artvee 頁面（/paintings/page/<random>）
2. 解析畫作清單，篩選 portrait + 2K+
3. 排除 used-artworks.json 中已用作品
4. 下載高解析原圖到 /tmp/frame-art-raw.jpg
5. 寫 meta json：title、artist、year、source_url

## Step 2：合成黑框 InfoBar 海報

```bash
TODAY=$(date +%Y-%m-%d)
OUTPUT_PATH="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/90_System/Deliverables/frame-art/${TODAY}.jpg"
mkdir -p "$(dirname "$OUTPUT_PATH")"

python3 scripts/compose-poster.py \
  --input /tmp/frame-art-raw.jpg \
  --meta /tmp/frame-art-meta.json \
  --output "$OUTPUT_PATH" \
  --scale 0.95 \
  --bg-color "#000000" \
  --infobar-height 80
```

compose-poster.py 流程：
1. 開啟原圖，縮放至 95%，置中於黑色背景
2. 底部加 InfoBar：畫名（粗體）/ 作者 / 年份
3. 存為 JPG，品質 92

## Step 3：上傳到 Frame TV

```bash
UPLOAD_SCRIPT=~/.openclaw/skills/samsung-smartthings/scripts/upload_to_frame.py
python3 "$UPLOAD_SCRIPT" "$OUTPUT_PATH" 2>&1
UPLOAD_EXIT=$?
if [ $UPLOAD_EXIT -ne 0 ]; then
  echo "WARN: Frame TV 離線，圖已存 Deliverables" >&2
fi
```

## Step 4：記錄已用作品

```bash
TITLE=$(jq -r .title /tmp/frame-art-meta.json)
ARTIST=$(jq -r .artist /tmp/frame-art-meta.json)
TODAY=$(date +%Y-%m-%d)
mkdir -p ~/lobster-skills/skills/frame-daily-art/data
echo "{\"date\":\"$TODAY\",\"title\":\"$TITLE\",\"artist\":\"$ARTIST\"}" \
  >> ~/lobster-skills/skills/frame-daily-art/data/used-artworks.json
```

## Step 5：推 LINE Flex 預覽

```bash
PUBLIC_URL="https://vault.life-os.work/90_System/Deliverables/frame-art/${TODAY}.jpg"
TITLE=$(jq -r .title /tmp/frame-art-meta.json)
ARTIST=$(jq -r .artist /tmp/frame-art-meta.json)
YEAR=$(jq -r .year /tmp/frame-art-meta.json)
LINE_USER="${LINE_PUSH_USER:-Uab09077d61b168708d6703f0baf8ca03}"

python3 ~/.openclaw/workspace/scripts/send-frame-flex.py \
  "$PUBLIC_URL" "$TITLE" "$ARTIST — $YEAR" "$LINE_USER"
```

注意：send-frame-flex.py 需要 4 個參數（image_url, title, artist_year, chat_id）。
LINE_PUSH_USER 環境變數優先，預設值為主帳號 User ID。

## 錯誤處理

| 情境 | 處理 |
|------|------|
| Artvee 無符合條件畫作 | 擴大篩選（放寬 ratio 到 1.1），仍失敗 exit 1 |
| 下載失敗（網路） | 重試 3 次，仍失敗 exit 1 |
| PIL 合成失敗 | exit 1，推 LINE 錯誤 |
| Frame TV 離線 | 警告，不 exit 1（圖已存） |
| 所有作品已用完 | 清空 used-artworks.json，重新循環 |

## 輸出規範

- 圖像：`Vault/90_System/Deliverables/frame-art/YYYY-MM-DD.jpg`
- 公開 URL：`https://vault.life-os.work/90_System/Deliverables/frame-art/YYYY-MM-DD.jpg`
- LINE：Flex Message hero image + 畫名/作者/年份
- 已用記錄：`~/lobster-skills/skills/frame-daily-art/data/used-artworks.json`

## 安全等級

- 抓圖、合成、存檔：🟢 green
- 推 LINE：🟢 green
- Frame TV 上傳：🟡 yellow

## 參考文件

- SPEC：`~/.openclaw/skills/frame-daily-art/SPEC.md`
- 舊版：`~/.openclaw/skills/samsung-smartthings/scripts/daily-art-random.py`
- upload_to_frame.py：`~/.openclaw/skills/samsung-smartthings/scripts/`
