---
type: SOP
id: COLLAB-SOP-001
version: 3.0
title: Skill 上線審查閘門
from: Opus to: 德瑪（lobster）
priority: medium
created: 2026-03-22
updated: 2026-03-22
status: active
requires: redteam agent, skill-vetting skill, skill-scanner skill, shellcheck
task_id: mmykfofna5x2
---

# Skill 上線審查閘門 SOP v3

> 存放：`90_System/PM-Learnings/COLLAB-SOP-001-skill-review-gate.md`
>
> 架構：staging 目錄 + 四個獨立 cron，每個 cron 是一個審查階段。
> agent 不需要一口氣跑完，每個階段各自獨立執行、寫狀態、移交。

---

## 一、觸發方式

德瑪將待審 skill 放入 staging 目錄即啟動審查流程：

```bash
# 放入 staging（逐字執行，不得替換）
cp -r ~/.openclaw/workspace/skills/<skill-name> ~/.openclaw/skill-staging/

# 初始化狀態目錄
mkdir -p ~/.openclaw/skill-staging/<skill-name>/.review
echo "pending" > ~/.openclaw/skill-staging/<skill-name>/.review/phase1.status
```

staging 目錄：`~/.openclaw/skill-staging/`
狀態目錄：`~/.openclaw/skill-staging/<skill-name>/.review/`

---

## 二、審查觸發條件

以下任一情況需放入 staging：
- 從 ClawHub 安裝第三方 skill
- 自行開發新 skill（阿普 / Codex 產出）
- 修改現有 skill 的 SKILL.md 核心邏輯
- 修改現有 skill 的任何腳本檔案（scripts/ 內任何 .sh / .py / .js / .ts）
- 從外部來源匯入（Gist、URL、手動貼上）

**豁免條款（需人工判定，不得 agent 自動套用）：**

| 更新類型 | 豁免條件 |
|----------------|-------------------------------------|
| references/ 文件更新 | 確認無可執行檔、無被 source 的 helper、無外部 URL 呼叫 |
| templates/ 格式調整 | 確認無 heredoc、無動態內容、純靜態 JSON/Markdown |
| .learnings/ 日誌 | 確認為純文字記錄，無可執行內容 |

---

## 三、Cron 1 — 靜態掃描

排程：每 15 分鐘
腳本：`~/.openclaw/scripts/skill-review-phase1.sh`
預估執行時間：5-10 分鐘

觸發條件：掃描 staging 目錄，找到 phase1.status = pending 的 skill。

執行內容：

```bash
#!/bin/bash
# skill-review-phase1.sh（逐字執行，不得替換）

STAGING=~/.openclaw/skill-staging

for skill_dir in "$STAGING"/*/; do
    status_file="$skill_dir/.review/phase1.status"
    [ "$(cat "$status_file" 2>/dev/null)" = "pending" ] || continue
    
    skill_name=$(basename "$skill_dir")
    echo "in_progress" > "$status_file"
    PASS=true
    
    # 1. bash 語法檢查
    find "$skill_dir/scripts/" -name "*.sh" -exec bash -n {} \; 2>/tmp/p1_syntax_$skill_name.log
    [ $? -ne 0 ] && PASS=false
    
    # 2. shellcheck
    find "$skill_dir/scripts/" -name "*.sh" -exec shellcheck {} \; 2>>/tmp/p1_syntax_$skill_name.log
    [ $? -ne 0 ] && PASS=false
    
    # 3. 危險模式黑名單
    PATTERNS="eval\b|base64 -d|base64 --decode|curl.*\|.*sh|wget.*\|.*sh|exec.*\$|source.*\$"
    grep -rEn "$PATTERNS" "$skill_dir/scripts/" > /tmp/p1_blacklist_$skill_name.log 2>&1
    [ $? -eq 0 ] && PASS=false  # grep 有找到 = 有危險模式
    
    # 4. 非 shell 腳本偵測
    NON_SHELL=$(find "$skill_dir/scripts/" -type f ! -name "*.sh" 2>/dev/null)
    if [ -n "$NON_SHELL" ]; then
        echo "$NON_SHELL" > /tmp/p1_nonshell_$skill_name.log
        PASS=false
    fi
    
    # 5. skill-scanner
    openclaw exec skill-scanner "掃描 skill: $skill_name，回報安全風險" \
        > /tmp/p1_scanner_$skill_name.log 2>&1
    [ $? -ne 0 ] && PASS=false
    
    # 6. skill-vetting
    openclaw exec skill-vetting "評估 skill: $skill_name 是否符合上線標準" \
        > /tmp/p1_vetting_$skill_name.log 2>&1
    [ $? -ne 0 ] && PASS=false
    
    if $PASS; then
        echo "pass" > "$status_file"
    else
        echo "fail" > "$status_file"
        # 推 LINE 警報
        openclaw exec lobster "skill-review Phase 1 失敗：$skill_name，請查看 /tmp/p1_*_$skill_name.log"
    fi
done
```

