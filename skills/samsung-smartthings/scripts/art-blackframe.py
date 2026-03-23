"""
art-blackframe.py — 黑框置中合成器
將名畫縮放至 95% 寬度內，置中於 1080×1920 純黑畫布，底部標註畫名與作者。
"""
import requests
from PIL import Image, ImageDraw, ImageFont
import io, sys, os


def compose_blackframe(img_source, title="", artist="", output="/tmp/art-blackframe.jpg"):
    # 載入圖片（本地路徑或 URL）
    if os.path.isfile(img_source):
        art = Image.open(img_source).convert("RGB")
    else:
        resp = requests.get(img_source, timeout=30)
        art = Image.open(io.BytesIO(resp.content)).convert("RGB")

    W, H = 1080, 1920
    canvas = Image.new('RGB', (W, H), (0, 0, 0))

    # 畫作佔 95% 寬度，最高 85% 高度（留空間給文字）
    max_w = int(W * 0.95)
    max_h = int(H * 0.85)

    ratio = min(max_w / art.width, max_h / art.height)
    new_w = int(art.width * ratio)
    new_h = int(art.height * ratio)
    art_resized = art.resize((new_w, new_h), Image.LANCZOS)

    # 置中，稍微偏上（視覺平衡）
    x = (W - new_w) // 2
    y = (H - new_h) // 2 - int(H * 0.04)
    canvas.paste(art_resized, (x, y))

    # 文字：比例制，標題 2.2%、副標 1.5%
    if title or artist:
        draw = ImageDraw.Draw(canvas)
        font_size_t = max(int(H * 0.022), 20)
        font_size_a = max(int(H * 0.015), 14)

        try:
            f_t = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", font_size_t)
            f_a = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", font_size_a)
        except Exception:
            f_t = f_a = ImageFont.load_default()

        text_y = y + new_h + int(H * 0.025)

        if title:
            bbox = draw.textbbox((0, 0), title, font=f_t)
            tw = bbox[2] - bbox[0]
            draw.text(((W - tw) // 2, text_y), title, font=f_t, fill=(200, 200, 200))

        if artist:
            bbox2 = draw.textbbox((0, 0), artist, font=f_a)
            tw2 = bbox2[2] - bbox2[0]
            draw.text(((W - tw2) // 2, text_y + font_size_t + 12), artist, font=f_a, fill=(140, 140, 140))

    # 壓到 1MB 以下
    for q in [92, 85, 75, 65, 55]:
        canvas.save(output, "JPEG", quality=q)
        if os.path.getsize(output) < 1_000_000:
            break

    size_kb = os.path.getsize(output) // 1024
    print(f"Saved: {output} ({size_kb}KB, art {new_w}x{new_h} on {W}x{H}, title={font_size_t}px artist={font_size_a}px)")
    return output


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: art-blackframe.py <image_path_or_url> [title] [artist]")
        sys.exit(1)
    src = sys.argv[1]
    title = sys.argv[2] if len(sys.argv) > 2 else ""
    artist = sys.argv[3] if len(sys.argv) > 3 else ""
    out = sys.argv[4] if len(sys.argv) > 4 else "/tmp/art-blackframe.jpg"
    compose_blackframe(src, title, artist, out)
