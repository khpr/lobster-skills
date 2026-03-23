# GOTCHAS.md — session-reset

> 格式：每條 = **錯誤描述** / **正確做法** / **觸發情境**

---

## G1: session-memory hook 日期異常導致記憶漏讀

**錯誤**：session-memory hook 使用 `event.timestamp`（可能帶到錯誤值）寫出錯誤日期的記憶檔（如月份 +4）。下次啟動讀 `memory/YYYY-MM-DD*.md` 時整份被跳過，agent 矇逼。
**正確**：啟動時如果看到 memory/ 下有日期奇怪的檔（月份差超過 1 個月），先手動 rename 到正確日期。長期解法：`event.timestamp` 無效時 fallback 到 `Date.now()`。
**觸發情境**：OpenClaw 2026.2.25 特定 webchat session reset 觸發，`event.timestamp` 被設為遠期時間。

---

## G2: workspace-sync 路徑改了沒同步，session-reset 失效

**錯誤**：修改了某 agent 的記憶路徑或啟動 glob，但沒有跑 workspace-sync 同步其他 agent，導致 session-reset 後 agent 讀到舊路徑，找不到記憶。
**正確**：任何涉及記憶路徑、啟動流程的變更，改完必須跑 `workspace-sync.sh diff` 確認全員一致。
**觸發情境**：調整 AGENTS.md 啟動 glob、修改 memory 路徑命名規則後。

---

## G3: session-reset 後未確認前次任務狀態

**錯誤**：session 重啟後直接等使用者下指令，沒有主動檢查是否有進行中的派工或未結案任務。
**正確**：session 重啟後第一件事是讀 memory 確認當天未完成任務清單，主動追蹤 subagent 狀態，不等人類提醒。
**觸發情境**：watchdog 自動觸發 session-reset、或長時間無操作後重啟。

---

## G4: Gateway restart 期間的 Reply token 會過期

**錯誤**：session-reset 觸發 gateway restart 時，正在處理的 LINE reply token（60 秒有效）可能過期，導致回覆送不出去。
**正確**：reset 前若有 pending 的 Reply，先送出 ACK 再重啟。或備份 reply token 讓重啟後繼續使用（如果 OpenClaw 支援）。
**觸發情境**：使用者發訊息、agent 開始處理途中觸發 session-reset。
