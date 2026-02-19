#!/usr/bin/env python3
"""
Generate abstract/artistic AI images for Quranic verses using OpenRouter's Nano Banana Pro model.
"""

import json
import os
import sys
import base64
import requests
from pathlib import Path
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Configuration
OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
MODEL = "google/gemini-3-pro-image-preview"
OUTPUT_DIR = Path("verse_art")
DATA_DIR = Path("Thaqalayn/Thaqalayn/Data")


def load_verse_data(surah: int, verse: int) -> dict:
    """Load verse text and translation from quran_data.json."""
    quran_path = DATA_DIR / "quran_data.json"

    with open(quran_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    surah_str = str(surah)
    verse_str = str(verse)

    if surah_str not in data.get("verses", {}):
        raise ValueError(f"Surah {surah} not found in quran_data.json")

    if verse_str not in data["verses"][surah_str]:
        raise ValueError(f"Verse {verse} not found in Surah {surah}")

    verse_data = data["verses"][surah_str][verse_str]

    # Get surah info
    surah_info = next((s for s in data["surahs"] if s["number"] == surah), None)

    return {
        "arabic": verse_data.get("arabicText", ""),
        "translation": verse_data.get("translation", ""),
        "surah_name": surah_info.get("englishName", "") if surah_info else "",
        "surah_meaning": surah_info.get("englishNameTranslation", "") if surah_info else ""
    }


def load_tafsir_context(surah: int, verse: int) -> dict:
    """Load tafsir layer1 context and gems if available."""
    tafsir_path = DATA_DIR / f"tafsir_{surah}.json"

    result = {"context": "", "gems": []}

    if not tafsir_path.exists():
        return result

    try:
        with open(tafsir_path, "r", encoding="utf-8") as f:
            data = json.load(f)

        verse_str = str(verse)
        if verse_str in data:
            layer1 = data[verse_str].get("layer1", "")
            # Return first 300 chars of context
            result["context"] = layer1[:300] + "..." if len(layer1) > 300 else layer1

            # Load gems from quickOverview.concepts
            quick_overview = data[verse_str].get("quickOverview", {})
            concepts = quick_overview.get("concepts", [])
            for concept in concepts:
                gem = {
                    "title": concept.get("title", ""),
                    "insight": concept.get("coreInsight", ""),
                    "arabic": concept.get("arabicHighlight", "")
                }
                if gem["title"] and gem["insight"]:
                    result["gems"].append(gem)
    except Exception:
        pass

    return result


def build_prompt(verse_data: dict, tafsir_data: dict) -> str:
    """Build the image generation prompt."""
    prompt_parts = [
        "Generate a vertical 9:16 story format image, very tall and narrow (1080x1920 pixels).",
        "",
        "Create a beautiful spiritual artwork for this Quranic verse that includes TEXT overlays.",
        "",
        "=== ARABIC VERSE (display prominently at top) ===",
        f"{verse_data['arabic']}",
        "",
        f"Translation: {verse_data['translation']}",
    ]

    # Add gems if available
    gems = tafsir_data.get("gems", [])
    if gems:
        prompt_parts.extend([
            "",
            "=== KEY GEMS TO DISPLAY AS TEXT ON THE IMAGE ==="
        ])
        for i, gem in enumerate(gems, 1):
            prompt_parts.extend([
                f"",
                f"Gem {i}: \"{gem['title']}\"",
                f"Insight: {gem['insight'][:150]}..."
            ])

    prompt_parts.extend([
        "",
        "=== TIKTOK SAFE ZONES ===",
        "Keep all text within safe zones to avoid TikTok UI overlap:",
        "- TOP: Avoid top 200 pixels (status bar, search)",
        "- BOTTOM: Avoid bottom 250 pixels (username, caption)",
        "- RIGHT: Avoid right 120 pixels (like/comment/share buttons)",
        "",
        "=== DESIGN INSTRUCTIONS ===",
        "1. Display the Arabic verse text beautifully in the UPPER-CENTER safe zone",
        "2. Create gem/insight cards or bubbles with the gem titles and short insights",
        "3. Use an ethereal, cosmic background with flowing light and colors",
        "4. NO human figures, NO faces",
        "5. Make the text readable and prominent - this is a verse art card for social sharing",
        "6. Use rich, harmonious colors that evoke spirituality",
        "7. The Arabic text MUST be included and clearly readable",
        "8. Keep text LEFT or CENTER aligned, avoiding the right edge"
    ])

    return "\n".join(prompt_parts)


def generate_image(prompt: str) -> bytes:
    """Call OpenRouter API to generate image using chat completions endpoint."""
    if not OPENROUTER_API_KEY:
        raise ValueError("OPENROUTER_API_KEY not found in .env file")

    headers = {
        "Authorization": f"Bearer {OPENROUTER_API_KEY}",
        "Content-Type": "application/json",
        "HTTP-Referer": "https://thaqalayn.app",
        "X-Title": "Thaqalayn Verse Art Generator"
    }

    payload = {
        "model": MODEL,
        "messages": [
            {
                "role": "user",
                "content": prompt
            }
        ],
        "modalities": ["image", "text"]
    }

    response = requests.post(
        "https://openrouter.ai/api/v1/chat/completions",
        headers=headers,
        json=payload,
        timeout=120
    )

    if response.status_code != 200:
        raise Exception(f"API error {response.status_code}: {response.text}")

    result = response.json()

    # Handle chat completions response format
    if "choices" in result and len(result["choices"]) > 0:
        message = result["choices"][0].get("message", {})

        # OpenRouter returns images in message.images array
        images = message.get("images", [])
        for img in images:
            if isinstance(img, dict) and "image_url" in img:
                url = img["image_url"].get("url", "")
                if url.startswith("data:"):
                    # Base64 data URL: data:image/png;base64,...
                    b64_data = url.split(",", 1)[1]
                    return base64.b64decode(b64_data)
                elif url:
                    # Regular URL - fetch the image
                    img_response = requests.get(url, timeout=60)
                    img_response.raise_for_status()
                    return img_response.content

        # Fallback: check content for inline_data format (raw Gemini format)
        content = message.get("content", [])
        if isinstance(content, list):
            for part in content:
                if isinstance(part, dict):
                    if "inline_data" in part:
                        inline_data = part["inline_data"]
                        if "data" in inline_data:
                            return base64.b64decode(inline_data["data"])
                    if "image_url" in part:
                        url = part["image_url"].get("url", "")
                        if url.startswith("data:"):
                            b64_data = url.split(",", 1)[1]
                            return base64.b64decode(b64_data)

    raise Exception(f"No image found in API response: {result}")


def save_image(image_data: bytes, surah: int, verse: int) -> Path:
    """Save the generated image."""
    OUTPUT_DIR.mkdir(exist_ok=True)

    output_path = OUTPUT_DIR / f"{surah}_{verse}.png"

    with open(output_path, "wb") as f:
        f.write(image_data)

    return output_path


def main():
    if len(sys.argv) < 2:
        print("Usage: python generate_art.py <surah:verse>")
        print("Example: python generate_art.py 1:1")
        sys.exit(1)

    # Parse input
    verse_ref = sys.argv[1]

    if ":" not in verse_ref:
        print(f"Invalid format: {verse_ref}. Use surah:verse (e.g., 1:1)")
        sys.exit(1)

    parts = verse_ref.split(":")
    surah = int(parts[0])
    verse = int(parts[1])

    print(f"Generating art for Surah {surah}, Verse {verse}...")

    # Load data
    print("Loading verse data...")
    verse_data = load_verse_data(surah, verse)
    print(f"  Surah: {verse_data['surah_name']} ({verse_data['surah_meaning']})")
    print(f"  Translation: {verse_data['translation'][:80]}...")

    print("Loading tafsir context and gems...")
    tafsir_data = load_tafsir_context(surah, verse)
    if tafsir_data["context"]:
        print(f"  Found tafsir context ({len(tafsir_data['context'])} chars)")
    if tafsir_data["gems"]:
        print(f"  Found {len(tafsir_data['gems'])} gems:")
        for gem in tafsir_data["gems"]:
            print(f"    - {gem['title']}")
    if not tafsir_data["context"] and not tafsir_data["gems"]:
        print("  No tafsir available, using translation only")

    # Build prompt
    prompt = build_prompt(verse_data, tafsir_data)
    print(f"\nPrompt preview:\n{prompt[:200]}...\n")

    # Generate image
    print("Calling OpenRouter API (Nano Banana Pro)...")
    image_data = generate_image(prompt)
    print(f"  Received {len(image_data)} bytes")

    # Save image
    output_path = save_image(image_data, surah, verse)
    print(f"\nImage saved to: {output_path}")

    return str(output_path)


if __name__ == "__main__":
    main()
