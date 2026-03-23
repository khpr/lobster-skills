# Obsidian Note Template

## File Path
`/Users/Modema11434/Documents/Obsidian Vault/_inbox/YYYY-MM-DD-正規化標題.md`

## Frontmatter Template

```yaml
---
source: threads
platform: Threads
url: https://www.threads.com/@user/post/xxx
author: "@username"
date: 2026-03-04
captured: 2026-03-04T05:00:00+08:00
interactions:
  likes: 66
  comments: 11
  shares: 26
tags:
  - AI生成tag1
  - AI生成tag2
  - AI生成tag3
status: inbox
---
```

## Body Template

```markdown
## 摘要

（約 500 字完整摘要，涵蓋主要論點、背景脈絡、關鍵細節）

## 留言精華

（社群平台才有，挑選最有代表性的 3-5 則）

- **留言者A**（讚數）：內容摘要
- **留言者B**（讚數）：內容摘要

## 圖片描述

（如有圖片，用 image 工具分析後記錄）

- [1] 描述...

## 原文

（完整原文貼在這裡，保留原始格式）
```

## Tag 生成規則

AI 自動生成 3 個語意 tag：
1. 主題分類（如：AI工具、感情、科技、投資）
2. 內容性質（如：教學、心得、討論、新聞）
3. 具體關鍵字（如：OpenClaw、免費模型、Dcard熱門）

Tag 用繁體中文，不加 # 前綴（Obsidian frontmatter tags 不需要）

## 正規化標題規則

- 繁體中文
- 去除標點符號和特殊字元
- 適合 AI 索引和搜尋
- 長度 10-30 字
- 格式：核心主題-補充描述
- 範例：「OpenClaw新手第34天免費模型配置攻略」
