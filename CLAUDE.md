# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Thaqalyn is a Shia Islamic Quranic commentary iOS app with an offline-first architecture. The project combines:

1. **Data Generation System** (Python) - Pre-generates AI-based Shia tafsir commentary using DeepSeek
2. **iOS App** (Swift/SwiftUI) - Modern iOS app displaying pre-generated content offline

**Current Status**: MVP complete with Surah 1 (Al-Fatiha) using updated no-transliteration prompts, full 4-layer tafsir system, stunning dark modern UI with glassmorphism design, nested tab navigation system, and **complete bookmarks feature with offline-first architecture** implemented.

## Architecture

### Data Flow Architecture
```
Al-Quran Cloud API → Python Scripts → JSON Files → iOS App Bundle → SwiftUI Views
```

### Four-Layer Tafsir System
Each verse receives commentary at 4 scholarly depths:
1. **Foundation Layer** - Simple explanations, historical context, contemporary relevance (🏛️)
2. **Classical Shia Layer** - Tabatabai (al-Mizan), Tabrisi (Majma al-Bayan) perspectives (📚)
3. **Contemporary Layer** - Modern scholars, scientific insights, social justice themes (🌍)
4. **Ahlul Bayt Layer** - Hadith from 14 Infallibles, theological concepts, spiritual guidance (⭐)

**Key Improvements (2025)**: Updated prompts eliminate transliterations (uses "Ali" not "ʿAlī"), generate complete sentences without truncation, and produce clean formatting without markdown artifacts.

### iOS App Architecture
- **Models**: `QuranModels.swift` - Core data structures for Quran, Tafsir, Bookmarks, and display models with SajdaInfo handling
- **Services**: 
  - `DataManager.swift` - Singleton managing JSON loading, caching, and data access with debug logging
  - `BookmarkManager.swift` - Offline-first bookmark management with UserDefaults storage, ready for Supabase sync
- **Views**: Modern dark SwiftUI hierarchy with glassmorphism design:
  - `ContentView` - Dark gradient surah list with floating orbs, search, and bookmarks access button
  - `SurahDetailView` - Modern verse cards with bookmark buttons, gradient elements, and nested tab navigation
  - `BookmarksView` - Complete bookmark management with search, sorting, deletion, and premium upsell
- **Data**: Bundled JSON files (quran_data.json + tafsir_1.json) + local UserDefaults bookmark storage

### Key Data Structures
```swift
QuranData: { surahs: [Surah], verses: [String: [String: Verse]] }
TafsirData: { verses: [String: TafsirVerse] }
TafsirVerse: { layer1: String, layer2: String, layer3: String, layer4: String }
SurahWithTafsir: Combined model for display with verses and commentary

// Bookmark System
Bookmark: { id, userId, surahNumber, verseNumber, surahName, verseText, verseTranslation, notes, tags, createdAt, updatedAt, syncStatus }
BookmarkCollection: { id, userId, name, description, bookmarkIds, createdAt, updatedAt }
UserBookmarkPreferences: { userId, isPremium, bookmarkLimit, defaultTags, sortOrder, groupBy }
```

## Development Commands

### iOS Development
```bash
# Build for simulator
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16' build

# Build and run on simulator
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16' build-for-testing test-without-building

# Using MCP XcodeBuild tools (recommended):
# Discover projects: discover_projs({ workspaceRoot: "/path/to/Thaqalayn" })
# Build and run: build_run_sim_name_proj({ projectPath: "Thaqalayn.xcodeproj", scheme: "Thaqalayn", simulatorName: "iPhone 16" })
```

### Supabase Setup (Cloud Sync for Bookmarks)
```bash
# IMPORTANT: Supabase organization and project have been created and are ready for integration

# Next steps for Supabase integration:
# 1. Add Supabase Swift SDK to Xcode project
# 2. Configure database schema for bookmarks and user data
# 3. Implement sync functions in BookmarkManager
# 4. Add user authentication flow

# Use MCP Supabase tools to manage the project:
# List projects: mcp__supabase__list_projects()
# Get project details: mcp__supabase__get_project({ id: "PROJECT_ID" })
# Execute SQL: mcp__supabase__execute_sql({ project_id: "PROJECT_ID", query: "SQL_QUERY" })
```

### Data Generation Setup (For extending to remaining 107 surahs)
```bash
# IMPORTANT: Always use virtual environment for Python dependencies
# Create and activate virtual environment
python3 -m venv thaqalyn-env
source thaqalyn-env/bin/activate

# Install dependencies
pip install -r requirements.txt
pip install openai python-dotenv  # Core dependencies for tafsir generation

# Configure API keys (create .env file)
echo "DEEPSEEK_API_KEY=your-key-here" > .env
echo "OPENROUTER_API_KEY=sk-or-v1-..." >> .env
```

### Data Generation Workflow
```bash
# Generate individual surah (recommended approach)
source thaqalyn-env/bin/activate
python3 quick_surah_1.py <surah_number>  # e.g., python3 quick_surah_1.py 2

# Examples:
python3 quick_surah_1.py 1   # Al-Fatiha
python3 quick_surah_1.py 36  # Ya-Sin
python3 quick_surah_1.py 114 # An-Nas

# Monitor progress
python monitor_progress.py

# Validate content quality
python validate_content.py
```

