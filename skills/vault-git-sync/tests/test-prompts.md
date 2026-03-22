# vault-git-sync Test Prompts

## Test 1：正常流程（有變更）
Prompt：「同步 Vault」
預期：agent 執行 vault-auto-commit.sh，Vault 有新的 git commit，回報 commit message
驗證：`cd ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Obsidian\ Vault && git log --oneline -1` 確認有新 commit

## Test 2：邊界情境（無變更）
Prompt：「Vault commit」
預期：腳本執行後無 commit（因為沒有新變更），agent 回報「無變更，Vault 已是最新狀態」
驗證：git log 的最後一筆 commit 時間不是剛才

## Test 3：錯誤情境（vault-auto-commit.sh 不存在）
Prompt：「備份 Vault」
預期：agent 回報 ❌ vault-auto-commit.sh 不存在 + 錯誤路徑
驗證：echo 輸出包含 ❌ 且 exit code 非 0
