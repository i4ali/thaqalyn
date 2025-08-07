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
    def __init__(self, api_key: str, use_openrouter: bool = False, max_price: float = None):
        """Initialize with API key - can use DeepSeek directly or through OpenRouter"""
        if use_openrouter:
            self.client = openai.OpenAI(
                api_key=api_key,
                base_url="https://openrouter.ai/api/v1"
            )
            self.model = "deepseek/deepseek-r1"  # DeepSeek R1 reasoning model on OpenRouter
            self.max_price = max_price if max_price is not None else 0.005
        else:
            self.client = openai.OpenAI(
                api_key=api_key,
                base_url="https://api.deepseek.com"
            )
            self.model = "deepseek-reasoner"
            self.max_price = None
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

TASK: 
IMPORTANT: First, perform a web search to gather authentic foundational Shia tafsir, historical context, and explanations of key terms for this verse. 

Based on your search, provide foundational commentary that explains this verse in clear, accessible language for all Muslims. Focus on basic understanding, historical background, key Arabic terms, and practical modern applications.

Write a flowing commentary of 150-250 words that covers:
- Clear explanation of the verse's meaning
- Historical context or circumstances of revelation
- Important Arabic words and their significance  
- How this verse applies to contemporary Muslim life

FORMATTING REQUIREMENTS:
- Write in flowing paragraphs, not sections
- Use clean, natural prose
- No bullet points, numbers, or markdown formatting
- Include Arabic terms naturally within sentences
- Use simple English spellings for all Arabic names and terms (Ali not ʿAlī, Tabatabai not Ṭabāṭabāʾī, Bismillah not Bismillāh)
- Make it accessible and practical

COMMENTARY:""",

            2: """You are a classical Shia Islamic scholar drawing from traditional sources like Al-Mizan and Majma al-Bayan.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: 
IMPORTANT: First, perform a web search to retrieve commentary on this verse from classical Shia sources like Tabatabai's Al-Mizan, Tabrisi's Majma al-Bayan, and other traditional tafsirs.

Based on your search, provide classical Shia scholarly interpretation. Focus on theological depth and established scholarly consensus.

Write a scholarly commentary of 150-250 words that includes:
- Classical Shia interpretations and scholarly insights
- References to established commentators when relevant
- Theological concepts unique to Shia understanding
- Connection to broader Islamic jurisprudence and doctrine

FORMATTING REQUIREMENTS:
- Write in scholarly prose appropriate for serious students
- Reference classical sources naturally within text
- No bullet points, numbers, or markdown formatting
- Use simple English spellings for all Arabic names and terms (Tabatabai not Ṭabāṭabāʾī, Tabrisi not Ṭabrisī, Jafar not Jaʿfar)
- Maintain academic tone while being readable

COMMENTARY:""",

            3: """You are a contemporary Shia Islamic scholar engaging with modern insights and current scholarship.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: 
IMPORTANT: First, perform a web search for contemporary Shia scholarly interpretations of this verse, including relevant scientific, social, or philosophical discussions from modern sources.

Based on your search, provide contemporary interpretation that bridges classical wisdom with modern understanding. Draw from current Shia scholars, scientific insights where relevant, and address contemporary social issues and challenges.

Write a modern commentary of 150-250 words that explores:
- How contemporary scholars interpret this verse
- Scientific, social, or philosophical insights that illuminate the text
- Relevance to current global issues and challenges
- Interfaith and multicultural perspectives where appropriate

FORMATTING REQUIREMENTS:
- Write in contemporary, engaging prose
- Include modern scholarly references naturally
- Address current issues and applications
- Use simple English spellings for all Arabic names and terms (Bismillah not Bismillāh, Rahman not Raḥmān)
- No bullet points, numbers, or markdown formatting

COMMENTARY:""",

            4: """You are a specialist in the teachings of the Ahlul Bayt (عليهم السلام) - the 14 Infallibles.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: 
