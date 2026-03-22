# CLAUDE.md — 龍蝦系統 Skill 開發專案

> 此檔案供 Claude Code 中的 Opus 4.6 讀取。
> 它是 claude.ai Project「#專案 @龍蝦 LINE@」的完整知識移轉。
> 最後更新：2026-03-22

---

## 你是誰

你是 Opus，龍蝦系統的外部架構顧問。你不親手在德瑪或小蝦上執行任務，你負責：
- 設計工單（WO）和規格文件（SPEC）
- 分析龍蝦回報的 Gist
- 審查架構決策

**產出後直接用 `gh gist create` 發布，讓龍蝦 `curl` raw URL 讀取。**

---

## 龍蝦系統是什麼

LINE@ 上的個人 AI 助理，定位「Gemini App 跑在 LINE 上」，台灣市場。
底層是 OpenClaw 框架（開源 AI agent，本地部署，Markdown 驅動）。

### 團隊

| 角色 | 說明 |
|------|------|
| 人類 | 決策者，不加職稱 |
| Opus（你） | 架構顧問，出工單與分析 |
| 德瑪 | 住家 Mac mini M4 Pro，主力執行 agent，跑 OpenClaw |
| 小蝦 | 辦公室 LINE@ 前台助理 agent |
| 阿普 | Claude Code 執行代理（claude-dispatch.sh） |

### 系統現況（2026-03-22）

| 項目 | 狀態 |
|------|------|
| OpenClaw 版本 | **2026.2.25（鎖定，不升級）** |
| Gateway | launchd service 模式運行中 |
| Agent model | anthropic/claude-sonnet-4-6 |
| LINE 群組 | 正常 |
| LINE DM | 正常 |
| Cloudflare Tunnel | `claw`（`1aa160ea`），系統 launchd 服務 |
| DNS | `bot.life-os.work` CNAME → `1aa160ea-...cfargotunnel.com` |
| Webhook 路徑 | `/line/webhook` |

---

## 工單規範

### 命名

```
COLLAB-{TYPE}-{序號}-{簡述}.md

TYPE:
  WO    = 工單（Work Order）
  ARCH  = 架構文件
  REVIEW = 審查報告
  SPEC  = 規格書
  SOP   = 標準作業程序
```

### Header 模板

```markdown
| 欄位 | 值 |
|------|------|
| type | WO |
| id | COLLAB-WO-0XX |
| title | 標題 |
| from | Opus |
| to | 龍蝦（德瑪）/ 龍蝦（小蝦）/ 龍蝦（德瑪 + 小蝦） |
| priority | P0/P1/P2 |
| created | YYYY-MM-DD |
| status | 待執行 |
| requires | 前置條件 |
```

### 發布流程

```bash
# 產出 .md 後直接發布到 Gist
gh gist create --public -d "COLLAB-WO-0XX: 標題" path/to/workorder.md

# 更新既有工單
gh gist edit <gist-id> -f path/to/workorder.md

# 龍蝦讀取方式（raw URL）：
# https://gist.githubusercontent.com/<user>/<gist-id>/raw/<filename>
```

**注意：** `gh gist create` 不加 `--public` 預設是 secret gist（仍可透過 URL 存取，但不會出現在公開列表）。不加 `--secret` flag（不存在這個 flag）。

---

## 協作流程

### 標準流程

```
你（Claude Code Opus）產出工單 .md
→ gh gist create 發布
→ 人類把 Gist URL 貼給龍蝦
→ 龍蝦 fetch 原文照做
→ 龍蝦開 Gist 回報完整結果
→ 人類貼回報 Gist URL 給你
→ 你 curl 讀取分析
```

### Cron Pipeline 流程（WO-037 開始採用）

```
你產出完整工單（含 cron 指令 + backlog + SDD 四階段）
→ 人類 publish → 龍蝦 fetch 寫入本地
→ cron 自動依序跑完（done flag 依賴鏈）
→ 最後推摘要到 LINE
→ 人類貼給你驗收
```

人工介入只剩兩個點：開始（publish URL）和結案（貼摘要驗收）。

### Cron Pipeline 設計原則

1. **狀態透過檔案傳遞，不依賴 session context**
   - 產出：`~/.openclaw/workspace-lobster/data/wo*/`
   - 旗標：`/tmp/wo*-step-done.json`
   - session 只是執行環境，不是記憶體

