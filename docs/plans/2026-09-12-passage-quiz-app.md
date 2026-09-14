# Passage Quiz App Side Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Show the shipped passage quizzes (`Data/quiz_<surah>.json`) in the iOS app: a Quiz swipe action in the passage list, a Test yourself button beside Mark as read, a one-tap question screen with four framings, a results screen, and a locally kept best score.

**Architecture:** Read-only data loaded lazily per surah by a `QuizStore` that mirrors `PassageStore`; a small `QuizResultsStore` keeps the best score per passage in `UserDefaults` (local only, not synced); two entry points push one `QuizView` that runs the five questions and then shows results; "Read this in the passage" pushes the existing `UnderstandingView` with a new optional scroll target resolved from the question's anchor. Premium gating reuses the Understanding gate. No pipeline code changes.

**Tech Stack:** SwiftUI, XCTest (hosted in the app, `@testable import Thaqalayn`), existing Emerald components (`EmCard`, `EmJourneyToggleButton`, `EmPressStyle`, `PressableNavLink`, `TextSizeButton`), `ThemeManager`, `ReadingSettingsManager`, `PremiumManager`, `PaywallView`.

---

## Context the implementer needs

**Design:** `docs/plans/2026-09-11-passage-quiz-design.md` (data shape, decision 7: the which-verse type is gone). **Mockup, approved by the user:** https://claude.ai/code/artifact/4f154cf1-728e-4668-9d98-a8541618eb29 (seven boards: list swipe, end of passage, the button pair's four states, question, answered, results, the other framings). Match it.

**Data already in the bundle.** `Thaqalayn/Thaqalayn/Data/quiz_1.json` and `quiz_2.json`. The Data folder is an Xcode synchronized group, so new files bundle automatically. Shape: a top-level object keyed by passage index as a string; each record is

```json
{"id": "2:4", "surah": 2, "index": 4, "range": [30, 39],
 "questions": [
   {"id": "q1", "type": "multipleChoice", "verse": 30,
    "prompt": {"en": "..."}, "options": [{"en": "..."}, {"en": "..."}, {"en": "..."}, {"en": "..."}],
    "answer": 1, "explanation": {"en": "..."},
    "anchor": {"where": "essay", "quote": "..."}}
 ],
 "status": {"written_at": "...", "review_attempts": 1, "reviewed_at": "...", "assembled_at": "..."}}
```

Types are exactly `multipleChoice` (two per quiz), `trueFalse` (options `True`, `False`), `fillGap` (prompt holds one `____`) and `whoSaid`. Every quiz has five questions `q1` to `q5` in passage order. `anchor.where` is one of `essay`, `perspectives`, `verses.<n>.note`, `verses.<n>.narrations.<nId>`, `verses.<n>.translation`, `verses.<n>.heading`. Note `where` is a Swift keyword: decode it into a property named `location`.

**Decisions made with the user (do not reopen):**
1. Entry points are the passage list swipe (third action after Read and Save; Read stays first so full swipe still marks read) and a Test yourself button beside Mark as read at the end of `PassageView`. Nothing is added to `UnderstandingView` other than the scroll target.
2. Tapping an option answers it at once. The explanation and a "Read this in the passage" link appear under the options, then a Next question button. No separate Check button.
3. Results show the score, five seals, the missed questions with their right answer, then Try again and Back to passage. No Next passage button.
4. Best score per passage is kept locally in `UserDefaults`. It is not synced and is not progress. This is a deliberate exception to `docs/BOOKMARK_SYNC_ARCHITECTURE.md`.
5. Gating follows Understanding: `PremiumManager.canAccessUnderstanding` (al-Fatihah free, the rest premium). Signal with the PREMIUM capsule, never a lock. A gated tap opens `PaywallView`.
6. Same five questions in the same order on every attempt; options are not shuffled.
7. Prompt, options, explanation and the missed-question text are reading content and scale with `ReadingSettingsManager.shared.scale`. Eyebrows, progress, buttons and chips stay fixed.
8. English only, inline literals or a `QuizStrings` enum; no localization files. Plain spelling, no diacritics, no em dash.

**House rules that apply:** ask before every commit (`AskUserQuestion`), no co-author trailer; never run or drive the simulator yourself, build and hand over; run the unit tests with `xcodebuild test`; add a What's New entry for the feature.

**Theme tokens used below** (all on `ThemeManager.shared`): `accentColor`, `accentColorDeep`, `accentChip`, `accentGradient`, `onAccentText`, `semanticGreen`, `semanticRed`, `primaryText`, `secondaryText`, `tertiaryText`, `glassSurface`, `glassSurfaceElevated`, `strokeColor`, `dividerColor`, `isMidnightEmerald`, `colorScheme`. Type: `EmType.serif(size, .semiBold | .medium)`, `EmType.arabic(size)`, `Text.emEyebrow(size:tracking:)`.

**Build and test commands** (run from the repo root):

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16' build 2>&1 | tail -n 3
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16' test -only-testing:ThaqalaynTests 2>&1 | grep -E 'Test Suite|passed|failed|error:' | tail -n 20
```

If `iPhone 16` is not installed, use any simulator name from `xcrun simctl list devices available | grep iPhone`.

---

### Task 1: Quiz models

**Files:**
- Create: `Thaqalayn/Models/QuizModels.swift`
- Test: `ThaqalaynTests/QuizModelsTests.swift`

**Step 1: Write the failing test**

```swift
import XCTest
@testable import Thaqalayn

final class QuizModelsTests: XCTestCase {
    private func loadSurah(_ n: Int) throws -> [String: PassageQuiz] {
        let url = try XCTUnwrap(Bundle.main.url(forResource: "quiz_\(n)", withExtension: "json"))
        return try JSONDecoder().decode([String: PassageQuiz].self, from: Data(contentsOf: url))
    }

    func testFatihaQuizDecodes() throws {
        let quizzes = try loadSurah(1)
        let q = try XCTUnwrap(quizzes["1"])
        XCTAssertEqual(q.id, "1:1")
        XCTAssertEqual(q.surah, 1)
        XCTAssertEqual(q.index, 1)
        XCTAssertEqual(q.start, 1)
        XCTAssertEqual(q.end, 7)
        XCTAssertEqual(q.questions.count, 5)
        XCTAssertEqual(q.questions.map(\.id), ["q1", "q2", "q3", "q4", "q5"])
    }

    func testEveryShippedQuestionIsWellFormed() throws {
        for surah in [1, 2] {
            for (_, quiz) in try loadSurah(surah) {
                XCTAssertEqual(quiz.questions.count, 5, quiz.id)
                for q in quiz.questions {
                    XCTAssertTrue(q.options.indices.contains(q.answer), "\(quiz.id) \(q.id)")
                    XCTAssertFalse(q.anchor.location.isEmpty, "\(quiz.id) \(q.id)")
                    XCTAssertFalse(q.anchor.quote.isEmpty, "\(quiz.id) \(q.id)")
                    if q.type == .trueFalse { XCTAssertEqual(q.options.map(\.en), ["True", "False"], "\(quiz.id) \(q.id)") }
                    if q.type == .fillGap { XCTAssertTrue(q.prompt.en.contains("____"), "\(quiz.id) \(q.id)") }
                }
            }
        }
    }
}
```

**Step 2: Run the test to verify it fails**

Run the test command above with `-only-testing:ThaqalaynTests/QuizModelsTests`.
Expected: build error, `cannot find type 'PassageQuiz' in scope`.

**Step 3: Write the models**

```swift
// Thaqalayn/Models/QuizModels.swift
import Foundation

