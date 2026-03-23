---
name: vault-git-sync
description: >
  自動 git commit Obsidian Vault，確保筆記有版本備份。
  觸發關鍵詞：同步 Vault、備份 Vault、Vault commit、存筆記到 git、vault-git-sync、
  Obsidian 備份、手動 git commit Vault、我想存一下筆記。
  也可由 cron 定時呼叫（不需用戶觸發）。
  執行 skills/vault-git-sync/scripts/main.sh（不寫死 workspace 路徑），
  有變更就 commit，沒有就靜默結束。
requires:
  bins: [git]
  env: [OBSIDIAN_VAULT_DIR, VAULT_GIT_SYNC_ALLOW_PUSH]
  config: []
owner: shared
complexity: S
version: "1.0"
created: "2026-03-22"
---

## 概述

封裝現有 `vault-auto-commit.sh` 腳本為 skill，讓龍蝦/小蝦都能一鍵觸發 Obsidian Vault 的 git auto-backup。

腳本路徑：`skills/vault-git-sync/scripts/main.sh`

## 前置條件

- Obsidian Vault 目錄已初始化為 git repo
- git 已設定（user.name / user.email）
- 不需要 push（腳本只 commit，不 push）

## 流程

### Step 1：執行腳本

```bash
bash scripts/main.sh sync
EXIT=$?
```

### Step 2：判斷結果

```bash
if [ $EXIT -eq 0 ]; then
  # 成功（有 commit 或無變更都算成功）
  echo "✅ Vault git sync 完成"
else
  echo "❌ Vault git sync 失敗（exit $EXIT）"
fi
```

### Step 3：回覆用戶

- 有 commit → 回報 commit message（帶時間戳）
- 無變更 → 回報「無變更，Vault 已是最新狀態」
- 失敗 → 回報錯誤，讓人類介入

## 輸出規範

- 純文字回覆
- 不需要 Flex Card
- cron 觸發時靜默（無變更 → NO_REPLY）

## 錯誤處理

| 錯誤 | 處理 |
|------|------|
| Vault 目錄不存在 | 回報 ❌，停止 |
| git 未初始化 | 回報 ❌，提示 `git init` |
| 腳本不存在 | 回報 ❌，提示路徑確認 |

## 安全等級

🟢 green — 只在本機寫 git commit，不 push，不對外

## 參考文件

- 腳本本體：`scripts/main.sh`
- Vault 路徑：`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault`
