# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Thaqalayn is a Shia Islamic Quranic commentary iOS app with an offline-first architecture.

**Current Status**: Production-ready app with **all 114 surahs**, **individual verse audio playback**, **bilingual commentary system**, and **multi-theme system**. Features complete **5-layer tafsir** with **English and Urdu support**, including new **comparative Shia/Sunni analysis**, 4 distinct UI themes including traditional manuscript style, complete authentication & bookmarks system with cloud sync, and individual verse audio playback using EveryAyah.com. **All features unlocked** with $0.99 paid app model.

## Architecture

### Data Flow
```
Al-Quran Cloud API → Python Scripts → JSON Files → iOS App Bundle → SwiftUI Views
```

### Five-Layer Tafsir System
1. **Foundation Layer** - Simple explanations, historical context (🏛️)
2. **Classical Shia Layer** - Tabatabai, Tabrisi perspectives (📚)
3. **Contemporary Layer** - Modern scholars, scientific insights (🌍)
4. **Ahlul Bayt Layer** - Hadith from 14 Infallibles, spiritual guidance (⭐)
5. **Comparative Layer** - Balanced Shia/Sunni scholarly analysis (⚖️)

### Key Data Structures
```swift
QuranData: { surahs: [Surah], verses: [String: [String: Verse]] }
TafsirData: { verses: [String: TafsirVerse] }
Bookmark: { id, userId, surahNumber, verseNumber, notes, tags, createdAt, syncStatus }
CurrentPlayback: { surahNumber, verseNumber, reciter, currentTime, isPlaying }
```

## Individual Verse Audio System ✅ COMPLETE

**Implementation**:
- ✅ Individual verse playback using EveryAyah.com URLs (`https://www.everyayah.com/data/Alafasy_128kbps/001001.mp3`)
- ✅ Individual play buttons on each verse card with visual feedback  
- ✅ **Play Sequence functionality** for continuous surah playback (FIXED)
- ✅ **All reciters free**: 6 high-quality reciters available to all users
- ✅ Reciter selection with clean UI (no premium barriers)
- ✅ **Responsive audio controls**: Fixed button touch targets with 60pt minimum height, contentShape for full area tappability
- ✅ Best available quality per reciter (40-192kbps), caching (100MB), HTTPS compliance

## Multi-Theme System ✅ COMPLETE

**Implementation**:
- ✅ **4 distinct themes** with full UI adaptation and smooth transitions
- ✅ **Modern Dark**: Current glassmorphism dark theme with floating orbs
- ✅ **Modern Light**: Light version of glassmorphism design 
- ✅ **Traditional Manuscript**: Greenish-cream background matching classic Islamic manuscripts
- ✅ **Sepia**: Warm, easy-on-eyes reading mode
- ✅ **Settings Integration**: Centralized settings view with theme selection and preview cards
- ✅ **Live Preview**: Interactive theme selection with real-time Arabic/English text previews
- ✅ **Backward Compatibility**: Maintains existing theme toggle for Modern Dark/Light themes
- ✅ **Persistent Storage**: Theme preference saved in UserDefaults with migration support

### Theme Architecture:
```swift
ThemeVariant: { modernDark, modernLight, classicLight, sepia }
ThemeManager: { selectedTheme, setTheme(), colorScheme, primaryBackground, etc. }
Views/SettingsView.swift: Centralized settings with theme selection
Views/ThemeSelectionView.swift: Interactive theme preview cards
```

## Development Commands

### iOS Development
```bash
# Build and run (MCP XcodeBuild tools recommended)
build_run_sim_name_proj({ projectPath: "Thaqalayn.xcodeproj", scheme: "Thaqalayn", simulatorName: "iPhone 16" })
```

### Python Development
```bash
# ⚠️ CRITICAL: ALWAYS USE VIRTUAL ENVIRONMENT ⚠️
source thaqalyn-env/bin/activate

# Generate individual surah tafsir when needed
python3 quick_surah_1.py <surah_number>
```

## App Structure

```
Thaqalayn/
├── Models/
│   ├── QuranModels.swift          # Core data models
│   └── AudioModels.swift          # Audio system models
├── Services/
│   ├── DataManager.swift          # JSON loading, caching
│   ├── BookmarkManager.swift      # Offline-first bookmarks with Supabase sync
│   ├── AudioManager.swift         # Individual verse audio playback
│   ├── ThemeManager.swift         # Multi-theme system management
│   └── PremiumManager.swift       # Simplified premium manager (always unlocked)
├── Views/
│   ├── ContentView.swift          # Main surah list with settings access
│   ├── SurahDetailView.swift      # Verse detail with audio controls
│   ├── BookmarksView.swift        # Bookmark management
│   ├── SettingsView.swift         # Centralized app settings
│   └── ThemeSelectionView.swift   # Interactive theme selection
└── Data/
    ├── quran_data.json            # All 114 surahs (3.4MB)
    └── tafsir_1.json              # Al-Fatiha commentary only
```

## Supabase Integration ✅ FULLY COMPLETE

- **Organization**: Configure in Config.swift
- **Project**: Configure in Config.swift
- **Database Schema**: Complete with RLS policies, triggers, security functions
- **Sync Strategy**: Three-step sync (delete → upload → download) with conflict resolution
- **Authentication**: Email/password, Apple Sign In, anonymous auth with upgrade paths

## Performance & App Store Readiness

- **App Size**: ~5MB optimized for App Store distribution
- **Load Performance**: <1 second app launch with smooth animations
- **Audio Performance**: Instant individual verse playback with intelligent caching and streaming
- **UI Performance**: 60fps animations with glassmorphism effects across all 4 themes
- **Stability**: Production-tested with offline-first architecture and robust error handling
- **Compatibility**: iOS 15.0+, supports iPhone and iPad with responsive design

## Critical Development Guidelines

### ⚠️ NO FALLBACK LOGIC UNLESS EXPLICITLY REQUESTED ⚠️

**IMPORTANT**: Do not add any fallback logic, alternative implementations, or graceful degradation patterns unless explicitly asked. When operations fail, throw appropriate errors and let the caller handle them.

**Examples of what NOT to do**:
- ❌ Adding `try-catch` blocks with alternative implementations
- ❌ Providing "backup" methods when primary fails
- ❌ Silently degrading functionality when errors occur
- ❌ Creating "safe" versions that skip critical steps

**Correct approach**:
- ✅ Throw clear, descriptive errors when operations fail
- ✅ Let calling code decide how to handle failures
- ✅ Maintain data integrity over graceful degradation
- ✅ Fail fast and fail clearly

**Rationale**: Fallback logic can mask critical failures, lead to data inconsistency, and make debugging difficult. Clean error handling ensures problems are caught early and addressed properly.