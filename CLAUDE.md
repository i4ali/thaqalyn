# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Thaqalyn is a Shia Islamic Quranic commentary iOS app with an offline-first architecture. The project has two main components:

1. **Data Generation System** (Python) - Pre-generates AI-based Shia tafsir commentary
2. **iOS App** (Swift/SwiftUI) - Displays the pre-generated content offline

## Architecture

### Data Generation Phase (Current)
The system generates a complete offline dataset before iOS development:
- Fetches complete Quran data (6,236 verses across 114 surahs) from Al-Quran Cloud API
- Generates 4-layer Shia tafsir commentary using DeepSeek LLM (24,944 total commentaries)
- Outputs JSON files optimized for iOS app bundle integration

### Four-Layer Tafsir System
Each verse receives commentary at 4 scholarly depths:
1. **Foundation Layer** - Simple explanations, historical context, contemporary relevance
2. **Classical Shia Layer** - Tabatabai (al-Mizan), Tabrisi (Majma al-Bayan) perspectives
3. **Contemporary Layer** - Modern scholars, scientific insights, social justice themes  
4. **Ahlul Bayt Layer** - Hadith from 14 Infallibles, theological concepts, spiritual guidance

### Data Structure
```
quran_data.json - Complete Quran with metadata
tafsir_1.json to tafsir_114.json - Commentary per surah
Structure: tafsir_data[surah][ayah][layer1-4] = commentary_text
```

## Development Commands

### Data Generation Setup
```bash
# Create and activate virtual environment
python3 -m venv thaqalyn-env
source thaqalyn-env/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure API key (create .env file)
echo "DEEPSEEK_API_KEY=your-key-here" > .env
```

### Data Generation Workflow
```bash
# Step 1: Fetch Quran data (one-time, ~3.4MB)
python fetch_quran_data.py

# Step 2: Generate tafsir commentary
python generate_tafsir.py
# Choose Option 1 for sample testing (surahs 1, 36, 67)
# Choose Option 2 for complete dataset (all 114 surahs)

# Step 3: Validate generated content
python validate_content.py
```

### iOS Development
The iOS app is currently a basic SwiftUI template. The data integration architecture from the PRD specifies:
- Core Data for user data (bookmarks, reading history, preferences)
- Bundle JSON files for Quran/tafsir content (no runtime API calls)
- Offline-first design with zero network dependencies

## Cost and Performance Expectations

### Data Generation
- **Sample Generation**: ~$1, 30 minutes (for testing)
- **Complete Dataset**: ~$50-100, 20-40 hours (production)
- **Output Size**: ~25-50MB optimized JSON files

### Production Constraints
- App must stay under iOS app size limits (~200MB uncompressed)
- Zero runtime API costs (all content pre-bundled)
- Instant performance (no network latency)

## Key Files

**Data Generation:**
- `generate_tafsir.py` - Main tafsir generator with DeepSeek integration
- `fetch_quran_data.py` - Quran data fetcher from Al-Quran Cloud API
- `validate_content.py` - Quality validation and optimization tools
- `quran_data.json` - Complete Quran dataset (generated)

**iOS App:**
- `Thaqalayn/ThaqalaynApp.swift` - App entry point
- `Thaqalayn/ContentView.swift` - Main view (currently template)

**Configuration:**
- `.env` - DeepSeek API key (not committed)
- `requirements.txt` - Python dependencies
- `tafsir_demo.json` - Sample tafsir structure for reference

## Development Notes

The current phase focuses on data generation. iOS development begins after the complete tafsir dataset is generated and validated. The PRD specifies a 3-phase approach with MVP targeting offline functionality first, then cloud features in later phases.