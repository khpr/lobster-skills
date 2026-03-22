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
    """Simple parse: find product links and titles from Artvee HTML."""
    try:
        from bs4 import BeautifulSoup
        soup = BeautifulSoup(html_bytes, "html.parser")
        results = []
        for item in soup.select(".product-element-top"):
            a = item.find("a", href=True)
            img = item.find("img")
            if not a:
                continue
            href = a["href"]
            title = img.get("alt", "Untitled") if img else "Untitled"
            results.append({"url": href, "title": title})
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
        # Try to get high-res image
        img = soup.select_one(".woocommerce-product-gallery__image img")
        if not img:
            img = soup.select_one("img.wp-post-image")
        img_url = None
        if img:
            img_url = img.get("data-large_image") or img.get("src")

        # Artist
        artist_el = soup.select_one(".product_meta .artist a")
        artist = artist_el.text.strip() if artist_el else "Unknown Artist"

        # Year
        year_el = soup.select_one(".product_meta .date")
        year = year_el.text.strip() if year_el else "Unknown Year"

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
        category = random.choice(["portraits", "figurative", "portraits", "religious"])
        list_url = f"https://artvee.com/{category}/page/{page_num}/"
        log(f"Attempt {attempt+1}: fetching {list_url}")
        html = fetch_url(list_url)
        if not html:
            time.sleep(2)
            continue

        paintings = parse_paintings(html)
        random.shuffle(paintings)
        log(f"Found {len(paintings)} candidates on page {page_num}")

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