/// One shipped passage quiz, decoded from Data/quiz_<surah>.json, which is an
/// object keyed by passage index as a string. Generated and reviewed by the
/// quiz pipeline (docs/plans/2026-09-11-passage-quiz-design.md); the app never
/// writes it.
struct PassageQuiz: Codable, Identifiable, Hashable {
    let id: String
    let surah: Int
    let index: Int
    let range: [Int]
    let questions: [QuizQuestion]

    var start: Int { range.first ?? 0 }
    var end: Int { range.last ?? 0 }
    var ref: PassageRef { PassageRef(surah: surah, index: index, start: start, end: end) }
}

/// The four framings. whichVerse was removed on 2026-09-12; a file that still
/// carries one fails to decode and the store hides that surah's quizzes.
enum QuizQuestionType: String, Codable, Hashable {
    case multipleChoice, trueFalse, fillGap, whoSaid

    var label: String {
        switch self {
        case .multipleChoice: return "Multiple choice"
        case .trueFalse: return "True or false"
        case .fillGap: return "Fill the gap"
        case .whoSaid: return "Who said it"
        }
    }
}

struct QuizQuestion: Codable, Identifiable, Hashable {
    let id: String
    let type: QuizQuestionType
    let verse: Int
    let prompt: LocalizedText
    let options: [LocalizedText]
    let answer: Int
    let explanation: LocalizedText
    let anchor: QuizAnchor
}

/// Where in the passage the answer is settled. `location` is the JSON key
/// `where`, a Swift keyword.
struct QuizAnchor: Codable, Hashable {
    let location: String
    let quote: String

    enum CodingKeys: String, CodingKey {
        case location = "where"
        case quote
    }
}
```

`PassageRef` has a memberwise init (stored `surah, index, start, end`; see `Thaqalayn/Models/PassageIndex.swift:6`). `LocalizedText` lives in `Thaqalayn/Models/DailyChallengeModels.swift:17`.

**Step 4: Run the tests to verify they pass**

Expected: both tests PASS.

**Step 5: Commit** (ask first)

```bash
git add Thaqalayn/Models/QuizModels.swift ThaqalaynTests/QuizModelsTests.swift
git commit -m "quiz: models for shipped passage quizzes"
```

---

### Task 2: QuizStore

**Files:**
- Create: `Thaqalayn/Services/QuizStore.swift`
- Test: `ThaqalaynTests/QuizStoreTests.swift`
- Reference: `Thaqalayn/Services/PassageStore.swift` (46 lines, copy its shape)

**Step 1: Write the failing test**

```swift
import XCTest
@testable import Thaqalayn

@MainActor
final class QuizStoreTests: XCTestCase {
    func testLoadsShippedQuiz() {
        let store = QuizStore()
        let ref = PassageRef(surah: 1, index: 1, start: 1, end: 7)
        XCTAssertTrue(store.hasQuiz(for: ref))
        XCTAssertEqual(store.quiz(for: ref)?.questions.count, 5)
    }

    func testMissingSurahHasNoQuiz() {
        let store = QuizStore()
        XCTAssertFalse(store.hasQuiz(for: PassageRef(surah: 114, index: 1, start: 1, end: 3)))
        XCTAssertTrue(store.quizIndices(surah: 114).isEmpty)
    }

    func testIndicesForBaqarah() {
        let store = QuizStore()
        XCTAssertGreaterThanOrEqual(store.quizIndices(surah: 2).count, 40)
    }
}
```

**Step 2: Run it, expect** `cannot find 'QuizStore' in scope`.

**Step 3: Write the store**

```swift
// Thaqalayn/Services/QuizStore.swift
import Foundation

/// Lazily loads Data/quiz_<surah>.json once per surah, like PassageStore does
/// for passages. A surah with no file, or a file that fails to decode, simply
/// has no quizzes; the UI hides the entry points for it.
@MainActor
final class QuizStore: ObservableObject {
    static let shared = QuizStore()

    private var cache: [Int: [String: PassageQuiz]] = [:]
    private var missing: Set<Int> = []

    init() {}

    private func load(surah: Int) -> [String: PassageQuiz] {
        if let hit = cache[surah] { return hit }
        if missing.contains(surah) { return [:] }
        guard let url = Bundle.main.url(forResource: "quiz_\(surah)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            missing.insert(surah)
            return [:]
        }
        do {
            let decoded = try JSONDecoder().decode([String: PassageQuiz].self, from: data)
            cache[surah] = decoded
            return decoded
        } catch {
            assertionFailure("quiz_\(surah).json failed to decode: \(error)")
            missing.insert(surah)
            return [:]
        }
    }

    func quiz(for ref: PassageRef) -> PassageQuiz? {
        load(surah: ref.surah)[String(ref.index)]
    }

    func hasQuiz(for ref: PassageRef) -> Bool {
        quiz(for: ref) != nil
    }

    /// Passage indices of this surah that have a quiz; the list view reads it once per render.
    func quizIndices(surah: Int) -> Set<Int> {
        Set(load(surah: surah).keys.compactMap { Int($0) })
    }
}
```

**Step 4: Run the tests, expect PASS.**

**Step 5: Commit** (ask first): `git commit -m "quiz: QuizStore loads quiz_<surah>.json lazily"`

---

### Task 3: QuizResultsStore, best score per passage

**Files:**
- Create: `Thaqalayn/Services/QuizResultsStore.swift`
- Test: `ThaqalaynTests/QuizResultsStoreTests.swift`
- Reference: `Thaqalayn/Services/DailyCrosswordManager.swift:87-108` (JSON in UserDefaults), `ThaqalaynTests/JourneyResumeTests.swift` (throwaway suite)

**Step 1: Write the failing test**

```swift
import XCTest
@testable import Thaqalayn

