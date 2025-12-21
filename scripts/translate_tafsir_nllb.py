#!/usr/bin/env python3
"""
Multi-Language Translation Script for Tafsir JSON Files using Meta NLLB
Translates tafsir content from English to Arabic, French, or other languages.
Uses Meta's No Language Left Behind (NLLB) model via Hugging Face Transformers.

Usage:
    python translate_tafsir_nllb.py <tafsir_file.json> <target_language>

Examples:
    python translate_tafsir_nllb.py Data/tafsir_1.json ar    # Translate to Arabic
    python translate_tafsir_nllb.py Data/tafsir_1.json fr    # Translate to French

Supported Languages:
    ar - Arabic (arb_Arab)
    fr - French (fra_Latn)
    ur - Urdu (urd_Arab)
    tr - Turkish (tur_Latn)
    id - Indonesian (ind_Latn)
    fa - Persian/Farsi (pes_Arab)
    ms - Malay (zsm_Latn)
    bn - Bengali (ben_Beng)
"""

import json
import sys
import time
from pathlib import Path
from typing import Optional

# Language code mappings for NLLB-200 model
NLLB_LANGUAGE_CODES = {
    "en": "eng_Latn",      # English (source)
    "ar": "arb_Arab",      # Arabic
    "fr": "fra_Latn",      # French
    "ur": "urd_Arab",      # Urdu
    "tr": "tur_Latn",      # Turkish
    "id": "ind_Latn",      # Indonesian
    "fa": "pes_Arab",      # Persian/Farsi
    "ms": "zsm_Latn",      # Malay
    "bn": "ben_Beng",      # Bengali
    "hi": "hin_Deva",      # Hindi
    "es": "spa_Latn",      # Spanish
    "de": "deu_Latn",      # German
    "ru": "rus_Cyrl",      # Russian
    "zh": "zho_Hans",      # Chinese (Simplified)
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
    "zh": "_zh",
}


class NLLBTranslator:
    """Translator using Meta NLLB-200 model"""

    def __init__(self, model_name: str = "facebook/nllb-200-3.3B"):
        """
        Initialize the NLLB translator.

        Args:
            model_name: HuggingFace model name. Options:
                - facebook/nllb-200-3.3B (default, ~13GB, best quality)
                - facebook/nllb-200-distilled-1.3B (~5GB, good quality)
                - facebook/nllb-200-distilled-600M (~2.4GB, fastest, lower quality)
        """
        print(f"Loading NLLB model: {model_name}")
        print("This may take a few minutes on first run (downloading model)...")

        from transformers import AutoTokenizer, AutoModelForSeq2SeqLM
        import torch

        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"Using device: {self.device}")

        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModelForSeq2SeqLM.from_pretrained(model_name).to(self.device)

        print("Model loaded successfully!")

    def translate(self, text: str, source_lang: str = "eng_Latn", target_lang: str = "arb_Arab", max_length: int = 1024) -> str:
        """
        Translate text from source language to target language.

        Args:
            text: Text to translate
            source_lang: Source language code (NLLB format, e.g., eng_Latn)
            target_lang: Target language code (NLLB format, e.g., arb_Arab)
            max_length: Maximum output length

        Returns:
            Translated text
        """
        if not text or not text.strip():
            return text

        # Set the source language
        self.tokenizer.src_lang = source_lang

        # Tokenize input
        inputs = self.tokenizer(text, return_tensors="pt", truncation=True, max_length=max_length).to(self.device)

        # Get the target language token ID
        forced_bos_token_id = self.tokenizer.convert_tokens_to_ids(target_lang)

        # Generate translation
        translated_tokens = self.model.generate(
            **inputs,
            forced_bos_token_id=forced_bos_token_id,
            max_length=max_length,
            num_beams=5,
            early_stopping=True
        )

        # Decode and return
        translated_text = self.tokenizer.batch_decode(translated_tokens, skip_special_tokens=True)[0]
        return translated_text


def translate_tafsir_file(file_path: str, target_lang: str, translator: NLLBTranslator) -> bool:
    """
    Process a tafsir JSON file and add translations for the target language.

    Args:
        file_path: Path to the tafsir JSON file
        target_lang: Target language code (e.g., 'ar', 'fr')
        translator: NLLBTranslator instance

    Returns:
        True if successful, False otherwise
    """
    print(f"\nProcessing {file_path} -> {target_lang}")

    # Validate language
    if target_lang not in NLLB_LANGUAGE_CODES:
        print(f"Error: Unsupported language '{target_lang}'")
        print(f"Supported languages: {list(NLLB_LANGUAGE_CODES.keys())}")
        return False

    target_nllb_code = NLLB_LANGUAGE_CODES[target_lang]
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

        # Define layers to translate
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
                translated_text = translator.translate(
                    english_text,
                    source_lang="eng_Latn",
                    target_lang=target_nllb_code
                )
                verse_data[target_key] = translated_text
                translations_done += 1
                print("done")
            except Exception as e:
                print(f"failed: {e}")
                verse_data[target_key] = f"[Translation failed]"

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
        print("Usage: python translate_tafsir_nllb.py <tafsir_file.json> <target_language>")
        print("\nSupported languages:")
        for code, nllb_code in NLLB_LANGUAGE_CODES.items():
            if code != "en":
                print(f"  {code} - {nllb_code}")
        print("\nExamples:")
        print("  python translate_tafsir_nllb.py Data/tafsir_1.json ar")
        print("  python translate_tafsir_nllb.py Data/tafsir_1.json fr")
        sys.exit(1)

    file_path = sys.argv[1]
    target_lang = sys.argv[2].lower()

    # Validate file exists
    if not Path(file_path).exists():
        print(f"Error: File {file_path} does not exist")
        sys.exit(1)

    if not file_path.endswith('.json'):
        print("Error: File must be a JSON file")
        sys.exit(1)

    # Validate language
    if target_lang not in NLLB_LANGUAGE_CODES:
        print(f"Error: Unsupported language '{target_lang}'")
        print(f"Supported: {[k for k in NLLB_LANGUAGE_CODES.keys() if k != 'en']}")
        sys.exit(1)

    print("="*60)
    print("NLLB Tafsir Translation")
    print("="*60)
    print(f"File: {file_path}")
    print(f"Target Language: {target_lang} ({NLLB_LANGUAGE_CODES[target_lang]})")
    print("="*60)

    # Initialize translator
    translator = NLLBTranslator()

    # Run translation
    success = translate_tafsir_file(file_path, target_lang, translator)

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
