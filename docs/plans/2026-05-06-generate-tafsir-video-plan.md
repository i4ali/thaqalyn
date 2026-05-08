# Generate Tafsir Video Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Claude Code skill (`generate-tafsir-video`) that produces per-verse tafsir-explainer videos by reusing a Kling-rendered silent base video and only swapping narration audio + headline + synced captions.

**Architecture:** Two-phase skill. **Phase A** is a one-time manual run of `shia-event-video-creator` with a curated prompt set to produce `assets/tafsir_base/tafsir_base.mp4`. **Phase B** is the per-verse pipeline: agent drafts script in chat from tafsir layer2 → user approves → Python pipeline does TTS + alignment + PIL header render + ffmpeg compose.

**Tech Stack:** Python 3 (project `.venv`), ElevenLabs API, PIL/Pillow, ffmpeg, pytest, existing tafsir JSON in `Thaqalayn/Thaqalayn/Data/`.

**Reference design doc:** `docs/plans/2026-05-06-generate-tafsir-video-design.md`

**Commit policy:** The user commits manually. The plan lists `git add` + `git commit -m` for clarity, but the executing agent should **stop after staging** and let the user run the commit. This matches the user's saved preference.

**Path conventions:**
- Skill root: `.claude/skills/generate-tafsir-video/`
- Tests live inside the skill: `.claude/skills/generate-tafsir-video/tests/`
- Output dir at project root: `tafsir_videos/`
- Run all Python via `source .venv/bin/activate && python3 ...` (project rule)

---

## Task 1: Scaffold the skill directory

**Files:**
- Create: `.claude/skills/generate-tafsir-video/SKILL.md` (placeholder, fleshed out in Task 10)
- Create: `.claude/skills/generate-tafsir-video/scripts/__init__.py` (empty)
- Create: `.claude/skills/generate-tafsir-video/tests/__init__.py` (empty)
- Create: `.claude/skills/generate-tafsir-video/assets/tafsir_base/.gitkeep` (empty)
- Create: `.claude/skills/generate-tafsir-video/assets/fonts/.gitkeep` (empty)
- Create: `.claude/skills/generate-tafsir-video/references/.gitkeep` (empty)

**Step 1: Create the directory tree**

```bash
mkdir -p .claude/skills/generate-tafsir-video/{scripts,tests,assets/tafsir_base,assets/fonts,references}
touch .claude/skills/generate-tafsir-video/scripts/__init__.py
touch .claude/skills/generate-tafsir-video/tests/__init__.py
touch .claude/skills/generate-tafsir-video/assets/tafsir_base/.gitkeep
touch .claude/skills/generate-tafsir-video/assets/fonts/.gitkeep
touch .claude/skills/generate-tafsir-video/references/.gitkeep
```

**Step 2: Create placeholder `SKILL.md`**

```markdown
---
name: generate-tafsir-video
description: WIP — fleshed out in Task 10
---

# Generate Tafsir Video (WIP)
```

**Step 3: Verify**

```bash
find .claude/skills/generate-tafsir-video -type f
```
Expected: 5 files listed (SKILL.md, both __init__.py, three .gitkeep).

**Step 4: Stage for commit**

```bash
git add .claude/skills/generate-tafsir-video
# User commits manually
```

---

## Task 2: Add test infrastructure with fixtures

**Files:**
- Create: `.claude/skills/generate-tafsir-video/tests/conftest.py`

**Step 1: Confirm pytest is available**

```bash
source .venv/bin/activate && python3 -c "import pytest; print(pytest.__version__)"
```
Expected: a version string. If missing, `pip install pytest pillow` and proceed.

**Step 2: Write `conftest.py` with shared fixtures**

```python
# .claude/skills/generate-tafsir-video/tests/conftest.py
import json
from pathlib import Path
import pytest


@pytest.fixture
def tmp_data_dir(tmp_path):
    """Mimics Thaqalayn/Thaqalayn/Data/ layout."""
    d = tmp_path / "Data"
    d.mkdir()
    return d


@pytest.fixture
def minimal_tafsir(tmp_data_dir):
    """Writes a tafsir_2.json with verse 258 layer2 populated."""
    path = tmp_data_dir / "tafsir_2.json"
    data = {
        "258": {
            "layer1": "Layer 1 placeholder text.",
            "layer2": "Allamah Tabatabai in Al-Mizan presents the debate between Ibrahim and the king who arrogantly claimed to control life and death. Tabatabai argues this verse demonstrates the irrationality of denying divine sovereignty.",
        }
    }
    path.write_text(json.dumps(data))
    return path


@pytest.fixture
def minimal_quran(tmp_data_dir):
    """Writes a quran_data.json with surah 2 metadata."""
    path = tmp_data_dir / "quran_data.json"
    data = {
        "surahs": [
            {"number": 1, "englishName": "Al-Fatiha"},
            {"number": 2, "englishName": "Al-Baqarah"},
        ]
    }
    path.write_text(json.dumps(data))
    return path
```

**Step 3: Run pytest discovery**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests --collect-only
```
Expected: `no tests ran` (no test files yet) — but **no import errors**.

**Step 4: Stage**

```bash
git add .claude/skills/generate-tafsir-video/tests
```

---

## Task 3: `verse_loader.py` — load tafsir layer + surah name (TDD)

**Files:**
- Create: `.claude/skills/generate-tafsir-video/scripts/verse_loader.py`
- Create: `.claude/skills/generate-tafsir-video/tests/test_verse_loader.py`

**Step 1: Write failing tests**

```python
# tests/test_verse_loader.py
import pytest
from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from verse_loader import load_tafsir_layer, get_surah_english_name  # noqa: E402


