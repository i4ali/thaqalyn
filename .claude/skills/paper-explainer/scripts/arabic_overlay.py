#!/usr/bin/env python3
"""Typeset real Arabic onto a generated still (fixes local models' garbled Arabic; free, exact).

usage: arabic_overlay.py --image in.png --out out.png --text "سورة الكوثر" \
         (--box x,y,w,h [--rotate DEG] | --quad "x1,y1 x2,y2 x3,y3 x4,y4")   # TL TR BR BL, image pixels
         [--font "Diwan Thuluth"] [--style ink|gold|cut] [--color "#1d3b2a"] [--align center|right|left]
         [--pad 0.08] [--crop preview.jpg]
  Repeat the run for each text region. Fonts by name from /System/Library/Fonts (+Supplemental) or a path:
  headings: "Diwan Thuluth", "Diwan Kufi"; verses with harakat: "Mishafi Gold", "DecoTypeNaskh", "GeezaPro".
Styles: ink = flat ink that picks up the paper fibre; gold = gold-leaf fill with sheen and a tiny cast shadow;
        cut = raised paper letters (light top edge, soft shadow beneath). Text is fitted to the region width
(or height if that binds), shaped with raqm (RTL + ligatures + tashkeel), then perspective-warped into the quad.
"""
import argparse, glob, math, os, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageChops

FONT_DIRS = ["/System/Library/Fonts", "/System/Library/Fonts/Supplemental", "/Library/Fonts", os.path.expanduser("~/Library/Fonts")]

def find_font(name):
    if os.path.exists(name): return name
    for d in FONT_DIRS:
        for ext in (".ttf", ".ttc", ".otf"):
            for cand in glob.glob(os.path.join(d, "*" + ext)):
                base = os.path.basename(cand)[:-len(ext)].replace(" ", "").lower()
                if base == name.replace(" ", "").lower(): return cand
    sys.exit(f"font not found: {name}")

FALLBACKS = {"\u0671": "\u0627"}   # alef wasla -> alef (Diwan Thuluth, DecoType Naskh lack U+0671)

def fit_text_to_font(text, font_path):
    """Replace characters the font cannot show (checked via its cmap) with safe equivalents."""
    try:
        from fontTools.ttLib import TTFont
        cmap = TTFont(font_path, fontNumber=0).getBestCmap()
    except Exception:
        return text
    out = []
    for ch in text:
        if ord(ch) in cmap or ch.isspace(): out.append(ch)
        elif ch in FALLBACKS and ord(FALLBACKS[ch]) in cmap: out.append(FALLBACKS[ch])
        elif "\u064b" <= ch <= "\u0652" or ch == "\u0670": continue   # drop a haraka the font lacks rather than draw a box
        else: out.append(ch)
    fixed = "".join(out)
    if fixed != text: print("note: substituted characters missing from the font:", repr(text), "->", repr(fixed))
    return fixed

def parse_quad(a, W, H):
    if a.quad:
        pts = [tuple(float(v) for v in p.split(",")) for p in a.quad.split()]
        assert len(pts) == 4, "--quad needs 4 points"
        return pts
    x, y, w, h = (float(v) for v in a.box.split(","))
    cx, cy = x + w / 2, y + h / 2
    r = math.radians(a.rotate)
    def rot(px, py):
        dx, dy = px - cx, py - cy
        return (cx + dx * math.cos(r) - dy * math.sin(r), cy + dx * math.sin(r) + dy * math.cos(r))
    return [rot(x, y), rot(x + w, y), rot(x + w, y + h), rot(x, y + h)]

def persp_coeffs(src, dst):
    # PIL transform maps OUTPUT (dst) -> INPUT (src); solve for the 8 coefficients
    A = []
    for (x, y), (X, Y) in zip(dst, src):
        A.append([x, y, 1, 0, 0, 0, -X * x, -X * y]); A.append([0, 0, 0, x, y, 1, -Y * x, -Y * y])
    B = np.array([c for p in src for c in p], dtype=float)
    return np.linalg.solve(np.array(A, dtype=float), B).tolist()

def hex_rgb(s):
    s = s.lstrip("#"); return tuple(int(s[i:i + 2], 16) for i in (0, 2, 4))

