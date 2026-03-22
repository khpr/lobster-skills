# frame-daily-art — Test Prompts

## Test 1：正常流程（手動觸發）

Prompt: "幫我換一張名畫"
預期: 觸發 frame-daily-art skill，抓 Artvee 名畫 → 合成海報 → 上傳 Frame TV → 推 LINE Flex（含畫名/作者/年份）
驗證: 
- Vault/90_System/Deliverables/frame-art/YYYY-MM-DD.jpg 存在
- LINE 收到 Flex，hero image 可顯示
- used-artworks.json 有新記錄

## Test 2：觸發詞變體

Prompt: "frame art"
預期: 同 Test 1
驗證: skill 被正確路由

Prompt: "今日畫作"
預期: 同 Test 1
驗證: skill 被正確路由

## Test 3：Frame TV 離線情境

前置: 斷開 Frame TV 電源或 WiFi
Prompt: "換海報"
預期: 流程完成但跳過 TV 上傳，LINE Flex 仍正常推播，stderr 有 WARN 訊息
驗證:
- 圖像仍存到 Vault
- LINE 有推播
- 無 exit 1（程式正常結束）

## Test 4：重複作品排除

前置: 在 used-artworks.json 塞入大量畫作 ID
Prompt: "換一張名畫"
預期: 跳過已用作品，找到未用的新作品
驗證: 推播的畫名不在 used-artworks.json 前一筆記錄中

## Test 5：cron 自動觸發

前置: cron 設定為 08:00
驗證: 08:00 後 Vault 有新檔案，LINE 有推播，無需人工干預