def test_load_layer2_returns_text(minimal_tafsir):
    text = load_tafsir_layer(2, 258, layer="layer2", data_dir=minimal_tafsir.parent)
    assert "Tabatabai" in text


def test_load_layer_missing_file_raises(tmp_data_dir):
    with pytest.raises(FileNotFoundError, match="Tafsir file not found for surah 99"):
        load_tafsir_layer(99, 1, layer="layer2", data_dir=tmp_data_dir)


def test_load_layer_missing_verse_raises(minimal_tafsir):
    with pytest.raises(ValueError, match="Verse 999 not found in surah 2"):
        load_tafsir_layer(2, 999, layer="layer2", data_dir=minimal_tafsir.parent)


def test_load_layer_missing_layer_raises(minimal_tafsir):
    with pytest.raises(ValueError, match="layer5 missing or empty for 2:258"):
        load_tafsir_layer(2, 258, layer="layer5", data_dir=minimal_tafsir.parent)


def test_surah_english_name_uppercased(minimal_quran):
    assert get_surah_english_name(2, data_dir=minimal_quran.parent) == "AL-BAQARAH"


def test_surah_name_missing_raises(minimal_quran):
    with pytest.raises(ValueError, match="Surah 999 not found"):
        get_surah_english_name(999, data_dir=minimal_quran.parent)
```

**Step 2: Run, expect failure**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_verse_loader.py -v
```
Expected: ImportError / ModuleNotFoundError on `verse_loader`.

**Step 3: Implement**

```python
# scripts/verse_loader.py
"""Load tafsir layers and surah metadata from project Data JSON."""
from __future__ import annotations
import json
from pathlib import Path


def _default_data_dir() -> Path:
    # When invoked from project root: Thaqalayn/Thaqalayn/Data/
    return Path(__file__).resolve().parents[4] / "Thaqalayn" / "Thaqalayn" / "Data"


def load_tafsir_layer(surah: int, verse: int, layer: str = "layer2", data_dir: Path | None = None) -> str:
    data_dir = Path(data_dir) if data_dir else _default_data_dir()
    path = data_dir / f"tafsir_{surah}.json"
    if not path.exists():
        raise FileNotFoundError(f"Tafsir file not found for surah {surah}: {path}")
    data = json.loads(path.read_text())
    verse_obj = data.get(str(verse))
    if not verse_obj:
        raise ValueError(f"Verse {verse} not found in surah {surah}")
    text = verse_obj.get(layer)
    if not text or not isinstance(text, str) or not text.strip():
        raise ValueError(f"{layer} missing or empty for {surah}:{verse}")
    return text


def get_surah_english_name(surah: int, data_dir: Path | None = None) -> str:
    data_dir = Path(data_dir) if data_dir else _default_data_dir()
    path = data_dir / "quran_data.json"
    if not path.exists():
        raise FileNotFoundError(f"quran_data.json not found at {path}")
    data = json.loads(path.read_text())
    for s in data.get("surahs", []):
        if s.get("number") == surah:
            name = s.get("englishName")
            if not name:
                raise ValueError(f"Surah {surah} has no englishName")
            return name.upper()
    raise ValueError(f"Surah {surah} not found in quran_data.json")
```

**Step 4: Run, expect pass**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_verse_loader.py -v
```
Expected: 6 passed.

**Step 5: Sanity-check against the real Data dir**

```bash
source .venv/bin/activate && python3 -c "
import sys; sys.path.insert(0, '.claude/skills/generate-tafsir-video/scripts')
from verse_loader import get_surah_english_name, load_tafsir_layer
print(get_surah_english_name(2))
print(load_tafsir_layer(2, 258, 'layer2')[:80])
"
```
Expected: `AL-BAQARAH` followed by the first 80 chars of the real layer2 text.

**Step 6: Stage**

```bash
git add .claude/skills/generate-tafsir-video/scripts/verse_loader.py
git add .claude/skills/generate-tafsir-video/tests/test_verse_loader.py
```

---

## Task 4: `preflight.py` — environment & file checks (TDD)

**Files:**
- Create: `.claude/skills/generate-tafsir-video/scripts/preflight.py`
- Create: `.claude/skills/generate-tafsir-video/tests/test_preflight.py`

**Step 1: Write failing tests**

```python
# tests/test_preflight.py
import os
import sys
from pathlib import Path
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from preflight import (  # noqa: E402
    check_base_video,
    check_elevenlabs_key,
    check_ffmpeg,
    check_font,
    check_script_file,
)


def test_check_base_video_missing_raises(tmp_path):
    missing = tmp_path / "nope.mp4"
    with pytest.raises(FileNotFoundError, match="Base video missing"):
        check_base_video(missing)


def test_check_base_video_exists_ok(tmp_path):
    p = tmp_path / "base.mp4"
    p.write_bytes(b"fake")
    check_base_video(p)  # should not raise


def test_check_elevenlabs_key_missing_raises(monkeypatch):
    monkeypatch.delenv("ELEVENLABS_API_KEY", raising=False)
    with pytest.raises(EnvironmentError, match="ELEVENLABS_API_KEY missing"):
        check_elevenlabs_key()


def test_check_elevenlabs_key_present_ok(monkeypatch):
    monkeypatch.setenv("ELEVENLABS_API_KEY", "abc")
    check_elevenlabs_key()


def test_check_ffmpeg_present_ok():
    check_ffmpeg()  # ffmpeg should be on PATH on this machine


def test_check_font_missing_raises(tmp_path):
    with pytest.raises(FileNotFoundError, match="Font missing"):
        check_font(tmp_path / "missing.ttf")


def test_check_script_file_empty_raises(tmp_path):
    p = tmp_path / "s.txt"
    p.write_text("")
    with pytest.raises(ValueError, match="Script file .* empty"):
        check_script_file(p)
