# Thaqalyn - Product Requirements Document (PRD) v2.1

## Executive Summary

**Product Name**: Thaqalyn (ثقلين - The Two Weighty Things)  
**Product Type**: iOS mobile app for Shia Islamic Quranic commentary  
**Core Innovation**: AI-generated layered tafsir system with modern iOS design  
**Target Launch**: MVP in 3-4 months from development start  
**Primary Market**: English-speaking Shia Muslims  

## Product Vision

Create the world's most comprehensive and accessible Shia Quranic commentary platform using AI-generated tafsir with a beautiful modern iOS interface.

## Core Value Proposition

- **Complete Coverage**: Every verse of the Quran with 4 layers of Shia-specific commentary
- **Instant Access**: AI-generated content available on-demand with intelligent caching
- **Modern Design**: Clean, contemporary iOS interface following Apple Human Interface Guidelines
- **Scholarly Depth**: From basic understanding to advanced Ahlul Bayt teachings
- **Premium Experience**: Smooth animations, intuitive navigation, and sophisticated UI
- **Advanced Technology**: LLM-powered with cost-effective, scalable architecture

## User Personas

### Primary Persona: Scholarly Student (60% of users)
- **Demographics**: Age 25-45, college-educated, practicing Shia Muslim
- **Needs**: Deep understanding of Quranic verses with Shia perspective
- **Pain Points**: Limited access to quality Shia tafsir in English
- **Goals**: Daily Quran study with authentic Shia commentary

### Secondary Persona: Community Leader (25% of users)  
- **Demographics**: Age 35-55, religious community role (imam, teacher)
- **Needs**: Reliable source for preparing lectures and answering questions
- **Pain Points**: Time-consuming research across multiple sources
- **Goals**: Quick access to comprehensive commentary for teaching

### Tertiary Persona: Curious Learner (15% of users)
- **Demographics**: Age 18-35, exploring Islamic knowledge
- **Needs**: Accessible introduction to Shia Islamic thought
- **Pain Points**: Overwhelming complexity of traditional texts
- **Goals**: Gradual learning with adjustable depth

## Development Phases

### Phase 1 (MVP) - 3-4 months
**No Backend Infrastructure - Standalone iOS App**

#### Core Features (MVP)

##### 1. LLM-Powered Tafsir Generation (Stateless)
**Technical Specs**:
```javascript
// Simple stateless API endpoint
POST /api/v1/tafsir/generate
{
  "surah": 1,
  "ayah": 1, 
  "layer": 1-4
}

// Response format
{
  "content": "Generated commentary text",
  "sources": ["tabatabai", "contemporary"],
  "generated_at": "2024-01-01T12:00:00Z",
  "confidence_score": 0.85
}
```

**MVP Approach**:
- All 4 layers available for free during MVP
- No user authentication required
- Pure stateless API calls
- Aggressive local caching using Core Data

##### 2. Four-Layer Commentary System
**Layer 1 - Foundation (🏛️)**:
- Simple modern language explanation
- Historical context (Asbab al-Nuzul)
- Basic Arabic word meanings
- Contemporary relevance

**Layer 2 - Classical Shia Commentary (📚)**:
- Tabatabai (al-Mizan) perspective
- Tabrisi (Majma al-Bayan) insights  
- Traditional Shia scholarly consensus
- Historical Shia interpretations

**Layer 3 - Contemporary Insights (🌍)**:
- Modern Shia scholars (Makarem Shirazi, etc.)
- Scientific correlations and modern applications
- Social justice themes
- Interfaith dialogue perspectives

**Layer 4 - Ahlul Bayt Wisdom (⭐)**:
- Relevant hadith from 14 Infallibles
- Unique Shia theological concepts (Wilayah, Imamah)
- Spiritual and mystical dimensions
- Practical applications in Shia practice

##### 3. Local-Only Features
- **Local Bookmarks**: Store in Core Data (no sync)
- **Reading History**: Track locally using UserDefaults
- **Offline Access**: All cached content available offline
- **Settings**: Theme preference, font size (UserDefaults)

