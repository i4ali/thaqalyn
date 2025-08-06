# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Thaqalyn is a Shia Islamic Quranic commentary iOS app with an offline-first architecture. The project combines:

1. **Data Generation System** (Python) - Pre-generates AI-based Shia tafsir commentary using DeepSeek
2. **iOS App** (Swift/SwiftUI) - Modern iOS app displaying pre-generated content offline

**Current Status**: Production-ready app with **all 114 surahs** available for reading and surah-level audio playback. Features Surah 1 (Al-Fatiha) with complete 4-layer tafsir using updated no-transliteration prompts, stunning dark modern UI with glassmorphism design, nested tab navigation system, **complete authentication & bookmarks system with full cloud sync**, **streamlined audio playback system** for complete surahs only, and email confirmation deep linking implemented. **Tafsir data for remaining 113 surahs will be generated manually as needed.**

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
- **Models**: 
  - `QuranModels.swift` - Core data structures for Quran, Tafsir, Bookmarks, and display models with SajdaInfo handling
  - `AudioModels.swift` - Audio system models for reciters, configurations, playback state
- **Services**: 
  - `DataManager.swift` - Singleton managing JSON loading, caching, and data access with debug logging
  - `BookmarkManager.swift` - Offline-first bookmark management with UserDefaults storage, ready for Supabase sync
  - `AudioManager.swift` - Streamlined audio playback service for surah-level audio only
- **Views**: Modern dark SwiftUI hierarchy with glassmorphism design:
  - `ContentView` - Dark gradient surah list with floating orbs, search, and bookmarks access button
  - `SurahDetailView` - Modern verse cards with bookmark buttons, gradient elements, and nested tab navigation
  - `BookmarksView` - Complete bookmark management with search, sorting, deletion, and premium upsell
  - `SurahAudioPlayerView` - Beautiful glassmorphism audio player with surah-level controls
- **Data**: Bundled JSON files (quran_data.json for all 114 surahs + tafsir_1.json for Al-Fatiha only) + local UserDefaults bookmark storage

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

