#!/usr/bin/env python3
"""Reflection slideshow builder - TikTok carousel PNGs + Ken Burns mp4.

The "verses for when you feel X" format: hook card, N verse slides
(cover art + Arabic key phrase + gem line + reference), lock-screen CTA card.
All text is pulled from the app's own data so nothing is re-authored:
  - Arabic phrases   : exact word-index slices of widget_daily.json arabic
  - gem lines        : widget_reflections.json verses[key].gems[i].en
  - widget CTA line  : widget_reflections.json verses[key].morning.en

Usage:
  source .venv/bin/activate
  python3 scripts/build_reflection_slideshow.py \
      --config assets/premium-art/tiktok/reflection_slideshow/heart_feels_tight.json

Outputs <outdir>/<slug>/slide_01.png ... slide_NN.png (1080x1920, post as a
native TikTok photo carousel + trending audio picked in-app) and
<outdir>/<slug>/<slug>.mp4 (Ken Burns version for Reels/Shorts, ambient bed).

Requires: PIL built with raqm (Arabic shaping), ffmpeg. Zero AI credits.
"""
import argparse, json, os, subprocess, sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

W, H, FPS = 1080, 1920, 30
IVORY = (243, 236, 217)
GOLD = (217, 179, 106)
SAND = (255, 233, 189)
DIM = (216, 210, 194)
SCRIM = (12, 10, 8)  # warm near-black

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
F = os.path.join(ROOT, "Thaqalayn", "Fonts")
SERIF_SB = os.path.join(F, "CormorantGaramond-SemiBold.ttf")
SERIF_MED = os.path.join(F, "CormorantGaramond-Medium.ttf")
SERIF_IT = os.path.join(F, "CormorantGaramond-MediumItalic.ttf")
AMIRI = os.path.join(F, "Amiri-Regular.ttf")


def font(path, size):
    return ImageFont.truetype(path, size)


def cover_fill(path, blur=0, darken=0.0, focus_x=0.5, crop_top=0.0):
    if not os.path.isabs(path):
        path = os.path.join(ROOT, path)
    img = Image.open(path).convert("RGB")
    if crop_top:
        img = img.crop((0, round(img.height * crop_top), img.width, img.height))
    scale = H / img.height
    img = img.resize((round(img.width * scale), H), Image.LANCZOS)
    x0 = round((img.width - W) * focus_x)
    img = img.crop((x0, 0, x0 + W, H))
    if blur:
        img = img.filter(ImageFilter.GaussianBlur(blur))
    if darken:
        img = Image.blend(img, Image.new("RGB", (W, H), SCRIM), darken)
    return img


def add_gradient(img, y_from, y_to, max_alpha):
    """Darken linearly: alpha 0 at y_from, max_alpha at y_to (either direction),
    clamped constant beyond each end."""
    grad = Image.new("L", (1, H), 0)
    for y in range(H):
        t = (y - y_from) / (y_to - y_from)
        grad.putpixel((0, y), round(max_alpha * min(1.0, max(0.0, t))))
    overlay = Image.new("RGB", (W, H), SCRIM)
    img.paste(overlay, (0, 0), grad.resize((W, H)))
    return img


def wrap(draw, text, fnt, max_w, direction=None):
    lines, cur = [], ""
    for word in text.split():
        trial = f"{cur} {word}".strip()
        if draw.textlength(trial, font=fnt, direction=direction) <= max_w or not cur:
            cur = trial
        else:
            lines.append(cur)
            cur = word
    if cur:
        lines.append(cur)
    return lines


def draw_centered(draw, text, fnt, fill, y, direction=None):
    w = draw.textlength(text, font=fnt, direction=direction)
    draw.text(((W - w) / 2, y), text, font=fnt, fill=fill, direction=direction)


def draw_tracked(draw, text, fnt, fill, y, tracking=8):
    widths = [draw.textlength(c, font=fnt) for c in text]
    total = sum(widths) + tracking * (len(text) - 1)
    x = (W - total) / 2
    for c, cw in zip(text, widths):
        draw.text((x, y), c, font=fnt, fill=fill)
        x += cw + tracking


def fit_arabic(draw, text, max_w, start=78, floor=56):
    """Shrink until the phrase fits one line; wrap to two lines as last resort."""
    for size in range(start, floor - 1, -2):
        fnt = font(AMIRI, size)
        if draw.textlength(text, font=fnt, direction="rtl") <= max_w:
            return fnt, [text]
    fnt = font(AMIRI, floor)
    return fnt, wrap(draw, text, fnt, max_w, direction="rtl")


def rounded_panel(img, box, radius, fill_alpha, border_alpha):
    panel = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    pd = ImageDraw.Draw(panel)
    pd.rounded_rectangle(box, radius=radius, fill=(255, 255, 255, fill_alpha),
                         outline=(255, 255, 255, border_alpha), width=2)
    img.paste(Image.new("RGB", (W, H), (250, 246, 236)), (0, 0), panel)


