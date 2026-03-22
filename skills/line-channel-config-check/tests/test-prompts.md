# test-prompts.md — line-channel-config-check

## Test 1：正常流程（WARN 診斷）
Prompt:   "openclaw status 顯示 LINE WARN，幫我查一下"
預期:     agent 觸發 line-channel-config-check skill，執行 main.sh diagnose，輸出 Step 1-4 診斷結果
驗證:     看到 "Step 1: openclaw status" / "Step 2: Token format" 等標題出現在回覆中

## Test 2：邊界（空 token）
Prompt:   "LINE token 沒有設定，怎麼修？"
預期:     agent 執行 Step 2 → 偵測到 token length 0，說明需要人工到 LINE Developers Console 重新產生 token，並且標注 🔴 紅線
驗證:     回覆中包含 LINE Developers Console 連結，並說明這是紅線操作需人類授權

## Test 3：錯誤情境（API 401）
Prompt:   "LINE bot 回覆停了，LINE channel 有問題嗎"
預期:     agent 執行 Step 3 API 呼叫 → HTTP 401/403 → 提示 token 過期，引導人工重新產生，不自動修改 openclaw.json
驗證:     回覆中明確說明 token 過期，提供重新產生步驟，不直接執行 openclaw config set
