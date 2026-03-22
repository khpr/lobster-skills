# Gist Publisher — 參考資料

## 依賴
- `gh` 已登入（帳號：khpr）
- `node`（用於維護 `gist-index/map.json`）

## 行為
- 以「檔案路徑（盡量轉成 workspace 相對路徑）」當 key，寫入 `gist-index/map.json`
- Publish 前會先從「中央 map gist」同步最新 map；publish 後再推回中央 gist（確保德瑪/小蝦共用同一份對照表，避免重複建立 gist）
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

## 疑難排解 / 踩坑
- 若 `gh auth status` 不是 khpr：先 `gh auth login`
- 若被要求重新授權：確認 scopes 需含 `gist`
- `gh gist create` **沒有 `--secret` flag**：不加 `--public` 時預設就是 secret gist
- `gh gist view --raw` 需加 `--filename lobster-gist-map.json`：否則可能輸出 gist description，造成 JSON parse 失敗
