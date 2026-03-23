#!/usr/bin/env python3
"""
fetch-artvee.py — 從 Artvee 抓取符合條件的名畫
條件：2K+（長邊 ≥2000px）、直式（height/width > min_ratio）、不重複
"""
import argparse
import json
import os
import random
import sys
import time
import urllib.request
import urllib.error

def log(msg):
    print(msg, file=sys.stderr)

def load_used(path):
    if not os.path.exists(path):
        return set()
    try:
        with open(path) as f:
            data = json.load(f)
        if isinstance(data, list):
            return {item.get("title", "") for item in data if isinstance(item, dict)}
        return set()
    except Exception:
        return set()

def fetch_url(url, timeout=15):
    try:
        req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.read()
    except Exception as e:
        log(f"fetch error: {url} -> {e}")
        return None

def parse_paintings(html_bytes):
    """Parse Artvee product listings. New structure uses data-url on .product-element-top."""
    try:
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(html_bytes, "html.parser")
        results = []
        for item in soup.select(".product-element-top"):
            # New structure: data-url="/dl/slug", img alt=title
            data_url = item.get("data-url")
            img = item.find("img")
            title = img.get("alt", "Untitled") if img else "Untitled"

            # Pre-filter using data-sk dimensions (avoid downloading to check ratio)
            import json as _json
            data_sk_raw = item.get("data-sk", "")
            pre_ok = True
            if data_sk_raw:
                try:
                    sk = _json.loads(data_sk_raw)
                    for sz_key in ("hdlimagesize", "sdlimagesize"):
                        sz = sk.get(sz_key, "")
                        if "x" in sz:
                            parts = sz.replace("px","").split("x")
                            w, h = int(parts[0].strip()), int(parts[1].strip())
                            if h / w < 1.2:
                                pre_ok = False
                            break
                except Exception:
                    pass

            if not pre_ok:
                continue

            if data_url:
                href = f"https://artvee.com{data_url}"
                results.append({"url": href, "title": title})
                continue
            # Fallback: old structure with <a href>
            a = item.find("a", href=True)
            if a:
                results.append({"url": a["href"], "title": title})
        return results
    except ImportError:
        log("bs4 not installed, falling back to regex")
        import re
        links = re.findall(r'href="(https://artvee\.com/dl/[^"]+)"', html_bytes.decode("utf-8", errors="ignore"))
        return [{"url": l, "title": "Unknown"} for l in links]

def fetch_artwork_detail(page_url):
    """Fetch artwork page to get high-res image URL, artist, year."""
    html = fetch_url(page_url)
    if not html:
        return None
    try:
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(html, "html.parser")
        # Try presigned SDL download link first (SD ~1800px, time-limited but fresh)
        dl_link = soup.select_one('a[href*="mdl.artvee.com/sdl"]')
        img_url = dl_link["href"] if dl_link else None

        # Fallback: sftb thumbnail (~800px)
        if not img_url:
            img = (soup.select_one(".woocommerce-product-gallery__image img") or
                   soup.select_one("img.wp-post-image"))
            if img:
                src = img.get("src", "")
                # Try to get sftb (larger than ft)
                img_url = src if "mdl.artvee.com" in src else img.get("data-large_image") or src

        # Artist — try multiple selectors
        artist_el = (soup.select_one(".tartist") or
                     soup.select_one(".product_meta .artist a") or
                     soup.select_one(".product-artist"))
        artist_raw = artist_el.text.strip() if artist_el else "Unknown Artist"
        # Clean up "Name (Nationality, YYYY-YYYY)" → keep just name
        import re as _re
        artist = _re.sub(r'\s*\([^)]*\)', '', artist_raw).strip() or artist_raw

        # Year — try multiple selectors
        year_el = (soup.select_one(".tdate") or
                   soup.select_one(".product_meta .date") or
                   soup.select_one(".product-date"))
        year = year_el.text.strip() if year_el else ""

        title_el = soup.select_one("h1.product_title")
        title = title_el.text.strip() if title_el else "Untitled"

        return {"img_url": img_url, "artist": artist, "year": year, "title": title, "source_url": page_url}
    except Exception as e:
        log(f"parse detail error: {e}")
        return None

def check_image_size(img_bytes, min_px, portrait_ratio):
    """Check resolution and portrait orientation."""
    try:
        from PIL import Image
        import io
        img = Image.open(io.BytesIO(img_bytes))
        w, h = img.size
        max_side = max(w, h)
        ratio = h / w if w > 0 else 0
        return max_side >= min_px and ratio >= portrait_ratio
    except Exception as e:
        log(f"image check error: {e}")
        return False

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--min-px", type=int, default=2000)
    parser.add_argument("--portrait-ratio", type=float, default=1.3)
    parser.add_argument("--exclude-log", default="data/used-artworks.json")
    parser.add_argument("--output", required=True)
    parser.add_argument("--meta", required=True)
    args = parser.parse_args()

    used = load_used(args.exclude_log)
    log(f"Loaded {len(used)} used artworks")

    # Try random pages on Artvee
    max_attempts = 5
    for attempt in range(max_attempts):
        page_num = random.randint(1, 50)
        # 優先用 portraits/figurative，直式比例高；paintings 易被橫式系列佔滿
        # Artvee 2026 新 URL 結構：/c/{category}/page/N/
        # figurative=人物畫、mythology=神話、religion=宗教（直式多）
        category = random.choice(["figurative", "figurative", "mythology", "religion"])
        list_url = f"https://artvee.com/c/{category}/page/{page_num}/"
        log(f"Attempt {attempt+1}: fetching {list_url}")
        html = fetch_url(list_url)
        if not html:
            time.sleep(2)
            continue

        paintings = parse_paintings(html)
        random.shuffle(paintings)
        log(f"Found {len(paintings)} candidates on page {page_num}")

        # 過濾明顯非畫作的標題（歷史服裝圖鑑、舞台設計、年代範圍標示）
        SKIP_KEYWORDS = ["Maquettes", "1876-1888", "1895-1911", "costumes", "Costumes",
                         "siecle", "mobiliers", "instruments", "Harper's", "McClure's"]
        paintings = [p for p in paintings if not any(kw in p["title"] for kw in SKIP_KEYWORDS)]

        for p in paintings:
            if p["title"] in used:
                continue
            detail = fetch_artwork_detail(p["url"])
            if not detail or not detail.get("img_url"):
                continue

            img_bytes = fetch_url(detail["img_url"])
            if not img_bytes:
                continue

            if not check_image_size(img_bytes, args.min_px, args.portrait_ratio):
                log(f"Skip (size/ratio): {detail['title']}")
                continue

            # Save image
            with open(args.output, "wb") as f:
                f.write(img_bytes)

            # Save meta
            with open(args.meta, "w") as f:
                json.dump({
                    "title": detail["title"],
                    "artist": detail["artist"],
                    "year": detail["year"],
                    "source_url": detail["source_url"]
                }, f, ensure_ascii=False, indent=2)

            log(f"Saved: {detail['title']} by {detail['artist']} ({detail['year']})")
            sys.exit(0)

        time.sleep(1)

    print("ERROR: No suitable artwork found after all attempts", file=sys.stderr)
    sys.exit(1)

if __name__ == "__main__":
    main()
