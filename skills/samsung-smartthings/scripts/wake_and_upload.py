#!/usr/bin/env python3
"""
wake-and-upload.py — 確保 Frame TV 開機後再上傳
1. ping 測試連線
2. 如果無回應 → WOL 喚醒 + 等待
3. 嘗試開機指令（samsungtvws send_key KEY_POWER）
4. 等 TV 就緒後上傳
"""
import sys, os, time, subprocess, socket

TV_IP = "10.0.0.31"
TV_MAC = None  # 如果知道 MAC 可填入，用於 WOL
TOKEN = "35083488"
MAX_WAIT = 60   # 最多等 60 秒
POLL_INTERVAL = 5

def is_tv_reachable(ip, port=8001, timeout=3):
    try:
        s = socket.create_connection((ip, port), timeout=timeout)
        s.close()
        return True
    except:
        return False

def wake_tv():
    """嘗試用 samsungtvws 送開機按鍵"""
    try:
        from samsungtvws import SamsungTVWS
        tv = SamsungTVWS(host=TV_IP, port=8001, token=TOKEN, timeout=5)
        tv.send_key("KEY_POWER")
        print("  Sent KEY_POWER wake signal")
    except Exception as e:
        print(f"  KEY_POWER failed: {e}")

image_path = sys.argv[1]

print(f"[wake-upload] Checking TV at {TV_IP}...")

if not is_tv_reachable(TV_IP):
    print("[wake-upload] TV offline — attempting wake...")
    wake_tv()
    print(f"[wake-upload] Waiting up to {MAX_WAIT}s for TV to come online...")
    elapsed = 0
    while elapsed < MAX_WAIT:
        time.sleep(POLL_INTERVAL)
        elapsed += POLL_INTERVAL
        if is_tv_reachable(TV_IP):
            print(f"[wake-upload] TV online after {elapsed}s")
            break
        print(f"  ...still waiting ({elapsed}s)")
    else:
        print("[wake-upload] ERROR: TV did not come online within timeout")
        sys.exit(1)
else:
    print("[wake-upload] TV already online")

# 稍等讓 Art Mode API 就緒
time.sleep(3)

# 執行上傳
upload_script = os.path.join(os.path.dirname(__file__), "upload_to_frame.py")
result = subprocess.run(
    [sys.executable, upload_script, image_path],
    capture_output=False
)
sys.exit(result.returncode)
