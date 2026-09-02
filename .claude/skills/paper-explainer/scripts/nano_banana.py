#!/usr/bin/env python3
"""
Generate / edit an image with Nano Banana Pro (google/gemini-3-pro-image)
via OpenRouter's Unified Image API (POST /api/v1/images).

Env: OPENROUTER_API_KEY
Usage:
  python3 scripts/nano_banana.py --prompt "..." --output out.png
  python3 scripts/nano_banana.py --prompt "..." --ref base.png --output out.png
  python3 scripts/nano_banana.py --prompt "..." --size 4K --aspect 9:16 --output out.png

Notes:
  - Resolution tiers: 1K, 2K, 4K. For this model, 2K is currently IDENTICAL to 1K
    (same ~1MP / 768px-wide 9:16 output, same price). Use 4K when you need genuinely
    higher resolution - crisp text, or delivery above ~768px (e.g. 1080x1920 video).
  - Aspect ratios: 1:1, 2:3, 3:2, 3:4, 4:3, 4:5, 5:4, 9:16, 16:9, 21:9.
  - Reference images (--ref) are passed as input_references. Always set --aspect
    explicitly with refs, or the output snaps to the last reference's ratio.
"""
import argparse
import base64
import os
import sys

import requests

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

MODEL = "google/gemini-3-pro-image"  # Nano Banana Pro (GA)
URL = "https://openrouter.ai/api/v1/images"
VALID_ASPECTS = ["1:1", "2:3", "3:2", "3:4", "4:3", "4:5", "5:4", "9:16", "16:9", "21:9"]
VALID_SIZES = ["1K", "2K", "4K"]


def b64_data_url(path):
    with open(path, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--ref", action="append", default=[],
                    help="Reference image(s) for character/style consistency")
    ap.add_argument("--output", required=True)
    ap.add_argument("--aspect", default="9:16", choices=VALID_ASPECTS)
    ap.add_argument("--size", default="1K", choices=VALID_SIZES,
                    help="Resolution tier (2K==1K for this model; use 4K for hi-res)")
    args = ap.parse_args()

    key = os.environ.get("OPENROUTER_API_KEY")
    if not key:
        print("ERROR: OPENROUTER_API_KEY not set", file=sys.stderr)
        sys.exit(1)

    payload = {
        "model": MODEL,
        "prompt": args.prompt,
        "resolution": args.size,
        "aspect_ratio": args.aspect,
    }
    if args.ref:
        payload["input_references"] = [
            {"type": "image_url", "image_url": {"url": b64_data_url(r)}}
            for r in args.ref
        ]

    resp = requests.post(
        URL,
        headers={"Authorization": f"Bearer {key}",
                 "Content-Type": "application/json"},
        json=payload,
        timeout=300,
    )
    if resp.status_code != 200:
        print(f"ERROR {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)

    data = resp.json()
    items = data.get("data") or []
    if not items or not items[0].get("b64_json"):
        print(f"ERROR: no image in response: {data}", file=sys.stderr)
        sys.exit(1)

    raw = base64.b64decode(items[0]["b64_json"])
    with open(args.output, "wb") as f:
        f.write(raw)
    print(f"Wrote {args.output} ({len(raw)} bytes)")


if __name__ == "__main__":
    main()