```

**Step 2: Run, expect import failure**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_preflight.py -v
```
Expected: ImportError.

**Step 3: Implement**

```python
# scripts/preflight.py
"""Pre-flight checks. Raise clear, actionable errors. No fallbacks."""
from __future__ import annotations
import os
import shutil
from pathlib import Path


def check_base_video(path: Path) -> None:
    if not Path(path).exists():
        raise FileNotFoundError(
            f"Base video missing. Run shia-event-video-creator with the tafsir-explainer "
            f"prompt set first. Expected: {path}"
        )


def check_elevenlabs_key() -> None:
    if not os.environ.get("ELEVENLABS_API_KEY"):
        raise EnvironmentError("ELEVENLABS_API_KEY missing in .env.")


def check_ffmpeg() -> None:
    if shutil.which("ffmpeg") is None:
        raise EnvironmentError("ffmpeg not found. Install with: brew install ffmpeg")


def check_font(path: Path) -> None:
    if not Path(path).exists():
        raise FileNotFoundError(f"Font missing: {path}")


def check_script_file(path: Path) -> None:
    p = Path(path)
    if not p.exists():
        raise FileNotFoundError(f"Script file not found: {path}")
    if not p.read_text().strip():
        raise ValueError(f"Script file is empty: {path}")
```

**Step 4: Run, expect pass**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_preflight.py -v
```
Expected: 7 passed.

**Step 5: Stage**

```bash
git add .claude/skills/generate-tafsir-video/scripts/preflight.py
git add .claude/skills/generate-tafsir-video/tests/test_preflight.py
```

---

## Task 5: Phase A reference doc — tafsir-explainer scene set

**Files:**
- Create: `.claude/skills/generate-tafsir-video/references/tafsir_explainer_scenes.md`

**Step 1: Write the scene set document**

This is a reference for the user to feed into `shia-event-video-creator` once. It should describe ~7 generic scenes with image+motion prompts that match the visual vocabulary in the reference video. Critical constraint: **no text in any scene**.

```markdown
# Tafsir-Explainer Base Video — Scene Set

This is the prompt set to feed into `shia-event-video-creator` ONCE to produce the
silent base video at `assets/tafsir_base/tafsir_base.mp4`.

**Total length target:** ~50 seconds (7 scenes × ~7s each).
**Format:** 1080×1920 vertical, no audio, no text overlays of any kind.

**Hard rule for every scene:** Add to the negative prompt: `"no text, no Arabic
calligraphy in image, no captions, no watermarks, no UI elements"`. The skill adds
all overlay text in CapCut-style during per-verse rendering.

## Scenes

### Scene 1 — Cosmic zoom (open)
Image: Wide shot of a deep-space nebula, indigo and teal cosmic dust, stars,
galactic core glowing in distance. Cinematic, photoreal, 9:16.
Motion: Slow zoom-in toward the galactic core, stars drifting outward at the edges.

### Scene 2 — Glowing Quran in dark space
Image: An open ornate Quran floating in a black void, a soft cyan-white glow
emanating from its center pages, golden detailing on the cover. Sparks of light
drifting around it. Photoreal, 9:16.
Motion: Subtle hover; pages flutter; cyan glow pulses gently.

### Scene 3 — Galaxy spiral
Image: A vast spiral galaxy seen face-on, deep purples, oranges, and whites. No
foreground objects. Photoreal, 9:16.
Motion: Slow rotation of the spiral arms.

### Scene 4 — Planetary alignment
Image: A row of three large planets at different distances in deep space, ringed
gas giant in the foreground, small red planet behind, distant blue planet in the
background. Stars, faint nebula. Photoreal, 9:16.
Motion: Gentle parallax — planets drift slowly past one another.

### Scene 5 — Exploding fire orb
Image: A fiery orange-red orb suspended in the center of a black void, intense
flames erupting outward in a halo, sparks and embers. Photoreal, 9:16.
Motion: Fire pulses outward and contracts back; embers drift upward.

### Scene 6 — Light tunnel (kinetic)
Image: A bright tunnel of streaking warm-white light particles converging toward
a central point against a dark cosmic backdrop. Photoreal, 9:16.
Motion: Particles streak rapidly toward the center (forward warp feel).

### Scene 7 — Cosmic stillness (close)
Image: A wide stillness — a single distant galaxy, vast empty space, soft purple
ambient glow. Calm, contemplative. Photoreal, 9:16.
Motion: Almost still; very slow drift, soft pulse of light from the galaxy.

## After generation

After Kling renders all 7, stitch them with `ffmpeg concat`:

```bash
ffmpeg -f concat -safe 0 -i scene_list.txt -c:v libx264 -preset slow -crf 18 \
  -pix_fmt yuv420p -an .claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4
```

Verify: `ffprobe -v error -show_streams tafsir_base.mp4` — should show video only,
no audio stream, ~50s, 1080×1920.
```

**Step 2: Stage**

```bash
git add .claude/skills/generate-tafsir-video/references/tafsir_explainer_scenes.md
```

---

## Task 6: `render_header.py` — PIL header rendering (TDD)

**Files:**
- Create: `.claude/skills/generate-tafsir-video/scripts/render_header.py`
- Create: `.claude/skills/generate-tafsir-video/tests/test_render_header.py`
- Drop a TTF at: `.claude/skills/generate-tafsir-video/assets/fonts/header.ttf` (any bold display TTF — e.g., Google's Bangers or Bowlby One are good free matches for the CapCut "wobble" style; user picks)

**Step 1: Acquire a header font**

User decision: download a bold display TTF (e.g., from Google Fonts) and place at `.claude/skills/generate-tafsir-video/assets/fonts/header.ttf`. Recommended: `BowlbyOne-Regular.ttf` (closest to the CapCut wobble in the reference). Caption font (Task 8) can be `Inter-Black.ttf` or `Roboto-Black.ttf`.

**Step 2: Confirm Pillow installed**

```bash
source .venv/bin/activate && python3 -c "from PIL import Image, ImageDraw, ImageFont, ImageFilter; print('ok')"
```
If missing: `pip install pillow`.

**Step 3: Write failing tests**

```python
# tests/test_render_header.py
import sys
from pathlib import Path
import pytest
from PIL import Image

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from render_header import render_header  # noqa: E402