##### 4. Modern iOS Design System
```swift
struct ThaqalynDesignSystem {
    // Colors
    static let primaryBlue = Color(hex: "007AFF")
    static let secondaryGray = Color(hex: "8E8E93")
    static let backgroundGray = Color(hex: "F2F2F7")
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "007AFF"), Color(hex: "5856D6")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Typography
    static let largeTitleFont = Font.system(size: 34, weight: .bold)
    static let titleFont = Font.system(size: 28, weight: .semibold)
    static let bodyFont = Font.system(size: 17, weight: .regular)
}
```

#### MVP Technical Stack
```yaml
Frontend Only:
- Language: Swift 5.9+
- UI Framework: SwiftUI
- Local Storage: Core Data + UserDefaults
- Networking: URLSession
- No Authentication Required
- No Backend Database
- No Payment Processing
```

#### MVP API (Minimal Stateless)
```javascript
// Deployed on Vercel free tier
const express = require('express');
const app = express();

// Only 2 endpoints needed for MVP
app.get('/api/v1/surahs', (req, res) => {
  // Return static surah list
});

app.post('/api/v1/tafsir/generate', async (req, res) => {
  const { surah, ayah, layer } = req.body;
  // Call LLM and return commentary
  // No user tracking, no database
});
```

### Phase 2 (Enhanced Features) - 3 months
**Add Backend Infrastructure with Supabase**

#### New Features
1. **User Authentication**
   - Email/password signup
   - Apple Sign In
   - User profiles

2. **Cloud Sync**
   - Bookmark synchronization
   - Reading history across devices
   - User preferences sync

3. **Monetization**
   - Premium subscriptions
   - Payment processing
   - Layer access control (Layers 3-4 become premium)

4. **Search Functionality**
   - Full-text search
   - Search history
   - Advanced filters

5. **Audio Integration**
   - Quran recitation
   - Synchronized highlighting
   - Multiple reciters

#### Supabase Schema (Phase 2)
```sql
-- Users table (handled by Supabase Auth)

-- User profiles
CREATE TABLE profiles (
  id UUID REFERENCES auth.users PRIMARY KEY,
  username TEXT UNIQUE,
  full_name TEXT,
  subscription_tier TEXT DEFAULT 'free',
  subscription_expires_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Bookmarks
CREATE TABLE bookmarks (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  surah INTEGER NOT NULL,
  ayah INTEGER NOT NULL,
  note TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Reading history
CREATE TABLE reading_history (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  surah INTEGER NOT NULL,
  ayah INTEGER NOT NULL,
  layer INTEGER NOT NULL,
  read_at TIMESTAMP DEFAULT NOW()
);

-- Search cache (for performance)
CREATE TABLE search_cache (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  query TEXT NOT NULL,
  results JSONB NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Phase 3 (Advanced Platform) - 4 months

#### Features
- Community features (notes, discussions)
- Advanced analytics dashboard
- iPad-optimized interface
- Web companion app
- Public API for developers
- Multiple language support for UI (content remains English)

## MVP Implementation Plan

### Month 1: Core Infrastructure
- [ ] Setup Xcode project with SwiftUI
- [ ] Implement modern design system
- [ ] Create Core Data models for caching
- [ ] Build basic navigation structure

### Month 2: LLM Integration
- [ ] Setup minimal Node.js API on Vercel
- [ ] Integrate OpenAI/Anthropic APIs
- [ ] Implement caching layer
- [ ] Build verse display UI

### Month 3: Features & Polish
- [ ] Local bookmarks functionality
- [ ] Offline support
- [ ] Settings and preferences
- [ ] UI animations and transitions

### Month 4: Testing & Launch
- [ ] Beta testing
- [ ] Performance optimization
- [ ] App Store preparation
- [ ] Launch marketing

## Monetization Strategy

### MVP Phase (Free)
- All features free
- No authentication required
- Gather user feedback
- Build user base

### Phase 2 Freemium Model
**Free Tier**:
- Layers 1 & 2 (Foundation + Classical)
- 20 cloud bookmarks
- Basic sync

**Premium Tier** ($4.99/month):
- All 4 layers
- Unlimited bookmarks
- Full sync
- Priority support

## Success Metrics

### MVP Metrics
- [ ] Downloads: 1,000+ in first month
- [ ] Daily Active Users: 30% of downloads
- [ ] Session duration: 10+ minutes
- [ ] App Store rating: 4.5+ stars
- [ ] Crash rate: <1%

### Phase 2 Metrics
- [ ] User registration: 50% of active users
- [ ] Premium conversion: 20-25%
- [ ] Monthly churn: <10%
- [ ] Revenue: $5K MRR within 3 months

## Technical Architecture (MVP)

### iOS App Structure
```
Thaqalyn/
├── App/
│   ├── ThaqalynApp.swift
│   └── ContentView.swift
├── Models/
│   ├── Surah.swift
│   ├── Verse.swift
│   ├── TafsirContent.swift
│   └── CoreData/
│       └── TafsirCache.xcdatamodeld
├── Views/
│   ├── SurahListView.swift
│   ├── VerseDetailView.swift
│   ├── CommentaryView.swift
│   └── Components/
│       ├── ModernCard.swift
│       ├── LayerSelector.swift
│       └── LoadingView.swift
├── ViewModels/
│   ├── SurahViewModel.swift
│   └── TafsirViewModel.swift
├── Services/
│   ├── APIService.swift
│   ├── CacheManager.swift
│   └── QuranService.swift
└── Utilities/
    ├── Constants.swift
    └── Extensions.swift
