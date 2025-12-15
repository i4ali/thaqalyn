#!/usr/bin/env python3
"""
Batch Translation Script for All Tafsir Files using Meta NLLB
Translates all 114 surah tafsir files to a target language.

Usage:
    python translate_all_tafsir_nllb.py <target_language> [--start <surah>] [--end <surah>]

Examples:
    python translate_all_tafsir_nllb.py ar              # Translate all surahs to Arabic
    python translate_all_tafsir_nllb.py fr              # Translate all surahs to French
    python translate_all_tafsir_nllb.py ar --start 1 --end 10   # Only surahs 1-10
"""

import os
import sys
import time
import argparse
import json
from pathlib import Path

# Add parent directory to path for imports
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from translate_tafsir_nllb import (
    NLLBTranslator,
    translate_tafsir_file,
    NLLB_LANGUAGE_CODES,
    LANGUAGE_SUFFIXES
)


def find_data_directory() -> str:
    """Find the Data directory containing tafsir files."""
    # Try common locations
    possible_paths = [
        Path(__file__).parent.parent / "Thaqalayn" / "Thaqalayn" / "Data",
        Path.cwd() / "Thaqalayn" / "Thaqalayn" / "Data",
        Path.cwd() / "Data",
    ]

    for path in possible_paths:
        if path.exists() and (path / "tafsir_1.json").exists():
            return str(path)

    return None


def main():
    parser = argparse.ArgumentParser(
        description="Batch translate all tafsir files using NLLB",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
    python translate_all_tafsir_nllb.py ar              # All surahs to Arabic
    python translate_all_tafsir_nllb.py fr              # All surahs to French
    python translate_all_tafsir_nllb.py ar --start 50   # Surahs 50-114 to Arabic
    python translate_all_tafsir_nllb.py fr --end 10     # Surahs 1-10 to French

Supported languages:
    ar - Arabic        fr - French        ur - Urdu
    tr - Turkish       id - Indonesian    fa - Persian
    ms - Malay         bn - Bengali       hi - Hindi
    es - Spanish       de - German        ru - Russian
        """
    )

    parser.add_argument("language", help="Target language code (ar, fr, ur, etc.)")
    parser.add_argument("--start", type=int, default=1, help="Start surah number (default: 1)")
    parser.add_argument("--end", type=int, default=114, help="End surah number (default: 114)")
    parser.add_argument("--data-dir", help="Path to Data directory containing tafsir files")
    parser.add_argument("--model", default="facebook/nllb-200-3.3B",
                        help="NLLB model to use (default: facebook/nllb-200-3.3B for best quality)")

    args = parser.parse_args()

    # Validate language
    target_lang = args.language.lower()
    if target_lang not in NLLB_LANGUAGE_CODES:
        print(f"Error: Unsupported language '{target_lang}'")
        print(f"Supported: {[k for k in NLLB_LANGUAGE_CODES.keys() if k != 'en']}")
        sys.exit(1)

    # Find data directory
    data_dir = args.data_dir or find_data_directory()
    if not data_dir:
        print("Error: Could not find Data directory with tafsir files")
        print("Please specify --data-dir or run from the project root")
        sys.exit(1)

    print("="*70)
    print("NLLB Batch Tafsir Translation")
    print("="*70)
    print(f"Data Directory: {data_dir}")
    print(f"Target Language: {target_lang} ({NLLB_LANGUAGE_CODES[target_lang]})")
    print(f"Surah Range: {args.start} to {args.end}")
    print(f"Model: {args.model}")
    print("="*70)

    # Get list of tafsir files
    tafsir_files = []
    for surah_num in range(args.start, args.end + 1):
        file_path = os.path.join(data_dir, f"tafsir_{surah_num}.json")
        if os.path.exists(file_path):
            tafsir_files.append((surah_num, file_path))
        else:
            print(f"Warning: {file_path} not found, skipping")

    if not tafsir_files:
        print("Error: No tafsir files found to process")
        sys.exit(1)

    print(f"\nFound {len(tafsir_files)} tafsir files to translate")
    print("="*70)

    # Initialize translator
    print("\nInitializing NLLB translator...")
    translator = NLLBTranslator(model_name=args.model)

    # Track results
    successful = []
    failed = []
    start_time = time.time()

    # Process each file
    for i, (surah_num, file_path) in enumerate(tafsir_files, 1):
        print(f"\n{'='*70}")
        print(f"Progress: {i}/{len(tafsir_files)} ({i/len(tafsir_files)*100:.1f}%)")
        print(f"Surah {surah_num}: {Path(file_path).name}")

        elapsed = time.time() - start_time
        if i > 1:
            avg_per_file = elapsed / (i - 1)
            remaining = avg_per_file * (len(tafsir_files) - i + 1)
            print(f"Estimated time remaining: {remaining/60:.1f} minutes")

        try:
            success = translate_tafsir_file(file_path, target_lang, translator)
            if success:
                successful.append(surah_num)
            else:
                failed.append(surah_num)
        except Exception as e:
            print(f"Error processing surah {surah_num}: {e}")
            failed.append(surah_num)

    # Final report
    total_time = time.time() - start_time

    print("\n" + "="*70)
    print("BATCH TRANSLATION COMPLETE")
    print("="*70)
    print(f"Total time: {total_time/60:.1f} minutes ({total_time/3600:.2f} hours)")
    print(f"Successful: {len(successful)}/{len(tafsir_files)}")
    print(f"Failed: {len(failed)}/{len(tafsir_files)}")

    if failed:
        print(f"\nFailed surahs: {failed}")
        print("\nYou can retry failed surahs individually:")
        for surah_num in failed:
            print(f"  python translate_tafsir_nllb.py Data/tafsir_{surah_num}.json {target_lang}")

    # Save summary
    summary = {
        "timestamp": time.strftime('%Y-%m-%d %H:%M:%S'),
        "target_language": target_lang,
        "model": args.model,
        "total_files": len(tafsir_files),
        "successful": len(successful),
        "failed": len(failed),
        "failed_surahs": failed,
        "total_time_minutes": total_time / 60
    }

    summary_file = f"translation_summary_{target_lang}_{time.strftime('%Y%m%d_%H%M%S')}.json"
    with open(summary_file, 'w') as f:
        json.dump(summary, f, indent=2)

    print(f"\nSummary saved to: {summary_file}")

    if len(failed) == 0:
        print(f"\nAll {len(successful)} surahs translated successfully to {target_lang}!")
    else:
        sys.exit(1)


if __name__ == "__main__":
    main()
