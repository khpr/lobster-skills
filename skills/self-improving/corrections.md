# Corrections Log
# 上限 20 條。超過時收割：行為規則晉升 AGENTS.md/CONDUCT.md，一次性 bug 刪除。

---

## 行為規則（長期有效）

### 先讀 SKILL.md 再動手（2026-03-20）
- 有對應 skill 就先讀 SKILL.md，按流程走，不自己拼裝腳本
- 「知道工具在哪」≠「知道完整流程」

### Flex Message 用 Push API 發送（2026-03-20）
- `[[flex:]]` 指令不可靠，會被當純文字送出
- 用 curl 打 LINE Push API：`POST https://api.line.me/v2/bot/message/push`
- Push 扣月額度（200則/月），reply token 過期時才用

---

## 一次性修復（修完可刪）

（目前無）
