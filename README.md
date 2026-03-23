# lobster-skills

龍蝦系統 OpenClaw Skill 庫。

## 安裝

```bash
git clone https://github.com/khpr/lobster-skills.git
cd lobster-skills
./install.sh list
./install.sh install <skill-name>
./install.sh status
```

## 可用 Skill

| Skill | 說明 |
|-------|------|
| triad-tools | 三大金剛（Gemini CLI / Codex CLI / Claude Code）派工路由 |
| gist-publisher | 把 workspace 文件發布到 GitHub Gist |
| dispatch-tracker | 派工/任務追蹤簿（add/done/list/check） |
| vault-git-sync | Obsidian Vault git 同步（pull/commit，可選 push） |
| skill-maintenance | skills 目錄健檢（缺檔/欄位/權限等） |
| line-channel-config-check | LINE channel 健檢（區分誤報 vs 真故障） |
| memory-handoff-sync | BOOT 交接摘要 → daily 記憶（可選 promote 到 MEMORY） |

## 更新

```bash
git pull
./install.sh update <skill-name> # symlink 會指回 repo；pull 後通常不必做，但可用來修正狀態
./install.sh status
```
