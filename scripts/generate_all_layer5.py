#!/usr/bin/env python3
"""
Generate Layer 5 (Comparative Commentary) for all 114 surahs
This script calls generate_layer5_quick function directly for each surah
"""

import time
from datetime import datetime
from quick_surah_commentary import generate_layer5_quick

def generate_layer5_for_all():
    """Generate Layer 5 for all 114 surahs"""
    print("🚀 Starting Layer 5 generation for all 114 surahs")
    print("📊 This will add comparative Shia/Sunni commentary to existing tafsir files")
    print("⏱️  Estimated total time: 3-4 hours\n")
    
    start_time = datetime.now()
    success_count = 0
    failed_surahs = []
    
    for surah_num in range(8, 115):
        print(f"\n{'='*60}")
        print(f"🔄 Processing Surah {surah_num}/114")
        print(f"⏰ Started at: {datetime.now().strftime('%H:%M:%S')}")
        
        try:
            # Call generate_layer5_quick function directly
            generate_layer5_quick(surah_num)
            success_count += 1
            print(f"✅ Surah {surah_num} completed successfully")
                
        except Exception as e:
            failed_surahs.append(surah_num)
            print(f"❌ Surah {surah_num} failed with exception: {e}")
        
        # Progress update
        completed_count = surah_num - 7  # Since we start from surah 8
        total_count = 114 - 7  # Total surahs to process (8-114)
        progress = (completed_count / total_count) * 100
        elapsed = datetime.now() - start_time
        if completed_count > 0:
            estimated_total = elapsed * (total_count / completed_count)
            remaining = estimated_total - elapsed
        else:
            remaining = "Unknown"
        
        print(f"📈 Progress: {progress:.1f}% ({success_count} successful, {len(failed_surahs)} failed)")
        print(f"⏱️  Elapsed: {elapsed}")
        print(f"🕒 Estimated remaining: {remaining}")
        
        # Small delay between surahs to avoid rate limiting
        time.sleep(2)
    
    # Final report
    total_time = datetime.now() - start_time
    print(f"\n{'='*60}")
    print(f"🎉 LAYER 5 GENERATION COMPLETE!")
    print(f"📊 Total time: {total_time}")
    total_processed = 114 - 7  # Surahs 8-114
    print(f"✅ Successful: {success_count}/{total_processed} surahs")
    print(f"❌ Failed: {len(failed_surahs)}/{total_processed} surahs")
    
    if failed_surahs:
        print(f"\n❌ Failed surahs: {failed_surahs}")
        print("💡 You can retry these individually using:")
        for surah in failed_surahs:
            print(f"   python3 quick_surah_commentary.py {surah} --layer5")
    else:
        print("\n🎯 All surahs completed successfully!")
        print("🔍 All tafsir files now include 5 layers:")
        print("   1. Foundation Layer")
        print("   2. Classical Shia Layer") 
        print("   3. Contemporary Layer")
        print("   4. Ahlul Bayt Layer")
        print("   5. Comparative Layer (NEW)")
        print("\n📱 Ready for iOS app integration!")

def main():
    """Main function with confirmation prompt"""
    total_surahs = 114 - 7  # Surahs 8-114
    print(f"⚠️  WARNING: This will process {total_surahs} surahs (8-114)!")
    print("📊 Estimated time: 3-4 hours")
    print("💰 Estimated cost: $20-40")
    
    confirm = input("\nDo you want to proceed? (y/N): ").strip().lower()
    
    if confirm == 'y':
        generate_layer5_for_all()
    else:
        print("❌ Operation cancelled")

if __name__ == "__main__":
    main()