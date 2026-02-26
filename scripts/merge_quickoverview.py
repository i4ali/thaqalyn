#!/usr/bin/env python3
"""
Merge Quick Overview JSON into Tafsir JSON files.

Usage:
    python3 merge_quickoverview.py <quickoverview_json_path> --surah <number> [--force]
    python3 merge_quickoverview.py <quickoverview_json_path> [--force]  # If filename contains surah number

Example:
    python3 merge_quickoverview.py new_tafsir/quickoverview/quickoverview_2_complete.json --surah 2
    python3 merge_quickoverview.py new_tafsir/quickoverview/quickoverview_2_v1-5.json
    python3 merge_quickoverview.py my_custom_file.json --surah 84 --force

The script will:
1. Use the provided surah number (or parse from filename if matches known pattern)
2. Find the corresponding tafsir_x.json file
3. Merge quickOverview data into the correct verses (skips if already exists)
4. Save the updated tafsir file

Options:
    --surah <number>  Specify the surah number (required if filename doesn't contain it)
    --force           Overwrite existing quickOverview data (default: skip existing)
"""

import json
import sys
import os
import re
from pathlib import Path


def parse_surah_from_filename(filepath: str) -> int | None:
    """
    Try to parse surah number from filename.

    Supported patterns:
    - quickoverview_2_v1-5.json
    - quickoverview_2_complete.json
    - quickoverview_114_v1-6.json
    - Any filename with _<number>_ pattern

    Returns:
        int or None: Surah number if found, None otherwise
    """
    filename = Path(filepath).stem

    # Pattern 1: quickoverview_<surah>_v<start>-<end>
    match = re.search(r'quickoverview_(\d+)_v\d+', filename)
    if match:
        return int(match.group(1))

    # Pattern 2: quickoverview_<surah>_complete
    match = re.search(r'quickoverview_(\d+)_complete', filename)
    if match:
        return int(match.group(1))

    # Pattern 3: Generic _<number>_ in filename
    match = re.search(r'_(\d+)_', filename)
    if match:
        num = int(match.group(1))
        if 1 <= num <= 114:
            return num

    return None


def find_tafsir_file(surah_number: int, base_dir: str = None) -> str:
    """
    Find the tafsir JSON file for a given surah number.

    Args:
        surah_number: The surah number (1-114)
        base_dir: Base directory of the project (auto-detected if not provided)

    Returns:
        str: Path to the tafsir JSON file
    """
    if base_dir is None:
        base_dir = Path(__file__).parent.parent

    tafsir_path = Path(base_dir) / "Thaqalayn" / "Thaqalayn" / "Data" / f"tafsir_{surah_number}.json"

    if not tafsir_path.exists():
        raise FileNotFoundError(
            f"Tafsir file not found: {tafsir_path}\n"
            f"Make sure tafsir_{surah_number}.json exists in the Data directory."
        )

    return str(tafsir_path)


