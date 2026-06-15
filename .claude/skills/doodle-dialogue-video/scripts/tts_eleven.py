#!/usr/bin/env python3
"""
ElevenLabs text-to-speech. Env: ELEVENLABS_API_KEY

Usage:
  python3 scripts/tts_eleven.py --list
  python3 scripts/tts_eleven.py --voice <voice_id> --text "..." --output out.mp3 \
      [--model eleven_multilingual_v2] [--stability 0.45] [--similarity 0.8] [--style 0.2]
"""
import argparse
import os
import sys

import requests

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

BASE = "https://api.elevenlabs.io/v1"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--list", action="store_true", help="List available voices and exit")
    ap.add_argument("--voice")
    ap.add_argument("--text")
    ap.add_argument("--output")
    ap.add_argument("--model", default="eleven_multilingual_v2")
    ap.add_argument("--stability", type=float, default=0.45)
    ap.add_argument("--similarity", type=float, default=0.8)
    ap.add_argument("--style", type=float, default=0.0)
    ap.add_argument("--format", default="mp3_44100_128")
    args = ap.parse_args()

    key = os.environ.get("ELEVENLABS_API_KEY")
    if not key:
        print("ERROR: ELEVENLABS_API_KEY not set", file=sys.stderr)
        sys.exit(1)

    if args.list:
        r = requests.get(f"{BASE}/voices", headers={"xi-api-key": key}, timeout=60)
        if r.status_code != 200:
            print(f"ERROR {r.status_code}: {r.text}", file=sys.stderr)
            sys.exit(1)
        for v in r.json().get("voices", []):
            lbl = v.get("labels", {}) or {}
            desc = ", ".join(f"{k}={val}" for k, val in lbl.items())
            print(f'{v["voice_id"]}  {v["name"]:16s} [{v.get("category","")}]  {desc}')
        return

    if not (args.voice and args.text and args.output):
        print("ERROR: need --voice, --text, --output (or --list)", file=sys.stderr)
        sys.exit(1)

    r = requests.post(
        f"{BASE}/text-to-speech/{args.voice}",
        params={"output_format": args.format},
        headers={"xi-api-key": key, "Content-Type": "application/json"},
        json={
            "text": args.text,
            "model_id": args.model,
            "voice_settings": {
                "stability": args.stability,
                "similarity_boost": args.similarity,
                "style": args.style,
                "use_speaker_boost": True,
            },
        },
        timeout=120,
    )
    if r.status_code != 200:
        print(f"ERROR {r.status_code}: {r.text}", file=sys.stderr)
        sys.exit(1)
    with open(args.output, "wb") as f:
        f.write(r.content)
    print(f"Wrote {args.output} ({len(r.content)} bytes)")


if __name__ == "__main__":
    main()