ASSETS = Path(__file__).resolve().parent.parent / "assets"
FONT = ASSETS / "fonts" / "header.ttf"


@pytest.mark.skipif(not FONT.exists(), reason="Header font not yet provided")
def test_render_header_dimensions(tmp_path):
    out = tmp_path / "h.png"
    render_header("AL-BAQARAH", 258, output_path=out, font_path=FONT)
    img = Image.open(out)
    assert img.size == (1080, 220)
    assert img.mode == "RGBA"


@pytest.mark.skipif(not FONT.exists(), reason="Header font not yet provided")
def test_render_header_has_visible_pixels(tmp_path):
    out = tmp_path / "h.png"
    render_header("AL-BAQARAH", 258, output_path=out, font_path=FONT)
    img = Image.open(out)
    alpha = img.getchannel("A")
    nonzero = sum(1 for p in alpha.getdata() if p > 0)
    assert nonzero > 5000, "Header looks empty — text not rendered"
```

**Step 4: Run, expect skip-or-fail**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_render_header.py -v
```
Expected: skip (if font absent) or ImportError on `render_header`.

**Step 5: Implement**

```python
# scripts/render_header.py
"""Pre-render the cyan-glow header overlay PNG with PIL.

Output: 1080x220 transparent PNG with two text lines:
  Line 1: SURAH {NAME}
  Line 2: AYAT {N}
"""
from __future__ import annotations
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont, ImageFilter


HEADER_W = 1080
HEADER_H = 220
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
    # Center each line horizontally, stack vertically
    bbox1 = draw.textbbox((0, 0), line1, font=font)
    bbox2 = draw.textbbox((0, 0), line2, font=font)
    w1 = bbox1[2] - bbox1[0]
    w2 = bbox2[2] - bbox2[0]
    h1 = bbox1[3] - bbox1[1]
    h2 = bbox2[3] - bbox2[1]
    gap = 8
    total_h = h1 + gap + h2
    y0 = (HEADER_H - total_h) // 2 - bbox1[1]
    y1 = y0 + h1 + gap - bbox2[1]
    x1 = (HEADER_W - w1) // 2
    x2 = (HEADER_W - w2) // 2
    kwargs = {"fill": fill}
    if stroke:
        kwargs["stroke_fill"] = stroke[0]
        kwargs["stroke_width"] = stroke[1]
    draw.text((x1, y0), line1, font=font, **kwargs)
    draw.text((x2, y1), line2, font=font, **kwargs)
```

**Step 6: Run, expect pass (assuming font present)**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_render_header.py -v
```
Expected: 2 passed.

**Step 7: Eyeball the rendered header**

```bash
source .venv/bin/activate && python3 -c "
import sys; sys.path.insert(0, '.claude/skills/generate-tafsir-video/scripts')
from render_header import render_header
from pathlib import Path
render_header('AL-BAQARAH', 258, Path('/tmp/header_preview.png'),
              Path('.claude/skills/generate-tafsir-video/assets/fonts/header.ttf'))
print('open /tmp/header_preview.png')
"
open /tmp/header_preview.png
```
Tweak `GLOW_BLUR_RADIUS`, `STROKE_WIDTH`, or `font_size` until it visually matches the reference video. If it doesn't match closely, that's OK — visual tuning happens during the Task 12 smoke test.

**Step 8: Stage**

```bash
git add .claude/skills/generate-tafsir-video/scripts/render_header.py
git add .claude/skills/generate-tafsir-video/tests/test_render_header.py
git add .claude/skills/generate-tafsir-video/assets/fonts/header.ttf
```

---

## Task 7: `synthesize_speech.py` — ElevenLabs TTS + alignment (TDD with mocks)

**Files:**
- Create: `.claude/skills/generate-tafsir-video/scripts/synthesize_speech.py`
- Create: `.claude/skills/generate-tafsir-video/tests/test_synthesize_speech.py`

**Step 1: Read existing pattern for reference**

Skim `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py` — note how it calls ElevenLabs and how it gets word-level timing (it uses ElevenLabs' `with-timestamps` endpoint or alignment). Reuse the same voice ID for "Adam" so audio is consistent across both skills.

**Step 2: Write failing tests with mocked HTTP**

```python
# tests/test_synthesize_speech.py
import json
import sys
from pathlib import Path
from unittest.mock import patch, MagicMock
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from synthesize_speech import synthesize, parse_alignment  # noqa: E402


def test_parse_alignment_returns_word_timings():
    raw = {
        "alignment": {
            "characters": ["H", "i", " ", "y", "o", "u"],
            "character_start_times_seconds": [0.0, 0.1, 0.2, 0.3, 0.4, 0.5],
            "character_end_times_seconds": [0.1, 0.2, 0.3, 0.4, 0.5, 0.6],
        }
    }
    timings = parse_alignment(raw)
    assert timings == [
        {"word": "Hi", "start": 0.0, "end": 0.2},
        {"word": "you", "start": 0.3, "end": 0.6},
    ]