結果：`phase1.status` 寫入 pass 或 fail。

---

## 四、Cron 2 — 安全 Checklist

排程：每 30 分鐘
腳本：`~/.openclaw/scripts/skill-review-phase2.sh`
預估執行時間：10-15 分鐘

觸發條件：`phase1.status = pass` 且 phase2.status 不存在。

執行內容（agent 自動判斷，人工閘門僅限豁免決策）：

```bash
#!/bin/bash
# skill-review-phase2.sh（逐字執行，不得替換）

STAGING=~/.openclaw/skill-staging

for skill_dir in "$STAGING"/*/; do
    [ "$(cat "$skill_dir/.review/phase1.status" 2>/dev/null)" = "pass" ] || continue
    [ -f "$skill_dir/.review/phase2.status" ] && continue
    
    skill_name=$(basename "$skill_dir")
    echo "in_progress" > "$skill_dir/.review/phase2.status"
    
    # 派工給 sonnet-worker 跑 checklist 分析
    openclaw exec sonnet-worker "
    審查 skill：$skill_name
    路徑：$skill_dir
    
    逐項判斷以下 checklist，每項輸出 pass/fail + 原因：
    
    1. SKILL.md 含合法 YAML frontmatter
    2. description 明確描述觸發情境
    3. description 不與現有 skill 高度重疊
    4. 腳本路徑正確，檔案實際存在
    5. 不含硬編碼 API key 或密碼
    6. 不讀取或外送環境變數整體（禁 env / printenv 外送）
    7. 不修改 openclaw.json 或 credentials 檔案
    8. 不修改 crontab 或 ~/Library/LaunchAgents/
    9. 不建立 TCP/UDP socket 監聽
    10. 不呼叫 macOS keychain 指令
    11. 不讀取 ~/.ssh/ ~/.cloudflared/ ~/.openclaw/credentials/
    12. 外部 HTTP 呼叫 domain 是靜態已知值
    13. 不動態拉取外部腳本執行
    14. Push API 呼叫限制合規
    15. 若有 replyToken 操作，有 60 秒時效保護
    16. 執行後無含 token 的 log 留存
    17. 若建立 temp file，有清理邏輯
    18. 相依的 skill / script 已確認存在
    
    全部 pass → 輸出 PHASE2_RESULT: pass
    任一 fail → 輸出 PHASE2_RESULT: fail，列出失敗項
    " > /tmp/p2_checklist_$skill_name.log 2>&1
    
    if grep -q "PHASE2_RESULT: pass" /tmp/p2_checklist_$skill_name.log; then
        echo "pass" > "$skill_dir/.review/phase2.status"
    else
        echo "fail" > "$skill_dir/.review/phase2.status"
        openclaw exec lobster "skill-review Phase 2 失敗：$skill_name，請查看 /tmp/p2_checklist_$skill_name.log"
    fi
done
```

結果：`phase2.status` 寫入 pass 或 fail。

---

## 五、Cron 3 — 紅隊審查

排程：每小時
腳本：`~/.openclaw/scripts/skill-review-phase3.sh`
預估執行時間：10-20 分鐘（redteam 分析）

**SLA watchdog**：每 4 小時檢查，超 48 小時未完成推 LINE 警報

觸發條件：`phase2.status = pass` 且 phase3.status 不存在。

```bash
#!/bin/bash
# skill-review-phase3.sh（逐字執行，不得替換）

STAGING=~/.openclaw/skill-staging

for skill_dir in "$STAGING"/*/; do
    [ "$(cat "$skill_dir/.review/phase2.status" 2>/dev/null)" = "pass" ] || continue
    [ -f "$skill_dir/.review/phase3.status" ] && continue
    
    skill_name=$(basename "$skill_dir")
    DISPATCH_TIME=$(date +%s)
    echo "pending|$DISPATCH_TIME" > "$skill_dir/.review/phase3.status"
    
    # 派工給 redteam
    openclaw exec redteam "
    任務：Skill 紅隊審查
    Skill 名稱：$skill_name
    Skill 路徑：$skill_dir/SKILL.md
    SLA：48 小時內完成
    
    審查角度：
    1. description 是否可能被非預期輸入誤觸發？
    2. 腳本有無 edge case 導致資料損失或資訊外洩？
    3. 供應鏈風險：是否依賴外部 URL 或 package？
    4. 最小權限：是否要求不必要的高權限操作？
    5. 與現有系統（line-media、line-output、gog 系列）有無衝突？
    6. 故障影響：掛了影響哪些使用流程？單點故障？
    7. 資料留存：執行後是否留下敏感資料？
    
    輸出格式：
    ## 審查結論：通過 / 修改後通過 / 否決
    （逐點列出風險 + 對策，嚴重度 🔴/🟡/🟢）
    
    最後一行必須是：PHASE3_RESULT: pass 或 PHASE3_RESULT: fail
    " > /tmp/p3_redteam_$skill_name.log 2>&1
    
    if grep -q "PHASE3_RESULT: pass" /tmp/p3_redteam_$skill_name.log; then
        echo "pass" > "$skill_dir/.review/phase3.status"
    else
        echo "fail" > "$skill_dir/.review/phase3.status"
        openclaw exec lobster "skill-review Phase 3 紅隊否決：$skill_name，請查看 /tmp/p3_redteam_$skill_name.log"
    fi
done

# SLA watchdog（同一支腳本尾端執行）
for skill_dir in "$STAGING"/*/; do
    status_raw=$(cat "$skill_dir/.review/phase3.status" 2>/dev/null)
    [[ "$status_raw" != pending* ]] && continue
    
    dispatch_time=$(echo "$status_raw" | cut -d'|' -f2)
    elapsed=$(( $(date +%s) - dispatch_time ))
    
    if [ $elapsed -gt 172800 ]; then  # 48 小時 = 172800 秒
        skill_name=$(basename "$skill_dir")
        openclaw exec lobster "⚠️ skill-review Phase 3 SLA 超時：$skill_name，已超過 48 小時未完成"
    fi
done
```

