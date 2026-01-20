# Story-Driven Narrative Onboarding Implementation Plan

## 🎯 Overview
Replace current WelcomeView with an immersive story-driven onboarding that begins with the Hadith of Thaqalayn and flows into app features with emotional resonance.

## 📖 Onboarding Flow (5 Screens)

### Screen 1: The Hadith (Opening)
- **Hadith of Thaqalayn quote** in Arabic with English translation
- Subtle geometric Islamic pattern background
- Beautiful fade-in animation
- Auto-advances after 4 seconds OR tap to continue
- Design: Centered text, elegant typography, reverent atmosphere

### Screen 2: The Mission
- **"This app brings those teachings to your fingertips"**
- Connect hadith meaning to app purpose
- Show app icon with glow effect
- Smooth transition from spiritual to practical
- Design: Clean, inspiring, bridge between tradition and technology

### Screen 3: The 5 Layers of Wisdom
- **Interactive pyramid/stack visualization**
- Each layer slides in with description:
  - 🏛️ Foundation - Simple explanations
  - 📚 Classical Shia - Tabatabai, Tabrisi
  - 🌍 Contemporary - Modern scholars
  - ⭐ Ahlul Bayt - Hadith from 14 Infallibles
  - ⚖️ Comparative - Balanced Shia/Sunni analysis
- Tap each layer for quick preview
- Design: Interactive, educational, highlighting uniqueness

### Screen 4: Daily Spiritual Connection
- **"Your Daily Companion"**
- Show beautiful notification card preview
- Explain Islamic calendar-based verse selection
- Option to enable notifications (with permission priming)
- Show today's verse with theme relevance
- Design: Warm, inviting, showcasing the daily verse feature

### Screen 5: Begin Your Journey
- **Theme selection** (4 beautiful theme cards)
- Interactive previews (tap to see theme)
- Account options:
  - Continue as Guest (primary)
  - Create Account (sync bookmarks)
  - Sign In
- Design: Empowering, choice-focused, ready to explore

## 🎨 Technical Implementation

### New Files to Create:
1. **Views/Onboarding/OnboardingFlowView.swift** - Main coordinator
2. **Views/Onboarding/HadithScreen.swift** - Screen 1
3. **Views/Onboarding/MissionScreen.swift** - Screen 2
4. **Views/Onboarding/FiveLayersScreen.swift** - Screen 3
5. **Views/Onboarding/DailyVerseScreen.swift** - Screen 4
6. **Views/Onboarding/FinalScreen.swift** - Screen 5

### Key Features:
- ✅ SwiftUI TabView with PageTabViewStyle for swipe navigation
- ✅ Page indicators (dots) showing progress
- ✅ Skip button (top-right) on all screens except last
- ✅ Smooth fade/slide transitions between screens
- ✅ Auto-advance on first screen (4s delay)
- ✅ Islamic geometric pattern backgrounds (subtle)
- ✅ Beautiful Arabic typography for Hadith
- ✅ Interactive layer exploration
- ✅ Notification permission priming
- ✅ Live theme preview and selection
- ✅ Persist onboarding completion to UserDefaults

### Design Elements:
- Reuse existing glassmorphism effects
- Use ThemeManager for consistency
- Arabic text with proper RTL support
- Gradient backgrounds with floating orbs
- Smooth animations (0.6s spring animations)
- Cultural respect in design and copy

### Integration:
- Replace WelcomeView in ContentView.swift
- Update first launch detection
- Preload notification preferences
- Preload selected theme
- Seamless transition to main app

## 📝 Copy/Content:

### Hadith of Thaqalayn (Arabic + English):
**Arabic:**
```
إني تارك فيكم الثقلين: كتاب الله وعترتي أهل بيتي، ما إن تمسكتم بهما لن تضلوا بعدي أبداً
```

**English:**
```
"I am leaving among you two weighty things: the Book of Allah and my progeny, the people of my household. As long as you hold fast to them, you shall never go astray."
```

### Mission Statement:
```
This app brings those teachings to your fingertips through authentic Shia scholarship, connecting you with the Quran and the wisdom of the Ahlul Bayt.
```

### Layer Descriptions:
- **Foundation**: Simple explanations and historical context for every verse
- **Classical Shia**: Insights from Tabatabai, Tabrisi, and traditional scholars
- **Contemporary**: Modern perspectives and scientific analysis
- **Ahlul Bayt**: Hadith and spiritual guidance from the 14 Infallibles
- **Comparative**: Balanced scholarly analysis from Shia and Sunni traditions

### Daily Verse Description:
```
Receive verses selected based on the Islamic calendar month, each chosen for its spiritual significance and relevance to the time of year.
```

## 🚀 Outcome
Users will experience:
1. Spiritual connection through authentic Islamic tradition
2. Clear understanding of app's unique 5-layer approach
3. Immediate value with today's verse preview
4. Personalized experience (theme + notifications)
5. Smooth entry into the app with emotional investment