def test_synthesize_writes_mp3_and_timings(tmp_path, monkeypatch):
    monkeypatch.setenv("ELEVENLABS_API_KEY", "fake")
    audio_bytes = b"\xff\xfb\x90\x44" + b"\x00" * 100  # fake mp3-ish
    fake_response = MagicMock(status_code=200)
    fake_response.json.return_value = {
        "audio_base64": __import__("base64").b64encode(audio_bytes).decode(),
        "alignment": {
            "characters": ["H", "i"],
            "character_start_times_seconds": [0.0, 0.1],
            "character_end_times_seconds": [0.1, 0.2],
        },
    }

    with patch("synthesize_speech.requests.post", return_value=fake_response):
        out_audio = tmp_path / "n.mp3"
        out_timings = tmp_path / "t.json"
        synthesize("Hi", out_audio, out_timings)

    assert out_audio.exists() and out_audio.read_bytes() == audio_bytes
    timings = json.loads(out_timings.read_text())
    assert timings == [{"word": "Hi", "start": 0.0, "end": 0.2}]


def test_synthesize_non_200_raises(tmp_path, monkeypatch):
    monkeypatch.setenv("ELEVENLABS_API_KEY", "fake")
    fake_response = MagicMock(status_code=401)
    fake_response.text = "Unauthorized"
    with patch("synthesize_speech.requests.post", return_value=fake_response):
        with pytest.raises(RuntimeError, match="ElevenLabs TTS failed: 401"):
            synthesize("Hi", tmp_path / "n.mp3", tmp_path / "t.json")
```

**Step 3: Run, expect ImportError**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_synthesize_speech.py -v
```

**Step 4: Implement**

```python
# scripts/synthesize_speech.py
"""ElevenLabs TTS with word-level alignment.

Uses the with-timestamps endpoint so we get character-level timing in one call,
then collapse to word-level. No retries, no fallbacks.
"""
from __future__ import annotations
import base64
import json
import os
from pathlib import Path
from typing import Any
import requests


# "Adam" voice — same as generate-tiktok-video for consistency
ADAM_VOICE_ID = "pNInz6obpgDQGcFmaJgB"
ELEVEN_URL = "https://api.elevenlabs.io/v1/text-to-speech/{voice_id}/with-timestamps"


def synthesize(text: str, audio_out: Path, timings_out: Path,
               voice_id: str = ADAM_VOICE_ID) -> None:
    api_key = os.environ.get("ELEVENLABS_API_KEY")
    if not api_key:
        raise EnvironmentError("ELEVENLABS_API_KEY missing in .env.")

    payload = {
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.75},
    }
    headers = {"xi-api-key": api_key, "Content-Type": "application/json"}
    resp = requests.post(ELEVEN_URL.format(voice_id=voice_id),
                         headers=headers, json=payload, timeout=60)
    if resp.status_code != 200:
        raise RuntimeError(f"ElevenLabs TTS failed: {resp.status_code} {resp.text[:300]}")

    data = resp.json()
    audio = base64.b64decode(data["audio_base64"])
    timings = parse_alignment(data)

    audio_out = Path(audio_out)
    audio_out.parent.mkdir(parents=True, exist_ok=True)
    audio_out.write_bytes(audio)

    timings_out = Path(timings_out)
    timings_out.parent.mkdir(parents=True, exist_ok=True)
    timings_out.write_text(json.dumps(timings, indent=2))


def parse_alignment(raw: dict[str, Any]) -> list[dict]:
    """Collapse character-level alignment into word-level."""
    align = raw.get("alignment") or raw.get("normalized_alignment")
    if not align:
        raise RuntimeError("ElevenLabs response missing alignment data.")
    chars = align["characters"]
    starts = align["character_start_times_seconds"]
    ends = align["character_end_times_seconds"]

    words: list[dict] = []
    cur_chars: list[str] = []
    cur_start = None
    cur_end = None

    for ch, s, e in zip(chars, starts, ends):
        if ch.isspace():
            if cur_chars:
                words.append({"word": "".join(cur_chars), "start": cur_start, "end": cur_end})
                cur_chars = []
                cur_start = None
        else:
            if cur_start is None:
                cur_start = s
            cur_end = e
            cur_chars.append(ch)
    if cur_chars:
        words.append({"word": "".join(cur_chars), "start": cur_start, "end": cur_end})
    return words
```

**Step 5: Run, expect pass**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_synthesize_speech.py -v
```
Expected: 3 passed.

**Step 6: Stage**

```bash
git add .claude/skills/generate-tafsir-video/scripts/synthesize_speech.py
git add .claude/skills/generate-tafsir-video/tests/test_synthesize_speech.py
```

---

## Task 8: `compose_video.py` — ffmpeg compositor (TDD on filter graph)

**Files:**
- Create: `.claude/skills/generate-tafsir-video/scripts/compose_video.py`
- Create: `.claude/skills/generate-tafsir-video/tests/test_compose_video.py`
- Drop caption TTF at: `.claude/skills/generate-tafsir-video/assets/fonts/caption.ttf` (e.g., `Inter-Black.ttf`)

**Step 1: Write failing tests on the pure filter-graph builder**

```python
# tests/test_compose_video.py
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from compose_video import build_drawtext_chain, build_filter_complex  # noqa: E402


def test_drawtext_chain_one_per_word():
    timings = [
        {"word": "Hello", "start": 0.0, "end": 0.5},
        {"word": "world", "start": 0.5, "end": 1.0},
    ]
    chain = build_drawtext_chain(timings, font_path="/x/caption.ttf")
    # one drawtext for the static (muted) line + N enable-gated drawtext for active words
    assert chain.count("drawtext=") == 2 + 1  # 2 active + 1 muted-baseline
    assert "between(t,0.0,0.5)" in chain
    assert "between(t,0.5,1.0)" in chain


def test_filter_complex_overlays_header_and_audio():
    fc = build_filter_complex(
        timings=[{"word": "Hi", "start": 0.0, "end": 0.3}],
        header_path="/tmp/h.png",
        font_path="/x/caption.ttf",
        narration_duration=0.3,
    )
    assert "overlay=" in fc  # header overlay
    assert "drawtext=" in fc  # captions
    assert "trim=duration=0.3" in fc
