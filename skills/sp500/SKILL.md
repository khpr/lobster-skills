---
name: sp500
description: |
  管理研究用信任來源池。收錄、審核、健檢、統計。
  
  觸發：來源、source、sp500、信任來源、審核來源、來源健檢。
  不觸發：單純查資料（用搜尋）、要查某網站可信度（用事實查核工具）。
metadata: {"clawdbot":{"emoji":"📊"}}
---

# S&P 500 Skill

S&P 500 可信來源資料庫，管理研究用的信任來源池。

## 功能

- **intake**: 收錄新來源
- **review**: 批量審核候選來源
- **health**: 定期健檢現有來源
- **rank**: 根據五維評分排序來源
- **stats**: 統計報告 (v2)

## 使用方式

### sp500-rank.sh

根據評分對來源進行排序。

```bash
bash ~/.openclaw/skills/sp500/scripts/sp500-rank.sh [category] [--limit N]
```

### sp500-stats.sh

統計報告 (v2 格式)。

```bash
bash ~/.openclaw/skills/sp500/scripts/sp500-stats-v2.sh
```

### sp500-intake.sh

收錄新來源到候選池。

```bash
bash ~/.openclaw/skills/sp500/scripts/sp500-intake.sh <URL>
```

流程：
1. 提取 domain（去 www.）
2. 對照 blocklist（聚合站黑名單）
3. 查重（sources.md + candidates.md）
4. 都不在 → append 到 candidates.md
5. 輸出：已加入/已存在/被封鎖

**自動觸發**: 當 agent 處理 URL 摘要後自動執行。

### sp500-review.sh

審核候選來源。

```bash
# 審核所有候選
bash ~/.openclaw/skills/sp500/scripts/sp500-review.sh

# 審核單一 domain
bash ~/.openclaw/skills/sp500/scripts/sp500-review.sh --domain example.com
```

流程：
1. 讀待審核條目
2. 測可達性（HTTP status）
3. 偵測 RSS（/feed, /rss, /atom.xml）
4. 取首頁 title + meta description
5. 輸出 JSON 結構化資料

### sp500-health.sh

健檢全池來源。

```bash
bash ~/.openclaw/skills/sp500/scripts/sp500-health.sh
```

流程：
1. 讀 sources.md 所有來源
2. curl -sI 測 HTTP status
3. 測 RSS 是否有效
4. 輸出存活/死亡/RSS失效報告

**建議排程**: 每月 1 日 10:00 cron。

### sp500-verify.sh

紅藍隊驗證，深入檢查文章品質。

```bash
# 驗證候選池（每批 5 個）
bash ~/.openclaw/skills/sp500/scripts/sp500-verify.sh

# 指定批次大小
bash ~/.openclaw/skills/sp500/scripts/sp500-verify.sh --batch 3

# 單一驗證
bash ~/.openclaw/skills/sp500/scripts/sp500-verify.sh --domain example.com

# 自動連續跑所有
bash ~/.openclaw/skills/sp500/scripts/sp500-verify.sh --auto
```

流程（每個 domain）：
1. web_fetch 抓首頁最新文章列表
2. 挑 3 篇文章（新聞、深度、專欄）
3. 每篇 web_fetch 抓全文
4. 輸出 JSON 到 /tmp/sp500-verify/
5. agent 讀取後做五維評分

## 數據檔案

- `data/sources.md`: 已通過審核的來源池（symlink → ~/.openclaw/workspace/sp500-sources.md）
- `data/candidates.md`: 候選來源（symlink → ~/.openclaw/workspace/sp500-candidates.md）

## 黑名單

聚合站不收錄：
- news.google.com
- news.yahoo.com
- smartnews.com
- flipboard.com
- apple.news
- line.me
- msn.com
- feedly.com
- news.livedoor.com

## 五維評分標準

詳見 `references/scoring-guide.md`：

1. 原創性（0-10）
2. 更新頻率（0-10）
3. 可抓取性（0-10）
4. 引用品質（0-10）
5. 領域權威（0-10）

Tier 1: 40+, Tier 2: 25-39, Tier 3: <25

---

## 系統架構與策略

詳細設計見 references/：
- `references/architecture-v2.md` — 三層架構（L1/L2/L3）、興趣圖譜演化機制
- `references/language-strategy.md` — 語言策略、翻譯基礎設施
- `references/scale-targets.md` — 規模目標、Podcast/YouTube 納入方式

---

## Gotchas（避坑指南）

### 來源審核常見誤判

1. **聚合站誤收**
   - 問題：誤將 Google News / SmartNews 等聚合站當原創來源
   - 解法：intake 時先檢查 blocklist，再看文章是否有具名作者
   - 案例：誤收 news.yahoo.com 轉載文，浪費審核時間

2. **政治傾向誤判**
   - 問題：某些來源在財經/科技可信，但政治時事偏頗
   - 解法：ZH-CN 來源加評審維度「編輯獨立性」，政治時事跳過
   - 案例：某財經網站科技報導可信，但政治評論明顯偏頗

3. **RSS 失效未發現**
   - 問題：來源 RSS 存在但長期無更新（網站改版/停止維護）
   - 解法：health 檢查時不只測 HTTP status，還要看 RSS 最近更新時間
   - 案例：某部落格 RSS 存在但最後更新是 2024 年

### 多語言來源處理

1. **翻譯品質問題**
   - 問題：AI 翻譯後失去原文精髓，或翻譯錯誤導致理解偏差
   - 解法：摘要後附原文關鍵詞，重要觀點雙語並列
   - 案例：某日文科技文章翻譯後專業術語失真

2. **語言標記遺漏**
   - 問題：intake 時忘記加 `lang:` 標記，導致 L2 收割時語言資訊缺失
   - 解法：intake.sh 自動偵測語言（HTML lang attribute），agent 審核時再次確認
   - 案例：某韓文來源誤標為英文

### Tier 晉升/降權

1. **過早晉升 Tier 1**
   - 問題：來源只發過 2-3 篇好文就被晉升 Tier 1，後續品質不穩
   - 解法：Tier 1 需連續 30 天高品質 + 至少 10 篇驗證文章
   - 案例：某新網站前幾篇深度分析，後來變流量農場

2. **降權觸發條件過嚴**
   - 問題：愛心率 < 5% 就降權，但可能是主題暫時冷門
   - 解法：降權前先檢查最近 7 天是否有新文章（可能只是停止更新）
   - 案例：某季刊網站愛心率低但品質高，不應降權

### 收割頻率調整

1. **高頻來源過載**
   - 問題：F≥8 的來源每 4 小時收割，產生大量重複內容
   - 解法：L2 加去重邏輯（URL hash + 標題相似度）
   - 案例：某科技網站每 4 小時收割，但只有 1-2 篇新文

2. **低頻來源遺漏**
   - 問題：F<5 週批次，可能錯過突發重要文章
   - 解法：關鍵來源（如官方公告）不受 F 限制，每 12 小時檢查
   - 案例：某政府網站突發重要公告，週批次才抓到已過時
