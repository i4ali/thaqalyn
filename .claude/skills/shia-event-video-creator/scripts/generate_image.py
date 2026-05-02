#!/usr/bin/env python3
"""
Generate a single image using Nano Banana (Google Gemini Image) or ChatGPT Image.

Recommended provider for Al-Thaqalayn pipeline: `openrouter` (uses Nano Banana Pro
via the same OpenRouter key you already use for verse-art generation).

Usage:
    python generate_image.py \\
        --prompt "full prompt text" \\
        --output /path/to/output.png \\
        --provider openrouter \\
        --aspect 9:16

Providers:
    openrouter        Google Gemini 3 Pro Image (Nano Banana Pro) via OpenRouter.
                      Requires OPENROUTER_API_KEY. RECOMMENDED.
    nano-banana-pro   Google Gemini 3 Pro Image via direct Gemini API.
                      Requires GEMINI_API_KEY.
    nano-banana       Google Gemini 2.5 Flash Image (cheaper, lower quality) via
                      direct Gemini API. Requires GEMINI_API_KEY.
    chatgpt           OpenAI gpt-image-1. Requires OPENAI_API_KEY.

Environment variables (auto-loaded from .env via python-dotenv if present):
    OPENROUTER_API_KEY    OpenRouter API key (recommended path)
    GEMINI_API_KEY        Google AI API key (for direct Gemini)
    OPENAI_API_KEY        OpenAI API key (for ChatGPT Image)

Exits with 0 on success, non-zero on failure. Prints the output path on success.
"""

import argparse
import base64
import os
import sys
from pathlib import Path

import requests

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass


def gemini_aspect_to_size(aspect: str) -> str:
    """Gemini image models accept aspect_ratio strings directly."""
    # Gemini accepts: "1:1", "3:4", "4:3", "9:16", "16:9", "2:3", "3:2", "4:5", "5:4", "21:9"
    valid = {"1:1", "3:4", "4:3", "9:16", "16:9", "2:3", "3:2", "4:5", "5:4", "21:9"}
    if aspect not in valid:
        print(f"Warning: aspect {aspect} may not be supported by Gemini. Using 9:16.", file=sys.stderr)
        return "9:16"
    return aspect


def openai_aspect_to_size(aspect: str) -> str:
    """gpt-image-1 accepts specific size strings."""
    mapping = {
        "1:1": "1024x1024",
        "9:16": "1024x1536",  # portrait
        "16:9": "1536x1024",  # landscape
    }
    return mapping.get(aspect, "1024x1536")


def generate_nano_banana(prompt: str, output: Path, aspect: str, model: str = "gemini-2.5-flash-image-preview") -> None:
    """
    Call Google Gemini image generation via REST.
    Endpoint: https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent
    """
    api_key = os.environ.get("GEMINI_API_KEY")
    if not api_key:
        raise RuntimeError("GEMINI_API_KEY is not set. Export it before running.")

    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
    payload = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "responseModalities": ["IMAGE"],
            "imageConfig": {"aspectRatio": gemini_aspect_to_size(aspect)},
        },
    }

    r = requests.post(url, json=payload, timeout=120)
    if r.status_code != 200:
        raise RuntimeError(f"Gemini API error {r.status_code}: {r.text[:500]}")

    data = r.json()
    # Walk the response to find the inline image data
    candidates = data.get("candidates", [])
    if not candidates:
        raise RuntimeError(f"No candidates in Gemini response: {data}")

    parts = candidates[0].get("content", {}).get("parts", [])
    for part in parts:
        inline = part.get("inlineData") or part.get("inline_data")
        if inline and inline.get("data"):
            image_bytes = base64.b64decode(inline["data"])
            output.parent.mkdir(parents=True, exist_ok=True)
            output.write_bytes(image_bytes)
            return

    # Fallback: sometimes text-only refusal
    for part in parts:
        if part.get("text"):
            raise RuntimeError(f"Gemini refused or returned text instead of image: {part['text'][:500]}")
    raise RuntimeError(f"No image data found in Gemini response: {data}")


