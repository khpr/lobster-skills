#!/usr/bin/env python3
import sys
from samsungtvws import SamsungTVWS

TV_IP = "10.0.0.31"
TOKEN = "35083488"

if len(sys.argv) < 3:
    print("Usage: change_matte.py <content_id> <color>")
    sys.exit(1)

content_id = sys.argv[1]
color = sys.argv[2]
matte = f"shadowbox_{color}"

tv = SamsungTVWS(host=TV_IP, port=8001, token=TOKEN, timeout=30)
art = tv.art()
print(f"Changing matte for {content_id} to {matte}...")
art.change_matte(content_id, matte)
print("Done.")