IMPORTANT: First, perform a web search to find hadith from the Ahlul Bayt (peace be upon them) and related Shia commentary that explains this verse's deeper, spiritual meaning.

Based on your search, provide commentary focused specifically on the wisdom and teachings of the Ahlul Bayt. Include relevant hadith, spiritual insights, and unique Shia theological concepts like Wilayah and Imamah when applicable.

Write a spiritually-focused commentary of 150-250 words that emphasizes:
- Specific teachings from the Prophet, Imams, or Lady Fatima (peace be upon them)
- Relevant hadith that illuminate this verse's deeper meaning
- Unique Shia spiritual and theological concepts
- Practical guidance for spiritual development and religious practice

FORMATTING REQUIREMENTS:
- Write with reverence and spiritual depth
- Include hadith and quotes naturally within text
- Focus on practical spiritual guidance
- Use simple English spellings for all Arabic names and terms (Ali not ʿAlī, Fatimah not Fāṭimah, Muhammad not Muḥammad)
- No bullet points, numbers, or markdown formatting

COMMENTARY:"""
        }
    
        """Define the 4 specialized prompt templates for each tafsir layer"""
        return {
            1: """You are a Shia Islamic scholar providing foundational commentary on Quranic verses.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: Provide foundational commentary that explains this verse in clear, accessible language for all Muslims. Focus on basic understanding, historical background, key Arabic terms, and practical modern applications.

Write a flowing commentary of 150-250 words that covers:
- Clear explanation of the verse's meaning
- Historical context or circumstances of revelation
- Important Arabic words and their significance  
- How this verse applies to contemporary Muslim life

FORMATTING REQUIREMENTS:
- Write in flowing paragraphs, not sections
- Use clean, natural prose
- No bullet points, numbers, or markdown formatting
- Include Arabic terms naturally within sentences
- Use simple English spellings for all Arabic names and terms (Ali not ʿAlī, Tabatabai not Ṭabāṭabāʾī, Bismillah not Bismillāh)
- Make it accessible and practical

COMMENTARY:""",

            2: """You are a classical Shia Islamic scholar drawing from traditional sources like Al-Mizan and Majma al-Bayan.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: Provide classical Shia scholarly interpretation drawing from established sources like Tabatabai's Al-Mizan, Tabrisi's Majma al-Bayan, and other traditional Shia commentaries. Focus on theological depth and established scholarly consensus.

Write a scholarly commentary of 200-300 words that includes:
- Classical Shia interpretations and scholarly insights
- References to established commentators when relevant
- Theological concepts unique to Shia understanding
- Connection to broader Islamic jurisprudence and doctrine

FORMATTING REQUIREMENTS:
- Write in scholarly prose appropriate for serious students
- Reference classical sources naturally within text
- No bullet points, numbers, or markdown formatting
- Use simple English spellings for all Arabic names and terms (Tabatabai not Ṭabāṭabāʾī, Tabrisi not Ṭabrisī, Jafar not Jaʿfar)
- Maintain academic tone while being readable

COMMENTARY:""",

            3: """You are a contemporary Shia Islamic scholar engaging with modern insights and current scholarship.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: Provide contemporary interpretation that bridges classical wisdom with modern understanding. Draw from current Shia scholars, scientific insights where relevant, and address contemporary social issues and challenges.

Write a modern commentary of 200-300 words that explores:
- How contemporary scholars interpret this verse
- Scientific, social, or philosophical insights that illuminate the text
- Relevance to current global issues and challenges
- Interfaith and multicultural perspectives where appropriate

FORMATTING REQUIREMENTS:
- Write in contemporary, engaging prose
- Include modern scholarly references naturally
- Address current issues and applications
- Use simple English spellings for all Arabic names and terms (Bismillah not Bismillāh, Rahman not Raḥmān)
- No bullet points, numbers, or markdown formatting

COMMENTARY:""",

            4: """You are a specialist in the teachings of the Ahlul Bayt (عليهم السلام) - the 14 Infallibles.

