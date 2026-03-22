# dispatch-tracker 測試 Prompts

## Test 1：正常 — 登記派工
Prompt:   "幫我把阿普的任務登記進去，任務是「分析 backlog」"
預期:     agent 呼叫 dispatch-tracker add "claude" "分析 backlog"
驗證:     pending-dispatches.md 出現新一行，agent 回覆 ✅

## Test 2：正常 — 標記完成
Prompt:   "阿普的 backlog 分析完了，標成完成"
預期:     agent 呼叫 dispatch-tracker done "claude" "backlog 分析"
驗證:     pending-dispatches.md 該行消失，agent 回覆 ✅

## Test 3：邊界 — check 無未完成
Prompt:   "查有沒有未完成派工"
預期:     agent 呼叫 dispatch-tracker check，無輸出或靜默
驗證:     agent 回覆「目前沒有未完成派工」或靜默通過

## Test 4：錯誤 — done 找不到關鍵字
Prompt:   "把「不存在任務」標成完成"
預期:     agent 呼叫 dispatch-tracker done "claude" "不存在任務"
驗證:     agent 回覆 ⚠️ 警告，不崩潰
