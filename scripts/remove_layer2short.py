#!/usr/bin/env python3
"""
Remove layer2short, layer2short_urdu, layer2short_ar fields from all tafsir files.

Usage:
    python3 remove_layer2short.py
    python3 remove_layer2short.py --dry-run  # Preview changes without modifying files
"""

import json
import sys
from pathlib import Path
from glob import glob


FIELDS_TO_REMOVE = ['layer2short', 'layer2short_urdu', 'layer2short_ar']


def process_tafsir_file(filepath: str, dry_run: bool = False) -> dict:
    """
    Remove specified fields from a tafsir file.

    Returns:
        dict with keys: removed_count, verses_modified
    """
    with open(filepath, 'r', encoding='utf-8') as f:
        data = json.load(f)

    removed_count = 0
    verses_modified = []

    for verse_num, verse_data in data.items():
        if not verse_num.isdigit():
            continue

        if not isinstance(verse_data, dict):
            continue

        fields_removed_in_verse = []
        for field in FIELDS_TO_REMOVE:
            if field in verse_data:
                if not dry_run:
                    del verse_data[field]
                fields_removed_in_verse.append(field)
                removed_count += 1

        if fields_removed_in_verse:
            verses_modified.append(verse_num)

    if not dry_run and verses_modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

    return {
        'removed_count': removed_count,
        'verses_modified': verses_modified
    }


def main():
    dry_run = '--dry-run' in sys.argv

    if dry_run:
        print("DRY RUN MODE - No files will be modified\n")

    # Find all tafsir files
    base_dir = Path(__file__).parent
    data_dir = base_dir / "Thaqalayn" / "Thaqalayn" / "Data"

    if not data_dir.exists():
        print(f"Error: Data directory not found: {data_dir}")
        sys.exit(1)

    tafsir_files = sorted(glob(str(data_dir / "tafsir_*.json")))

    if not tafsir_files:
        print(f"No tafsir files found in {data_dir}")
        sys.exit(1)

    print(f"Processing {len(tafsir_files)} tafsir files...")
    print(f"Fields to remove: {', '.join(FIELDS_TO_REMOVE)}\n")

    total_removed = 0
    files_modified = 0

    for filepath in tafsir_files:
        filename = Path(filepath).name

        try:
            result = process_tafsir_file(filepath, dry_run)

            if result['verses_modified']:
                files_modified += 1
                total_removed += result['removed_count']
                print(f"  {filename}: Removed {result['removed_count']} fields from {len(result['verses_modified'])} verses")
            else:
                print(f"  {filename}: No fields to remove")

        except json.JSONDecodeError as e:
            print(f"  {filename}: ERROR - JSON parse error: {e}")
        except Exception as e:
            print(f"  {filename}: ERROR - {e}")

    print(f"\n{'=' * 50}")
    print("SUMMARY")
    print(f"{'=' * 50}")
    print(f"Files processed: {len(tafsir_files)}")
    print(f"Files modified: {files_modified}")
    print(f"Total fields removed: {total_removed}")

    if dry_run:
        print("\nThis was a dry run. Run without --dry-run to apply changes.")


if __name__ == "__main__":
    main()