def render_text_layer(text, font_path, target_w, target_h, pad, align, color, style):
    """Text layer (RGBA) at the quad's straight size, text fitted inside the padded box."""
    tw, th = int(target_w * (1 - 2 * pad)), int(target_h * (1 - 2 * pad))
    size = 40
    def measure(sz):
        f = ImageFont.truetype(font_path, sz, layout_engine=ImageFont.Layout.RAQM)
        l, t, r, b = f.getbbox(text, direction="rtl", language="ar")
        return f, (r - l, b - t), (l, t)
    f, (w, h), _ = measure(size)
    scale = min(tw / max(w, 1), th / max(h, 1))
    f, (w, h), (l, t) = measure(max(8, int(size * scale)))
    layer = Image.new("RGBA", (int(target_w), int(target_h)), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    x = {"center": (target_w - w) / 2, "right": target_w - w - pad * target_w, "left": pad * target_w}[align] - l
    y = (target_h - h) / 2 - t
    if style == "gold":
        # gold leaf: vertical warm gradient with sheen bands + fine noise, masked by the glyphs
        mask = Image.new("L", layer.size, 0); ImageDraw.Draw(mask).text((x, y), text, font=f, fill=255, direction="rtl", language="ar")
        yy = np.linspace(0, 1, layer.size[1])[:, None]
        sheen = 0.55 + 0.45 * np.sin(yy * 9.0 + np.linspace(0, 1.5, layer.size[0])[None, :])
        base = np.array([212, 170, 60], dtype=float)[None, None, :] * (0.75 + 0.35 * sheen[..., None])
        noise = np.random.default_rng(3).normal(0, 9, base.shape)
        rgb = np.clip(base + noise, 0, 255).astype(np.uint8)
        fill = Image.fromarray(rgb, "RGB").convert("RGBA"); fill.putalpha(mask)
        layer = fill
    else:
        d.text((x, y), text, font=f, fill=color + (255,), direction="rtl", language="ar")
    return layer

def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--image", required=True); ap.add_argument("--out", required=True); ap.add_argument("--text", required=True)
    ap.add_argument("--box"); ap.add_argument("--rotate", type=float, default=0.0); ap.add_argument("--quad")
    ap.add_argument("--font", default="Diwan Thuluth"); ap.add_argument("--style", default="ink", choices=["ink", "gold", "cut"])
    ap.add_argument("--color", default="#1d3b2a"); ap.add_argument("--align", default="center", choices=["center", "right", "left"])
    ap.add_argument("--pad", type=float, default=0.08); ap.add_argument("--crop", help="write a zoomed preview of the region")
    a = ap.parse_args()
    if not (a.box or a.quad): sys.exit("give --box or --quad")

    img = Image.open(a.image).convert("RGB"); W, H = img.size
    quad = parse_quad(a, W, H)
    # straight size of the quad = average of opposite edges
    def dist(p, q): return math.hypot(p[0] - q[0], p[1] - q[1])
    qw = (dist(quad[0], quad[1]) + dist(quad[3], quad[2])) / 2
    qh = (dist(quad[0], quad[3]) + dist(quad[1], quad[2])) / 2
    S = 2  # supersample
    font_path = find_font(a.font)
    layer = render_text_layer(fit_text_to_font(a.text, font_path), font_path, qw * S, qh * S, a.pad, a.align, hex_rgb(a.color), a.style)

    # warp the straight layer into the quad (full-canvas output)
    src = [(0, 0), (qw * S, 0), (qw * S, qh * S), (0, qh * S)]
    coeffs = persp_coeffs(src, quad)
    warped = layer.transform((W, H), Image.Transform.PERSPECTIVE, coeffs, resample=Image.Resampling.BICUBIC)
    alpha = warped.getchannel("A")

    # paper fibre: modulate the text colour by the local luminance of the still (normalised)
    lum = np.asarray(img.convert("L"), dtype=float)
    blurred = np.asarray(img.convert("L").filter(ImageFilter.GaussianBlur(25)), dtype=float)
    fibre = np.clip(lum / np.maximum(blurred, 1), 0.6, 1.4)
    rgb = np.asarray(warped.convert("RGB"), dtype=float) * fibre[..., None]
    text_rgb = Image.fromarray(np.clip(rgb, 0, 255).astype(np.uint8), "RGB")

    out = img.copy()
    if a.style in ("gold", "cut"):
        # soft cast shadow below-right, as if the letters were cut and glued on
        sh = alpha.filter(ImageFilter.GaussianBlur(2.5 if a.style == "gold" else 4))
        sh = ImageChops.offset(sh, 2 if a.style == "gold" else 4, 3 if a.style == "gold" else 5)
        shadow = Image.new("RGB", (W, H), (40, 28, 12))
        out = Image.composite(shadow, out, sh.point(lambda v: int(v * (0.45 if a.style == "gold" else 0.55))))
        if a.style == "cut":
            # light top-left edge for the raised paper look
            edge = ImageChops.subtract(alpha, ImageChops.offset(alpha, 2, 2))
            out = Image.composite(Image.new("RGB", (W, H), (255, 250, 235)), out, edge.point(lambda v: int(v * 0.8)))
    else:
        # ink sinks into paper: slightly soften and multiply
        alpha = alpha.filter(ImageFilter.GaussianBlur(0.6))
    out = Image.composite(text_rgb, out, alpha)
    out.save(a.out)
    if a.crop:
        xs = [p[0] for p in quad]; ys = [p[1] for p in quad]
        m = 40; box = (max(0, int(min(xs)) - m), max(0, int(min(ys)) - m), min(W, int(max(xs)) + m), min(H, int(max(ys)) + m))
        c = out.crop(box); c = c.resize((int(c.width * 900 / c.width), int(c.height * 900 / c.width))); c.save(a.crop, quality=92)
    print("wrote", a.out)

if __name__ == "__main__":
    main()
