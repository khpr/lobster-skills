# WO-037 Pipeline 執行指令

| 欄位 | 值 |
|------|------|
| id | COLLAB-WO-037 |
| title | Backlog 自動建置 Pipeline — 執行指令 |
| from | Opus |
| to | 龍蝦（德瑪） |
| created | 2026-03-22 |
| 存放位置 | ~/lobster-skills/docs/WO-037-pipeline.md |

---

## B0. 設計理念

- **Backlog 是輸入**：6 個認領的 skill 就是 6 個 story
- **Pipeline 是流程**：每個 story 跑完固定的 SDD 四階段才能推進下一個
- **Cron 是排程引擎**：定時喚醒，檢查 Backlog，推進下一步
- **Done flag 是狀態機**：檔案存在 = 完成，不存在 = 阻塞

SDD 四階段（每個 Skill 都要跑完）：

| 階段 | 名稱 | 做什麼 | 產出 |
|------|------|--------|------|
| S1 | Spec | 讀 SPEC.md + 候選說明，產出 SKILL.md 草稿 | skills/<n>/SKILL.md |
| S2 | Scaffold | 建目錄結構、寫腳本骨架、寫 install 測試 | `scripts/`、`tests/test-prompts.md` |
| S3 | Implement | 實作腳本內容、填充 SKILL.md 完整流程 | 完整可用的 skill |
| S4 | Verify | 跑 test-prompts、確認 Gateway 載入、觸發測試 | verify-report.json |

---

## B1. Backlog 定義

檔案位置：`~/.openclaw/workspace-lobster/data/wo037/backlog.json`

```json
{
  "wo": "037",
  "created": "2026-03-22",
  "spec_url": "~/lobster-skills/SPEC.md",
  "stories": [
    { "id": 1, "skill": "dispatch-tracker", "owner": "shared", "complexity": "S", "status": "pending",
      "source_note": "每個 turn 手動跑，最高頻率重複操作，封裝後省最多心力。兩邊都認領 #3。",
      "phases": { "s1": null, "s2": null, "s3": null, "s4": null } },
    { "id": 2, "skill": "vault-git-sync", "owner": "shared", "complexity": "S", "status": "pending",
      "source_note": "腳本已存在（vault-auto-commit.sh），只需包 skill。德瑪 #2 小蝦 #5。",
      "phases": { "s1": null, "s2": null, "s3": null, "s4": null } },
    { "id": 3, "skill": "skill-maintenance", "owner": "shared", "complexity": "M", "status": "pending",
      "source_note": "idle cron 補實作，讓每週一 cron 有實質內容。德瑪 #5 小蝦 #4。",
      "phases": { "s1": null, "s2": null, "s3": null, "s4": null } },
    { "id": 4, "skill": "frame-daily-art", "owner": "dema", "complexity": "M", "status": "pending",
      "source_note": "CAPABILITY-MATRIX 已標 error/timeout，最急，換 Nano Banana 引擎。德瑪 #1。",
      "phases": { "s1": null, "s2": null, "s3": null, "s4": null } },
    { "id": 5, "skill": "line-channel-config-check", "owner": "xiaxia", "complexity": "M", "status": "pending",
      "source_note": "openclaw status 顯示 LINE token WARN，需要檢查與修復 SOP skill 化。小蝦 #1。",
      "phases": { "s1": null, "s2": null, "s3": null, "s4": null } },
    { "id": 6, "skill": "memory-handoff-sync", "owner": "xiaxia", "complexity": "M", "status": "pending",
      "source_note": "重啟交接高頻且容易漏步，值得一鍵化。小蝦 #2。",
      "phases": { "s1": null, "s2": null, "s3": null, "s4": null } }
  ]
}
```

---

## B2. 輸送帶 Cron 邏輯

每次 cron 喚醒時，龍蝦讀此文件並執行以下流程：

1. 讀 backlog：`cat ~/.openclaw/workspace-lobster/data/wo037/backlog.json`
2. 找到第一個 status=pending 或 status=in_progress 的 story
3. 如果沒有（全部 done）→ 回覆「WO-037 Backlog 清空，全部完成」然後停止
4. 如果有，檢查它的 phases：
   - 找到第一個值為 null 的 phase（s1/s2/s3/s4）
   - 執行該 phase（見下方 B3 的 Phase 執行指令）
   - 完成後更新 backlog.json：把該 phase 的值從 null 改為完成時間戳（ISO 格式）
   - 如果是 s1 → 把 story 的 status 改為 "in_progress"
   - 如果是 s4 → 把 story 的 status 改為 "done"
   - 寫 done flag：`echo '{"phase":"<phase>","skill":"<skill>","ts":"<ISO>"}' > /tmp/wo037-<skill>-<phase>-done.json`