@MainActor
final class QuizResultsStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private let suite = "QuizResultsStoreTests"
    private let ref = PassageRef(surah: 2, index: 4, start: 30, end: 39)

    override func setUp() {
        defaults = UserDefaults(suiteName: suite)
        defaults.removePersistentDomain(forName: suite)
    }

    func testEmptyByDefault() {
        XCTAssertNil(QuizResultsStore(defaults: defaults).best(for: ref))
    }

    func testRecordKeepsTheHigherScore() {
        let store = QuizResultsStore(defaults: defaults)
        store.record(PassageQuizResult(surah: 2, index: 4, score: 3, total: 5, completedAt: Date()))
        store.record(PassageQuizResult(surah: 2, index: 4, score: 5, total: 5, completedAt: Date()))
        store.record(PassageQuizResult(surah: 2, index: 4, score: 2, total: 5, completedAt: Date()))
        XCTAssertEqual(store.best(for: ref)?.score, 5)
    }

    func testPersistsAcrossInstances() {
        QuizResultsStore(defaults: defaults)
            .record(PassageQuizResult(surah: 2, index: 4, score: 4, total: 5, completedAt: Date()))
        let reloaded = QuizResultsStore(defaults: defaults)
        XCTAssertEqual(reloaded.best(for: ref)?.score, 4)
        XCTAssertEqual(reloaded.bestScores(surah: 2), [4: 4])
    }
}
```

**Step 2: Run it, expect** `cannot find 'QuizResultsStore' in scope`.

**Step 3: Write the store**

```swift
// Thaqalayn/Services/QuizResultsStore.swift
import Foundation

struct PassageQuizResult: Codable, Equatable {
    let surah: Int
    let index: Int
    let score: Int
    let total: Int
    let completedAt: Date

    var key: String { "\(surah):\(index)" }
}

/// Best quiz score per passage. Local only, on purpose: the quiz is a
/// self-check, not reading progress, so it does not join the synced stores
/// (see docs/plans/2026-09-12-passage-quiz-app.md, decision 4).
@MainActor
final class QuizResultsStore: ObservableObject {
    static let shared = QuizResultsStore()

    private static let storageKey = "passageQuizBest"
    private let defaults: UserDefaults
    @Published private(set) var best: [String: PassageQuizResult] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([String: PassageQuizResult].self, from: data) {
            best = decoded
        }
    }

    func best(for ref: PassageRef) -> PassageQuizResult? {
        best[ref.id]
    }

    /// Passage index to best score, for the list rows.
    func bestScores(surah: Int) -> [Int: Int] {
        var out: [Int: Int] = [:]
        for r in best.values where r.surah == surah { out[r.index] = r.score }
        return out
    }

    /// Keeps the higher score; an equal score keeps the newer attempt.
    func record(_ result: PassageQuizResult) {
        if let old = best[result.key], old.score > result.score { return }
        best[result.key] = result
        if let data = try? JSONEncoder().encode(best) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }
}
```

**Step 4: Run the tests, expect PASS.**

**Step 5: Commit** (ask first): `git commit -m "quiz: local best-score store"`

---

### Task 4: Premium gate

**Files:**
- Modify: `Thaqalayn/Services/PremiumManager.swift` (next to `canAccessUnderstanding`, line 123)
- Test: `ThaqalaynTests/QuizStoreTests.swift` (add one test)

**Step 1: Add the test**

```swift
    func testQuizGateFollowsUnderstanding() {
        let pm = PremiumManager.shared
        XCTAssertEqual(pm.canAccessQuiz(surahNumber: 1), pm.canAccessUnderstanding(surahNumber: 1))
        XCTAssertEqual(pm.canAccessQuiz(surahNumber: 2), pm.canAccessUnderstanding(surahNumber: 2))
    }
```

**Step 2: Run it, expect** `value of type 'PremiumManager' has no member 'canAccessQuiz'`.

**Step 3: Add the method** right after `canAccessUnderstanding`:

```swift
    /// The passage quiz follows the Understanding gate: al-Fatihah is free, the rest is premium.
    func canAccessQuiz(surahNumber: Int) -> Bool {
        canAccessUnderstanding(surahNumber: surahNumber)
    }
```

**Step 4: Run, expect PASS. Step 5: Commit** (ask first): `git commit -m "quiz: premium gate follows Understanding"`

---

### Task 5: Anchor to scroll target in UnderstandingView

**Files:**
- Modify: `Thaqalayn/Views/Passages/UnderstandingView.swift` (init at line 29, `paragraphs` static helper near line 62, `ScrollViewReader` at line 194, section ids listed below)
- Test: `ThaqalaynTests/QuizAnchorTests.swift`
- Fixture already present: `ThaqalaynTests/Fixtures/passage_2_4.json`

UnderstandingView already tags its blocks with ids: essay paragraph i is `"essay.\(i)"`, a verse heading `"v\(n).heading"`, a verse note `"v\(n).note"`, a narration `"v\(n).\(narration.id)"`, perspectives paragraph i `"persp.\(i)"`. The essay and perspectives are split with the private static `paragraphs(_:)`. The resolver maps an anchor onto one of those ids.

**Step 1: Write the failing test**

```swift
import XCTest
@testable import Thaqalayn

final class QuizAnchorTests: XCTestCase {
    private func passage() throws -> Passage {
        let url = try XCTUnwrap(Bundle(for: Self.self).url(forResource: "passage_2_4", withExtension: "json"))
        return try JSONDecoder().decode(Passage.self, from: Data(contentsOf: url))
    }

    func testNarrationAndNoteAnchors() throws {
        let p = try passage()
        XCTAssertEqual(UnderstandingView.scrollId(for: QuizAnchor(location: "verses.31.narrations.n3", quote: "x"), in: p, lang: .english), "v31.n3")
        XCTAssertEqual(UnderstandingView.scrollId(for: QuizAnchor(location: "verses.31.note", quote: "x"), in: p, lang: .english), "v31.note")
    }

    func testEssayAnchorFindsItsParagraph() throws {
        let p = try passage()
        let paragraphs = UnderstandingView.paragraphs(p.essay.en)
        let target = paragraphs.indices.last ?? 0
        let words = paragraphs[target].split(separator: " ").prefix(8).joined(separator: " ")
        XCTAssertEqual(UnderstandingView.scrollId(for: QuizAnchor(location: "essay", quote: words), in: p, lang: .english), "essay.\(target)")
    }

    func testEssayAnchorWithUnknownQuoteFallsBackToTop() throws {
        let p = try passage()
        XCTAssertEqual(UnderstandingView.scrollId(for: QuizAnchor(location: "essay", quote: "not in the essay at all"), in: p, lang: .english), "essay.0")
    }

