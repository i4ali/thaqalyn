# Dhul-Hijjah Journey Carousel — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.
>
> **Commits:** This repo's owner commits manually. Do NOT run `git commit`. Where a step says "Stage", run only `git add` and stop.

**Goal:** Produce a 5-slide, dark-and-dramatic, 1080×1350 promotional carousel for the app's Dhul-Hijjah Journey feature using Nano Banana backgrounds + PIL-composited text.

**Architecture:** A small Python pipeline. Nano Banana Pro (OpenRouter) generates 5 text-free dark atmospheric backgrounds; PIL (with the `raqm` layout engine for correct Arabic shaping) composites pixel-accurate English + verified Arabic typography and the slide-5 CTA. A central config module holds all copy, colors, paths, and fonts so content lives in one place. A pytest module structurally validates the 5 output PNGs.

**Tech Stack:** Python 3.13 (`.venv`), `requests`, `python-dotenv`, Pillow 12.1 (`raqm` enabled), OpenRouter model `google/gemini-3-pro-image-preview`. Fonts: `/System/Library/Fonts/SFArabic.ttf` (Arabic), `/System/Library/Fonts/Supplemental/Arial Bold.ttf` (English display/body).

**Reference:** Existing Nano Banana usage pattern: `.claude/skills/generate-verse-art/scripts/generate_art.py` (API auth, headers, response parsing).

**Spec:** `docs/superpowers/specs/2026-05-16-dhul-hijjah-carousel-design.md`

---

## File Structure

- `scripts/dhul_hijjah_carousel/__init__.py` — package marker
- `scripts/dhul_hijjah_carousel/config.py` — all copy, colors, dimensions, font paths, slide definitions
- `scripts/dhul_hijjah_carousel/backgrounds.py` — Nano Banana background generation + normalize to 1080×1350
- `scripts/dhul_hijjah_carousel/compose.py` — PIL text/CTA compositor
- `scripts/dhul_hijjah_carousel/build.py` — orchestrator CLI
- `tests/dhul_hijjah_carousel/test_outputs.py` — structural validation of final PNGs
- `tests/dhul_hijjah_carousel/test_config.py` — config invariants
- `dhul_hijjah_carousel/` — OUTPUT folder: `slide_1.png` … `slide_5.png` (+ `backgrounds/` subfolder for raw bg cache)

All commands run from repo root with the venv: prefix python calls with `.venv/bin/python`.

---

## Task 1: Package scaffold + config module

**Files:**
- Create: `scripts/dhul_hijjah_carousel/__init__.py`
- Create: `scripts/dhul_hijjah_carousel/config.py`
- Create: `tests/dhul_hijjah_carousel/__init__.py`
- Test: `tests/dhul_hijjah_carousel/test_config.py`

- [ ] **Step 1: Write the failing test**

`tests/dhul_hijjah_carousel/test_config.py`:
```python
from scripts.dhul_hijjah_carousel import config


def test_canvas_is_4x5_portrait():
    assert config.CANVAS_W == 1080
    assert config.CANVAS_H == 1350


def test_five_slides_defined_in_order():
    slides = config.SLIDES
    assert [s["index"] for s in slides] == [1, 2, 3, 4, 5]
    roles = [s["role"] for s in slides]
    assert roles == ["hook", "pillar", "pillar", "pillar", "cta"]


def test_every_slide_has_required_fields():
    for s in config.SLIDES:
        assert s["headline"], f"slide {s['index']} missing headline"
        assert s["bg_prompt"], f"slide {s['index']} missing bg_prompt"
        # Arabic only allowed on slide 2 and must be flagged unverified until approved
        if s.get("arabic"):
            assert s["index"] == 2
            assert s["arabic_verified"] in (True, False)


def test_fonts_exist():
    import os
    assert os.path.exists(config.FONT_ARABIC)
    assert os.path.exists(config.FONT_DISPLAY)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_config.py -v`
Expected: FAIL — `ModuleNotFoundError: scripts.dhul_hijjah_carousel`

- [ ] **Step 3: Create package markers**

`scripts/dhul_hijjah_carousel/__init__.py`: empty file.
`tests/dhul_hijjah_carousel/__init__.py`: empty file.

