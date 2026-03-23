#!/usr/bin/env python3
"""
Daily Random Portrait Art → Samsung Frame TV
圖源優先順序：Artvee > Met Museum（fallback）

用法：
  python3 daily-art-random.py              # 隨機挑 + 上傳
  python3 daily-art-random.py --dry-run    # 只合成不上傳
  python3 daily-art-random.py --department 11  # 指定部門（11=歐洲繪畫，Met only）
"""

import requests
import random
import os
import sys
import subprocess
import json
import re
from datetime import datetime
from PIL import Image, ImageDraw, ImageFont
import io

FRAME_TV_PYTHON = "/Users/Modema11434/.local/pipx/venvs/samsungtvws/bin/python"
UPLOAD_SCRIPT = os.path.join(os.path.dirname(__file__), "upload_to_frame.py")
HISTORY_FILE = os.path.expanduser("~/.openclaw/skills/samsung-smartthings/art-history.json")

# Met Museum 部門：11=歐洲繪畫, 21=現代藝術, 6=亞洲藝術
DEFAULT_DEPARTMENTS = [11, 21]

# 已知高品質直式作品池（冷啟動 + fallback 用）
CURATED_IDS = [
    436535,  # Vermeer - Young Woman with a Water Pitcher
    459027,  # Van Gogh - Self-Portrait with a Straw Hat
    436524,  # Vermeer - A Maid Asleep
    437984,  # Monet - Bridge over a Pond of Water Lilies
    436573,  # Velázquez - Juan de Pareja
    438817,  # Renoir - Madame Georges Charpentier and Her Children
    437153,  # Courbet - Woman with a Parrot
    435882,  # El Greco - View of Toledo
    459123,  # Van Gogh - Irises
    437329,  # Degas - The Dance Class
    436105,  # Goya - Manuel Osorio Manrique de Zuñiga
    438722,  # Cézanne - The Card Players
    437869,  # Manet - Boating
    436947,  # Klimt - Mäda Primavesi
]

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}


def load_history():
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE) as f:
            return json.load(f)
    return {"shown": [], "last_date": None}


def save_history(history):
    os.makedirs(os.path.dirname(HISTORY_FILE), exist_ok=True)
    with open(HISTORY_FILE, "w") as f:
        json.dump(history, f, indent=2)


def artvee_full_url(thumbnail_url):
    """把縮圖 URL 轉成全尺寸 URL"""
    # artvee.com/mcnt/upl/ → mdl.artvee.com/ft/
    return re.sub(r'https?://artvee\.com/mcnt/upl/', 'https://mdl.artvee.com/ft/', thumbnail_url)


def parse_artvee_artist(html):
    """從作品頁 HTML 抓 .tartist 裡的藝術家名稱"""
    # <div class="tartist">Artist Name (Nationality, birth-death)</div>
    m = re.search(r'class=["\']tartist["\'][^>]*>\s*([^<]+)', html)
    if m:
        raw = m.group(1).strip()
        # 取出括號前的名稱
        name_m = re.match(r'^([^(]+)', raw)
        name = name_m.group(1).strip() if name_m else raw
        # 取括號內的年代
        date_m = re.search(r'\(([^)]+)\)', raw)
        date_str = date_m.group(1).strip() if date_m else ""
        return name, date_str
    return None, ""