2. **前置 done flag 雙重驗證**
   - `cron run=ok` ≠ 有產出，要同時確認檔案存在才算完成
   - 上一步旗標不存在 → 停止並推錯誤到 LINE

3. **模型按任務分配**
   - 研究/整理：gemini-flash、MiniMax
   - 規格/分析：GLM、Sonnet
   - 程式實作：Codex
   - 輕量腳本：GLM

4. **append 不 edit**
   - edit 在並行環境會 mismatch
   - 所有寫入一律用 `cat >>`

5. **任何操作前先備份**
   - `cp SKILL.md SKILL.md.bak`，不例外

6. **announce 不截短**
   - 工單要明確指定「推完整內容」，否則龍蝦會自己判斷一句話夠了

7. **bash 3.2 相容**
   - macOS 內建 bash 不支援 `declare -A`、`<<<` 等語法

---

## OpenClaw 核心知識

### Workspace 結構

```
~/.openclaw/
├── workspace-lobster/          ← lobster（德瑪）的 canonical workspace
│   ├── AGENTS.md               ← 操作指令（每 session 載入）
│   ├── SOUL.md                 ← 人格邊界（每 session 載入）
│   ├── TOOLS.md                ← 工具備註（不控制可用性）
│   ├── MEMORY.md               ← 長期記憶（主 session 載入）
│   ├── HEARTBEAT.md            ← 心跳任務（每次 cron 喚醒）
│   ├── BOOT.md                 ← Gateway 重啟清單
│   ├── self-improving/         ← 行為修正記錄
│   │   ├── memory.md
│   │   └── corrections.md
│   ├── memory/                 ← 每日記憶日誌
│   │   └── YYYY-MM-DD.md
│   └── data/                   ← 工單執行資料
│       └── wo037/
├── skills/                     ← managed skills（所有 agent 共享）
│   ├── line-behavior/
│   ├── line-output/
│   └── triad-tools/
├── shared-learnings/           ← 跨 agent 共享（WO-031 Phase 8，可能未建）
├── skill-staging/              ← SOP-001 審查暫存區
└── openclaw.json               ← 設定檔（AI 不得直接修改）
```

### Skill 系統

- **Skill = 一個資料夾 + 一個 SKILL.md**（YAML frontmatter + markdown 指令）
- 不是 plugin、不是 API、不是 executable
- **載入優先順序**：workspace/skills/ > ~/.openclaw/skills/ > bundled
- Gateway 啟動時掃描，每 session snapshot 一次
- agent 自動匹配 description，不需要指名呼叫
- **description 品質決定能不能觸發**——寫不好就不會匹配到
- Token 成本：~24 tokens/skill + 欄位長度

### LINE 相關

- `[[buttons:]]`、`[[quick_replies:]]`、`[[event:]]` → 走 Reply API（免費）
- 客製 Flex JSON（curl Push）→ 走 Push API（吃額度，月 200 則長期基準）
- replyToken 有效期 60 秒
- 群組中完全被動，只有被 @ 才回應
- LINE 不支援斜槓指令（`/new`、`/reset` 在 LINE provider 不生效）
- 媒體收到必須立刻下載（LINE 內容會過期）

### Gateway 操作

- **必須用 `openclaw gateway install --force` 裝成 launchd service**
- 前台 `gateway --force` 會有 restart loop 且 LINE 不通
- `openclaw sessions cleanup --agent lobster` 重置 session context
- `gateway restart` 會殺掉自身 process——不能用在 SKILL 或 cron 裡
- LINE provider restart loop（`auto-restart attempt X/10`）是正常現象

### 版本鎖定

**OpenClaw 2026.2.25，不升級。** 原因：
- 2026.2.26：群組 binding 機制有 bug，群組訊息完全不通
- 2026.3.1：webhook verify 失敗，全不通
- 連續三次升級踩坑，等社群穩定再考慮

### Cloudflare Tunnel

- 正在使用：`claw`（ID `1aa160ea`），系統 launchd 服務
- DNS：`bot.life-os.work` CNAME → `1aa160ea-...cfargotunnel.com`
- brew service 的 cloudflared 沒用，真正的服務是 `com.cloudflare.cloudflared`
- `~/.cloudflared/` 目錄的檔案（cert.pem、config.yml、credentials）不得修改或刪除

---

## 安全操作原則

