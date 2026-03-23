# GOTCHAS.md — Runbook Skill 已知坑

## Log 路徑不存在

**症狀**：`find: ... No such file or directory`
**原因**：`~/.openclaw/logs/` 不一定存在，取決於 Gateway 版本
**解法**：腳本已做路徑存在檢查（`[ -d ... ]`），不存在就跳過，不報錯

---

## `~` 在腳本內不展開

**症狀**：路徑帶 `~` 卻找不到檔案
**原因**：`find "~/.openclaw/..."` 在某些 shell context 下不展開
**解法**：腳本統一用 `$HOME` 取代 `~`

---

## grep 無輸出不代表沒錯誤

**症狀**：報告顯示「無相關 Log」，但問題確實發生過
**原因**：
1. Log rotation 把舊 log 壓縮或刪除
2. 錯誤發生在 stdout 而非 log 檔
3. 關鍵字大小寫不符（grep 預設 case-sensitive）
**解法**：腳本用 `-i` flag（case-insensitive），也可手動 `journalctl` 補查

---

## Gateway log 在 launchd stdout

**症狀**：`~/.openclaw/logs/` 沒有 gateway 相關 log
**原因**：macOS launchd service 的 stdout/stderr 可能導向 `~/Library/Logs/`
**解法**：
```bash
# 手動查 launchd log
cat ~/Library/Logs/openclaw-gateway.log 2>/dev/null || \
  log show --predicate 'process == "node"' --last 1h | grep -i openclaw
```

---

## JSON 格式 log 難讀

**症狀**：log 是 `{"level":"error","msg":"..."}` 格式，grep 輸出很醜
**原因**：部分服務用 JSON structured logging
**解法**：腳本偵測到 JSON log 時自動用 `jq` 格式化（需安裝 jq）
```bash
brew install jq  # 未安裝時
```

---

## 關鍵字太廣導致輸出爆炸

**症狀**：輸入 `"error"` 導致幾千行輸出
**原因**：error 是高頻詞
**解法**：腳本限制輸出最多 50 行相關 log；建議用更具體的關鍵字

---

## 權限問題

**症狀**：`Permission denied` 讀取某些 log
**原因**：系統 log（`/var/log/`）需要 sudo
**解法**：腳本只掃使用者可讀的路徑，系統 log 不在範圍內
若需要：`sudo log show --last 30m`

---

## diagnose.sh 沒有執行權限

**症狀**：`bash: permission denied` 或 `zsh: permission denied`
**原因**：新建立的腳本預設無 `+x`
**解法**：`chmod +x ~/.openclaw/skills/runbook/scripts/diagnose.sh`