def fetch_from_artvee(history=None, max_attempts=8):
    """
    從 Artvee WordPress REST API 隨機取得直式畫作。
    回傳 dict 或 None（失敗時）。
    """
    shown = set(history.get("shown", [])) if history else set()

    # 1. 查總數
    try:
        count_resp = requests.get(
            "https://artvee.com/wp-json/wp/v2/product?per_page=1&_embed=false",
            headers=HEADERS,
            timeout=15
        )
        total = int(count_resp.headers.get("X-WP-Total", 0))
        if total <= 0:
            print("⚠️  Artvee: could not get total count")
            return None
        print(f"   Artvee: {total} artworks available")
    except Exception as e:
        print(f"⚠️  Artvee count failed: {e}")
        return None

    for attempt in range(max_attempts):
        offset = random.randint(0, total - 1)
        try:
            api_url = f"https://artvee.com/wp-json/wp/v2/product?per_page=1&offset={offset}&_embed=true"
            resp = requests.get(api_url, headers=HEADERS, timeout=15)
            resp.raise_for_status()
            items = resp.json()
            if not items:
                continue
            product = items[0]

            product_id = f"artvee-{product['id']}"
            if product_id in shown:
                continue

            # 取縮圖 URL
            try:
                thumb_url = product["_embedded"]["wp:featuredmedia"][0]["source_url"]
            except (KeyError, IndexError, TypeError):
                continue

            full_url = artvee_full_url(thumb_url)
            page_url = product.get("link", "")
            title = product.get("title", {}).get("rendered", "Untitled")
            # 清除 HTML 實體
            title = re.sub(r'<[^>]+>', '', title)
            title = title.replace("&#8211;", "–").replace("&amp;", "&").replace("&#8217;", "'")

            # 2. 從作品頁面抓藝術家資訊
            artist = "Unknown"
            artist_date = ""
            if page_url:
                try:
                    page_resp = requests.get(page_url, headers=HEADERS, timeout=10)
                    parsed_name, parsed_date = parse_artvee_artist(page_resp.text)
                    if parsed_name:
                        artist = parsed_name
                        artist_date = parsed_date
                except Exception:
                    pass

            # 3. 下載圖片，檢查是否直式（h > w）
            try:
                img_resp = requests.get(full_url, headers=HEADERS, timeout=20)
                img_resp.raise_for_status()
                img = Image.open(io.BytesIO(img_resp.content))
                w, h = img.size
                if w < 1000 or h < 1400:
                    print(f"   Artvee: skip low-res {w}x{h} — {title[:40]}")
                    continue
                if h <= w * 1.4:  # 必須高於寬度 1.4 倍，更接近電視的 1.77 (9:16)
                    print(f"   Artvee: skip non-portrait {w}x{h} (ratio {h/w:.2f}) — {title[:40]}")
                    continue
                # 成功
                print(f"   Artvee: portrait {w}x{h} ✓ — {title[:40]}")
                return {
                    "id": product_id,
                    "title": title,
                    "artist": artist,
                    "date": artist_date,
                    "medium": "",
                    "image_url": full_url,
                    "department": "Artvee",
                    "_img_bytes": img_resp.content,  # 避免重複下載
                }
            except Exception as e:
                print(f"   Artvee: image fetch failed ({e}), retrying...")
                continue

        except Exception as e:
            print(f"   Artvee attempt {attempt+1} failed: {e}")
            continue

    print("⚠️  Artvee: all attempts failed")
    return None


