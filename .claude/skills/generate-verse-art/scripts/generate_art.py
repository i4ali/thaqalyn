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
MODEL = "google/gemini-3-pro-image"
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
    """Build the Nano Banana Pro prompt as a descriptive creative-director brief.

    Follows the model's prompting guide: narrative brief (not keyword soup),
    positive framing for exclusions, exact text quoted for literal rendering,
    a clear type hierarchy, and short caption strings (long insight bodies are
    NOT rendered - they garble at small sizes). Resolution is set to 4K in the
    API call so the Arabic and English stay legible.
    """
    arabic = verse_data["arabic"]
    translation = verse_data["translation"]
    gems = tafsir_data.get("gems", [])

    lines = [
        "A vertical 9:16 devotional artwork for a Quranic verse.",
        "",
        "STYLE & SUBJECT: an ethereal, cosmic devotional artwork - a deep spiritual "
        "atmosphere of flowing light, nebular color, and soft luminous depth in rich, "
        "harmonious tones. The scene is purely abstract: only light, color, and gentle "
        "particulate texture, with generous calm negative space. The field is unpopulated "
        "and serene.",
        "",
        "TEXT TO RENDER - render these exact strings, spelled precisely, all clearly legible:",
        f'- Arabic verse (top-center, largest, elegant Naskh calligraphy): "{arabic}"',
        f'- English translation (below the Arabic, medium weight, clean serif): "{translation}"',
    ]

    if gems:
        lines.append("- Caption chips (smallest, clean sans-serif), each on its own tidy card:")
        for gem in gems:
            lines.append(f'    - "{gem["title"]}"')

    lines += [
        "",
        "TYPOGRAPHY: a clear size hierarchy - Arabic verse largest, English translation "
        "medium, caption chips smallest - with strong contrast against the background so "
        "every character stays crisp and correctly rendered.",
        "",
        "LAYOUT (keep all text inside TikTok-safe margins): place text in the central "
        "column. Keep the top ~12% and bottom ~13% of the frame clear of text, and keep "
        "clear of the right ~11% edge. The Arabic sits in the upper-center; caption chips "
        "arrange neatly in the middle; text is left- or center-aligned and never touches "
        "the edges.",
        "",
        "Render only the verse text specified above - no logo, watermark, signature, "
        "footer, or caption of any kind.",
    ]

    return "\n".join(lines)


def generate_image(prompt: str) -> bytes:
    """Generate the verse-art image via OpenRouter's Unified Image API.

    Uses "1K". Measured: this model caps multi-element text-card layouts at ~768px
    wide regardless of the requested tier - "4K" bills ~1.8x but returns the identical
    768x1376 pixels for this prompt, so a higher tier is pure waste here. The model
    still renders the Arabic + English legibly at this size; for a larger, truly crisp
    canvas the text would have to be composited (PIL) rather than model-rendered.
    """
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
        "prompt": prompt,
        "resolution": "1K",
        "aspect_ratio": "9:16",
    }

    response = requests.post(
        "https://openrouter.ai/api/v1/images",
        headers=headers,
        json=payload,
        timeout=300
    )

    if response.status_code != 200:
        raise Exception(f"API error {response.status_code}: {response.text}")

    result = response.json()
    items = result.get("data") or []
    if items and items[0].get("b64_json"):
        return base64.b64decode(items[0]["b64_json"])

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
