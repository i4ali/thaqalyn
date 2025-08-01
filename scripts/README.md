# Thaqalyn Data Generation Scripts

This directory contains scripts to generate the complete dataset for the Thaqalyn app by collecting Quran text and generating AI-powered commentary.

## Overview

The Thaqalyn app uses a **static data architecture** where all content is embedded directly in the iOS app bundle. This eliminates network dependencies and provides instant, offline access to all content.

## Generated Dataset

- **Complete Quran Text**: Arabic + English translation for all 114 surahs (~6,200 verses)
- **4 Layers of AI Commentary**: Generated using OpenAI GPT-4 for each verse
  - 🏛️ **Layer 1 - Foundation**: Simple explanations, historical context
  - 📚 **Layer 2 - Classical Shia Commentary**: Tabatabai, Tabrisi perspectives
  - 🌍 **Layer 3 - Contemporary Insights**: Modern scholars, scientific correlations
  - ⭐ **Layer 4 - Ahlul Bayt Wisdom**: Hadith from 14 Infallibles, theological concepts

## Usage

### Prerequisites

1. **Node.js 18+** installed
2. **OpenAI API Key** with sufficient credits
3. **Internet connection** for API calls

### Setup

```bash
cd scripts
npm install
export OPENAI_API_KEY="your-api-key-here"
```

### Test with Small Dataset (Recommended First)

Generate commentary for just Al-Fatihah (7 verses) to test the process:

```bash
npm run test-small
```

This will:
- Fetch Al-Fatihah text from AlQuran.cloud
- Generate 28 commentary entries (7 verses × 4 layers)
- Save test files to `../data/` directory
- Take about 30 seconds to complete

### Generate Complete Dataset

⚠️ **This will make ~25,000 OpenAI API calls and may cost $50-100**

```bash
npm run generate
```

This will:
- Fetch all 114 surahs from AlQuran.cloud (~2 minutes)
- Generate ~25,000 commentary entries using OpenAI (~7 hours)
- Save complete dataset to `../data/` directory

## Output Files

The scripts generate these JSON files in the `../data/` directory:

```
data/
├── surahs.json                 # All 114 surah metadata
├── verses.json                 # Complete Quran text (Arabic + English)
├── commentary-layer1.json      # Foundation commentary
├── commentary-layer2.json      # Classical Shia commentary  
├── commentary-layer3.json      # Contemporary insights
├── commentary-layer4.json      # Ahlul Bayt wisdom
└── dataset-summary.json        # Generation stats and info
```

## File Structure Examples

### Surah Entry
```json
{
  "id": 1,
  "name": "سُورَةُ الفَاتِحَةِ",
  "englishName": "Al-Fatihah", 
  "englishNameTranslation": "The Opening",
  "numberOfAyahs": 7,
  "revelationType": "Meccan"
}
```

### Verse Entry
```json
{
  "id": "1:1",
  "surahId": 1,
  "ayahNumber": 1,
  "arabicText": "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَـٰنِ ٱلرَّحِيمِ",
  "translation": "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
  "transliteration": null
}
```

### Commentary Entry
```json
{
  "verseId": "1:1",
  "surah": 1,
  "ayah": 1,
  "layer": 1,
  "layerName": "Foundation",
  "content": "This verse, known as the Basmala...",
  "generatedAt": "2025-08-01T05:30:00.000Z",
  "sources": ["Simple explanations, historical context"]
}
```

## Cost Estimation

- **OpenAI API calls**: ~25,000 calls (6,200 verses × 4 layers)
- **Token usage**: ~500 tokens per call = ~12.5M tokens total
- **Estimated cost**: $50-100 depending on model and usage
- **Generation time**: ~7 hours (with 1-second delays between calls)

## Rate Limiting

The script includes:
- 1-second delay between OpenAI API calls
- Respectful delays for AlQuran.cloud API
- Progress logging and error handling
- Automatic retry logic

## Next Steps

After generating the dataset:
1. Review generated content quality
2. Update iOS app to load from local JSON files
3. Remove APIService and network code
4. Test app with complete embedded dataset

## Troubleshooting

**OpenAI API Errors**: Check your API key and credit balance
**Rate Limiting**: The script handles this automatically
**Large File Sizes**: Generated JSON files may be 50-100MB total
**Memory Usage**: Node.js may need increased heap size for large datasets