- [ ] **Step 4: Write `scripts/dhul_hijjah_carousel/config.py`**

```python
"""Single source of truth: copy, colors, dimensions, fonts, slide defs."""
from pathlib import Path

# Canvas — 4:5 portrait
CANVAS_W = 1080
CANVAS_H = 1350

# Palette — dark & dramatic, gold typography
COLOR_BG_FALLBACK = (8, 9, 14)        # near-black, used if bg fails
COLOR_GOLD = (230, 122, 60)           # brand #E67A3C
COLOR_GOLD_BRIGHT = (247, 197, 110)   # brighter gold for glow/headlines
COLOR_CREAM = (240, 233, 220)         # body text on dark
COLOR_DIM = (170, 162, 150)           # captions / sources

# Fonts (macOS system)
FONT_ARABIC = "/System/Library/Fonts/SFArabic.ttf"
FONT_DISPLAY = "/System/Library/Fonts/Supplemental/Arial Bold.ttf"
FONT_BODY = "/System/Library/Fonts/Supplemental/Arial.ttf"

# Paths
OUTPUT_DIR = Path("dhul_hijjah_carousel")
BG_DIR = OUTPUT_DIR / "backgrounds"
APP_ICON = Path("appicon.png")

# Shared background style appended to every bg prompt
BG_STYLE = (
    "Dark, dramatic, reverent, cinematic spiritual atmosphere. Deep near-black "
    "night palette with a single warm gold light source. Abstract, no text, no "
    "letters, no words, no human figures, no faces, no animals. Minimal, "
    "elegant, lots of negative space. Subtle film grain. 4:5 vertical portrait."
)

SLIDES = [
    {
        "index": 1,
        "role": "hook",
        "headline": "You're about to waste\nthe best 10 days\nof the year.",
        "subtext": "The first ten days of Dhul-Hijjah",
        "arabic": None,
        "arabic_verified": None,
        "bg_prompt": "A vast dark night sky over a tiny distant silhouette of "
                     "the Kaaba on the horizon, faint warm glow rising behind it.",
    },
    {
        "index": 2,
        "role": "pillar",
        "headline": "The most beloved days to Allah",
        "subtext": ("“There are no days in which righteous deeds are more "
                    "beloved to Allah than these ten days.”\n— the "
                    "Prophet ﷺ"),
        # Arabic stays None until Task 3 approval gate fills it in.
        "arabic": None,
        "arabic_verified": False,
        "bg_prompt": "Shafts of warm golden light breaking dramatically through "
                     "heavy dark clouds in a near-black sky.",
    },
    {
        "index": 3,
        "role": "pillar",
        "headline": "And most of us\nlet them slip by.",
        "subtext": ("Fasting · dhikr · repentance · the Day of "
                    "Arafah — the day of forgiveness. Gone, unnoticed, "
                    "every single year."),
        "arabic": None,
        "arabic_verified": None,
        "bg_prompt": "A row of dim hanging brass lanterns fading into deep "
                     "darkness, one faint warm glow remaining.",
    },
    {
        "index": 4,
        "role": "pillar",
        "headline": "This year, don't.",
        "subtext": ("The Dhul-Hijjah Journey walks you through all 10 days — "
                    "a dua, verses, and a reflection each day, building to "
                    "Arafah and Eid al-Adha."),
        "arabic": None,
        "arabic_verified": None,
        "bg_prompt": "First light of dawn breaking over a still dark desert, a "
                     "warm gold band on the horizon promising sunrise.",
    },
    {
        "index": 5,
        "role": "cta",
        "headline": "Don't do these\n10 days alone.",
        "subtext": "Download Thaqalayn — free on the App Store",
        "arabic": None,
        "arabic_verified": None,
        "bg_prompt": "Minimal dark backdrop with a soft centered warm gold "
                     "radial glow, deep vignette edges.",
    },
]
```

