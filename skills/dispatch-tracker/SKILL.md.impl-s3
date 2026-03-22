---
name: dispatch-tracker
description: >
  Track sub-tasks / dispatch items with a minimal lifecycle (add/done/list/show). Use when the user says 追蹤派工/派工清單/新增任務/任務完成/查看任務，或需要把零散的子任務收斂成可查詢清單。
owner: shared
complexity: S
version: "0.1"
created: "2026-03-22"
---

# dispatch-tracker

## 概述
用最小資料結構記錄派工/子任務，避免每個 turn 人工整理。

## 流程
- 新增： → 回傳 id
- 完成：
- 列表：
- 詳情：

## 輸出規範
- 回覆以純文字為主：
  - add：回傳 id + text
  - list：每行一筆 

## 錯誤處理
- 缺參數：回 usage（exit 2）
- id 找不到：exit 1

## 安全等級
green（本機寫入 tasks/dispatch-tracker.json，可逆）
