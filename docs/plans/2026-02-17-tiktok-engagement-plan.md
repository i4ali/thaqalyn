# TikTok Engagement Improvements Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add bold statement hooks, countdown pacing, and text overlays to TikTok videos for better viewer retention.

**Architecture:** Extend existing `generate_tiktok.py` with hook generation, updated narration script format, and FFmpeg drawtext filters for text overlays.

**Tech Stack:** Python 3, FFmpeg drawtext filter, ElevenLabs TTS

---

## Task 1: Add Hook Templates and Generator

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Add hook templates constant after VOICE_ID**

Add after line 25:

```python
# Hook templates for engaging intros
HOOK_TEMPLATES = [
    "This verse will transform how you understand {theme}",
    "Most people miss these {n} layers in this verse",
    "Here's what the scholars say about this powerful verse",
    "This verse holds {n} profound secrets",
]
```

**Step 2: Add generate_hook function after load_gems**

Add after `load_gems` function (after line 57):

```python
def generate_hook(gems: list[dict], count: int) -> str:
    """Generate a bold statement hook based on gem content."""
    # Extract theme from first gem title
    theme = gems[0]["title"].lower() if gems else "faith"

    # Pick template and fill in
    template = random.choice(HOOK_TEMPLATES)
    hook = template.format(theme=theme, n=count)

    return hook
```

**Step 3: Verify function works**

Run:
```bash
source .venv/bin/activate && python -c "
exec(open('.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py').read())
gems = load_gems(1, 5)
hook = generate_hook(gems, len(gems))
print(f'Hook: {hook}')
"
```

Expected: Hook text like "This verse will transform how you understand exclusive worship"

---

## Task 2: Update Narration Script with Countdown Format

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Replace build_narration_script function**

Replace the existing `build_narration_script` function (lines 60-69) with:

```python
def build_narration_script(gems: list[dict], hook: str) -> str:
    """Build narration script with hook and countdown pacing."""
    # Cap at 3 gems for optimal TikTok length
    gems = gems[:3]
    count = len(gems)

    # Ordinal words for countdown
    ordinals = ["First", "Second", "Third"]

    # Build script
    lines = [
        hook,
        f"Here are {count} insights from this verse."
    ]

    for i, gem in enumerate(gems):
        insight = gem["insight"].rstrip(".")
        lines.append(f"{ordinals[i]}... {gem['title']}. {insight}.")

    return "\n\n".join(lines)
```

**Step 2: Verify new narration format**

Run:
```bash
source .venv/bin/activate && python -c "
exec(open('.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py').read())
gems = load_gems(1, 5)
hook = generate_hook(gems, min(len(gems), 3))
script = build_narration_script(gems, hook)
print(script)
"
```

Expected: Script starting with hook, then "Here are 3 insights...", then "First... Second... Third..."

---

## Task 3: Add Text Overlay Timing Calculator

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Add timing constants after HOOK_TEMPLATES**

Add after HOOK_TEMPLATES:

```python
# Timing estimates (seconds)
HOOK_DURATION = 3.0      # Hook display time
SETUP_DURATION = 3.0     # "Here are N insights"
GEM_INTRO_DURATION = 2.0 # "First/Second/Third..."
GEM_INSIGHT_DURATION = 8.0  # Average insight narration
```

**Step 2: Add calculate_text_timings function**

Add after `generate_hook` function:

```python
def calculate_text_timings(gem_count: int) -> dict:
    """Calculate start/end times for each text overlay."""
    timings = {
        "hook": {"start": 0.0, "end": HOOK_DURATION},
    }

    # Gems start after hook + setup
    gem_start = HOOK_DURATION + SETUP_DURATION

    for i in range(gem_count):
        gem_key = f"gem_{i+1}"
        start = gem_start + i * (GEM_INTRO_DURATION + GEM_INSIGHT_DURATION)
        end = start + GEM_INTRO_DURATION + GEM_INSIGHT_DURATION
        timings[gem_key] = {
            "start": start,
            "end": end,
            "number": i + 1
        }

    return timings
```

**Step 3: Verify timing calculation**

Run:
```bash
source .venv/bin/activate && python -c "
exec(open('.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py').read())
timings = calculate_text_timings(3)
for k, v in timings.items():
    print(f'{k}: {v}')
"
```

Expected:
```
hook: {'start': 0.0, 'end': 3.0}
gem_1: {'start': 6.0, 'end': 16.0, 'number': 1}
gem_2: {'start': 16.0, 'end': 26.0, 'number': 2}
gem_3: {'start': 26.0, 'end': 36.0, 'number': 3}
```

---

## Task 4: Add Text Overlay Filter Builder

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Add font path constant**