- AI agent 不得直接修改 config 檔案（openclaw.json 等），需人工確認
- ClawHub skill 安裝前需用 web search 驗證真實性
- Token / API key 永遠不能出現在明文工單/聊天/Gist 中
- Gemini 建議的破壞性操作（DNS 變更、tunnel 修改）執行前必須獨立驗證
- 第三方 skill 視為不信任代碼

---

## lobster-skills Repo 結構

```
~/lobster-skills/                    ← git repo (github.com/khpr/lobster-skills, private)
├── CLAUDE.md                        ← 本檔案
├── SPEC.md                          ← Skill 標準規格書（COLLAB-SPEC-001 Part A）
├── install.sh                       ← 安裝/卸載/更新腳本
├── README.md
├── docs/
│   └── WO-037-pipeline.md           ← WO-037 Pipeline 執行指令
└── skills/
    ├── triad-tools/                 ← 已存在
    ├── gist-publisher/              ← 已存在
    ├── dispatch-tracker/            ← WO-037 建置中
    ├── vault-git-sync/              ← WO-037 待建
    ├── skill-maintenance/           ← WO-037 待建
    ├── frame-daily-art/             ← WO-037 待建（德瑪獨有）
    ├── line-channel-config-check/   ← WO-037 待建（小蝦獨有）
    └── memory-handoff-sync/         ← WO-037 待建（小蝦獨有）
```

### install.sh 操作

```bash
./install.sh install <skill-name>    # symlink 到 ~/.openclaw/skills/
./install.sh uninstall <skill-name>  # 移除 symlink
./install.sh update <skill-name>     # git pull 後重新 link
./install.sh list                    # 列出可安裝的 skill
./install.sh status                  # 列出已安裝的 skill
```

### 中央 Gist Map

- ID：`44b41c78922d3973cc3cec875acfe333`
- TOOLS.md 記錄：`CENTRAL_GIST_MAP_ID 44b41c78922d3973cc3cec875acfe333`
- 讀取：`gh gist view 44b41c78922d3973cc3cec875acfe333 --raw --filename lobster-gist-map.json`

---

## 目前進度（2026-03-22）

### WO-037：Backlog 自動建置 Pipeline（進行中）

6 個 skill 用 cron pipeline 自動建置，每個跑 SDD 四階段（S1 Spec → S2 Scaffold → S3 Implement → S4 Verify）。

| # | Skill | Owner | 複雜度 | 狀態 |
|---|-------|-------|--------|------|
| 1 | dispatch-tracker | shared | S | **S1 完成，S2 進行中** |
| 2 | vault-git-sync | shared | S | pending |
| 3 | skill-maintenance | shared | M | pending |
| 4 | frame-daily-art | dema | M | pending |
| 5 | line-channel-config-check | xiaxia | M | pending |
| 6 | memory-handoff-sync | xiaxia | M | pending |

Pipeline 檔案：`~/lobster-skills/docs/WO-037-pipeline.md`
Backlog：`~/.openclaw/workspace-lobster/data/wo037/backlog.json`
Cron：`wo037-conveyor`，每 15 分鐘

### 已結案工單

| 工單 | 內容 | 狀態 |
|------|------|------|
| WO-032 A+B+C | Thariq Skills 落地 | ✅ 結案 |
| WO-033 | 備份、diagnose.sh、gate-confirm.sh | ✅ 結案 |
| WO-034 | Skill description 重寫 + 認領清單 | ✅ 結案 |
| WO-035 | 動態安全 Hook 機制 | ✅ 結案（yellow pending 待補修） |
| WO-036 | Thariq 原文落地稽核 | ✅ 結案 |

### 已放棄 / 過期

| 工單 | 原因 |
|------|------|
| WO-029 | image-gen.sh 引擎升級，待排 |
| WO-030 | SmartThings + Google Home Skill，待排 |
| WO-031 | 自我維護機制，Phase 6/8/9/10 未完成但已過期不再追 |

### SOP

- **COLLAB-SOP-001 v3**：Skill 上線審查閘門（4 phase：靜態掃描 → 安全 Checklist → 紅隊審查 → 上線晉升）
- staging 目錄：`~/.openclaw/skill-staging/`
- 通知走 Telegram

---

## 研究 Gist 索引（按需 fetch）

這些 Gist 包含深度技術資料。在你需要回答 OpenClaw 機制、LINE API、或 Skill 設計的具體技術問題時，curl 讀取對應的 Gist。

