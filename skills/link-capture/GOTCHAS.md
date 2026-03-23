# GOTCHAS.md — link-capture

> 格式：每條 = **錯誤描述** / **正確做法** / **觸發情境**

---

## G1: IG 不能用 curl OG tags 取代 Browser Relay

**錯誤**：認為 curl 抓 OG tags 就夠了，繞過 Browser Relay 節省時間。
**正確**：curl OG tags 只拿到 caption + 第一張圖，IG 輪播圖片中大量內容在後續圖片的圖片文字裡，全部遺失。IG 必須走 Browser Relay。
**觸發情境**：擷取 Instagram 帖文 URL，特別是含多張圖片的輪播貼文。

---

## G2: 不要自作聰明修改 SKILL.md 的設計決策

**錯誤**：看到「IG 走 Browser Relay」覺得多此一舉，直接改成 curl 方案。
**正確**：每個設計決策背後有原因。不理解意圖就別改，先讀 SKILL.md 了解為什麼這樣寫，再問使用者確認。
**觸發情境**：覺得現有方案「太複雜」想簡化的時候。

---

## G3: Vault 圖片路徑須用 Deliverables 不能用 91_Attachments

**錯誤**：擷取文章圖片後存到 `91_Attachments/` 再附在 Flex 訊息裡，LINE 讀不到圖片。
**正確**：LINE Flex Message 的圖片 URL 必須公開可存取。Vault `91_Attachments/` 有 Cloudflare Access 保護，外部讀不到。改存 `90_System/Deliverables/` 或 `93_Deliverables/`，URL 用 `https://vault.life-os.work/...`。
**觸發情境**：擷取文章後要在 Flex 卡片顯示縮圖的場景。

---

## G4: 產出必須落地 Vault 才算完成

**錯誤**：subagent status=done，但筆記只存在 session 記憶，沒有寫到 Vault。
**正確**：每次擷取完成後必須寫 Obsidian `_inbox/` 或 `00_Inbox/`。session 結束後未落地的產出會消失。交付前用 ls / find 確認檔案實際存在。
**觸發情境**：擷取長文章、社群貼文後，任務結案。

---

## G5: Threads / X / 非 IG 平台不需要 Browser Relay

**錯誤**：因為 IG 用 Browser Relay，就把所有平台都走 Browser Relay，造成不必要的延遲。
**正確**：Browser Relay 只用於需要 JS 渲染或有防爬限制的平台（如 IG）。Threads、X、Dcard、PTT 等可用直接 HTTP 請求或平台 API 處理。
**觸發情境**：擷取非 IG 的社群媒體 URL。