# ---------- slides ----------

def hook_slide(cfg):
    img = cover_fill(cfg["hook"]["cover"], blur=22, darken=0.62)
    img = add_gradient(img, 900, 1920, 140)
    d = ImageDraw.Draw(img)
    big, sub = cfg["hook"]["big"], cfg["hook"]["sub"]
    draw_centered(d, big, font(SERIF_SB, 170), IVORY, 620)
    sub_lines = wrap(d, sub, font(SERIF_IT, 66), 820)
    y = 880
    for ln in sub_lines:
        draw_centered(d, ln, font(SERIF_IT, 66), SAND, y)
        y += 84
    d.rectangle([(W - 70) / 2, y + 60, (W + 70) / 2, y + 63], fill=GOLD)
    draw_tracked(d, cfg["hook"].get("hint", "KEEP SWIPING"), font(SERIF_MED, 30), DIM, 1470, 10)
    return img


def verse_slide(slide, arabic_phrase, gem, ref):
    img = cover_fill(slide["cover"], focus_x=slide.get("focus_x", 0.5))
    img = add_gradient(img, 680, 60, 130)    # top scrim for Arabic
    img = add_gradient(img, 880, 1920, 225)  # bottom scrim for gem
    d = ImageDraw.Draw(img)

    afnt, alines = fit_arabic(d, arabic_phrase, 940)
    ay = 330 if len(alines) == 1 else 260
    for ln in alines:
        draw_centered(d, ln, afnt, SAND, ay, direction="rtl")
        ay += round(afnt.size * 1.55)

    gfnt = font(SERIF_SB, 58)
    glines = wrap(d, gem, gfnt, 880)
    line_h = 76
    y = 1400 - line_h * len(glines)   # block bottom-anchored above ref
    for ln in glines:
        draw_centered(d, ln, gfnt, IVORY, y)
        y += line_h
    d.rectangle([(W - 70) / 2, y + 28, (W + 70) / 2, y + 31], fill=GOLD)
    draw_tracked(d, ref, font(SERIF_MED, 36), GOLD, y + 64, 10)
    return img


def quote_slide(slide, text, speaker, book, context=None):
    img = cover_fill(slide["cover"], focus_x=slide.get("focus_x", 0.5),
                     crop_top=slide.get("crop_top", 0.0))
    img = add_gradient(img, 680, 60, 130)    # top scrim for attribution
    img = add_gradient(img, 880, 1920, 225)  # bottom scrim for quote
    d = ImageDraw.Draw(img)

    draw_tracked(d, speaker.upper(), font(SERIF_SB, 40), GOLD, 330, 10)
    if context:
        draw_centered(d, context, font(SERIF_IT, 40), DIM, 410)

    size = 84 if len(text) <= 32 else 62
    qfnt = font(SERIF_SB, size)
    qlines = wrap(d, text, qfnt, 880)
    line_h = round(size * 1.3)
    y = 1400 - line_h * len(qlines)
    for ln in qlines:
        draw_centered(d, ln, qfnt, IVORY, y)
        y += line_h
    d.rectangle([(W - 70) / 2, y + 28, (W + 70) / 2, y + 31], fill=GOLD)
    if book:
        draw_tracked(d, book.upper(), font(SERIF_MED, 32), GOLD, y + 64, 8)
    return img


def cta_slide(cfg, widget_line):
    cta = cfg["cta"]
    img = cover_fill(cta["cover"], blur=26, darken=0.58)
    img = add_gradient(img, 1000, 1920, 150)
    d = ImageDraw.Draw(img)

    draw_centered(d, cta["date"], font(SERIF_MED, 42), DIM, 300)
    draw_centered(d, cta["clock"], font(SERIF_MED, 210), IVORY, 350)

    box = (110, 760, 970, 1120)
    rounded_panel(img, box, 44, 34, 46)
    d = ImageDraw.Draw(img)
    d.text((170, 806), "DAILY REFLECTION", font=font(SERIF_SB, 30), fill=GOLD)
    wfnt = font(SERIF_MED, 40)
    y = 866
    for ln in wrap(d, widget_line, wfnt, 740):
        d.text((170, y), ln, font=wfnt, fill=IVORY)
        y += 52

    y = 1250
    for ln in [cta["line1"], cta["line2"]]:
        draw_centered(d, ln, font(SERIF_IT, 52), SAND, y)
        y += 70
    draw_tracked(d, cta["brand"], font(SERIF_SB, 34), GOLD, y + 60, 8)
    return img


# ---------- mp4 ----------

def run(args, name):
    p = subprocess.run(args, capture_output=True, text=True)
    if p.returncode != 0:
        print(f"FAIL {name}\n{p.stderr[-3000:]}")
        sys.exit(1)
    print(f"ok {name}")


