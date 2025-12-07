# Meditation Feature Research & Design Proposal

## Executive Summary

This document proposes a **"Sakina" (سَكِينَة)** meditation feature for the Thaqalayn app - named after the Quranic concept of divine tranquility. The feature authentically integrates Islamic spiritual practices (muraqaba, dhikr, tafakkur, muhasaba) with modern mindfulness UX patterns, leveraging the app's existing infrastructure (audio, progress tracking, themes).

---

## Part 1: Islamic Meditation Concepts

### Core Practices to Implement

| Practice | Arabic | Description | Implementation |
|----------|--------|-------------|----------------|
| **Muraqaba** | مُراقَبَة | Vigilant awareness of Allah | Guided meditation sessions |
| **Dhikr** | ذِکر | Remembrance through repetition | Digital tasbih counter |
| **Tafakkur** | تَفَکُّر | Contemplation of creation/Quran | Verse reflection sessions |
| **Muhasaba** | مُحاسَبَة | Self-accounting/reflection | Journaling with prompts |
| **Du'a** | دُعاء | Supplication | Guided prayer sessions |
| **Tasbih** | تَسبِیح | Glorification counting | Bead counter with presets |

### Shia-Specific Content Sources

1. **Sahifa Sajjadiyya** - 54 supplications by Imam Zain al-Abidin (a.s.)
   - Known as "Psalms of Islam"
   - Ranked behind only Quran and Nahj al-Balagha
   - Rich contemplative content perfect for meditation

2. **Mafatih al-Jinan** - Collection of daily/special duas

3. **Munajat** (Whispered Prayers) - 15 intimate conversations with Allah

4. **Ahlul Bayt Teachings** - Wisdom from the 14 Infallibles on inner peace

---

## Part 2: Feature Architecture

### Proposed Structure

```
Sakina (Meditation Tab)
├── 🧘 Guided Sessions
│   ├── Muraqaba (Awareness Meditation)
│   ├── Breathing + Dhikr
│   ├── Morning Intentions
│   └── Evening Reflection
├── 📿 Dhikr Counter
│   ├── Quick Tasbih (33-33-34)
│   ├── Custom Dhikr
│   └── Dhikr History
├── 📖 Tafakkur (Contemplation)
│   ├── Verse of the Day Reflection
│   ├── Thematic Contemplations
│   └── Nature Contemplation
├── 🤲 Du'a Sessions
│   ├── Sahifa Sajjadiyya (54 duas)
│   ├── Daily Duas
│   └── Munajat Collection
├── 📝 Muhasaba (Journal)
│   ├── Daily Reflection
│   ├── Gratitude Log
│   └── Self-Improvement Goals
└── 📊 Progress & Stats
    ├── Meditation Streak
    ├── Total Dhikr Count
    └── Meditation Minutes
```

### Integration with Existing Features

| Existing Feature | Integration Point |
|------------------|-------------------|
| **AudioManager** | Ambient sounds, guided audio, du'a recitation |
| **ProgressManager** | Meditation streaks, badges, sawab tracking |
| **ThemeManager** | Sakina-specific calming variants |
| **BookmarkManager** | Save favorite meditations/duas |
| **NotificationManager** | Meditation reminders, dhikr alerts |
| **Quran Verses** | Deep link to verses for tafakkur |

---

## Part 3: Wireframes

### 3.1 Main Sakina Tab (Entry Point)

```
┌─────────────────────────────────────┐
│ ◀ Home          Sakina          ⚙️  │
├─────────────────────────────────────┤
│                                     │
│    ╭─────────────────────────────╮  │
│    │  ☪️  Assalamu Alaykum       │  │
│    │                             │  │
│    │  "Verily, in the           │  │
│    │   remembrance of Allah     │  │
│    │   do hearts find rest"     │  │
│    │           — Quran 13:28    │  │
│    │                             │  │
│    │  🔥 5-day streak           │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    Quick Actions                    │
│    ┌─────────┐ ┌─────────┐         │
│    │   📿    │ │   🧘    │         │
│    │  Dhikr  │ │ Breathe │         │
│    │  (2m)   │ │  (5m)   │         │
│    └─────────┘ └─────────┘         │
│    ┌─────────┐ ┌─────────┐         │
│    │   🤲    │ │   📖    │         │
│    │  Du'a   │ │ Reflect │         │
│    │  (3m)   │ │  (5m)   │         │
│    └─────────┘ └─────────┘         │
│                                     │
│    Today's Recommendation           │
│    ╭─────────────────────────────╮  │
│    │ 🌅 Morning Muraqaba        →│  │
│    │ Start your day with         │  │
│    │ awareness of Allah          │  │
│    │ 10 min • Beginner           │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    Browse Categories                │
│    ╭──────╮ ╭──────╮ ╭──────╮      │
│    │Guided│ │Dhikr │ │ Du'a │      │
│    ╰──────╯ ╰──────╯ ╰──────╯      │
│    ╭──────╮ ╭──────╮ ╭──────╮      │
│    │Quran │ │Journal│ │Stats │      │
│    ╰──────╯ ╰──────╯ ╰──────╯      │
│                                     │
└─────────────────────────────────────┘
```

