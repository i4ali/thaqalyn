#!/usr/bin/env python3
"""
Multi-Language Translation Script for Tafsir JSON Files using Google Translate
Translates tafsir content from English to Arabic, French, Urdu, and other languages.
Uses the free googletrans package (unofficial Google Translate API).

Usage:
    python translate_tafsir.py <tafsir_file.json> <target_language>

Examples:
    python translate_tafsir.py Data/tafsir_1.json ar    # Translate to Arabic
    python translate_tafsir.py Data/tafsir_1.json fr    # Translate to French
    python translate_tafsir.py Data/tafsir_1.json ur    # Translate to Urdu

Supported Languages:
    ar - Arabic
    fr - French
    ur - Urdu
    tr - Turkish
    id - Indonesian
    fa - Persian/Farsi
    ms - Malay
    bn - Bengali
    hi - Hindi
    es - Spanish
    de - German
    ru - Russian
    zh-cn - Chinese (Simplified)
"""

import json
import sys
import asyncio
import time
from googletrans import Translator
from pathlib import Path

# Language code mappings for googletrans
SUPPORTED_LANGUAGES = {
    "ar": "ar",      # Arabic
    "fr": "fr",      # French
    "ur": "ur",      # Urdu
    "tr": "tr",      # Turkish
    "id": "id",      # Indonesian
    "fa": "fa",      # Persian/Farsi
    "ms": "ms",      # Malay
    "bn": "bn",      # Bengali
    "hi": "hi",      # Hindi
    "es": "es",      # Spanish
    "de": "de",      # German
    "ru": "ru",      # Russian
    "zh-cn": "zh-cn", # Chinese (Simplified)
}

# JSON field suffix for each language
LANGUAGE_SUFFIXES = {
    "ar": "_ar",
    "fr": "_fr",
    "ur": "_urdu",  # Keep existing convention for Urdu
    "tr": "_tr",
    "id": "_id",
    "fa": "_fa",
    "ms": "_ms",
    "bn": "_bn",
    "hi": "_hi",
    "es": "_es",
    "de": "_de",
    "ru": "_ru",
    "zh-cn": "_zh",
}

async def translate_text(text, translator, target_lang='ur', max_retries=3):
    """Translate English text to target language with retry logic (async)"""
    for attempt in range(max_retries):
        try:
            # Add delay to avoid rate limiting
            await asyncio.sleep(0.5)
            result = await translator.translate(text, src='en', dest=target_lang)
            return result.text
        except Exception as e:
            print(f"Translation attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                await asyncio.sleep(2)  # Wait longer between retries
            else:
                print(f"Failed to translate after {max_retries} attempts: {text[:100]}...")
                return f"[Translation failed: {text[:50]}...]"

async def process_tafsir_file(file_path, target_lang='ur'):
    """Process a tafsir JSON file and add translations for target language (async)"""
    print(f"\nProcessing {file_path} -> {target_lang}")

    # Validate language
    if target_lang not in SUPPORTED_LANGUAGES:
        print(f"Error: Unsupported language '{target_lang}'")
        print(f"Supported languages: {list(SUPPORTED_LANGUAGES.keys())}")
        return False

    lang_code = SUPPORTED_LANGUAGES[target_lang]
    suffix = LANGUAGE_SUFFIXES[target_lang]

    # Load the JSON file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        return False
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {file_path}")
        return False

    # Initialize Google Translator
    translator = Translator()

    # Get verses (top-level numeric keys)
    verses = {k: v for k, v in data.items() if k.isdigit()}
    total_verses = len(verses)

    if total_verses == 0:
        print("No verses found in the file")
        return False

    print(f"Found {total_verses} verses to translate")

    # Track progress
    start_time = time.time()
    translations_done = 0
    translations_skipped = 0

    # Process each verse
    for verse_num, verse_data in verses.items():
        print(f"\nVerse {verse_num}/{total_verses}")

        # Define layers to translate (all 5 layers + layer2short)
        layers = ['layer1', 'layer2', 'layer3', 'layer4', 'layer5', 'layer2short']

        for layer in layers:
            if layer not in verse_data:
                continue

            english_text = verse_data[layer]
            target_key = f"{layer}{suffix}"

            # Skip if translation already exists
            if target_key in verse_data and verse_data[target_key]:
                print(f"  {target_key} already exists, skipping...")
                translations_skipped += 1
                continue

            # Skip empty content
            if not english_text or not english_text.strip():
                continue

            print(f"  Translating {layer}... ", end="", flush=True)

            try:
                translated_text = await translate_text(english_text, translator, lang_code)
                verse_data[target_key] = translated_text
                translations_done += 1
                print("done")
            except Exception as e:
                print(f"failed: {e}")
                verse_data[target_key] = "[Translation failed]"

    # Save the updated file
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        elapsed = time.time() - start_time
        print(f"\n{'='*60}")
        print(f"Successfully updated {file_path}")
        print(f"Translations completed: {translations_done}")
        print(f"Translations skipped (already exist): {translations_skipped}")
        print(f"Time elapsed: {elapsed:.1f} seconds")
        return True
    except Exception as e:
        print(f"Error saving file: {e}")
        return False

def main():
    """Main function"""
    if len(sys.argv) < 3:
        print("Usage: python translate_tafsir.py <tafsir_file.json> <target_language>")
        print("\nSupported languages:")
        for code in sorted(SUPPORTED_LANGUAGES.keys()):
            print(f"  {code}")
        print("\nExamples:")
        print("  python translate_tafsir.py Data/tafsir_1.json ar")
        print("  python translate_tafsir.py Data/tafsir_1.json fr")
        print("  python translate_tafsir.py Data/tafsir_1.json ur")
        sys.exit(1)

    file_path = sys.argv[1]
    target_lang = sys.argv[2].lower()

    # Validate file exists and is JSON
    if not Path(file_path).exists():
        print(f"Error: File {file_path} does not exist")
        sys.exit(1)

    if not file_path.endswith('.json'):
        print("Error: File must be a JSON file")
        sys.exit(1)

    # Validate language
    if target_lang not in SUPPORTED_LANGUAGES:
        print(f"Error: Unsupported language '{target_lang}'")
        print(f"Supported: {list(SUPPORTED_LANGUAGES.keys())}")
        sys.exit(1)

    print("="*60)
    print("Google Translate Tafsir Translation")
    print("="*60)
    print(f"File: {file_path}")
    print(f"Target Language: {target_lang}")
    print("="*60)
    print("\nStarting translation process...")
    print("This may take several minutes depending on the number of verses...")

    success = asyncio.run(process_tafsir_file(file_path, target_lang))

    if success:
        print("\n" + "="*60)
        print("Translation completed successfully!")
        print("="*60)
    else:
        print("\n" + "="*60)
        print("Translation failed. Check errors above.")
        print("="*60)
        sys.exit(1)

if __name__ == "__main__":
    main()