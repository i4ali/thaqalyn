# Phase 1 (MVP) - Task List
**Duration**: 3-4 months  
**Goal**: No Backend Infrastructure - Standalone iOS App

## Overview
Create a standalone iOS app with AI-generated Shia Quranic commentary featuring 4 layers of tafsir, modern SwiftUI design, and local-only features.

## Core Features

### 1. LLM-Powered Tafsir Generation (Stateless)
- [ ] **API Integration**
  - [ ] Design API request/response models
  - [ ] Implement stateless API calls to generate tafsir
  - [ ] Handle API errors and timeouts gracefully
  - [ ] Add retry logic for failed requests

- [ ] **Four-Layer Commentary System**
  - [ ] Layer 1 - Foundation (🏛️): Simple explanations, historical context
  - [ ] Layer 2 - Classical Shia Commentary (📚): Tabatabai, Tabrisi perspectives
  - [ ] Layer 3 - Contemporary Insights (🌍): Modern scholars, scientific correlations
  - [ ] Layer 4 - Ahlul Bayt Wisdom (⭐): Hadith from 14 Infallibles, theological concepts

### 2. iOS App Core Infrastructure

#### Month 1: Core Infrastructure
- [x] **Project Setup**
  - [x] Setup Xcode project with SwiftUI
  - [x] Configure project settings and deployment target (iOS 18.2+)
  - [x] Setup folder structure according to PRD specification
  - [ ] Configure Git workflow and branching strategy

- [x] **Design System Implementation**
  - [x] Create `ThaqalynDesignSystem` with colors, gradients, typography
  - [x] Implement primary blue (#007AFF) and secondary gray (#8E8E93) color scheme
  - [x] Create reusable UI components following Apple HIG
  - [x] Design modern card components and animations

- [x] **Core Data Models**
  - [x] Create `TafsirCache.xcdatamodeld` with entities:
    - [x] TafsirCache entity (surah, ayah, layer, content, generatedAt, arabicText, translation)
    - [x] LocalBookmark entity (id, surah, ayah, note, createdAt)
  - [x] Implement Core Data stack and persistence manager
  - [ ] Add data migration support

- [x] **Basic Navigation Structure**
  - [x] Create main navigation flow
  - [x] Implement tab bar or navigation view structure
  - [ ] Design app launch screen and onboarding flow

#### Month 2: LLM Integration
- [ ] **Backend API (Minimal Stateless)**
  - [ ] Setup Node.js API on Vercel free tier
  - [ ] Implement `/api/v1/surahs` endpoint (static surah list)
  - [ ] Implement `/api/v1/tafsir/generate` endpoint
  - [ ] Integrate OpenAI/Anthropic APIs for commentary generation
  - [ ] Add rate limiting and cost optimization

- [ ] **Caching Layer**
  - [ ] Implement aggressive local caching using Core Data
  - [ ] Create cache invalidation strategy
  - [ ] Add offline-first data access patterns
  - [ ] Optimize cache performance and storage

- [ ] **Verse Display UI**
  - [ ] Create `SurahListView` with modern card design
  - [ ] Implement `VerseDetailView` with Arabic text and translation
  - [ ] Build `CommentaryView` with layered tafsir display
  - [ ] Add loading states and skeleton views

#### Month 3: Features & Polish
- [ ] **Local-Only Features**
  - [ ] **Local Bookmarks**: Core Data storage (no sync)
  - [ ] **Reading History**: UserDefaults tracking
  - [ ] **Offline Access**: All cached content available offline
  - [ ] **Settings**: Theme preference, font size (UserDefaults)

- [ ] **UI Components**
  - [ ] `ModernCard` component with gradients and shadows
  - [ ] `LayerSelector` component for switching between commentary layers
  - [ ] `LoadingView` with modern animations
  - [ ] Search interface (local search only)

- [ ] **ViewModels & Services**
  - [ ] `SurahViewModel` for surah list management
  - [ ] `TafsirViewModel` for commentary loading and caching
  - [ ] `APIService` for network requests
  - [ ] `CacheManager` for Core Data operations
  - [ ] `QuranService` for Quran text and metadata

- [ ] **Animations & Transitions**
  - [ ] Smooth transitions between views
  - [ ] Loading animations and micro-interactions
  - [ ] Gesture-based navigation enhancements

#### Month 4: Testing & Launch
- [ ] **Beta Testing**
  - [ ] Recruit beta testers from target Shia Muslim community
  - [ ] Implement crash reporting and analytics
  - [ ] Gather user feedback and iterate on UI/UX
  - [ ] Test on various iOS devices and screen sizes

- [ ] **Performance Optimization**
  - [ ] Optimize Core Data queries and memory usage
  - [ ] Reduce app launch time and API response times
  - [ ] Implement lazy loading for large content
  - [ ] Battery usage optimization

- [ ] **App Store Preparation**
  - [ ] Create app icons and screenshots
  - [ ] Write App Store description and keywords
  - [ ] Prepare privacy policy and terms of service
  - [ ] Submit for App Store review
  
- [ ] **Launch Marketing**
  - [ ] Create landing page or website
  - [ ] Prepare social media content
  - [ ] Reach out to Islamic communities and influencers
  - [ ] Plan soft launch strategy

## Technical Implementation Details

### Models to Create
- [x] `Surah.swift` - Model for Quran chapters
- [x] `Verse.swift` - Model for individual verses
- [x] `TafsirContent.swift` - Model for commentary content
- [x] Core Data entities as specified in PRD

### Views to Create
- [x] `SurahListView.swift` - List of Quran chapters
- [x] `VerseDetailView.swift` - Individual verse with Arabic text
- [x] `CommentaryView.swift` - Layered commentary display
- [x] Component views: `ModernCard`, `LayerSelector`, `LoadingView`

### Services to Create  
- [ ] `APIService.swift` - Network layer for API calls
- [x] `CacheManager.swift` - Core Data management
- [ ] `QuranService.swift` - Quran text and metadata handling

### Utilities to Create
- [ ] `Constants.swift` - App constants and configuration
- [ ] `Extensions.swift` - Swift extensions for common operations

## Success Criteria (MVP)
- [ ] **Downloads**: 1,000+ in first month
- [ ] **Daily Active Users**: 30% of downloads  
- [ ] **Session Duration**: 10+ minutes average
- [ ] **App Store Rating**: 4.5+ stars
- [ ] **Crash Rate**: <1%
- [ ] **All 4 layers** of commentary working seamlessly
- [ ] **Offline functionality** for cached content
- [ ] **Modern iOS design** following Apple HIG

## Key Constraints
- **No Backend Database**: Pure stateless API approach
- **No User Authentication**: Anonymous usage only
- **No Payment Processing**: All features free during MVP
- **iOS Only**: Focus on single platform excellence
- **Cost Management**: Keep monthly costs under $110