    func testTranslationAnchorLandsOnTheVerseRow() throws {
        let p = try passage()
        let id = UnderstandingView.scrollId(for: QuizAnchor(location: "verses.34.translation", quote: "x"), in: p, lang: .english)
        XCTAssertTrue(id?.hasPrefix("v34.") ?? false, String(describing: id))
    }
}
```

Check the enum case name for English on `CommentaryLanguage` (grep `enum CommentaryLanguage`) and use it in place of `.english` if it differs.

**Step 2: Run it, expect** `type 'UnderstandingView' has no member 'scrollId'` (and `paragraphs` is inaccessible).

**Step 3: Implement**

1. Make the paragraph splitter internal: change `private static func paragraphs(` to `static func paragraphs(`.
2. Add the init parameter with a default so existing call sites compile unchanged:

```swift
    /// Block id to scroll to on appear (from a quiz anchor). See `scrollId(for:in:lang:)`.
    let scrollTarget: String?

    init(surahWithTafsir: SurahWithTafsir, ref: PassageRef, passage: Passage, scrollTarget: String? = nil) {
        // existing assignments
        self.scrollTarget = scrollTarget
    }
```

3. Add the resolver as a static method on `UnderstandingView` (an extension at the bottom of the file is fine):

```swift
extension UnderstandingView {
    /// Maps a quiz anchor onto the block ids this screen tags its content with.
    /// Essay and perspectives anchors land on the paragraph that holds the quote,
    /// falling back to the first paragraph; verse anchors land on the verse's
    /// heading, note or first narration, whichever the passage has.
    static func scrollId(for anchor: QuizAnchor, in passage: Passage, lang: CommentaryLanguage) -> String? {
        let parts = anchor.location.split(separator: ".").map(String.init)
        switch parts.first {
        case "essay":
            return "essay.\(paragraphIndex(containing: anchor.quote, in: paragraphs(passage.essay.text(for: lang))))"
        case "perspectives":
            guard let persp = passage.perspectives else { return nil }
            return "persp.\(paragraphIndex(containing: anchor.quote, in: paragraphs(persp.text(for: lang))))"
        case "verses":
            guard parts.count >= 3, let verse = Int(parts[1]) else { return nil }
            if parts[2] == "narrations", parts.count >= 4 { return "v\(verse).\(parts[3])" }
            if parts[2] == "note" { return "v\(verse).note" }
            // translation or heading: the nearest block this screen shows for that verse
            guard let entry = passage.entry(forVerse: verse) else { return nil }
            if entry.heading != nil { return "v\(verse).heading" }
            if entry.note != nil { return "v\(verse).note" }
            if let first = entry.narrations.first { return "v\(verse).\(first.id)" }
            return nil
        default:
            return nil
        }
    }

    private static func paragraphIndex(containing quote: String, in paragraphs: [String]) -> Int {
        let needle = normalized(quote)
        return paragraphs.firstIndex { normalized($0).contains(needle) } ?? 0
    }

    private static func normalized(_ s: String) -> String {
        let straight = s.replacingOccurrences(of: "\u{2018}", with: "'").replacingOccurrences(of: "\u{2019}", with: "'")
            .replacingOccurrences(of: "\u{201C}", with: "\"").replacingOccurrences(of: "\u{201D}", with: "\"")
        return straight.split(whereSeparator: { $0.isWhitespace }).joined(separator: " ").lowercased()
    }
}
```

Check `passage.entry(forVerse:)` exists (`PassageModels.swift:48`); if it returns an optional under a different name, use that.

4. Scroll on appear. Inside the existing `ScrollViewReader { proxy in ... }` (line 194), add to the scroll view:

```swift
.onAppear {
    guard let target = scrollTarget else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
        withAnimation(.easeInOut(duration: 0.45)) { proxy.scrollTo(target, anchor: .top) }
    }
}
```

The delay lets the lazy content lay out first; the listen-follow code at lines 224 to 227 already scrolls the same proxy with `.center`, so `.top` here is deliberate.

**Step 4: Run the tests, expect PASS.** Also build the app target to confirm no call site broke.

**Step 5: Commit** (ask first): `git commit -m "understanding: scroll target resolved from a quiz anchor"`

---

### Task 6: QuizStrings and the option row

**Files:**
- Create: `Thaqalayn/Views/Passages/QuizStrings.swift`
- Create: `Thaqalayn/Views/Passages/QuizOptionRow.swift`

No unit test: pure SwiftUI. Verified by building and by the user on device.

**Step 1: Strings**

```swift
// Thaqalayn/Views/Passages/QuizStrings.swift
import Foundation

/// Chrome copy for the passage quiz. English only, plain spelling, no em dash.
enum QuizStrings {
    static let title = "Test yourself"
    static let entry = "Test yourself"
    static let swipe = "Quiz"
    static let hint = "Tap an answer to check it"
    static let why = "Why"
    static let readInPassage = "Read this in the passage"
    static let next = "Next question"
    static let seeResults = "See results"
    static let missed = "What you missed"
    static let tryAgain = "Try again"
    static let backToPassage = "Back to passage"
    static let premium = "PREMIUM"

    static func question(_ n: Int, of total: Int) -> String { "Question \(n) of \(total)" }
    static func score(_ score: Int, of total: Int) -> String { "\(score) of \(total)" }
    static func scoreShort(_ score: Int, of total: Int) -> String { "\(score)/\(total)" }
    static func verse(_ n: Int) -> String { "Verse \(n)" }
    static func anchorLabel(_ location: String) -> String {
        let parts = location.split(separator: ".")
        if parts.first == "essay" { return "Essay" }
        if parts.first == "perspectives" { return "Perspectives" }
        guard parts.count >= 3, let v = Int(parts[1]) else { return "" }
        if parts[2] == "narrations" { return "Narration on verse \(v)" }
        if parts[2] == "note" { return "Note on verse \(v)" }
        return "Verse \(v)"
    }
    static func verdict(_ score: Int, of total: Int) -> String {
        switch score {
        case total: return "You understood this passage."
        case (total - 1)...: return "You understood this passage."
        case (total / 2)...: return "Most of it landed. Read the missed points again."
        default: return "Worth another read before moving on."
        }
    }
}
```

**Step 2: Option row**

One row for every framing. `state` drives fill, border and the marker on the left: an empty ring before answering, a green seal on the right answer, a red ring with a cross on a wrong pick, dimmed for the rest.

```swift
// Thaqalayn/Views/Passages/QuizOptionRow.swift
import SwiftUI

struct QuizOptionRow: View {
    enum State { case idle, correct, wrong, dimmed }

    let text: String
    let state: State
    let centered: Bool
    let onTap: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    init(text: String, state: State, centered: Bool = false, onTap: @escaping () -> Void) {
        self.text = text
        self.state = state
        self.centered = centered
        self.onTap = onTap
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if centered { Spacer(minLength: 0) }
                marker
                Text(text)
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(centered ? .center : .leading)
                    .fixedSize(horizontal: false, vertical: true)
                if centered { Spacer(minLength: 0) }
                if !centered { Spacer(minLength: 0) }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(minHeight: 52)
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(fill))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(border, lineWidth: 1))
            .opacity(state == .dimmed ? 0.45 : 1)
        }
        .buttonStyle(EmPressStyle.gentle)
        .disabled(state != .idle)
        .accessibilityLabel(accessibilityText)
    }

    private var fill: Color {
        switch state {
        case .correct: return themeManager.semanticGreen.opacity(0.16)
        case .wrong: return themeManager.semanticRed.opacity(0.14)
        default: return themeManager.glassSurface
        }
    }

    private var border: Color {
        switch state {
        case .correct: return themeManager.semanticGreen.opacity(0.55)
        case .wrong: return themeManager.semanticRed.opacity(0.55)
        default: return themeManager.strokeColor
        }
    }

    @ViewBuilder private var marker: some View {
        switch state {
        case .correct:
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.semanticGreen)
        case .wrong:
            Image(systemName: "xmark")
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(themeManager.semanticRed)
                .frame(width: 22, height: 22)
                .overlay(Circle().stroke(themeManager.semanticRed, lineWidth: 1.5))
        default:
            Circle().stroke(themeManager.strokeColor, lineWidth: 1.5).frame(width: 22, height: 22)
        }
    }

    private var accessibilityText: String {
        switch state {
        case .correct: return "\(text), correct answer"
        case .wrong: return "\(text), your answer, wrong"
        default: return text
        }
    }
}
```

**Step 3: Build**, expect success. **Step 4: Commit** (ask first): `git commit -m "quiz: strings and option row"`

---

### Task 7: QuizView, the question flow and results

**Files:**
- Create: `Thaqalayn/Views/Passages/QuizView.swift`
- Create: `Thaqalayn/Views/Passages/QuizResultsView.swift`
- Reference for chrome: `PassageView.swift` header (lines 254 to 330) and its screen modifiers (lines 204 to 231); `UnderstandingView.swift` `TextSizeButton` use (line 254 onwards)

The screen runs the five questions in a `ScrollView`, then switches to results. State: `currentIndex`, `answers: [Int?]`, `phase`. The result is recorded once, when the results phase is entered.

**Step 1: QuizView**

```swift
// Thaqalayn/Views/Passages/QuizView.swift
import SwiftUI

