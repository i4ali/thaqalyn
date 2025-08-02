#!/usr/bin/env python3
"""
Generate comprehensive Shia tafsir for all Quran verses using DeepSeek
Creates 4 layers of commentary for each verse
"""

import json
import os
import time
from typing import Dict, List, Any, Optional
from datetime import datetime
import openai

class TafsirGenerator:
    def __init__(self, api_key: str):
        """Initialize with DeepSeek API key"""
        self.client = openai.OpenAI(
            api_key=api_key,
            base_url="https://api.deepseek.com"
        )
        self.quran_data = None
        self.generated_count = 0
        self.total_verses = 0
        
    def load_quran_data(self, filename: str = "quran_data.json"):
        """Load Quran data from JSON file"""
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                self.quran_data = json.load(f)
            
            # Calculate total verses
            self.total_verses = sum(len(surah_verses) for surah_verses in self.quran_data["verses"].values())
            print(f"✓ Loaded Quran data: {len(self.quran_data['surahs'])} surahs, {self.total_verses} verses")
            return True
            
        except FileNotFoundError:
            print(f"Error: {filename} not found. Run fetch_quran_data.py first.")
            return False
        except json.JSONDecodeError:
            print(f"Error: Invalid JSON in {filename}")
            return False
    
    def get_layer_prompts(self) -> Dict[int, str]:
        """Define the 4 specialized prompt templates for each tafsir layer"""
        return {
            1: """You are a Shia Islamic scholar providing foundational commentary on Quranic verses.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: Provide Layer 1 Foundation Commentary (🏛️) following these guidelines:

1. SIMPLE EXPLANATION: Explain the verse in clear, modern language accessible to all Muslims
2. HISTORICAL CONTEXT: Provide Asbab al-Nuzul (reasons for revelation) if relevant
3. KEY ARABIC TERMS: Define important Arabic words and their meanings
4. CONTEMPORARY RELEVANCE: How this verse applies to modern Muslim life

REQUIREMENTS:
- Write 150-250 words
- Use accessible language
- Focus on practical understanding
- Include Arabic terminology with translations
- Be respectful and scholarly

COMMENTARY:""",

            2: """You are a Shia Islamic scholar specializing in classical Shia tafsir traditions.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: Provide Layer 2 Classical Shia Commentary (📚) drawing from these sources:

1. TABATABAI'S AL-MIZAN: Include insights from this comprehensive tafsir
2. TABRISI'S MAJMA AL-BAYAN: Reference classical Shia scholarly interpretations
3. TRADITIONAL CONSENSUS: Present established Shia scholarly views
4. HISTORICAL SHIA PERSPECTIVE: Unique Shia interpretations and approaches

REQUIREMENTS:
- Write 200-300 words
- Reference classical scholars when relevant
- Highlight distinctly Shia interpretations
- Maintain scholarly tone
- Include theological depth

COMMENTARY:""",

            3: """You are a contemporary Shia Islamic scholar providing modern insights on Quranic verses.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: Provide Layer 3 Contemporary Insights (🌍) covering:

1. MODERN SCHOLARS: Insights from contemporary Shia scholars (Makarem Shirazi, Jawadi Amuli, etc.)
2. SCIENTIFIC CORRELATIONS: Modern scientific understanding that relates to the verse
3. SOCIAL JUSTICE THEMES: How the verse addresses contemporary social issues
4. INTERFAITH DIALOGUE: Perspectives that promote understanding with other faiths

REQUIREMENTS:
- Write 200-300 words
- Connect ancient wisdom to modern contexts
- Include scientific or social insights where appropriate
- Maintain balance between tradition and modernity
- Be inclusive while maintaining Shia identity

COMMENTARY:""",

            4: """You are a Shia Islamic scholar specializing in the teachings of the Ahlul Bayt (عليهم السلام).

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: Provide Layer 4 Ahlul Bayt Wisdom (⭐) focusing on:

1. RELEVANT HADITH: Narrations from the 14 Infallibles that illuminate this verse
2. THEOLOGICAL CONCEPTS: Unique Shia concepts (Wilayah, Imamah, Tawhid, etc.) related to the verse
3. SPIRITUAL DIMENSIONS: Mystical and spiritual interpretations from Ahlul Bayt
4. PRACTICAL APPLICATIONS: How this verse guides Shia religious practice and daily life

REQUIREMENTS:
- Write 250-350 words
- Include specific hadith or teachings when available
- Explain unique Shia theological concepts
- Connect to spiritual development and practice
- Maintain reverence for the Ahlul Bayt

COMMENTARY:"""
        }
    
    def generate_layer_commentary(self, surah_num: int, ayah_num: int, layer: int) -> Optional[str]:
        """Generate commentary for a specific verse and layer"""
        if not self.quran_data:
            return None
        
        # Get verse data
        verse_data = self.quran_data["verses"][str(surah_num)][str(ayah_num)]
        surah_data = next(s for s in self.quran_data["surahs"] if s["number"] == surah_num)
        
        # Get prompt template
        prompts = self.get_layer_prompts()
        prompt = prompts[layer].format(
            surah_name=surah_data["englishName"],
            surah_number=surah_num,
            ayah_number=ayah_num,
            arabic_text=verse_data["arabicText"],
            translation=verse_data["translation"]
        )
        
        try:
            response = self.client.chat.completions.create(
                model="deepseek-chat",
                messages=[
                    {"role": "system", "content": "You are an expert Shia Islamic scholar with deep knowledge of Quranic commentary, classical tafsir, and the teachings of the Ahlul Bayt."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=800,
                temperature=0.7
            )
            
            commentary = response.choices[0].message.content.strip()
            self.generated_count += 1
            
            # Progress indicator
            progress = (self.generated_count / (self.total_verses * 4)) * 100
            print(f"Generated {surah_num}:{ayah_num} Layer {layer} ({progress:.1f}% complete)")
            
            return commentary
            
        except Exception as e:
            print(f"Error generating commentary for {surah_num}:{ayah_num} Layer {layer}: {e}")
            return None
        
        # Small delay to avoid rate limiting
        time.sleep(0.1)
    
    def generate_surah_tafsir(self, surah_num: int) -> Dict[str, Dict[str, str]]:
        """Generate all 4 layers of tafsir for a complete surah"""
        print(f"\nGenerating tafsir for Surah {surah_num}...")
        
        surah_tafsir = {}
        surah_verses = self.quran_data["verses"][str(surah_num)]
        
        for ayah_num_str in surah_verses.keys():
            ayah_num = int(ayah_num_str)
            surah_tafsir[ayah_num_str] = {}
            
            # Generate all 4 layers for this verse
            for layer in range(1, 5):
                commentary = self.generate_layer_commentary(surah_num, ayah_num, layer)
                if commentary:
                    surah_tafsir[ayah_num_str][f"layer{layer}"] = commentary
                else:
                    print(f"Failed to generate layer {layer} for {surah_num}:{ayah_num}")
        
        return surah_tafsir
    
    def save_surah_tafsir(self, surah_num: int, tafsir_data: Dict[str, Dict[str, str]]):
        """Save tafsir for a surah to separate JSON file"""
        filename = f"tafsir_{surah_num}.json"
        
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(tafsir_data, f, ensure_ascii=False, indent=2)
            
            # Calculate file size
            file_size = os.path.getsize(filename) / 1024  # KB
            verse_count = len(tafsir_data)
            print(f"✓ Saved {filename} ({verse_count} verses, {file_size:.1f} KB)")
            
        except Exception as e:
            print(f"Error saving {filename}: {e}")
    
    def generate_sample_surahs(self, surah_numbers: List[int] = [1, 36, 67]):
        """Generate tafsir for sample surahs for testing"""
        print(f"=== Generating Sample Tafsir ===")
        print(f"Target surahs: {surah_numbers}")
        
        for surah_num in surah_numbers:
            tafsir_data = self.generate_surah_tafsir(surah_num)
            if tafsir_data:
                self.save_surah_tafsir(surah_num, tafsir_data)
        
        print(f"\n✓ Sample generation complete!")
    
    def generate_complete_tafsir(self):
        """Generate tafsir for all 114 surahs"""
        print("=== Generating Complete Tafsir Dataset ===")
        print(f"This will generate commentary for {self.total_verses} verses across 114 surahs")
        print(f"Estimated time: 20-40 hours")
        print(f"Estimated cost: $50-100\n")
        
        start_time = datetime.now()
        
        for surah_num in range(1, 115):
            tafsir_data = self.generate_surah_tafsir(surah_num)
            if tafsir_data:
                self.save_surah_tafsir(surah_num, tafsir_data)
            
            # Progress report every 10 surahs
            if surah_num % 10 == 0:
                elapsed = datetime.now() - start_time
                print(f"\n--- Progress Report ---")
                print(f"Completed: {surah_num}/114 surahs")
                print(f"Elapsed time: {elapsed}")
                print(f"Generated commentaries: {self.generated_count}")
        
        elapsed_total = datetime.now() - start_time
        print(f"\n=== Generation Complete! ===")
        print(f"Total time: {elapsed_total}")
        print(f"Total commentaries: {self.generated_count}")
        print(f"Ready for iOS app integration!")

def main():
    print("=== Thaqalyn Tafsir Generator ===\n")
    
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv()
    
    # Get API key
    api_key = os.getenv("DEEPSEEK_API_KEY")
    if not api_key:
        api_key = input("Enter your DeepSeek API key: ").strip()
        if not api_key:
            print("Error: API key required")
            return
    
    # Initialize generator
    generator = TafsirGenerator(api_key)
    
    # Load Quran data
    if not generator.load_quran_data():
        return
    
    # Choose generation mode
    print("\nSelect generation mode:")
    print("1. Sample surahs (1, 36, 67) - for testing")
    print("2. Complete dataset (all 114 surahs)")
    
    choice = input("Enter choice (1 or 2): ").strip()
    
    if choice == "1":
        generator.generate_sample_surahs()
    elif choice == "2":
        confirm = input("Generate complete dataset? This will take many hours and cost $50-100. (y/N): ")
        if confirm.lower() == 'y':
            generator.generate_complete_tafsir()
        else:
            print("Generation cancelled.")
    else:
        print("Invalid choice.")

if __name__ == "__main__":
    main()