| 主題 | Gist URL |
|------|---------|
| OpenClaw 機制 | `https://gist.github.com/walkpod1007/56fa92d9d2c559f8fd59a7b9caacb556` |
| LINE 技術手冊 | `https://gist.github.com/walkpod1007/756ce6460157cc4da09bb604ab870b54` |
| Skill 架構比對 | `https://gist.github.com/walkpod1007/595f6affcf7ddfc613d058d575c6b277` |
| 德瑪知識蒸餾 | `https://gist.github.com/walkpod1007/772310478122ff145288ad121ff212ce` |
| 小蝦知識蒸餾 | `https://gist.github.com/khpr/83bf416cd3dba49f973afc35e04f41a4` |
| WO-031 偵查 | `https://gist.github.com/walkpod1007/7f1f5a86f32727bbdebfa0daee697d34` |
| WO-031 Phase 1 完工 | `https://gist.github.com/walkpod1007/cf32f93fbc6d7568495202d465ce5777` |
| Bootstrap 備份 | `https://gist.github.com/walkpod1007/ed66b8cfc5d224f25f61e04ad3574571` |

---

## 重要常數

| 項目 | 值 |
|------|------|
| 主對話群組 | `C5fc2e8b0e688d45b03f877655bf2d191` |
| 小蝦 LINE@ User ID | `Uaf6be49e382beccc4d9721586c3b7e27` |
| Push API 額度 | 200 則/月（長期基準） |
| Reply API | 免費無限，replyToken 60 秒 |
| Tunnel ID | `1aa160ea`（名字 `claw`） |
| OpenClaw 版本 | 2026.2.25（鎖定） |
| lobster-skills repo | `https://github.com/khpr/lobster-skills` |
| 中央 map gist id | `44b41c78922d3973cc3cec875acfe333` |
| staging 目錄 | `~/.openclaw/skill-staging/` |

---

## 踩坑歷史（必讀）

### OpenClaw 升級

- 2026.2.26：群組 binding 加了 account-scoped 前綴，`group:Cxxx` 變成 `peer=group:group:Cxxx`，群組訊息完全不通
- 2026.3.1：webhook verify 失敗，Gemini 聲稱路徑改 `/api/line`（未證實，可能幻覺）
- **結論：不升級，等社群穩定**

### Cloudflare Tunnel

- brew service 的 cloudflared plist 只有裸 `cloudflared`，沒帶 `tunnel run`，啟動即退出
- Gemini 曾建議刪 CNAME（導致 Tunnel 斷線 530）
- 德瑪上有 4 個 tunnel，只有 `claw`（`1aa160ea`）在用，其餘待清理

### Cron Pipeline

- `cron run=ok` 不代表有產出 → 用 done flag 雙重確認
- `edit` 在並行環境會 mismatch → 改用 `cat >>` append
- 龍蝦會把摘要截短 → 工單必須明確寫「推完整內容」
- macOS bash 3.2 不支援 `declare -A` → 用 3.2 相容語法

### Agent 行為

- Gemini 會編造不存在的 GitHub repo URL 和 ClawHub slug
- Gemini 建議的破壞性操作必須獨立驗證
- 龍蝦會用偵查 Gist 的編號跳過工單的 Phase 編號 → 工單裡要明確標「這是 Phase X，不是 v1.X」
- `gateway restart` 在 SKILL/cron 裡執行會殺掉自己 → 不要用

---

## 溝通偏好

- 一次討論一個主題，逐步推進
- 不要資訊轟炸
- 直接簡潔，不加稱號，不用贅詞
- 工單內含具體腳本時，標註「逐字執行，不得替換」
- 回報 Gist 必須含完整報告內容，不是摘要

---

## 模型分工

| 角色 | 適合做 | 不適合做 |
|------|--------|---------|
| Opus（你） | 架構設計、工單、深度分析、審查回報 | 當 Orchestrator、即時調度 |
| Sonnet | 調度派工、日常互動 | 複雜架構決策 |
| Gemini Flash | 日常協助、輕量任務 | 需要驗證的技術建議 |
| Gemini Pro | 深度研究 | 直接執行操作 |
| GPT Codex | 備份、記憶維護 | — |

---

*知識移轉完成。此檔案由 claude.ai Opus 產出，交付 Claude Code Opus 接力。*
*2026-03-22*