/// Five questions on one passage, answered one tap at a time, then results.
/// Pushed from the passage list swipe and from the Test yourself button.
struct QuizView: View {
    let surahWithTafsir: SurahWithTafsir
    let ref: PassageRef
    let quiz: PassageQuiz

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var passageStore = PassageStore.shared
    @ObservedObject private var results = QuizResultsStore.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    @State private var currentIndex = 0
    @State private var answers: [Int?]
    @State private var showingResults = false
    @State private var showTextSizePanel = false
    @State private var understandingTarget: String? = nil
    @State private var showingUnderstanding = false

    init(surahWithTafsir: SurahWithTafsir, ref: PassageRef, quiz: PassageQuiz) {
        self.surahWithTafsir = surahWithTafsir
        self.ref = ref
        self.quiz = quiz
        _answers = State(initialValue: Array(repeating: nil, count: quiz.questions.count))
    }

    private var surah: Surah { surahWithTafsir.surah }
    private var passage: Passage? { passageStore.passage(surah: ref.surah, index: ref.index) }
    private var question: QuizQuestion { quiz.questions[currentIndex] }
    private var picked: Int? { answers[currentIndex] }
    private var isLast: Bool { currentIndex == quiz.questions.count - 1 }
    private var score: Int {
        zip(quiz.questions, answers).filter { $0.1 == $0.0.answer }.count
    }
    private var eyebrow: String { "\(surah.englishName) · \(passageStore.title(for: ref))" }

