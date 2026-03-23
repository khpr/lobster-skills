---
name: skill-maintenance
description: >
  技能庫健檢與整理：掃描 skills/ 目錄，抓出缺檔、frontmatter 不完整、版本欄位缺失、
  scripts 權限問題等常見地雷，輸出一份清單（可作為 PR 前的自動檢查）。
trigger_phrases:
  - skill 健檢
  - skills 健檢
  - 檢查技能
  - skill maintenance
requires:
  bins: [python3]
  env: [SKILLS_DIR]
owner: shared
complexity: M
version: "0.2"
created: "2026-03-22"
updated: "2026-03-23"
---

# skill-maintenance

## 這個技能能幹嘛（白話）

你丟給我一個 skills 資料夾（例如 `~/lobster-skills/skills`），我會幫你做「技能庫健康檢查」：

- 哪些 skill 沒有 `SKILL.md`
- `SKILL.md` 的 YAML frontmatter 缺欄位（name/description/version…）
- `scripts/*.sh` 沒有 executable 權限
- 技能資料夾結構不一致（該有 scripts 卻沒有、或引用不存在檔案）

它不會直接幫你大改，但會把「該修的點」列清楚。

## 使用方式
- `SKILLS_DIR=~/lobster-skills/skills bash scripts/main.sh`
- JSON 輸出：`bash scripts/main.sh --json`

## 安全等級
green（預設只讀取；不會自動修復）

## 相關檔案
- 腳本：`scripts/main.sh`