- [ ] **Step 5: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_config.py -v`
Expected: PASS (4 tests)

- [ ] **Step 6: Stage**

```bash
git add scripts/dhul_hijjah_carousel/__init__.py scripts/dhul_hijjah_carousel/config.py tests/dhul_hijjah_carousel/
```
Do NOT commit. Report staged files to the user.

---

## Task 2: Nano Banana background generation + normalize

**Files:**
- Create: `scripts/dhul_hijjah_carousel/backgrounds.py`
- Test: `tests/dhul_hijjah_carousel/test_backgrounds.py`

Nano Banana does not guarantee exact pixel dimensions, so every returned image is
center-cropped to 4:5 and resized to exactly 1080×1350. The API call is mocked in
tests (no network in CI).

- [ ] **Step 1: Write the failing test**

`tests/dhul_hijjah_carousel/test_backgrounds.py`:
```python
from PIL import Image
from scripts.dhul_hijjah_carousel import backgrounds, config


def test_normalize_crops_and_resizes_to_canvas():
    wide = Image.new("RGB", (2000, 1000), (10, 10, 10))
    out = backgrounds.normalize(wide)
    assert out.size == (config.CANVAS_W, config.CANVAS_H)
    assert out.mode == "RGB"


def test_normalize_tall_image():
    tall = Image.new("RGB", (1000, 4000), (10, 10, 10))
    out = backgrounds.normalize(tall)
    assert out.size == (config.CANVAS_W, config.CANVAS_H)


def test_build_bg_prompt_includes_shared_style_and_no_text_rule():
    p = backgrounds.build_bg_prompt(config.SLIDES[0])
    assert "Kaaba" in p
    assert "no text" in p.lower()
    assert config.BG_STYLE in p
```

- [ ] **Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_backgrounds.py -v`
Expected: FAIL — `ModuleNotFoundError` / `AttributeError: normalize`

- [ ] **Step 3: Write `scripts/dhul_hijjah_carousel/backgrounds.py`**

```python
"""Generate dark atmospheric backgrounds (no text) via OpenRouter Nano Banana."""
import base64
import os
from io import BytesIO

import requests
from dotenv import load_dotenv
from PIL import Image, ImageOps

from . import config

load_dotenv()

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
MODEL = "google/gemini-3-pro-image-preview"


def build_bg_prompt(slide: dict) -> str:
    return (
        f"Generate a 4:5 vertical portrait image (1080x1350 pixels). "
        f"{slide['bg_prompt']} {config.BG_STYLE}"
    )


def normalize(img: Image.Image) -> Image.Image:
    """Center-crop to 4:5 and resize to exactly the canvas size."""
    img = img.convert("RGB")
    return ImageOps.fit(
        img,
        (config.CANVAS_W, config.CANVAS_H),
        method=Image.LANCZOS,
        centering=(0.5, 0.5),
    )


def _request_image(prompt: str) -> bytes:
    if not OPENROUTER_API_KEY:
        raise ValueError("OPENROUTER_API_KEY not found in .env")
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://thaqalayn.app",
        "X-Title": "Thaqalayn Dhul-Hijjah Carousel",
    }
    payload = {
        "model": MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "modalities": ["image", "text"],
    }
    resp = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers=headers, json=payload, timeout=120,
    )
    if resp.status_code != 200:
        raise Exception(f"API error {resp.status_code}: {resp.text}")
    message = resp.json()["choices"][0]["message"]
    for img in message.get("images", []):
        url = img.get("image_url", {}).get("url", "")
        if url.startswith("data:"):
            return base64.b64decode(url.split(",", 1)[1])
        if url:
            r = requests.get(url, timeout=60)
            r.raise_for_status()
            return r.content
    raise Exception(f"No image in response: {resp.json()}")


def generate(slide: dict) -> Image.Image:
    raw = _request_image(build_bg_prompt(slide))
    return normalize(Image.open(BytesIO(raw)))


def generate_all() -> dict:
    """Generate + cache all 5 backgrounds. Returns {index: Path}."""
    config.BG_DIR.mkdir(parents=True, exist_ok=True)
    out = {}
    for slide in config.SLIDES:
        path = config.BG_DIR / f"bg_{slide['index']}.png"
        img = generate(slide)
        img.save(path)
        print(f"  bg slide {slide['index']} -> {path}")
        out[slide["index"]] = path
    return out
```