    var body: some View {
        ZStack {
            background
            if showingResults {
                QuizResultsView(
                    eyebrow: eyebrow,
                    quiz: quiz,
                    answers: answers,
                    onReadAnchor: openUnderstanding,
                    onTryAgain: reset,
                    onBack: { dismiss() }
                )
            } else {
                questionScreen
            }
        }
        .background(
            NavigationLink(destination: understandingDestination, isActive: $showingUnderstanding) { EmptyView() }
                .hidden()
                .accessibilityHidden(true)
        )
        .textSizePanelOverlay(isOpen: $showTextSizePanel, topPadding: 60, trailingPadding: 20)
        .navigationBarHidden(true)
        .hideTabBar()
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.22, starCount: 10)
    }

    // MARK: - Background (same ground as PassageView)

    @ViewBuilder private var background: some View {
        if themeManager.isMidnightEmerald {
            EmeraldBackground().ignoresSafeArea()
        } else {
            LinearGradient(
                colors: [themeManager.primaryBackground, themeManager.secondaryBackground, themeManager.tertiaryBackground],
                startPoint: .topLeading, endPoint: .bottomTrailing
            ).ignoresSafeArea()
        }
    }

    // MARK: - Question screen

    private var questionScreen: some View {
        VStack(spacing: 0) {
            header
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    titleBlock
                    progress.padding(.top, 14).padding(.bottom, 18)
                    questionCard
                    options.padding(.top, 14)
                    if picked != nil {
                        explanation.padding(.top, 18)
                        readLink.padding(.top, 12)
                        nextButton.padding(.top, 20)
                    } else {
                        Text(QuizStrings.hint)
                            .font(.system(size: 12.5, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 18)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Back")
            Spacer()
            TextSizeButton(isPanelOpen: $showTextSizePanel)
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .emEyebrow(size: 11, tracking: 2)
                .foregroundColor(themeManager.accentColor)
            Text(QuizStrings.title)
                .font(EmType.serif(30, .semiBold))
                .foregroundColor(themeManager.primaryText)
            Text(QuizStrings.question(currentIndex + 1, of: quiz.questions.count))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
    }

    private var progress: some View {
        HStack(spacing: 6) {
            ForEach(quiz.questions.indices, id: \.self) { i in
                Capsule()
                    .fill(i < currentIndex ? themeManager.accentColor
                          : i == currentIndex ? themeManager.accentBright
                          : themeManager.strokeColor)
                    .frame(height: 4)
            }
        }
        .accessibilityHidden(true)
    }

    private var questionCard: some View {
        EmCard(elevated: true, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Text(question.type.label.uppercased())
                        .emEyebrow(size: 11, tracking: 2)
                        .foregroundColor(themeManager.accentColor)
                    Spacer()
                    Text(QuizStrings.verse(question.verse))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }
                promptText
            }
            .padding(20)
        }
    }

    /// The fill-the-gap prompt shows its blank as an underlined space; other types show the prompt as is.
    @ViewBuilder private var promptText: some View {
        let font = EmType.serif(20 * readingSettings.scale, .medium)
        if question.type == .fillGap, let range = question.prompt.en.range(of: "____") {
            let before = String(question.prompt.en[..<range.lowerBound])
            let after = String(question.prompt.en[range.upperBound...])
            (Text(before) + Text("        ").underline(true, color: themeManager.accentColor) + Text(after))
                .font(font)
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(5 * readingSettings.scale)
                .fixedSize(horizontal: false, vertical: true)
        } else {
            Text(question.prompt.en)
                .font(font)
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(5 * readingSettings.scale)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    @ViewBuilder private var options: some View {
        switch question.type {
        case .trueFalse:
            HStack(spacing: 12) {
                ForEach(question.options.indices, id: \.self) { i in
                    QuizOptionRow(text: question.options[i].en, state: state(for: i), centered: true) { answer(i) }
                }
            }
        case .fillGap:
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(question.options.indices, id: \.self) { i in
                    QuizOptionRow(text: question.options[i].en, state: state(for: i), centered: true) { answer(i) }
                }
            }
        default:
            VStack(spacing: 10) {
                ForEach(question.options.indices, id: \.self) { i in
                    QuizOptionRow(text: question.options[i].en, state: state(for: i)) { answer(i) }
                }
            }
        }
    }

    private func state(for option: Int) -> QuizOptionRow.State {
        guard let picked else { return .idle }
        if option == question.answer { return .correct }
        if option == picked { return .wrong }
        return .dimmed
    }

    private var explanation: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(QuizStrings.why.uppercased())
                .emEyebrow(size: 11, tracking: 2)
                .foregroundColor(picked == question.answer ? themeManager.semanticGreen : themeManager.semanticRed)
            Text(question.explanation.en)
                .font(EmType.serif(16 * readingSettings.scale, .medium))
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(5 * readingSettings.scale)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var readLink: some View {
        Button(action: { openUnderstanding(question.anchor) }) {
            HStack(spacing: 12) {
                Image(systemName: "book")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                VStack(alignment: .leading, spacing: 2) {
                    Text(QuizStrings.readInPassage)
                        .font(EmType.serif(17, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(QuizStrings.anchorLabel(question.anchor.location))
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
            }
            .frame(minHeight: 44)
        }
        .buttonStyle(EmPressStyle.gentle)
        .disabled(passage == nil)
        .accessibilityLabel("Read this in the passage, \(QuizStrings.anchorLabel(question.anchor.location))")
    }

    private var nextButton: some View {
        Button(action: advance) {
            HStack(spacing: 10) {
                Text(isLast ? QuizStrings.seeResults : QuizStrings.next)
                    .font(.system(size: 16, weight: .bold)).tracking(0.3)
                Image(systemName: "arrow.right")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(themeManager.onAccentText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
            .shadow(color: themeManager.accentColor.opacity(0.28), radius: 24, x: 0, y: 10)
        }
        .buttonStyle(EmPressStyle())
    }

    // MARK: - Actions

    private func answer(_ option: Int) {
        guard answers[currentIndex] == nil else { return }
        withAnimation(.easeInOut(duration: 0.2)) { answers[currentIndex] = option }
        UINotificationFeedbackGenerator().notificationOccurred(option == question.answer ? .success : .error)
    }

    private func advance() {
        if isLast {
            results.record(PassageQuizResult(surah: ref.surah, index: ref.index, score: score,
                                             total: quiz.questions.count, completedAt: Date()))
            withAnimation(.easeInOut(duration: 0.3)) { showingResults = true }
        } else {
            withAnimation(.easeInOut(duration: 0.25)) { currentIndex += 1 }
        }
    }

    private func reset() {
        answers = Array(repeating: nil, count: quiz.questions.count)
        currentIndex = 0
        withAnimation(.easeInOut(duration: 0.3)) { showingResults = false }
    }

    private func openUnderstanding(_ anchor: QuizAnchor) {
        guard let passage else { return }
        understandingTarget = UnderstandingView.scrollId(for: anchor, in: passage, lang: CommentaryLanguageManager.shared.selectedLanguage)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showingUnderstanding = true }
    }

    @ViewBuilder private var understandingDestination: some View {
        if let passage {
            UnderstandingView(surahWithTafsir: surahWithTafsir, ref: ref, passage: passage, scrollTarget: understandingTarget)
        } else {
            EmptyView()
        }
    }
}
```

Check the exact names before building: `themeManager.accentBright` exists (`ThemeManager.swift:352`); `EmeraldBackground` is the view PassageView uses in Midnight Emerald (`PassageView.swift:119`); `CommentaryLanguageManager.shared.selectedLanguage` is how UnderstandingView reads `lang` (grep it there and copy). `Surah.englishName` is at `QuranModels.swift:20`.

**Step 2: QuizResultsView**

```swift
// Thaqalayn/Views/Passages/QuizResultsView.swift
import SwiftUI

struct QuizResultsView: View {
    let eyebrow: String
    let quiz: PassageQuiz
    let answers: [Int?]
    let onReadAnchor: (QuizAnchor) -> Void
    let onTryAgain: () -> Void
    let onBack: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared

    private var total: Int { quiz.questions.count }
    private var score: Int { zip(quiz.questions, answers).filter { $0.1 == $0.0.answer }.count }
    private var missed: [QuizQuestion] { zip(quiz.questions, answers).filter { $0.1 != $0.0.answer }.map(\.0) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 40, height: 40)
                        .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                }
                .buttonStyle(EmPressStyle())
                .accessibilityLabel("Back to passage")
                Spacer()
            }
            .padding(.horizontal, 20).padding(.top, 12).padding(.bottom, 8)

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text(eyebrow.uppercased())
                        .emEyebrow(size: 11, tracking: 2)
                        .foregroundColor(themeManager.accentColor)
                    Text(QuizStrings.score(score, of: total))
                        .font(EmType.serif(64, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .padding(.top, 10)
                    Text(QuizStrings.verdict(score, of: total))
                        .font(EmType.serifItalic(19))
                        .foregroundColor(themeManager.secondaryText)
                        .padding(.top, 4)

                    seals.padding(.top, 26)

                    if !missed.isEmpty {
                        Text(QuizStrings.missed.uppercased())
                            .emEyebrow(size: 11, tracking: 2)
                            .foregroundColor(themeManager.accentColor)
                            .padding(.top, 30)
                        VStack(spacing: 12) {
                            ForEach(missed) { q in missedCard(q) }
                        }
                        .padding(.top, 12)
                    }

                    buttons.padding(.top, 28)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 40)
            }
        }
        .onAppear { UINotificationFeedbackGenerator().notificationOccurred(.success) }
    }

    private var seals: some View {
        HStack {
            ForEach(quiz.questions.indices, id: \.self) { i in
                VStack(spacing: 6) {
                    if answers[i] == quiz.questions[i].answer {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 30, weight: .semibold))
                            .foregroundColor(themeManager.semanticGreen)
                    } else {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(themeManager.semanticRed)
                            .frame(width: 34, height: 34)
                            .overlay(Circle().stroke(themeManager.semanticRed, lineWidth: 1.5))
                    }
                    Text("Q\(i + 1)")
                        .font(.system(size: 11, weight: .bold)).tracking(1)
                        .foregroundColor(themeManager.tertiaryText)
                }
                if i < quiz.questions.count - 1 { Spacer() }
            }
        }
        .padding(.horizontal, 12)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(score) of \(total) correct")
    }

    private func missedCard(_ q: QuizQuestion) -> some View {
        EmCard(elevated: true, cornerRadius: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("\(q.id.uppercased()) · \(q.type.label)".uppercased())
                        .emEyebrow(size: 11, tracking: 1.5)
                        .foregroundColor(themeManager.tertiaryText)
                    Spacer()
                    Text(QuizStrings.verse(q.verse))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }
                Text(q.prompt.en)
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4 * readingSettings.scale)
                    .fixedSize(horizontal: false, vertical: true)
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.semanticGreen)
                    Text(q.options[q.answer].en)
                        .font(EmType.serif(17 * readingSettings.scale, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                }
                Button(action: { onReadAnchor(q.anchor) }) {
                    HStack(spacing: 6) {
                        Text(QuizStrings.readInPassage)
                            .font(.system(size: 14, weight: .semibold))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .foregroundColor(themeManager.accentColor)
                    .frame(minHeight: 44)
                }
                .buttonStyle(EmPressStyle.gentle)
                .accessibilityLabel("Read this in the passage, \(QuizStrings.anchorLabel(q.anchor.location))")
            }
            .padding(18)
        }
    }

    private var buttons: some View {
        HStack(spacing: 12) {
            Button(action: onTryAgain) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 16, weight: .semibold))
                    Text(QuizStrings.tryAgain)
                        .font(.system(size: 16, weight: .bold)).tracking(0.3)
                }
                .foregroundColor(themeManager.accentColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.glassSurfaceElevated))
                .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Try the quiz again")

            Button(action: onBack) {
                Text(QuizStrings.backToPassage)
                    .font(.system(size: 16, weight: .bold)).tracking(0.3)
                    .foregroundColor(themeManager.onAccentText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
                    .shadow(color: themeManager.accentColor.opacity(0.28), radius: 24, x: 0, y: 10)
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Back to passage")
        }
    }
}
```

**Step 3: Build**, expect success. Fix any token or helper name that differs from the fact sheet rather than inventing a new one.

**Step 4: Commit** (ask first): `git commit -m "quiz: question flow and results screens"`

---

### Task 8: Test yourself beside Mark as read in PassageView

**Files:**
- Create: `Thaqalayn/Views/Passages/QuizEntryButton.swift`
- Modify: `Thaqalayn/Views/Passages/PassageView.swift` (state vars near line 33, `markReadButton` use at line 161, `markReadButton` definition at line 335, hidden Understanding link at line 197, paywall sheet at line 229)

**Step 1: The button** (same height and radius as `EmJourneyToggleButton`: 17 pt vertical padding, radius 15, 16 pt bold label)

```swift
// Thaqalayn/Views/Passages/QuizEntryButton.swift
import SwiftUI

