# Daily Challenge Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (or superpowers:subagent-driven-development) to implement this plan task-by-task.

**Goal:** Add a single, rotating, bite-sized **Daily Challenge** to the Today screen (multiple-choice, true/false, tap-to-flip flashcard, complete-the-ayah) with a daily streak, sawab, and badges — built as a self-contained subsystem.

**Architecture:** A standalone module mirroring the app's existing daily providers. One `DailyChallenge` model (a `format` enum + optional fields covers all four types), a `DailyChallengeProvider` that deterministically picks today's item, a `@MainActor DailyChallengeManager` that owns completion/streak/badge state and awards sawab through the existing accumulator, a `DailyChallengeView` interaction sheet, and a `DailyChallengeCard` on the Today screen (light + Midnight Emerald variants). Content lives in a trilingual `daily_challenges.json`.

**Tech Stack:** Swift, SwiftUI, Combine (`ObservableObject`), UserDefaults (JSON-encoded persistence), Xcode 16 synced folder groups.

**Design doc:** `docs/plans/2026-06-21-daily-challenge-design.md`

---

## Conventions for this plan

**Verification (no XCTest in this project).** The gate for every task is:

```bash
# Build (substitute a booted simulator UDID or device name you have installed)
xcodebuild -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
  build 2>&1 | tail -30
# Expected: "** BUILD SUCCEEDED **"
```

