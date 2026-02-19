#!/usr/bin/env python3
"""
Generate TikTok videos from verse art with AI narration using ElevenLabs TTS and FFmpeg.
Supports English and Urdu languages.
"""

import argparse
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
QURAN_DATA_PATH = DATA_DIR / "quran_data.json"
VERSE_ART_DIR = Path("verse_art")
OUTPUT_DIR = Path("tiktok_videos")
AMBIENT_DIR = Path(".claude/skills/generate-tiktok-video/assets/ambient")

# ElevenLabs voice IDs (using free premade voices with multilingual model)
VOICE_ID_EN = "pNInz6obpgDQGcFmaJgB"  # Adam - clear, calm male voice (English)
VOICE_ID_UR = "JBFqnCBsd6RMkjVDRZzb"  # George - warm storyteller (free, works with Urdu via multilingual model)

# Hook templates for engaging intros (English)
HOOK_TEMPLATES_EN = [
    "Most people miss these {n} meanings in this verse",
    "Here's what the scholars say about this powerful verse",
    "This verse holds {n} profound secrets",
]

# Hook templates for engaging intros (Urdu)
HOOK_TEMPLATES_UR = [
    "اس آیت میں {n} گہرے معانی جو اکثر لوگ نہیں جانتے",
    "علماء اس طاقتور آیت کے بارے میں کیا کہتے ہیں",
    "اس آیت میں {n} گہرے راز پوشیدہ ہیں",
]

# Timing estimates (seconds)
HOOK_DURATION = 3.0      # Hook display time
SETUP_DURATION = 3.0     # "Here are N insights"
GEM_INTRO_DURATION = 2.0 # "First/Second/Third..."
GEM_INSIGHT_DURATION = 8.0  # Average insight narration

# Font for text overlays (macOS system fonts)
FONT_PATH_EN = "/System/Library/Fonts/Helvetica.ttc"
FONT_PATH_UR = "/System/Library/Fonts/Supplemental/Arial Unicode.ttf"  # Supports Urdu/Arabic

# Urdu ordinals
ORDINALS_UR = ["پہلی", "دوسری", "تیسری"]


