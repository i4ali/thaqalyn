#!/usr/bin/env python3
"""
Generate concise summaries for all verses in tafsir files.
Each summary captures the essence of all commentary layers in a respectful, scholarly tone.
"""

import json
import os
from pathlib import Path

def extract_paragraphs(text):
    """Split text into paragraphs."""
    if not text:
        return []
    return [p.strip() for p in text.split('\n\n') if p.strip()]

def extract_sentences(text, max_sentences=None):
    """Extract sentences from text."""
    if not text:
        return []
    sentences = [s.strip() + '.' for s in text.split('.') if s.strip() and len(s.strip()) > 10]
    if max_sentences:
        return sentences[:max_sentences]
    return sentences

def create_verse_summary(verse_data, surah_num, verse_num):
    """
    Create a sophisticated summary using only layer 2 (Classical Shia) commentary.

    The summary should:
    - Draw exclusively from Classical Shia scholarly perspectives
    - Include theological depth from scholars like Tabatabai, Tabrisi, etc.
    - Be 3-5 sentences of substantial scholarly content
    - Maintain reverent, respectful tone
    """

    # Extract layer 2 (Classical Shia layer - theological depth)
    layer2_content = verse_data.get('layer2', '')

    if not layer2_content:
        return "Classical Shia commentary explores this verse's theological and spiritual dimensions."

    layer2_paragraphs = extract_paragraphs(layer2_content)

    summary_parts = []

    # Part 1: Opening theological context (first paragraph)
    if layer2_paragraphs:
        first_para = layer2_paragraphs[0]
        opening_sentences = extract_sentences(first_para, 3)
        if opening_sentences:
            # Take first 2-3 sentences that establish theological foundation
            summary_parts.extend(opening_sentences[:3])

    # Part 2: Additional theological depth (second paragraph if available)
    if len(layer2_paragraphs) > 1 and len(summary_parts) < 5:
        second_para = layer2_paragraphs[1]
        additional_sentences = extract_sentences(second_para, 2)
        if additional_sentences:
            # Add 1-2 more sentences for theological elaboration
            summary_parts.extend(additional_sentences[:2])

    # Part 3: Jurisprudential/practical application (third paragraph if available and needed)
    if len(layer2_paragraphs) > 2 and len(summary_parts) < 5:
        third_para = layer2_paragraphs[2]
        application_sentences = extract_sentences(third_para, 1)
        if application_sentences:
            summary_parts.append(application_sentences[0])

    # Ensure we have content
    if not summary_parts:
        return "Classical Shia exegetes provide profound insights into this verse's theological significance."

    # Combine into final summary (3-5 sentences from layer 2)
    final_summary = ' '.join(summary_parts[:5])

    return final_summary

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
