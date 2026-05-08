"""Pre-render the cyan-glow header overlay PNG with PIL.

Output: 1080x220 transparent PNG with two text lines:
  Line 1: SURAH {NAME}
  Line 2: AYAT {N}
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter


HEADER_W = 1080
HEADER_H = 260
GLOW_COLOR = (0, 229, 255, 230)   # cyan
FILL_COLOR = (245, 255, 255, 255) # near-white
STROKE_COLOR = (0, 100, 140, 255) # dark cyan stroke
GLOW_BLUR_RADIUS = 14
STROKE_WIDTH = 4


def render_header(surah_name: str, ayat: int, output_path: Path, font_path: Path,
                  font_size: int = 70) -> Path:
    output_path = Path(output_path)
    font_path = Path(font_path)
    if not font_path.exists():
        raise FileNotFoundError(f"Font missing: {font_path}")

    line1 = f"SURAH {surah_name}"
    line2 = f"AYAT {ayat}"
    font = ImageFont.truetype(str(font_path), font_size)

    # Glow layer (text drawn in cyan, blurred large)
    glow = Image.new("RGBA", (HEADER_W, HEADER_H), (0, 0, 0, 0))
    gdraw = ImageDraw.Draw(glow)
    _draw_two_lines(gdraw, line1, line2, font, fill=GLOW_COLOR, stroke=None)
    glow = glow.filter(ImageFilter.GaussianBlur(GLOW_BLUR_RADIUS))

    # Sharp text layer on top with stroke
    sharp = Image.new("RGBA", (HEADER_W, HEADER_H), (0, 0, 0, 0))
    sdraw = ImageDraw.Draw(sharp)
    _draw_two_lines(sdraw, line1, line2, font, fill=FILL_COLOR,
                    stroke=(STROKE_COLOR, STROKE_WIDTH))

    composed = Image.alpha_composite(glow, sharp)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    composed.save(output_path, "PNG")
    return output_path


def _draw_two_lines(draw: ImageDraw.ImageDraw, line1: str, line2: str,
                    font: ImageFont.FreeTypeFont, fill, stroke):
    # Use the ACTUAL ink-box (textbbox) for vertical layout, not font metrics.
    # Display fonts like Bowlby One have glyphs that extend above the metric
    # ascent line, and stroke_width adds further padding. textbbox accounts
    # for both, so the visible text top is exactly where we expect it.
    sw = stroke[1] if stroke else 0
    bbox1 = draw.textbbox((0, 0), line1, font=font, stroke_width=sw)
    bbox2 = draw.textbbox((0, 0), line2, font=font, stroke_width=sw)
    h1 = bbox1[3] - bbox1[1]
    h2 = bbox2[3] - bbox2[1]
    w1 = bbox1[2] - bbox1[0]
    w2 = bbox2[2] - bbox2[0]
    gap = 14
    total_h = h1 + gap + h2

    # Visual top of line 1 should sit at (HEADER_H - total_h) // 2.
    # Drawing at draw_y means the visible top is at draw_y + bbox[1], so
    # draw_y = visual_top - bbox[1].
    visual_top_1 = (HEADER_H - total_h) // 2
    draw_y_1 = visual_top_1 - bbox1[1]
    visual_top_2 = visual_top_1 + h1 + gap
    draw_y_2 = visual_top_2 - bbox2[1]

    x1 = (HEADER_W - w1) / 2 - bbox1[0]
    x2 = (HEADER_W - w2) / 2 - bbox2[0]

    kwargs = {"fill": fill, "anchor": "lt"}
    if stroke:
        kwargs["stroke_fill"] = stroke[0]
        kwargs["stroke_width"] = stroke[1]
    draw.text((x1, draw_y_1), line1, font=font, **kwargs)
    draw.text((x2, draw_y_2), line2, font=font, **kwargs)
