(來源：workspace/docs/tools/triad.md)

# Triad Tools 參考資料

以下內容與 `docs/tools/triad.md` 同步，作為 triad-tools skill 的詳細參考。

# 三大金剛：Claude Code / Gemini CLI / Codex CLI（OpenClaw 用法與路由）

目標：把三個 CLI 當成「可派工的外掛大腦」，但維持可控（路徑範圍、權限、可追溯 log）。

## 快速路由（先選工具再做事）

- **Gemini CLI**：一次性 Q&A / 摘要 / 產文 / 要 JSON 輸出（不落地改檔）
- **Codex CLI**：在 repo 內做 code 理解、產生 patch/diff、review、可互動 agent（偏工程）
- **Claude Code**：互動式 coding assistant，適合跨多檔重構、改碼→跑測試→迭代（偏工程、長流程）

原則：
- 一兩行修正 → 直接用 OpenClaw `edit`
- 需要讀很多檔、改很多檔、跑測試 → Claude Code / Codex CLI
- 只要快速摘要/改寫/清單/JSON → Gemini CLI

---

## Gemini CLI（`/opt/homebrew/bin/gemini`）

### 適用情境
- one-shot Q&A、摘要、改寫、生成清單/文案
- 需要 **JSON**（方便後續處理）

### 常用指令
- 直接問：`gemini "用 5 點列出我該怎麼規劃一週運動安排（含強度分級）"`
- 指定模型：`gemini --model <name> "…"`
- JSON：`gemini --output-format json "把以下內容抽成 {title, bullets[]}：…"`

### 大檔摘要技巧（先裁切再總結）
- `gemini "摘要：$(sed -n '1,200p' big.md)"`
- `gemini "摘要：$(tail -n 200 big.md)"`

### Gotchas
- 避免互動模式：用 `gemini "…"` 一次性呼叫較可控
- 長文別直接 `$(cat bigfile)`：先 `sed/head/tail` 裁切或分段
- 不用 `--yolo`

---

## Codex CLI（`/opt/homebrew/bin/codex`）

### 適用情境
- 在本機 repo 內：理解程式碼、產 patch、跑 review、互動式 agent

### 工作目錄（最重要）
- 明確用 `-C, --cd <DIR>` 釘死範圍，避免在錯誤目錄誤改檔
  - `codex -C /Users/m4pro/.openclaw/workspace …`

### pty（互動式）
- 互動式 `codex`（TUI）在 OpenClaw 內建議 `exec(pty:true)`
- 非互動 `codex exec/review/apply` 通常不需要 pty；不確定就開

### 常用指令
- 互動：`codex -C /Users/m4pro/.openclaw/workspace --no-alt-screen`
- 一次性：`codex exec -C /Users/m4pro/.openclaw/workspace "請提出修正 diff：…"`
- Review：`codex review -C /Users/m4pro/.openclaw/workspace`
- Apply（需 git working tree）：`codex apply -C /Users/m4pro/.openclaw/workspace`

### 風險控制（建議）
- `--sandbox read-only | workspace-write` + `--ask-for-approval untrusted`（保守好用）
- 避免：`--dangerously-bypass-approvals-and-sandbox`

---

## Claude Code（`~/.local/bin/claude`）

### 適用情境
- 互動式 coding assistant：跨多檔重構、建立新功能、改碼→跑測試→反覆迭代

### 在 OpenClaw 內怎麼跑
- 通常是互動式：建議 `exec(pty:true)`
- 一律在目標 repo/資料夾啟動：用 `workdir` 或先 `cd`

### 安全預設（強烈建議）
- 進場前先 `git status`（乾淨或先 commit/stash）
- 限定作用範圍：只在指定 repo/子資料夾內跑
- 先要求它提出計畫（改哪些檔、跑哪些測試、回滾方式）再開始改

### 輸出落地（log）
- `... 2>&1 | tee -a logs/claude-code-YYYYMMDD-HHMM.txt`

### Gotchas
- 沒開 PTY：互動介面可能卡住
- 目錄錯：看不到檔或掃到不該掃的
- Repo 太大：先聚焦子目錄/小步改，避免掃描爆成本