- [ ] **Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_backgrounds.py -v`
Expected: PASS (3 tests)

- [ ] **Step 5: Stage**

```bash
git add scripts/dhul_hijjah_carousel/backgrounds.py tests/dhul_hijjah_carousel/test_backgrounds.py
```
Do NOT commit.

---

## Task 3: Slide-2 hadith Arabic approval gate (BLOCKING — manual)

**Files:**
- Modify: `scripts/dhul_hijjah_carousel/config.py` (fill slide 2 `arabic` + set `arabic_verified=True`)

This task has no automated test — it is a human approval checkpoint required by the
spec's Section 6 (Arabic is never AI-generated; the hadith wording must be
explicitly approved before any render).

- [ ] **Step 1: Present the proposed Arabic to the user**

Show the user this proposed wording for slide 2 and ask for explicit approval or a
correction:

> Proposed Slide-2 hadith Arabic (well-attested wording, to be confirmed):
> `مَا مِنْ أَيَّامٍ الْعَمَلُ الصَّالِحُ فِيهِنَّ أَحَبُّ إِلَى اللَّهِ مِنْ هَذِهِ الْأَيَّامِ الْعَشْرِ`
> English already in config: "There are no days in which righteous deeds are more
> beloved to Allah than these ten days." — the Prophet ﷺ
>
> Please confirm this exact Arabic, OR paste the exact wording/diacritics/source
> you want used. Nothing will be rendered until you reply.

Do not proceed to Step 2 until the user replies with approved text.

- [ ] **Step 2: Apply the user-approved Arabic to config**

Edit `scripts/dhul_hijjah_carousel/config.py`, slide index 2 dict: set
`"arabic"` to the EXACT user-approved string and `"arabic_verified": True`.
(If the user supplied a different wording/source, use theirs verbatim.)

- [ ] **Step 3: Add a guard test**

Append to `tests/dhul_hijjah_carousel/test_config.py`:
```python
def test_slide2_arabic_must_be_verified_before_render():
    s2 = next(s for s in config.SLIDES if s["index"] == 2)
    if s2["arabic"]:
        assert s2["arabic_verified"] is True, (
            "Slide 2 Arabic present but not user-verified — render must not proceed"
        )
```

- [ ] **Step 4: Run config tests**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_config.py -v`
Expected: PASS

- [ ] **Step 5: Stage**

```bash
git add scripts/dhul_hijjah_carousel/config.py tests/dhul_hijjah_carousel/test_config.py
```
Do NOT commit.

---

## Task 4: PIL typography compositor (slides 1–4)

**Files:**
- Create: `scripts/dhul_hijjah_carousel/compose.py`
- Test: `tests/dhul_hijjah_carousel/test_compose.py`

Arabic is rendered with the `raqm` layout engine (Pillow 12.1 has it) for correct
shaping + RTL — no reshaper libs needed. Headlines get a soft gold glow (blurred
duplicate underneath). Text is laid out within a centered safe column.

- [ ] **Step 1: Write the failing test**

`tests/dhul_hijjah_carousel/test_compose.py`:
```python
from PIL import Image
from scripts.dhul_hijjah_carousel import compose, config


def _blank_bg():
    return Image.new("RGB", (config.CANVAS_W, config.CANVAS_H), (8, 9, 14))


def test_wrap_text_respects_max_width():
    lines = compose.wrap("a " * 60, compose._font(config.FONT_BODY, 40), 800)
    assert len(lines) > 1
    assert all(isinstance(ln, str) for ln in lines)


def test_render_slide_returns_exact_canvas():
    img = compose.render_slide(config.SLIDES[0], _blank_bg())
    assert img.size == (config.CANVAS_W, config.CANVAS_H)
    assert img.mode == "RGB"


def test_render_slide_changes_pixels():
    bg = _blank_bg()
    out = compose.render_slide(config.SLIDES[0], bg.copy())
    assert list(out.getdata()) != list(bg.getdata()), "no text drawn"


def test_arabic_renders_when_present_and_verified():
    slide = dict(config.SLIDES[1])
    slide["arabic"] = "لا إله إلا الله"
    slide["arabic_verified"] = True
    out = compose.render_slide(slide, _blank_bg())
    assert out.size == (config.CANVAS_W, config.CANVAS_H)


def test_render_slide_refuses_unverified_arabic():
    slide = dict(config.SLIDES[1])
    slide["arabic"] = "anything"
    slide["arabic_verified"] = False
    try:
        compose.render_slide(slide, _blank_bg())
        assert False, "should have raised"
    except ValueError as e:
        assert "verified" in str(e).lower()
```