### 3.2 Dhikr Counter Screen

```
┌─────────────────────────────────────┐
│ ◀ Back      Digital Tasbih      ⚙️  │
├─────────────────────────────────────┤
│                                     │
│           Current Dhikr             │
│    ╭─────────────────────────────╮  │
│    │                             │  │
│    │    سُبْحَانَ ٱللَّٰهِ          │  │
│    │    SubhanAllah              │  │
│    │    "Glory be to Allah"      │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│                                     │
│           ╭───────────╮             │
│           │           │             │
│           │           │             │
│           │    23     │             │
│           │   / 33    │             │
│           │           │             │
│           ╰───────────╯             │
│              TAP HERE               │
│           (or anywhere)             │
│                                     │
│    Progress: ████████░░ 23/33       │
│                                     │
│    ┌─────────────────────────────┐  │
│    │ ◀ Prev │ Reset │ Next ▶    │  │
│    └─────────────────────────────┘  │
│                                     │
│    Today's Sequence                 │
│    ╭─────╮  ╭─────╮  ╭─────╮       │
│    │ 33  │→ │ 33  │→ │ 34  │       │
│    │سبحان│  │الحمد│  │الله │       │
│    │ ✓   │  │ ●   │  │     │       │
│    ╰─────╯  ╰─────╯  ╰─────╯       │
│                                     │
│    Total Today: 89 dhikr           │
│    All Time: 12,847 dhikr          │
│                                     │
└─────────────────────────────────────┘
```

### 3.3 Guided Meditation Session

```
┌─────────────────────────────────────┐
│ ✕ Close                        🔊   │
├─────────────────────────────────────┤
│                                     │
│                                     │
│           ╭───────────╮             │
│          ╱             ╲            │
│         │   ◐ ◐ ◐ ◐    │           │
│         │   Breathing   │           │
│         │               │           │
│          ╲             ╱            │
│           ╰───────────╯             │
│                                     │
│            BREATHE IN               │
│                                     │
│    ╭─────────────────────────────╮  │
│    │                             │  │
│    │   "With every breath,      │  │
│    │    remember Allah is       │  │
│    │    closer to you than      │  │
│    │    your jugular vein"      │  │
│    │                             │  │
│    │         — Quran 50:16      │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    ━━━━━━━━━●━━━━━━━━━━━━━━━━━━━    │
│    2:34              7:00           │
│                                     │
│    ┌─────────────────────────────┐  │
│    │   ⏮   │   ⏸️   │   ⏭    │  │
│    └─────────────────────────────┘  │
│                                     │
│    🔔 Gentle chime at end           │
│                                     │
└─────────────────────────────────────┘
```

### 3.4 Du'a Session (Sahifa Sajjadiyya)

```
┌─────────────────────────────────────┐
│ ◀ Back    Sahifa Sajjadiyya    🔖   │
├─────────────────────────────────────┤
│                                     │
│    Search duas...              🔍   │
│                                     │
│    ╭─────────────────────────────╮  │
│    │ 📜 Featured                 │  │
│    │                             │  │
│    │ Du'a #1: Praising Allah    │  │
│    │ "His Supplication in       │  │
│    │  Praising God"             │  │
│    │ 5 min • Audio available 🔊 │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    Categories                       │
│    ╭───────────────────────────╮    │
│    │ 🌙 Daily Prayers      (12)│    │
│    ╰───────────────────────────╯    │
│    ╭───────────────────────────╮    │
│    │ 🤲 Seeking Forgiveness (8)│    │
│    ╰───────────────────────────╯    │
│    ╭───────────────────────────╮    │
│    │ 💪 Strength & Guidance (9)│    │
│    ╰───────────────────────────╯    │
│    ╭───────────────────────────╮    │
│    │ ❤️ Gratitude & Love    (7)│    │
│    ╰───────────────────────────╯    │
│    ╭───────────────────────────╮    │
│    │ 🌟 Special Occasions  (18)│    │
│    ╰───────────────────────────╯    │
│                                     │
│    All 54 Supplications         →   │
│                                     │
└─────────────────────────────────────┘
```

