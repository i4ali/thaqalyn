#!/usr/bin/env python3
"""
Generate concise summaries for all verses in tafsir files.
Each summary captures the essence of all commentary layers in a respectful, scholarly tone.
"""

import json
import os
from pathlib import Path

def extract_key_points(text, max_sentences=2):
    """Extract the most important sentences from a text."""
    if not text:
        return ""

    # Split into sentences
    sentences = [s.strip() for s in text.split('.') if s.strip()]

    # Return first few sentences (usually contain main themes)
    return '. '.join(sentences[:max_sentences]) + '.'

def create_verse_summary(verse_data, surah_num, verse_num):
    """
    Create a concise, scholarly summary synthesizing all commentary layers.
    Captures: core meaning, theological significance, and practical application.
    """
    summary_elements = []

    # Layer 1 (Foundation): Simple explanation and historical context
    if 'layer1' in verse_data:
        layer1 = verse_data['layer1']
        # Extract opening which usually has the core message
        first_para = layer1.split('\n\n')[0] if '\n\n' in layer1 else layer1
        core_message = extract_key_points(first_para, 1)
        if core_message:
            summary_elements.append(core_message)

    # Layer 2 (Classical Shia): Theological depth
    if 'layer2' in verse_data and len(summary_elements) < 2:
        layer2 = verse_data['layer2']
        first_para = layer2.split('\n\n')[0] if '\n\n' in layer2 else layer2
        theological = extract_key_points(first_para, 1)
        if theological and theological != summary_elements[0] if summary_elements else True:
            # Extract theological significance
            if 'Shia' in theological or 'Imam' in theological or 'Tawhid' in theological:
                summary_elements.append(theological)

    # Layer 4 (Ahlul Bayt): Spiritual dimension
    if 'layer4' in verse_data and len(summary_elements) < 3:
        layer4 = verse_data['layer4']
        first_para = layer4.split('\n\n')[0] if '\n\n' in layer4 else layer4
        spiritual = extract_key_points(first_para, 1)
        if spiritual:
            # Extract spiritual significance if not redundant
            if len(summary_elements) < 2 or 'Ahlul Bayt' in spiritual or 'Prophet' in spiritual:
                summary_elements.append(spiritual)

    # Combine elements into a cohesive summary
    if not summary_elements:
        return "Commentary available across multiple dimensions of understanding."

    summary = ' '.join(summary_elements)

    # Ensure summary is concise (3-4 sentences max, ~300-400 chars)
    sentences = [s.strip() for s in summary.split('.') if s.strip()]
    if len(sentences) > 3:
        summary = '. '.join(sentences[:3]) + '.'

    return summary

def process_tafsir_file(file_path, surah_num):
    """Process a single tafsir file and extract summaries for all verses."""
    print(f"Processing Surah {surah_num}...")

    with open(file_path, 'r', encoding='utf-8') as f:
        tafsir_data = json.load(f)

    surah_summaries = {}

    for verse_num, verse_data in tafsir_data.items():
        summary = create_verse_summary(verse_data, surah_num, verse_num)
        surah_summaries[verse_num] = {
            "summary": summary,
            "surah": surah_num,
            "verse": verse_num
        }

    return surah_summaries

def main():
    """Main function to process all tafsir files."""
    data_dir = Path("/home/user/thaqalyn/Thaqalayn/Thaqalayn/Data")
    all_summaries = {}

    # Process all tafsir files (1-114)
    for surah_num in range(1, 115):
        tafsir_file = data_dir / f"tafsir_{surah_num}.json"

        if tafsir_file.exists():
            try:
                surah_summaries = process_tafsir_file(tafsir_file, surah_num)
                all_summaries[str(surah_num)] = surah_summaries
                print(f"✓ Completed Surah {surah_num} ({len(surah_summaries)} verses)")
            except Exception as e:
                print(f"✗ Error processing Surah {surah_num}: {e}")
        else:
            print(f"✗ File not found: {tafsir_file}")

    # Save all summaries to a file
    output_file = data_dir / "verse_summaries.json"
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(all_summaries, f, ensure_ascii=False, indent=2)

    print(f"\n✓ All summaries saved to: {output_file}")
    print(f"Total surahs processed: {len(all_summaries)}")

    # Calculate total verses
    total_verses = sum(len(verses) for verses in all_summaries.values())
    print(f"Total verses summarized: {total_verses}")

if __name__ == "__main__":
    main()
