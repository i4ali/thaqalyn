#!/usr/bin/env python3
"""Merge Urdu tafsir layers into existing surah files.

Only merges Urdu keys (layer1_urdu–layer5_urdu), leaving English, Arabic,
and quickOverview untouched.

Source file is automatically resolved to new_tafsir/tafsir_<N>_ur.json.

Usage:
    python3 scripts/merge_urdu_layers.py <surah_number> [--dry-run]

Example:
    python3 scripts/merge_urdu_layers.py 114
    python3 scripts/merge_urdu_layers.py 114 --dry-run
"""

import json
import sys
from pathlib import Path

URDU_KEYS = {"layer1_urdu", "layer2_urdu", "layer3_urdu", "layer4_urdu", "layer5_urdu"}


def merge_urdu_layers(surah_num: int, dry_run: bool = False):
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    target_path = project_root / "Thaqalayn" / "Thaqalayn" / "Data" / f"tafsir_{surah_num}.json"
    source_path = project_root / "new_tafsir" / f"tafsir_{surah_num}_ur.json"

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

    # Identify which Urdu keys are present in the source
    found_keys = set()
    for verse_data in source_data.values():
        if isinstance(verse_data, dict):
            found_keys.update(URDU_KEYS & verse_data.keys())

    if not found_keys:
        print(f"Error: No Urdu keys ({sorted(URDU_KEYS)}) found in source file.")
        sys.exit(1)

    print(f"\nUrdu keys found in source: {sorted(found_keys)}")
    print(f"Verses in source: {len(source_data)}")
    print(f"Verses in target: {len(target_data)}")

    verses_updated = 0
    layers_added = 0
    layers_replaced = 0

    for verse_key, source_verse in source_data.items():
        if not isinstance(source_verse, dict):
            print(f"  Warning: Verse {verse_key} in source is not a dict, skipping")
            continue

        urdu_layers = {k: v for k, v in source_verse.items() if k in URDU_KEYS}
        if not urdu_layers:
            continue

        if verse_key not in target_data:
            print(f"  Warning: Verse {verse_key} not found in target, adding new entry")
            target_data[verse_key] = urdu_layers
            verses_updated += 1
            layers_added += len(urdu_layers)
            continue

        target_verse = target_data[verse_key]
        if not isinstance(target_verse, dict):
            print(f"  Warning: Verse {verse_key} in target is not a dict, replacing")
            target_data[verse_key] = urdu_layers
            verses_updated += 1
            continue

        verse_changed = False
        for key, value in urdu_layers.items():
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

    print(f"\n--- Merge Summary (Urdu) ---")
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
        print("Usage: python3 merge_urdu_layers.py <surah_number> [--dry-run]")
        print("")
        print("Examples:")
        print("  python3 scripts/merge_urdu_layers.py 114")
        print("  python3 scripts/merge_urdu_layers.py 114 --dry-run")
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

    merge_urdu_layers(surah_num, dry_run=dry_run)


if __name__ == "__main__":
    main()
