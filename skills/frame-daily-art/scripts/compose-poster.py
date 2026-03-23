#!/usr/bin/env python3
"""
compose-poster.py — 將名畫合成黑框 InfoBar 海報（Frame TV 格式）
規格：4K 直式 2160×3840、畫作置中、底部動態 InfoBar
InfoBar 風格：深藍灰底色、Georgia Bold 標題（大寫）、Georgia 副標
"""
import argparse
import json
import os
import sys

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", required=True, help="原始圖像路徑")
    parser.add_argument("--meta", required=True, help="meta JSON 路徑")
    parser.add_argument("--output", required=True, help="輸出路徑")
    parser.add_argument("--scale", type=float, default=1.0, help="畫作縮放比（1.0=撐滿）")
    parser.add_argument("--bg-color", default="0,0,0", help="背景 RGB，如 0,0,0")
    args = parser.parse_args()

    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("ERROR: Pillow not installed. Run: pip3 install Pillow", file=sys.stderr)
        sys.exit(1)

    # Load meta
    with open(args.meta) as f:
        meta = json.load(f)
    title = meta.get("title", "Untitled").upper()
    artist = meta.get("artist", "Unknown Artist")
    year = meta.get("year", "")
    subtitle = f"{artist} · {year}" if year and year not in ("", "Unknown Year") else artist

    # Load source image
    src = Image.open(args.input).convert("RGB")

    # 固定 4K 直式畫布
    target_w, target_h = 2160, 3840
    canvas = Image.new("RGB", (target_w, target_h), (0, 0, 0))

    # Cover 模式：縮放到填滿整個畫布（超出部分裁切），不留黑邊
    scale_w = target_w / src.width
    scale_h = target_h / src.height
    scale = max(scale_w, scale_h)
    nw = int(src.width * scale)
    nh = int(src.height * scale)

    img_resized = src.resize((nw, nh), Image.Resampling.LANCZOS)
    # 裁切置中
    x = (nw - target_w) // 2
    y = (nh - target_h) // 2
    img_cropped = img_resized.crop((x, y, x + target_w, y + target_h))
    canvas.paste(img_cropped, (0, 0))

    # InfoBar 固定在畫布最底部，高度動態（畫布高 8%，至少 160px）
    bar_h_calc = max(160, int(target_h * 0.08))
    bar_top = target_h - bar_h_calc

    # InfoBar：半透明深色遮罩疊在畫作上（alpha composite）
    overlay = Image.new("RGBA", (target_w, target_h), (0, 0, 0, 0))
    ov_draw = ImageDraw.Draw(overlay)
    ov_draw.rectangle([(0, bar_top), (target_w, target_h)], fill=(14, 16, 22, 210))
    canvas = canvas.convert("RGBA")
    canvas = Image.alpha_composite(canvas, overlay).convert("RGB")
    draw = ImageDraw.Draw(canvas)

    # 字體：Georgia Bold / Georgia，按畫布比例
    font_size_title = int(target_h * 0.020)   # ~76px
    font_size_sub   = int(target_h * 0.012)   # ~46px
    font_paths_bold = [
        "/System/Library/Fonts/Supplemental/Georgia Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    font_paths_reg = [
        "/System/Library/Fonts/Supplemental/Georgia.ttf",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]

    def load_font(paths, size):
        for p in paths:
            if os.path.exists(p):
                try:
                    return ImageFont.truetype(p, size)
                except Exception:
                    pass
        return ImageFont.load_default()

    f_title = load_font(font_paths_bold, font_size_title)
    f_sub   = load_font(font_paths_reg,  font_size_sub)

    margin = int(target_w * 0.05)
    bar_h = target_h - bar_top
    text_block_h = font_size_title + 8 + font_size_sub
    label_y = bar_top + max(16, (bar_h - text_block_h) // 2)

    draw.text((margin, label_y),                      title,    font=f_title, fill=(220, 220, 220))
    draw.text((margin, label_y + font_size_title + 8), subtitle, font=f_sub,   fill=(150, 150, 150))

    # 儲存，2MB 以下
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    for quality in range(95, 50, -5):
        canvas.save(args.output, "JPEG", quality=quality)
        if os.path.getsize(args.output) <= 2_000_000:
            break

    print(f"Saved poster: {args.output} ({target_w}x{target_h})")

if __name__ == "__main__":
    main()
