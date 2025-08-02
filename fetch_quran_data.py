#!/usr/bin/env python3
"""
Fetch complete Quran data from Al-Quran Cloud API
Generates quran_data.json with all surahs and verses
"""

import requests
import json
import time
from typing import Dict, List, Any

class QuranDataFetcher:
    def __init__(self):
        self.base_url = "http://api.alquran.cloud/v1"
        self.quran_data = {
            "surahs": [],
            "verses": {}
        }
    
    def fetch_surah_metadata(self) -> List[Dict[str, Any]]:
        """Fetch metadata for all 114 surahs"""
        print("Fetching surah metadata...")
        
        try:
            response = requests.get(f"{self.base_url}/surah")
            response.raise_for_status()
            data = response.json()
            
            surahs = []
            for surah in data['data']:
                surahs.append({
                    "number": surah['number'],
                    "name": surah['name'],
                    "englishName": surah['englishName'],
                    "englishNameTranslation": surah['englishNameTranslation'],
                    "arabicName": surah['name'],
                    "versesCount": surah['numberOfAyahs'],
                    "revelationType": surah['revelationType']
                })
            
            print(f"✓ Fetched metadata for {len(surahs)} surahs")
            return surahs
            
        except requests.RequestException as e:
            print(f"Error fetching surah metadata: {e}")
            return []
    
    def fetch_complete_quran(self) -> Dict[str, Dict[str, Any]]:
        """Fetch Arabic text and English translation for entire Quran"""
        print("Fetching complete Quran with Arabic text and translation...")
        
        verses = {}
        
        try:
            # Fetch Arabic text (Uthmani script)
            print("  → Fetching Arabic text...")
            arabic_response = requests.get(f"{self.base_url}/quran/quran-uthmani")
            arabic_response.raise_for_status()
            arabic_data = arabic_response.json()
            
            # Fetch English translation (Sahih International)
            print("  → Fetching English translation...")
            translation_response = requests.get(f"{self.base_url}/quran/en.sahih")
            translation_response.raise_for_status()
            translation_data = translation_response.json()
            
            # Debug: Check response structure
            print(f"  → Arabic data keys: {list(arabic_data['data'].keys())}")
            print(f"  → Translation data keys: {list(translation_data['data'].keys())}")
            
            # Get surahs from the response
            arabic_surahs = arabic_data['data']['surahs']
            translation_surahs = translation_data['data']['surahs']
                
            # Process surahs and their ayahs
            for arabic_surah, translation_surah in zip(arabic_surahs, translation_surahs):
                surah_num = str(arabic_surah['number'])
                verses[surah_num] = {}
                
                # Process each ayah in the surah
                for arabic_ayah, english_ayah in zip(arabic_surah['ayahs'], translation_surah['ayahs']):
                    ayah_num = str(arabic_ayah['numberInSurah'])
                    
                    verses[surah_num][ayah_num] = {
                        "arabicText": arabic_ayah['text'],
                        "translation": english_ayah['text'],
                        "juz": arabic_ayah['juz'],
                        "manzil": arabic_ayah['manzil'],
                        "page": arabic_ayah['page'],
                        "ruku": arabic_ayah['ruku'],
                        "hizbQuarter": arabic_ayah['hizbQuarter'],
                        "sajda": arabic_ayah.get('sajda', False)
                    }
            
            # Count total verses
            total_verses = sum(len(surah_verses) for surah_verses in verses.values())
            print(f"✓ Fetched {total_verses} verses from {len(verses)} surahs")
            return verses
            
        except requests.RequestException as e:
            print(f"Error fetching Quran data: {e}")
            return {}
    
    def save_data(self, filename: str = "quran_data.json"):
        """Save the complete Quran data to JSON file"""
        print(f"Saving data to {filename}...")
        
        try:
            with open(filename, 'w', encoding='utf-8') as f:
                json.dump(self.quran_data, f, ensure_ascii=False, indent=2)
            
            # Calculate file size
            import os
            file_size = os.path.getsize(filename) / (1024 * 1024)  # MB
            print(f"✓ Saved {filename} ({file_size:.2f} MB)")
            
        except Exception as e:
            print(f"Error saving data: {e}")
    
    def fetch_all_data(self):
        """Main method to fetch all Quran data"""
        print("=== Thaqalyn Quran Data Fetcher ===\n")
        
        # Fetch surah metadata
        self.quran_data["surahs"] = self.fetch_surah_metadata()
        
        if not self.quran_data["surahs"]:
            print("Failed to fetch surah metadata. Aborting.")
            return
        
        # Fetch all verses
        self.quran_data["verses"] = self.fetch_complete_quran()
        
        if not self.quran_data["verses"]:
            print("Failed to fetch verse data. Aborting.")
            return
        
        # Save to file
        self.save_data()
        
        # Print summary
        total_verses = sum(len(surah_verses) for surah_verses in self.quran_data["verses"].values())
        print(f"\n=== Summary ===")
        print(f"Surahs: {len(self.quran_data['surahs'])}")
        print(f"Verses: {total_verses}")
        print(f"Data ready for tafsir generation!")

if __name__ == "__main__":
    fetcher = QuranDataFetcher()
    fetcher.fetch_all_data()