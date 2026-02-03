#!/usr/bin/env python3
"""Merge Urdu tafsir fragment files into a single surah file.

Usage:
    python3 scripts/merge_urdu_tafsir.py <surah_number>

Example:
    python3 scripts/merge_urdu_tafsir.py 22

This merges all files matching tafsir_22_v*_ur.json into tafsir_22_ur.json
"""

import json
import os
import re
import sys
from pathlib import Path


def merge_urdu_tafsir(surah_num: int, tafsir_dir: str = "new_tafsir"):
    """Merge all Urdu fragment files for a surah into a single file."""

    tafsir_dir = Path(tafsir_dir)

    if not tafsir_dir.exists():
        print(f"Error: Directory not found: {tafsir_dir}")
        sys.exit(1)

    # Find all Urdu fragment files for this surah
    pattern = re.compile(rf"tafsir_{surah_num}_v(\d+)-(\d+)_ur\.json")
    fragments = []

    for filename in os.listdir(tafsir_dir):
        match = pattern.match(filename)
        if match:
            start_verse = int(match.group(1))
            end_verse = int(match.group(2))
            filepath = tafsir_dir / filename
            fragments.append((start_verse, end_verse, filepath))

    if not fragments:
        print(f"No Urdu fragments found for Surah {surah_num}")
        print(f"Expected pattern: tafsir_{surah_num}_v<start>-<end>_ur.json")
        sys.exit(1)

    # Sort by start verse
    fragments.sort(key=lambda x: x[0])

    print(f"Surah {surah_num}: Found {len(fragments)} Urdu fragments")
    for start, end, path in fragments:
        print(f"  - v{start}-{end}: {path.name}")

    # Merge all verses
    merged_verses = {}

    for start, end, filepath in fragments:
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                data = json.load(f)

            # Handle different data structures
            if isinstance(data, dict):
                if 'verses' in data:
                    verses = data['verses']
                else:
                    verses = data
            else:
                print(f"  Warning: Unexpected data format in {filepath}")
                continue

            # Merge verses
            for verse_key, verse_data in verses.items():
                if verse_key in merged_verses:
                    print(f"  Warning: Verse {verse_key} already exists, overwriting with {filepath.name}")
                merged_verses[verse_key] = verse_data

        except json.JSONDecodeError as e:
            print(f"  Error: Invalid JSON in {filepath}: {e}")
            sys.exit(1)
        except Exception as e:
            print(f"  Error reading {filepath}: {e}")
            sys.exit(1)

    # Sort verses numerically
    sorted_verses = dict(sorted(merged_verses.items(), key=lambda x: int(x[0])))

    # Write merged file
    output_path = tafsir_dir / f"tafsir_{surah_num}_ur.json"
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(sorted_verses, f, ensure_ascii=False, indent=2)

    print(f"\nMerged {len(sorted_verses)} verses -> {output_path}")

    # Verify verse range
    verse_nums = sorted([int(k) for k in sorted_verses.keys()])
    if verse_nums:
        print(f"Verse range: {min(verse_nums)} to {max(verse_nums)}")

        # Check for gaps
        expected = set(range(min(verse_nums), max(verse_nums) + 1))
        actual = set(verse_nums)
        missing = expected - actual
        if missing:
            print(f"Warning: Missing verses: {sorted(missing)}")

    return output_path


def main():
    if len(sys.argv) != 2:
        print("Usage: python3 scripts/merge_urdu_tafsir.py <surah_number>")
        print("Example: python3 scripts/merge_urdu_tafsir.py 22")
        sys.exit(1)

    try:
        surah_num = int(sys.argv[1])
    except ValueError:
        print(f"Error: '{sys.argv[1]}' is not a valid surah number")
        sys.exit(1)

    if surah_num < 1 or surah_num > 114:
        print(f"Error: Surah number must be between 1 and 114")
        sys.exit(1)

    result = merge_urdu_tafsir(surah_num)
    if result:
        print("\nDone!")


if __name__ == "__main__":
    main()
