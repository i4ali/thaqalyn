# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Thaqalayn is a Shia Islamic Quranic commentary iOS app with an offline-first architecture.

**Current Status**: Production-ready app with **all 114 surahs**, **individual verse audio playback**, and **multi-theme system**. Features Surah 1 (Al-Fatiha) with complete 4-layer tafsir, 4 distinct UI themes including traditional manuscript style, complete authentication & bookmarks system with cloud sync, and individual verse audio playback using EveryAyah.com. **All features unlocked** with $0.99 paid app model.

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

## Paid App Model ✅ COMPLETE

**Implementation**: Simple paid app model with all features unlocked for $0.99 App Store purchase
- ✅ **All Reciters Free**: 6 high-quality reciters available to all users immediately
- ✅ **Standard Bookmark Limit**: 10 bookmarks for all users (reasonable limit for database efficiency)
- ✅ **No In-App Purchases**: Simplified architecture without premium complexity
- ✅ **Clean User Experience**: No paywalls, upgrade prompts, or premium UI elements

### Simplified Architecture:
```swift
PremiumManager: { isPremiumUnlocked: true (always), simplified feature access }
Services/AudioManager.swift: No premium validation - all reciters accessible
Services/BookmarkManager.swift: Standard 10 bookmark limit for all users
Models/AudioModels.swift: All reciters marked as free (isPremium: false)
```

### Audio System:
- **All 6 Reciters**: Mishary Alafasy, Al-Sudais, Al-Ghamidi, Al-Ajamy, Al-Muaiqly, Al-Dosari
- **High Quality**: 128-192kbps audio with intelligent caching
- **Individual Verse Playback**: Complete EveryAyah.com integration

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

## Current Status

**✅ Complete Features**:
- All 114 surahs with Quran text and individual verse audio playback
- Surah 1 with full 4-layer tafsir (remaining 113 surahs: text + audio only)
- Complete bookmark system with offline-first architecture and Supabase cloud sync
- **Fixed bookmark navigation** - Direct NavigationLink approach for reliable verse navigation
- User authentication (email/password, Apple Sign In, guest mode)
- Multi-theme system (4 themes: Modern Dark/Light, Traditional Manuscript, Sepia)
- Centralized settings with responsive button controls and user-friendly data management
- Search functionality across all surahs
- **All 6 reciters unlocked** with clean, simple UI design
- **Professional app icon with Islamic Quran book design**

**🚀 Ready for App Store**:
- ✅ Production-ready MVP with core features complete
- ✅ All 114 surahs with individual verse audio playback  
- ✅ Complete authentication and bookmark sync system
- ✅ Multi-theme system with 4 distinct UI themes
- ✅ **Simple paid app model** with $0.99 App Store pricing
- ✅ **Complete app icon set** (all iOS sizes: 76x76, 120x120, 152x152, 167x167, 180x180, 1024x1024)
- ✅ **Clean production code** with no hardcoded user data or debug overrides
- ✅ **Improved UI responsiveness** with enhanced touch targets and button feedback
- ✅ Stable performance and user experience

**📱 App Store Publishing Status**: READY FOR SUBMISSION

**🔄 Future Enhancements** (Post-Launch):
- Enhanced features: reading progress tracking, background audio playback
- Additional convenience features: advanced bookmarks, analytics, personalization

## Bookmark Navigation System ✅ FIXED

**Implementation**: Direct NavigationLink approach for reliable navigation
- ✅ **NavigationLink Pattern**: Replaced sheet-based navigation with direct NavigationLink
- ✅ **BookmarkCardContent**: Specialized component for NavigationLink usage (no tap gesture interference)
- ✅ **BookmarkCard**: Fallback component for non-navigation cases
- ✅ **Reliable Navigation**: Eliminates timing issues and state management complexity
- ✅ **Automatic Scrolling**: Target verse scrolling works consistently with NavigationLink
- ✅ **Clean Architecture**: Standard SwiftUI navigation patterns without complex workarounds

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

## App Store Publishing Checklist ✅

**Technical Requirements**:
- ✅ Xcode project configured for distribution
- ✅ Bundle identifier and versioning set up (`MAHR.Partner.Thaqalayn`)
- ✅ **Complete app icon set** with all required iOS sizes (76x76 to 1024x1024)
- ✅ Performance optimized for App Store guidelines
- ✅ Privacy compliance (no sensitive data collection)
- ✅ Offline functionality working properly
- ✅ **Production-ready code** with no hardcoded user data or debug overrides
- ✅ **Responsive UI controls** and proper touch targets

**Content & Metadata Ready**:
- ✅ App description highlighting Islamic Quranic commentary features
- ✅ Keywords: Islamic, Quran, Tafsir, Commentary, Shia, Audio, Offline
- ✅ Screenshots showcasing multi-theme system and audio playback
- ✅ Category: Reference/Education
- ✅ Age rating: 4+ (suitable for all ages)
- ✅ **Professional app icon** featuring Islamic Quran book design

**App Store Connect Setup Required**:
- ⏳ **Developer Program Enrollment**: Active (yearly subscription)
- ⏳ **App Store Connect Configuration**: Create app listing with unique name
- ⏳ **Pricing Setup**: Configure $0.99 paid app pricing tier
- ⏳ **No In-App Purchases**: Simplified submission process without StoreKit complexity