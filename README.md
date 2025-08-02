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
- `tafsir_1.json` to `tafsir_114.json` - Commentary for each surah

## Tafsir Layers

Each verse gets 4 layers of commentary:

1. **Foundation (🏛️)** - Simple explanations, historical context
2. **Classical Shia (📚)** - Tabatabai, Tabrisi perspectives  
3. **Contemporary (🌍)** - Modern scholars, scientific insights
4. **Ahlul Bayt (⭐)** - Hadith, theological concepts, spiritual guidance

## Cost & Time

- **Sample**: ~$1, 30 minutes
- **Complete**: ~$50-100, 20-40 hours
- **Storage**: ~50-100MB total

## Next Steps

After generation, integrate JSON files into the iOS app bundle for offline access.