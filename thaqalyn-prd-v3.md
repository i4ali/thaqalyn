# Thaqalyn - Product Requirements Document (PRD) v3.0

## Executive Summary

**Product Name**: Thaqalyn (ثقلين - The Two Weighty Things)  
**Product Type**: iOS mobile app for Shia Islamic Quranic commentary  
**Core Innovation**: Pre-generated AI tafsir with offline-first architecture  
**Target Launch**: MVP in 2-3 months from development start  
**Primary Market**: English-speaking Shia Muslims  

## Product Vision

Create the world's most comprehensive and accessible Shia Quranic commentary platform using pre-generated AI tafsir with a beautiful modern iOS interface and complete offline functionality.

## Core Value Proposition

- **Complete Offline Access**: Entire Quran with 4 layers of commentary available offline
- **Zero API Costs**: All content pre-generated and bundled with app
- **Instant Performance**: No network delays, immediate access to all content
- **Modern Design**: Clean, contemporary iOS interface following Apple Human Interface Guidelines
- **Scholarly Depth**: From basic understanding to advanced Ahlul Bayt teachings
- **Premium Experience**: Smooth animations, intuitive navigation, and sophisticated UI

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

### Phase 0 (Pre-Development) - 2-4 weeks
**Data Generation Phase**

#### Data Generation Scripts

##### 1. Quran Data Script
```python
# fetch_quran_data.py
import requests
import json

def fetch_all_quran_data():
    """Fetch all Quran data from Al-Quran Cloud API"""
    quran_data = {
        "surahs": [],
        "verses": {}
    }
    
    # Fetch all surahs metadata
    # Fetch Arabic text (Uthmani)
    # Fetch English translation (Sahih International)
    # Structure: verses[surah_number][ayah_number] = {...}
    
    # Save to quran_data.json
    with open('quran_data.json', 'w', encoding='utf-8') as f:
        json.dump(quran_data, f, ensure_ascii=False, indent=2)
```

##### 2. Tafsir Generation Script
```python
# generate_tafsir.py
import json
from deepseek import DeepSeekClient

def generate_all_tafsir():
    """Generate tafsir for all verses using DeepSeek LLM"""
    
    # Load Quran data
    with open('quran_data.json', 'r', encoding='utf-8') as f:
        quran_data = json.load(f)
    
    tafsir_data = {}
    
    # For each verse in Quran (6,236 verses)
    for surah in range(1, 115):
        for ayah in get_ayah_count(surah):
            # Generate 4 layers of commentary
            for layer in range(1, 5):
                prompt = build_layer_prompt(surah, ayah, layer)
                commentary = deepseek.generate(prompt)
                
                # Store: tafsir_data[surah][ayah][layer] = commentary
    
    # Save to tafsir_data.json (or split into multiple files)
    save_tafsir_data(tafsir_data)
```

##### 3. Data Structure
```json
// quran_data.json
{
  "surahs": [
    {
      "number": 1,
      "name": "Al-Fatihah",
      "englishName": "The Opening",
      "arabicName": "الفاتحة",
      "versesCount": 7,
      "revelationType": "Meccan"
    }
  ],
  "verses": {
    "1": {
      "1": {
        "arabicText": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
        "translation": "In the name of Allah, the Entirely Merciful, the Especially Merciful",
        "audioUrl": "https://..."
      }
    }
  }
}

// tafsir_data_1.json (split by surah for smaller file sizes)
{
  "1": { // Surah number
    "1": { // Ayah number
      "layer1": "Foundation commentary text...",
      "layer2": "Classical Shia commentary text...",
      "layer3": "Contemporary insights text...",
      "layer4": "Ahlul Bayt wisdom text..."
    }
  }
}
```

### Phase 1 (MVP) - 2-3 months
**Offline-First iOS App**

#### Core Features (MVP)

##### 1. Complete Offline Functionality
- All Quran data bundled with app
- All tafsir commentary pre-loaded
- No internet connection required
- Zero API calls during runtime

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

##### 3. Local Features
- **Local Bookmarks**: Store in Core Data
- **Reading History**: Track locally using Core Data
- **Notes**: Personal notes on verses
- **Settings**: Theme, font size, reading preferences

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
iOS App:
- Language: Swift 5.9+
- UI Framework: SwiftUI
- Local Storage: Core Data + JSON files
- No Networking Required
- No Authentication Required
- No Backend Infrastructure

Data Generation:
- Python scripts
- DeepSeek LLM API
- Al-Quran Cloud API
- One-time generation only
```

#### Data Storage Strategy
```swift
// Bundle JSON files with app
struct DataManager {
    static let shared = DataManager()
    
    private var quranData: QuranData?
    private var tafsirData: [String: [String: TafsirLayers]] = [:]
    
    init() {
        loadQuranData()
        loadTafsirData()
    }
    
