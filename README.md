# Thaqalyn Data Generation

Scripts to generate the complete offline dataset for the Thaqalyn iOS app.

## Overview

This generates:
- Complete Quran data (6,236 verses across 114 surahs)
- 4-layer AI-generated Shia tafsir using DeepSeek
- JSON files ready for iOS app integration

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Get DeepSeek API key from [platform.deepseek.com](https://platform.deepseek.com)

3. Set environment variable:
```bash
export DEEPSEEK_API_KEY="your-api-key-here"
```

## Usage

### Step 1: Fetch Quran Data
```bash
python fetch_quran_data.py
```
This creates `quran_data.json` with all Quran text and translations.

### Step 2: Generate Tafsir
```bash
python generate_tafsir.py
```

Choose:
- **Option 1**: Sample surahs (1, 36, 67) for testing
- **Option 2**: Complete dataset (all 114 surahs)

## Output Files

- `quran_data.json` - Complete Quran with metadata
- `passages_N.json` - Passage commentary for surah N (one entry per ruku)
- `tafsir_N.json` - Legacy per-verse files, now read only for the Gems (`quickOverview`) data

## Passage commentary

Commentary is written per passage (a ruku), not per verse, and only from fetched sources. Each passage carries:

1. **Essay** - the passage told once, in order, with citation markers
2. **Verse by verse** - headings and notes on the verses that need them
3. **Narrations** - from the Prophet and the Imams, each with its source
4. **Perspectives** - where Shia and Sunni readings differ (the only place Sunni works are cited)

Every marker resolves to a source record (work, author, locus, excerpt where the tier allows). Design: `docs/plans/2026-09-05-passage-commentary-design.md`; generation: `/passages`.

## Cost & Time

- **Sample**: ~$1, 30 minutes
- **Complete**: ~$50-100, 20-40 hours
- **Storage**: ~50-100MB total

## Next Steps

After generation, integrate JSON files into the iOS app bundle for offline access.