Add after timing constants:

```python
# Font for text overlays (macOS system font)
FONT_PATH = "/System/Library/Fonts/Helvetica.ttc"
```

**Step 2: Add build_drawtext_filters function**

Add after `calculate_text_timings`:

```python
def build_drawtext_filters(hook: str, gems: list[dict], timings: dict) -> str:
    """Build FFmpeg drawtext filter chain for text overlays."""
    filters = []

    # Hook text - centered, large, with fade
    hook_escaped = hook.replace("'", "'\\''").replace(":", "\\:")
    hook_filter = (
        f"drawtext=text='{hook_escaped}':"
        f"fontfile={FONT_PATH}:"
        f"fontsize=55:fontcolor=white:"
        f"x=(w-text_w)/2:y=(h-text_h)/2:"
        f"shadowcolor=black:shadowx=3:shadowy=3:"
        f"enable='between(t,{timings['hook']['start']},{timings['hook']['end']})'"
    )
    filters.append(hook_filter)

    # Gem overlays - top-left with number and title
    for i, gem in enumerate(gems[:3]):
        gem_key = f"gem_{i+1}"
        if gem_key not in timings:
            continue

        t = timings[gem_key]
        title_escaped = gem["title"].replace("'", "'\\''").replace(":", "\\:")

        # Large number
        number_filter = (
            f"drawtext=text='{t['number']}':"
            f"fontfile={FONT_PATH}:"
            f"fontsize=100:fontcolor=white:"
            f"x=50:y=150:"
            f"shadowcolor=black:shadowx=3:shadowy=3:"
            f"enable='between(t,{t['start']},{t['end']})'"
        )
        filters.append(number_filter)

        # Title below number
        title_filter = (
            f"drawtext=text='{title_escaped}':"
            f"fontfile={FONT_PATH}:"
            f"fontsize=40:fontcolor=white:"
            f"x=50:y=270:"
            f"shadowcolor=black:shadowx=2:shadowy=2:"
            f"enable='between(t,{t['start']},{t['end']})'"
        )
        filters.append(title_filter)

    return ",".join(filters)
```

**Step 3: Verify filter generation**

Run:
```bash
source .venv/bin/activate && python -c "
exec(open('.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py').read())
gems = load_gems(1, 5)[:3]
hook = generate_hook(gems, len(gems))
timings = calculate_text_timings(len(gems))
filters = build_drawtext_filters(hook, gems, timings)
print(filters[:200] + '...')
"
```

Expected: FFmpeg drawtext filter string starting with `drawtext=text=...`

---

## Task 5: Update compose_video with Text Overlays

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Update compose_video signature**

Change the function signature (line 113) to accept new parameters:

```python
def compose_video(
    image_path: Path,
    narration_path: Path,
    output_path: Path,
    text_filters: str,
    ambient_path: Path | None = None
) -> Path:
```

**Step 2: Update the filter chain to include text overlays**

Replace the zoom_filter and filter_complex sections (lines 121-158) with:

```python
    # Get narration duration and add 2s padding
    duration = get_audio_duration(narration_path) + 2.0

    # Ken Burns: slow zoom from 100% to 110%
    zoom_filter = (
        f"zoompan=z='1+0.1*on/{duration*30}':"
        f"x='iw/2-(iw/zoom/2)':"
        f"y='ih/2-(ih/zoom/2)':"
        f"d={int(duration*30)}:s=1080x1920:fps=30"
    )

    # Combine zoom with text overlays
    video_filter = f"{zoom_filter},{text_filters}" if text_filters else zoom_filter

    if ambient_path and ambient_path.exists():
        # Mix narration (100%) + ambient (15%) with fades
        filter_complex = (
            f"[0:v]{video_filter}[v];"
            f"[1:a]volume=1.0,afade=t=out:st={duration-1.5}:d=1.5[narr];"
            f"[2:a]volume=0.15,afade=t=in:st=0:d=1,afade=t=out:st={duration-1.5}:d=1.5[amb];"
            f"[narr][amb]amix=inputs=2:duration=first[a]"
        )
        inputs = [
            "-loop", "1", "-i", str(image_path),
            "-i", str(narration_path),
            "-i", str(ambient_path)
        ]
        maps = ["-map", "[v]", "-map", "[a]"]
    else:
        # Just narration with fade out
        filter_complex = (
            f"[0:v]{video_filter}[v];"
            f"[1:a]volume=1.0,afade=t=out:st={duration-1.5}:d=1.5[a]"
        )
        inputs = [
            "-loop", "1", "-i", str(image_path),
            "-i", str(narration_path)
        ]
        maps = ["-map", "[v]", "-map", "[a]"]
```

