# Discovery Carousel Implementation Plan
## Life Moments + Questions & Answers

**Version**: 1.0
**Date**: 2025-11-16
**Status**: Planning Phase

---

## Table of Contents
1. [Overview](#overview)
2. [Visual Design](#visual-design)
3. [Feature Specifications](#feature-specifications)
4. [Implementation Phases](#implementation-phases)
5. [File Structure](#file-structure)
6. [Data Schema](#data-schema)
7. [Success Criteria](#success-criteria)

---

## Overview

### Goal
Replace the single Life Moments card on the home screen with a horizontal auto-scrolling carousel that features:
1. **Life Moments** (existing feature, adapted for carousel)
2. **Questions & Answers** (new feature)

### Benefits
- **65% vertical space savings** (680px → 240px)
- **Automatic feature discovery** through auto-scroll
- **Modern UX** familiar from Instagram, App Store, etc.
- **Scalable** for future discovery features
- **User-controlled** with pause on interaction

---

## Visual Design

### Home Screen - Carousel State 1 (Life Moments)
```
┌─────────────────────────────────────────────────┐
│  🌙 Thaqalayn                                   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     │
│  🔍 [Search surahs, verses...]                  │
│                                                 │
│  ╔════════════════════════════════════╗         │
│ ◀║ 🌸                                 ║▶        │
│  ║ Life Moments                       ║         │
│  ║ ━━━━━━━━━━━━━━━━━━━━━━━━━━━       ║         │
│  ║ Find solace in divine words for    ║         │
│  ║ any situation                      ║         │
│  ║                                    ║         │
│  ║ 💭 "You are sad"                   ║         │
│  ║ 💭 "You need patience"             ║         │
│  ║ 💭 "You seek forgiveness"          ║         │
│  ║                                    ║         │
│  ║ [Tap to explore →]                 ║         │
│  ╚════════════════════════════════════╝         │
│           ● ○                                   │
│      (1 of 2 features)                          │
│                                                 │
│  ┌────────── Recently Read ──────────           │
│  │ 📖 Al-Fatiha                                 │
│  └──────────────────────────────────            │
└─────────────────────────────────────────────────┘
```

### Home Screen - Carousel State 2 (Questions & Answers)
```
┌─────────────────────────────────────────────────┐
│  🌙 Thaqalayn                                   │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━     │
│  🔍 [Search surahs, verses...]                  │
│                                                 │
│  ╔════════════════════════════════════╗         │
│ ◀║ ❓                                 ║▶        │
│  ║ Questions & Answers                ║         │
│  ║ ━━━━━━━━━━━━━━━━━━━━━━━━━━━       ║         │
│  ║ Find Quranic answers to life's     ║         │
│  ║ biggest questions                  ║         │
│  ║                                    ║         │
│  ║ 💭 "What is life's purpose?"       ║         │
│  ║ 💭 "Can God forgive any sin?"      ║         │
│  ║ 💭 "Why do we suffer?"             ║         │
│  ║                                    ║         │
│  ║ [Tap to explore →]                 ║         │
│  ╚════════════════════════════════════╝         │
│           ○ ●                                   │
│      (2 of 2 features)                          │
│                                                 │
│  ┌────────── Recently Read ──────────           │
│  │ 📖 Al-Fatiha                                 │
│  └──────────────────────────────────            │
└─────────────────────────────────────────────────┘
```

### Auto-Scroll Behavior Timeline
```
Time:  0s    4s    8s    12s   16s   20s (loop)
       │     │     │     │     │     │
Page:  1 ────┤ 2 ──┤ 1 ──┤ 2 ──┤ 1 ──┤ 2...
       │     │     │     │     │     │
       Life  Q&A   Life  Q&A   Life  Q&A
       Moments     Moments     Moments

User Interactions:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
• Swipe/drag → Pauses auto-scroll
• Tap card → Navigates to feature
• Resume → Auto-scroll continues after 10s pause
```

### Questions View - Full Screen List
```
┌─────────────────────────────────────────────────┐
│ ← Back        Questions & Answers               │
│   Find Quranic guidance for life's questions    │
├─────────────────────────────────────────────────┤
│                                                 │
│ 🔍 [Search questions...]                        │
│                                                 │
│ ┌─ Filter by Category ─────────────────────┐   │
│ │ [All] [Faith] [Justice] [Ethics] [More▼] │   │
│ └───────────────────────────────────────────┘   │
│                                                 │
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│ ┃  🌟 FAITH & BELIEF                       ┃   │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                                 │
│ ┌─────────────────────────────────────────┐   │
│ │ 🤔 What is the purpose of life?         │   │
│ │    Answered in 3 verses            →    │   │
│ │    📍 Quran 51:56 • 67:2 • 2:30         │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ ┌─────────────────────────────────────────┐   │
│ │ 💫 Can God forgive any sin?             │   │
│ │    Answered in 2 verses            →    │   │
│ │    📍 Quran 39:53 • 4:48                │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓   │
│ ┃  ⚖️ JUSTICE & SUFFERING                  ┃   │
│ ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛   │
│                                                 │
│ ┌─────────────────────────────────────────┐   │
│ │ 😢 Why do bad things happen to          │   │
│ │    good people?                         │   │
│ │    Answered in 4 verses            →    │   │
│ │    📍 Quran 2:155-157 • 29:2 • 3:142    │   │
│ └─────────────────────────────────────────┘   │
│                                                 │
│ ⋮ (scroll for more)                            │
└─────────────────────────────────────────────────┘
```

### Question Detail View
```
┌─────────────────────────────────────────────────┐
│ ← Questions    What is the purpose of life?     │
├─────────────────────────────────────────────────┤
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │         💭 THE QUESTION                  │  │
│  │  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━   │  │
│  │                                          │  │
│  │  What is the purpose of life?            │  │
│  │  Why did God create us?                  │  │
│  │                                          │  │
│  │  Category: Faith & Belief                │  │
│  │  Related: Why worship? →                 │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓  │
│  ┃  Verse 1 of 3                          ┃  │
│  ┃  Surah Adh-Dhariyat (51:56)            ┃  │
│  ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛  │
│  ┌──────────────────────────────────────────┐  │
│  │  وَمَا خَلَقْتُ ٱلْجِنَّ وَٱلْإِنسَ      │  │
│  │         إِلَّا لِيَعْبُدُونِ             │  │
│  │                                          │  │
│  │  "And I did not create the jinn and     │  │
│  │  mankind except to worship Me."          │  │
│  │                                          │  │
│  │  ┌─ 📚 Why This Answers ───────────┐    │  │
│  │  │ This verse directly states the   │    │  │
│  │  │ purpose: to worship and know     │    │  │
│  │  │ Allah. Worship here means        │    │  │
│  │  │ complete submission and          │    │  │
│  │  │ recognition of the Creator.      │    │  │
│  │  └──────────────────────────────────┘    │  │
│  │                                          │  │
│  │  🔊 [Play Audio]  📖 [Read Full Tafsir] │  │
│  │  🔖 [Bookmark]    📤 [Share]             │  │
│  └──────────────────────────────────────────┘  │
│                                                 │
│  ⋮ (Verses 2 & 3 follow)                       │
│                                                 │
│  ┌──────────────────────────────────────────┐  │
│  │      🔗 RELATED QUESTIONS                │  │
│  │  • Does God need our worship? →          │  │
│  │  • What happens after death? →           │  │
│  └──────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

### Navigation Flow
```
                    ┌─────────────────┐
                    │   ContentView   │
                    │   (Home Screen) │
                    └────────┬────────┘
                             │
                    ┌────────┴────────┐
                    │                 │
    [Tap Life      │                 │ [Tap Q&A Card]
     Moments Card] ▼                 ▼
         ┌──────────────────┐  ┌─────────────────┐
         │ LifeMomentsView  │  │  QuestionsView  │
         │   (existing)     │  │    (new)        │
         └──────────────────┘  └────────┬────────┘
                                        │
                                        │ [Tap Question]
                                        ▼
                                ┌────────────────────┐
                                │ QuestionDetailView │
                                │      (new)         │
                                └────────┬───────────┘
                                         │
                                         │ [Tap Verse]
                                         ▼
                                ┌────────────────────┐
                                │ SurahDetailView    │
                                │ (existing, with    │
                                │  targetVerse)      │
                                └────────────────────┘
```

---

## Feature Specifications

### Carousel Specifications
- **Card Height**: 220px
- **Auto-scroll Interval**: 4 seconds
- **Animation Duration**: 0.5 seconds ease-in-out
- **Pause Duration**: 10 seconds after user interaction
- **Number of Cards**: 2 (Life Moments, Q&A)
- **Gesture Support**: Swipe/drag to navigate manually
- **Page Indicators**: Circular dots (● ○)

### Questions & Answers Feature Specifications

#### Question Categories (6 total)
1. **Faith & Belief** 🌟 (`star.fill`)
   - Purpose of life, forgiveness, worship, faith strengthening
   - ~8 questions

2. **Justice & Suffering** ⚖️ (`scale.3d`)
   - Why bad things happen, suffering, fairness, accountability
   - ~7 questions

3. **Ethics & Morality** 💚 (`heart.circle.fill`)
   - How to treat others, right/wrong, anger, charity, forgiveness
   - ~8 questions

4. **Death & Afterlife** 🌙 (`moon.stars.fill`)
   - What happens after death, judgment, paradise, hell
   - ~6 questions

5. **Relationships** 👥 (`person.2.fill`)
   - Parents, marriage, children, friends, relatives
   - ~6 questions

6. **Interfaith** 🌍 (`globe.americas.fill`)
   - Islam's view of other faiths, religious diversity
   - ~5 questions

**Total**: 30-40 curated questions

#### Question Structure
Each question includes:
- **Question text**: "What is the purpose of life?"
- **Category**: Faith & Belief
- **Multiple verse answers**: 2-4 verses per question
- **Relevance notes**: Explains why each verse answers the question
- **Related questions**: Links to similar questions
- **Primary flag**: Marks most important verses

#### Example Questions by Category

**Faith & Belief**:
- What is the purpose of life?
- Can God forgive any sin?
- Does God need our worship?
- Why did God create us?
- How can I strengthen my faith?
- What is true worship?
- Does God hear my prayers?
- How do I get closer to God?

**Justice & Suffering**:
- Why do bad things happen to good people?
- Why is there suffering in the world?
- Is life fair?
- Why do children suffer?
- Where is God when I'm hurting?
- Will wrongdoers be held accountable?
- What about innocent victims?

**Ethics & Morality**:
- How should I treat others?
- What makes something right or wrong?
- Can I lie to save someone?
- How do I control my anger?
- What is true charity?
- Should I forgive those who hurt me?
- How do I avoid backbiting?
- What is true humility?

**Death & Afterlife**:
- What happens after we die?
- Is there really a Day of Judgment?
- What is Paradise like?
- Who goes to Hell?
- Will families reunite in Paradise?
- What happens in the grave?

**Relationships**:
- How should I treat my parents?
- What are the rights of spouses?
- How do I raise righteous children?
- What makes a good friend?
- How do I deal with difficult relatives?
- What is a blessed marriage?

**Interfaith**:
- What does Islam say about other faiths?
- Are Christians and Jews believers?
- Can people of other faiths be good?
- Why are there different religions?
- How should Muslims treat non-Muslims?

---

## Implementation Phases

### Phase 1: Questions & Answers Foundation (4-5 hours)

#### 1.1 Create Data Models (30 min)
**File**: `Thaqalayn/Models/QuranModels.swift`

Add to existing file:
```swift
// MARK: - Questions & Answers Models

struct Question: Identifiable, Codable {
    let id: String
    let question: String
    let shortQuestion: String?
    let category: QuestionCategory
    let verses: [QuestionVerse]
    let relatedQuestions: [String]

    var categoryIcon: String {
        category.icon
    }

    var verseCount: Int {
        verses.count
    }
}

struct QuestionVerse: Codable {
    let surahNumber: Int
    let verseNumber: Int
    let relevanceNote: String
    let isPrimary: Bool

    var verseReference: String {
        "Quran \(surahNumber):\(verseNumber)"
    }
}

enum QuestionCategory: String, Codable, CaseIterable {
    case faith = "faith"
    case justice = "justice"
    case ethics = "ethics"
    case afterlife = "afterlife"
    case relationships = "relationships"
    case interfaith = "interfaith"

    var displayName: String {
        switch self {
        case .faith: return "Faith & Belief"
        case .justice: return "Justice & Suffering"
        case .ethics: return "Ethics & Morality"
        case .afterlife: return "Death & Afterlife"
        case .relationships: return "Relationships"
        case .interfaith: return "Interfaith"
        }
    }

    var icon: String {
        switch self {
        case .faith: return "star.fill"
        case .justice: return "scale.3d"
        case .ethics: return "heart.circle.fill"
        case .afterlife: return "moon.stars.fill"
        case .relationships: return "person.2.fill"
        case .interfaith: return "globe.americas.fill"
        }
    }
}
```

#### 1.2 Create Questions Manager (45 min)
**File**: `Thaqalayn/Services/QuestionsManager.swift`

```swift
import Foundation
import Combine

class QuestionsManager: ObservableObject {
    static let shared = QuestionsManager()

    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadQuestions()
    }

    func loadQuestions() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            errorMessage = "Failed to load questions data"
            isLoading = false
            return
        }

        do {
            let decoder = JSONDecoder()
            let questionsData = try decoder.decode(QuestionsData.self, from: data)
            self.questions = questionsData.questions
            isLoading = false
        } catch {
            errorMessage = "Failed to parse questions: \(error.localizedDescription)"
            isLoading = false
        }
    }

    func questions(for category: QuestionCategory) -> [Question] {
        questions.filter { $0.category == category }
    }

    func search(query: String) -> [Question] {
        guard !query.isEmpty else { return questions }
        let lowercased = query.lowercased()
        return questions.filter {
            $0.question.lowercased().contains(lowercased)
        }
    }

    var categories: [QuestionCategory] {
        QuestionCategory.allCases
    }
}

struct QuestionsData: Codable {
    let questions: [Question]
}
```

#### 1.3 Create Questions Data JSON (2 hours)
**File**: `Thaqalayn/Data/questions.json`

Curate 30-40 questions with verse mappings. See [Data Schema](#data-schema) section below.

#### 1.4 Create Questions List View (1 hour)
**File**: `Thaqalayn/Views/QuestionsView.swift`

Full-screen view with:
- Search bar
- Category filter chips
- Grouped questions by category
- Navigation to QuestionDetailView

#### 1.5 Create Question Detail View (1 hour)
**File**: `Thaqalayn/Views/QuestionDetailView.swift`

Shows:
- Question context
- All verse answers with relevance notes
- Navigation to SurahDetailView
- Related questions

#### 1.6 Create Question Card Component (30 min)
**File**: `Thaqalayn/Views/Components/QuestionCard.swift`

Reusable card for question display in lists.

### Phase 2: Discovery Carousel Implementation (2-3 hours)

#### 2.1 Create Carousel Container (1 hour)
**File**: `Thaqalayn/Views/Components/DiscoveryCarousel.swift`

```swift
struct DiscoveryCarousel: View {
    @State private var currentPage = 0
    @State private var autoScrollTimer: Timer?
    @State private var pauseAutoScroll = false
    @State private var showLifeMoments = false
    @State private var showQuestions = false

    var body: some View {
        VStack(spacing: 12) {
            // Carousel
            TabView(selection: $currentPage) {
                LifeMomentsCarouselCard(showFullView: $showLifeMoments)
                    .tag(0)

                QuestionsCarouselCard(showFullView: $showQuestions)
                    .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 220)
            .gesture(
                DragGesture()
                    .onChanged { _ in
                        pauseAutoScroll = true
                    }
            )

            // Page indicators
            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .fill(currentPage == index ?
                              Color.accentColor : Color.gray.opacity(0.3))
                        .frame(width: 8, height: 8)
                        .animation(.easeInOut, value: currentPage)
                }
            }
        }
        .onAppear { startAutoScroll() }
        .onDisappear { stopAutoScroll() }
        .onChange(of: pauseAutoScroll) { paused in
            if paused {
                stopAutoScroll()
                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                    pauseAutoScroll = false
                    startAutoScroll()
                }
            }
        }
        .fullScreenCover(isPresented: $showLifeMoments) {
            LifeMomentsView()
        }
        .fullScreenCover(isPresented: $showQuestions) {
            QuestionsView()
        }
    }

    private func startAutoScroll() {
        autoScrollTimer = Timer.scheduledTimer(withTimeInterval: 4.0,
                                                repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentPage = (currentPage + 1) % 2
            }
        }
    }

    private func stopAutoScroll() {
        autoScrollTimer?.invalidate()
        autoScrollTimer = nil
    }
}
```

#### 2.2 Create Life Moments Carousel Card (45 min)
**File**: `Thaqalayn/Views/Components/LifeMomentsCarouselCard.swift`

Compact preview version that links to existing LifeMomentsView.

#### 2.3 Create Q&A Carousel Card (45 min)
**File**: `Thaqalayn/Views/Components/QuestionsCarouselCard.swift`

Preview with 3 sample questions that links to QuestionsView.

#### 2.4 Integrate Carousel into ContentView (30 min)
**File**: `Thaqalayn/Views/ContentView.swift`

Replace existing Life Moments card with DiscoveryCarousel component.

### Phase 3: Polish & Testing (1-2 hours)

#### 3.1 Theme Adaptation (30 min)
- Test all 4 themes: Modern Dark, Modern Light, Traditional Manuscript, Sepia
- Ensure colors, gradients, glassmorphism adapt correctly

#### 3.2 Navigation Testing (30 min)
- Test full navigation flow
- Verify targetVerse highlighting
- Test back navigation

#### 3.3 Auto-Scroll Behavior (30 min)
- Verify timing
- Test pause/resume
- Verify smooth animations

#### 3.4 Accessibility (30 min)
- Add VoiceOver labels
- Test haptic feedback
- Verify contrast

---

## File Structure

```
Thaqalayn/
├── Models/
│   └── QuranModels.swift
│       └── ADD: Question, QuestionVerse, QuestionCategory
│
├── Services/
│   └── QuestionsManager.swift (NEW)
│
├── Views/
│   ├── ContentView.swift
│   │   └── MODIFY: Replace Life Moments card with DiscoveryCarousel
│   │
│   ├── QuestionsView.swift (NEW)
│   │   └── Full-screen questions list with search and filtering
│   │
│   ├── QuestionDetailView.swift (NEW)
│   │   └── Individual question with verse answers
│   │
│   └── Components/
│       ├── DiscoveryCarousel.swift (NEW)
│       │   └── Horizontal auto-scrolling carousel container
│       │
│       ├── LifeMomentsCarouselCard.swift (NEW)
│       │   └── Compact Life Moments preview card
│       │
│       ├── QuestionsCarouselCard.swift (NEW)
│       │   └── Compact Q&A preview card
│       │
│       └── QuestionCard.swift (NEW)
│           └── Reusable question card component
│
└── Data/
    └── questions.json (NEW)
        └── 30-40 curated questions with verse mappings
