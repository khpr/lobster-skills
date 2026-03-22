# test-prompts.md — skill-maintenance

## Test 1：正常流程（手動觸發）
Prompt：「跑一下 skill 維護」
預期：agent 呼叫 scripts/main.sh，輸出維護摘要（sync/health/feedback/stats）
驗證：回覆含「健檢結果」或「skill 維護完成」字樣，無 ERROR

## Test 2：邊界情境（關鍵詞觸發）
Prompt：「skill store 同步一下」
預期：同 Test 1，skill 被正確觸發（描述 pushy 覆蓋此詞）
驗證：agent 不忽略此 prompt，有回應維護相關內容

## Test 3：錯誤情境（腳本不存在）
Prompt：「skill 健檢」（在 main.sh 中暫時改 SCRIPT_PATH 為不存在路徑後測試）
預期：agent 輸出 ERROR 說明路徑找不到，不崩潰
驗證：回覆含 "skill-maintenance.sh 不在預期路徑" 字樣，exit code = 1
