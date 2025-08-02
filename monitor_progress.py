#!/usr/bin/env python3
"""
Monitor tafsir generation progress
"""

import os
import json
import time
from datetime import datetime

def check_progress():
    """Check current generation progress"""
    
    generated_files = []
    total_verses = 0
    total_size_mb = 0
    
    print("=== Thaqalyn Generation Progress ===")
    print(f"Check time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Count generated files
    for surah_num in range(1, 115):
        filename = f"tafsir_{surah_num}.json"
        if os.path.exists(filename):
            file_size = os.path.getsize(filename) / (1024*1024)  # MB
            total_size_mb += file_size
            
            # Count verses in this file
            try:
                with open(filename, 'r', encoding='utf-8') as f:
                    data = json.load(f)
                    verses_count = len(data)
                    total_verses += verses_count
                    
                    # Check if complete (all layers present)
                    complete_verses = 0
                    for verse_data in data.values():
                        if all(f"layer{i}" in verse_data for i in range(1, 5)):
                            complete_verses += 1
                    
                    generated_files.append({
                        "surah": surah_num,
                        "verses": verses_count,
                        "complete": complete_verses,
                        "size_mb": file_size
                    })
            except:
                pass
    
    # Calculate progress
    total_surahs = 114
    total_expected_verses = 6236
    
    progress_surahs = (len(generated_files) / total_surahs) * 100
    progress_verses = (total_verses / total_expected_verses) * 100
    
    print(f"\n📊 Progress Summary:")
    print(f"Surahs: {len(generated_files)}/114 ({progress_surahs:.1f}%)")
    print(f"Verses: {total_verses}/6,236 ({progress_verses:.1f}%)")
    print(f"Total size: {total_size_mb:.1f} MB")
    
    if generated_files:
        print(f"\n📋 Latest files:")
        for file_info in generated_files[-5:]:  # Show last 5
            print(f"  Surah {file_info['surah']:3d}: {file_info['complete']:3d}/{file_info['verses']} verses complete ({file_info['size_mb']:.2f} MB)")
    
    # Estimate completion
    if len(generated_files) > 1:
        avg_size_per_surah = total_size_mb / len(generated_files)
        estimated_total_size = avg_size_per_surah * 114
        print(f"\n🔮 Estimates:")
        print(f"Est. total size: {estimated_total_size:.1f} MB")
        
        if progress_surahs > 0:
            remaining_surahs = 114 - len(generated_files)
            print(f"Remaining surahs: {remaining_surahs}")
    
    print(f"\n{'='*50}")
    
    return len(generated_files), total_verses

if __name__ == "__main__":
    check_progress()