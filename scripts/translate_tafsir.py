#!/usr/bin/env python3
"""
Urdu Translation Script for Tafsir JSON Files
Adds Urdu translations for all 4 tafsir layers using Google Translate
"""

import json
import sys
import asyncio
from googletrans import Translator
from pathlib import Path

async def translate_to_urdu(text, translator, max_retries=3):
    """Translate English text to Urdu with retry logic (async)"""
    for attempt in range(max_retries):
        try:
            # Add delay to avoid rate limiting
            await asyncio.sleep(0.5)
            result = await translator.translate(text, src='en', dest='ur')
            return result.text
        except Exception as e:
            print(f"Translation attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                await asyncio.sleep(2)  # Wait longer between retries
            else:
                print(f"Failed to translate after {max_retries} attempts: {text[:100]}...")
                return f"[Translation failed: {text[:50]}...]"

async def process_tafsir_file(file_path):
    """Process a tafsir JSON file and add Urdu translations (async)"""
    print(f"Processing {file_path}...")
    
    # Load the JSON file
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: File {file_path} not found")
        return False
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {file_path}")
        return False
    
    # Initialize Google Translator
    translator = Translator()
    
    # The JSON structure has verses as top-level keys (not nested under 'verses')
    # Remove 'verses' key and work with the data directly
    verses = {k: v for k, v in data.items() if k.isdigit()}
    total_verses = len(verses)
    
    if total_verses == 0:
        print("No verses found in the file")
        return False
    
    print(f"Found {total_verses} verses to translate")
    
    # Process each verse
    for verse_num, verse_data in verses.items():
        print(f"Translating verse {verse_num}...")
        
        # Translate each layer
        # layers = ['layer1', 'layer2', 'layer3', 'layer4']
        layers = ['layer5']

        
        for layer in layers:
            if layer in verse_data:
                english_text = verse_data[layer]
                urdu_key = f"{layer}_urdu"
                
                # Skip if Urdu translation already exists
                if urdu_key in verse_data:
                    print(f"  {urdu_key} already exists, skipping...")
                    continue
                
                print(f"  Translating {layer}...")
                urdu_translation = await translate_to_urdu(english_text, translator)
                verse_data[urdu_key] = urdu_translation
            else:
                print(f"  Warning: {layer} not found in verse {verse_num}")
    
    # Save the updated file
    try:
        with open(file_path, 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print(f"Successfully updated {file_path}")
        return True
    except Exception as e:
        print(f"Error saving file: {e}")
        return False

def main():
    """Main function"""
    if len(sys.argv) != 2:
        print("Usage: python translate_tafsir.py <tafsir_file.json>")
        print("Example: python translate_tafsir.py Data/tafsir_1.json")
        sys.exit(1)
    
    file_path = sys.argv[1]
    
    # Validate file exists and is JSON
    if not Path(file_path).exists():
        print(f"Error: File {file_path} does not exist")
        sys.exit(1)
    
    if not file_path.endswith('.json'):
        print("Error: File must be a JSON file")
        sys.exit(1)
    
    print("Starting Urdu translation process...")
    print("This may take several minutes depending on the number of verses...")
    
    success = asyncio.run(process_tafsir_file(file_path))
    
    if success:
        print("\n✅ Translation completed successfully!")
        print("The file has been updated with Urdu translations.")
    else:
        print("\n❌ Translation failed. Please check the errors above.")
        sys.exit(1)

if __name__ == "__main__":
    main()