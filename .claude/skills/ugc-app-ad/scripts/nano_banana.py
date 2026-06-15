#!/usr/bin/env python3
"""
Generate / edit an image with Nano Banana Pro via OpenRouter.

Env: OPENROUTER_API_KEY
Usage:
  python3 scripts/nano_banana.py --prompt "..." --output out.png
  python3 scripts/nano_banana.py --prompt "..." --ref base.png --output out.png
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

MODEL = "google/gemini-3-pro-image-preview"  # Nano Banana Pro
URL = "https://openrouter.ai/api/v1/chat/completions"


def b64_data_url(path):
    with open(path, "rb") as f:
        return "data:image/png;base64," + base64.b64encode(f.read()).decode()


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--ref", action="append", default=[],
                    help="Reference image(s) for character/style consistency")
    ap.add_argument("--output", required=True)
    args = ap.parse_args()

    key = os.environ.get("OPENROUTER_API_KEY")
    if not key:
        print("ERROR: OPENROUTER_API_KEY not set", file=sys.stderr)
        sys.exit(1)

    content = [{"type": "text", "text": args.prompt}]
    for r in args.ref:
        content.append({"type": "image_url",
                         "image_url": {"url": b64_data_url(r)}})

    resp = requests.post(
        URL,
        headers={"Authorization": f"Bearer {key}",
                 "Content-Type": "application/json"},
        json={"model": MODEL,
              "messages": [{"role": "user", "content": content}],
              "modalities": ["image", "text"]},
        timeout=240,
    )
    if resp.status_code != 200:
        print(f"ERROR {resp.status_code}: {resp.text}", file=sys.stderr)
        sys.exit(1)

    data = resp.json()
    images = data["choices"][0]["message"].get("images") or []
    if not images:
        print(f"ERROR: no image in response: {data}", file=sys.stderr)
        sys.exit(1)

    img_url = images[0]["image_url"]["url"]
    raw = base64.b64decode(img_url.split(",", 1)[1])
    with open(args.output, "wb") as f:
        f.write(raw)
    print(f"Wrote {args.output} ({len(raw)} bytes)")


if __name__ == "__main__":
    main()
