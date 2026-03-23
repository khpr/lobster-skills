# 生圖引擎迭代 v2.0

**日期**: 2026-03-19
**類型**: 能力迭代（引擎替換）
**影響範圍**: image-gen.sh, imagen-gen.py, nano-banana-pro skill, nano-banana-2 skill

---

## 變更摘要

生圖引擎從 Imagen 4 系列遷移至 Nano Banana（Gemini Image）系列。

## 原因

Google Imagen 4 的三個 model（Generate / Ultra / Fast）API quota 歸零，無法再使用。不是暫時性 rate limit，是額度永久清零。

## 變更前（v1.0）

| 引擎 | Model ID | 狀態 |
|------|----------|------|
| Imagen 4 Generate | imagen-4.0-generate-001 | ❌ quota 0 |
| Imagen 4 Ultra | imagen-4.0-ultra-generate-001 | ❌ quota 0 |
| Imagen 4 Fast | imagen-4.0-fast-generate-001 | ❌ quota 0 |
| DALL-E 3 | dall-e-3 | ✅ fallback |

## 變更後（v2.0）

| 引擎 | Model ID | 用途 | 狀態 |
|------|----------|------|------|
| Nano Banana Pro | gemini-3-pro-image-preview | 高品質生圖、編輯、多圖合成 | ✅ 主力 |
| Nano Banana 2 | gemini-3.1-flash-image-preview | 快速迭代、草稿 | ✅ 次選 |
| DALL-E 3 | dall-e-3 | 最終 fallback | ✅ 備援 |

## Fallback 鏈

image-gen.sh: Nano Banana Pro → Nano Banana 2 → DALL-E 3
imagen-gen.py --fast: Nano Banana 2
imagen-gen.py --ultra: Nano Banana Pro + 4K 解析度

## 修復的附帶問題

1. **Key 來源混亂**: openclaw.json 有兩處放 Gemini key（env.GEMINI_API_KEY 和 skills.entries.google-image-gen.apiKey），腳本之前只讀後者。改為優先讀 env 區塊。
2. **套件缺失**: 系統 python3 沒裝 google-genai，import 靜默失敗一直 fallback 到 DALL-E 3。改用 `uv run --with google-genai python3`。

## 受影響的檔案

- `~/.openclaw/workspace/scripts/image-gen.sh` → v2.0
- `~/.openclaw/workspace/scripts/imagen-gen.py` → v2.0
- `~/.openclaw/skills/nano-banana-2/` → 新建 skill（Flash Image 引擎）
- `~/.openclaw/skills/nano-banana-pro/` → 無變更，原本就存在
- CAPABILITY-MATRIX.md → 更新引擎優先序
- CAPABILITY-CHANGELOG.md → 已記錄

## 未驗證

- Nano Banana 系列目前 API key 處於 rate limit 中，腳本能跑但尚未實測生圖成功
- 等額度恢復後需跑一次端到端測試
