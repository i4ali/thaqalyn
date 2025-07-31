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

## Current Status

The project is in initial setup phase with basic SwiftUI app structure. The current ContentView shows a placeholder "Hello, world!" interface that needs to be replaced with the actual Quran commentary interface according to the PRD specifications.