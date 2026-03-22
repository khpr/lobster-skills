# Gist Publisher — 參考資料

## 依賴
- `gh` 已登入（帳號：khpr）
- `node`（用於維護 `gist-index/map.json`）

## 行為
- 以「檔案路徑（盡量轉成 workspace 相對路徑）」當 key，寫入 `gist-index/map.json`
- 之後對同一檔案再次發布，預設走 `gh gist edit <id>` 更新內容（不新增 gist）

## 分享策略
- 預設 secret gist
- 使用者要求 public 才用 `--public`

## 禁止發布的內容（例）
- `~/.openclaw/openclaw.json`
- `client_secret.json`
- 任何含 token/key 的檔案

## 常見用法
- 發布能力矩陣：`scripts/publish-gist.sh docs/capability-matrix.md`
- 發布 triad 文件：`scripts/publish-gist.sh docs/tools/triad.md`

## 疑難排解
- 若 `gh auth status` 不是 khpr：先 `gh auth login`
- 若被要求重新授權：確認 scopes 需含 `gist`
