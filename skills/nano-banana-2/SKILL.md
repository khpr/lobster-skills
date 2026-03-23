---
name: nano-banana-2
description: Generate or edit images via Gemini 3.1 Flash Image (Nano Banana 2). Faster and cheaper than Pro, good for quick iterations.
metadata:
  {
    "openclaw":
      {
        "emoji": "🍌",
        "requires": { "bins": ["uv"], "env": ["GEMINI_API_KEY"] },
        "primaryEnv": "GEMINI_API_KEY",
      },
  }
---

# Nano Banana 2 (Gemini 3.1 Flash Image)

Flash 版生圖，速度快、成本低，適合快速迭代和草稿。

## Generate

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "your image description" --filename "output.png" --resolution 1K
```

## Edit (single image)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "edit instructions" --filename "output.png" -i "/path/in.png" --resolution 2K
```

## Multi-image composition (up to 14 images)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "combine these into one scene" --filename "output.png" -i img1.png -i img2.png -i img3.png
```

## API key

- `GEMINI_API_KEY` env var
- Or set in `~/.openclaw/openclaw.json`

## Aspect ratio (optional)

```bash
uv run {baseDir}/scripts/generate_image.py --prompt "portrait photo" --filename "output.png" --aspect-ratio 9:16
```

## Notes

- Resolutions: `1K` (default), `2K`, `4K`.
- Aspect ratios: `1:1`, `2:3`, `3:2`, `3:4`, `4:3`, `4:5`, `5:4`, `9:16`, `16:9`, `21:9`.
- Use timestamps in filenames: `yyyy-mm-dd-hh-mm-ss-name.png`.
- The script prints a `MEDIA:` line for OpenClaw to auto-attach.
- Do not read the image back; report the saved path only.

## vs Nano Banana Pro

| | Pro (Gemini 3 Pro) | Flash (Gemini 3.1 Flash) |
|---|---|---|
| 速度 | 較慢 | 快 |
| 品質 | 高 | 中高 |
| 成本 | 高 | 低 |
| 適用 | 最終成品 | 草稿、快速迭代 |
