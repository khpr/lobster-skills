## Test 1：正常流程
Prompt："請使用 line-channel-config-check ..."
預期：skill 觸發，並完成主要流程（或至少回覆下一步/輸出）
驗證：能看到預期輸出或產生對應檔案

## Test 2：邊界情境
Prompt："請使用 line-channel-config-check，但缺少必要參數..."
預期：skill 仍觸發，並回覆可操作的 usage/錯誤提示
驗證：stderr/訊息包含 usage 與缺少參數說明

## Test 3：錯誤情境
Prompt："請使用 line-channel-config-check 對不存在的資源..."
預期：skill 回覆錯誤，不做破壞性操作
驗證：exit 非 0（若跑腳本）或明確錯誤訊息
