# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Thaqalyn is an iOS mobile app for Shia Islamic Quranic commentary using AI-generated tafsir. The app provides a modern SwiftUI interface with four layers of commentary, from basic explanations to advanced Ahlul Bayt teachings.

## Architecture

This is a standard iOS SwiftUI project with the following structure:
- **ThaqalynApp.swift**: Main app entry point
- **ContentView.swift**: Primary view (currently placeholder)
- Built for iOS 18.2+ deployment target
- Uses Swift 5.0 and SwiftUI framework
- Bundle identifier: `MAHR.Partner.Thaqalyn`

## Development Commands

### Building and Testing
- **Build for iOS Simulator**: Use Xcode Build MCP tools with scheme `Thaqalyn`
- **Available Scheme**: `Thaqalyn` (only scheme in project)
- **Project File**: `Thaqalyn.xcodeproj`

### Xcode Build MCP Commands
```bash
# Build for iOS simulator
mcp__XcodeBuildMCP__build_sim_name_proj({ 
  projectPath: "/path/to/Thaqalyn.xcodeproj", 
  scheme: "Thaqalyn", 
  simulatorName: "iPhone 16" 
})

# Run in simulator
mcp__XcodeBuildMCP__build_run_sim_name_proj({
  projectPath: "/path/to/Thaqalyn.xcodeproj",
  scheme: "Thaqalyn",
  simulatorName: "iPhone 16"
})
```

## Product Context

According to the PRD (thaqalyn-prd-v2.md), this project implements:

1. **Four-Layer Commentary System**:
   - Layer 1: Foundation (basic explanations)
   - Layer 2: Classical Shia Commentary (Tabatabai, Tabrisi)
   - Layer 3: Contemporary Insights (modern scholars)
   - Layer 4: Ahlul Bayt Wisdom (hadith from 14 Infallibles)

2. **MVP Architecture** (current phase):
   - Pure iOS app with no backend initially
   - LLM-powered tafsir generation via stateless API
   - Local Core Data caching
   - Modern SwiftUI design system

3. **Planned Structure**:
   ```
   Thaqalyn/
   ├── App/ (ThaqalynApp.swift, ContentView.swift)
   ├── Models/ (Surah.swift, Verse.swift, TafsirContent.swift)
   ├── Views/ (SurahListView, VerseDetailView, CommentaryView)
   ├── ViewModels/ (SurahViewModel, TafsirViewModel)
   ├── Services/ (APIService, CacheManager, QuranService)
   └── Utilities/ (Constants, Extensions)
   ```

## Design System

The app uses a modern iOS design system with:
- Primary colors: Blue (#007AFF), Secondary Gray (#8E8E93)
- Modern gradients and typography
- Following Apple Human Interface Guidelines
- SwiftUI-native components and animations

## Key Technologies

- **Swift 5.0+** with SwiftUI
- **Core Data** for local caching
- **URLSession** for API communication
- **UserDefaults** for settings and preferences
- Target: iOS 18.2+ (iPhone and iPad)

## API Backend

The app now includes a complete API backend deployed on Vercel:

### API Endpoints
- **Base URL**: `https://thaqalyn-api.vercel.app/api/v1/`
- **Surahs**: `GET /surahs` - Returns all 114 Quran chapters
- **Verses**: `GET /verses/[surah]` - Returns verses for specific surah (integrates AlQuran.cloud API)  
- **Tafsir**: `POST /tafsir/generate` - Generates AI commentary using OpenAI/Anthropic APIs

### API Configuration
- **Runtime**: Node.js 18.x on Vercel
- **External APIs**: AlQuran.cloud for verse data, OpenAI for commentary generation
- **Error Handling**: Returns "Not Available" messages when APIs fail (no sample data fallback)
- **CORS**: Configured for iOS app communication

## Current Status

## 🔄 **MAJOR ARCHITECTURE TRANSITION - August 2025**

### **New Direction: Self-Contained Static Data Architecture**

**Decision Made**: Remove all APIs and embed complete Quran text + AI-generated commentary directly in iOS app bundle.

**Rationale**: Since Quran text and commentary content will never change, a static data approach provides:
- ✅ Zero network dependencies and deployment complexity
- ✅ Instant loading with perfect offline experience
- ✅ No ongoing API costs or infrastructure maintenance  
- ✅ Reliable, consistent user experience always
- ✅ Simplified development workflow and testing

### **Current Phase: Data Collection & Generation** 

**✅ Completed Infrastructure:**
1. **Complete iOS App Structure**: Modern SwiftUI design with full navigation
2. **Design System**: ThaqalynDesignSystem with modern iOS components  
3. **Core Data**: Local caching infrastructure ready for static data
4. **Build System**: App builds and runs successfully on iOS Simulator
5. **Data Generation Scripts**: Complete infrastructure for dataset creation

**🔄 In Progress - Data Collection:**
- ✅ **Generation Scripts Built**: Complete Node.js infrastructure for dataset creation
- ✅ **Test Dataset Working**: Al-Fatihah commentary generation verified with OpenAI API
- ✅ **4-Layer Commentary System**: Foundation, Classical Shia, Contemporary, Ahlul Bayt
- 🔄 **Full Dataset Generation**: Ready to generate ~25,000 commentary entries for all verses

**📋 Next Phase - iOS Integration:**
- [ ] Generate complete commentary dataset (~7 hours, $50-100 cost)
- [ ] Remove APIService and all network code from iOS app
- [ ] Create LocalDataService to load from bundled JSON files
- [ ] Update all views (SurahListView, VerseListView, CommentaryView) for local data
- [ ] Optimize performance for large embedded dataset (50-100MB)
- [ ] Test complete offline functionality

**📱 Current App Capabilities:**
- ✅ Modern SwiftUI interface with Apple HIG compliance
- ✅ Complete navigation structure and UI components
- ✅ Four-layer commentary display system
- ✅ Core Data integration ready for local data
- ✅ Error handling and loading states (will be simplified for static data)

**🎯 Current Priority:**
**Primary Goal**: Generate complete AI commentary dataset for all 6,200+ Quranic verses using OpenAI API, then integrate static data files into iOS app to eliminate all network dependencies.

**Status**: Successfully tested data generation process. Ready to generate full dataset and transition to self-contained app architecture.