- [ ] **Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_compose.py -v`
Expected: FAIL — `ModuleNotFoundError` / missing attributes

- [ ] **Step 3: Write `scripts/dhul_hijjah_carousel/compose.py`**

```python
"""Composite verified text onto backgrounds. Arabic via raqm layout engine."""
from functools import lru_cache

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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_compose.py -v`
Expected: PASS (5 tests)

- [ ] **Step 5: Stage**

```bash
git add scripts/dhul_hijjah_carousel/compose.py tests/dhul_hijjah_carousel/test_compose.py
```
Do NOT commit.

---

## Task 5: Slide-5 CTA composite (app icon + store button)

**Files:**
- Modify: `scripts/dhul_hijjah_carousel/compose.py` (add `render_cta`)
- Test: `tests/dhul_hijjah_carousel/test_compose.py` (append)

Slide 5 uses its own renderer: rounded app-icon mockup + a self-contained
"Download free on the App Store" pill button (not Apple's trademarked badge —
this is a non-clickable promo, a styled CTA is appropriate and safe).

- [ ] **Step 1: Write the failing test**

Append to `tests/dhul_hijjah_carousel/test_compose.py`:
```python
def test_render_cta_returns_exact_canvas_and_draws():
    bg = Image.new("RGB", (config.CANVAS_W, config.CANVAS_H), (8, 9, 14))
    out = compose.render_cta(config.SLIDES[4], bg.copy())
    assert out.size == (config.CANVAS_W, config.CANVAS_H)
    assert list(out.getdata()) != list(bg.getdata())
```

- [ ] **Step 2: Run test to verify it fails**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_compose.py::test_render_cta_returns_exact_canvas_and_draws -v`
Expected: FAIL — `AttributeError: render_cta`

- [ ] **Step 3: Add `render_cta` to `compose.py`**

Add these imports at the top of `compose.py` if not present: `from pathlib import Path`.
Append this function to `scripts/dhul_hijjah_carousel/compose.py`:
```python
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
    label = "Download free on the App Store"
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
```

- [ ] **Step 4: Run test to verify it passes**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_compose.py -v`
Expected: PASS (6 tests)

- [ ] **Step 5: Stage**

```bash
git add scripts/dhul_hijjah_carousel/compose.py tests/dhul_hijjah_carousel/test_compose.py
```
Do NOT commit.

---

## Task 6: Orchestrator + final structural validation

**Files:**
- Create: `scripts/dhul_hijjah_carousel/build.py`
- Test: `tests/dhul_hijjah_carousel/test_outputs.py`

- [ ] **Step 1: Write the failing test**

`tests/dhul_hijjah_carousel/test_outputs.py`:
```python
import pytest
from PIL import Image
from scripts.dhul_hijjah_carousel import config

OUTPUTS = [config.OUTPUT_DIR / f"slide_{i}.png" for i in range(1, 6)]


@pytest.mark.parametrize("path", OUTPUTS)
def test_slide_exists_and_is_exact_canvas(path):
    if not path.exists():
        pytest.skip(f"{path} not generated yet (run build.py to produce)")
    with Image.open(path) as im:
        assert im.size == (config.CANVAS_W, config.CANVAS_H)
        assert im.mode == "RGB"
    assert path.stat().st_size > 20_000, "suspiciously small image"
```

- [ ] **Step 2: Run test to verify it skips (no outputs yet)**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/test_outputs.py -v`
Expected: 5 SKIPPED

- [ ] **Step 3: Write `scripts/dhul_hijjah_carousel/build.py`**