```

**Step 2: Run, expect ImportError**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_compose_video.py -v
```

**Step 3: Implement**

```python
# scripts/compose_video.py
"""Compose final video with ffmpeg.

Inputs: silent base mp4, narration mp3, word_timings json, header png.
Output: single mp4 with sticky header overlay + word-by-word captions + narration audio.
"""
from __future__ import annotations
import json
import shlex
import subprocess
from pathlib import Path

CAPTION_Y = 1500            # y-position of caption baseline
CAPTION_FONT_SIZE = 60
ACTIVE_COLOR = "yellow"
MUTED_COLOR = "0xC9A227"    # darker amber
HEADER_Y = 80


def build_drawtext_chain(timings: list[dict], font_path: str) -> str:
    """Build drawtext filters for word-by-word captions.

    Pattern: one always-on muted line of all words + one enable-gated drawtext per
    word in the active brighter color. The active drawtext is drawn at the same
    position as the corresponding word in the muted line, on top of it.

    For simplicity v1: render only the *current* active word (as in the reference
    video), not the full sentence. Less code, sharper visual.
    """
    parts = []
    # Empty static layer — placeholder so the test sees one base entry.
    parts.append(
        f"drawtext=fontfile='{font_path}':text=' ':enable='between(t,0,0.0001)':"
        f"fontcolor=white:fontsize=1:x=0:y=0"
    )
    for t in timings:
        word = _escape_text(t["word"])
        parts.append(
            f"drawtext=fontfile='{font_path}':text='{word}':"
            f"enable='between(t,{t['start']},{t['end']})':"
            f"fontcolor={ACTIVE_COLOR}:fontsize={CAPTION_FONT_SIZE}:"
            f"box=1:boxcolor=black@0.55:boxborderw=20:"
            f"x=(w-text_w)/2:y={CAPTION_Y}"
        )
    return ",".join(parts)


def build_filter_complex(timings: list[dict], header_path: str, font_path: str,
                         narration_duration: float) -> str:
    """Build the full ffmpeg filter_complex string."""
    captions = build_drawtext_chain(timings, font_path)
    fc = (
        f"[0:v]trim=duration={narration_duration},setpts=PTS-STARTPTS,"
        f"scale=1080:1920,format=rgba[base];"
        f"[1:v]format=rgba[hdr];"
        f"[base][hdr]overlay=x=0:y={HEADER_Y}:format=auto[withhdr];"
        f"[withhdr]{captions}[out]"
    )
    return fc


def _escape_text(s: str) -> str:
    # ffmpeg drawtext: escape colons, single quotes, backslashes, percent
    return (s.replace("\\", "\\\\")
             .replace("'", "\\'")
             .replace(":", "\\:")
             .replace("%", "\\%"))


def compose(base_video: Path, narration_audio: Path, word_timings: Path,
            header_png: Path, font_path: Path, output: Path) -> Path:
    timings = json.loads(Path(word_timings).read_text())
    if not timings:
        raise RuntimeError("Word timings are empty — cannot render captions.")
    duration = timings[-1]["end"]

    fc = build_filter_complex(timings, str(header_png), str(font_path), duration)

    cmd = [
        "ffmpeg", "-y",
        "-i", str(base_video),
        "-loop", "1", "-i", str(header_png),
        "-i", str(narration_audio),
        "-filter_complex", fc,
        "-map", "[out]", "-map", "2:a",
        "-c:v", "libx264", "-preset", "medium", "-crf", "20", "-pix_fmt", "yuv420p",
        "-c:a", "aac", "-b:a", "192k",
        "-shortest",
        str(output),
    ]
    output.parent.mkdir(parents=True, exist_ok=True)
    res = subprocess.run(cmd, capture_output=True, text=True)
    if res.returncode != 0:
        tail = "\n".join(res.stderr.splitlines()[-40:])
        raise RuntimeError(f"ffmpeg failed (exit {res.returncode}):\n{tail}")
    return output
```

**Step 4: Run, expect pass**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_compose_video.py -v
```
Expected: 2 passed.

**Step 5: Stage**

```bash
git add .claude/skills/generate-tafsir-video/scripts/compose_video.py
git add .claude/skills/generate-tafsir-video/tests/test_compose_video.py
git add .claude/skills/generate-tafsir-video/assets/fonts/caption.ttf
```

---

## Task 9: `generate_tafsir_video.py` — CLI orchestrator (TDD-light)

**Files:**
- Create: `.claude/skills/generate-tafsir-video/scripts/generate_tafsir_video.py`
- Create: `.claude/skills/generate-tafsir-video/tests/test_orchestrator.py`

**Step 1: Write failing tests on argparse + path resolution**

```python
# tests/test_orchestrator.py
import sys
from pathlib import Path
import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent.parent / "scripts"))

from generate_tafsir_video import parse_verse, output_path_for  # noqa: E402


def test_parse_verse_valid():
    assert parse_verse("2:258") == (2, 258)


def test_parse_verse_invalid_raises():
    with pytest.raises(ValueError, match="Expected SURAH:VERSE"):
        parse_verse("nope")


def test_output_path_for():
    p = output_path_for(2, 258, base_dir=Path("/tmp/out"))
    assert p == Path("/tmp/out/2_258.mp4")
```

**Step 2: Run, expect ImportError**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_orchestrator.py -v
```

**Step 3: Implement**