def build_mp4(pngs, outdir, slug, workdir):
    durs = [2.6] + [3.4] * (len(pngs) - 2) + [4.6]
    enc = ["-r", str(FPS), "-c:v", "libx264", "-crf", "16",
           "-preset", "veryfast", "-pix_fmt", "yuv420p"]
    segs = []
    for i, (png, dur) in enumerate(zip(pngs, durs)):
        n = int(dur * FPS)
        zoom = (f"1+0.07*on/{n - 1}" if i % 2 == 0 else f"1.07-0.07*on/{n - 1}")
        fc = (f"[0:v]scale=1620:2880:flags=lanczos,select='eq(n\\,0)',"
              f"zoompan=d={n}:z='{zoom}':x='(iw-iw/zoom)/2':y='(ih-ih/zoom)/2':"
              f"s={W}x{H}:fps={FPS}[v]")
        seg = os.path.join(workdir, f"seg{i}.mp4")
        run(["ffmpeg", "-y", "-loglevel", "error", "-loop", "1", "-t", str(dur),
             "-i", png, "-filter_complex", fc, "-map", "[v]", "-t", str(dur),
             *enc, seg], f"seg{i}")
        segs.append(seg)

    offs, acc = [], 0.0
    for dd in durs[:-1]:
        acc += dd - 0.5
        offs.append(round(acc, 2))
    total = round(offs[-1] + durs[-1], 2)
    fc, prev = "", "0:v"
    for i, o in enumerate(offs):
        out = f"x{i}" if i < len(offs) - 1 else "vout"
        fc += f"[{prev}][{i + 1}:v]xfade=transition=fade:duration=0.5:offset={o}[{out}];"
        prev = out
    fc += (f"anoisesrc=color=brown:r=48000:d={total},lowpass=f=240,volume=0.35,"
           f"tremolo=f=0.1:d=0.5[nz];"
           f"sine=frequency=52:r=48000:d={total},volume=0.08,tremolo=f=0.13:d=0.5[dr];"
           f"[nz][dr]amix=inputs=2:duration=first,afade=t=in:d=1.0,"
           f"afade=t=out:st={total - 2.2}:d=2.2[aout]")
    dst = os.path.join(outdir, f"{slug}.mp4")
    run(["ffmpeg", "-y", "-loglevel", "error",
         *sum([["-i", s] for s in segs], []),
         "-filter_complex", fc, "-map", "[vout]", "-map", "[aout]",
         "-c:v", "libx264", "-crf", "19", "-preset", "slow", "-pix_fmt", "yuv420p",
         "-c:a", "aac", "-b:a", "128k", "-movflags", "+faststart",
         "-t", str(total), dst], "final")
    print(f"DONE {dst} total={total}s")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--config", required=True)
    ap.add_argument("--skip-mp4", action="store_true")
    a = ap.parse_args()
    cfg = json.load(open(a.config))
    slug = cfg["slug"]

    refl_all = json.load(open(os.path.join(ROOT, "Thaqalayn/Data/widget_reflections.json")))
    reflections, journeys = refl_all["verses"], refl_all["journeys"]
    daily = json.load(open(os.path.join(ROOT, "Thaqalayn/Data/widget_daily.json")))["verses"]

    outdir = os.path.join(ROOT, cfg.get("outdir", "assets/premium-art/tiktok/reflection_slideshow"), slug)
    workdir = os.path.join(outdir, "work")
    os.makedirs(workdir, exist_ok=True)

    pngs = []

    def save(img, i, label):
        p = os.path.join(outdir, f"slide_{i:02d}.png")
        img.save(p)
        pngs.append(p)
        print(f"ok slide {i} ({label})")

    save(hook_slide(cfg), 1, "hook")
    for i, slide in enumerate(cfg["slides"], start=2):
        if slide.get("type", "verse") == "quote":
            line = journeys[slide["journey"]]["lines"][slide["line"]]
            parts = (line.get("source") or "").split(" - ", 1)
            speaker = slide.get("speaker", parts[0])
            book = slide.get("book", parts[1] if len(parts) > 1 else None)
            save(quote_slide(slide, line["en"], speaker, book,
                             slide.get("context")), i, f"{slide['journey']}#{slide['line']}")
        else:
            key = slide["key"]
            w0, w1 = slide["arabic_words"]
            arabic = " ".join(daily[key]["arabic"].split()[w0:w1 + 1])
            gem = reflections[key]["gems"][slide["gem_index"]]["en"]
            ref = f"QUR'AN {key.replace(':', ' : ')}"
            save(verse_slide(slide, arabic, gem, ref), i, key)
    cta = cfg["cta"]
    if "widget_journey" in cta:
        widget_line = journeys[cta["widget_journey"]]["lines"][cta["widget_line"]]["en"]
    else:
        widget_line = reflections[cta["widget_key"]]["morning"]["en"]
    save(cta_slide(cfg, widget_line), len(cfg["slides"]) + 2, "cta")

    if not a.skip_mp4:
        build_mp4(pngs, outdir, slug, workdir)


if __name__ == "__main__":
    main()
