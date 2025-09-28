#!/usr/bin/env python3
"""
Clean Commentary Prefixes from Tafsir JSON Files
Removes unwanted prefixes like "Commentary on Surah..." from all commentary layers
"""

import json
import re
import glob
import os
from pathlib import Path

def clean_commentary_text(text):
    """Remove unwanted prefixes from commentary text"""
    if not text or not isinstance(text, str):
        return text
    
    # Common prefix patterns to remove
    patterns = [
        # "**COMMENTARY ON SURAH AL-BAQARA 2:106**"
        r'^\*\*COMMENTARY ON SURAH [^*]*\*\*\s*',
        
        # "Commentary on Surah Al-Baqara 2:3"
        r'^Commentary on Surah [^:]*:\d+\s*',
        
        # "COMMENTARY ON SURAH AL-BAQARA 2:106"
        r'^COMMENTARY ON SURAH [^0-9]*\d+:\d+\s*',
        
        # "COMMENTARY:"
        r'^COMMENTARY:\s*',
        
        # "Tafsir of Surah 2:3"
        r'^Tafsir of Surah \d+:\d+\s*',
        
        # Any line starting and ending with ** (markdown-style headers)
        r'^\*\*[^*]+\*\*\s*',
        
        # "VERSE COMMENTARY:" or similar
        r'^VERSE COMMENTARY:\s*',
        
        # "AL-BAQARA 2:106" (surah name with verse reference)
        r'^[A-Z-]+\s+\d+:\d+\s*',
    ]
    
    original_text = text
    
    # Apply each pattern
    for pattern in patterns:
        text = re.sub(pattern, '', text, flags=re.IGNORECASE | re.MULTILINE)
    
    # Clean up extra whitespace and newlines
    text = text.strip()
    
    # If we removed something, show what was cleaned
    if text != original_text:
        removed_part = original_text[:len(original_text) - len(text)].strip()
        if removed_part:
            print(f"    Removed prefix: '{removed_part[:50]}{'...' if len(removed_part) > 50 else ''}'")
    
    return text

def clean_tafsir_file(file_path):
    """Clean prefixes from a single tafsir JSON file"""
    print(f"\nProcessing: {Path(file_path).name}")
    
    # Load the JSON file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except Exception as e:
        print(f"  ❌ Error loading file: {e}")
        return False
    
    changes_made = False
    
    # Process each verse
    for verse_num, verse_data in data.items():
        if not isinstance(verse_data, dict):
            continue
            
        print(f"  Cleaning verse {verse_num}...")
        
        # Check all possible layer keys (including Urdu variants)
        layer_keys = [
            'layer1', 'layer2', 'layer3', 'layer4', 'layer5',
            'layer1_urdu', 'layer2_urdu', 'layer3_urdu', 'layer4_urdu', 'layer5_urdu'
        ]
        
        for layer_key in layer_keys:
            if layer_key in verse_data:
                original_text = verse_data[layer_key]
                cleaned_text = clean_commentary_text(original_text)
                
                if cleaned_text != original_text:
                    verse_data[layer_key] = cleaned_text
                    changes_made = True
    
    # Save the file if changes were made
    if changes_made:
        try:
            with open(file_path, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            print(f"  ✅ File updated with cleaned commentary")
            return True
        except Exception as e:
            print(f"  ❌ Error saving file: {e}")
            return False
    else:
        print(f"  ℹ️  No prefixes found to clean")
        return True

def main():
    """Main function to clean all tafsir files"""
    
    # Define the data directory path
    data_dir = "/Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Thaqalayn/Data"
    
    # Check if data directory exists
    if not Path(data_dir).exists():
        print(f"❌ Error: Data directory not found: {data_dir}")
        return
    
    # Find all tafsir JSON files
    pattern = os.path.join(data_dir, "tafsir_*.json")
    tafsir_files = glob.glob(pattern)
    
    if not tafsir_files:
        print(f"❌ No tafsir_*.json files found in {data_dir}")
        return
    
    # Sort files by surah number
    def extract_surah_number(filepath):
        filename = Path(filepath).stem  # tafsir_1, tafsir_2, etc.
        try:
            return int(filename.split('_')[1])
        except (IndexError, ValueError):
            return 0
    
    tafsir_files.sort(key=extract_surah_number)
    
    print(f"🧹 Starting prefix cleanup for {len(tafsir_files)} tafsir files")
    print(f"📂 Directory: {data_dir}")
    
    # Track results
    successful = 0
    failed = 0
    
    # Process each file
    for i, file_path in enumerate(tafsir_files, 1):
        progress = (i / len(tafsir_files)) * 100
        print(f"\n📊 Progress: {i}/{len(tafsir_files)} ({progress:.1f}%)")
        
        if clean_tafsir_file(file_path):
            successful += 1
        else:
            failed += 1
    
    # Final report
    print(f"\n{'='*60}")
    print(f"🎉 PREFIX CLEANUP COMPLETED")
    print(f"{'='*60}")
    print(f"✅ Successful: {successful}/{len(tafsir_files)}")
    print(f"❌ Failed: {failed}/{len(tafsir_files)}")
    
    if failed == 0:
        print(f"\n🎊 All files cleaned successfully!")
        print(f"📝 Commentary text is now free of unwanted prefixes")
    else:
        print(f"\n⚠️  {failed} files failed. Check the errors above.")

if __name__ == "__main__":
    main()