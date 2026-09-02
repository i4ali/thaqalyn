#!/usr/bin/env python3
"""Overlay shaped Arabic (or any) text on a still, or emit a transparent PNG to overlay on a clip.

usage: overlay_arabic.py --text "سُورَةُ الْفِيل" --out out.png [--in still.png | --canvas 720x1280]
       [--font /System/Library/Fonts/GeezaPro.ttc] [--size 0.06] [--x 0.5 --y 0.12] [--anchor mm]
       [--color "#d4af37"] [--shadow 0.18] [--outline 0]

--size is a fraction of the canvas height; --x/--y are fractions of width/height; --anchor is a
PIL anchor (mm centre, ma top-centre, ...). --shadow adds a soft dark drop shadow (opacity 0..1)
so gold reads on cream and on dark sky. Arabic is shaped with arabic_reshaper + python-bidi.
For clips: emit with --canvas WxH and composite: ffmpeg -i clip.mp4 -i text.png -filter_complex overlay ...
"""
import argparse
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import arabic_reshaper
from bidi.algorithm import get_display

ap = argparse.ArgumentParser()
ap.add_argument("--text", required=True); ap.add_argument("--out", required=True)
ap.add_argument("--in", dest="inp"); ap.add_argument("--canvas")
ap.add_argument("--font", default="/System/Library/Fonts/GeezaPro.ttc"); ap.add_argument("--font-index", type=int, default=0)
ap.add_argument("--size", type=float, default=0.06); ap.add_argument("--x", type=float, default=0.5); ap.add_argument("--y", type=float, default=0.12)
ap.add_argument("--anchor", default="mm"); ap.add_argument("--color", default="#d4af37")
ap.add_argument("--shadow", type=float, default=0.18); ap.add_argument("--outline", type=int, default=0)
ap.add_argument("--rotate", type=float, default=0.0, help="degrees, counter-clockwise, about the text anchor (match a tilted page)")
ap.add_argument("--quad", help="TL,TR,BR,BL as 8 fractions x1,y1,...: perspective-warp the text box onto this quad (page plane)")
ap.add_argument("--weight", type=float, default=0.0018, help="foil only: extra stroke as a fraction of canvas height, fattens thin calligraphy")
ap.add_argument("--blind", type=float, default=0.0, help="foil only: 0 = gold paint, 1 = blind emboss (letters keep the paper pixels, tinted); 0.6 = light foil press")
ap.add_argument("--foil", action="store_true", help="gold-foil look: darker outline + light highlight, for headings printed on a page")
a = ap.parse_args()

if a.inp:
    base = Image.open(a.inp).convert("RGBA")
else:
    w, h = map(int, a.canvas.lower().split("x")); base = Image.new("RGBA", (w, h), (0, 0, 0, 0))
W, H = base.size
from PIL import features
RAQM = features.check("raqm")
if RAQM:   # raqm shapes + orders RTL itself; feeding it pre-shaped text mirrors the glyphs
    shaped = a.text; kw = {"direction": "rtl"}
    font = ImageFont.truetype(a.font, int(a.size * H), index=a.font_index, layout_engine=ImageFont.Layout.RAQM)
else:
    cfg = arabic_reshaper.ArabicReshaper({"delete_harakat": False, "support_ligatures": True})
    shaped = get_display(cfg.reshape(a.text)); kw = {}
    font = ImageFont.truetype(a.font, int(a.size * H), index=a.font_index, layout_engine=ImageFont.Layout.BASIC)
layer = Image.new("RGBA", base.size, (0, 0, 0, 0)); d = ImageDraw.Draw(layer)
x, y = a.x * W, a.y * H
if a.shadow > 0:
    sh = Image.new("RGBA", base.size, (0, 0, 0, 0)); ds = ImageDraw.Draw(sh)
    ds.text((x + H * 0.004, y + H * 0.006), shaped, font=font, fill=(0, 0, 0, int(255 * a.shadow)), anchor=a.anchor, **kw)
    sh = sh.filter(ImageFilter.GaussianBlur(H * 0.006)); layer = Image.alpha_composite(layer, sh); d = ImageDraw.Draw(layer)