5. 推結果到 LINE（推完整內容，不要自己判斷一句話夠了）：
   ```
   WO-037 進度：<skill> 的 <phase> 已完成。
   下一個：<下一步是什麼>
   Backlog 狀態：<已完成數>/<總數>
   ```
6. 一次 cron 只做一個 phase。做完就停，等下次 cron 再推進下一個。

---

## B3. Phase 執行指令

### S1：Spec（產出 SKILL.md 草稿）

逐字執行，不得替換：

```
Phase S1 — Spec for <skill-name>

1. 讀規格書：
   cat ~/lobster-skills/SPEC.md

2. 讀 backlog 裡這個 story 的 source_note

3. 如果這個 skill 有現成腳本或舊版（source_note 會說），先讀它：
   - vault-git-sync → cat ~/路徑/vault-auto-commit.sh（如果存在）
   - dispatch-tracker → 看 AGENTS.md 裡目前手動跑的流程
   - 其他 → 按 source_note 提示找

4. 按 SPEC.md 的 A2 模板，產出 SKILL.md 草稿：
   mkdir -p ~/lobster-skills/skills/<skill-name>
   寫入 ~/lobster-skills/skills/<skill-name>/SKILL.md
   包含：完整 YAML frontmatter + 概述 + 流程骨架（Step 可以先寫 TODO）

5. 驗證 frontmatter 格式：
   head -20 ~/lobster-skills/skills/<skill-name>/SKILL.md
   確認有 name、description、owner、complexity、version、created

6. 備份：
   cp ~/lobster-skills/skills/<skill-name>/SKILL.md \
      ~/lobster-skills/skills/<skill-name>/SKILL.md.draft-s1
```

### S2：Scaffold（建目錄 + 腳本骨架）

逐字執行，不得替換：

```
Phase S2 — Scaffold for <skill-name>

1. 讀已完成的 SKILL.md：
   cat ~/lobster-skills/skills/<skill-name>/SKILL.md

2. 根據流程判斷需要哪些子目錄：
   - 有腳本需求 → mkdir -p ~/lobster-skills/skills/<skill-name>/scripts
   - 有參考文件 → mkdir -p ~/lobster-skills/skills/<skill-name>/references
   - 有靜態資源 → mkdir -p ~/lobster-skills/skills/<skill-name>/assets

3. 建腳本骨架（如需要）：
   寫入 scripts/main.sh（或依 skill 需求命名）
   包含：shebang、參數檢查、主要流程佔位（echo TODO）、錯誤處理框架
   chmod +x scripts/*.sh
   必須 bash 3.2 相容（不用 declare -A、不用 <<<）

4. 建測試 prompt：
   mkdir -p ~/lobster-skills/skills/<skill-name>/tests
   寫入 tests/test-prompts.md：
   至少 3 個測試 prompt（正常、邊界、錯誤情境各一）
   格式：
   ## Test 1：正常流程
   Prompt：  "用戶會說的話"
   預期：    agent 應該做什麼
   驗證：    怎麼確認成功

5. 輸出結構確認：
   find ~/lobster-skills/skills/<skill-name> -type f
```

### S3：Implement（實作）

逐字執行，不得替換：

```
Phase S3 — Implement for <skill-name>

1. 讀 SKILL.md 和腳本骨架：
   cat ~/lobster-skills/skills/<skill-name>/SKILL.md
   cat ~/lobster-skills/skills/<skill-name>/scripts/*.sh 2>/dev/null

2. 實作腳本內容：
   - 把所有 TODO 替換為實際邏輯
   - 所有寫檔用 cat >>（append），不用 edit
   - 錯誤時 exit 非 0 + 寫 stderr
   - 敏感資料從環境變數或 openclaw.json 讀，不硬編碼

3. 完善 SKILL.md：
   - 把 Step 裡的 TODO 替換為完整指令
   - 補充錯誤處理段落
   - 確認安全等級標記（green/yellow/red）
   - 確認輸出規範（用什麼 directive、走 Reply 還是 Push）

4. 語法檢查：
   bash -n ~/lobster-skills/skills/<skill-name>/scripts/*.sh 2>&1
   如果有語法錯誤 → 修復後重新檢查

5. 備份：
   cp ~/lobster-skills/skills/<skill-name>/SKILL.md \
      ~/lobster-skills/skills/<skill-name>/SKILL.md.impl-s3
```

### S4：Verify（驗證）

逐字執行，不得替換：

