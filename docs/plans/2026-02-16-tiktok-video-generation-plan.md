# TikTok Video Generation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Create a Claude Code skill that generates TikTok-ready videos from verse art images with ElevenLabs AI narration of gems/insights.

**Architecture:** Python script orchestrates: load gems from tafsir JSON → generate narration via ElevenLabs API → compose video with FFmpeg (Ken Burns effect + ambient audio mixing).

**Tech Stack:** Python 3, ElevenLabs SDK, FFmpeg, python-dotenv

---

## Task 1: Create Skill Directory Structure

**Files:**
- Create: `.claude/skills/generate-tiktok-video/SKILL.md`
- Create: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`
- Create: `.claude/skills/generate-tiktok-video/assets/ambient/.gitkeep`
- Create: `tiktok_videos/.gitkeep`

**Step 1: Create directory structure**

```bash
mkdir -p .claude/skills/generate-tiktok-video/scripts
mkdir -p .claude/skills/generate-tiktok-video/assets/ambient
mkdir -p tiktok_videos
```

**Step 2: Create .gitkeep files for empty directories**

```bash
touch .claude/skills/generate-tiktok-video/assets/ambient/.gitkeep
touch tiktok_videos/.gitkeep
```

---

## Task 2: Create SKILL.md Definition

**Files:**
- Create: `.claude/skills/generate-tiktok-video/SKILL.md`

**Step 1: Write the skill definition file**

```markdown
---
name: generate-tiktok-video
description: Generate TikTok videos from verse art with AI narration of gems/insights using ElevenLabs TTS and FFmpeg.
argument-hint: [surah:verse]
allowed-tools: Read, Bash, Glob
---

# Generate TikTok Video

Generate TikTok-ready videos from Quranic verse art with AI-narrated insights.

## Instructions

When invoked with a verse reference (e.g., `1:1` or `2:255`):

1. Parse the surah and verse number from `$ARGUMENTS`
2. Run the Python script to generate the video:
   ```bash
   source .venv/bin/activate && python3 .claude/skills/generate-tiktok-video/scripts/generate_tiktok.py $ARGUMENTS
   ```
3. Report the result to the user with the saved file path

## Input Format

- Single verse: `1:1`, `2:255`, `112:1`
- Requires verse art to exist at `verse_art/{surah}_{verse}.png`
- Requires tafsir with gems at `Thaqalayn/Thaqalayn/Data/tafsir_{surah}.json`

## Output

- Videos saved to `tiktok_videos/{surah}_{verse}.mp4`
- Vertical 9:16 format (1080x1920)
- Ken Burns zoom effect with narration + ambient audio

## Requirements

- `.env` file with `ELEVENLABS_API_KEY`
- FFmpeg installed (`brew install ffmpeg`)
- Python virtual environment with `elevenlabs` package
- Verse art image must exist (run `/generate-verse-art` first)
```

---

## Task 3: Update .env.example with ElevenLabs Key

**Files:**
- Modify: `.env.example`

**Step 1: Add ElevenLabs API key to .env.example**

Add after the OpenRouter line:

```
# ElevenLabs API Key for TTS narration
# Get your key at: https://elevenlabs.io/
ELEVENLABS_API_KEY=your_api_key_here
```

---

## Task 4: Install Python Dependencies

**Step 1: Activate virtual environment and install elevenlabs**

```bash
source .venv/bin/activate && pip install elevenlabs
```

**Step 2: Verify installation**

```bash
source .venv/bin/activate && python -c "import elevenlabs; print('elevenlabs installed')"
```

Expected: `elevenlabs installed`

---

## Task 5: Write Core Script - Data Loading Functions

**Files:**
- Create: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Write the script header and imports**

```python
#!/usr/bin/env python3
"""
Generate TikTok videos from verse art with AI narration using ElevenLabs TTS and FFmpeg.
"""

import json
import os
import sys
import random
import subprocess
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY")
DATA_DIR = Path("Thaqalayn/Thaqalayn/Data")
VERSE_ART_DIR = Path("verse_art")
OUTPUT_DIR = Path("tiktok_videos")
AMBIENT_DIR = Path(".claude/skills/generate-tiktok-video/assets/ambient")