def generate_openrouter(prompt: str, output: Path, aspect: str, model: str = "google/gemini-3-pro-image-preview") -> None:
    """
    Call Google Gemini 3 Pro Image via OpenRouter's chat completions endpoint.
    OpenRouter accepts `modalities: ["image", "text"]` and returns images inline.
    """
    api_key = os.environ.get("OPENROUTER_API_KEY")
    if not api_key:
        raise RuntimeError("OPENROUTER_API_KEY is not set. Add it to .env or export it.")

    aspect_hint = f"Generate a vertical {aspect} story format image, very tall and narrow (1080x1920 pixels)." if aspect == "9:16" else f"Generate an image with aspect ratio {aspect}."
    full_prompt = f"{aspect_hint}\n\n{prompt}"

    url = "https://openrouter.ai/api/v1/chat/completions"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://thaqalayn.app",
        "X-Title": "Thaqalayn Shia Event Video Creator",
    }
    payload = {
        "model": model,
        "messages": [{"role": "user", "content": full_prompt}],
        "modalities": ["image", "text"],
    }

    r = requests.post(url, headers=headers, json=payload, timeout=180)
    if r.status_code != 200:
        raise RuntimeError(f"OpenRouter API error {r.status_code}: {r.text[:500]}")

    data = r.json()
    choices = data.get("choices", [])
    if not choices:
        raise RuntimeError(f"No choices in OpenRouter response: {data}")

    message = choices[0].get("message", {})

    # Primary: message.images array
    for img in message.get("images", []) or []:
        if isinstance(img, dict) and "image_url" in img:
            u = img["image_url"].get("url", "")
            if u.startswith("data:"):
                b64 = u.split(",", 1)[1]
                output.parent.mkdir(parents=True, exist_ok=True)
                output.write_bytes(base64.b64decode(b64))
                return
            if u:
                fetched = requests.get(u, timeout=120)
                fetched.raise_for_status()
                output.parent.mkdir(parents=True, exist_ok=True)
                output.write_bytes(fetched.content)
                return

    # Fallback: content with inline_data (raw Gemini format passthrough)
    content = message.get("content", [])
    if isinstance(content, list):
        for part in content:
            if not isinstance(part, dict):
                continue
            if "inline_data" in part and "data" in part["inline_data"]:
                output.parent.mkdir(parents=True, exist_ok=True)
                output.write_bytes(base64.b64decode(part["inline_data"]["data"]))
                return
            if "image_url" in part:
                u = part["image_url"].get("url", "")
                if u.startswith("data:"):
                    output.parent.mkdir(parents=True, exist_ok=True)
                    output.write_bytes(base64.b64decode(u.split(",", 1)[1]))
                    return

    # Final fallback: text-only refusal
    if isinstance(content, str) and content:
        raise RuntimeError(f"OpenRouter returned text instead of image: {content[:500]}")
    raise RuntimeError(f"No image data in OpenRouter response: {data}")


def generate_chatgpt(prompt: str, output: Path, aspect: str) -> None:
    """
    Call OpenAI gpt-image-1 via REST.
    Endpoint: https://api.openai.com/v1/images/generations
    """
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        raise RuntimeError("OPENAI_API_KEY is not set. Export it before running.")

    url = "https://api.openai.com/v1/images/generations"
    payload = {
        "model": "gpt-image-1",
        "prompt": prompt,
        "size": openai_aspect_to_size(aspect),
        "n": 1,
    }
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }

    r = requests.post(url, json=payload, headers=headers, timeout=180)
    if r.status_code != 200:
        raise RuntimeError(f"OpenAI API error {r.status_code}: {r.text[:500]}")

    data = r.json()
    items = data.get("data", [])
    if not items:
        raise RuntimeError(f"No image in OpenAI response: {data}")

    first = items[0]
    # gpt-image-1 returns base64 by default
    if first.get("b64_json"):
        image_bytes = base64.b64decode(first["b64_json"])
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(image_bytes)
        return
    # Some endpoints return a URL
    if first.get("url"):
        img = requests.get(first["url"], timeout=120)
        img.raise_for_status()
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_bytes(img.content)
        return
    raise RuntimeError(f"No image data in OpenAI response: {first}")


def main() -> int:
    ap = argparse.ArgumentParser(description="Generate a religious-video scene image.")
    ap.add_argument("--prompt", required=True, help="The full image generation prompt.")
    ap.add_argument("--output", required=True, help="Output PNG path.")
    ap.add_argument(
        "--provider",
        choices=["nano-banana", "nano-banana-pro", "openrouter", "chatgpt"],
        default="nano-banana",
        help="Which API to call.",
    )
    ap.add_argument("--aspect", default="9:16", help="Aspect ratio (default 9:16 for TikTok).")
    ap.add_argument("--scene-num", type=int, default=None, help="Optional scene number for logging.")
    args = ap.parse_args()

    output_path = Path(args.output)

    scene_tag = f"[scene {args.scene_num}] " if args.scene_num else ""
    print(f"{scene_tag}Generating image via {args.provider} → {output_path}", file=sys.stderr)

    try:
        if args.provider == "nano-banana":
            generate_nano_banana(args.prompt, output_path, args.aspect, model="gemini-2.5-flash-image-preview")
        elif args.provider == "nano-banana-pro":
            generate_nano_banana(args.prompt, output_path, args.aspect, model="gemini-3-pro-image-preview")
        elif args.provider == "openrouter":
            generate_openrouter(args.prompt, output_path, args.aspect)
        elif args.provider == "chatgpt":
            generate_chatgpt(args.prompt, output_path, args.aspect)
    except Exception as e:
        print(f"{scene_tag}ERROR: {e}", file=sys.stderr)
        return 1

    print(str(output_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