/// The quiz entry beside Mark as read. Quiet glass before the passage is read,
/// gold once it is read (the next step), a green chip with the best score once
/// taken, and the PREMIUM capsule when the surah is gated.
struct QuizEntryButton: View {
    enum Mode { case todo(passageRead: Bool), done(score: Int, total: Int), gated }

    let mode: Mode
    let onTap: () -> Void
    @ObservedObject private var tm = ThemeManager.shared

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                if case .gated = mode {
                    Text(QuizStrings.premium)
                        .emEyebrow(size: 10, tracking: 1.5)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(tm.accentChip))
                        .overlay(Capsule().stroke(tm.accentColor.opacity(0.35), lineWidth: 1))
                } else {
                    Text(label)
                        .font(.system(size: 16, weight: .bold)).tracking(0.3)
                        .lineLimit(1)
                }
            }
            .foregroundColor(foreground)
            .padding(.horizontal, 16)
            .padding(.vertical, 17)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(background))
            .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(border, lineWidth: 1))
            .shadow(color: isGold ? tm.accentColor.opacity(0.28) : .clear, radius: 24, x: 0, y: 10)
        }
        .buttonStyle(EmPressStyle())
        .accessibilityLabel(accessibility)
    }

    private var isGold: Bool { if case .todo(true) = mode { return true } else { return false } }

    private var icon: String {
        switch mode {
        case .done: return "checkmark.seal.fill"
        default: return "questionmark.circle"
        }
    }

    private var label: String {
        switch mode {
        case .done(let score, let total): return QuizStrings.score(score, of: total)
        default: return QuizStrings.entry
        }
    }

    private var foreground: Color {
        switch mode {
        case .todo(true): return tm.onAccentText
        case .done: return tm.semanticGreen
        default: return tm.accentColor
        }
    }

    private var background: AnyShapeStyle {
        switch mode {
        case .todo(true): return AnyShapeStyle(tm.accentGradient)
        case .done: return AnyShapeStyle(tm.semanticGreen.opacity(0.14))
        default: return AnyShapeStyle(tm.glassSurfaceElevated)
        }
    }

    private var border: Color {
        switch mode {
        case .todo(true): return .clear
        case .done: return tm.semanticGreen.opacity(0.5)
        default: return tm.strokeColor
        }
    }

    private var accessibility: String {
        switch mode {
        case .todo: return "Test yourself on this passage"
        case .done(let s, let t): return "Quiz best score \(s) of \(t). Tap to try again"
        case .gated: return "Test yourself, premium feature"
        }
    }
}
```

**Step 2: Wire it into PassageView**

Add observed objects and state next to the existing ones (line 27 onwards):

```swift
    @ObservedObject private var quizStore = QuizStore.shared
    @ObservedObject private var quizResults = QuizResultsStore.shared
    @State private var showingQuiz = false
```

Add derived values in `// MARK: - Derived`:

```swift
    private var quiz: PassageQuiz? { quizStore.quiz(for: ref) }
    private var isQuizGated: Bool { !premiumManager.canAccessQuiz(surahNumber: surah.number) }
    private var quizMode: QuizEntryButton.Mode {
        if isQuizGated { return .gated }
        if let best = quizResults.best(for: ref) { return .done(score: best.score, total: best.total) }
        return .todo(passageRead: isPassageRead)
    }
```

Replace the single `markReadButton` in the content stack (line 161, `.padding(.top, 28)`) with the pair:

```swift
                            HStack(alignment: .center, spacing: 12) {
                                markReadButton
                                if quiz != nil {
                                    QuizEntryButton(mode: quizMode, onTap: openQuiz)
                                        .fixedSize(horizontal: true, vertical: false)
                                }
                            }
                            .padding(.top, 28)
```

`EmJourneyToggleButton` already fills the remaining width (`frame(maxWidth: .infinity)`), so the pair lays out as in the mockup.

Add a hidden link beside the Understanding one (line 197):

```swift
            NavigationLink(destination: quizDestination, isActive: $showingQuiz) { EmptyView() }
                .hidden()
                .accessibilityHidden(true)
```

and the destination plus the action, near `openUnderstanding()`:

```swift
    @ViewBuilder private var quizDestination: some View {
        if let quiz {
            QuizView(surahWithTafsir: surahWithTafsir, ref: ref, quiz: quiz)
        } else {
            EmptyView()
        }
    }

    /// Gated surahs open the paywall, like the Understand card; otherwise push the quiz.
    private func openQuiz() {
        if isQuizGated {
            paywallContext = .inSurah(surah, "Quiz")
            showingPaywall = true
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showingQuiz = true }
    }
```

Two hidden `NavigationLink`s in one `.background` need a container: wrap both in a `ZStack { }` inside the existing `.background(...)`.

**Step 3: Build**, expect success.

**Step 4: Commit** (ask first): `git commit -m "passage: Test yourself button beside Mark as read"`

