# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Thaqalayn is a Shia Islamic Quranic commentary iOS app with an offline-first architecture.

**Current Status**: Production-ready app with **all 114 surahs**, **individual verse audio playback**, and **multi-theme system**. Features Surah 1 (Al-Fatiha) with complete 4-layer tafsir, 4 distinct UI themes including traditional manuscript style, complete authentication & bookmarks system with cloud sync, and individual verse audio playback using EveryAyah.com.

## Architecture

### Data Flow
```
Al-Quran Cloud API → Python Scripts → JSON Files → iOS App Bundle → SwiftUI Views
```

### Four-Layer Tafsir System
1. **Foundation Layer** - Simple explanations, historical context (🏛️)
2. **Classical Shia Layer** - Tabatabai, Tabrisi perspectives (📚)
3. **Contemporary Layer** - Modern scholars, scientific insights (🌍)
4. **Ahlul Bayt Layer** - Hadith from 14 Infallibles, spiritual guidance (⭐)

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
- ✅ **Premium reciter system**: Mishary Alafasy (free), 5 premium reciters with upgrade prompts
- ✅ Reciter selection with crown badges, lock icons, and premium upgrade flow
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
│   └── ThemeManager.swift         # Multi-theme system management
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

## Current Status

**✅ Complete Features**:
- All 114 surahs with Quran text and individual verse audio playback
- Surah 1 with full 4-layer tafsir (remaining 113 surahs: text + audio only)
- Complete bookmark system with offline-first architecture and Supabase cloud sync
- User authentication (email/password, Apple Sign In, guest mode)
- Multi-theme system (4 themes: Modern Dark/Light, Traditional Manuscript, Sepia)
- Centralized settings with theme selection and live previews
- Search functionality across all surahs

**🚀 Next Steps**:
- Manual tafsir generation for remaining 113 surahs using `quick_surah_1.py`
- Enhanced features: reading progress tracking, background audio playback
- Monetization: in-app purchase system for premium features
- App Store distribution

## Supabase Integration ✅ FULLY COMPLETE

- **Organization**: "i4ali's Org" (zijygqgebsdmibiwdxis)  
- **Project**: "Thaqalayn" (awiuswwmvlmmvkkfghvc)
- **Database Schema**: Complete with RLS policies, triggers, security functions
- **Sync Strategy**: Three-step sync (delete → upload → download) with conflict resolution
- **Authentication**: Email/password, Apple Sign In, anonymous auth with upgrade paths

## Performance

- **App Size**: ~5MB current, ~50-80MB projected with full tafsir
- **Load Performance**: <1 second app launch
- **Audio Performance**: Instant individual verse playback with caching and streaming
- **UI Performance**: 60fps animations with glassmorphism effects