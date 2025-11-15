#!/usr/bin/env python3
"""
Script to add layer2short field to all verses in tafsir JSON files.
The layer2short field contains the first paragraph of the layer2 commentary.
"""

import json
import os
from pathlib import Path

def extract_first_paragraph(text):
    """Extract the first paragraph from text (everything before first \\n\\n)"""
    if not text:
        return ""

    # Split by double newline to get paragraphs
    paragraphs = text.split('\n\n')

    # Return the first paragraph
    return paragraphs[0] if paragraphs else text

def process_tafsir_file(file_path):
    """Process a single tafsir JSON file and add layer2short to all verses"""
    print(f"Processing {file_path}...")

    try:
        # Read the JSON file
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)

        modified_count = 0

        # Process each verse in the file
        for verse_num, verse_data in data.items():
            if isinstance(verse_data, dict) and 'layer2' in verse_data:
                # Extract first paragraph from layer2
                first_paragraph = extract_first_paragraph(verse_data['layer2'])

                # Add layer2short field
                verse_data['layer2short'] = first_paragraph
                modified_count += 1

        # Write the updated data back to the file
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)

        print(f"  ✓ Modified {modified_count} verses")
        return True

    except Exception as e:
        print(f"  ✗ Error processing {file_path}: {e}")
        return False

def main():
    """Main function to process all tafsir files"""
    # Path to the Data directory
    data_dir = Path("/home/user/thaqalyn/Thaqalayn/Thaqalayn/Data")

    if not data_dir.exists():
        print(f"Error: Data directory not found at {data_dir}")
        return

    # Find all tafsir_*.json files
    tafsir_files = sorted(data_dir.glob("tafsir_*.json"))

    if not tafsir_files:
        print("No tafsir files found!")
        return

    print(f"Found {len(tafsir_files)} tafsir files to process\n")

    success_count = 0
    fail_count = 0

    # Process each file
    for file_path in tafsir_files:
        if process_tafsir_file(file_path):
            success_count += 1
        else:
            fail_count += 1

    print(f"\n{'='*60}")
    print(f"Processing complete!")
    print(f"  ✓ Successfully processed: {success_count} files")
    if fail_count > 0:
        print(f"  ✗ Failed: {fail_count} files")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
