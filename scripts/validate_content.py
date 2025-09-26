#!/usr/bin/env python3
"""
Validation and optimization tools for Thaqalyn data generation
Checks content quality, file sizes, and data integrity
"""

import json
import os
import re
from typing import Dict, List, Tuple, Any
from datetime import datetime

class ContentValidator:
    def __init__(self):
        self.quran_data = None
        self.validation_results = {
            "quran_validation": {},
            "tafsir_validation": {},
            "file_sizes": {},
            "recommendations": []
        }
    
    def load_quran_data(self, filename: str = "quran_data.json") -> bool:
        """Load and validate Quran data"""
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                self.quran_data = json.load(f)
            return True
        except FileNotFoundError:
            print(f"Error: {filename} not found")
            return False
        except json.JSONDecodeError:
            print(f"Error: Invalid JSON in {filename}")
            return False
    
    def validate_quran_structure(self) -> Dict[str, Any]:
        """Validate Quran data structure and completeness"""
        results = {
            "surahs_count": 0,
            "verses_count": 0,
            "missing_surahs": [],
            "missing_verses": [],
            "data_integrity": True
        }
        
        if not self.quran_data:
            results["data_integrity"] = False
            return results
        
        # Check surahs
        surahs = self.quran_data.get("surahs", [])
        results["surahs_count"] = len(surahs)
        
        expected_surahs = set(range(1, 115))
        actual_surahs = set(surah["number"] for surah in surahs)
        results["missing_surahs"] = list(expected_surahs - actual_surahs)
        
        # Check verses
        verses = self.quran_data.get("verses", {})
        total_verses = 0
        
        for surah_num_str, surah_verses in verses.items():
            surah_num = int(surah_num_str)
            total_verses += len(surah_verses)
            
            # Find expected verse count
            surah_info = next((s for s in surahs if s["number"] == surah_num), None)
            if surah_info:
                expected_count = surah_info["versesCount"]
                actual_count = len(surah_verses)
                
                if expected_count != actual_count:
                    results["missing_verses"].append({
                        "surah": surah_num,
                        "expected": expected_count,
                        "actual": actual_count
                    })
        
        results["verses_count"] = total_verses
        
        # Expected total is 6,236 verses
        if total_verses != 6236:
            results["data_integrity"] = False
        
        return results
    
    def validate_tafsir_file(self, filename: str) -> Dict[str, Any]:
        """Validate a single tafsir file"""
        results = {
            "file_exists": False,
            "valid_json": False,
            "verses_count": 0,
            "layers_complete": True,
            "content_quality": {},
            "file_size_kb": 0
        }
        
        if not os.path.exists(filename):
            return results
        
        results["file_exists"] = True
        results["file_size_kb"] = os.path.getsize(filename) / 1024
        
        try:
            with open(filename, 'r', encoding='utf-8') as f:
                tafsir_data = json.load(f)
            results["valid_json"] = True
        except json.JSONDecodeError:
            return results
        
        # Count verses and check layers
        results["verses_count"] = len(tafsir_data)
        
        for verse_num, verse_tafsir in tafsir_data.items():
            # Check all 4 layers exist
            for layer in range(1, 5):
                layer_key = f"layer{layer}"
                if layer_key not in verse_tafsir:
                    results["layers_complete"] = False
                    break
                
                # Basic content quality checks
                content = verse_tafsir[layer_key]
                if len(content) < 100:  # Too short
                    results["content_quality"][f"{verse_num}:{layer_key}"] = "too_short"
                elif len(content) > 2000:  # Too long
                    results["content_quality"][f"{verse_num}:{layer_key}"] = "too_long"
        
        return results
    
    def check_file_sizes(self) -> Dict[str, float]:
        """Check file sizes for all generated files"""
        sizes = {}
        
        # Check quran_data.json
        if os.path.exists("quran_data.json"):
            sizes["quran_data.json"] = os.path.getsize("quran_data.json") / (1024*1024)  # MB
        
        # Check tafsir files
        total_tafsir_size = 0
        tafsir_count = 0
        
        for surah_num in range(1, 115):
            filename = f"tafsir_{surah_num}.json"
            if os.path.exists(filename):
                size = os.path.getsize(filename) / (1024*1024)  # MB
                total_tafsir_size += size
                tafsir_count += 1
        
        sizes["total_tafsir_mb"] = total_tafsir_size
        sizes["tafsir_files_count"] = tafsir_count
        sizes["average_tafsir_file_mb"] = total_tafsir_size / tafsir_count if tafsir_count > 0 else 0
        
        return sizes
    
    def generate_recommendations(self) -> List[str]:
        """Generate optimization recommendations"""
        recommendations = []
        
        sizes = self.check_file_sizes()
        total_size = sizes.get("quran_data.json", 0) + sizes.get("total_tafsir_mb", 0)
        
        if total_size > 100:  # Over 100MB
            recommendations.append("Consider compressing JSON files or using binary format")
        
        if sizes.get("average_tafsir_file_mb", 0) > 2:  # Large tafsir files
            recommendations.append("Tafsir files are large - consider splitting by juz or shorter content")
        
        if sizes.get("tafsir_files_count", 0) < 114:
            missing = 114 - sizes.get("tafsir_files_count", 0)
            recommendations.append(f"Missing {missing} tafsir files - generation incomplete")
        
        return recommendations
    
    def run_full_validation(self) -> Dict[str, Any]:
        """Run complete validation suite"""
        print("=== Thaqalyn Data Validation ===\n")
        
        # Validate Quran data
        print("Validating Quran data structure...")
        if self.load_quran_data():
            self.validation_results["quran_validation"] = self.validate_quran_structure()
            print(f"✓ Quran: {self.validation_results['quran_validation']['surahs_count']} surahs, "
                  f"{self.validation_results['quran_validation']['verses_count']} verses")
        else:
            print("✗ Quran data validation failed")
        
        # Validate tafsir files
        print("\nValidating tafsir files...")
        tafsir_results = {}
        total_verses = 0
        complete_files = 0
        
        for surah_num in range(1, 115):
            filename = f"tafsir_{surah_num}.json"
            result = self.validate_tafsir_file(filename)
            
            if result["file_exists"] and result["valid_json"]:
                total_verses += result["verses_count"]
                if result["layers_complete"]:
                    complete_files += 1
                
                if surah_num <= 3 or surah_num % 20 == 0:  # Show sample results
                    print(f"  Surah {surah_num}: {result['verses_count']} verses, "
                          f"{result['file_size_kb']:.1f}KB")
            
            tafsir_results[filename] = result
        
        self.validation_results["tafsir_validation"] = {
            "total_files": len([r for r in tafsir_results.values() if r["file_exists"]]),
            "complete_files": complete_files,
            "total_verses": total_verses,
            "files_detail": tafsir_results
        }
        
        print(f"✓ Tafsir: {complete_files}/114 complete files, {total_verses} verses with commentary")
        
        # Check file sizes
        print("\nAnalyzing file sizes...")
        self.validation_results["file_sizes"] = self.check_file_sizes()
        
        total_size = (self.validation_results["file_sizes"].get("quran_data.json", 0) + 
                     self.validation_results["file_sizes"].get("total_tafsir_mb", 0))
        
        print(f"✓ Total dataset size: {total_size:.1f} MB")
        
        # Generate recommendations
        self.validation_results["recommendations"] = self.generate_recommendations()
        
        if self.validation_results["recommendations"]:
            print("\n=== Recommendations ===")
            for rec in self.validation_results["recommendations"]:
                print(f"• {rec}")
        
        # Save validation report
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_filename = f"validation_report_{timestamp}.json"
        
        with open(report_filename, 'w', encoding='utf-8') as f:
            json.dump(self.validation_results, f, ensure_ascii=False, indent=2)
        
        print(f"\n✓ Validation report saved: {report_filename}")
        
        return self.validation_results