def fetch_random_portrait(departments=None, history=None):
    """從 Met Museum API 隨機找一幅直式有圖作品（Artvee fallback 用）"""
    shown = set(history.get("shown", [])) if history else set()
    depts = departments or DEFAULT_DEPARTMENTS

    # 策略 1：從 API 搜尋
    for attempt in range(5):
        dept = random.choice(depts)
        url = f"https://collectionapi.metmuseum.org/public/collection/v1/search?departmentId={dept}&hasImages=true&q=painting"
        try:
            resp = requests.get(url, headers=HEADERS, timeout=10)
            obj_ids = resp.json().get("objectIDs", [])
            if not obj_ids:
                continue

            random.shuffle(obj_ids)
            for oid in obj_ids[:30]:  # 最多試 30 個
                if oid in shown:
                    continue
                detail = requests.get(
                    f"https://collectionapi.metmuseum.org/public/collection/v1/objects/{oid}",
                    headers=HEADERS,
                    timeout=10
                ).json()

                img_url = detail.get("primaryImage", "")
                if not img_url:
                    continue

                title = detail.get("title", "Untitled")
                artist = detail.get("artistDisplayName", "Unknown")
                date = detail.get("objectDate", "")
                medium = detail.get("medium", "")

                # 快速檢查圖片比例
                try:
                    small_url = img_url.replace("/original/", "/web-large/")
                    img_resp = requests.get(small_url, headers=HEADERS, timeout=8)
                    img = Image.open(io.BytesIO(img_resp.content))
                    w, h = img.size
                    if w < 800 or h < 1100:
                        continue  # skip low-res
                    if h > w * 1.4:  # 直式：高 > 寬*1.4
                        return {
                            "id": oid,
                            "title": title,
                            "artist": artist,
                            "date": date,
                            "medium": medium,
                            "image_url": img_url,
                            "department": detail.get("department", ""),
                        }
                except Exception:
                    continue
        except Exception as e:
            print(f"Met API attempt {attempt+1} failed: {e}")
            continue

    # 策略 2：完全離線的精選池（Wikimedia 穩定 URL，不依賴 Met API）
    OFFLINE_POOL = [
        {"id": "wm_vangogh_straw", "title": "Self-Portrait with a Straw Hat", "artist": "Vincent van Gogh", "date": "1887", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Vincent_van_Gogh_-_Self-Portrait_with_Straw_Hat_-_Google_Art_Project.jpg/800px-Vincent_van_Gogh_-_Self-Portrait_with_Straw_Hat_-_Google_Art_Project.jpg", "department": "European Paintings"},
        {"id": "wm_klimt_adele", "title": "Portrait of Adele Bloch-Bauer I", "artist": "Gustav Klimt", "date": "1907", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/40/Klimt_-_Adele_Bloch-Bauer_I.jpg/800px-Klimt_-_Adele_Bloch-Bauer_I.jpg", "department": "European Paintings"},
        {"id": "wm_vermeer_girl", "title": "Girl with a Pearl Earring", "artist": "Johannes Vermeer", "date": "ca. 1665", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/1665_Girl_with_a_Pearl_Earring.jpg/800px-1665_Girl_with_a_Pearl_Earring.jpg", "department": "European Paintings"},
        {"id": "wm_davinci_lady", "title": "Lady with an Ermine", "artist": "Leonardo da Vinci", "date": "ca. 1489–90", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Lady_with_an_Ermine_-_Leonardo_da_Vinci_-_Google_Art_Project.jpg/800px-Lady_with_an_Ermine_-_Leonardo_da_Vinci_-_Google_Art_Project.jpg", "department": "European Paintings"},
        {"id": "wm_modigliani_jeanne", "title": "Jeanne Hébuterne", "artist": "Amedeo Modigliani", "date": "1919", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/Jeanne_H%C3%A9buterne%2C_1919_-_Amadeo_Modigliani.jpg/800px-Jeanne_H%C3%A9buterne%2C_1919_-_Amadeo_Modigliani.jpg", "department": "European Paintings"},
        {"id": "wm_vangogh_irises", "title": "Irises", "artist": "Vincent van Gogh", "date": "1890", "image_url": "https://images.metmuseum.org/CRDImages/ep/original/DP346474.jpg", "department": "European Paintings"},
        {"id": "wm_courbet_parrot", "title": "Woman with a Parrot", "artist": "Gustave Courbet", "date": "1866", "image_url": "https://images.metmuseum.org/CRDImages/ep/original/DT1911.jpg", "department": "European Paintings"},
        {"id": "wm_vangogh_starry", "title": "The Starry Night", "artist": "Vincent van Gogh", "date": "1889", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/ea/Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg/1280px-Van_Gogh_-_Starry_Night_-_Google_Art_Project.jpg", "department": "European Paintings"},
        {"id": "wm_raphael_sistine", "title": "Sistine Madonna", "artist": "Raphael", "date": "1512", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/69/Raphael_-_Madonna_Sixtina.jpg/800px-Raphael_-_Madonna_Sixtina.jpg", "department": "European Paintings"},
        {"id": "wm_ingres_grande", "title": "La Grande Odalisque", "artist": "Jean-Auguste-Dominique Ingres", "date": "1814", "image_url": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4f/La_Grande_Odalisque.jpg/1280px-La_Grande_Odalisque.jpg", "department": "European Paintings"},
    ]
    available_offline = [a for a in OFFLINE_POOL if a["id"] not in shown]
    if not available_offline:
        available_offline = OFFLINE_POOL
    return random.choice(available_offline)


def compose_frame_art(art_info):
    """下載原圖 → 合成 9:16 + 底部標註 → 壓到 2MB 以下"""
    from PIL import ImageDraw, ImageFont

    # Artvee 可能已經快取了圖片 bytes，避免重複下載
    img_bytes = art_info.pop("_img_bytes", None)
    if img_bytes:
        art_img = Image.open(io.BytesIO(img_bytes)).convert("RGB")
    else:
        resp = requests.get(art_info["image_url"], headers=HEADERS, timeout=30)
        art_img = Image.open(io.BytesIO(resp.content)).convert("RGB")

    # 統一輸出 4K 直式（2160×3840），確保 TV 允許無遮罩
    target_w, target_h = 2160, 3840
    canvas = Image.new("RGB", (target_w, target_h), (0, 0, 0))

    # 底部預留標註區域（5% 高度）
    label_h = int(target_h * 0.05)
    art_area_h = target_h - label_h

    # 撐滿寬度，只在上下補黑 bar
    scale = target_w / art_img.width
    if int(art_img.height * scale) > art_area_h:
        scale = art_area_h / art_img.height
    nw = int(art_img.width * scale)
    nh = int(art_img.height * scale)
    img_resized = art_img.resize((nw, nh), Image.Resampling.LANCZOS)

    x = (target_w - nw) // 2
    y = (art_area_h - nh) // 2
    canvas.paste(img_resized, (x, y))

    # 底部標註 bar（深藍灰色，參考 Marriage Story 風格）
    draw = ImageDraw.Draw(canvas)
    bar_color = (20, 22, 30)
    bar_top = y + nh
    draw.rectangle([(0, bar_top), (target_w, target_h)], fill=bar_color)

    title = art_info.get("title", "Untitled").upper()
    artist = art_info.get("artist", "Unknown")
    date = art_info.get("date", "")
    subtitle = f"{artist} · {date}" if date else artist

    font_size_title = int(target_h * 0.020)
    font_size_sub = int(target_h * 0.012)
    try:
        f_title = ImageFont.truetype("/System/Library/Fonts/Supplemental/Georgia Bold.ttf", font_size_title)
        f_sub = ImageFont.truetype("/System/Library/Fonts/Supplemental/Georgia.ttf", font_size_sub)
    except Exception:
        try:
            f_title = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Bold.ttf", font_size_title)
            f_sub = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", font_size_sub)
        except Exception:
            f_title = ImageFont.load_default()
            f_sub = ImageFont.load_default()

    margin = int(target_w * 0.05)
    bar_h = target_h - bar_top
    text_block_h = font_size_title + 8 + font_size_sub
    label_y = bar_top + (bar_h - text_block_h) // 2
    draw.text((margin, label_y), title, font=f_title, fill=(220, 220, 220))
    draw.text((margin, label_y + font_size_title + 8), subtitle, font=f_sub, fill=(150, 150, 150))

    # 存到 ~/.openclaw/media/frame-art/
    media_dir = os.path.expanduser("~/.openclaw/media/frame-art")
    os.makedirs(media_dir, exist_ok=True)
    output = os.path.join(media_dir, f"{datetime.now().strftime('%Y%m%d')}-{art_info['id']}.jpg")
    max_bytes = 2_000_000
    for quality in range(95, 50, -5):
        canvas.save(output, "JPEG", quality=quality)
        if os.path.getsize(output) <= max_bytes:
            break

    return output


def delete_previous_art(history):
    """刪除前一張每日名畫，避免堆積"""
    prev_id = history.get("last_content_id")
    if not prev_id:
        return
    try:
        from samsungtvws import SamsungTVWS
        tv = SamsungTVWS(host="10.0.0.31", port=8001, token="35083488", timeout=30)
        art = tv.art()
        art.delete(prev_id)
        print(f"🗑️  Deleted previous: {prev_id}")
    except Exception as e:
        print(f"⚠️  Failed to delete {prev_id}: {e}")


def upload_to_frame(image_path):
    """上傳並回傳 content_id"""
    try:
        from samsungtvws import SamsungTVWS
        tv = SamsungTVWS(host="10.0.0.31", port=8001, token="35083488", timeout=30)
        art = tv.art()
        with open(image_path, "rb") as f:
            image_data = f.read()
        ext = image_path.rsplit(".", 1)[-1].upper()
        file_type = "JPEG" if ext in ("JPG", "JPEG") else "PNG"
        content_id = art.upload(image_data, file_type=file_type, matte="none")
        art.select_image(content_id)
        try:
            art.change_matte(content_id, "none")
        except Exception:
            pass
        print(f"📺 Uploaded & showing: {content_id}")
        return content_id
    except Exception as e:
        print(f"❌ Upload error: {e}")
        return None


def main():
    dry_run = "--dry-run" in sys.argv
    dept_arg = None
    if "--department" in sys.argv:
        idx = sys.argv.index("--department")
        dept_arg = [int(sys.argv[idx + 1])]

    history = load_history()

    # 優先嘗試 Artvee
    print("🎨 Trying Artvee (primary source)...")
    art = fetch_from_artvee(history=history)

    # Artvee 失敗 → fallback 到 Met Museum
    if not art or not art.get("image_url"):
        print("⚠️  Artvee failed, falling back to Met Museum...")
        art = fetch_random_portrait(departments=dept_arg, history=history)

    if not art or not art.get("image_url"):
        print("❌ No suitable artwork found")
        sys.exit(1)

    source = art.get("department", "Unknown")
    print(f"✅ {art['title']} — {art['artist']} ({art['date']})")
    print(f"   Source: {source}  |  ID: {art['id']}")

    print("🖼️  Composing 9:16 canvas...")
    output = compose_frame_art(art)
    size_kb = os.path.getsize(output) / 1024
    print(f"   Saved: {output} ({size_kb:.0f} KB)")

    if dry_run:
        print("🏁 Dry run — skipping upload")
    else:
        # 先刪前一張
        delete_previous_art(history)
        # 上傳新圖
        print("📺 Uploading to Frame TV...")
        content_id = upload_to_frame(output)
        if content_id:
            print("✅ Done!")
            history["shown"].append(art["id"])
            if len(history["shown"]) > 200:
                history["shown"] = history["shown"][-100:]
            history["last_date"] = datetime.now().strftime("%Y-%m-%d")
            history["last_content_id"] = content_id
            history["last_art"] = {
                "id": art["id"],
                "title": art["title"],
                "artist": art["artist"],
            }
            save_history(history)
        else:
            print("❌ Upload failed")
            sys.exit(1)

    # 輸出 JSON 供 agent 使用（排除內部 bytes 欄位）
    art_out = {k: v for k, v in art.items() if k != "_img_bytes"}
    print(json.dumps(art_out, ensure_ascii=False))


if __name__ == "__main__":
    main()