    private func loadQuranData() {
        guard let url = Bundle.main.url(forResource: "quran_data", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode(QuranData.self, from: data) else {
            return
        }
        self.quranData = decoded
    }
    
    private func loadTafsirData() {
        // Load tafsir files (possibly split by surah)
        for surahNumber in 1...114 {
            guard let url = Bundle.main.url(forResource: "tafsir_\(surahNumber)", withExtension: "json"),
                  let data = try? Data(contentsOf: url),
                  let decoded = try? JSONDecoder().decode([String: TafsirLayers].self, from: data) else {
                continue
            }
            tafsirData[String(surahNumber)] = decoded
        }
    }
    
    func getVerse(surah: Int, ayah: Int) -> Verse? {
        return quranData?.verses[String(surah)]?[String(ayah)]
    }
    
    func getTafsir(surah: Int, ayah: Int, layer: Int) -> String? {
        return tafsirData[String(surah)]?[String(ayah)]?.getLayer(layer)
    }
}
```

### Phase 2 (Enhanced Features) - 3 months
**Add Cloud Features with Supabase**

#### New Features
1. **User Authentication**
   - Email/password signup
   - Apple Sign In
   - User profiles

2. **Cloud Sync**
   - Bookmark synchronization
   - Reading history across devices
   - Notes synchronization

3. **Search Functionality**
   - Full-text search across all content
   - Search history
   - Advanced filters

4. **Audio Integration**
   - Quran recitation (bundled audio files)
   - Synchronized highlighting
   - Multiple reciters

5. **App Updates**
   - Ability to download updated tafsir content
   - New commentary additions
   - Bug fixes without full app update

### Phase 3 (Advanced Platform) - 4 months

#### Features
- Community features (shared notes, discussions)
- Advanced analytics dashboard
- iPad-optimized interface
- Study plans and reminders
- Widget support
- Apple Watch companion app

## MVP Implementation Plan

### Pre-Development: Data Generation (2-4 weeks)
- [ ] Write and test Quran data fetching script
- [ ] Design DeepSeek prompts for each layer
- [ ] Generate tafsir for all 6,236 verses
- [ ] Validate generated content quality
- [ ] Optimize JSON file structure and size

### Month 1: Core Infrastructure
- [ ] Setup Xcode project with SwiftUI
- [ ] Implement modern design system
- [ ] Create Core Data models
- [ ] Build JSON data loading system
- [ ] Basic navigation structure

### Month 2: Features & UI
- [ ] Surah list view
- [ ] Verse display with Arabic and translation
- [ ] Layer-based commentary view
- [ ] Bookmarks functionality
- [ ] Reading history tracking

### Month 3: Polish & Launch
- [ ] UI animations and transitions
- [ ] Settings and preferences
- [ ] Performance optimization
- [ ] App Store preparation
- [ ] Beta testing

## Monetization Strategy

### MVP Phase (Free with Ads)
- All features free
- Optional banner ads (removable via IAP)
- Tip jar for support

### Phase 2 Premium Features
**Free Tier**:
- All 4 layers
- Local bookmarks
- Basic features

**Premium Tier** ($2.99/month):
- Remove ads
- Cloud sync
- Advanced search
- Priority support
- Early access to new features

## Success Metrics

### MVP Metrics
- [ ] Downloads: 2,000+ in first month
- [ ] Daily Active Users: 40% of downloads
- [ ] Session duration: 15+ minutes
- [ ] App Store rating: 4.6+ stars
- [ ] App size: <150MB

### Phase 2 Metrics
- [ ] Premium conversion: 15-20%
- [ ] Monthly churn: <8%
- [ ] User retention: 50% after 30 days

## Technical Architecture (MVP)

### iOS App Structure
```
Thaqalyn/
├── App/
│   ├── ThaqalynApp.swift
│   └── ContentView.swift
├── Models/
│   ├── QuranModels.swift
│   ├── TafsirModels.swift
│   └── CoreData/
│       └── Thaqalyn.xcdatamodeld
├── Data/
│   ├── JSON/
│   │   ├── quran_data.json
│   │   └── tafsir_*.json
│   └── DataManager.swift
├── Views/
│   ├── SurahListView.swift
│   ├── VerseDetailView.swift
│   ├── CommentaryView.swift
│   └── Components/
├── ViewModels/
│   ├── QuranViewModel.swift
│   └── BookmarkViewModel.swift
└── Utilities/
    ├── Constants.swift
    └── Extensions.swift
```

### Core Data Models (MVP)
```swift
// User data only (all Quran/Tafsir data comes from JSON)
entity Bookmark {
  id: UUID
  surah: Integer
  ayah: Integer
  note: String?
  createdAt: Date
}

entity ReadingHistory {
  id: UUID
  surah: Integer
  ayah: Integer
  readAt: Date
}

entity UserPreferences {
  fontSize: Double
  theme: String
  lastReadSurah: Integer
  lastReadAyah: Integer
}
```

## Cost Analysis

### One-Time Costs
- **DeepSeek API**: ~$50-100 (generating all tafsir)
- **Apple Developer**: $99/year
- **Total Setup**: ~$150-200

### Ongoing Costs (MVP)
- **Apple Developer**: $8.25/month
- **No API costs**: All data bundled
- **No backend costs**: Offline-first
- **Total**: ~$8.25/month

### Phase 2 Costs (Monthly)
- **Supabase**: $25 (Pro tier)
- **Apple Developer**: $8.25
- **Total**: ~$33.25/month

## Risk Mitigation

### MVP Risks
- **App size**: Optimize JSON, consider compression
- **Initial generation quality**: Review samples before full generation
- **App Store size limit**: Stay under 200MB uncompressed

### Content Risks
- **Quality control**: Have scholars review generated content
- **Updates**: Plan for content update mechanism in Phase 2

## Key Advantages of Offline-First Approach

1. **Zero Runtime Costs**: No API calls = no ongoing expenses
2. **Instant Performance**: No network latency
3. **100% Reliability**: Works without internet
4. **Privacy**: No user data sent to servers
5. **Simplified Architecture**: No backend complexity

## Data Generation Estimates

- **Verses**: 6,236 total
- **Layers**: 4 per verse
- **Total Generations**: 24,944 commentary pieces
- **Estimated Time**: 20-40 hours of generation
- **Estimated Cost**: $50-100 (DeepSeek is very affordable)
- **Storage Size**: ~50-100MB JSON (compressible)

## Next Steps

1. **Create data generation scripts**
2. **Test with sample surahs** (1, 36, 67)
3. **Refine prompts** based on quality
4. **Generate complete dataset**
5. **Begin iOS development**

---

*This PRD is a living document and will be updated as the project evolves.*