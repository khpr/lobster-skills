# frame-daily-art — 參考說明

## Artvee 抓圖策略

- URL pattern: `https://artvee.com/paintings/page/<N>/`
- 頁數範圍：約 1–100（隨機選取）
- 高解析圖直連：product gallery 的 `data-large_image` 屬性

## 篩選條件說明

| 條件 | 值 | 原因 |
|------|-----|------|
| 長邊 ≥ 2000px | 2K+ | Frame TV 解析度需求 |
| height/width > 1.3 | portrait | Frame TV 直式顯示 |
| 不重複 | used-artworks.json | 避免重複顯示同一幅畫 |

## InfoBar 規格

- 背景：#000000（純黑）
- 字色：白色（畫名）/ #cccccc（作者/年份）
- 字體大小：28px 粗體（畫名）/ 22px 一般（作者年份）
- 高度：80px
- 左邊距：30px

## 已知限制

- Artvee HTML 結構偶有變動 → 需定期驗證 CSS selector
- 部分畫作無年份資料 → 顯示作者名即可
- Frame TV 上傳依賴 samsungtvws，需要 TV 在同一局域網

## 歷史紀錄

- v1.0（2026-03-22）：Nano Banana 2 AI 生圖（S1 草稿，已廢棄）
- v2.0（2026-03-23）：改用 Artvee 真實名畫（SPEC v1.1 確認版）
