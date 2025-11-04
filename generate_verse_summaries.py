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
    Create a sophisticated summary synthesizing layer 1 and layer 2 commentary.

    The summary should:
    - Capture core meaning and historical context (layer 1)
    - Include theological depth and classical Shia perspectives (layer 2)
    - Be 4-5 sentences of substantial scholarly content
    - Maintain reverent, respectful tone
    """

    # Extract layer 1 (Foundation layer - contemporary, accessible)
    layer1_content = verse_data.get('layer1', '')
    layer1_paragraphs = extract_paragraphs(layer1_content)

    # Extract layer 2 (Classical Shia layer - theological depth)
    layer2_content = verse_data.get('layer2', '')
    layer2_paragraphs = extract_paragraphs(layer2_content)

    summary_parts = []

    # Part 1: Core meaning and context from Layer 1 (first paragraph usually contains essence)
    if layer1_paragraphs:
        # Get first paragraph which typically introduces the verse's core message
        first_para = layer1_paragraphs[0]
        core_sentences = extract_sentences(first_para, 2)
        if core_sentences:
            # Take first 1-2 sentences that capture the core meaning
            summary_parts.extend(core_sentences[:2])

    # Part 2: Theological and classical Shia perspective from Layer 2
    if layer2_paragraphs:
        # First paragraph of layer 2 usually has theological foundations
        first_para = layer2_paragraphs[0]
        theological_sentences = extract_sentences(first_para, 2)

        # Add theological depth (1-2 sentences)
        if theological_sentences:
            summary_parts.extend(theological_sentences[:2])

    # Part 3: Practical/spiritual application from later in Layer 1
    if len(layer1_paragraphs) > 1:
        # Last paragraph often contains practical applications
        last_para = layer1_paragraphs[-1]
        application_sentences = extract_sentences(last_para, 1)
        if application_sentences and len(summary_parts) < 5:
            summary_parts.append(application_sentences[0])

    # Part 4: Additional depth from Layer 2 if available
    if len(layer2_paragraphs) > 1 and len(summary_parts) < 5:
        # Get additional theological insight from second paragraph
        second_para = layer2_paragraphs[1]
        additional_sentences = extract_sentences(second_para, 1)
        if additional_sentences:
            summary_parts.append(additional_sentences[0])

    # Ensure we have content
    if not summary_parts:
        return "This verse contains profound commentary exploring its theological, spiritual, and practical dimensions."

    # Combine into final summary (4-5 sentences ideal)
    # Prioritize balance between layer 1 and layer 2
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
