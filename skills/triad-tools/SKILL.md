---
name: triad-tools
description: Tool routing and delegation for the "三大金剛" (Gemini CLI, Codex CLI, Claude Code). Use when the user asks to 派工/委派/交給三大金剛/派給阿普/叫阿普, or when a task is multi-step, likely >3s, requires repo-wide code changes, or needs one-shot summarization/JSON output.
---

# Triad Tools（三大金剛派工 / 路由）

目標：不用每次提醒，也能把工作自動路由到正確的金剛，並且可控（workdir/sandbox/pty/log）。

## 0) 快速判斷（選誰出戰）

- **Gemini CLI**：one-shot 內容工作（摘要/改寫/清單/要 JSON）；不需要落地改檔。
- **Codex CLI**：工程任務（理解 repo、產生 patch/diff、review、可互動 agent）。
- **Claude Code**：長流程工程任務（跨多檔重構、改碼→跑測試→迭代）。

硬規則：
- 一兩行小修 → 直接 `edit`
- 需要多檔修改或跑測試 → Codex / Claude Code（務必限定 workdir）

## 1) 派工標準作業（所有金剛共通）

1. **先鎖工作目錄**：只在目標資料夾內跑（workdir 或 `-C`），避免掃到不該掃的檔。
2. **先留痕（log）**：stdout/stderr 一律落地到 `logs/`（用 `tee`）。
3. **互動就開 PTY**：Codex/Claude Code 互動模式都用 `pty:true`。
4. **能沙盒就沙盒**（Codex）：優先 `--sandbox` + `--ask-for-approval`。

## 2) 命令模板（精簡版）

### Gemini（one-shot）
- `gemini "<prompt>"`
- JSON：`gemini --output-format json "<prompt>"`

### Codex（工程，建議加 -C + sandbox）
- 互動：`codex -C <dir> --no-alt-screen`
- 一次性：`codex exec -C <dir> "<prompt>"`

### Claude Code（工程互動，需 pty）
- `claude`（在 repo workdir 內啟動）
- 建議：先要求它列 plan（改哪些檔、跑哪些測試、回滾方式）再動手。

## 3) 需要細節時

- 讀：`references/triad.md`（完整路由、gotchas、風險控制）
