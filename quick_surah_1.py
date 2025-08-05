#!/usr/bin/env python3
"""Quick generation of any Surah with progress updates"""

import json
import sys
import argparse
sys.path.append('.')
from generate_tafsir import TafsirGenerator

def generate_surah_quick(surah_num):
    # Set API key
    api_key = "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"
    
    # Initialize generator with OpenRouter
    generator = TafsirGenerator(api_key, use_openrouter=True)
    
    # Load Quran data
    if not generator.load_quran_data():
        print("❌ Failed to load Quran data")
        return
    
    # Get surah info
    surah_info = next((s for s in generator.quran_data["surahs"] if s["number"] == surah_num), None)
    if not surah_info:
        print(f"❌ Surah {surah_num} not found")
        return
    
    verse_count = len(generator.quran_data["verses"][str(surah_num)])
    
    print(f"🚀 Generating complete tafsir for Surah {surah_num} ({surah_info['englishName']})...")
    print(f"📊 {verse_count} verses × 4 layers = {verse_count * 4} commentaries total")
    print("⏱️  Estimated time: 5-8 minutes\n")
    
    # Generate verse by verse with progress
    surah_data = {}
    
    for verse_num_iter in range(1, verse_count + 1):
        print(f"\n🔄 Processing verse {verse_num_iter}/{verse_count}...")
        verse_data = {}
        
        for layer in range(1, 5):
            print(f"  Layer {layer}... ", end="", flush=True)
            try:
                commentary = generator.generate_layer_commentary(surah_num, verse_num_iter, layer)
                if commentary:
                    verse_data[f"layer{layer}"] = commentary
                    print("✅")
                else:
                    print("❌")
                    verse_data[f"layer{layer}"] = f"Error generating layer {layer} for verse {verse_num_iter}"
            except Exception as e:
                print(f"❌ Error: {e}")
                verse_data[f"layer{layer}"] = f"Error: {e}"
        
        surah_data[str(verse_num_iter)] = verse_data
        progress = (verse_num_iter / verse_count) * 100
        print(f"  ✅ Verse {verse_num_iter} complete ({progress:.1f}% total)")
    
    # Save the data
    try:
        filename = f"tafsir_{surah_num}.json"
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(surah_data, f, ensure_ascii=False, indent=2)
        
        # Also save to iOS app directory
        ios_path = f"Thaqalayn/Thaqalayn/Data/tafsir_{surah_num}.json"
        try:
            with open(ios_path, 'w', encoding='utf-8') as f:
                json.dump(surah_data, f, ensure_ascii=False, indent=2)
            print(f"✅ Saved to iOS app: {ios_path}")
        except:
            print(f"⚠️  Could not save to iOS directory")
        
        print(f"\n🎉 SUCCESS! Complete Surah {surah_num} ({surah_info['englishName']}) generated")
        print(f"📁 Saved as: {filename}")
        print(f"📊 Total verses: {len(surah_data)}")
        print(f"🎯 Ready for iOS app testing!")
        
    except Exception as e:
        print(f"❌ Error saving file: {e}")

def main():
    parser = argparse.ArgumentParser(description='Generate tafsir for a specific Surah')
    parser.add_argument('surah_num', type=int, help='Surah number (1-114)')
    
    args = parser.parse_args()
    
    if args.surah_num < 1 or args.surah_num > 114:
        print("❌ Surah number must be between 1 and 114")
        return
    
    generate_surah_quick(args.surah_num)

if __name__ == "__main__":
    main()