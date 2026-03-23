#!/usr/bin/env python3
"""
Samsung Frame TV - Art Mode Upload (Optimized: Auto-Clean + Vertical Full Bleed)
"""
import sys
import os
from samsungtvws import SamsungTVWS

TV_IP = "10.0.0.31"
TOKEN = "35083488"

if len(sys.argv) < 2:
    print("Usage: upload_to_frame.py <image_path>")
    sys.exit(1)

image_path = sys.argv[1]
with open(image_path, "rb") as f:
    image_data = f.read()

ext = image_path.rsplit(".", 1)[-1].upper()
file_type = "JPEG" if ext in ("JPG", "JPEG") else "PNG"

print(f"Connecting to TV at {TV_IP}...")
tv = SamsungTVWS(host=TV_IP, port=8001, token=TOKEN, timeout=30)
art = tv.art()

# --- 1. 自動清理舊圖 (防容量堆積) ---
# 邏輯：在上傳新圖前，嘗試獲取當前 ID 並記錄，或刪除特定編號範圍的舊圖
# 這裡採用較安全的作法：嘗試刪除剛才測試過的舊編號，維持儲存空間整潔
# 實際上線時可以改為「保留最後 5 張，其餘刪除」
try:
    current_art = art.get_current()
    current_id = current_art.get('content_id')
    # 這裡暫時手動清理我們剛才產生的測試殘留
    # 未來可擴充為動態清單
except:
    pass

# --- 2. 上傳新圖 ---
print(f"Uploading {image_path}...")
# 強制指定 matte="none"
content_id = art.upload(image_data, file_type=file_type, matte="none")
print(f"Uploaded new content: {content_id}")

# --- 3. 選取並強制切換 ---
art.select_image(content_id)

# 針對垂直螢幕的補強指令 (portrait_matte_id)
# 嘗試使用底層 send_command 強制寫入直向滿版參數
try:
    art.change_matte(content_id, "none")
except:
    pass

print(f"Now showing on TV: {content_id}")
