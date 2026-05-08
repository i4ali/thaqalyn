#!/usr/bin/env python3
"""Per-verse tafsir-video orchestrator.

Usage:
  python3 generate_tafsir_video.py --verse 2:258 --script-file path/to/script.txt
"""
from __future__ import annotations
import argparse
import sys
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

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


def hashtags_path_for(surah: int, verse: int, base_dir: Path = OUTPUT_DIR) -> Path:
    return base_dir / f"{surah}_{verse}_hashtags.txt"


def publish_hashtags(hashtags_file: Path, surah: int, verse: int) -> Path:
    """Copy the agent-curated hashtags to the output dir and print them."""
    src = Path(hashtags_file)
    if not src.exists() or not src.read_text().strip():
        raise FileNotFoundError(f"Hashtags file not found or empty: {src}")
    dst = hashtags_path_for(surah, verse)
    dst.parent.mkdir(parents=True, exist_ok=True)
    dst.write_text(src.read_text().strip() + "\n")
    print()
    print("=" * 60)
    print(f"TikTok hashtags for {surah}:{verse} (paste into your post):")
    print("=" * 60)
    print(dst.read_text().strip())
    print("=" * 60)
    return dst


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--verse", required=True, help="SURAH:VERSE, e.g., 2:258")
    p.add_argument("--script-file", required=True, help="Path to approved narration script")
    p.add_argument("--hashtags-file", default=None,
                   help="Optional path to a file containing 5 agent-curated hashtags")
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

    if args.hashtags_file:
        publish_hashtags(Path(args.hashtags_file), surah, verse)

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
