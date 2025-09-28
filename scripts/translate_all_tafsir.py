#!/usr/bin/env python3
"""
Wrapper Script for Translating All Tafsir Files
Processes all tafsir_x.json files in the Data directory sequentially
"""

import os
import subprocess
import sys
import time
from pathlib import Path
import glob

def run_translation(file_path):
    """Run the translate_tafsir.py script on a single file"""
    try:
        print(f"\n{'='*60}")
        print(f"🔄 Starting translation for: {Path(file_path).name}")
        print(f"{'='*60}")
        
        # Run the translation script
        result = subprocess.run([
            sys.executable, 
            'scripts/translate_tafsir.py', 
            file_path
        ], capture_output=True, text=True, encoding='utf-8')
        
        if result.returncode == 0:
            print(f"✅ SUCCESS: {Path(file_path).name}")
            return True
        else:
            print(f"❌ FAILED: {Path(file_path).name}")
            print(f"Error output: {result.stderr}")
            return False
            
    except Exception as e:
        print(f"❌ EXCEPTION while processing {Path(file_path).name}: {e}")
        return False

def main():
    """Main function to process all tafsir files"""
    
    # Define the data directory path
    # data_dir = "/Users/Imran.Ali/Documents/development/Thaqalayn/Thaqalayn/Thaqalayn/Data"
    data_dir = "/Users/muhammadimranali/Documents/development/thaqalyn/Thaqalayn/Thaqalayn/Data"
    
    # Check if data directory exists
    if not Path(data_dir).exists():
        print(f"❌ Error: Data directory not found: {data_dir}")
        sys.exit(1)
    
    # Find all tafsir JSON files
    pattern = os.path.join(data_dir, "tafsir_*.json")
    tafsir_files = glob.glob(pattern)
    
    if not tafsir_files:
        print(f"❌ No tafsir_*.json files found in {data_dir}")
        sys.exit(1)
    
    # Sort files by surah number
    def extract_surah_number(filepath):
        filename = Path(filepath).stem  # tafsir_1, tafsir_2, etc.
        try:
            return int(filename.split('_')[1])
        except (IndexError, ValueError):
            return 0
    
    tafsir_files.sort(key=extract_surah_number)
    
    print(f"🌟 Found {len(tafsir_files)} tafsir files to translate")
    print(f"📂 Directory: {data_dir}")
    print(f"📋 Files: {[Path(f).name for f in tafsir_files[:5]]}{'...' if len(tafsir_files) > 5 else ''}")
    
    # Track results
    successful = []
    failed = []
    start_time = time.time()
    
    print(f"\n🚀 Starting batch translation at {time.strftime('%Y-%m-%d %H:%M:%S')}")
    print("⚠️  This process may take several hours depending on the number of files...")
    
    # Process each file
    for i, file_path in enumerate(tafsir_files, 1):
        file_name = Path(file_path).name
        
        print(f"\n📊 Progress: {i}/{len(tafsir_files)} ({i/len(tafsir_files)*100:.1f}%)")
        print(f"⏰ Estimated time remaining: {((time.time() - start_time) / i * (len(tafsir_files) - i)) / 60:.1f} minutes")
        
        # Run translation
        if run_translation(file_path):
            successful.append(file_name)
        else:
            failed.append(file_name)
            
        # Small delay between files to be respectful to Google Translate
        if i < len(tafsir_files):  # Don't delay after the last file
            print("⏳ Waiting 30 seconds before next file...")
            time.sleep(30)
    
    # Final report
    end_time = time.time()
    total_time = end_time - start_time
    
    print(f"\n{'='*80}")
    print(f"🎉 BATCH TRANSLATION COMPLETED")
    print(f"{'='*80}")
    print(f"⏱️  Total time: {total_time/60:.1f} minutes ({total_time/3600:.1f} hours)")
    print(f"✅ Successful: {len(successful)}/{len(tafsir_files)}")
    print(f"❌ Failed: {len(failed)}/{len(tafsir_files)}")
    
    if successful:
        print(f"\n✅ Successfully translated files:")
        for file_name in successful:
            print(f"   - {file_name}")
    
    if failed:
        print(f"\n❌ Failed to translate files:")
        for file_name in failed:
            print(f"   - {file_name}")
        print(f"\n💡 You can retry failed files individually using:")
        print(f"   python translate_tafsir.py <file_path>")
    
    # Generate summary file
    summary_file = "translation_summary.txt"
    with open(summary_file, 'w', encoding='utf-8') as f:
        f.write(f"Tafsir Translation Summary\n")
        f.write(f"Generated: {time.strftime('%Y-%m-%d %H:%M:%S')}\n")
        f.write(f"Total files: {len(tafsir_files)}\n")
        f.write(f"Successful: {len(successful)}\n")
        f.write(f"Failed: {len(failed)}\n")
        f.write(f"Total time: {total_time/60:.1f} minutes\n\n")
        
        f.write(f"Successful files:\n")
        for file_name in successful:
            f.write(f"  - {file_name}\n")
        
        f.write(f"\nFailed files:\n")
        for file_name in failed:
            f.write(f"  - {file_name}\n")
    
    print(f"\n📄 Summary saved to: {summary_file}")
    
    if len(failed) == 0:
        print(f"\n🎊 All files translated successfully!")
    else:
        print(f"\n⚠️  {len(failed)} files failed. Check the summary above.")

if __name__ == "__main__":
    main()