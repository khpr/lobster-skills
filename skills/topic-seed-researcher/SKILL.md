---
name: topic-seed-researcher
version: "3.0"
description: 以 research-seed.sh 與 research-grow.sh 管理「主題種子→每日研究→成熟論文」流程。v3.0：素材與論文 cron 拆分、研究問題持久化防失憶、質疑提問機制。
metadata: {"clawdbot":{"emoji":"🌱"}}
---

# Topic Seed Researcher v3.0

## Changelog

### v3.0（2026-03-09）
- 素材蒐集與論文撰寫拆分為獨立 cron
- 新增 `--skip-layer3` flag
- Layer 1a prompt 注入歷史研究問題 log，強制換方向、禁止重複
- 每日研究問題持久化到 `research-questions-log.md`（Obsidian）
- 論文撰寫改為手動觸發（人類決定切角和時機）
- 核心認知：Resource 蒐集可 SOP，論文撰寫不可 SOP

### v2.1
- 四層 pipeline：方向分析 → 針對性搜尋 → 驗證+摘要 → 彙整
- 三語搜尋（英/中/日）
- 探究式摘要 prompt
- 紅藍隊論文審查

### v1.0
- 基礎種子管理 + 單層 Gemini 研究

## 架構

```
素材 cron (05:00)          論文撰寫（手動）
┌─────────────┐           ┌──────────────┐
│ Layer 1a    │           │ Layer 3      │
│ Sonnet 方向 │           │ Opus/Gemini  │
│ + 質疑提問  │           │ 人類指定切角 │
├─────────────┤           └──────────────┘
│ Layer 1b    │
│ 三語搜尋    │
├─────────────┤
│ Layer 2     │
│ 探究式摘要  │
└─────────────┘
      ↓
research-questions-log.md（持久化）
      ↓
次日 Layer 1a 讀取 → 避免重複
```

## 目錄與資料

- 種子 JSON：`~/.openclaw/workspace/research-seeds.json`
- 種子管理腳本：`~/.openclaw/workspace/scripts/research-seed.sh`
- 每日研究腳本：`~/.openclaw/workspace/scripts/research-grow.sh`
- Vault 根目錄：`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault`
- Resource 輸出：`30_Resources/research/<seed-id>/`
- 論文輸出：`50_Research/<topic>/index.md`、`paper-v1.md`、`paper-v2.md`...
- 研究問題日誌：`50_Research/<topic>/research-questions-log.md`

## 使用方式

### A) 管理種子（CLI）

- 新增：`bash research-seed.sh add "主題" "種子文字" [url1] [url2]`
- 列表：`bash research-seed.sh list`
- 查狀態：`bash research-seed.sh status <seed-id>`
- 暫停：`bash research-seed.sh pause <seed-id>`
- 恢復：`bash research-seed.sh resume <seed-id>`

### B) 素材蒐集（自動 cron）

每日 05:00 自動執行，只跑 Layer 1-2：
```
bash research-grow.sh --orchestrate --skip-layer3
```

行為：
- Layer 1a：Sonnet 讀所有 Resource + 歷史問題 log → 質疑盲點 → 產 3 條新方向
- Layer 1b：三語搜尋（Flash/MiniMax/GPT）
- Layer 2：抓取 URL + 探究式摘要 → 存 Resource
- 完成後 append 當天問題到 research-questions-log.md

### C) 論文撰寫（手動觸發）

人類說「寫論文」時，由德米派 Gemini/Opus：
1. 餵入所有 Resource + 紅藍隊審查 + 明確切角
2. 一次產出完整論文
3. 存為 paper-vN.md

也可跑 Layer 3：
```
bash research-grow.sh --layer3
```

### D) 研究成熟規則

任一條件成立即標記 `mature`：
- Resource 數量 >= 70
- 論文估計字數 >= 30000

「飽和」不等於「主題窮盡」。如果搜尋 query 重複但主題仍有新角度，開新 seed 或手動指定方向。

## Cron 配置（目前生效）

素材 cron：
- ID：60476796-65eb-424d-9cf7-23831b216bca
- 名稱：topic-seed-material-daily
- 時間：05:00 Asia/Taipei
- 指令：--orchestrate --skip-layer3
- prompt 含質疑提問指令

論文 cron：已刪除（手動觸發）

## 質疑提問機制（v3.0 核心）

問題：Layer 1a 的 Sonnet 每次是新 session，不知道昨天問了什麼，導致搜尋方向重複、素材飽和假象。

解法：
1. 每天 Layer 1a 完成後，研究問題 append 到 `research-questions-log.md`
2. 下次 Layer 1a 啟動時，讀取最近 3000 字的歷史問題
3. prompt 強制要求：
   - 質疑現有素材盲點
   - 禁止與過去問題方向相同
   - 每天必須換角度（人物→產業→數據→地域→反面觀點）

## 依賴

- Shell：bash
- Python：python3
- AI CLI：gemini（Layer 1a 方向分析、Layer 3 論文）
- Agent：Sonnet（Layer 1a/2a）、Flash/MiniMax/GPT（Layer 1b 搜尋）
- 搜尋：Brave Search API（可選，fallback Gemini）
- 系統：curl, find, stat, wc, date
- 筆記：Obsidian Vault（iCloud）

## 故障排查

- Layer 3 timeout → 已拆分，不再是問題
- 素材飽和 → 檢查 research-questions-log.md，確認是否真的換了方向
- Gemini rate limit → 等 reset 或降低 Layer 密度
- research-questions-log.md 不存在 → 第一次跑會自動建立
