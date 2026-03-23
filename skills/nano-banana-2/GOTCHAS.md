# GOTCHAS.md — nano-banana-2

> 格式：每條 = **錯誤描述** / **正確做法** / **觸發情境**

---

## G1: Imagen 4 quota 歸零不是 rate limit，是永久額度清零

**錯誤**：生圖失敗後以為是暫時性 rate limit，等一下再試，或一直重試造成浪費。
**正確**：Imagen 4 API quota 已永久清零（非暫時性）。系統改走 Nano Banana 系列（Gemini Image）。收到 quota 錯誤立刻切換，不重試 Imagen 4。Fallback 鏈：Nano Banana Pro → Nano Banana 2 → DALL-E 3。
**觸發情境**：呼叫 `imagen-gen.py` 或 `image-gen.sh` 時看到 quota 0 / 403 錯誤。

---

## G2: Gemini API Key 讀取來源錯誤導致靜默 fallback 到 DALL-E 3

**錯誤**：腳本從 `skills.entries.google-image-gen.apiKey` 讀 key，但 key 實際放在 `env.GEMINI_API_KEY`，導致 Nano Banana 靜默失敗，一直用 DALL-E 3，使用者不知道。
**正確**：`imagen-gen.py` v2.0 已修正，優先讀 `env.GEMINI_API_KEY`。確認環境變數已設定：`echo $GEMINI_API_KEY`。若為空則查 `openclaw.json` 的 env 區塊。
**觸發情境**：更新設定或新機器部署後第一次生圖。

---

## G3: google-genai 套件未安裝導致靜默失敗

**錯誤**：系統 python3 沒有 `google-genai` 套件，import 靜默失敗，直接 fallback 到 DALL-E 3，沒有任何錯誤訊息。
**正確**：使用 `uv run --with google-genai python3 imagen-gen.py`，確保套件可用。不要直接 `python3 imagen-gen.py`。
**觸發情境**：新環境首次執行、或 uv 環境被清理後。

---

## G4: Nano Banana 2 vs Pro 的選用場景混淆

**錯誤**：所有生圖任務都用 Nano Banana 2（Flash），導致高品質輸出時畫質不符需求。
**正確**：Nano Banana 2（Flash）適合快速迭代、草稿確認、低優先級生圖。需要高品質輸出（Frame TV 展示、正式交付圖）改用 Nano Banana Pro。Fallback 才降級到 Nano Banana 2。
**觸發情境**：Frame TV 展示圖、正式對外的圖片交付場景。