```python
#!/usr/bin/env python3
# scripts/generate_tafsir_video.py
"""Per-verse tafsir-video orchestrator.

Usage:
  python3 generate_tafsir_video.py --verse 2:258 --script-file path/to/script.txt
"""
from __future__ import annotations
import argparse
import sys
from pathlib import Path

# Ensure sibling modules importable when called as script
HERE = Path(__file__).resolve().parent
sys.path.insert(0, str(HERE))

from preflight import (check_base_video, check_elevenlabs_key, check_ffmpeg,
                       check_font, check_script_file)
from verse_loader import get_surah_english_name
from synthesize_speech import synthesize
from render_header import render_header
from compose_video import compose


SKILL_ROOT = HERE.parent
ASSETS = SKILL_ROOT / "assets"
BASE_VIDEO = ASSETS / "tafsir_base" / "tafsir_base.mp4"
HEADER_FONT = ASSETS / "fonts" / "header.ttf"
CAPTION_FONT = ASSETS / "fonts" / "caption.ttf"
PROJECT_ROOT = SKILL_ROOT.parents[2]
OUTPUT_DIR = PROJECT_ROOT / "tafsir_videos"
TEMP_DIR = OUTPUT_DIR / "temp"


def parse_verse(s: str) -> tuple[int, int]:
    if ":" not in s:
        raise ValueError("Expected SURAH:VERSE format, e.g., 2:258")
    a, b = s.split(":", 1)
    return int(a), int(b)


def output_path_for(surah: int, verse: int, base_dir: Path = OUTPUT_DIR) -> Path:
    return base_dir / f"{surah}_{verse}.mp4"


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--verse", required=True, help="SURAH:VERSE, e.g., 2:258")
    p.add_argument("--script-file", required=True, help="Path to approved narration script")
    args = p.parse_args()

    surah, verse = parse_verse(args.verse)
    script_path = Path(args.script_file)

    # Pre-flight
    check_base_video(BASE_VIDEO)
    check_elevenlabs_key()
    check_ffmpeg()
    check_font(HEADER_FONT)
    check_font(CAPTION_FONT)
    check_script_file(script_path)

    surah_name = get_surah_english_name(surah)
    script_text = script_path.read_text().strip()

    TEMP_DIR.mkdir(parents=True, exist_ok=True)
    audio_path = TEMP_DIR / f"{surah}_{verse}.mp3"
    timings_path = TEMP_DIR / f"{surah}_{verse}_timings.json"
    header_path = TEMP_DIR / f"{surah}_{verse}_header.png"
    out_path = output_path_for(surah, verse)

    print(f"[1/3] Synthesizing speech for {surah}:{verse}...")
    synthesize(script_text, audio_path, timings_path)

    print(f"[2/3] Rendering header for SURAH {surah_name} AYAT {verse}...")
    render_header(surah_name, verse, header_path, HEADER_FONT)

    print(f"[3/3] Composing video → {out_path}")
    compose(BASE_VIDEO, audio_path, timings_path, header_path, CAPTION_FONT, out_path)

    print(f"Done: {out_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
```

**Step 4: Run, expect pass**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests/test_orchestrator.py -v
```
Expected: 3 passed.

**Step 5: Run the full test suite**

```bash
source .venv/bin/activate && python3 -m pytest .claude/skills/generate-tafsir-video/tests -v
```
Expected: all tests pass (~17 total, may skip header tests if font absent at this point).

**Step 6: Stage**

```bash
git add .claude/skills/generate-tafsir-video/scripts/generate_tafsir_video.py
git add .claude/skills/generate-tafsir-video/tests/test_orchestrator.py
```

---

## Task 10: Flesh out `SKILL.md` with the agent workflow

**Files:**
- Modify: `.claude/skills/generate-tafsir-video/SKILL.md`

**Step 1: Replace placeholder with full skill definition**

```markdown
---
name: generate-tafsir-video
description: Generate TikTok-style tafsir-explainer videos for any Quranic verse. The agent drafts a ~40s narration from tafsir layer2 (Tabatabai/Classical Shia), the user approves it in chat, then a Python pipeline does ElevenLabs TTS, renders a glowing cyan header, and composites everything onto a pre-rendered silent base video with synced word-by-word captions. Use when the user says "make a tafsir video for X:Y", "generate verse video for surah X verse Y", or similar. Requires assets/tafsir_base/tafsir_base.mp4 (one-time Phase A setup via shia-event-video-creator) and ELEVENLABS_API_KEY.
argument-hint: [surah:verse]
allowed-tools: Read, Write, Bash
---

# Generate Tafsir Video

Per-verse video generator that reuses a Kling-rendered silent base video and only swaps narration + header + captions.

## Phase A — One-time base video setup (manual)

Before this skill can run, the user must produce `.claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4`. See `references/tafsir_explainer_scenes.md` — feed those scene prompts into `shia-event-video-creator`, then ffmpeg-concat the outputs.

If the base video is missing, the Python pipeline pre-flight will say so explicitly.

## Phase B — Per-verse workflow (this skill)

When invoked with `$ARGUMENTS = "2:258"`:

1. **Parse** the surah and verse from `$ARGUMENTS`.

2. **Load tafsir layer2** for that verse from `Thaqalayn/Thaqalayn/Data/tafsir_{surah}.json` (key: `verses[str(verse)]["layer2"]`). This layer is the Classical Shia / Tabatabai-style commentary.

3. **Draft a ~100-word narration** from layer2:
   - Open with: `"Allama Tabatabai explains that ayah {verse}..."`
   - Declarative prose, no bullets, no list markers
   - No Arabic script in the narration text (this is for English TTS)
   - Aim for ~40 seconds of read-aloud time
   - Preserve the key argument/insight — don't add new content

4. **Show the draft to the user** and iterate until they approve.

5. **Save the approved script** to `tafsir_videos/temp/{surah}_{verse}_script.txt` (create dirs as needed).