```

### Files Modified
1. `Thaqalayn/Models/QuranModels.swift` - Add Q&A models
2. `Thaqalayn/Views/ContentView.swift` - Integrate carousel
3. `Thaqalayn.xcodeproj/project.pbxproj` - Add new files to project

### Files Created (7 new files)
1. `Thaqalayn/Services/QuestionsManager.swift`
2. `Thaqalayn/Views/QuestionsView.swift`
3. `Thaqalayn/Views/QuestionDetailView.swift`
4. `Thaqalayn/Views/Components/DiscoveryCarousel.swift`
5. `Thaqalayn/Views/Components/LifeMomentsCarouselCard.swift`
6. `Thaqalayn/Views/Components/QuestionsCarouselCard.swift`
7. `Thaqalayn/Views/Components/QuestionCard.swift`
8. `Thaqalayn/Data/questions.json`

---

## Data Schema

### questions.json Structure

```json
{
  "questions": [
    {
      "id": "q1",
      "question": "What is the purpose of life?",
      "shortQuestion": "Life's purpose?",
      "category": "faith",
      "verses": [
        {
          "surahNumber": 51,
          "verseNumber": 56,
          "relevanceNote": "This verse directly states the purpose: to worship and know Allah. Worship here means complete submission and recognition of the Creator.",
          "isPrimary": true
        },
        {
          "surahNumber": 67,
          "verseNumber": 2,
          "relevanceNote": "Life is a test - we are placed here to demonstrate righteous action. The purpose includes moral growth and spiritual development.",
          "isPrimary": true
        },
        {
          "surahNumber": 2,
          "verseNumber": 30,
          "relevanceNote": "Humanity's role as khalifah (vicegerent) on earth - to establish justice and goodness.",
          "isPrimary": false
        }
      ],
      "relatedQuestions": ["q2", "q7"]
    },
    {
      "id": "q2",
      "question": "Can God forgive any sin?",
      "shortQuestion": "Divine forgiveness?",
      "category": "faith",
      "verses": [
        {
          "surahNumber": 39,
          "verseNumber": 53,
          "relevanceNote": "Allah's mercy is infinite - despair not! This verse emphasizes that no sin is too great for Allah's forgiveness if one sincerely repents.",
          "isPrimary": true
        },
        {
          "surahNumber": 4,
          "verseNumber": 48,
          "relevanceNote": "Exception: shirk (associating partners with Allah) if one dies in that state. But even shirk can be forgiven if one repents before death.",
          "isPrimary": true
        }
      ],
      "relatedQuestions": ["q1", "q15"]
    },
    {
      "id": "q3",
      "question": "Why do bad things happen to good people?",
      "shortQuestion": "Why suffering?",
      "category": "justice",
      "verses": [
        {
          "surahNumber": 2,
          "verseNumber": 155,
          "relevanceNote": "Trials test faith and purify souls. Hardship is not punishment but a means of spiritual growth and elevation.",
          "isPrimary": true
        },
        {
          "surahNumber": 2,
          "verseNumber": 156,
          "relevanceNote": "Patient perseverance in trials leads to divine blessings and closeness to Allah.",
          "isPrimary": true
        },
        {
          "surahNumber": 2,
          "verseNumber": 157,
          "relevanceNote": "Those who remain steadfast receive guidance and mercy from their Lord.",
          "isPrimary": true
        },
        {
          "surahNumber": 29,
          "verseNumber": 2,
          "relevanceNote": "Testing is how Allah distinguishes truth from falsehood in hearts - it's not about earning Paradise through ease.",
          "isPrimary": false
        }
      ],
      "relatedQuestions": ["q4", "q5"]
    }
  ]
}
```

### Sample Data for All Categories

**Total questions needed**: 30-40 across 6 categories

**Distribution**:
- Faith & Belief: 8 questions
- Justice & Suffering: 7 questions
- Ethics & Morality: 8 questions
- Death & Afterlife: 6 questions
- Relationships: 6 questions
- Interfaith: 5 questions

Each question should have:
- 2-4 verse answers
- At least 1 verse marked as `isPrimary: true`
- Meaningful relevance notes (2-3 sentences)
- 1-3 related questions

---

## Success Criteria

### Carousel Functionality
✅ Carousel auto-scrolls between Life Moments and Q&A every 4 seconds
✅ User can swipe manually to browse cards
✅ Auto-scroll pauses when user interacts (swipe/drag)
✅ Auto-scroll resumes 10 seconds after last interaction
✅ Smooth animations with 0.5s ease-in-out duration
✅ Page indicators (● ○) accurately reflect current page
✅ Carousel is responsive and works on all iPhone sizes

### Life Moments Integration
✅ Life Moments card displays in carousel format
✅ Shows 3 example moments in preview
✅ Tapping card opens existing LifeMomentsView
✅ Maintains all existing Life Moments functionality

### Questions & Answers Feature
✅ QuestionsView displays all 30-40 questions
✅ Questions are grouped by 6 categories
✅ Search functionality filters questions in real-time
✅ Category filter chips work correctly
✅ Tapping question opens QuestionDetailView
✅ QuestionDetailView shows all verse answers with relevance notes
✅ Tapping verse navigates to SurahDetailView with targetVerse highlighted
✅ Related questions are clickable and navigate correctly

### Theme Adaptation
✅ All components work in Modern Dark theme
✅ All components work in Modern Light theme
✅ All components work in Traditional Manuscript theme
✅ All components work in Sepia theme
✅ Colors, gradients, and glassmorphism effects adapt correctly

### Navigation
✅ ContentView → LifeMomentsView (existing flow preserved)
✅ ContentView → QuestionsView → QuestionDetailView → SurahDetailView
✅ Back navigation works correctly at all levels
✅ Deep linking with targetVerse highlighting works

### User Experience
✅ 65% vertical space savings vs. stacked cards
✅ Carousel height is 220px (matches design spec)
✅ All tap targets are at least 44x44 points
✅ Smooth, performant animations at 60fps
✅ No layout shifts or jank during auto-scroll
✅ Clear visual hierarchy and readability

### Accessibility
✅ VoiceOver announces "Page 1 of 2: Life Moments"
✅ VoiceOver announces "Page 2 of 2: Questions and Answers"
✅ All interactive elements have proper labels
✅ Haptic feedback on page change (optional)
✅ Readable contrast ratios in all themes (WCAG AA)

### Data & Performance
✅ questions.json loads successfully
✅ QuestionsManager singleton initializes correctly
✅ All 30-40 questions parse without errors
✅ Search performs well with no lag
✅ No memory leaks from Timer in carousel
✅ App bundle size increase < 500KB

### Code Quality
✅ No force unwraps or force casts
✅ Proper error handling in QuestionsManager
✅ Consistent naming conventions
✅ SwiftUI best practices followed
✅ No compiler warnings
✅ Code follows existing Thaqalayn architecture patterns

---

## Implementation Notes

### Carousel Best Practices
1. **Timer Management**: Always invalidate timer in `onDisappear` to prevent memory leaks
2. **Gesture Detection**: Use `DragGesture().onChanged` not `.onEnded` for immediate pause
3. **Animation**: Use `withAnimation` wrapper for smooth page transitions
4. **State Management**: Keep `pauseAutoScroll` state separate from timer existence

### Questions Data Curation Tips
1. **Relevance Notes**: Should be 2-3 sentences explaining verse's connection to question
2. **Primary Verses**: Mark 1-2 verses as primary for "key answers"
3. **Question Phrasing**: Use natural, conversational language users actually ask
4. **Category Balance**: Distribute questions evenly across categories
5. **Verse Selection**: Choose verses with clear, direct answers when possible

### Theme Adaptation Strategy
1. Use `@EnvironmentObject var themeManager: ThemeManager` in all views
2. Reference `themeManager.primaryBackground`, `themeManager.cardBackground`, etc.
3. Test each component individually in all 4 themes before integration
4. Pay special attention to text contrast on glassmorphism backgrounds

### Navigation Pattern
Follow existing Thaqalayn pattern:
```swift
NavigationLink(
    destination: SurahDetailView(
        surahWithTafsir: surahData,
        targetVerse: verseNumber
    ),
    isActive: $navigateToVerse
) { EmptyView() }
```

---

## Estimated Effort

**Total Time**: 7-10 hours

**Breakdown**:
- Phase 1 (Q&A Foundation): 4-5 hours
  - Data models: 30 min
  - Manager: 45 min
  - JSON curation: 2 hours
  - Views: 2 hours

- Phase 2 (Carousel): 2-3 hours
  - Carousel container: 1 hour
  - Card components: 1.5 hours
  - Integration: 30 min

- Phase 3 (Polish): 1-2 hours
  - Theme testing: 30 min
  - Navigation testing: 30 min
  - Auto-scroll testing: 30 min
  - Accessibility: 30 min

---

## Future Enhancements (Post-Launch)

Once the 2-card carousel is stable, consider:

1. **Add Card 3: Daily Reflection**
   - Verse of the day with rotating themes
   - Push notifications
   - Streak counter

2. **Add Card 4: Quranic Themes**
   - Thematic reading paths
   - Connect verses across surahs
   - Progress tracking

3. **Enhanced Carousel Features**
   - Peek preview (show edges of adjacent cards)
   - Parallax effects
   - Custom page indicator styles

4. **Q&A Enhancements**
   - User-submitted questions
   - Community voting on answers
   - Share question/answer cards
   - Audio narration of answers

---

## Version History

- **v1.0** (2025-11-16): Initial plan document created
  - 2-card carousel with Life Moments + Q&A
  - 30-40 curated questions across 6 categories
  - Auto-scroll with pause on interaction
  - Full integration with existing app architecture

---

## References

### Existing Features to Integrate With
- **Life Moments**: `/Thaqalayn/Views/LifeMomentsView.swift`
- **5-Layer Tafsir**: Foundation, Classical Shia, Contemporary, Ahlul Bayt, Comparative
- **Verse Audio**: Individual verse playback system
- **Theme System**: 4 themes (Modern Dark, Modern Light, Traditional Manuscript, Sepia)
- **Bookmark System**: Offline-first with Supabase sync
- **Navigation**: `SurahDetailView` with `targetVerse` parameter

### Similar Implementations in Codebase
- **LifeMomentsManager**: Pattern for QuestionsManager
- **LifeMomentsView**: Pattern for QuestionsView
- **IslamicGeometricPattern**: Icon design inspiration
- **ContentView**: Integration point for carousel

---

**Document Status**: Ready for Implementation
**Next Steps**: Begin Phase 1 - Create data models and questions.json