# ElevenLabs voice ID (Adam - clear, calm male voice)
VOICE_ID = "pNInz6obpgDQGcFmaJgB"
```

**Step 2: Write the gems loading function**

```python
def load_gems(surah: int, verse: int) -> list[dict]:
    """Load gems from tafsir quickOverview.concepts."""
    tafsir_path = DATA_DIR / f"tafsir_{surah}.json"

    if not tafsir_path.exists():
        raise FileNotFoundError(f"Tafsir file not found: {tafsir_path}")

    with open(tafsir_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    verse_str = str(verse)
    if verse_str not in data:
        raise ValueError(f"Verse {verse} not found in tafsir_{surah}.json")

    quick_overview = data[verse_str].get("quickOverview", {})
    concepts = quick_overview.get("concepts", [])

    gems = []
    for concept in concepts:
        gem = {
            "title": concept.get("title", ""),
            "insight": concept.get("coreInsight", "")
        }
        if gem["title"] and gem["insight"]:
            gems.append(gem)

    if not gems:
        raise ValueError(f"No gems found for {surah}:{verse}. Tafsir with quickOverview required.")

    return gems
```

**Step 3: Verify the script parses correctly**

```bash
source .venv/bin/activate && python -c "exec(open('.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py').read()); print('Script parses OK')"
```

Expected: `Script parses OK`

---

## Task 6: Write Narration Script Builder

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Add the build_narration_script function**

Add after `load_gems` function:

```python
def build_narration_script(gems: list[dict]) -> str:
    """Build narration script from gems with intro."""
    lines = ["This verse gives us these powerful insights."]

    for gem in gems:
        # Clean up insight text - remove trailing ellipsis if present
        insight = gem["insight"].rstrip(".")
        lines.append(f"{gem['title']}. {insight}.")

    return "\n\n".join(lines)
```

**Step 2: Verify function works**

```bash
source .venv/bin/activate && python -c "
exec(open('.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py').read())
gems = load_gems(1, 1)
script = build_narration_script(gems)
print(script[:200])
"
```

Expected: Output starting with "This verse gives us these powerful insights..."

---

## Task 7: Write ElevenLabs TTS Function

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Add the generate_narration function**

Add after `build_narration_script` function:

```python
def generate_narration(script: str, output_path: Path) -> Path:
    """Generate narration audio using ElevenLabs API."""
    if not ELEVENLABS_API_KEY:
        raise ValueError("ELEVENLABS_API_KEY not found in .env file")

    from elevenlabs import ElevenLabs

    client = ElevenLabs(api_key=ELEVENLABS_API_KEY)

    # Generate audio
    audio_generator = client.text_to_speech.convert(
        voice_id=VOICE_ID,
        text=script,
        model_id="eleven_multilingual_v2"
    )

    # Write audio to file
    OUTPUT_DIR.mkdir(exist_ok=True)
    with open(output_path, "wb") as f:
        for chunk in audio_generator:
            f.write(chunk)

    return output_path
```

---

## Task 8: Write FFmpeg Video Composition Function

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Add helper to get audio duration**

Add after `generate_narration` function:

```python
def get_audio_duration(audio_path: Path) -> float:
    """Get audio duration in seconds using ffprobe."""
    result = subprocess.run(
        [
            "ffprobe", "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            str(audio_path)
        ],
        capture_output=True,
        text=True,
        check=True
    )
    return float(result.stdout.strip())
```

**Step 2: Add the compose_video function**

```python
def compose_video(
    image_path: Path,
    narration_path: Path,
    output_path: Path,
    ambient_path: Path | None = None
) -> Path:
    """Compose video with Ken Burns effect and audio mixing."""

    # Get narration duration and add 2s padding
    duration = get_audio_duration(narration_path) + 2.0

    # Ken Burns: slow zoom from 100% to 110%
    # zoompan: z increases from 1.0 to 1.1 over duration
    # fps=30, output 1080x1920
    zoom_filter = (
        f"zoompan=z='1+0.1*on/{duration*30}':"
        f"x='iw/2-(iw/zoom/2)':"
        f"y='ih/2-(ih/zoom/2)':"
        f"d={int(duration*30)}:s=1080x1920:fps=30"
    )

    if ambient_path and ambient_path.exists():
        # Mix narration (100%) + ambient (15%) with fades
        filter_complex = (
            f"[0:v]{zoom_filter}[v];"
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
            f"[0:v]{zoom_filter}[v];"
            f"[1:a]volume=1.0,afade=t=out:st={duration-1.5}:d=1.5[a]"
        )
        inputs = [
            "-loop", "1", "-i", str(image_path),
            "-i", str(narration_path)
        ]
        maps = ["-map", "[v]", "-map", "[a]"]

    cmd = [
        "ffmpeg", "-y",
        *inputs,
        "-filter_complex", filter_complex,
        *maps,
        "-c:v", "libx264", "-preset", "medium", "-crf", "23",
        "-c:a", "aac", "-b:a", "128k",
        "-t", str(duration),
        "-pix_fmt", "yuv420p",
        str(output_path)
    ]

    subprocess.run(cmd, check=True, capture_output=True)
    return output_path
```

---

## Task 9: Write Main Function and CLI

**Files:**
- Modify: `.claude/skills/generate-tiktok-video/scripts/generate_tiktok.py`

**Step 1: Add the main function**

Add at the end of the file:

```python
def get_random_ambient() -> Path | None:
    """Get a random ambient track if available."""
    if not AMBIENT_DIR.exists():
        return None

    tracks = list(AMBIENT_DIR.glob("*.mp3"))
    if not tracks:
        return None

    return random.choice(tracks)


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

    # Load gems
    print("Loading gems from tafsir...")
    gems = load_gems(surah, verse)
    print(f"  Found {len(gems)} gems:")
    for gem in gems:
        print(f"    - {gem['title']}")

    # Build narration script
    script = build_narration_script(gems)
    print(f"\nNarration script ({len(script)} chars):")
    print(f"  {script[:100]}...")

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

    # Compose video
    output_path = OUTPUT_DIR / f"{surah}_{verse}.mp4"
    print(f"\nComposing video with FFmpeg...")
    compose_video(image_path, narration_path, output_path, ambient_path)
    print(f"  Saved: {output_path}")

    # Clean up narration file
    narration_path.unlink()

    print(f"\nVideo generated successfully: {output_path}")
    return str(output_path)


if __name__ == "__main__":
    main()
```

**Step 2: Make script executable**

```bash
chmod +x .claude/skills/generate-tiktok-video/scripts/generate_tiktok.py
```

---

## Task 10: Add Ambient Audio Tracks

**Files:**
- Create: `.claude/skills/generate-tiktok-video/assets/ambient/README.md`

**Step 1: Create README explaining ambient audio setup**

```markdown
# Ambient Audio Tracks

Place royalty-free ambient MP3 files in this directory.

The script will randomly select one track per video generation.

## Recommended Sources

- [Free Music Archive](https://freemusicarchive.org/) - Search for "ambient" or "meditation"
- [Pixabay Music](https://pixabay.com/music/) - Free for commercial use
- [Mixkit](https://mixkit.co/free-stock-music/) - Free ambient tracks

## Naming Convention

- `ambient_1.mp3`
- `ambient_2.mp3`
- `ambient_3.mp3`

## Requirements

- MP3 format
- Loopable or at least 60 seconds long
- Soft, non-distracting background music
- No vocals or copyrighted material
```

---

## Task 11: Test End-to-End (Manual)

**Prerequisite:** Ensure you have:
- Verse art at `verse_art/1_1.png` (or generate with `/generate-verse-art 1:1`)
- `ELEVENLABS_API_KEY` in `.env`
- FFmpeg installed

**Step 1: Run the script**

```bash
source .venv/bin/activate && python .claude/skills/generate-tiktok-video/scripts/generate_tiktok.py 1:1
```

Expected output:
```
Generating TikTok video for Surah 1, Verse 1...
  Found verse art: verse_art/1_1.png
Loading gems from tafsir...
  Found 3 gems:
    - Divine Mercy
    - Sacred Beginning
    - Allah's Name
Narration script (XXX chars):
  This verse gives us these powerful insights...
Generating narration via ElevenLabs...
  Saved: tiktok_videos/1_1_narration.mp3
Composing video with FFmpeg...
  Saved: tiktok_videos/1_1.mp4
Video generated successfully: tiktok_videos/1_1.mp4
```

**Step 2: Verify output video**

```bash
ls -la tiktok_videos/1_1.mp4
ffprobe tiktok_videos/1_1.mp4 2>&1 | grep -E "Duration|Video|Audio"
```

Expected: Video file exists with ~15-30s duration, 1080x1920 resolution, H.264 video + AAC audio.

---

## Summary

| Task | Description | Estimated Time |
|------|-------------|----------------|
| 1 | Create directory structure | 2 min |
| 2 | Create SKILL.md | 3 min |
| 3 | Update .env.example | 2 min |
| 4 | Install Python dependencies | 2 min |
| 5 | Write data loading functions | 5 min |
| 6 | Write narration script builder | 3 min |
| 7 | Write ElevenLabs TTS function | 5 min |
| 8 | Write FFmpeg composition | 10 min |
| 9 | Write main function + CLI | 5 min |
| 10 | Add ambient audio docs | 3 min |
| 11 | End-to-end test | 5 min |
| 12 | Final commit | 2 min |

**Total: ~47 minutes**