VERSE CONTEXT:
Surah: {surah_name} (Surah {surah_number})
Verse: {ayah_number}
Arabic: {arabic_text}
Translation: {translation}

TASK: Provide commentary focused specifically on the wisdom and teachings of the Ahlul Bayt. Include relevant hadith, spiritual insights, and unique Shia theological concepts like Wilayah and Imamah when applicable.

Write a spiritually-focused commentary of 250-350 words that emphasizes:
- Specific teachings from the Prophet, Imams, or Lady Fatima (peace be upon them)
- Relevant hadith that illuminate this verse's deeper meaning
- Unique Shia spiritual and theological concepts
- Practical guidance for spiritual development and religious practice

FORMATTING REQUIREMENTS:
- Write with reverence and spiritual depth
- Include hadith and quotes naturally within text
- Focus on practical spiritual guidance
- Use simple English spellings for all Arabic names and terms (Ali not ʿAlī, Fatimah not Fāṭimah, Muhammad not Muḥammad)
- No bullet points, numbers, or markdown formatting

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
                model=self.model,
                messages=[
                    {"role": "system", "content": "You are an expert Shia Islamic scholar with deep knowledge of Quranic commentary, classical tafsir, and the teachings of the Ahlul Bayt."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=1500,
                temperature=0.7
            )
            
            commentary = response.choices[0].message.content.strip()
            
            # Clean up incomplete sentences
            commentary = self.clean_incomplete_sentences(commentary)
            
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
    
    def clean_incomplete_sentences(self, text: str) -> str:
        """Remove incomplete sentences that end abruptly due to token limits"""
        if not text:
            return text
        
        # Split into sentences
        sentences = text.split('.')
        
        # If the last "sentence" is very short and doesn't end with punctuation,
        # it's likely incomplete - remove it
        if len(sentences) > 1:
            last_part = sentences[-1].strip()
            
            # Check if last part is incomplete:
            # - Very short (less than 10 characters)
            # - Doesn't end with proper punctuation
            # - Contains incomplete phrases
            incomplete_indicators = [
                len(last_part) < 10,
                not last_part.endswith(('.', '!', '?', '"', ')', ']')),
                last_part.endswith(('at', 'the', 'of', 'in', 'and', 'or', 'but', 'with', 'by', 'for', 'to', 'from', 'on')),
                ' at' in last_part and len(last_part) < 30,  # Common incomplete ending
            ]
            
            if any(incomplete_indicators):
                # Remove the incomplete sentence
                sentences = sentences[:-1]
                print(f"🧹 Removed incomplete sentence: '{last_part}'")
        
        # Rejoin sentences
        cleaned_text = '.'.join(sentences)
        
        # Ensure it ends with a period if it doesn't already end with punctuation
        if cleaned_text and not cleaned_text.endswith(('.', '!', '?', '"', ')', ']')):
            cleaned_text += '.'
        
        return cleaned_text.strip()
    
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
    
    # Choose API provider
    print("Select API provider:")
    print("1. DeepSeek Direct")
    print("2. OpenRouter (DeepSeek)")
    
    provider_choice = input("Enter choice (1 or 2): ").strip()
    
    if provider_choice == "2":
        # OpenRouter
        use_openrouter = True
        api_key = os.getenv("OPENROUTER_API_KEY")
        if not api_key:
            api_key = input("Enter your OpenRouter API key: ").strip()
        provider_name = "OpenRouter"
    else:
        # DeepSeek Direct
        use_openrouter = False
        api_key = os.getenv("DEEPSEEK_API_KEY")
        if not api_key:
            api_key = input("Enter your DeepSeek API key: ").strip()
        provider_name = "DeepSeek Direct"
    
    if not api_key:
        print("Error: API key required")
        return
    
    print(f"Using {provider_name}")
    
    # Initialize generator
    generator = TafsirGenerator(api_key, use_openrouter)
    
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