### Data Generation Workflow (For Manual Tafsir Generation)
```bash
# IMPORTANT: Tafsir data will be generated manually as needed
# Current status: Only Surah 1 (Al-Fatiha) has tafsir data
# All other 113 surahs display Quran text with audio but no tafsir commentary

# Generate individual surah tafsir when needed (manual process)
source thaqalyn-env/bin/activate
python3 quick_surah_1.py <surah_number>  # e.g., python3 quick_surah_1.py 2

# Examples:
python3 quick_surah_1.py 1   # Al-Fatiha (already complete)
python3 quick_surah_1.py 36  # Ya-Sin (to be generated manually)
python3 quick_surah_1.py 114 # An-Nas (to be generated manually)

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
│   ├── BookmarkManager.swift       # Offline-first bookmark management with UserDefaults
│   └── AudioManager.swift          # Comprehensive audio playback with verse highlighting
├── Views/
│   ├── ContentView.swift           # Main surah list view with bookmarks access
│   ├── SurahDetailView.swift       # Verse detail with bookmark buttons + tafsir modal
│   └── BookmarksView.swift         # Complete bookmark management interface
├── Data/                           # Bundled JSON files
│   ├── quran_data.json            # Complete Quran (3.4MB, all 114 surahs with 6,236 verses)
│   └── tafsir_1.json              # Al-Fatiha commentary only (clean, no transliterations)
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

**Audio System**: Streamlined audio playback implementation with:
- AudioManager service with AVAudioPlayer and caching (100MB cache limit)
- 6 popular Quran reciters including Mishary Alafasy and Abdul Rahman Al-Sudais
- **Surah-level audio playback only** - complete surahs from start to finish
- Beautiful glassmorphism audio player UI with playback controls
- Reciter selection, repeat modes, and audio quality settings
- Now Playing integration with Control Center support
- Simplified architecture without verse highlighting or individual verse audio

**Error Handling**: Comprehensive error states in DataManager with user-friendly glassmorphism error cards and graceful degradation when tafsir data is missing.

## Current Status and Next Steps

**🎯 Recent Improvements (January 2025)**:
- ✅ **Verse Highlighting Removed**: Completely removed verse highlighting feature and all related timing systems for simplified, cleaner architecture
- ✅ **Individual Verse Audio Removed**: Eliminated individual verse audio buttons and playback - now supports surah-level audio only
- ✅ **Timing Data Cleaned**: Removed all word-level timing JSON files and related data models from the codebase
- ✅ **Streamlined Audio Architecture**: Simplified AudioManager with focus on complete surah playback experience
- ✅ **UI Cleanup**: Removed audio buttons from individual verse cards, keeping only bookmark and commentary buttons

**✅ Complete Features**:
- **All 114 Surahs with complete Quran text** (6,236 verses) available for reading and audio playback
- **Surah 1 (Al-Fatiha) with full 4-layer tafsir** using improved prompts - remaining tafsir to be generated manually
- **Streamlined audio playback system**:
  - Complete surah audio with 6 popular reciters (Mishary Alafasy, Abdul Rahman Al-Sudais, etc.)
  - Beautiful glassmorphism audio player with playback controls and settings
  - Audio caching, quality selection, repeat modes, and Now Playing integration
  - Simplified architecture focused on complete surah listening experience
- Stunning dark modern UI with glassmorphism design throughout
- Complete navigation system (list → detail → tafsir modal when available)
- Nested tab navigation system within tafsir layers
- Search functionality with glassmorphism styling across all 114 surahs
- **Complete bookmarks system with offline-first architecture and cloud sync**:
  - Heart-shaped bookmark buttons on all verse cards with instant visual feedback
  - Bookmark access buttons on main page with live count badges
  - Full BookmarksView with search, sorting, enhanced deletion, and navigation to original verse context
  - Auto-scrolling to specific verses when navigating from bookmarks
  - Free tier (2 bookmarks) with premium upsell integration
  - UserDefaults storage with comprehensive Supabase cloud sync
  - Three-step sync process: delete → upload → download with conflict resolution
  - Real-time sync status indicators and toast notifications
- **Complete user authentication system**:
  - Modern glassmorphism AuthenticationView with email/password, Apple Sign In, and guest mode
  - SupabaseService with full authentication methods (signUp, signIn, signInWithApple, resetPassword)
  - Anonymous authentication with upgrade paths to permanent accounts
  - Authentication state management with automatic sync triggering
- Comprehensive error handling and loading states
- Custom SajdaInfo handling for mixed JSON formats
- Debug logging system for troubleshooting
- Clean data generation without transliterations or formatting artifacts

**🚀 Next Steps**:
- **Supabase Integration** ✅ **FULLY COMPLETE**:
  - ✅ **Organization Created**: "i4ali's Org" (zijygqgebsdmibiwdxis)
  - ✅ **Project Created**: "Thaqalayn" (awiuswwmvlmmvkkfghvc) in us-east-1 region
  - ✅ **Credentials Configured**: URL and anon key stored in Config.swift
  - ✅ **Supabase Swift SDK Added**: Successfully integrated v2.5.1+ with proper project configuration
  - ✅ **Database Schema Complete**: Full bookmark system with secure RLS policies
    - `bookmarks` table with verse references, notes, tags, and collections
    - `user_preferences` table with premium status, limits, reading progress
    - `bookmark_collections` table for organizing bookmarks
    - Automatic user setup, triggers, and security functions
    - All security advisors passed - production ready
  - ✅ **SupabaseService Complete**: Full service wrapper with authentication and CRUD operations
  - ✅ **Offline-first sync strategy implemented**: Three-step sync with conflict resolution
  - ✅ **User authentication flow complete**: Email/password, Apple Sign In, guest mode with AuthenticationView
- **Manual Tafsir Generation**: Generate remaining 113 surahs using `quick_surah_1.py` script as needed
- **Enhanced Features**: Reading progress tracking, additional reciters, background audio playback
- **Monetization**: Add in-app purchase system for premium upgrade and additional features
- **Distribution**: App Store submission and distribution

## Bundle Size and Performance

- **Current App Size**: ~8MB (all 114 surahs + 1 surah tafsir + dark modern UI + bookmark system + audio system + Supabase SDK)
- **Projected Full Size**: ~50-80MB (all 114 surahs with full tafsir commentary + complete feature set)
- **Load Performance**: <1 second app launch with beautiful loading animations
- **UI Performance**: 60fps smooth animations with glassmorphism effects, bookmark interactions, and audio controls
- **Memory Usage**: Intelligent per-surah caching with gradient rendering optimization + efficient local/cloud bookmark storage + 100MB audio cache
- **Data Quality**: Clean text without transliterations, complete sentences, proper formatting across all 114 surahs
- **Audio Performance**: Instant surah-level audio playback with caching and seamless streaming
- **Bookmark Performance**: Instant bookmark toggles, real-time count updates, offline-first architecture with cloud sync
- **Database Performance**: PostgreSQL 17.4 with optimized indexes, RLS security, and efficient querying

## Memories
- to memorize