"""Composite verified text onto backgrounds. Arabic via raqm layout engine."""
from functools import lru_cache
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

from . import config

SAFE_W = 880          # centered text column width
MARGIN_X = (config.CANVAS_W - SAFE_W) // 2


@lru_cache(maxsize=32)
def _font(path: str, size: int) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(path, size, layout_engine=ImageFont.Layout.RAQM)


def wrap(text: str, font: ImageFont.FreeTypeFont, max_w: int) -> list:
    words, lines, cur = text.split(), [], ""
    for w in words:
        trial = f"{cur} {w}".strip()
        if font.getlength(trial) <= max_w:
            cur = trial
        else:
            if cur:
                lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def _draw_block(draw, text, font, fill, y, line_h, glow=None, rtl=False):
    for raw_line in text.split("\n"):
        for line in (wrap(raw_line, font, SAFE_W) or [""]):
            w = font.getlength(line)
            x = (config.CANVAS_W - w) / 2
            if glow is not None:
                draw.text((x, y), line, font=font, fill=glow,
                          direction="rtl" if rtl else "ltr")
            draw.text((x, y), line, font=font, fill=fill,
                      direction="rtl" if rtl else "ltr")
            y += line_h
    return y


def render_slide(slide: dict, bg: Image.Image) -> Image.Image:
    if slide.get("arabic") and not slide.get("arabic_verified"):
        raise ValueError(
            f"Slide {slide['index']} has unverified Arabic — refusing to render"
        )

    img = bg.convert("RGB").copy()
    # Darken for text legibility
    overlay = Image.new("RGB", img.size, (0, 0, 0))
    img = Image.blend(img, overlay, 0.35)

    head_f = _font(config.FONT_DISPLAY, 92)
    body_f = _font(config.FONT_BODY, 44)
    sub_f = _font(config.FONT_BODY, 38)
    ar_f = _font(config.FONT_ARABIC, 60)

    # --- glow layer for the headline ---
    glow_layer = Image.new("RGBA", img.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow_layer)
    _draw_block(gd, slide["headline"], head_f, config.COLOR_GOLD_BRIGHT,
                420, 108)
    glow_layer = glow_layer.filter(ImageFilter.GaussianBlur(18))
    img = Image.alpha_composite(img.convert("RGBA"), glow_layer).convert("RGB")

    draw = ImageDraw.Draw(img)
    y = _draw_block(draw, slide["headline"], head_f,
                    config.COLOR_GOLD_BRIGHT, 420, 108)

    if slide.get("arabic") and slide.get("arabic_verified"):
        y += 40
        y = _draw_block(draw, slide["arabic"], ar_f, config.COLOR_GOLD,
                        y, 92, rtl=True)

    if slide.get("subtext"):
        y += 50
        _draw_block(draw, slide["subtext"], body_f, config.COLOR_CREAM,
                    y, 58)
    return img


def _rounded(img: Image.Image, radius: int) -> Image.Image:
    from PIL import ImageOps
    mask = Image.new("L", img.size, 0)
    md = ImageDraw.Draw(mask)
    md.rounded_rectangle([0, 0, img.size[0], img.size[1]], radius, fill=255)
    out = ImageOps.fit(img, img.size)
    out.putalpha(mask)
    return out


def render_cta(slide: dict, bg: Image.Image) -> Image.Image:
    img = bg.convert("RGB").copy()
    overlay = Image.new("RGB", img.size, (0, 0, 0))
    img = Image.blend(img, overlay, 0.45).convert("RGBA")

    # App icon mockup, centered upper area
    icon_size = 300
    if config.APP_ICON.exists():
        icon = Image.open(config.APP_ICON).convert("RGBA")
        icon = icon.resize((icon_size, icon_size), Image.LANCZOS)
        icon = _rounded(icon, 66)
        img.alpha_composite(icon, ((config.CANVAS_W - icon_size) // 2, 300))

    draw = ImageDraw.Draw(img)
    head_f = _font(config.FONT_DISPLAY, 88)
    _draw_block(draw, slide["headline"], head_f,
                config.COLOR_GOLD_BRIGHT, 680, 104)

    # "Download free on the App Store" pill
    pill_f = _font(config.FONT_DISPLAY, 40)
    label = "Download on the App Store — link in bio"
    tw = pill_f.getlength(label)
    pad_x, pad_y = 56, 34
    pw, ph = tw + pad_x * 2, 40 + pad_y * 2
    px = (config.CANVAS_W - pw) / 2
    py = 980
    draw.rounded_rectangle([px, py, px + pw, py + ph], radius=ph / 2,
                           fill=config.COLOR_GOLD)
    draw.text((px + pad_x, py + pad_y - 4), label, font=pill_f,
              fill=(12, 10, 8))
    return img.convert("RGB")


def render_appshot(slide: dict, bg: Image.Image) -> Image.Image:
    img = bg.convert("RGB").copy()
    overlay = Image.new("RGB", img.size, (0, 0, 0))
    img = Image.blend(img, overlay, 0.55).convert("RGBA")

    draw = ImageDraw.Draw(img)
    head_f = _font(config.FONT_DISPLAY, 84)
    _draw_block(draw, slide["headline"], head_f,
                config.COLOR_GOLD_BRIGHT, 90, 100)
    body_f = _font(config.FONT_BODY, 38)
    _draw_block(draw, slide["subtext"], body_f, config.COLOR_CREAM, 210, 50)

    shot = Image.open(config.APP_SCREENSHOT).convert("RGBA")
    dev_h = 960
    dev_w = round(dev_h * shot.width / shot.height)
    shot = shot.resize((dev_w, dev_h), Image.LANCZOS)
    radius = 48
    shot = _rounded(shot, radius)

    cx = (config.CANVAS_W - dev_w) // 2
    cy = 350

    shadow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    sd = ImageDraw.Draw(shadow)
    sd.rounded_rectangle([cx, cy + 18, cx + dev_w, cy + dev_h + 18],
                         radius=radius, fill=(0, 0, 0, 170))
    shadow = shadow.filter(ImageFilter.GaussianBlur(30))
    img = Image.alpha_composite(img, shadow)

    glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.rounded_rectangle([cx - 6, cy - 6, cx + dev_w + 6, cy + dev_h + 6],
                         radius=radius + 6,
                         outline=config.COLOR_GOLD + (255,), width=6)
    glow = glow.filter(ImageFilter.GaussianBlur(10))
    img = Image.alpha_composite(img, glow)

    img.alpha_composite(shot, (cx, cy))
    return img.convert("RGB")