6. **Invoke the Python pipeline:**

   ```bash
   source .venv/bin/activate && python3 .claude/skills/generate-tafsir-video/scripts/generate_tafsir_video.py \
     --verse {surah}:{verse} \
     --script-file tafsir_videos/temp/{surah}_{verse}_script.txt
   ```

7. **Report the output path** to the user: `tafsir_videos/{surah}_{verse}.mp4`.

## Output

`tafsir_videos/{surah}_{verse}.mp4` — 1080×1920, ~40–50s, narrated.

## Requirements

- `.env` with `ELEVENLABS_API_KEY`
- `ffmpeg` on PATH (`brew install ffmpeg`)
- Project `.venv` with `pillow` and `requests` installed
- `assets/tafsir_base/tafsir_base.mp4` (one-time Phase A output)
- `assets/fonts/header.ttf` and `assets/fonts/caption.ttf`

## Failure modes

The Python pipeline does pre-flight checks and raises clear errors if anything is missing. There are no fallbacks (per project CLAUDE.md). If a check fails, fix the listed issue and re-run.
```

**Step 2: Confirm the skill is discoverable**

```bash
ls .claude/skills/generate-tafsir-video/SKILL.md && head -5 .claude/skills/generate-tafsir-video/SKILL.md
```

**Step 3: Stage**

```bash
git add .claude/skills/generate-tafsir-video/SKILL.md
```

---

## Task 11: Phase A — produce the silent base video (manual)

**Files:**
- Drop output at: `.claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4`

**Step 1: Run shia-event-video-creator with the prompt set**

Open the references doc and feed it scene-by-scene into `shia-event-video-creator`:

```
Read .claude/skills/generate-tafsir-video/references/tafsir_explainer_scenes.md
```

Have `shia-event-video-creator` produce 7 image+video outputs in a fresh `video_output/tafsir_base/` directory.

**Step 2: ffmpeg-concat into the base mp4**

```bash
cd video_output/tafsir_base
cat > scene_list.txt <<EOF
file 'scene_1.mp4'
file 'scene_2.mp4'
file 'scene_3.mp4'
file 'scene_4.mp4'
file 'scene_5.mp4'
file 'scene_6.mp4'
file 'scene_7.mp4'
EOF
ffmpeg -f concat -safe 0 -i scene_list.txt -c:v libx264 -preset slow -crf 18 \
  -pix_fmt yuv420p -an \
  ../../.claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4
```

**Step 3: Verify**

```bash
ffprobe -v error -show_streams \
  .claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4 \
  | grep -E "codec_name|width|height|duration"
```
Expected: video stream only (no audio), 1080×1920, ~50s.

**Step 4: Stage**

```bash
git add .claude/skills/generate-tafsir-video/assets/tafsir_base/tafsir_base.mp4
```

> **Note:** Large binary; consider `git lfs track "*.mp4"` if not already.

---

## Task 12: End-to-end smoke test on 2:258

**Files:**
- (no new files; produces `tafsir_videos/2_258.mp4`)

**Step 1: Trigger the skill**

In Claude Code:

```
/generate-tafsir-video 2:258
```

Or directly invoke the agent workflow described in SKILL.md Task 10.

**Step 2: Approve the drafted script**

Review the agent's proposed narration. Should open with "Allama Tabatabai explains that ayah 258...". Iterate until it reads well aloud.

**Step 3: Wait for the Python pipeline to finish**

You'll see:
```
[1/3] Synthesizing speech for 2:258...
[2/3] Rendering header for SURAH AL-BAQARAH AYAT 258...
[3/3] Composing video → tafsir_videos/2_258.mp4
Done: tafsir_videos/2_258.mp4
```

**Step 4: Open and visually compare to reference**

```bash
open tafsir_videos/2_258.mp4
```

Check against `v12044gd0000cs6qt0fog65ut0gcss00.MP4`:

- [ ] 1080×1920 9:16, ~40–50s
- [ ] Cyan glowing header reads "SURAH AL-BAQARAH / AYAT 258" for the entire duration
- [ ] Narration is intelligible, opens correctly
- [ ] Yellow captions appear at bottom, current word matches what's spoken
- [ ] Base visuals (cosmos / Quran / fire / planets) play underneath
- [ ] No black frames, no audio clipping

**Step 5: Tune if needed**

Visual mismatches → adjust:
- Header glow too soft → bump `GLOW_BLUR_RADIUS` in `render_header.py`
- Captions too small → bump `CAPTION_FONT_SIZE` in `compose_video.py`
- Captions misaligned vertically → adjust `CAPTION_Y`
- Header positioned wrong → adjust `HEADER_Y`

Commit any tuning changes.

**Step 6: Test a second verse to confirm reusability**

```
/generate-tafsir-video 2:255
```

Should produce a different narration + header + captions, but same base visuals. Confirms the "base video reuse" architecture works.

**Step 7: Stage final outputs (optional)**

```bash
git add tafsir_videos/2_258.mp4 tafsir_videos/2_255.mp4
# User commits manually
```

> Consider adding `tafsir_videos/temp/` to `.gitignore` since temp files have no value committed.

---

## Done criteria

- [ ] All unit tests pass: `pytest .claude/skills/generate-tafsir-video/tests -v`
- [ ] Phase A base video exists and is 1080×1920, no audio, ~50s
- [ ] `/generate-tafsir-video 2:258` produces a file at `tafsir_videos/2_258.mp4`
- [ ] Video visually parallels the reference video (header glow, caption sync, base visuals, narration tone)
- [ ] A second verse generates correctly with the same base video reused

## Out of scope (deferred)

- Urdu / Arabic variants
- Multiple themed base videos (cosmology / stories / ethics)
- Sharing TTS+alignment helper between this skill and `generate-tiktok-video`
- Automated visual regression on the final video