### 3.5 Du'a Reading View

```
┌─────────────────────────────────────┐
│ ◀      Du'a for Morning      🔖 📤 │
├─────────────────────────────────────┤
│                                     │
│    Du'a #6 from Sahifa Sajjadiyya   │
│    His Supplication at Morning      │
│                                     │
│    ╭─────────────────────────────╮  │
│    │                             │  │
│    │  اَللّٰهُمَّ يَا مَنْ دَلَعَ    │  │
│    │  لِسَانَ الصَّبَاحِ بِنُطْقِ    │  │
│    │  تَبَلُّجِهِ                  │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    O Allah, O He who extended       │
│    the morning's tongue in the      │
│    speech of its dawning...         │
│                                     │
│    ────────────────────────────     │
│                                     │
│    📖 Commentary                    │
│    This supplication teaches us     │
│    to begin each day with...        │
│                             [more]  │
│                                     │
│    🔗 Related Verses                │
│    • Quran 17:78 - Fajr prayer     │
│    • Quran 113:1 - Lord of dawn    │
│                                     │
│    ━━━━━━━━━━━━●━━━━━━━━━━━━━━━━    │
│    0:45                  3:22       │
│                                     │
│    ┌─────────────────────────────┐  │
│    │ 0.75x │  ▶️ Play  │ 1.25x │  │
│    └─────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### 3.6 Tafakkur (Contemplation) Session

```
┌─────────────────────────────────────┐
│ ✕                           ⏱️ 5:00 │
├─────────────────────────────────────┤
│                                     │
│            TAFAKKUR                 │
│         Contemplation               │
│                                     │
│    ╭─────────────────────────────╮  │
│    │                             │  │
│    │  أَفَلَا يَنظُرُونَ إِلَى      │  │
│    │  ٱلْإِبِلِ كَيْفَ خُلِقَتْ      │  │
│    │                             │  │
│    │  "Do they not look at the  │  │
│    │   camels - how they are    │  │
│    │   created?"                │  │
│    │                             │  │
│    │         — Quran 88:17      │  │
│    │                             │  │
│    │        [View Full Tafsir]  │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    Contemplation Prompts            │
│                                     │
│    ╭─────────────────────────────╮  │
│    │ 🌿 Reflect on Allah's      │  │
│    │    design in nature...     │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    ╭─────────────────────────────╮  │
│    │ 💭 What signs of Allah     │  │
│    │    have you witnessed      │  │
│    │    today?                  │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    ╭─────────────────────────────╮  │
│    │ 📝 Write your reflection   │  │
│    │                            │  │
│    │ __________________________ │  │
│    │ __________________________ │  │
│    │                            │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    [Continue to Next Verse →]       │
│                                     │
└─────────────────────────────────────┘
```

### 3.7 Muhasaba (Self-Reflection Journal)

```
┌─────────────────────────────────────┐
│ ◀ Back       Muhasaba          📊   │
├─────────────────────────────────────┤
│                                     │
│    Evening Self-Accounting          │
│    Saturday, December 7, 2025       │
│                                     │
│    ╭─────────────────────────────╮  │
│    │ 💭 Imam Ali (a.s.) said:   │  │
│    │                             │  │
│    │ "Account yourself before   │  │
│    │  you are accounted"        │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    Today's Reflection               │
│                                     │
│    1. What good did I do today?     │
│    ╭─────────────────────────────╮  │
│    │                             │  │
│    │ __________________________ │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    2. Where could I improve?        │
│    ╭─────────────────────────────╮  │
│    │                             │  │
│    │ __________________________ │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    3. What am I grateful for?       │
│    ╭─────────────────────────────╮  │
│    │                             │  │
│    │ __________________________ │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    Quick Mood Check                 │
│    😔  😐  🙂  😊  🤩               │
│                                     │
│    [Save Reflection]                │
│                                     │
│    Past Entries →                   │
│                                     │
└─────────────────────────────────────┘
```

### 3.8 Meditation Stats Dashboard

```
┌─────────────────────────────────────┐
│ ◀ Back     Sakina Stats        📤   │
├─────────────────────────────────────┤
│                                     │
│    Your Spiritual Journey           │
│                                     │
│    ╭─────────────────────────────╮  │
│    │       🔥 15-Day Streak      │  │
│    │         Keep going!         │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    This Week                        │
│    ┌────┬────┬────┬────┬────┬────┐  │
│    │ M  │ T  │ W  │ Th │ F  │ S  │  │
│    │ ✓  │ ✓  │ ✓  │ ✓  │ ✓  │ ●  │  │
│    └────┴────┴────┴────┴────┴────┘  │
│                                     │
│    ╭───────────╮  ╭───────────╮     │
│    │   127     │  │   45      │     │
│    │   mins    │  │   mins    │     │
│    │  (total)  │  │ (this wk) │     │
│    ╰───────────╯  ╰───────────╯     │
│                                     │
│    ╭───────────╮  ╭───────────╮     │
│    │  12,847   │  │    54     │     │
│    │   dhikr   │  │   duas    │     │
│    │ (all time)│  │(completed)│     │
│    ╰───────────╯  ╰───────────╯     │
│                                     │
│    Badges Earned                    │
│    ╭──────╮ ╭──────╮ ╭──────╮      │
│    │ 📿   │ │ 🧘   │ │ 🌙   │      │
│    │Dhakir│ │Muraqib│ │Night │      │
│    │1000  │ │ 10    │ │Worshp│      │
│    ╰──────╯ ╰──────╯ ╰──────╯      │
│                                     │
│    Favorite Practices               │
│    1. SubhanAllah Tasbih   (45%)   │
│    2. Morning Muraqaba     (25%)   │
│    3. Sahifa Du'a #1       (15%)   │
│                                     │
└─────────────────────────────────────┘
```

### 3.9 Session Complete Screen

```
┌─────────────────────────────────────┐
│                                     │
│                                     │
│                                     │
│             ☪️ ✨                    │
│                                     │
│         Session Complete            │
│                                     │
│    ╭─────────────────────────────╮  │
│    │                             │  │
│    │     7 minutes of           │  │
│    │     divine remembrance     │  │
│    │                             │  │
│    │     +70 sawab earned       │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    ╭─────────────────────────────╮  │
│    │ 🏆 Badge Unlocked!          │  │
│    │                             │  │
│    │     "Dhakir"               │  │
│    │  1000 dhikr completed      │  │
│    │                             │  │
│    │  "Those who remember       │  │
│    │   Allah standing, sitting, │  │
│    │   and lying on their       │  │
│    │   sides..." — 3:191        │  │
│    │                             │  │
│    ╰─────────────────────────────╯  │
│                                     │
│    How do you feel?                 │
│    😌  🙏  💚  ✨  🤲               │
│                                     │
│    ┌─────────────────────────────┐  │
│    │        Return Home          │  │
│    └─────────────────────────────┘  │
│                                     │
│    Share with a friend  📤          │
│                                     │
└─────────────────────────────────────┘
```

---

## Part 4: Technical Implementation

### 4.1 New Service Architecture

```swift
// MeditationManager.swift
@MainActor
class MeditationManager: ObservableObject {
    static let shared = MeditationManager()

