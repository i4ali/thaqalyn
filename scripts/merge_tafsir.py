#!/usr/bin/env python3
"""Merge tafsir fragment files into complete surah files."""

import json
import os
import re
from pathlib import Path

def merge_surah_tafsir(surah_num: int, new_tafsir_dir: str = "new_tafsir"):
    """Merge all fragment files for a surah into a single file."""

    # Find all fragment files for this surah
    pattern = re.compile(rf"tafsir_{surah_num}_v(\d+)-(\d+)\.json")
    fragments = []

    for filename in os.listdir(new_tafsir_dir):
        match = pattern.match(filename)
        if match:
            start_verse = int(match.group(1))
            end_verse = int(match.group(2))
            filepath = os.path.join(new_tafsir_dir, filename)
            fragments.append((start_verse, end_verse, filepath))

    if not fragments:
        print(f"No fragments found for Surah {surah_num}")
        return

    # Sort by start verse
    fragments.sort(key=lambda x: x[0])

    print(f"\nSurah {surah_num}: Found {len(fragments)} fragments")
    for start, end, path in fragments:
        print(f"  - v{start}-{end}: {os.path.basename(path)}")

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
                merged_verses[verse_key] = verse_data

        except Exception as e:
            print(f"  Error reading {filepath}: {e}")
            continue

    # Sort verses numerically
    sorted_verses = dict(sorted(merged_verses.items(), key=lambda x: int(x[0])))

    # Create output structure
    output = {"verses": sorted_verses}

    # Write merged file
    output_path = os.path.join(new_tafsir_dir, f"tafsir_{surah_num}.json")
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output, f, ensure_ascii=False, indent=2)

    print(f"  Merged {len(sorted_verses)} verses -> {output_path}")

    # Verify verse range
    verse_nums = sorted([int(k) for k in sorted_verses.keys()])
    if verse_nums:
        print(f"  Verse range: {min(verse_nums)} to {max(verse_nums)}")

        # Check for gaps
        expected = set(range(min(verse_nums), max(verse_nums) + 1))
        actual = set(verse_nums)
        missing = expected - actual
        if missing:
            print(f"  Warning: Missing verses: {sorted(missing)}")

    return output_path

def main():
    # Merge Surahs 16, 17, 18
    for surah_num in [16, 17, 18]:
        merge_surah_tafsir(surah_num)

    print("\nDone!")

if __name__ == "__main__":
    main()
