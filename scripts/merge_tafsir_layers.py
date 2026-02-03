#!/usr/bin/env python3
"""Merge specific tafsir layers into existing surah files without overwriting other layers.

This script merges only the keys present in the source file into the target file,
preserving all existing layers that aren't in the source.

Example usage:
    python3 merge_tafsir_layers.py 114 new_tafsir/tafsir_114_ur.json

This would merge only the Urdu layers from tafsir_114_ur.json into
Thaqalayn/Thaqalayn/Data/tafsir_114.json, preserving English, Arabic, and quickOverview.
"""

import json
import os
import sys
from pathlib import Path


def merge_tafsir_layers(surah_num: int, source_path: str, dry_run: bool = False):
    """Merge layers from source file into existing tafsir file.

    Args:
        surah_num: The surah number (1-114)
        source_path: Path to the file containing new layers to merge
        dry_run: If True, show what would be changed without writing
    """
    # Paths
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    target_path = project_root / "Thaqalayn" / "Thaqalayn" / "Data" / f"tafsir_{surah_num}.json"
    source_path = Path(source_path)

    # Validate paths
    if not target_path.exists():
        print(f"Error: Target file not found: {target_path}")
        sys.exit(1)

    if not source_path.exists():
        print(f"Error: Source file not found: {source_path}")
        sys.exit(1)

    # Load files
    print(f"Loading target: {target_path}")
    with open(target_path, 'r', encoding='utf-8') as f:
        target_data = json.load(f)

    print(f"Loading source: {source_path}")
    with open(source_path, 'r', encoding='utf-8') as f:
        source_data = json.load(f)

    # Track changes
    verses_updated = 0
    layers_added = 0
    layers_replaced = 0

    # Get all unique layer keys from source to report what we're merging
    all_source_layers = set()
    for verse_key, verse_data in source_data.items():
        if isinstance(verse_data, dict):
            all_source_layers.update(verse_data.keys())

    print(f"\nLayers found in source file: {sorted(all_source_layers)}")
    print(f"Verses in source: {len(source_data)}")
    print(f"Verses in target: {len(target_data)}")

    # Merge each verse
    for verse_key, source_verse in source_data.items():
        if not isinstance(source_verse, dict):
            print(f"  Warning: Verse {verse_key} in source is not a dict, skipping")
            continue

        if verse_key not in target_data:
            print(f"  Warning: Verse {verse_key} not found in target, adding new verse")
            target_data[verse_key] = source_verse
            verses_updated += 1
            layers_added += len(source_verse)
            continue

        target_verse = target_data[verse_key]
        if not isinstance(target_verse, dict):
            print(f"  Warning: Verse {verse_key} in target is not a dict, replacing entirely")
            target_data[verse_key] = source_verse
            verses_updated += 1
            continue

        # Merge layer by layer
        verse_changed = False
        for layer_key, layer_value in source_verse.items():
            if layer_key in target_verse:
                # Check if value is actually different
                if target_verse[layer_key] != layer_value:
                    layers_replaced += 1
                    verse_changed = True
            else:
                layers_added += 1
                verse_changed = True

            # Merge the layer
            target_verse[layer_key] = layer_value

        if verse_changed:
            verses_updated += 1

    # Summary
    print(f"\n--- Merge Summary ---")
    print(f"Verses updated: {verses_updated}")
    print(f"Layers added (new): {layers_added}")
    print(f"Layers replaced (existing): {layers_replaced}")

    if dry_run:
        print(f"\n[DRY RUN] No changes written to disk.")
        print(f"Run without --dry-run to apply changes.")
        return

    # Write merged data
    print(f"\nWriting merged data to: {target_path}")
    with open(target_path, 'w', encoding='utf-8') as f:
        json.dump(target_data, f, ensure_ascii=False, indent=2)

    print("Done!")


def main():
    if len(sys.argv) < 3:
        print("Usage: python3 merge_tafsir_layers.py <surah_number> <source_file> [--dry-run]")
        print("")
        print("Arguments:")
        print("  surah_number  The surah number (1-114)")
        print("  source_file   Path to file containing layers to merge")
        print("  --dry-run     Show what would be changed without writing")
        print("")
        print("Examples:")
        print("  python3 merge_tafsir_layers.py 114 new_tafsir/tafsir_114_ur.json --dry-run")
        print("  python3 merge_tafsir_layers.py 114 new_tafsir/tafsir_114_ur.json")
        sys.exit(1)

    try:
        surah_num = int(sys.argv[1])
    except ValueError:
        print(f"Error: '{sys.argv[1]}' is not a valid surah number")
        sys.exit(1)

    if surah_num < 1 or surah_num > 114:
        print(f"Error: Surah number must be between 1 and 114")
        sys.exit(1)

    source_path = sys.argv[2]
    dry_run = "--dry-run" in sys.argv

    merge_tafsir_layers(surah_num, source_path, dry_run=dry_run)


if __name__ == "__main__":
    main()
