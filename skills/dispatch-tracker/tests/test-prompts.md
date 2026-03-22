## Test 1：正常流程
Prompt："幫我新增一個派工：把 WO-037 backlog 的 status 檢查一下"
預期：skill 觸發，新增一筆 item，回傳 id
驗證：跑 `bash scripts/main.sh list` 能看到該筆

## Test 2：邊界情境
Prompt："把剛剛那個派工標記完成"
預期：skill 觸發，要求提供 id 或列出 open items
驗證：回覆有 usage 或提示

## Test 3：錯誤情境
Prompt："把 id=xxxxxxx 標記完成"
預期：skill 觸發，但回 not found
驗證：腳本 exit 1，且不會改其他 item