if a.foil:
    import numpy as np
    # 1. glyph mask
    m = Image.new("L", base.size, 0); ImageDraw.Draw(m).text((x, y), shaped, font=font, fill=255, anchor=a.anchor, stroke_width=max(1, int(round(H * a.weight))), stroke_fill=255, **kw)
    M = np.array(m).astype(np.float32) / 255.0
    bb = m.getbbox(); top, bot = bb[1], bb[3]
    k = max(1, int(round(H * 0.0016)))
    up = np.roll(np.roll(M, -k, 0), -k, 1); dn = np.roll(np.roll(M, k, 0), k, 1)
    hi = np.clip(M - dn, 0, 1); sh = np.clip(M - up, 0, 1)   # highlight on the up-left edges, shadow on the down-right
    rng = np.random.default_rng(7)
    # A. gold paint: metallic gradient (light gold at the top of the line -> deeper gold at the bottom) + grain
    yy = np.linspace(0, 1, H)[:, None]; t = np.clip((yy - top / H) / max(1e-6, (bot - top) / H), 0, 1)
    c1 = np.array([214, 178, 84], np.float32); c2 = np.array([134, 101, 30], np.float32)
    gold = c1 * (1 - t) + c2 * t; gold = np.broadcast_to(gold[:, None, :], (H, W, 3)).copy() + rng.normal(0, 6, (H, W, 1))
    gold = gold * (1 - hi[..., None] * 0.85) + np.array([250, 238, 190], np.float32) * hi[..., None] * 0.85
    gold = gold * (1 - sh[..., None] * 0.75) + np.array([70, 50, 12], np.float32) * sh[..., None] * 0.75
    # B. blind emboss: the paper itself, warm-tinted a touch darker, relief from a soft light edge and a shadow edge
    paper = np.array(base.convert("RGB")).astype(np.float32)
    blind = paper * np.array([0.93, 0.84, 0.66], np.float32)
    blind = blind * (1 - hi[..., None] * 0.7) + np.array([255, 250, 232], np.float32) * hi[..., None] * 0.7
    blind = blind * (1 - sh[..., None] * 0.6) + np.array([115, 88, 48], np.float32) * sh[..., None] * 0.6
    fill = gold * (1 - a.blind) + blind * a.blind
    rgba = np.dstack([np.clip(fill, 0, 255), M * 255]).astype(np.uint8)
    glyphs = Image.fromarray(rgba, "RGBA")
    # 4. soft cast shadow into the paper, offset down-right
    shl = Image.new("RGBA", base.size, (0, 0, 0, 0)); shl.paste(Image.new("RGBA", base.size, (60, 40, 10, int(255 * max(a.shadow, 0.35)))), (int(H * 0.003), int(H * 0.004)), m)
    shl = shl.filter(ImageFilter.GaussianBlur(H * 0.003))
    layer = Image.alpha_composite(Image.alpha_composite(Image.new("RGBA", base.size, (0, 0, 0, 0)), shl), glyphs)
else:
    d.text((x, y), shaped, font=font, fill=a.color, anchor=a.anchor, stroke_width=a.outline, stroke_fill=(30, 20, 10, 200) if a.outline else None, **kw)
if a.quad:
    import numpy as np, cv2
    q = [float(v) for v in a.quad.split(",")]
    dst = np.float32([[q[0] * W, q[1] * H], [q[2] * W, q[3] * H], [q[4] * W, q[5] * H], [q[6] * W, q[7] * H]])
    bb = layer.getbbox()  # text box in the flat layer
    src = np.float32([[bb[0], bb[1]], [bb[2], bb[1]], [bb[2], bb[3]], [bb[0], bb[3]]])
    Mp = cv2.getPerspectiveTransform(src, dst)
    arr = cv2.warpPerspective(np.array(layer), Mp, (W, H), flags=cv2.INTER_CUBIC, borderValue=(0, 0, 0, 0))
    layer = Image.fromarray(arr, "RGBA")
if a.rotate:
    layer = layer.rotate(a.rotate, resample=Image.BICUBIC, center=(x, y))
out = Image.alpha_composite(base, layer)
(out.convert("RGB") if a.out.lower().endswith((".jpg", ".jpeg")) else out).save(a.out)
print("wrote", a.out, base.size)