    // State
    @Published var currentSession: MeditationSession?
    @Published var dhikrCount: Int = 0
    @Published var meditationStreak: Int = 0
    @Published var totalMinutes: Int = 0
    @Published var totalDhikr: Int = 0

    // Sessions
    func startMuraqaba(duration: Int, theme: MuraqabaTheme)
    func startDhikr(type: DhikrType, targetCount: Int)
    func startDuaSession(dua: SahifaDua)
    func startTafakkur(verse: Verse)

    // Progress
    func completeSession()
    func incrementDhikr()
    func saveReflection(_ text: String)
}

// DhikrManager.swift
@MainActor
class DhikrManager: ObservableObject {
    static let shared = DhikrManager()

    @Published var currentDhikr: DhikrType = .subhanAllah
    @Published var count: Int = 0
    @Published var target: Int = 33
    @Published var hapticEnabled: Bool = true
    @Published var soundEnabled: Bool = true

    func increment()
    func reset()
    func nextInSequence()
}
```

### 4.2 Data Models

```swift
// MeditationModels.swift

enum MeditationType {
    case muraqaba      // Guided awareness
    case dhikr         // Remembrance counting
    case tafakkur      // Verse contemplation
    case dua           // Supplication session
    case muhasaba      // Self-reflection
    case breathing     // Breath focus
}