---

## Task 6: Update main() to Wire Everything Together

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Update main() function**

Replace the main() function (lines 188-251) with:

```python
def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_tiktok.py <surah:verse>")
        print("Example: python generate_tiktok.py 1:1")
        sys.exit(1)

    # Parse input
    verse_ref = sys.argv[1]

    if ":" not in verse_ref:
        print(f"Invalid format: {verse_ref}. Use surah:verse (e.g., 1:1)")
        sys.exit(1)

    parts = verse_ref.split(":")
    surah = int(parts[0])
    verse = int(parts[1])

    print(f"Generating TikTok video for Surah {surah}, Verse {verse}...")

    # Check verse art exists
    image_path = VERSE_ART_DIR / f"{surah}_{verse}.png"
    if not image_path.exists():
        print(f"Error: Verse art not found at {image_path}")
        print(f"Run '/generate-verse-art {surah}:{verse}' first.")
        sys.exit(1)
    print(f"  Found verse art: {image_path}")

    # Load gems (cap at 3)
    print("Loading gems from tafsir...")
    all_gems = load_gems(surah, verse)
    gems = all_gems[:3]
    print(f"  Using {len(gems)} of {len(all_gems)} gems:")
    for gem in gems:
        print(f"    - {gem['title']}")

    # Generate hook
    hook = generate_hook(gems, len(gems))
    print(f"\nHook: {hook}")

    # Build narration script with countdown
    script = build_narration_script(gems, hook)
    print(f"\nNarration script ({len(script)} chars):")
    print(f"  {script[:100]}...")

    # Calculate text overlay timings
    timings = calculate_text_timings(len(gems))
    print(f"\nText overlay timings calculated for {len(gems)} gems")

    # Build text overlay filters
    text_filters = build_drawtext_filters(hook, gems, timings)

    # Generate narration audio
    OUTPUT_DIR.mkdir(exist_ok=True)
    narration_path = OUTPUT_DIR / f"{surah}_{verse}_narration.mp3"
    print(f"\nGenerating narration via ElevenLabs...")
    generate_narration(script, narration_path)
    print(f"  Saved: {narration_path}")

    # Get ambient track
    ambient_path = get_random_ambient()
    if ambient_path:
        print(f"  Using ambient: {ambient_path.name}")
    else:
        print("  No ambient tracks found, using narration only")

    # Compose video with text overlays
    output_path = OUTPUT_DIR / f"{surah}_{verse}.mp4"
    print(f"\nComposing video with FFmpeg...")
    compose_video(image_path, narration_path, output_path, text_filters, ambient_path)
    print(f"  Saved: {output_path}")

    # Clean up narration file
    narration_path.unlink()

    print(f"\nVideo generated successfully: {output_path}")
    return str(output_path)
```

---

## Task 7: End-to-End Test

**Step 1: Run the updated script**

```bash
source .venv/bin/activate && python .claude/skills/generate-tiktok-video/scripts/generate_tiktok.py 1:5
```

Expected output:
```
Generating TikTok video for Surah 1, Verse 5...
  Found verse art: verse_art/1_5.png
Loading gems from tafsir...
  Using 3 of 3 gems:
    - Exclusive Worship
    - Seeking Help
    - Divine Dialogue

Hook: [bold statement about exclusive worship]

Narration script (XXX chars):
  [hook]. Here are 3 insights...

Text overlay timings calculated for 3 gems

Generating narration via ElevenLabs...
  Saved: tiktok_videos/1_5_narration.mp3

Composing video with FFmpeg...
  Saved: tiktok_videos/1_5.mp4

Video generated successfully: tiktok_videos/1_5.mp4
```

**Step 2: Verify video properties**

```bash
ffprobe tiktok_videos/1_5.mp4 2>&1 | grep -E "Duration|Video"
```

Expected: Video with ~35-45 second duration, 1080x1920 resolution

**Step 3: Visual verification**

Open `tiktok_videos/1_5.mp4` and verify:
- [ ] Hook text appears centered (0-3 sec)
- [ ] Numbers 1, 2, 3 appear at correct times
- [ ] Gem titles visible below numbers
- [ ] Text readable against image background
- [ ] Ken Burns zoom effect still works

---

## Summary

| Task | Description | Est. Time |
|------|-------------|-----------|
| 1 | Add hook templates and generator | 3 min |
| 2 | Update narration script format | 3 min |
| 3 | Add timing calculator | 3 min |
| 4 | Add text overlay filter builder | 5 min |
| 5 | Update compose_video | 5 min |
| 6 | Update main() | 5 min |
| 7 | End-to-end test | 5 min |

**Total: ~30 minutes**
