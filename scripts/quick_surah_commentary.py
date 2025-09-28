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
    generator = TafsirGenerator(api_key, use_openrouter=True, max_price=0.002)
    
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

def generate_layer5_quick(surah_num):
    """Generate only Layer 5 (comparative commentary) for an existing surah tafsir"""
    # Set API key
    api_key = "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"
    
    # Initialize generator with OpenRouter
    generator = TafsirGenerator(api_key, use_openrouter=True, max_price=0.002)
    
    # Load Quran data
    if not generator.load_quran_data():
        print("❌ Failed to load Quran data")
        return
    
    # Get surah info
    surah_info = next((s for s in generator.quran_data["surahs"] if s["number"] == surah_num), None)
    if not surah_info:
        print(f"❌ Surah {surah_num} not found")
        return
    
    # Load existing tafsir file
    # filename = f"tafsir_{surah_num}.json"
    filename = f"Thaqalayn/Thaqalayn/Data/tafsir_{surah_num}.json"
    try:
        with open(filename, 'r', encoding='utf-8') as f:
            existing_data = json.load(f)
        print(f"✅ Loaded existing tafsir file: {filename}")
    except FileNotFoundError:
        print(f"❌ Tafsir file not found: {filename}")
        print("💡 Generate the complete 4-layer tafsir first using generate_surah_quick()")
        return
    except Exception as e:
        print(f"❌ Error loading existing tafsir: {e}")
        return
    
    # Validate existing data structure
    verse_count = len(existing_data)
    missing_layers = []
    for verse_key, verse_data in existing_data.items():
        for layer in range(1, 5):
            if f"layer{layer}" not in verse_data:
                missing_layers.append(f"{verse_key}:layer{layer}")
    
    if missing_layers:
        print(f"❌ Incomplete existing tafsir. Missing: {missing_layers[:5]}{'...' if len(missing_layers) > 5 else ''}")
        return
    
    print(f"🚀 Adding Layer 5 (Comparative Commentary) to Surah {surah_num} ({surah_info['englishName']})...")
    print(f"📊 {verse_count} verses to process")
    print("⏱️  Estimated time: 2-3 minutes\n")
    
    # Generate Layer 5 for each verse
    for verse_num_iter in range(1, verse_count + 1):
        verse_key = str(verse_num_iter)
        
        # Skip if Layer 5 already exists
        if f"layer5" in existing_data[verse_key]:
            print(f"⏭️  Verse {verse_num_iter}: Layer 5 already exists, skipping...")
            continue
            
        print(f"🔄 Processing verse {verse_num_iter}/{verse_count} - Layer 5... ", end="", flush=True)
        
        try:
            commentary = generator.generate_layer_commentary(surah_num, verse_num_iter, 5)
            if commentary:
                existing_data[verse_key]["layer5"] = commentary
                print("✅")
            else:
                print("❌")
                existing_data[verse_key]["layer5"] = f"Error generating layer 5 for verse {verse_num_iter}"
        except Exception as e:
            print(f"❌ Error: {e}")
            existing_data[verse_key]["layer5"] = f"Error: {e}"
        
        progress = (verse_num_iter / verse_count) * 100
        print(f"  ✅ Verse {verse_num_iter} complete ({progress:.1f}% total)")
    
    # Save the updated data
    try:
        with open(filename, 'w', encoding='utf-8') as f:
            json.dump(existing_data, f, ensure_ascii=False, indent=2)
        print(f"✅ Updated local file: {filename}")
        
        # Also save to iOS app directory
        ios_path = f"Thaqalayn/Thaqalayn/Data/tafsir_{surah_num}.json"
        try:
            with open(ios_path, 'w', encoding='utf-8') as f:
                json.dump(existing_data, f, ensure_ascii=False, indent=2)
            print(f"✅ Updated iOS app file: {ios_path}")
        except:
            print(f"⚠️  Could not update iOS directory")
        
        print(f"\n🎉 SUCCESS! Layer 5 added to Surah {surah_num} ({surah_info['englishName']})")
        print(f"📊 Total verses updated: {verse_count}")
        print(f"🔍 Now includes 5 layers: Foundation, Classical, Contemporary, Ahlul Bayt, Comparative")
        print(f"🎯 Ready for iOS app testing!")
        
    except Exception as e:
        print(f"❌ Error saving updated file: {e}")

def main():
    parser = argparse.ArgumentParser(description='Generate tafsir for a specific Surah')
    parser.add_argument('surah_num', type=int, help='Surah number (1-114)')
    parser.add_argument('--layer5', action='store_true', help='Generate only Layer 5 (comparative commentary) for existing tafsir')
    
    args = parser.parse_args()
    
    if args.surah_num < 1 or args.surah_num > 114:
        print("❌ Surah number must be between 1 and 114")
        return
    
    if args.layer5:
        generate_layer5_quick(args.surah_num)
    else:
        generate_surah_quick(args.surah_num)

if __name__ == "__main__":
    main()