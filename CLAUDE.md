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

### ⚠️ CLOUD SYNC ARCHITECTURE PATTERN ⚠️

**CRITICAL**: For any data type that needs to be synced to cloud (Supabase), follow the **BOOKMARK_SYNC_ARCHITECTURE.md** as closely as possible. This architecture is production-tested and provides:

- **Offline-First Design**: Local operations succeed immediately, cloud sync happens asynchronously
- **Zero Data Loss**: Every operation persists locally before attempting cloud sync
- **Intelligent Conflict Resolution**: Timestamp-based detection with local-first preservation
- **User Account Isolation**: Complete data separation between users
- **Automatic Retry**: Failed operations queue for next sync attempt
- **Three-Step Sync Process**: Delete → Upload → Download (correct order guaranteed)

**Implementation Checklist** (from BOOKMARK_SYNC_ARCHITECTURE.md):
1. ✅ Define data model with sync status enum (`synced`, `pendingSync`, `conflict`)
2. ✅ Create manager class with `@MainActor` isolation
3. ✅ Implement local storage (UserDefaults with JSON encoding)
4. ✅ Implement pending deletes tracking (separate Set)
5. ✅ Setup Supabase observers for auth state changes
6. ✅ Implement CRUD operations (offline-first pattern)
7. ✅ Implement three-step sync process
8. ✅ Implement conflict resolution in merge algorithm
9. ✅ Add debouncing for sync scheduling
10. ✅ Implement cleanup methods (sign-out, user switching)
11. ✅ Add Supabase service methods
12. ✅ Create database schema with RLS policies

**Do NOT** deviate from this pattern without explicit approval. This architecture guarantees data integrity and provides excellent UX.