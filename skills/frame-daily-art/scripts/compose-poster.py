#!/usr/bin/env python3
"""
compose-poster.py — 將名畫合成黑框 InfoBar 海報（Frame TV 格式）
規格：黑色背景、名畫縮放 95%、底部 InfoBar（畫名/作者/年份）
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
    parser.add_argument("--scale", type=float, default=0.95)
    parser.add_argument("--bg-color", default="#000000")
    parser.add_argument("--infobar-height", type=int, default=80)
    args = parser.parse_args()

    try:
        from PIL import Image, ImageDraw, ImageFont
    except ImportError:
        print("ERROR: Pillow not installed. Run: pip3 install Pillow", file=sys.stderr)
        sys.exit(1)

    # Load meta
    with open(args.meta) as f:
        meta = json.load(f)
    title = meta.get("title", "Untitled")
    artist = meta.get("artist", "Unknown Artist")
    year = meta.get("year", "")

    # Load source image
    src = Image.open(args.input).convert("RGB")
    src_w, src_h = src.size

    # Target canvas: keep portrait, e.g. 9:16 ~ 1080x1920 or use original dims
    # We'll use original dims as canvas base
    canvas_w = src_w
    canvas_h = src_h + args.infobar_height

    # Convert bg color
    bg = tuple(int(args.bg_color.lstrip("#")[i:i+2], 16) for i in (0, 2, 4))

    canvas = Image.new("RGB", (canvas_w, canvas_h), bg)

    # Scale image 95%, center it in top portion
    scaled_w = int(src_w * args.scale)
    scaled_h = int(src_h * args.scale)
    src_scaled = src.resize((scaled_w, scaled_h), Image.LANCZOS)

    offset_x = (canvas_w - scaled_w) // 2
    offset_y = (src_h - scaled_h) // 2
    canvas.paste(src_scaled, (offset_x, offset_y))

    # Draw InfoBar at bottom
    draw = ImageDraw.Draw(canvas)
    bar_y = src_h
    draw.rectangle([0, bar_y, canvas_w, canvas_h], fill=bg)

    # Try to load a font
    font_bold = None
    font_regular = None
    font_paths = [
        "/System/Library/Fonts/Helvetica.ttc",
        "/System/Library/Fonts/Arial.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]
    for fp in font_paths:
        if os.path.exists(fp):
            try:
                from PIL import ImageFont
                font_bold = ImageFont.truetype(fp, 28)
                font_regular = ImageFont.truetype(fp, 22)
                break
            except Exception:
                pass
    if not font_bold:
        font_bold = ImageFont.load_default()
        font_regular = font_bold

    # InfoBar text
    info_line1 = title
    info_line2 = f"{artist}  ·  {year}" if year and year != "Unknown Year" else artist

    text_x = 30
    text_y1 = bar_y + 12
    text_y2 = bar_y + 46

    draw.text((text_x, text_y1), info_line1, fill="white", font=font_bold)
    draw.text((text_x, text_y2), info_line2, fill="#cccccc", font=font_regular)

    # Save
    os.makedirs(os.path.dirname(os.path.abspath(args.output)), exist_ok=True)
    canvas.save(args.output, "JPEG", quality=92)
    print(f"Saved poster: {args.output} ({canvas_w}x{canvas_h})")

if __name__ == "__main__":
    main()