def optimize_json_files():
    """Optimize JSON files for smaller size"""
    print("\n=== Optimizing JSON Files ===")
    
    total_saved = 0
    
    # Optimize quran_data.json
    if os.path.exists("quran_data.json"):
        original_size = os.path.getsize("quran_data.json")
        
        with open("quran_data.json", 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Save with minimal formatting
        with open("quran_data_optimized.json", 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
        
        optimized_size = os.path.getsize("quran_data_optimized.json")
        saved = (original_size - optimized_size) / (1024*1024)
        total_saved += saved
        
        print(f"✓ Quran data: saved {saved:.2f} MB")
    
    # Optimize tafsir files
    optimized_count = 0
    for surah_num in range(1, 115):
        filename = f"tafsir_{surah_num}.json"
        optimized_filename = f"tafsir_{surah_num}_optimized.json"
        
        if os.path.exists(filename):
            original_size = os.path.getsize(filename)
            
            with open(filename, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            with open(optimized_filename, 'w', encoding='utf-8') as f:
                json.dump(data, f, ensure_ascii=False, separators=(',', ':'))
            
            optimized_size = os.path.getsize(optimized_filename)
            saved = (original_size - optimized_size) / 1024  # KB
            total_saved += saved / 1024  # Convert to MB
            optimized_count += 1
    
    print(f"✓ Optimized {optimized_count} tafsir files")
    print(f"✓ Total space saved: {total_saved:.2f} MB")

def main():
    validator = ContentValidator()
    results = validator.run_full_validation()
    
    # Ask about optimization
    if results["file_sizes"].get("total_tafsir_mb", 0) > 20:  # If larger than 20MB
        optimize = input("\nOptimize JSON files for smaller size? (y/N): ")
        if optimize.lower() == 'y':
            optimize_json_files()

if __name__ == "__main__":
    main()