## Key Files and Architecture

### iOS App Structure
```
Thaqalayn/
├── Models/QuranModels.swift          # Core data models with SajdaInfo + Bookmark models
├── Services/
│   ├── DataManager.swift           # Singleton data loader with caching
│   └── BookmarkManager.swift       # Offline-first bookmark management with UserDefaults
├── Views/
│   ├── ContentView.swift           # Main surah list view with bookmarks access
│   ├── SurahDetailView.swift       # Verse detail with bookmark buttons + tafsir modal
│   └── BookmarksView.swift         # Complete bookmark management interface
├── Data/                           # Bundled JSON files
│   ├── quran_data.json            # Complete Quran (3.4MB, 114 surahs)
│   └── tafsir_1.json              # Al-Fatiha commentary (clean, no transliterations)
└── ThaqalaynApp.swift              # App entry point
```

### Python Data Generation
- `fetch_quran_data.py` - Al-Quran Cloud API integration
- `generate_tafsir.py` - Core TafsirGenerator class with updated no-transliteration prompts
- `quick_surah_1.py` - Generate any individual surah with real-time progress monitoring
- `monitor_progress.py` - Real-time progress tracking and statistics
- `validate_content.py` - Quality validation tools

### Critical Implementation Details

**Dark Modern UI Design**: Complete implementation of glassmorphism design with:
- Dark gradient backgrounds (#0f172a to #334155) with floating gradient orbs
- Ultra-thin material glassmorphism effects with backdrop blur
- Vibrant gradient accents (purple/blue #6366f1 to pink #ec4899)
- Modern typography with proper weight and opacity hierarchy
- Smooth animations and micro-interactions

**SajdaInfo Handling**: The `Verse.sajda` field handles both boolean (`false`) and object (`{id: 1, recommended: true}`) formats from the API using custom Codable implementation.

**DataManager Pattern**: Singleton `@MainActor` class with `@Published` properties for SwiftUI reactivity. Loads JSON at app launch with intelligent caching per surah and comprehensive debug logging.

**Navigation Architecture**: `NavigationView` with `StackNavigationViewStyle` → Modern cards → `NavigationLink` → Full-screen verse view → Sheet modal for tafsir with nested tab system (Foundation/Classical/Contemporary/Ahlul Bayt layers, each with internal section tabs).

**Bookmark Architecture**: Complete offline-first bookmark system with:
- Heart-shaped bookmark buttons on verse cards with instant visual feedback
- Bookmark count badges with live updates across all views
- BookmarksView with search, sort (date/surah order/alphabetical), and multiple deletion methods
- Free tier: 2 bookmarks limit with premium upsell UI
- UserDefaults storage with sync-ready architecture for Supabase integration
- Comprehensive bookmark data models supporting notes, tags, collections, and user preferences

**Error Handling**: Comprehensive error states in DataManager with user-friendly glassmorphism error cards and graceful degradation when tafsir data is missing.

## Current Status and Next Steps

**✅ Complete Features**:
- Surah 1 (Al-Fatiha) with full 4-layer tafsir using improved prompts
- Stunning dark modern UI with glassmorphism design
- Complete navigation system (list → detail → tafsir modal)
- Nested tab navigation system within tafsir layers
- Search functionality with glassmorphism styling
- **Complete bookmarks system with offline-first architecture**:
  - Heart-shaped bookmark buttons on all verse cards
  - Bookmark access buttons on main page and surah pages
  - Full BookmarksView with search, sorting, and deletion capabilities
  - Free tier (2 bookmarks) with premium upsell integration
  - UserDefaults storage ready for Supabase cloud sync
- Comprehensive error handling and loading states
- Custom SajdaInfo handling for mixed JSON formats
- Debug logging system for troubleshooting
- Clean data generation without transliterations or formatting artifacts

**🚀 Next Steps**:
- **Supabase Integration** (organization and project created, ready for implementation):
  - Add Supabase Swift SDK to Xcode project
  - Design and implement database schema for bookmarks and user data
  - Implement cloud sync functions in BookmarkManager
  - Add user authentication flow with Supabase Auth
- Generate remaining 113 surahs using `quick_surah_1.py` script
- Implement additional features: reading progress tracking, audio recitation
- App Store submission and distribution

## Bundle Size and Performance

- **Current App Size**: ~5MB (1 surah with clean commentary + dark modern UI + bookmark system)
- **Projected Full Size**: ~50-80MB (all 114 surahs with full glassmorphism UI + cloud sync)
- **Load Performance**: <1 second app launch with beautiful loading animations
- **UI Performance**: 60fps smooth animations with glassmorphism effects and bookmark interactions
- **Memory Usage**: Intelligent per-surah caching with gradient rendering optimization + efficient UserDefaults bookmark storage
- **Data Quality**: Clean text without transliterations, complete sentences, proper formatting
- **Bookmark Performance**: Instant bookmark toggles, real-time count updates, efficient local storage with sync-ready architecture

## Memories
- to memorize