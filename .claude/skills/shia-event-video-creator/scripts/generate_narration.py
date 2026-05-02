#!/usr/bin/env python3
"""
Generate per-scene ElevenLabs narration MP3s for an event video.

Reads `<event-dir>/narration.json` and writes one MP3 per scene into
`<event-dir>/audio/scene_N.mp3`. Works for any number of scenes.

Usage:
    python generate_narration.py --event-dir video_output/aam-al-huzn/
    python generate_narration.py --event-dir <dir> --voice-id <eleven_labs_voice_id>

narration.json format:
    [
      {"scene": 1, "text": "For years, Abu Talib was the shield of the Prophet."},
      {"scene": 2, "text": "When illness came, the Prophet would not leave his side."},
      ...
    ]

Env vars (auto-loaded from .env via python-dotenv):
    ELEVENLABS_API_KEY    Required. Your ElevenLabs API key.

Defaults:
    Voice ID: pNInz6obpgDQGcFmaJgB (Adam — calm, clear male English voice)
    Model:    eleven_multilingual_v2 (handles English well, serviceable for Arabic)

Exits 0 on success; non-zero on any failure. Prints output paths as they're written.
"""

import argparse
import json
import os
import sys
from pathlib import Path

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

DEFAULT_VOICE_ID = "pNInz6obpgDQGcFmaJgB"  # Adam (English, calm, clear)
DEFAULT_MODEL = "eleven_multilingual_v2"


def main() -> int:
    ap = argparse.ArgumentParser(description="Generate per-scene ElevenLabs narrations.")
    ap.add_argument("--event-dir", required=True, help="Event folder (must contain narration.json).")
    ap.add_argument("--voice-id", default=DEFAULT_VOICE_ID, help=f"ElevenLabs voice ID (default: Adam {DEFAULT_VOICE_ID}).")
    ap.add_argument("--model", default=DEFAULT_MODEL, help=f"ElevenLabs model (default: {DEFAULT_MODEL}).")
    ap.add_argument("--overwrite", action="store_true", help="Regenerate MP3s that already exist.")
    args = ap.parse_args()

    event_dir = Path(args.event_dir).resolve()
    narration_file = event_dir / "narration.json"
    audio_dir = event_dir / "audio"
    audio_dir.mkdir(parents=True, exist_ok=True)

    if not narration_file.exists():
        print(f"ERROR: {narration_file} not found. Create it with your per-scene narration.", file=sys.stderr)
        return 1

    api_key = os.environ.get("ELEVENLABS_API_KEY")
    if not api_key:
        print("ERROR: ELEVENLABS_API_KEY not set. Add to .env or export it.", file=sys.stderr)
        return 1

    try:
        from elevenlabs import ElevenLabs
    except ImportError:
        print("ERROR: elevenlabs package not installed. Run: pip install elevenlabs", file=sys.stderr)
        return 1

    with narration_file.open() as f:
        narrations = json.load(f)

    if not isinstance(narrations, list):
        print(f"ERROR: {narration_file} must contain a JSON array.", file=sys.stderr)
        return 1

    client = ElevenLabs(api_key=api_key)

    for entry in narrations:
        scene_num = entry.get("scene")
        text = entry.get("text", "").strip()
        if scene_num is None or not text:
            print(f"WARNING: skipping entry with missing scene/text: {entry}", file=sys.stderr)
            continue

        output_path = audio_dir / f"scene_{scene_num}.mp3"
        if output_path.exists() and not args.overwrite:
            print(f"[scene {scene_num}] EXISTS — skipping (use --overwrite to regenerate)", file=sys.stderr)
            continue

        print(f"[scene {scene_num}] Generating: {text!r}", file=sys.stderr)
        audio_iter = client.text_to_speech.convert(
            voice_id=args.voice_id,
            text=text,
            model_id=args.model,
        )
        with output_path.open("wb") as f:
            for chunk in audio_iter:
                if chunk:
                    f.write(chunk)
        print(str(output_path))

    print("All narrations written.", file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