struct MeditationSession: Codable, Identifiable {
    let id: UUID
    let type: MeditationType
    let startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var dhikrCount: Int?
    var reflection: String?
    var mood: MoodRating?
}

enum DhikrType: String, CaseIterable, Codable {
    case subhanAllah = "سُبْحَانَ ٱللَّٰهِ"
    case alhamdulillah = "ٱلْحَمْدُ لِلَّٰهِ"
    case allahuAkbar = "ٱللَّٰهُ أَكْبَرُ"
    case laIlahaIllallah = "لَا إِلَٰهَ إِلَّا ٱللَّٰهُ"
    case astaghfirullah = "أَسْتَغْفِرُ ٱللَّٰهَ"
    case salawat = "اللَّهُمَّ صَلِّ عَلَىٰ مُحَمَّدٍ وَآلِ مُحَمَّدٍ"
    case custom

    var englishTranslation: String { ... }
    var defaultCount: Int { ... }
}

struct SahifaDua: Codable, Identifiable {
    let id: Int                    // 1-54
    let arabicTitle: String
    let englishTitle: String
    let arabicText: String
    let englishTranslation: String
    let urduTranslation: String?
    let audioURL: String?
    let duration: TimeInterval?
    let category: DuaCategory
    let relatedVerses: [VerseReference]
}

struct MuhasabaEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let goodDeeds: String
    let improvements: String
    let gratitude: String
    let mood: MoodRating
    var syncStatus: SyncStatus
}

enum MoodRating: Int, Codable {
    case struggling = 1
    case neutral = 2
    case okay = 3
    case good = 4
    case excellent = 5
}
```

### 4.3 Database Schema (Supabase)

```sql
-- Meditation sessions table
CREATE TABLE meditation_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    type TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ,
    duration_seconds INTEGER,
    dhikr_count INTEGER,
    dua_id INTEGER,
    verse_key TEXT,
    reflection TEXT,
    mood INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Dhikr totals table
CREATE TABLE dhikr_totals (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    dhikr_type TEXT NOT NULL,
    total_count BIGINT DEFAULT 0,
    last_session TIMESTAMPTZ,
    UNIQUE(user_id, dhikr_type)
);

-- Muhasaba entries table
CREATE TABLE muhasaba_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    good_deeds TEXT,
    improvements TEXT,
    gratitude TEXT,
    mood INTEGER,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(user_id, date)
);

-- RLS Policies (same pattern as bookmarks)
ALTER TABLE meditation_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE dhikr_totals ENABLE ROW LEVEL SECURITY;
ALTER TABLE muhasaba_entries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own data" ON meditation_sessions
    FOR ALL USING (auth.uid() = user_id);
-- ... similar for other tables
```

### 4.4 File Structure

```
Thaqalayn/
├── Models/
│   └── MeditationModels.swift      # NEW: All meditation data models
├── Services/
│   ├── MeditationManager.swift     # NEW: Session management
│   ├── DhikrManager.swift          # NEW: Tasbih counter logic
│   └── MuhasabaManager.swift       # NEW: Journal management
├── Views/
│   ├── Sakina/                     # NEW: Meditation feature views
│   │   ├── SakinaTabView.swift     # Main entry point
│   │   ├── DhikrCounterView.swift  # Tasbih counter
│   │   ├── GuidedSessionView.swift # Muraqaba sessions
│   │   ├── DuaListView.swift       # Sahifa Sajjadiyya
│   │   ├── DuaDetailView.swift     # Individual dua
│   │   ├── TafakkurView.swift      # Contemplation
│   │   ├── MuhasabaView.swift      # Journal
│   │   └── MeditationStatsView.swift
└── Data/
    ├── sahifa_sajjadiyya.json      # NEW: 54 duas
    ├── dhikr_collection.json       # NEW: Dhikr definitions
    └── guided_sessions.json        # NEW: Session scripts
