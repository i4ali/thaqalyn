#!/usr/bin/env python3
"""Merge Arabic tafsir layers into existing surah files.

Only merges Arabic keys (layer1_ar–layer5_ar), leaving English, Urdu,
and quickOverview untouched.

Source file is automatically resolved to new_tafsir/tafsir_<N>_ar.json.

Usage:
    python3 scripts/merge_arabic_layers.py <surah_number> [--dry-run]

Example:
    python3 scripts/merge_arabic_layers.py 114
    python3 scripts/merge_arabic_layers.py 114 --dry-run
"""

import json
import sys
from pathlib import Path

ARABIC_KEYS = {"layer1_ar", "layer2_ar", "layer3_ar", "layer4_ar", "layer5_ar"}


def merge_arabic_layers(surah_num: int, dry_run: bool = False):
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    target_path = project_root / "Thaqalayn" / "Thaqalayn" / "Data" / f"tafsir_{surah_num}.json"
    source_path = project_root / "new_tafsir" / f"tafsir_{surah_num}_ar.json"

    if not target_path.exists():
        print(f"Error: Target file not found: {target_path}")
        sys.exit(1)

    if not source_path.exists():
        print(f"Error: Source file not found: {source_path}")
        sys.exit(1)

    print(f"Loading target: {target_path}")
    with open(target_path, 'r', encoding='utf-8') as f:
        target_data = json.load(f)

    print(f"Loading source: {source_path}")
    with open(source_path, 'r', encoding='utf-8') as f:
        source_data = json.load(f)

    # Identify which Arabic keys are present in the source
    found_keys = set()
    for verse_data in source_data.values():
        if isinstance(verse_data, dict):
            found_keys.update(ARABIC_KEYS & verse_data.keys())

    if not found_keys:
        print(f"Error: No Arabic keys ({sorted(ARABIC_KEYS)}) found in source file.")
        sys.exit(1)

    print(f"\nArabic keys found in source: {sorted(found_keys)}")
    print(f"Verses in source: {len(source_data)}")
    print(f"Verses in target: {len(target_data)}")

    verses_updated = 0
    layers_added = 0
    layers_replaced = 0

    for verse_key, source_verse in source_data.items():
        if not isinstance(source_verse, dict):
            print(f"  Warning: Verse {verse_key} in source is not a dict, skipping")
            continue

        arabic_layers = {k: v for k, v in source_verse.items() if k in ARABIC_KEYS}
        if not arabic_layers:
            continue

        if verse_key not in target_data:
            print(f"  Warning: Verse {verse_key} not found in target, adding new entry")
            target_data[verse_key] = arabic_layers
            verses_updated += 1
            layers_added += len(arabic_layers)
            continue

        target_verse = target_data[verse_key]
        if not isinstance(target_verse, dict):
            print(f"  Warning: Verse {verse_key} in target is not a dict, replacing")
            target_data[verse_key] = arabic_layers
            verses_updated += 1
            continue

        verse_changed = False
        for key, value in arabic_layers.items():
            if key in target_verse:
                if target_verse[key] != value:
                    layers_replaced += 1
                    verse_changed = True
            else:
                layers_added += 1
                verse_changed = True
            target_verse[key] = value

        if verse_changed:
            verses_updated += 1

    print(f"\n--- Merge Summary (Arabic) ---")
    print(f"Verses updated:          {verses_updated}")
    print(f"Layers added (new):      {layers_added}")
    print(f"Layers replaced:         {layers_replaced}")

    if dry_run:
        print(f"\n[DRY RUN] No changes written to disk.")
        return

    print(f"\nWriting merged data to: {target_path}")
    with open(target_path, 'w', encoding='utf-8') as f:
        json.dump(target_data, f, ensure_ascii=False, indent=2)

    print("Done!")


def main():
    if len(sys.argv) < 2:
        print("Usage: python3 merge_arabic_layers.py <surah_number> [--dry-run]")
        print("")
        print("Examples:")
        print("  python3 scripts/merge_arabic_layers.py 114")
        print("  python3 scripts/merge_arabic_layers.py 114 --dry-run")
        sys.exit(1)

    try:
        surah_num = int(sys.argv[1])
    except ValueError:
        print(f"Error: '{sys.argv[1]}' is not a valid surah number")
        sys.exit(1)

    if surah_num < 1 or surah_num > 114:
        print(f"Error: Surah number must be between 1 and 114")
        sys.exit(1)

    dry_run = "--dry-run" in sys.argv

    merge_arabic_layers(surah_num, dry_run=dry_run)


if __name__ == "__main__":
    main()
