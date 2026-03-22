# COLLAB-SPEC-001 — Skill 標準規格書（lobster-skills）

建立：2026-03-22
適用範圍：本 repo 內所有自建 skills。

> 目的：定義龍蝦系統所有自建 Skill 的結構、品質標準、安裝流程、跨機器同步機制。

---

## A1. 目錄結構規範

```
skill-name/
├── SKILL.md          # 必要。YAML frontmatter + markdown 指令
├── scripts/          # 選用。可執行腳本（bash/python）
│   └── main.sh
├── references/       # 選用。補充文件，agent 按需讀取
│   └── api-notes.md
├── assets/           # 選用。模板、圖片等靜態資源
├── tests/            # 選用。測試用 prompt + 預期結果
│   └── test-prompts.md
└── CHANGELOG.md      # 選用。版本變更記錄
```

硬性規則：
- 每個 skill 是一個獨立資料夾，資料夾名 = skill 名（kebab-case）
- `SKILL.md` 是唯一必要檔案
- 腳本放 `scripts/`，不放根目錄
- **不在 skill 目錄內存放 API key、token、密碼等敏感資料**
- 所有 bash 腳本需 **bash 3.2 相容**（macOS 內建）

---

## A2. SKILL.md 模板（推薦）

注意：OpenClaw 核心觸發主要依賴 frontmatter 的 `name` + `description`。
其它欄位可保留作為內部治理/檢查用，但不保證被引擎解析。

```yaml
---
name: skill-name
description: >
  一句話說明這個 skill 做什麼 + 什麼情境該觸發。
  要稍微 pushy：列出所有該觸發的關鍵詞和情境，寧可多觸發也不要漏。
  控制在 80-150 字（中英混合）。
requires:
  bins: []     # 選用，例如: [jq, curl]
  env: []      # 選用，例如: [GITHUB_TOKEN]
  config: []   # 選用，例如: [line.channelAccessToken]
owner: shared  # dema|xiaxia|shared
complexity: M  # S|M|L
version: "1.0"
created: "2026-03-22"
---
```

Body 建議章節：
- 概述
- 前置條件
- 流程（Step 1/2/3…）
- 輸出規範
- 錯誤處理
- 安全等級（green/yellow/red）
- 參考文件（references/ 的讀取時機）

---

## A3. Description 品質標準

- 觸發描述清楚：列出動詞、名詞、情境；寧可 pushy 不要 miss
- 避免過度 railroading：流程寫在 body，不寫死在 description
- 狀態管理：跨 turn 狀態用檔案/log，不依賴 session context
- 同目錄原則：相關腳本/參考都在同 skill 資料夾內（不散落）

自測：用三種不同說法在聊天中觸發；3/3 命中才算通過。

---

## A4. install.sh 標準化（symlink-based）

本 repo 根目錄 `install.sh` 必須支援：

```bash
./install.sh list
./install.sh status
./install.sh install <skill-name>
./install.sh uninstall <skill-name>
./install.sh update <skill-name>
```

安裝機制：
- `install`：`ln -sf <repo>/skills/<skill-name> ~/.openclaw/skills/<skill-name>`
- `uninstall`：只刪除 symlink（不刪 repo 原始碼）

為什麼用 symlink：
- git pull 後自動生效，不需要重新 install
- 原始碼集中在 repo，不散落在 ~/.openclaw/skills/

---

## A5. 跨機器同步機制（建議）

- **技能同步**：以 `lobster-skills` repo 為單一真相；每台機器 `git pull` 後用 `install.sh status/update` 對齊。
- **共享狀態檔**（例如 gist-publisher 的 map）：用「中央資源」同步（Gist/Drive）而不是各機器各一份。