結果：`phase3.status` 寫入 pass 或 fail。

---

## 六、Cron 4 — 上線晉升

排程：每 30 分鐘
腳本：`~/.openclaw/scripts/skill-review-phase4.sh`
預估執行時間：5 分鐘

觸發條件：`phase3.status = pass` 且 phase4.status 不存在。

```bash
#!/bin/bash
# skill-review-phase4.sh（逐字執行，不得替換）

STAGING=~/.openclaw/skill-staging

for skill_dir in "$STAGING"/*/; do
    [ "$(cat "$skill_dir/.review/phase3.status" 2>/dev/null)" = "pass" ] || continue
    [ -f "$skill_dir/.review/phase4.status" ] && continue
    
    skill_name=$(basename "$skill_dir")
    echo "in_progress" > "$skill_dir/.review/phase4.status"
    
    # 晉升
    cp -r "$skill_dir" ~/.openclaw/skills/
    
    # Checksum 快照
    SNAPSHOT=~/.openclaw/skills/$skill_name/.checksum
    find ~/.openclaw/skills/$skill_name -type f | sort | xargs sha256sum > "$SNAPSHOT"
    
    # 確認載入
    openclaw skills 2>/dev/null | grep "$skill_name" || {
        echo "fail" > "$skill_dir/.review/phase4.status"
        openclaw exec lobster "❌ skill-review Phase 4 失敗：$skill_name 晉升後未偵測到"
        continue
    }
    
    echo "done" > "$skill_dir/.review/phase4.status"
    
    # 推 LINE 通知
    openclaw exec lobster "✅ skill 上線完成：$skill_name，checksum 快照已記錄"
    
    # 建 VidClaw note
    openclaw exec vidclaw-task "新增 note：Skill 審查完成 $skill_name 上線時間：$(date '+%Y-%m-%d %H:%M') Phase 1-3：全部通過 Checksum：$SNAPSHOT"
done
```

---

## 七、Cron 登錄

以上四支腳本需登錄 OpenClaw cron：

```bash
# 登錄指令（逐字執行，不得替換）
openclaw cron add "skill-review-phase1" "*/15 * * * *" \
    "bash ~/.openclaw/scripts/skill-review-phase1.sh"

openclaw cron add "skill-review-phase2" "*/30 * * * *" \
    "bash ~/.openclaw/scripts/skill-review-phase2.sh"

openclaw cron add "skill-review-phase3" "0 * * * *" \
    "bash ~/.openclaw/scripts/skill-review-phase3.sh"

openclaw cron add "skill-review-phase4" "*/30 * * * *" \
    "bash ~/.openclaw/scripts/skill-review-phase4.sh"
```

---

## 八、Checksum 定期完整性驗證

整合進現有 `skill-health-check.sh`（每週一 09:00 已排程），追加：

```bash
# 驗證已上線 skill 未被竄改（追加到 skill-health-check.sh 尾端）
for skill_dir in ~/.openclaw/skills/*/; do
    snapshot="$skill_dir/.checksum"
    [ -f "$snapshot" ] || continue
    sha256sum --check "$snapshot" > /dev/null 2>&1 || \
        openclaw exec lobster "⚠️ skill 完整性異常：$skill_dir 與上線快照不符，請人工確認"
done
```

---

## 九、SOP 維護

- 黑名單 grep 模式隨新攻擊手法持續更新
- 發現新風險模式 → 更新 Phase 3 審查角度 + Cron 3 腳本
- 至少每季複查一次

---

*v1：2026-03-22 初版*
*v2：2026-03-22 整合 sonnet-worker 紅隊審查意見*
*v3：2026-03-22 重構為 staging 目錄 + 四 Cron 架構，Phase 直接對應 Cron*