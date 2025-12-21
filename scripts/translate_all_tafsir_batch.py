#!/usr/bin/env python3
"""
Batch Translation Script for All Tafsir Files
Translates tafsir_1.json through tafsir_114.json to a target language

Usage:
    python translate_all_tafsir_batch.py <language> [start_surah] [end_surah]

Examples:
    python translate_all_tafsir_batch.py ar              # Translate all 114 surahs to Arabic
    python translate_all_tafsir_batch.py fr 1 10         # Translate surahs 1-10 to French
    python translate_all_tafsir_batch.py ur 50 114       # Translate surahs 50-114 to Urdu
"""

import sys
import subprocess
import time
from pathlib import Path
from datetime import datetime, timedelta

# Supported languages
SUPPORTED_LANGUAGES = [
    "ar", "fr", "ur", "tr", "id", "fa", "ms", "bn",
    "hi", "es", "de", "ru", "zh-cn"
]

def format_time(seconds):
    """Format seconds into HH:MM:SS"""
    return str(timedelta(seconds=int(seconds)))

def main():
    """Main function"""
    # Parse arguments
    if len(sys.argv) < 2:
        print("Usage: python translate_all_tafsir_batch.py <language> [start_surah] [end_surah]")
        print("\nSupported languages:")
        for lang in SUPPORTED_LANGUAGES:
            print(f"  {lang}")
        print("\nExamples:")
        print("  python translate_all_tafsir_batch.py ar              # All 114 surahs to Arabic")
        print("  python translate_all_tafsir_batch.py fr 1 10         # Surahs 1-10 to French")
        print("  python translate_all_tafsir_batch.py ur 50 114       # Surahs 50-114 to Urdu")
        sys.exit(1)

    language = sys.argv[1].lower()
    start_surah = int(sys.argv[2]) if len(sys.argv) > 2 else 1
    end_surah = int(sys.argv[3]) if len(sys.argv) > 3 else 114

    # Validate language
    if language not in SUPPORTED_LANGUAGES:
        print(f"Error: Unsupported language '{language}'")
        print(f"Supported: {', '.join(SUPPORTED_LANGUAGES)}")
        sys.exit(1)

    # Validate surah range
    if start_surah < 1 or start_surah > 114:
        print("Error: Start surah must be between 1 and 114")
        sys.exit(1)

    if end_surah < 1 or end_surah > 114:
        print("Error: End surah must be between 1 and 114")
        sys.exit(1)

    if start_surah > end_surah:
        print("Error: Start surah cannot be greater than end surah")
        sys.exit(1)

    # Paths
    data_dir = Path("Thaqalayn/Thaqalayn/Data")
    script_path = Path("scripts/translate_tafsir.py")

    # Check paths exist
    if not data_dir.exists():
        print(f"Error: Data directory not found: {data_dir}")
        sys.exit(1)

    if not script_path.exists():
        print(f"Error: Translation script not found: {script_path}")
        sys.exit(1)

    # Statistics
    total_surahs = end_surah - start_surah + 1
    completed = 0
    failed = 0
    skipped = 0
    start_time = time.time()

    # Create log file
    log_file = f"translation_log_{language}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"

    print("=" * 60)
    print("Batch Tafsir Translation")
    print("=" * 60)
    print(f"Language: {language}")
    print(f"Surah range: {start_surah} - {end_surah}")
    print(f"Total surahs: {total_surahs}")
    print(f"Log file: {log_file}")
    print("=" * 60)
    print()

    # Loop through surahs
    for surah in range(start_surah, end_surah + 1):
        tafsir_file = data_dir / f"tafsir_{surah}.json"
        progress = surah - start_surah + 1

        print(f"[{progress}/{total_surahs}] Processing Surah {surah}...")

        # Check if file exists
        if not tafsir_file.exists():
            print(f"  ⚠️  File not found: {tafsir_file} (skipping)")
            with open(log_file, 'a') as f:
                f.write(f"SKIPPED: Surah {surah} - File not found\n")
            skipped += 1
            continue

        # Run translation
        try:
            result = subprocess.run(
                [sys.executable, str(script_path), str(tafsir_file), language],
                capture_output=True,
                text=True,
                timeout=600  # 10 minute timeout per surah
            )

            # Log output
            with open(log_file, 'a') as f:
                f.write(f"\n{'='*60}\n")
                f.write(f"Surah {surah}\n")
                f.write(f"{'='*60}\n")
                f.write(result.stdout)
                if result.stderr:
                    f.write(f"\nSTDERR:\n{result.stderr}\n")

            if result.returncode == 0:
                print(f"  ✅ Completed")
                with open(log_file, 'a') as f:
                    f.write(f"SUCCESS: Surah {surah}\n")
                completed += 1
            else:
                print(f"  ❌ Failed (check log for details)")
                with open(log_file, 'a') as f:
                    f.write(f"FAILED: Surah {surah}\n")
                failed += 1

        except subprocess.TimeoutExpired:
            print(f"  ❌ Timeout (exceeded 10 minutes)")
            with open(log_file, 'a') as f:
                f.write(f"TIMEOUT: Surah {surah}\n")
            failed += 1
        except Exception as e:
            print(f"  ❌ Error: {e}")
            with open(log_file, 'a') as f:
                f.write(f"ERROR: Surah {surah} - {e}\n")
            failed += 1

        # Show progress
        elapsed = time.time() - start_time
        avg_time = elapsed / progress
        remaining_surahs = end_surah - surah
        eta = avg_time * remaining_surahs

        print(f"  Progress: {completed} completed, {failed} failed, {skipped} skipped")
        print(f"  Elapsed: {format_time(elapsed)} | ETA: {format_time(eta)}")
        print()

    # Final summary
    total_time = time.time() - start_time

    print("=" * 60)
    print("Batch Translation Complete!")
    print("=" * 60)
    print(f"Language: {language}")
    print(f"Surah range: {start_surah} - {end_surah}")
    print()
    print("Results:")
    print(f"  ✅ Completed: {completed}")
    print(f"  ❌ Failed: {failed}")
    print(f"  ⚠️  Skipped: {skipped}")
    print(f"  📊 Total: {total_surahs}")
    print()
    print(f"Time: {format_time(total_time)}")
    print(f"Log file: {log_file}")
    print("=" * 60)

    # Exit with error if any failed
    if failed > 0:
        sys.exit(1)

if __name__ == "__main__":
    main()