```python
"""Build the 5-slide Dhul-Hijjah carousel: backgrounds -> compose -> save."""
import sys

from PIL import Image

from . import backgrounds, compose, config


def main(skip_bg: bool = False):
    config.OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

    # Hard gate: slide 2 Arabic must be verified before any render
    s2 = next(s for s in config.SLIDES if s["index"] == 2)
    if s2.get("arabic") and not s2.get("arabic_verified"):
        raise SystemExit("ABORT: Slide 2 Arabic not user-verified (see Task 3).")

    if not skip_bg:
        print("Generating backgrounds (Nano Banana)...")
        backgrounds.generate_all()

    for slide in config.SLIDES:
        bg_path = config.BG_DIR / f"bg_{slide['index']}.png"
        if not bg_path.exists():
            raise SystemExit(f"Missing background: {bg_path}")
        bg = Image.open(bg_path)
        if slide["role"] == "cta":
            out = compose.render_cta(slide, bg)
        else:
            out = compose.render_slide(slide, bg)
        dest = config.OUTPUT_DIR / f"slide_{slide['index']}.png"
        out.save(dest)
        print(f"  saved {dest}")
    print("Done. 5 slides in", config.OUTPUT_DIR)


if __name__ == "__main__":
    main(skip_bg="--skip-bg" in sys.argv)
```

- [ ] **Step 4: Run the real build (network — generates images)**

Run: `.venv/bin/python -m scripts.dhul_hijjah_carousel.build`
Expected: prints 5 background lines + 5 "saved" lines, no error.
If OpenRouter credit/network fails, fix and re-run — per repo policy do NOT add
fallback logic; let it fail loudly.

- [ ] **Step 5: Run final validation**

Run: `.venv/bin/python -m pytest tests/dhul_hijjah_carousel/ -v`
Expected: ALL PASS — including 5 `test_outputs` now non-skipped at 1080×1350.

- [ ] **Step 6: Visual review checkpoint (manual)**

Open `dhul_hijjah_carousel/slide_1.png` … `slide_5.png`. Confirm with the user:
legibility at feed size, gold-on-dark consistency, Arabic shaping correct on
slide 2, app icon + pill correct on slide 5. Regenerate any weak background by
deleting `dhul_hijjah_carousel/backgrounds/bg_N.png` and re-running
`build.py` (it regenerates only missing backgrounds if `--skip-bg` is omitted;
to recompose text only without new bg, use `--skip-bg`).

- [ ] **Step 7: Stage**

```bash
git add scripts/dhul_hijjah_carousel/build.py tests/dhul_hijjah_carousel/test_outputs.py
```
Do NOT commit. Note: the `dhul_hijjah_carousel/` output PNGs are deliverables —
ask the user whether to stage them or add to `.gitignore`.

---

## Self-Review

**Spec coverage:**
- Goal / App Store install driver → Task 5 CTA pill + Task 1 slide 5 copy ✓
- 5 slides Hook→3 pillars→CTA → Task 1 `SLIDES` (roles enforced by test) ✓
- Dark & dramatic, gold typography → Task 1 palette, Task 4 glow + dark overlay ✓
- 1080×1350 PNG → Task 2 `normalize`, Task 6 `test_outputs` exact-size assertion ✓
- Nano Banana backgrounds only, no text/faces → Task 2 `BG_STYLE` + `build_bg_prompt` ✓
- Text composited, never AI → Task 4/5 PIL render ✓
- Arabic verified, never AI, user-approved before render → Task 3 gate + refusal in `render_slide` + abort in `build.main` ✓
- Output to `dhul_hijjah_carousel/` → Task 1 `OUTPUT_DIR`, Task 6 ✓
- App icon + store badge on slide 5 → Task 5 ✓
- Non-goals (no video/animation/per-day/app changes) → respected; nothing in plan adds them ✓

**Placeholder scan:** No TBD/TODO; all code blocks complete; Task 3's manual gate has concrete proposed text. ✓

**Type consistency:** `config.SLIDES` dict keys (`index, role, headline, subtext, arabic, arabic_verified, bg_prompt`) used identically across backgrounds.py, compose.py, build.py. `normalize`, `render_slide`, `render_cta`, `generate_all`, `build_bg_prompt` names consistent between definitions, tests, and callers. ✓
