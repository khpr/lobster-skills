# BOOT.md 格式說明

BOOT.md 是 session-reset.sh 產生的交接卡，由 boot-md hook 在 gateway restart 時自動執行。

## 格式

```
# BOOT.md — 交接卡
generated: <ISO 8601 timestamp>
source: <產生來源腳本>

## HANDOFF 摘要

<上一輪 session 的 50 輪 HANDOFF 摘要>

## 歸檔路徑

memory/<YYYY-MM-DD>.md
```

## 注意事項

- BOOT.md 每次重啟覆寫，不保留歷史
- 歷史存於 memory/YYYY-MM-DD.md（append 模式）
- generated 欄位為 UTC 時間
