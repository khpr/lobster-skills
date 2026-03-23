import requests
from PIL import Image, ImageDraw, ImageFont
import io


def compose_9_16_art(img_url, title, artist, museum):
    """
    將名畫合成至 9:16 垂直畫布，並在底部留白處標註資訊
    """
    # 1. 取得原圖
    resp = requests.get(img_url)
    art_img = Image.open(io.BytesIO(resp.content)).convert("RGB")

    # 2. 固定輸出 2160x3840 (9:16 vertical 4K)
    target_w = 2160
    target_h = 3840

    # 資訊欄高度固定 200px
    info_bar_h = 200
    art_area_h = target_h - info_bar_h

    # 3. 縮放畫作以填滿藝術區域（保持比例，fit 進去）
    art_w, art_h = art_img.size
    scale = min(target_w / art_w, art_area_h / art_h)
    new_w = int(art_w * scale)
    new_h = int(art_h * scale)
    art_img = art_img.resize((new_w, new_h), Image.LANCZOS)

    # 4. 建立深色背景畫布
    canvas = Image.new('RGB', (target_w, target_h), (18, 18, 18))

    # 5. 畫作置中貼上（在藝術區域內垂直居中）
    x_offset = (target_w - new_w) // 2
    y_offset = (art_area_h - new_h) // 2
    canvas.paste(art_img, (x_offset, y_offset))

    # 6. 標註資訊 Bar（固定在底部 200px 區域）
    draw = ImageDraw.Draw(canvas)

    # 固定字級：標題 42px，副標 24px（適配 2160 寬度）
    font_size_t = 42
    font_size_i = 24

    try:
        f_t = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", font_size_t)
        f_i = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", font_size_i)
    except Exception:
        f_t = f_i = ImageFont.load_default()

    margin = int(target_w * 0.06)
    base_y = art_area_h + 40  # 資訊欄頂部 + 40px padding

    draw.text((margin, base_y), title, font=f_t, fill=(255, 255, 255))
    draw.text((margin, base_y + font_size_t + 12), f"{artist} • {museum}", font=f_i, fill=(160, 160, 160))

    return canvas


if __name__ == "__main__":
    import sys
    if len(sys.argv) < 5:
        print("Usage: art-composer.py <image_url> <title> <artist> <museum> [output_path]")
        sys.exit(1)
    img_url, title, artist, museum = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]
    output = sys.argv[5] if len(sys.argv) > 5 else "/tmp/art-composed.jpg"
    canvas = compose_9_16_art(img_url, title, artist, museum)
    canvas.save(output, "JPEG", quality=92)
    print(f"Saved to {output}")
