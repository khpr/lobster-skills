# test-prompts.md — memory-handoff-sync

## Test 1：正常流程
Prompt：「重啟交接，幫我備份記憶並準備交接卡」
預期：agent 整理本輪摘要 → 執行 handoff.sh → 回覆 BOOT.md 前三行 + 歸檔路徑
驗證：
- BOOT.md 存在且含 `generated:` 時間戳
- memory/YYYY-MM-DD.md 有新增 `## HANDOFF` 段落
- /tmp/memory-handoff-done.json 存在

## Test 2：邊界條件 — 無摘要提示
Prompt：「memory handoff」
預期：agent 觸發 skill，使用預設摘要文字，完成備份
驗證：
- BOOT.md 寫入成功
- 不因摘要缺失而報錯

## Test 3：錯誤情境 — 不含 session-reset
Prompt：「交接卡備份但先不重啟」
預期：agent 只做 Step 1–3（備份），Step 4 詢問確認後跳過
驗證：
- BOOT.md 更新
- session-reset.sh 未被執行（session 仍存活）