```

### Core Data Models (MVP)
```swift
// Tafsir Cache Entity
entity TafsirCache {
  surah: Integer
  ayah: Integer  
  layer: Integer
  content: String
  generatedAt: Date
  arabicText: String
  translation: String
}

// Bookmark Entity (local only)
entity LocalBookmark {
  id: UUID
  surah: Integer
  ayah: Integer
  note: String?
  createdAt: Date
}
```

### API Service (MVP)
```swift
class APIService {
    static let shared = APIService()
    private let baseURL = "https://thaqalyn-api.vercel.app/api/v1"
    
    func generateTafsir(surah: Int, ayah: Int, layer: Int) async throws -> TafsirContent {
        let url = URL(string: "\(baseURL)/tafsir/generate")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "surah": surah,
            "ayah": ayah,
            "layer": layer
        ]
        request.httpBody = try JSONEncoder().encode(body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return try JSONDecoder().decode(TafsirContent.self, from: data)
    }
}
```

## Cost Analysis

### MVP Costs (Monthly)
- **Vercel**: Free tier (serverless functions)
- **LLM API**: ~$50-100 (with caching)
- **Apple Developer**: $99/year ($8.25/month)
- **Total**: ~$60-110/month

### Phase 2 Costs (Monthly)
- **Supabase**: $25 (Pro tier)
- **Vercel**: $20 (Pro tier) 
- **LLM API**: ~$200-500 (more users)
- **Total**: ~$250-550/month

## Risk Mitigation

### MVP Risks
- **LLM costs**: Aggressive caching, rate limiting
- **App Store rejection**: Follow guidelines carefully
- **User adoption**: Beta test with target community

### Scaling Risks
- **Backend complexity**: Gradual migration to Supabase
- **Cost management**: Monitor usage, optimize caching
- **Feature creep**: Stick to MVP scope

## Key Decisions

1. **No Backend in MVP**: Reduces complexity and cost
2. **All Layers Free in MVP**: Maximize user testing
3. **iOS Only**: Focus on quality over platforms
4. **Modern Design**: Appeal to younger users
5. **Stateless Architecture**: Simplify MVP development

## Next Steps

1. **Validate LLM prompts** with Islamic scholars
2. **Design mockups** for key screens
3. **Setup development environment**
4. **Begin MVP development**
5. **Recruit beta testers** from target community

---

*This PRD is a living document and will be updated as the project evolves.*