If SourceKit shows "cannot find type in scope" on a *new* file, trust `xcodebuild`, not the editor (stale index — see the project's SourceKit-false-positives note).

Logic that can't be eyeballed (streak transitions) is verified with a **removable `#if DEBUG` self-check** function that `assert`s expected outcomes and is called once from a DEBUG-only `.task {}`/button. UI is verified with **`#if DEBUG` `#Preview`s** and a simulator pass.

**Commits.** The repo owner commits manually — **do not run `git commit`.** Each task ends with a **Checkpoint** (build green + the stated visual/behavioral check); the owner commits at those points.

**Don't fabricate sibling APIs.** Several steps say *"read file X, then mirror its exact API."* Do that — the code blocks here are faithful skeletons, but the precise initializer signatures of `EmCard`/`EmGoldCTA`, the sawab-award call, and `DailyMessageProvider`'s rotation are the source of truth. Match them; do not invent.

**No fallback logic** (project rule): missing/corrupt `daily_challenges.json` must fail loudly, exactly like `DataManager` handles bundle data. The English fallback inside `LocalizedText` is the app's established localization convention, not prohibited fallback logic.

**Text scaling** (project rule): reading content (prompt, options, explanation, flashcard answer, verse/du'a) multiplies font size **and** line spacing by `ReadingSettingsManager.shared.scale`. Chrome (eyebrow, titles, source citation, badges, button labels) stays fixed.

---

## Task 0: Read the siblings you'll mirror

No code. Before writing anything, read these and note their exact patterns:

**Files to read:**
- `Thaqalayn/Services/DailyMessageProvider.swift` — rotation + `refreshIfDayChanged()` pattern.
- `Thaqalayn/Services/DuasManager.swift` — singleton + bundle JSON load pattern.
- `Thaqalayn/Services/ProgressManager.swift` — reading-streak date math; **how sawab is stored/added**; how badges are awarded/persisted.
- `Thaqalayn/Services/QuizManager.swift` — `QuizBadgeType` persistence (`awardedQuizBadges`), `sawabValue`, and the sawab total it feeds.
- `Thaqalayn/Models/QuizModels.swift` — `CommentaryLanguage`, `UnderstandingLevel`, badge enum shape.
- `Thaqalayn/Views/TodayView.swift` — `legacyContent`, `DuaOfTheDayCard`, where managers are declared, scene-phase/refresh hooks.
- `Thaqalayn/Views/EmeraldTodayView.swift` — `EmDuaOfTheDayCard` and the Emerald section layout.
- `Thaqalayn/Utilities/EmeraldComponents.swift` — exact signatures of `EmCard`, `EmGoldCTA`, `EmIconChip`, `EmHeading`, `EmType`, `PressableNavLink`, `EmPressStyle`.
- `Thaqalayn/Services/ReadingSettingsManager.swift` and one consumer (e.g. `SurahDetailView.swift`) — the `* readingSettings.scale` pattern.

**Output:** a short note (in your working memory) recording: the exact sawab-award API, the exact `EmCard`/`EmGoldCTA` initializers, and how `DailyMessageProvider` computes the day index. The rest of the plan assumes you have these.

---

## Task 1: Data models

**Files:**
- Create: `Thaqalayn/Models/DailyChallengeModels.swift`

**Step 1: Write the models.** (`LocalizedText` mirrors the app's parallel-field + English-fallback convention.)

```swift
import Foundation

// MARK: - Format

enum DailyChallengeFormat: String, Codable {
    case multipleChoice
    case trueFalse
    case flashcard
    case fillInBlank
}

// MARK: - Localized text (en authored; ur/ar filled by translator agents; English fallback)

struct LocalizedText: Codable, Hashable {
    let en: String
    let ur: String?
    let ar: String?

    func text(for language: CommentaryLanguage) -> String {
        switch language {
        case .english, .french: return en          // French not authored for this feature → English
        case .urdu:   return (ur?.isEmpty == false ? ur! : en)
        case .arabic: return (ar?.isEmpty == false ? ar! : en)
        }
    }
}

// MARK: - The challenge

struct DailyChallenge: Codable, Identifiable {
    let id: String                       // stable, e.g. "dc_001"
    let format: DailyChallengeFormat
    let topic: String                    // "quran" | "dua" | "ahlulbayt" | "event" | "practice"
    let prompt: LocalizedText            // question / statement / flashcard front / sentence-with-blank
    let options: [LocalizedText]?        // multipleChoice + fillInBlank only
    let correctIndex: Int?               // MC/fill-in → option index; trueFalse → 1=true,0=false; flashcard → nil
    let answer: LocalizedText?           // flashcard back
    let explanation: LocalizedText?      // shown after answering
    let arabicText: String?              // optional verse/du'a, shown verbatim, never translated
    let source: String?                  // optional citation, e.g. "Qur'an 2:255"

    /// True/false convenience. Convention: correctIndex 1 = true, 0 = false.
    var trueFalseAnswer: Bool? {
        guard format == .trueFalse, let i = correctIndex else { return nil }
        return i == 1
    }
}

// MARK: - Completion + streak (persisted)

struct DailyChallengeCompletion: Codable {
    let dayKey: String                   // "yyyy-MM-dd" (user's calendar)
    let challengeId: String
    let format: DailyChallengeFormat
    let wasCorrect: Bool                 // flashcards: true (self-graded "got it") or store user's choice
    let sawabEarned: Int
    let completedAt: Date
}

struct DailyChallengeStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletedDayKey: String? = nil
}

// MARK: - Badges (persisted like QuizBadgeType)

enum DailyChallengeBadge: String, Codable, CaseIterable {
    case firstChallenge = "dc_first"
    case streak7  = "dc_streak_7"
    case streak30 = "dc_streak_30"
    case streak100 = "dc_streak_100"

    var sawabValue: Int {
        switch self {
        case .firstChallenge: return 50
        case .streak7:        return 150
        case .streak30:       return 600
        case .streak100:      return 2500
        }
    }
}
```

**Step 2: Build.** Run the build command. Expected: BUILD SUCCEEDED. (`CommentaryLanguage` already exists in `QuizModels.swift`/`QuranModels.swift`; confirm the case set matches what you used.)

**Checkpoint:** models compile.

---

## Task 2: Dev seed content file

A small seed so the rest of the feature can be built and previewed. The full ~80-item pool is Task 9.

**Files:**
- Create: `Thaqalayn/Data/daily_challenges.json`

**Step 1: Write 8 seed items** — two per format, interleaved, English filled, `ur`/`ar` left `null` (English fallback covers dev). Keep facts well-established and cite sources. Example shape (write all 8; this shows one of each format):

```json
[
  {
    "id": "dc_001",
    "format": "multipleChoice",
    "topic": "quran",
    "prompt": { "en": "How many chapters (surahs) are in the Qur'an?", "ur": null, "ar": null },
    "options": [
      { "en": "100", "ur": null, "ar": null },
      { "en": "114", "ur": null, "ar": null },
      { "en": "120", "ur": null, "ar": null },
      { "en": "99", "ur": null, "ar": null }
    ],
    "correctIndex": 1,
    "answer": null,
    "explanation": { "en": "The Qur'an has 114 surahs, beginning with al-Fātiḥa.", "ur": null, "ar": null },
    "arabicText": null,
    "source": null
  },
  {
    "id": "dc_002",
    "format": "trueFalse",
    "topic": "ahlulbayt",
    "prompt": { "en": "Imam ʿAlī (ʿa) was born inside the Kaʿba.", "ur": null, "ar": null },
    "options": null,
    "correctIndex": 1,
    "answer": null,
    "explanation": { "en": "By well-known reports, Imam ʿAlī (ʿa) was born inside the Holy Kaʿba.", "ur": null, "ar": null },
    "arabicText": null,
    "source": null
  },
  {
    "id": "dc_003",
    "format": "flashcard",
    "topic": "quran",
    "prompt": { "en": "What does “Bismillāhir-Raḥmānir-Raḥīm” mean?", "ur": null, "ar": null },
    "options": null,
    "correctIndex": null,
    "answer": { "en": "In the name of God, the All-Merciful, the Ever-Merciful.", "ur": null, "ar": null },
    "explanation": { "en": "It opens almost every surah and is recited before acts of worship.", "ur": null, "ar": null },
    "arabicText": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ",
    "source": null
  },
  {
    "id": "dc_004",
    "format": "fillInBlank",
    "topic": "quran",
    "prompt": { "en": "“Iyyāka naʿbudu wa iyyāka ____.”", "ur": null, "ar": null },
    "options": [
      { "en": "nastaʿīn (we seek help)", "ur": null, "ar": null },
      { "en": "naḥmadu (we praise)", "ur": null, "ar": null },
      { "en": "nadhkuru (we remember)", "ur": null, "ar": null }
    ],
    "correctIndex": 0,
    "answer": null,
    "explanation": { "en": "Al-Fātiḥa 1:5 — “You alone we worship, and You alone we ask for help.”", "ur": null, "ar": null },
    "arabicText": "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ",
    "source": "Qur'an 1:5"
  }
]
```

**Step 2: Validate JSON** locally:

```bash
python3 -c "import json; d=json.load(open('Thaqalayn/Data/daily_challenges.json')); print(len(d), 'items')"
# Expected: 8 items   (after you add the other 4)
```

**Step 3: Build** (file is picked up automatically via synced folder; no pbxproj edits).

**Checkpoint:** JSON valid, app builds.

---

## Task 3: Provider (today's pick + rotation)

**Files:**
- Create: `Thaqalayn/Services/DailyChallengeProvider.swift`

**Step 1: Mirror `DailyMessageProvider`.** Match its bundle-load and day-index approach exactly (you read it in Task 0). Skeleton:

```swift
import Foundation

@MainActor
final class DailyChallengeProvider: ObservableObject {
    static let shared = DailyChallengeProvider()

    @Published private(set) var today: DailyChallenge

    private let all: [DailyChallenge]

    private init() {
        self.all = Self.loadAll()
        self.today = Self.resolve(all: all)   // stable for the calendar day
    }

    /// Call when the app becomes active across a date boundary (mirror DailyMessageProvider).
    func refreshIfDayChanged() {
        let resolved = Self.resolve(all: all)
        if resolved.id != today.id { today = resolved }
    }

    // MARK: - Loading (fail loud — NO fallback)

    private static func loadAll() -> [DailyChallenge] {
        guard let url = Bundle.main.url(forResource: "daily_challenges", withExtension: "json") else {
            fatalError("daily_challenges.json missing from bundle")
        }
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode([DailyChallenge].self, from: data)
    }

    // MARK: - Deterministic daily pick

    /// Day index = whole days since a fixed epoch, in the user's current calendar.
    static func dayIndex(for date: Date = Date(), calendar: Calendar = .current) -> Int {
        let startOfToday = calendar.startOfDay(for: date)
        let epoch = calendar.startOfDay(for: Date(timeIntervalSince1970: 0))
        return calendar.dateComponents([.day], from: epoch, to: startOfToday).day ?? 0
    }

    static func resolve(all: [DailyChallenge], date: Date = Date()) -> DailyChallenge {
        precondition(!all.isEmpty, "daily_challenges.json must not be empty")
        let idx = ((dayIndex(for: date) % all.count) + all.count) % all.count
        return all[idx]
    }
}
```

> Note: `try!`/`fatalError` here is the intended *fail-loud* behavior for a packaged data file (match how `DataManager` does it — if `DataManager` throws instead, throw too).

**Step 2: Build.** Expected: BUILD SUCCEEDED.

**Step 3: DEBUG sanity** — temporarily print `DailyChallengeProvider.shared.today.id` from a DEBUG `.task{}` in `TodayView` (or a preview) and confirm it's stable and within the seed set. Remove after.

**Checkpoint:** provider loads and returns a stable daily pick.

---

## Task 4: Manager (completion, streak, sawab, badges)

**Files:**
- Create: `Thaqalayn/Services/DailyChallengeManager.swift`

**Step 1: Implement the manager.** The sawab-award call and badge-persistence must match what you found in Task 0 — replace the marked lines with the real APIs.

```swift
import Foundation
import SwiftUI

@MainActor
final class DailyChallengeManager: ObservableObject {
    static let shared = DailyChallengeManager()

    @Published private(set) var streak = DailyChallengeStreak()
    @Published private(set) var lastCompletion: DailyChallengeCompletion?
    @Published private(set) var awardedBadges: Set<DailyChallengeBadge> = []
    @Published private(set) var justUnlockedBadge: DailyChallengeBadge?   // drives the unlock flourish

    private let streakKey = "dailyChallengeStreak"
    private let completionKey = "dailyChallengeLastCompletion"
    private let badgesKey = "dailyChallengeBadges"

    private init() { load() }

    // MARK: - Day key

    static func dayKey(for date: Date = Date(), calendar: Calendar = .current) -> String {
        let c = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
    }

    var isCompletedToday: Bool { lastCompletion?.dayKey == Self.dayKey() }

    // MARK: - Completion

    /// MC / true-false / fill-in. Returns the sawab earned for the reveal animation.
    @discardableResult
    func complete(challenge: DailyChallenge, wasCorrect: Bool) -> Int {
        guard !isCompletedToday else { return 0 }
        let sawab = 15 + (wasCorrect ? 10 : 0)
        recordCompletion(challenge: challenge, wasCorrect: wasCorrect, sawab: sawab)
        return sawab
    }

    /// Flashcards are self-graded — always counts as done. (gotIt informs nothing scoring-wise in v1.)
    @discardableResult
    func completeFlashcard(challenge: DailyChallenge, gotIt: Bool) -> Int {
        guard !isCompletedToday else { return 0 }
        let sawab = 15
        recordCompletion(challenge: challenge, wasCorrect: gotIt, sawab: sawab)
        return sawab
    }

    private func recordCompletion(challenge: DailyChallenge, wasCorrect: Bool, sawab: Int) {
        let key = Self.dayKey()
        lastCompletion = DailyChallengeCompletion(
            dayKey: key, challengeId: challenge.id, format: challenge.format,
            wasCorrect: wasCorrect, sawabEarned: sawab, completedAt: Date()
        )
        updateStreak(forNewCompletionDayKey: key)

        // === REPLACE with the real sawab accumulator found in Task 0 ===
        // e.g. ProgressManager.shared.addSawab(sawab)   // or QuizManager's mechanism
        awardSawabViaExistingSystem(sawab)

        checkBadges()
        save()
    }

    // MARK: - Streak

    private func updateStreak(forNewCompletionDayKey today: String) {
        let cal = Calendar.current
        let yesterday = Self.dayKey(for: cal.date(byAdding: .day, value: -1, to: Date())!)
        if streak.lastCompletedDayKey == today {
            return                                   // already counted (defensive)
        } else if streak.lastCompletedDayKey == yesterday {
            streak.currentStreak += 1
        } else {
            streak.currentStreak = 1                 // first ever, or chain broken
        }
        streak.longestStreak = max(streak.longestStreak, streak.currentStreak)
        streak.lastCompletedDayKey = today
    }

    // MARK: - Badges

    private func checkBadges() {
        var newly: [DailyChallengeBadge] = []
        if lastCompletion != nil && !awardedBadges.contains(.firstChallenge) { newly.append(.firstChallenge) }
        if streak.currentStreak >= 7   && !awardedBadges.contains(.streak7)   { newly.append(.streak7) }
        if streak.currentStreak >= 30  && !awardedBadges.contains(.streak30)  { newly.append(.streak30) }
        if streak.currentStreak >= 100 && !awardedBadges.contains(.streak100) { newly.append(.streak100) }
        for b in newly {
            awardedBadges.insert(b)
            awardSawabViaExistingSystem(b.sawabValue)
        }
        justUnlockedBadge = newly.last   // card shows a flourish, then clears it
    }

    func clearUnlockFlourish() { justUnlockedBadge = nil }

    // MARK: - Sawab integration (REPLACE body per Task 0 findings)

    private func awardSawabViaExistingSystem(_ amount: Int) {
        // TODO: call the real accumulator, e.g. ProgressManager.shared.addSawab(amount)
    }

    // MARK: - Persistence

    private func load() {
        let d = UserDefaults.standard
        if let data = d.data(forKey: streakKey),
           let s = try? JSONDecoder().decode(DailyChallengeStreak.self, from: data) { streak = s }
        if let data = d.data(forKey: completionKey),
           let c = try? JSONDecoder().decode(DailyChallengeCompletion.self, from: data) { lastCompletion = c }
        if let data = d.data(forKey: badgesKey),
           let b = try? JSONDecoder().decode(Set<DailyChallengeBadge>.self, from: data) { awardedBadges = b }
    }

    private func save() {
        let d = UserDefaults.standard
        if let data = try? JSONEncoder().encode(streak) { d.set(data, forKey: streakKey) }
        if let c = lastCompletion, let data = try? JSONEncoder().encode(c) { d.set(data, forKey: completionKey) }
        if let data = try? JSONEncoder().encode(awardedBadges) { d.set(data, forKey: badgesKey) }
    }
}
```

> Decoding here uses `try?` only for reading *user-owned local prefs* (absent/old data is a normal first-run state, not a corrupt packaged asset) — consistent with the other managers. The packaged content file (Task 3) still fails loud.

**Step 2: DEBUG self-check for streak math** (removable). Add at the bottom, guarded:

```swift
#if DEBUG
extension DailyChallengeManager {
    /// Pure-logic check of the streak transitions. Call once from a DEBUG button; remove before ship.
    static func _selfCheckStreak() {
        var s = DailyChallengeStreak()
        func step(_ last: String?, _ today: String, expect: Int) {
            s.lastCompletedDayKey = last
            // inline mirror of updateStreak:
            if s.lastCompletedDayKey == today { /* no-op */ }
            else if last == "yДень" { } // placeholder — see note
        }
        // Recommended: refactor updateStreak into a static pure func
        // `next(_ streak:, today:, yesterday:) -> DailyChallengeStreak` and assert:
        //   fresh + day1            => current 1
        //   current 1 (yesterday)   => current 2
        //   current 2 (gap of 2d)   => current 1 (reset)
        //   current 2 (same day)    => current 2 (no double count)
        assert(true, "fill in with the pure-func version")
    }
}
#endif
```

> Recommended refactor: extract the streak transition into a **static pure function** `static func nextStreak(_ s: DailyChallengeStreak, todayKey: String, yesterdayKey: String) -> DailyChallengeStreak` and have both `updateStreak` and the self-check call it. Then assert the four cases above. This is the only "test" for the logic.

**Step 3: Build.** Expected: BUILD SUCCEEDED.

**Checkpoint:** manager compiles; streak self-check passes (assertions don't trip); sawab call wired to the real accumulator.

---

## Task 5: Localized UI strings

**Files:**
- Create: `Thaqalayn/Views/DailyChallengeStrings.swift` (or co-locate in the view file)

**Step 1: Add the strings** keyed by `CommentaryLanguage` (mirror `TodayStrings` in `TodayView.swift`). Cover: `dailyChallenge` (eyebrow), `start`, `doneForToday`, `correct`, `notQuite`, `flipCard`, `gotIt`, `reviewAgain`, `comeBackTomorrow`, `dayUnit(_:count)` (singular/plural + ur/ar forms), `sawabEarned(_:)`, format teasers (`teaser(for:)`), `true`/`false`. Provide en/ur/ar for each (Arabic/Urdu strings can be drafted now and refined in Task 9 alongside the content translation pass).

**Step 2: Build.**

**Checkpoint:** strings compile and read correctly in all three languages.

---

## Task 6: Interaction sheet (`DailyChallengeView`)

**Files:**
- Create: `Thaqalayn/Views/DailyChallengeView.swift`

This is the largest view. Build it format by format. Use `@StateObject readingSettings = ReadingSettingsManager.shared`, `@ObservedObject languageManager = CommentaryLanguageManager.shared`, `@ObservedObject themeManager = ThemeManager.shared`, `@ObservedObject manager = DailyChallengeManager.shared`. Apply RTL via `.environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)` and trailing alignment for ur/ar. Scale reading text per the rule.

**Step 1: Shell + state machine.**

```swift
struct DailyChallengeView: View {
    let challenge: DailyChallenge
    var onCompleted: () -> Void           // tells the card to refresh + dismiss

    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var manager = DailyChallengeManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedIndex: Int? = nil      // chosen option (MC/fill-in/TF)
    @State private var revealed = false               // answer locked + explanation shown
    @State private var flipped = false                // flashcard
    @State private var earnedSawab = 0

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var body: some View {
        // header (eyebrow + topic, close) → format body → reveal/explanation → done button
        // background: themeManager.isMidnightEmerald ? emerald : warm
    }
}
```

**Step 2: Multiple choice + fill-in body** (they share the same option-row UI; fill-in just shows `arabicText` with the blank context). On tap: set `selectedIndex`, set `revealed = true`, color rows (green = `correctIndex`, red = wrong pick), show `explanation`. Reading text scaled; option labels are reading content → scaled; the eyebrow/source are not.

**Step 3: True/false body** — two big buttons (localized True/False). On tap, compare to `challenge.trueFalseAnswer`, reveal + explanation.

**Step 4: Flashcard body** — front shows `prompt` (+ `arabicText` if present); tap flips (use a rotation3D flip or a simple cross-fade) to back showing `answer` + `explanation`; then "Got it" / "Review again" buttons.

**Step 5: Reveal → completion.** When revealed (or flashcard graded), show a "Done" CTA. On tap:
- MC/TF/fill-in: `earnedSawab = manager.complete(challenge: challenge, wasCorrect: selectedIndex == challenge.correctIndex)` (for TF compare against the bool).
- flashcard: `earnedSawab = manager.completeFlashcard(challenge: challenge, gotIt: <button>)`.
- Show a brief "+\(earnedSawab) sawab" + streak flourish, call `onCompleted()`, `dismiss()`.

**Step 6: `#Preview`s** (DEBUG) — one per format. Add a small `static let sample…` for each format in a `#if DEBUG` extension on `DailyChallenge`. Preview each in both themes (`ThemeManager` override) and at least English + Urdu (RTL) to confirm scaling + layout.

**Step 7: Build + preview.** Expected: BUILD SUCCEEDED; previews render all four formats; Urdu preview is right-aligned/RTL; increasing the reading scale grows the prompt/options/explanation but not the eyebrow.

**Checkpoint:** all four formats interact correctly in previews, both themes, scaling honored.

---

## Task 7: Today card (`DailyChallengeCard`)

**Files:**
- Create: `Thaqalayn/Views/DailyChallengeCard.swift`

Provide both variants, matching `DuaOfTheDayCard` (light) and `EmDuaOfTheDayCard` (Emerald) — read those first and mirror their structure/initializers.

**Step 1: Card view** with two states driven by `DailyChallengeManager.shared`:

```swift
struct DailyChallengeCard: View {
    @ObservedObject private var manager = DailyChallengeManager.shared
    @ObservedObject private var provider = DailyChallengeProvider.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showSheet = false

    var body: some View {
        // if manager.isCompletedToday → done state (✓, "Done for today",
        //     result, "+N sawab", "🔥 \(manager.streak.currentStreak) days — come back tomorrow")
        // else → teaser state (eyebrow "Daily Challenge", format teaser, 🔥 chip if streak>0, gold "Start")
        // Use the light vs Emerald variant per themeManager.isMidnightEmerald, like DuaOfTheDayCard.
    }
}
```

- Not-done tap → `showSheet = true` → `.sheet { DailyChallengeView(challenge: provider.today) { /* state already updated by manager */ } }`.
- Streak chip + eyebrow + button labels are **chrome** (fixed size). Any displayed prompt teaser is short and may stay fixed (it's a teaser, not the reading body).
- On `manager.justUnlockedBadge != nil`, show a brief celebratory overlay/toast, then call `manager.clearUnlockFlourish()`.

**Step 2: `#Preview`s** — done + not-done × both themes × (English, Urdu).

**Step 3: Build + preview.**

**Checkpoint:** card shows correct state, opens the sheet, both themes look right.

---

## Task 8: Wire into the Today screen

**Files:**
- Modify: `Thaqalayn/Views/TodayView.swift` (insert into `legacyContent`; declare manager/provider if needed; refresh hook)
- Modify: `Thaqalayn/Views/EmeraldTodayView.swift` (insert into the Emerald section list)

**Step 1: Insert the card** after *Continue Reading* and before *Du'a of the Day* in **both** layouts. Match the existing spacing/section padding used by neighboring cards.

**Step 2: Refresh on day change.** Where `DailyMessageProvider.refreshIfDayChanged()` is already called (scene-phase `.active`), also call `DailyChallengeProvider.shared.refreshIfDayChanged()`. (If no such hook exists, add one mirroring DailyMessageProvider's.)

**Step 3: Build, then simulator pass:**

```bash
xcodebuild -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1 | tail -5
# then run the app in the simulator
```

Verify in-app:
- Card appears on Today in **both** themes (toggle theme in Settings).
- Start → answer each format (you'll need to temporarily seed today's pick to each format — e.g. a DEBUG override of `provider.today`).
- After completing: card shows the done/recap state; relaunch app → still done (persisted).
- Simulate a day change to confirm streak: in DEBUG, expose a helper to set `lastCompletedDayKey` to "yesterday" and re-complete → `currentStreak` increments; set to 2 days ago → resets to 1.

**Checkpoint:** end-to-end works in the running app, both themes, persistence + streak confirmed.

---

## Task 9: Author + translate the full content pool

**Files:**
- Modify: `Thaqalayn/Data/daily_challenges.json` (expand to ~80 items)

**Step 1: Author ~80 English items**, interleaved by format, spread across topics (`quran`, `dua`, `ahlulbayt`, `event`, `practice`). Even-ish format split (~20 each). Every fact/narration item carries a `source`; keep v1 to well-established facts. Verify any Ahlul Bayt narration against a real source before including (per the project's narration-verification practice).

**Step 2: Translate.** Run the `urdu-translator` agent, then the `arabic-translator` agent, to fill `ur` and `ar` for every `LocalizedText` (`prompt`, every `options[]`, `answer`, `explanation`). Leave `arabicText` (verse/du'a) and `source` untouched. Then run the project's Urdu/Arabic tafsir validators' spirit-equivalent spot check, or at minimum re-validate JSON.

**Step 3: Validate + build:**

```bash
python3 -c "import json; d=json.load(open('Thaqalayn/Data/daily_challenges.json')); \
print(len(d),'items'); \
assert all(k in x for x in d for k in ('id','format','topic','prompt')); \
print('ok')"
```

**Step 4: Spot-check in app** — switch app language to Urdu, then Arabic; confirm several items read correctly and RTL is right.

**Checkpoint:** ~80 trilingual items, JSON valid, reads correctly in all three languages. **User reviews the pool.**

---

## Task 10: Final verification matrix

**Step 1:** Build clean. Expected BUILD SUCCEEDED.

**Step 2:** Simulator matrix — for each format (force today's pick), in **both** themes, in **English / Urdu / Arabic**:
- prompt/options/explanation render and scale with the reading-size control;
- chrome (eyebrow, source, buttons, streak chip) stays fixed;
- RTL correct for ur/ar;
- completion → recap → persists → streak increments across a simulated day.

**Step 3:** Remove all temporary DEBUG overrides/prints (keep only the optional `#Preview`s and the streak self-check, which are `#if DEBUG`).

**Step 4:** Confirm the per-surah quiz system is untouched and still works.

**Checkpoint:** feature complete; design doc's acceptance criteria all met.

---

## Acceptance criteria (from the design)

- [ ] One rotating daily challenge on Today, ~30s, stable for the calendar day.
- [ ] All four formats work: multiple choice, true/false, flashcard, complete-the-ayah.
- [ ] Done-for-today recap with result + sawab + streak ("come back tomorrow"); not re-playable today.
- [ ] Daily streak (current/longest) with correct increment/reset/no-double-count.
- [ ] Sawab awarded via the existing accumulator; badges (`firstChallenge`, `streak7/30/100`) award once + persist.
- [ ] Light + Midnight Emerald variants, both Today layouts.
- [ ] Fully trilingual (en/ur/ar) with English fallback; RTL correct.
- [ ] Reading content scales with `ReadingSettingsManager`; chrome fixed.
- [ ] Missing/corrupt content file fails loud (no placeholder).
- [ ] Local-only persistence (no cloud sync in v1); per-surah quiz untouched.
- [ ] `xcodebuild` build succeeds; DEBUG-only test scaffolding removable.