```
Phase S4 — Verify for <skill-name>

1. 安裝到 managed skills：
   cd ~/lobster-skills && ./install.sh install <skill-name>

2. 確認 symlink 建立：
   ls -la ~/.openclaw/skills/<skill-name>

3. 重置 session 讓 Gateway 重新掃描 skill：
   openclaw sessions cleanup --agent lobster

4. 等 30 秒讓 Gateway 建新 session

5. 讀測試 prompt：
   cat ~/lobster-skills/skills/<skill-name>/tests/test-prompts.md

6. 在 LINE 上逐個測試（手動，由人類或龍蝦自測）：
   - 對龍蝦說 Test 1 的 prompt
   - 觀察是否觸發該 skill
   - 記錄結果

7. 產出驗證報告：
   寫入 /tmp/wo037-<skill-name>-verify-report.json：
   {
     "skill": "<skill-name>",
     "test_count": 3,
     "pass": <通過數>,
     "fail": <失敗數>,
     "trigger_rate": "<觸發率>",
     "issues": ["<如有問題列出>"],
     "verdict": "pass|fail|partial"
   }

8. 如果 verdict = fail：
   - 不更新 backlog（phase 停在 s4 = null）
   - 推 LINE 訊息：「<skill> 驗證失敗：<原因>，等待人工介入」
   - 停止，不推進下一個 story

9. 如果 verdict = pass 或 partial：
   - git add + commit：
     cd ~/lobster-skills
     git add skills/<skill-name>/
     git commit -m "feat: add <skill-name> (WO-037)"
   - 不自動 push（等人類確認後手動 push）

10. 推完整結果到 LINE（推完整內容，不要截短）
```

---

## B4. 安全閘門

| 操作 | 安全等級 | 處理方式 |
|------|---------|---------|
| 建目錄、寫新檔 | green | 直接執行 |
| 修改 SKILL.md | yellow | 先備份再改 |
| install.sh install | yellow | 確認 symlink 目標正確 |
| sessions cleanup | yellow | 確認不在關鍵對話中 |
| git commit | yellow | 只 commit，不 push |
| git push | red | 停止，推 LINE 等人類手動 push |
| 任何涉及 openclaw.json | red | 停止，推 LINE 等人工確認 |

---

## B5. 錯誤處理

| 錯誤情境 | 處理方式 |
|---------|---------|
| backlog.json 不存在 | 推 LINE 錯誤，停止 cron |
| SPEC.md 不存在 | 推 LINE 錯誤，停止 cron |
| 前一個 phase 的 done flag 不存在但 backlog 顯示已完成 | 回退 backlog 狀態，重跑該 phase |
| 腳本語法錯誤（bash -n 失敗） | 留在 S3，推 LINE 錯誤，等下次 cron 重試（最多 3 次） |
| S4 驗證失敗 | 不推進，推 LINE 等人工介入 |
| 15 分鐘內 cron 重入（上一個還沒跑完） | 檢查 /tmp/wo037-running.lock，存在就跳過 |

Lock 機制：
```bash
# cron 開始時
if [ -f /tmp/wo037-running.lock ]; then exit 0; fi
echo $$ > /tmp/wo037-running.lock
# cron 結束時（包含錯誤退出）
rm -f /tmp/wo037-running.lock
```

---

## B6. 完成條件

當 backlog.json 的 6 個 story 全部 status: "done" 時：

1. 龍蝦推完整摘要到 LINE：
   - 每個 skill 的建立時間、驗證結果
   - `./install.sh status` 輸出
   - 總計花了幾個 cron cycle

2. 刪除 cron：
   ```bash
   openclaw cron rm --name "wo037-conveyor"
   ```

3. 清理：
   ```bash
   rm -f /tmp/wo037-*.json
   rm -f /tmp/wo037-running.lock
   ```

4. 開完工 Gist，URL 推給人類轉交 Opus 驗收

---

## B7. 人工介入點（只有這些）

| 時機 | 誰 | 做什麼 |
|------|-----|--------|
| 開始 | 人類 | 把此工單 URL 貼給龍蝦 |
| S4 驗證時 | 人類 | 在 LINE 上測試 skill 觸發（如龍蝦自測不夠） |
| S4 通過後 | 人類 | `cd ~/lobster-skills && git push` |
| 小蝦認領 shared skill | 人類/小蝦 | `cd ~/lobster-skills && git pull && ./install.sh install <n>` |
| 結案 | 人類 | 把完工 Gist URL 貼給 Opus |

---

*Opus 產出，2026-03-22*
*此文件由龍蝦寫入 ~/lobster-skills/docs/WO-037-pipeline.md 後，即為 cron 執行的唯一參照。*
