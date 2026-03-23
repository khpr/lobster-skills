"""
Samsung Frame TV Daily Art Uploader
- 從 TMDB 抓電影海報 或 Met Museum 抓名畫
- 合成 9:16 (1080x1920) 畫布
- 上傳至 Frame TV Art Mode
- 壓在 1MB 以下（Frame TV API 限制 2MB，實測 1MB 最穩）
"""

import requests
import os
import subprocess
import sys
from PIL import Image, ImageDraw, ImageFont
from datetime import datetime
import io

# --- 載入 .env ---
_env_path = os.path.expanduser("~/.openclaw/.env")
if os.path.isfile(_env_path):
    with open(_env_path) as _f:
        for _line in _f:
            _line = _line.strip()
            if _line and not _line.startswith("#") and "=" in _line:
                _k, _v = _line.split("=", 1)
                os.environ.setdefault(_k.strip(), _v.strip())

# --- 設定 ---
FRAME_TV_PYTHON = "/Users/Modema11434/.local/pipx/venvs/samsungtvws/bin/python"
UPLOAD_SCRIPT = os.path.join(os.path.dirname(__file__), "upload_to_frame.py")
TMDB_API_KEY = os.environ.get("TMDB_API_KEY", "")

# --- 踩坑筆記 ---
# 1. 容量紅線：Frame TV API 上傳上限 2MB，實測壓在 1MB 以下最穩定
# 2. 解析度策略：1080x1920 (垂直 1080p) 在 1MB 限制下能維持最佳銳利度
# 3. 直向參數：上傳必須指定 matte="none" 並確保 portrait_matte_id 也是 none
# 4. 圖源權重：優先找原生直式海報 (TMDB ja > en)，解析度不足則以高品質 en 版替代
# 5. 安全區：垂直電視常有邊緣裁切，文字邊距建議設為寬度的 11% 以上


def fetch_tmdb_poster(movie_name, lang_pref="en"):
    """從 TMDB 取得電影海報 URL（優先直式）"""
    if not TMDB_API_KEY:
        print("ERROR: TMDB_API_KEY not set")
        return None, None

    # 搜尋電影
    search_url = f"https://api.themoviedb.org/3/search/movie?api_key={TMDB_API_KEY}&query={requests.utils.quote(movie_name)}&language={lang_pref}"
    resp = requests.get(search_url)
    results = resp.json().get("results", [])
    if not results:
        return None, None

    movie = results[0]
    movie_id = movie["id"]
    title = movie.get("title", movie_name)

    # 取得所有海報（多語言）
    images_url = f"https://api.themoviedb.org/3/movie/{movie_id}/images?api_key={TMDB_API_KEY}"
    images = requests.get(images_url).json().get("posters", [])

    # 優先：日文 > 指定語言 > 無文字版 > 任意
    best = None
    for lang_code in ["ja", lang_pref, None]:
        candidates = [p for p in images if p.get("iso_639_1") == lang_code]
        if candidates:
            best = max(candidates, key=lambda p: p.get("height", 0))
            break
    if not best and images:
        best = max(images, key=lambda p: p.get("height", 0))

    if best:
        poster_url = f"https://image.tmdb.org/t/p/original{best['file_path']}"
        return poster_url, title

    return None, title


def compose_9_16(art_img, title, info=""):
    """9:16 合成，原圖夠大就用 4K，否則 1080p"""
    if art_img.width >= 1440 or art_img.height >= 2560:
        target_w, target_h = 1440, 2560
    else:
        target_w = art_img.width
        target_h = int(target_w * 16 / 9)
    canvas = Image.new("RGB", (target_w, target_h), (15, 15, 15))

    # 高品質縮放
    scale = target_w / art_img.width
    new_h = int(art_img.height * scale)
    img_resized = art_img.resize((target_w, new_h), Image.Resampling.LANCZOS)

    # 垂直置中（如果圖片比畫布矮）或靠上對齊
    y_offset = 0 if new_h >= target_h else 0
    canvas.paste(img_resized, (0, y_offset))

    # 如果圖片沒填滿畫布，加標註
    if new_h < target_h:
        draw = ImageDraw.Draw(canvas)
        font_size_t = int(target_h * 0.028)
        font_size_i = int(target_h * 0.016)
        try:
            f_t = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", font_size_t)
            f_i = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", font_size_i)
        except Exception:
            f_t = f_i = ImageFont.load_default()

        margin = int(target_w * 0.11)  # 安全區 11%
        base_y = new_h + int((target_h - new_h) * 0.3)
        draw.text((margin, base_y), title, font=f_t, fill=(255, 255, 255))
        if info:
            draw.text((margin, base_y + font_size_t + 15), info, font=f_i, fill=(140, 140, 140))

    return canvas


def save_under_1mb(canvas, output_path, max_bytes=1_000_000):
    """JPEG 品質遞減直到 < 1MB"""
    for quality in range(92, 50, -5):
        canvas.save(output_path, "JPEG", quality=quality)
        if os.path.getsize(output_path) <= max_bytes:
            return quality
    return 50


def upload_to_frame(image_path):
    """呼叫 upload_to_frame.py 上傳至 Frame TV"""
    result = subprocess.run(
        [FRAME_TV_PYTHON, UPLOAD_SCRIPT, image_path],
        capture_output=True, text=True
    )
    print(result.stdout)
    if result.returncode != 0:
        print(f"Upload error: {result.stderr}")
    return result.returncode == 0


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Usage: samsung-art-daily.py <mode> <query>")
        print("  mode: movie | art")
        print("  movie: samsung-art-daily.py movie 'Blade Runner 2049'")
        print("  art:   samsung-art-daily.py art '<image_url>' '<title>' '<artist>'")
        sys.exit(1)

    mode = sys.argv[1]

    if mode == "movie":
        movie_name = sys.argv[2]
        poster_url, title = fetch_tmdb_poster(movie_name)
        if not poster_url:
            print(f"No poster found for: {movie_name}")
            sys.exit(1)
        print(f"Found: {title} → {poster_url}")
        resp = requests.get(poster_url)
        art_img = Image.open(io.BytesIO(resp.content)).convert("RGB")
        canvas = compose_9_16(art_img, title)

    elif mode == "art":
        if len(sys.argv) < 5:
            print("Usage: samsung-art-daily.py art <image_url> <title> <artist>")
            sys.exit(1)
        img_url, title, artist = sys.argv[2], sys.argv[3], sys.argv[4]
        resp = requests.get(img_url)
        art_img = Image.open(io.BytesIO(resp.content)).convert("RGB")
        canvas = compose_9_16(art_img, title, artist)

    else:
        print(f"Unknown mode: {mode}")
        sys.exit(1)

    media_dir = os.path.expanduser("~/.openclaw/media/frame-art")
    os.makedirs(media_dir, exist_ok=True)
    output = os.path.join(media_dir, f"{datetime.now().strftime('%Y%m%d-%H%M%S')}.jpg")
    quality = save_under_1mb(canvas, output)
    print(f"Saved: {output} (quality={quality}, size={os.path.getsize(output)})")

    if input("Upload to Frame TV? [y/N] ").strip().lower() == "y":
        upload_to_frame(output)
