"""Generate dark atmospheric backgrounds (no text) via OpenRouter Nano Banana."""
import base64
import os
from io import BytesIO

import requests
from dotenv import load_dotenv
from PIL import Image, ImageOps

from . import config

load_dotenv()

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
MODEL = "google/gemini-3-pro-image-preview"


def build_bg_prompt(slide: dict) -> str:
    return (
        f"Generate a 4:5 vertical portrait image (1080x1350 pixels). "
        f"{slide['bg_prompt']} {config.BG_STYLE}"
    )


def normalize(img: Image.Image) -> Image.Image:
    """Center-crop to 4:5 and resize to exactly the canvas size."""
    img = img.convert("RGB")
    return ImageOps.fit(
        img,
        (config.CANVAS_W, config.CANVAS_H),
        method=Image.LANCZOS,
        centering=(0.5, 0.5),
    )


def _request_image(prompt: str) -> bytes:
    if not OPENROUTER_API_KEY:
        raise ValueError("OPENROUTER_API_KEY not found in .env")
    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://thaqalayn.app",
        "X-Title": "Thaqalayn Dhul-Hijjah Carousel",
    }
    payload = {
        "model": MODEL,
        "messages": [{"role": "user", "content": prompt}],
        "modalities": ["image", "text"],
    }
    resp = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers=headers, json=payload, timeout=120,
    )
    if resp.status_code != 200:
        raise Exception(f"API error {resp.status_code}: {resp.text}")
    message = resp.json()["choices"][0]["message"]
    for img in message.get("images", []):
        url = img.get("image_url", {}).get("url", "")
        if url.startswith("data:"):
            return base64.b64decode(url.split(",", 1)[1])
        if url:
            r = requests.get(url, timeout=60)
            r.raise_for_status()
            return r.content
    raise Exception(f"No image in response: {resp.json()}")


def generate(slide: dict) -> Image.Image:
    raw = _request_image(build_bg_prompt(slide))
    return normalize(Image.open(BytesIO(raw)))


def generate_all() -> dict:
    """Generate + cache all 5 backgrounds. Returns {index: Path}."""
    config.BG_DIR.mkdir(parents=True, exist_ok=True)
    out = {}
    for slide in config.SLIDES:
        path = config.BG_DIR / f"bg_{slide['index']}.png"
        img = generate(slide)
        img.save(path)
        print(f"  bg slide {slide['index']} -> {path}")
        out[slide["index"]] = path
    return out
