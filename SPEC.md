# COLLAB-SPEC-001 — Skill 標準規格書

> 版本：1.0 | 建立：2026-03-22 | 維護：Opus + 龍蝦

本規格書定義龍蝦系統所有自建 Skill 的結構、品質標準、安裝流程、跨機器同步機制。

---

## A1. 目錄結構規範

```
skill-name/
├── SKILL.md          # 必要。YAML frontmatter + markdown 指令
├── scripts/          # 選用。可執行腳本（bash/python）
│   └── main.sh       # 主要腳本（如有）
├── references/       # 選用。補充文件，agent 按需讀取
│   └── api-notes.md
├── assets/           # 選用。模板、圖片等靜態資源
├── tests/            # 選用。測試用 prompt + 預期結果
│   └── test-prompts.md
└── CHANGELOG.md      # 選用。版本變更記錄
```

硬性規則：
- 每個 skill 是一個獨立資料夾，資料夾名 = skill 名（kebab-case）
- SKILL.md 是唯一必要檔案
- 腳本放 `scripts/`，不放根目錄
- 不在 skill 目錄內存放 API key、token、密碼等敏感資料
- 所有腳本必須 bash 3.2 相容（macOS 內建版本）

---

## A2. SKILL.md 模板

```yaml
---
name: skill-name
description: >
  一句話說明這個 skill 做什麼 + 什麼情境該觸發。
  要「稍微 pushy」——列出所有該觸發的關鍵詞和情境，
  寧可多觸發也不要漏觸發。
  控制在 80-150 字（中英混合）。
requires:
  bins:       # 選用。需要哪些 CLI 工具才能跑
    - jq
    - curl
  env:        # 選用。需要哪些環境變數
    - GITHUB_TOKEN
  config:     # 選用。需要 openclaw.json 裡的哪些設定
    - line.channelAccessToken
owner: dema|xiaxia|shared   # 誰維護。shared = 兩邊共用
complexity: S|M|L           # 估計複雜度
version: "1.0"
created: "2026-03-22"
---
```

```markdown
# skill-name

## 概述

一段話說明 skill 的目的和使用場景。

## 前置條件

列出需要的工具、權限、環境變數。
如果都在 frontmatter 的 requires 裡了，這段可以只寫「見 frontmatter」。

## 流程

agent 收到匹配的請求後，照以下步驟操作：

### Step 1：[步驟名]

具體指令。如果要跑腳本：

```bash
bash scripts/main.sh [參數]
```

### Step 2：[步驟名]

...

## 輸出規範

定義 agent 回覆使用者的格式。
包含：用什麼 directive（`[[buttons:]]`、`[[quick_replies:]]`）、
走 Reply 還是 Push、輸出語言和語氣。

## 錯誤處理

列出常見錯誤和對應動作。
範例：「scripts/main.sh 回傳非 0 → 推一則錯誤訊息到 LINE，不要重試」

## 安全等級

green / yellow / red
- green：無副作用，直接執行
- yellow：有副作用但可逆，需推確認訊息
- red：不可逆操作，必須跑 gate-confirm.sh

## 參考文件

如果 references/ 裡有補充文件，列出路徑和讀取時機：
- `references/api-notes.md`：當需要查 API 限制時讀取
```

---

## A3. Description 品質標準（Thariq 四標準 + WO-034 模板）

| 標準 | 要求 |
|------|------|
| 觸發描述清楚 | 列出所有該觸發的動詞、名詞、情境。寧可 pushy 不要 miss |
| 避免過度 railroading | 不要在 description 裡寫死流程，流程寫在 body |
| 狀態管理 | 需要跨 turn 狀態時用檔案/log，不依賴 session context |
| 範例/腳本同目錄 | 所有相關檔案放在 skill 資料夾內，不散落在其他位置 |

**Description 自測法：**
在 LINE 上對龍蝦說一句你認為該觸發這個 skill 的話，觀察是否觸發。
連續 3 次不同說法都觸發 = 通過。有 1 次不觸發 = 需改 description。

---

## A4. install.sh 標準化

`lobster-skills` repo 根目錄的 `install.sh` 需支援以下操作：

```bash
# 安裝（symlink 到 managed skills）
./install.sh install <skill-name>

# 卸載（移除 symlink）
./install.sh uninstall <skill-name>

# 更新（git pull 後重新 link）
./install.sh update <skill-name>

# 列出所有可安裝的 skill
./install.sh list

# 列出目前已安裝的 skill
./install.sh status
```

安裝機制：

```bash
# install 實際做的事：
ln -sf ~/lobster-skills/skills/<skill-name> ~/.openclaw/skills/<skill-name>

# uninstall 實際做的事：
rm ~/.openclaw/skills/<skill-name>   # 只刪 symlink，不刪原檔
```

為什麼用 symlink：
- git pull 後自動生效，不需要重新 install
- 原始碼集中在 repo，不散落在 ~/.openclaw/skills/
- uninstall 只刪 link，不影響 repo 裡的檔案

安裝後生效：
- OpenClaw Gateway 下一個 session 自動掃描到新 skill
- 不需要 `gateway restart`（新 session 自動 snapshot）
- 如果要立即生效：等 session 自然結束（compaction 或 idle timeout）或用 `openclaw sessions cleanup --agent lobster`

---

## A5. 跨機器同步機制

```
lobster-skills repo (GitHub private)
├── SPEC.md（本文件）
├── install.sh
├── skills/
│   ├── dispatch-tracker/       ← shared
│   ├── vault-git-sync/         ← shared
│   ├── skill-maintenance/      ← shared
│   ├── frame-daily-art/        ← dema only
│   ├── voice-session/          ← dema only
│   ├── wp-builder/             ← dema only
│   ├── line-channel-config-check/ ← xiaxia only
│   ├── memory-handoff-sync/    ← xiaxia only
│   └── dispatch-rules-curator/ ← xiaxia only
└── README.md
```

```
德瑪                              小蝦
~/lobster-skills/  ←── git pull ──→  ~/lobster-skills/
       │                                      │
./install.sh install dispatch-tracker   ./install.sh install dispatch-tracker
       │                                      │
~/.openclaw/skills/dispatch-tracker  ~/.openclaw/skills/dispatch-tracker
        (symlink)                              (symlink)
```

同步流程：
1. 建立方在本機開發、測試、push 到 repo
2. 另一邊 git pull
3. 看到新 skill → 決定要不要 `./install.sh install <name>`
4. 不認領就不裝，repo 裡有但不 install = 不會被 Gateway 載入

owner 標記：
- SKILL.md frontmatter 的 `owner` 欄位標明誰維護
- `shared`：兩邊都裝、都可改（改完 push，另一邊 pull）
- `dema` / `xiaxia`：只有該機器需要裝，另一邊 pull 到但不 install

---

## A6. 現有 Skill 遷移

德瑪目前的 3 個 managed skill（line-behavior、line-output、triad-tools）：
- `triad-tools`：已在 repo，已有 frontmatter ✅
- `line-behavior`：無 frontmatter，需補 YAML header 後推到 repo
- `line-output`：無 frontmatter，需補 YAML header 後推到 repo

遷移不在 WO-037 範圍內。
先建新的，舊的之後另開工單統一遷移。
