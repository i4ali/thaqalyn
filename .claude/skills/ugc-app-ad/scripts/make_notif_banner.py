#!/usr/bin/env python3
"""
Render an iOS-style notification banner PNG (transparent background).

Usage:
  python3 make_notif_banner.py --icon appicon.png --app-name THAQALAYN \
      --title "The Hajj Journey is here" \
      --subtitle "10 days to walk with the Prophets" \
      --brand "#E67A3C" --output banner.png
"""
import argparse

from PIL import Image, ImageDraw, ImageFont


def hex_rgba(h):
    h = h.lstrip("#")
    return tuple(int(h[i:i + 2], 16) for i in (0, 2, 4)) + (255,)


def font(sz, bold=False):
    candidates = (
        ["/System/Library/Fonts/SFNSRounded.ttf",
         "/System/Library/Fonts/SFNS.ttf",
         "/Library/Fonts/Arial Bold.ttf"]
        if bold else
        ["/System/Library/Fonts/SFNS.ttf",
         "/Library/Fonts/Arial.ttf"]
    )
    for p in candidates:
        try:
            return ImageFont.truetype(p, sz)
        except OSError:
            continue
    return ImageFont.load_default()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--icon", required=True)
    ap.add_argument("--app-name", required=True)
    ap.add_argument("--title", required=True)
    ap.add_argument("--subtitle", default="")
    ap.add_argument("--brand", default="#E67A3C")
    ap.add_argument("--output", required=True)
    a = ap.parse_args()

    brand = hex_rgba(a.brand)
    W, H = 1000, 200
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    d.rounded_rectangle([0, 0, W, H], radius=44, fill=(245, 243, 240, 235))

    icon = Image.open(a.icon).convert("RGBA").resize((128, 128))
    mask = Image.new("L", (128, 128), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, 128, 128],
                                           radius=28, fill=255)
    img.paste(icon, (36, 36), mask)

    d.text((196, 40), a.app_name.upper(), font=font(34, True), fill=brand)
    d.text((196, 84), a.title, font=font(42, True), fill=(20, 20, 20, 255))
    if a.subtitle:
        d.text((196, 136), a.subtitle, font=font(34),
               fill=(90, 90, 90, 255))
    d.text((W - 120, 40), "now", font=font(30), fill=(140, 140, 140, 255))

    img.save(a.output)
    print(f"Wrote {a.output} {img.size}")


if __name__ == "__main__":
    main()