---

### Task 9: Quiz swipe action and score in the passage list

**Files:**
- Modify: `Thaqalayn/Views/Passages/SurahPassagesView.swift` (state near line 32, per-render lets at lines 76 to 80, `PassageRow` call at lines 118 to 126, swipe block at lines 132 to 147, hidden link at line 164, `PassageRow` struct at line 320)

**Step 1: State and per-render values**

Add observed objects and state:

```swift
    @ObservedObject private var quizStore = QuizStore.shared
    @ObservedObject private var quizResults = QuizResultsStore.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var quizTarget: PassageRef? = nil
    @State private var showingPaywall = false
```

At the top of `body`, after `savedIndices`:

```swift
        let quizIndices = quizStore.quizIndices(surah: surah.number)
        let bestScores = quizResults.bestScores(surah: surah.number)
        let quizGated = !premiumManager.canAccessQuiz(surahNumber: surah.number)
```

**Step 2: Row score.** Add `let bestScore: Int?` to `PassageRow` and pass `bestScore: bestScores[ref.index]` from the call site. In the trailing `HStack(spacing: 10)` of the row, before the heart:

```swift
                if let bestScore {
                    Text(QuizStrings.scoreShort(bestScore, of: 5))
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                        .accessibilityLabel("Quiz best score \(bestScore) of 5")
                }
```

**Step 3: Third swipe action.** After the Save button inside `.swipeActions(edge: .leading, allowsFullSwipe: true)`:

```swift
                            if quizIndices.contains(ref.index) {
                                Button {
                                    if quizGated {
                                        showingPaywall = true
                                    } else {
                                        quizTarget = ref
                                    }
                                } label: {
                                    Label(QuizStrings.swipe, systemImage: "questionmark.circle")
                                }
                                .tint(themeManager.semanticGreen)
                            }
```

Read stays the first button so the full swipe still marks read.

**Step 4: Push and paywall.** Next to the existing hidden `NavigationLink(destination: targetDestination, ...)` (line 164), inside the same `.background` (wrap both in a `ZStack`):

```swift
                NavigationLink(destination: quizDestination, isActive: quizTargetIsActive) { EmptyView() }
                    .hidden()
                    .accessibilityHidden(true)
```

with

```swift
    private var quizTargetIsActive: Binding<Bool> {
        Binding(get: { quizTarget != nil }, set: { if !$0 { quizTarget = nil } })
    }

    @ViewBuilder private var quizDestination: some View {
        if let ref = quizTarget, let quiz = quizStore.quiz(for: ref) {
            QuizView(surahWithTafsir: surahWithTafsir, ref: ref, quiz: quiz)
        } else {
            EmptyView()
        }
    }
```

and, on the screen's outer view, the paywall sheet in the same form PassageView uses:

```swift
        .sheet(isPresented: $showingPaywall) { PaywallView(context: .inSurah(surah, "Quiz")) }
```

**Step 5: Build**, expect success.

**Step 6: Commit** (ask first): `git commit -m "passage list: Quiz swipe action and best score"`

---

### Task 10: What's New entry

**Files:**
- Modify: `Thaqalayn/Models/WhatsNewItem.swift` (`WhatsNewCatalog.all`, newest entry at line 45)

Add at the top of the array (the manager sorts newest first anyway). Destination is al-Fatihah passage 1, which is free for everyone and has a quiz; no new destination case is needed.

```swift
        WhatsNewItem(
            id: "passage-quizzes",
            sfSymbol: "questionmark.circle",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 9, day: 13).date ?? .distantPast,
            destination: .passage(surah: 1, index: 1),
            title: "Test yourself on a passage",
            blurb: "Five quick questions after each passage, drawn only from what you just read. Swipe a passage in the list, or tap Test yourself beside Mark as read.",
            cta: "Try it in al-Fatihah"
        ),
```

Set `releaseDate` to the day the build ships. Build, expect success. Commit (ask first): `git commit -m "whats new: passage quizzes"`

---

### Task 11: Docs, full test run, build for the user

**Files:**
- Modify: `docs/plans/2026-09-11-passage-quiz-design.md`, section "App side (later, separate design)" at line 228: replace the paragraph with one line pointing at this plan and the decisions list above.
- Modify: `Thaqalayn.xcodeproj/project.pbxproj`: bump `CURRENT_PROJECT_VERSION` (all four occurrences of the current value) by one. Marketing version stays 9.1 unless 9.1 has been approved in App Store Connect since, in which case bump to 9.2 (a closed train refuses new builds).

**Steps**

1. Run the whole unit suite with the test command from the top. Expected: all `ThaqalaynTests` pass, including the four new files.
2. Build the app target. Expected: `BUILD SUCCEEDED`, no new warnings from the quiz files.
3. Hand over. The user tests on the simulator or a device themselves; do not launch the simulator. If they want a TestFlight build, archive and upload with the App Store Connect key exactly as on 2026-09-12:

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -configuration Release -destination 'generic/platform=iOS' \
  -archivePath /tmp/Thaqalayn.xcarchive archive -allowProvisioningUpdates \
  -authenticationKeyPath /Users/muhammadimranali/Documents/appstoreconnect_general.p8 \
  -authenticationKeyID JDUAKLDB8M -authenticationKeyIssuerID f706d3c7-b216-4036-a1b0-d67e0932f6b1
xcodebuild -exportArchive -archivePath /tmp/Thaqalayn.xcarchive -exportOptionsPlist tools/asc/ExportOptions.plist \
  -exportPath /tmp/Thaqalayn-export -allowProvisioningUpdates \
  -authenticationKeyPath /Users/muhammadimranali/Documents/appstoreconnect_general.p8 \
  -authenticationKeyID JDUAKLDB8M -authenticationKeyIssuerID f706d3c7-b216-4036-a1b0-d67e0932f6b1
```

4. Commit (ask first): docs and pbxproj in one commit, `git commit -m "quiz: app side shipped, design doc pointer, build N"`.

**What to check on device, for the user's hand-over note:**
- Al-Fatihah passage 1 (free): swipe left to right on the row shows Read, Save, Quiz; tapping Quiz opens the quiz. Bottom of the passage shows Mark as read beside Test yourself; the quiz button turns gold once the passage is marked read; after finishing, it shows the best score and the list row shows `n/5`.
- Any al-Baqarah passage as a free user: the button shows the PREMIUM capsule and the swipe action opens the paywall.
- In a quiz: tap an option, see the highlight, explanation and "Read this in the passage"; the link opens Understanding scrolled to the right block; Next question through to results; Try again resets; Back to passage returns to the passage.
- Reading text size: the prompt, options and explanation grow with the Aa control; chrome does not.
- Both themes render (Midnight Emerald and Light).

---

## Out of scope, on purpose

- Syncing scores to Supabase (decision 4). Revisit only if quizzes become progress.
- A quiz card on the Understanding screen or the Today tab.
- Shuffling options or drawing different questions per attempt.
- Analytics events.
- Widgets.
