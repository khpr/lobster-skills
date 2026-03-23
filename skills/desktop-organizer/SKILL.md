---
name: desktop-organizer
description: 六大檔案區域整理腳本。自動分類 Desktop、GDrive、Downloads、iCloud、Obsidian Vault、.openclaw，保持檔案系統整潔。支援 dry-run 模式（預設）與 --execute 真正執行模式。
metadata: {"clawdbot":{"emoji":"🗂️","short-description":"桌面與六大區域自動整理，每日排程執行","author":"lobster","version":"1.0","task":"desktop-organizer-skill","created":"2026-03-05"}}
---

# Desktop Organizer

> 一鍵整理六大檔案區域，每日自動執行，日誌保留 7 天

---

## 使用方式

### Dry-run（預設，只列出會做什麼）

```bash
bash ~/.openclaw/workspace/scripts/desktop-organizer.sh
```

### 真正執行

```bash
bash ~/.openclaw/workspace/scripts/desktop-organizer.sh --execute
```

### Cron 設定（每天凌晨 3:30 自動執行）

```cron
30 3 * * * bash ~/.openclaw/workspace/scripts/desktop-organizer.sh --execute >> ~/.openclaw/workspace/var/logs/desktop-organizer-cron.log 2>&1
```

---

## 六大整理區域

### Zone 1：~/Desktop

| 類型 | 動作 |
|------|------|
| 圖片（jpg/png/gif/webp/heic 等） | 移到 `~/Desktop/圖片/` |
| 文件（pdf/doc/txt/md/csv 等） | 移到 `~/Desktop/文件/` |
| 影片（mp4/mov/mkv 等） | 移到 `~/Desktop/影片/` |
| 其他 | 移到 `~/Desktop/其他/` |
| 螢幕截圖（含 Screenshot/截圖）超過 2 天 | 移到 `~/.Trash/` |

### Zone 2：~/我的雲端硬碟

| 類型 | 動作 |
|------|------|
| 根目錄散落檔案 | 移到 `~/我的雲端硬碟/00_Inbox/` |

### Zone 3：~/Downloads

| 類型 | 動作 |
|------|------|
| 超過 3 天的檔案 | 移到 `~/Downloads/_older/` |
| 空資料夾 | 刪除（rmdir） |

### Zone 4：~/Library/Mobile Documents/（iCloud）

| 類型 | 動作 |
|------|------|
| `.DS_Store`、`Thumbs.db`、`._*` | 移到 `_trash/` |
| 超過 1 年（365 天）未修改 | 移到 `_trash/` |
| iCloud~md~obsidian（Obsidian） | **不動**（Zone 5 另外處理） |

### Zone 5：Obsidian Vault

路徑：`~/Library/Mobile Documents/iCloud~md~obsidian/Documents/Obsidian Vault/`

| 類型 | 動作 |
|------|------|
| 根目錄散落 `.md` 檔（非 README.md） | 移到 `00_Inbox/` |
| 根目錄非 `.md` 檔 | 移到 `90_System/attachments/` |
| `README.md` | 保留原位 |
| `.obsidian/` 設定資料夾 | **絕對不動** |

### Zone 6：~/.openclaw

| 類型 | 動作 |
|------|------|
| 根目錄 `*.bak*`、`*.backup*`、`*-old*` 超過 7 天 | 移到 `~/.Trash/` |
| `workspace/` 根目錄散落圖片（jpg/png/gif/webp） | 移到 `workspace/media/` |
| `workspace/media/` 超過 7 天 | 移到 `~/.Trash/` |
| `openclaw.json` | **絕對不動** |
| `workspace-*/memory/` | **絕對不動** |

---

## 日誌

| 項目 | 說明 |
|------|------|
| 路徑 | `~/.openclaw/workspace/var/logs/desktop-organizer-YYYY-MM-DD.log` |
| 格式 | `[時間戳] 動作 \| src=來源路徑 \| dst=目標路徑` |
| 保留期 | 7 天，自動清理 |

### 日誌動作代碼

| 代碼 | 說明 |
|------|------|
| `INFO` | 一般資訊（區域開始/結束） |
| `MOVE` | 實際移動（--execute 模式） |
| `DRY-RUN` | 模擬移動（dry-run 模式） |
| `SKIP` | 跳過（不符合條件） |

---

## 安全規則

- 所有「刪除」一律用 `mv` 到 `~/.Trash/`，**絕不使用 `rm`**
- 不動 `openclaw.json`
- 不動 `.git` 資料夾
- 不動 `node_modules`
- 不動 `workspace-*/memory/` 資料夾
- 不動 `.obsidian/` 設定資料夾
- 每個 Zone 獨立 try-catch，單一失敗不影響其他區域

---

## 相關檔案

| 路徑 | 說明 |
|------|------|
| `scripts/desktop-organizer.sh` | 主腳本 |
| `var/logs/desktop-organizer-YYYY-MM-DD.log` | 每日執行日誌 |
| `skills/desktop-organizer/SKILL.md` | 本文件 |