def load_json(filepath: str) -> dict:
    """Load and parse a JSON file."""
    with open(filepath, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json(filepath: str, data: dict) -> None:
    """Save data to a JSON file with proper formatting."""
    with open(filepath, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def get_verse_keys(data: dict) -> list[str]:
    """Extract numeric verse keys from data, filtering out non-numeric keys."""
    return [k for k in data.keys() if k.isdigit()]


def merge_quickoverview(tafsir_data: dict, quickoverview_data: dict, force: bool = False) -> tuple[dict, list[str], list[str]]:
    """
    Merge quickOverview data into tafsir data.

    Args:
        tafsir_data: The existing tafsir data
        quickoverview_data: The quickOverview data to merge
        force: If True, overwrite existing quickOverview data. If False, skip existing.

    Returns:
        tuple: (merged_data, list_of_merged_verses, list_of_skipped_verses)
    """
    merged_verses = []
    skipped_verses = []

    # Get only numeric verse keys
    verse_keys = get_verse_keys(quickoverview_data)

    for verse_num in verse_keys:
        verse_data = quickoverview_data[verse_num]

        if verse_num not in tafsir_data:
            print(f"  Warning: Verse {verse_num} not found in tafsir data, creating new entry")
            tafsir_data[verse_num] = {}

        # Check if verse_data has quickOverview directly or is the quickOverview itself
        if 'quickOverview' in verse_data:
            qo_data = verse_data['quickOverview']
        elif 'concepts' in verse_data:
            # The verse_data IS the quickOverview
            qo_data = verse_data
        else:
            print(f"  Warning: Verse {verse_num} has no quickOverview or concepts, skipping")
            continue

        # Check if quickOverview already exists
        existing_qo = tafsir_data[verse_num].get('quickOverview')

        if existing_qo and not force:
            existing_concepts = len(existing_qo.get('concepts', []))
            print(f"  Verse {verse_num}: SKIPPED (already has {existing_concepts} concepts)")
            skipped_verses.append(verse_num)
            continue

        # Merge the data
        tafsir_data[verse_num]['quickOverview'] = qo_data
        merged_verses.append(verse_num)

        # Count concepts for reporting
        concept_count = len(qo_data.get('concepts', []))
        action = "Replaced" if existing_qo else "Added"
        print(f"  Verse {verse_num}: {action} {concept_count} concepts")

    return tafsir_data, merged_verses, skipped_verses


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 merge_quickoverview.py <quickoverview_json_path> --surah <number> [--force]")
        print("\nExample:")
        print("  python3 merge_quickoverview.py new_tafsir/quickoverview/quickoverview_2_complete.json --surah 2")
        print("  python3 merge_quickoverview.py new_tafsir/quickoverview/quickoverview_2_v1-5.json")
        print("  python3 merge_quickoverview.py my_custom_file.json --surah 84 --force")
        print("\nOptions:")
        print("  --surah <number>  Specify the surah number (required if not in filename)")
        print("  --force           Overwrite existing quickOverview data (default: skip existing)")
        sys.exit(1)

    quickoverview_path = sys.argv[1]
    force = '--force' in sys.argv

    # Parse --surah argument
    surah_number = None
    if '--surah' in sys.argv:
        idx = sys.argv.index('--surah')
        if idx + 1 < len(sys.argv):
            try:
                surah_number = int(sys.argv[idx + 1])
            except ValueError:
                print(f"Error: Invalid surah number: {sys.argv[idx + 1]}")
                sys.exit(1)

    # Validate input file exists
    if not os.path.exists(quickoverview_path):
        print(f"Error: File not found: {quickoverview_path}")
        sys.exit(1)

    print(f"Processing: {quickoverview_path}")

    # Try to get surah number from filename if not provided
    if surah_number is None:
        surah_number = parse_surah_from_filename(quickoverview_path)

    if surah_number is None:
        print("Error: Could not determine surah number from filename.")
        print("Please specify with --surah <number>")
        sys.exit(1)

    if not 1 <= surah_number <= 114:
        print(f"Error: Invalid surah number: {surah_number} (must be 1-114)")
        sys.exit(1)

    print(f"  Surah: {surah_number}")

    # Find the corresponding tafsir file
    try:
        tafsir_path = find_tafsir_file(surah_number)
        print(f"  Tafsir file: {tafsir_path}")
    except FileNotFoundError as e:
        print(f"Error: {e}")
        sys.exit(1)

    # Load both JSON files
    print("\nLoading files...")
    try:
        quickoverview_data = load_json(quickoverview_path)
    except json.JSONDecodeError as e:
        print(f"Error: Failed to parse JSON file: {e}")
        sys.exit(1)

    tafsir_data = load_json(tafsir_path)

    # Report what we found
    verse_keys = get_verse_keys(quickoverview_data)
    if verse_keys:
        verse_nums = sorted([int(k) for k in verse_keys])
        print(f"  Found {len(verse_keys)} verses in input file: {verse_nums[0]}-{verse_nums[-1]}")
    else:
        print("Error: No verse data found in input file")
        sys.exit(1)

    # Merge the data
    print("\nMerging quickOverview data...")
    if force:
        print("  (--force enabled: will overwrite existing data)")
    merged_data, merged_verses, skipped_verses = merge_quickoverview(tafsir_data, quickoverview_data, force)

    # Only save if there were changes
    if merged_verses:
        print(f"\nSaving to: {tafsir_path}")
        save_json(tafsir_path, merged_data)
        print(f"\nSuccess! Merged quickOverview for {len(merged_verses)} verses:")
        print(f"  Merged: {', '.join(sorted(merged_verses, key=int))}")
        print(f"  File updated: {tafsir_path}")
    else:
        print("\nNo changes made (all verses already have quickOverview data)")

    # Report skipped verses
    if skipped_verses:
        print(f"\nSkipped {len(skipped_verses)} verses (already have quickOverview):")
        print(f"  Skipped: {', '.join(sorted(skipped_verses, key=int))}")
        if not force:
            print("  (Use --force to overwrite existing data)")


if __name__ == "__main__":
    main()