```

---

## Part 5: UX Considerations

### Design Principles

1. **Authenticity First**
   - Use proper Arabic typography
   - Include scholarly sources
   - Connect every feature to Quranic verses
   - Reference Ahlul Bayt teachings

2. **Calming Visuals**
   - Soft, muted color palette
   - Rounded corners (20px+)
   - Generous white space
   - Gentle animations (no jarring transitions)
   - Floating gradient backgrounds (existing pattern)

3. **Haptic Feedback**
   - Light tap for dhikr counting
   - Medium pulse at milestones (33, 66, 99)
   - Gentle vibration for session completion

4. **Audio Integration**
   - Optional ambient sounds (rain, nature, silence)
   - Dua recitation with adjustable speed
   - Soft notification chimes
   - Volume fade for session end

5. **Accessibility**
   - Large touch targets for dhikr (tap anywhere)
   - Screen reader support
   - High contrast mode option
   - Adjustable text sizes

### User Flows

```
New User Flow:
1. Discover Sakina tab → 2. See welcome card with benefits
3. Try quick 2-min dhikr → 4. Experience haptic feedback
5. Complete first session → 6. See sawab earned + encouragement
7. Get reminder notification → 8. Build streak

Returning User Flow:
1. Open app → 2. See streak reminder in header
3. Quick dhikr or recommended session → 4. Complete
5. View progress dashboard → 6. Set reminder for tomorrow
```

---

## Part 6: Content Requirements

### Sahifa Sajjadiyya Data

Need JSON files containing:
- All 54 supplications in Arabic
- English translations (William Chittick translation recommended)
- Urdu translations
- Category tags
- Audio recordings (if available)
- Related Quranic verses

### Guided Session Scripts

Need scripts for:
- Morning Muraqaba (5, 10, 15 min versions)
- Evening Reflection
- Breathing + Dhikr
- Pre-prayer centering
- Stress relief session
- Sleep preparation

### Contemplation Content

Need:
- 30+ Quranic verses about nature/creation
- Reflection prompts for each
- Deep links to existing tafsir

---

## Part 7: Recommended MVP Scope

### Phase 1: Core Features (MVP)
1. ✅ Dhikr Counter with haptics
2. ✅ Basic 3-5 guided sessions
3. ✅ Sahifa Sajjadiyya (text only, 10 key duas)
4. ✅ Simple streak tracking
5. ✅ Basic stats dashboard

### Phase 2: Enhanced Experience
1. 📖 Full 54 Sahifa Sajjadiyya with audio
2. 🧘 More guided sessions (15+)
3. 📝 Muhasaba journal
4. 🔔 Smart reminders
5. ☁️ Cloud sync

### Phase 3: Advanced Features
1. 🤖 AI-personalized recommendations
2. 👥 Community challenges
3. 📊 Advanced analytics
4. 🎵 Custom ambient sounds
5. ⌚ Apple Watch app

---

## Sources & References

### Islamic Meditation Concepts
- [Muraqaba App - Muslim Mindfulness](https://www.muraqaba.app/)
- [Muraqabah - Wikipedia](https://en.wikipedia.org/wiki/Muraqabah)
- [Sufi Meditation at Nur Muhammad](https://nurmuhammad.com/sufi-meditation/)
- [Academic Research on Islamic Mindfulness Apps](https://cupola.gettysburg.edu/cgi/viewcontent.cgi?article=1052&context=relfac)

### Sahifa Sajjadiyya
- [Al-Sahifa Al-Kamilah Al-Sajjadiyya | Al-Islam.org](https://al-islam.org/sahifa-al-kamilah-al-sajjadiyya-imam-ali-zayn-al-abidin)
- [Sahifa Sajjadia at Duas.org](https://www.duas.org/mobile/sahifa-sajjadia-index.html)

### App Design Inspiration
- [Meditation App Wireframe Template - Visily](https://www.visily.ai/templates/meditation-app-wireframe/)
- [Top Meditation App UI Design Examples](https://blog.designpeeps.net/blog/meditation-app-ui-design-examples/)
- [Purrweb Meditation App Design Guide](https://www.purrweb.com/blog/designing-a-meditation-app-tips-step-by-step-guide/)

### Tasbih Counter Apps
- [Dynamologic Tasbih App Case Study](https://www.dynamologic.com/portfolio/tasbih-app/)
- [Tasbih Counter Lite on App Store](https://apps.apple.com/us/app/tasbih-counter-lite-dhikr-app/id1501329079)

---

## Conclusion

The **Sakina** meditation feature will position Thaqalayn as a comprehensive Islamic spiritual companion, not just a Quran reader. By integrating authentic Shia practices (Sahifa Sajjadiyya, Ahlul Bayt teachings) with modern mindfulness UX patterns, the app can serve Muslims seeking both knowledge and spiritual growth.

The feature naturally extends the app's existing infrastructure (audio, progress tracking, themes) while adding significant new value. Starting with a focused MVP (dhikr counter + basic sessions) allows quick validation before expanding.