def load_surah_name(surah: int, lang: str = "en") -> str:
    """Load surah name from quran_data.json based on language."""
    if not QURAN_DATA_PATH.exists():
        raise FileNotFoundError(f"Quran data not found: {QURAN_DATA_PATH}")

    with open(QURAN_DATA_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    for surah_data in data.get("surahs", []):
        if surah_data.get("number") == surah:
            if lang == "ur":
                # Use Arabic name for Urdu (shared script)
                return surah_data.get("arabicName", surah_data.get("name", f"سورۃ {surah}"))
            return surah_data.get("englishName", f"Surah {surah}")

    return f"سورۃ {surah}" if lang == "ur" else f"Surah {surah}"


def load_gems(surah: int, verse: int, lang: str = "en") -> list[dict]:
    """Load gems from tafsir quickOverview.concepts based on language."""
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

    # Field names based on language
    title_key = "title_urdu" if lang == "ur" else "title"
    insight_key = "coreInsight_urdu" if lang == "ur" else "coreInsight"

    gems = []
    for concept in concepts:
        gem = {
            "title": concept.get(title_key, concept.get("title", "")),
            "insight": concept.get(insight_key, concept.get("coreInsight", ""))
        }
        if gem["title"] and gem["insight"]:
            gems.append(gem)

    if not gems:
        lang_name = "Urdu" if lang == "ur" else "English"
        raise ValueError(f"No {lang_name} gems found for {surah}:{verse}. Tafsir with quickOverview required.")

    return gems


def wrap_text(text: str, max_chars: int = 35) -> str:
    """Wrap text into multiple lines, breaking at word boundaries."""
    words = text.split()
    lines = []
    current_line = []
    current_length = 0

    for word in words:
        word_length = len(word)
        # +1 for space between words
        if current_length + word_length + (1 if current_line else 0) <= max_chars:
            current_line.append(word)
            current_length += word_length + (1 if len(current_line) > 1 else 0)
        else:
            if current_line:
                lines.append(" ".join(current_line))
            current_line = [word]
            current_length = word_length

    if current_line:
        lines.append(" ".join(current_line))

    return "\n".join(lines)


def generate_hook(gems: list[dict], count: int, lang: str = "en") -> str:
    """Generate a bold statement hook based on gem content and language."""
    # Extract theme from first gem title
    theme = gems[0]["title"].lower() if gems else "faith"

    # Pick template based on language
    templates = HOOK_TEMPLATES_UR if lang == "ur" else HOOK_TEMPLATES_EN
    template = random.choice(templates)
    hook = template.format(theme=theme, n=count)

    return hook


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


def build_drawtext_filters(hook: str, gems: list[dict], timings: dict, surah_name: str, verse: int, lang: str = "en") -> str:
    """Build FFmpeg drawtext filter chain for text overlays."""
    # Select font based on language
    font_path = FONT_PATH_UR if lang == "ur" else FONT_PATH_EN

    # Wrap hook text for multi-line display (shorter lines for Urdu)
    max_chars = 30 if lang == "ur" else 35
    hook_wrapped = wrap_text(hook, max_chars=max_chars)

    # Escape special characters for FFmpeg
    hook_escaped = hook_wrapped.replace("'", "'\\''").replace(":", "\\:")

    # Verse label format based on language
    if lang == "ur":
        # Urdu: سورۃ الفاتحہ : ۱
        verse_label = f"{surah_name} \\: {verse}"
    else:
        verse_label = f"{surah_name} \\: {verse}"
    verse_label_escaped = verse_label.replace("'", "'\\''")

    # Surah name and verse number at the top - elegant, persistent overlay
    # TikTok safe zone: ~200px from top to avoid status bar/back button
    verse_label_filter = (
        f"drawtext=text='{verse_label_escaped}':"
        f"fontfile={font_path}:"
        f"fontsize=36:fontcolor=white:"
        f"x=(w-text_w)/2:y=200:"  # Top center, within TikTok safe zone
        f"box=1:boxcolor=black@0.5:boxborderw=15:"  # Semi-transparent pill background
        f"borderw=1:bordercolor=white@0.6"  # Subtle glow outline
    )

    # Modern styled hook: center of screen, rounded pill background, glow outline
    # Use slightly smaller font for Urdu to accommodate longer text
    hook_fontsize = 42 if lang == "ur" else 48
    hook_filter = (
        f"drawtext=text='{hook_escaped}':"
        f"fontfile={font_path}:"
        f"fontsize={hook_fontsize}:fontcolor=white:"
        f"x=(w-text_w)/2:y=(h-text_h)/2:"  # Center positioning
        f"box=1:boxcolor=black@0.6:boxborderw=20:"  # Rounded pill background
        f"borderw=2:bordercolor=white@0.8:"  # Subtle glow outline
        f"enable='between(t,{timings['hook']['start']},{timings['hook']['end']})'"
    )

    # Combine both filters: verse label (always visible) + hook (timed)
    return f"{verse_label_filter},{hook_filter}"


def build_narration_script(gems: list[dict], hook: str, surah_name: str, verse: int, lang: str = "en") -> str:
    """Build narration script with hook, verse reference, and countdown pacing."""
    # Cap at 3 gems for optimal TikTok length
    gems = gems[:3]
    count = len(gems)

    if lang == "ur":
        # Urdu script
        lines = [
            hook,
            f"{surah_name}، آیت نمبر {verse} سے۔",
            f"یہ ہیں {count} اہم نکات۔"
        ]

        for i, gem in enumerate(gems):
            insight = gem["insight"].rstrip("۔").rstrip(".")
            lines.append(f"{ORDINALS_UR[i]}... {gem['title']}۔ {insight}۔")
    else:
        # English script
        ordinals = ["First", "Second", "Third"]
        lines = [
            hook,
            f"From Surah {surah_name}, verse {verse}.",
            f"Here are {count} insights."
        ]

        for i, gem in enumerate(gems):
            insight = gem["insight"].rstrip(".")
            lines.append(f"{ordinals[i]}... {gem['title']}. {insight}.")

    return "\n\n".join(lines)


def generate_narration(script: str, output_path: Path, lang: str = "en") -> Path:
    """Generate narration audio using ElevenLabs API."""
    if not ELEVENLABS_API_KEY:
        raise ValueError("ELEVENLABS_API_KEY not found in .env file")

    from elevenlabs import ElevenLabs

    client = ElevenLabs(api_key=ELEVENLABS_API_KEY)

    # Select voice based on language
    voice_id = VOICE_ID_UR if lang == "ur" else VOICE_ID_EN

    # Generate audio
    audio_generator = client.text_to_speech.convert(
        voice_id=voice_id,
        text=script,
        model_id="eleven_multilingual_v2"
    )

    # Write audio to file
    output_path.parent.mkdir(parents=True, exist_ok=True)
    with open(output_path, "wb") as f:
        for chunk in audio_generator:
            f.write(chunk)

    return output_path


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


def compose_video(
    image_path: Path,
    narration_path: Path,
    output_path: Path,
    text_filters: str,
    ambient_path: Path | None = None
) -> Path:
    """Compose video with Ken Burns effect, text overlays, and audio mixing."""

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


def get_random_ambient() -> Path | None:
    """Get a random ambient track if available."""
    if not AMBIENT_DIR.exists():
        return None

    tracks = list(AMBIENT_DIR.glob("*.mp3"))
    if not tracks:
        return None

    return random.choice(tracks)


def main():
    parser = argparse.ArgumentParser(
        description="Generate TikTok videos from verse art with AI narration."
    )
    parser.add_argument(
        "verse_ref",
        help="Verse reference in format surah:verse (e.g., 1:1, 2:255)"
    )
    parser.add_argument(
        "--urdu", "-u",
        action="store_true",
        help="Generate video with Urdu audio and text overlays"
    )

    args = parser.parse_args()

    # Determine language
    lang = "ur" if args.urdu else "en"
    lang_name = "Urdu" if lang == "ur" else "English"

    # Parse verse reference
    verse_ref = args.verse_ref
    if ":" not in verse_ref:
        print(f"Invalid format: {verse_ref}. Use surah:verse (e.g., 1:1)")
        sys.exit(1)

    parts = verse_ref.split(":")
    surah = int(parts[0])
    verse = int(parts[1])

    # Load surah name
    surah_name = load_surah_name(surah, lang)
    print(f"Generating {lang_name} TikTok video for {surah_name} ({surah}:{verse})...")

    # Check verse art exists
    image_path = VERSE_ART_DIR / f"{surah}_{verse}.png"
    if not image_path.exists():
        print(f"Error: Verse art not found at {image_path}")
        print(f"Run '/generate-verse-art {surah}:{verse}' first.")
        sys.exit(1)
    print(f"  Found verse art: {image_path}")

    # Load gems (cap at 3)
    print(f"Loading {lang_name} gems from tafsir...")
    all_gems = load_gems(surah, verse, lang)
    gems = all_gems[:3]
    print(f"  Using {len(gems)} of {len(all_gems)} gems:")
    for gem in gems:
        print(f"    - {gem['title']}")

    # Generate hook
    hook = generate_hook(gems, len(gems), lang)
    print(f"\nHook: {hook}")

    # Build narration script with verse reference and countdown
    script = build_narration_script(gems, hook, surah_name, verse, lang)
    print(f"\nNarration script ({len(script)} chars):")
    print(f"  {script[:100]}...")

    # Calculate text overlay timings
    timings = calculate_text_timings(len(gems))
    print(f"\nText overlay timings calculated for {len(gems)} gems")

    # Build text overlay filters
    text_filters = build_drawtext_filters(hook, gems, timings, surah_name, verse, lang)

    # Determine output directory based on language
    if lang == "ur":
        output_dir = OUTPUT_DIR / "urdu"
    else:
        output_dir = OUTPUT_DIR
    output_dir.mkdir(parents=True, exist_ok=True)

    # Generate narration audio
    narration_path = output_dir / f"{surah}_{verse}_narration.mp3"
    print(f"\nGenerating {lang_name} narration via ElevenLabs...")
    generate_narration(script, narration_path, lang)
    print(f"  Saved: {narration_path}")

    # Get ambient track
    ambient_path = get_random_ambient()
    if ambient_path:
        print(f"  Using ambient: {ambient_path.name}")
    else:
        print("  No ambient tracks found, using narration only")

    # Compose video with text overlays
    output_path = output_dir / f"{surah}_{verse}.mp4"
    print(f"\nComposing video with FFmpeg...")
    compose_video(image_path, narration_path, output_path, text_filters, ambient_path)
    print(f"  Saved: {output_path}")

    # Clean up narration file
    narration_path.unlink()

    print(f"\n{lang_name} video generated successfully: {output_path}")
    return str(output_path)


if __name__ == "__main__":
    main()
