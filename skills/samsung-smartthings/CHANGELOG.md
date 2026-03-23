# Samsung SmartThings Skill — CHANGELOG

## v1.1 — 2026-03-20
- **改了什麼**：daily-art-random.py 加入最低解析度門檻（Artvee ≥ 1000×1400、Met ≥ 800×1100）
- **為什麼改**：Artvee 縮圖常只有 500px 寬，放大到 4K 畫布嚴重模糊
- **改之前**：只檢查直式比例，不檢查解析度，500×822 也照收
- **驗證方式**：實測跑 daily-art-random.py，低解析度圖正確被 skip，最終上傳 Met 高解析圖
- **搭配變更**：SKILL.md 加入解析度門檻說明

## v1.0 — 初始版本
- Frame TV Art Mode 上傳、合成、每日隨機換畫

## 2026-03-23

- Frame TV 推畫前若 8001 不通，SmartThings 有開機權限可先喚醒，不需要關機處理
- daily-art-random.py 的 Met Museum 策略 2 fallback 改為完全離線 Wikimedia 精選池（原本仍依賴 Met API，API 掛掉時會 crash）
- sonos-now-playing-server.py run_sonos_json timeout 2→5 秒（Qobuz 狀態查詢偶爾超時導致封面/歌手空白）
