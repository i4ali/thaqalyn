# Passage Reader Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace the per-verse surah screen and the five-layer commentary with the approved three-screen passage reader (Surah = passage list, Passage = its verses, Understanding = essay, verse by verse, perspectives, source sheet), reading `Data/passages_N.json`, gated once on the Understand button.

**Architecture:** Passage models decode `passages_N.json`; a `PassageIndex` derives every surah's passages from the `ruku` field already in `quran_data.json`, so all 114 surahs list passages even where no commentary exists yet. `PassageStore` loads passage files lazily. Progress stays per verse (existing `ProgressManager`, Supabase sync unchanged); a passage is read when all its verses are read, and reaching the end of a passage marks them. `SurahDetailView` keeps its init signature as a thin wrapper over the new `SurahPassagesView`, so the 40-plus navigation call sites compile unchanged. The five-layer UI, `TafsirLayer`, and `canAccessLayer` are deleted; `TafsirVerse` is slimmed to `quickOverview` (Gems) so `tafsir_N.json` keeps working for Gems and the widget build script until the gems split at release.

**Tech Stack:** SwiftUI, iOS 18.2 target, `NavigationView` with hidden `NavigationLink(isActive:)` (house pattern via `PressableNavLink`), XCTest target `ThaqalaynTests` (`@testable import Thaqalayn`), Xcode synchronized groups (new files need no pbxproj edit).

**Design:** `docs/plans/2026-09-05-passage-commentary-design.md` (reader section) and the approved mock "Passage Reading" (three screens; Understand button carries a Premium chip, never a lock; Next passage at the bottom of Passage and Understanding; Play/Bookmark/Gems appear on the tapped verse; reaching the end marks the passage read).

**Data on hand:** `Thaqalayn/Thaqalayn/Data/passages_2.json` with passages 2:1 to 2:5 (keys "1" to "5"). Every other passage shows "Understanding for this passage is coming in an update."

---

## Execution status (update when handing off between sessions)

Last updated 2026-09-05, end of the first session.

| Task | Status | Notes |
|---|---|---|
| 1 Passage models | done, uncommitted | `LocalizedText` already existed (`Models/DailyChallengeModels.swift:16`); `PassageModels.swift` extends it instead of redefining it. `readingMinutes` counts essay + notes + narrations + perspectives; the test was corrected to match. |
| 2 Passage index | done, uncommitted | Verbatim. `DataManager.passageIndex` is set right after `quranData` in `loadQuranData()`. |
| 3 Store, progress, gate | done, uncommitted | `verseProgress` is an array, so `readVerseKeys` has no `.values`. `markVerseAsRead` was split into `recordVerseRead` + `finishMarkingRead`; `markPassageRead` records each unread verse (one sawab each) then finishes once, so save, sync, streak and badge checks run once per passage; early return when the passage is already read. Known consequence: the "5 verses left" encouragement nudge in `updateEngagementNotifications` can be skipped when a passage marks several verses at once. |
| 4 Citation markup | done, uncommitted | Verbatim. 3 tests pass. |
| 5 Surah passages screen | done, uncommitted, unbuilt until Task 6 | `SurahDetailView.swift` is the wrapper plus `GoToVerseSheet` (byte-identical to HEAD). None of the old file's types (`ModernSurahHeader`, `ModernVerseCard`, `ModernTafsirTabs`, ...) or `FullScreenCommentaryView` were referenced elsewhere; all dropped. `FullScreenCommentaryView.swift` removed with plain `rm` (unstaged). Read state is computed once per render from `readVerseKeys` via `PassageProgress`, not per row. A `didOpenTargetVerse` flag stops the deep-link push from re-firing when the user pops back. `EmType` weight case is `.semiBold`. |
| 6 Passage screen | done, uncommitted, build succeeded | Deviations: eyebrow/title/sub scroll with the verses (only the chevron, TextSize and play row is pinned) to keep reading space; no chevron on the no-commentary Understand card; "1 verse"/"1 narration" singulars; the playing highlight does not require `.playing` state; playback auto-scroll checks surah and range. `NextPassageCard(surahWithTafsir:next:)` lives in `PassageView.swift` for Task 7. `UnderstandingView.swift` is a placeholder that Task 7 overwrites whole. `VerseSummaryView` still gets `onViewFullCommentary: {}` until Task 7. |
| 7 Understanding + source sheet | done, uncommitted, build succeeded | Serif UIFont resolves `EmType.Weight.face` ("CormorantGaramond-Medium"/"-SemiBold"; italic "CormorantGaramondItalic-MediumItalic"). Listen text strips `[n]` markers; a language change stops playback; falls back to English when the selected language is not in the passage. Bibliography sorted by marker number; Sources section hidden when empty. Source line "Sourced · work · locus" is not uppercased. `SourceSheet` gates excerpt and narrations on `tier == "C"`, shows the link only for a valid http(s) URL, and adds a "Cited in <surah> · <title>" context line and an xmark close. `onViewFullCommentary` is gone everywhere; `VerseSummaryView` lost its `languageManager`/`readingSettings` (only fed layer2). `TafsirVerse.getLayer2Short` now has no callers: delete it in Task 9. |
| 8 Home, continue reading, deep link, what's new | done, uncommitted, build succeeded | `ModernSurahCard` lives in `ContentView.swift`; it takes `readVerseKeys` (computed once per render in `EmeraldHomeView`, `HomeView`, `SearchResultsView`) and shows "40 passages" / "3 of 40 passages" on its own line in place of the verse percentage (the joined line overflows 375pt phones). Continue Reading lines allow 2 lines. `thaqalayn://passage` waits on `$passageIndex.values` then takes the verse route; like the verse route, a link during the splash has no listener yet (pre-existing). What's New entry `passages-baqarah` dated 2026-09-05 (placeholder); card title now wraps to 2 lines. `EmeraldHomeView`'s own continue-reading card still says "Verse N of T"; revisit. |
| 9 Remove five-layer types | done, uncommitted, build + full test bundle pass (56 tests) | `TafsirVerse` had no custom decoder, so the synthesized one now ignores the layer keys in `tafsir_N.json`. `FiveLayersScreen.swift` removed with plain `rm`; onboarding `totalPages` 14 to 13, tags renumbered. Chip palettes deleted; `HeroChip` preview uses `chipGold`. Paywall section title "Understanding" with the four rows; its subtitle "All 114 surahs · English, Urdu & Arabic" and the `PaywallContext` doc comments still describe layers: copy to revisit. `TafsirSourcesView` got the leading paragraph (Emerald body: prepended to the `EmHeading(sub:)` string). Notification body uses the first gem's `coreInsight`. |
| 10 Simulator run | partial, stopped for the 8.6 (107) TestFlight upload | Deep links landed as expected (verse 2:1 and passage 2:4 both open the Passage screen over the surah list). Fixes made from the screenshots: `TabBarVisibility` now counts hider tokens (`hide(_:)`/`show(_:)`) because a child's onAppear fires before its parent's onDisappear, so the bar reappeared one step into surah > passage > understanding; a deep link to a passage's first verse no longer scrolls (the title was pushed off the top); Arabic and RTL prose use `.leading` under a right-to-left `layoutDirection` instead of `.trailing`. Not yet captured: Understanding screen, source sheet, PREMIUM capsule, Next passage card (no simctl tap tool). Screenshots live in the session scratchpad only. |

Version bumped to 8.6 (107) on 2026-09-05 for a TestFlight device check; the test target stays at 1.0 (1).

Post-plan change after the device check (build 108): the Passage screen gained a pinned Understand bar above the bottom edge (`PassageView.pinnedUnderstandBar`), shown while the passage has commentary and the end-of-verses card is off screen, so Understanding is one tap away without scrolling through the verses. The hidden `NavigationLink` for Understanding moved from the lazy end card to the screen level so the bar can push before the card has ever been built. It stacks above the audio player when playback is showing.

Nothing from this plan has been committed yet; the user has chosen to skip commits so far. Ask before every commit. Every finished task passed its tests and a full `xcodebuild build`.

Facts learned that later tasks need:

- Build and test destination must be pinned by id on this machine: `-destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1'` (iPhone 16 Pro, iOS 18.6). `name=iPhone 16 Pro` alone fails because xcodebuild resolves to iOS 26.5 where only iPhone 17 models exist.
- `-quiet` hides the `Executed N tests` summary; the per-case `passed` lines are the evidence. Check `${pipestatus[1]}` (zsh) for xcodebuild's own exit code when piping into grep.
- One pre-existing warning in test builds, unrelated: `Views/SettingsView.swift:1540 'catch' block is unreachable`.
- SourceKit diagnostics in the editor (missing `XCTest`, `QuranData`) are noise; trust `xcodebuild`.
- Only one `xcodebuild` at a time: concurrent runs on the same derived data collide, so the tasks run sequentially, one subagent each.

## Conventions for every task

- Repo root: `/Users/muhammadimranali/Documents/development/thaqalyn`. App sources under `Thaqalayn/`, tests under `ThaqalaynTests/`.
- Build: `xcodebuild build -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' -quiet 2>&1 | grep -E "error|warning: unused|BUILD" | head -40`. Expected last line `** BUILD SUCCEEDED **` (with `-quiet`, no output means success; check `$?`).
- Tests: `xcodebuild test -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' -only-testing:ThaqalaynTests/<Class> -quiet 2>&1 | grep -E "Test Case|error|passed|failed" | head -40`. The first run compiles the whole app (several minutes); later runs are incremental.
- Theme: every new view declares `@ObservedObject private var themeManager = ThemeManager.shared` and uses its tokens (`primaryText`, `secondaryText`, `tertiaryText`, `accentColor`, `glassSurface`, `strokeColor`, `dividerColor`); background is `if themeManager.isMidnightEmerald { EmeraldBackground() } else { LinearGradient(colors: [themeManager.primaryBackground, themeManager.secondaryBackground], startPoint: .top, endPoint: .bottom) }`, same as `SurahDetailView.swift:48-62` today. Typography via `EmType.serif`, `EmType.serifItalic`, `EmType.arabic`, eyebrows via `.emEyebrow(size:tracking:)`. Components: `EmCard`, `EmNumeralCircle`, `EmDivider`, `EmGoldCTA`, `PressableNavLink`, `TextSizeButton` + `.textSizePanelOverlay`. Screens use `.navigationBarHidden(true)`, `.hideTabBar()`, `.preferredColorScheme(themeManager.colorScheme)`, `.darkScreenAura(glowOpacity: 0.22, starCount: 10)` like the current surah screen.
- Reading content scales: `@StateObject private var readingSettings = ReadingSettingsManager.shared`; multiply font size and line spacing by `readingSettings.scale` for Arabic, translations, essay, notes, narrations, perspectives, glosses. Never scale titles, eyebrows, labels, chips, buttons.
- Premium signal is a "PREMIUM" capsule in accent style (see `DailyCrosswordCard`), never `lock.fill`.
- English copy: plain spelling, no transliteration diacritics, no em dash.
- **Commits:** ask first with AskUserQuestion, list the files, commit only on approval, no co-author trailer.
- Do not touch `passages_work/`, `scripts/passage_pipeline/`, or `Data/tafsir_*.json`.

---

### Task 1: Passage models

**Files:**
- Create: `Thaqalayn/Models/PassageModels.swift`
- Create: `ThaqalaynTests/PassageModelsTests.swift`
- Create: `ThaqalaynTests/Fixtures/passage_2_4.json` (copy of the `"4"` object from `Thaqalayn/Thaqalayn/Data/passages_2.json`, produced with `.venv/bin/python -c "import json;d=json.load(open('Thaqalayn/Thaqalayn/Data/passages_2.json'));json.dump(d['4'],open('ThaqalaynTests/Fixtures/passage_2_4.json','w'),ensure_ascii=False,indent=2)"`)

**Step 1: Write the failing test**

```swift
// ThaqalaynTests/PassageModelsTests.swift
import XCTest
@testable import Thaqalayn

final class PassageModelsTests: XCTestCase {
    private func load() throws -> Passage {
        let url = Bundle(for: Self.self).url(forResource: "passage_2_4", withExtension: "json")!
        return try JSONDecoder().decode(Passage.self, from: Data(contentsOf: url))
    }

    func testDecodesRealPassage() throws {
        let p = try load()
        XCTAssertEqual(p.id, "2:4")
        XCTAssertEqual(p.surah, 2)
        XCTAssertEqual(p.index, 4)
        XCTAssertEqual(p.range, [30, 39])
        XCTAssertEqual(p.title.en, "Adam and the angels")
        XCTAssertTrue(p.essay.en.contains("[1]"))
        XCTAssertEqual(p.verses.first?.verse, 30)
        XCTAssertEqual(p.verses.first?.narrations.first?.id, "n1")
        XCTAssertEqual(p.verses.first?.narrations.first?.source, "s25")
        XCTAssertNotNil(p.perspectives)
        XCTAssertEqual(p.sources.first?.id, "s1")
        XCTAssertEqual(p.sources.first?.tier, "B")
        XCTAssertEqual(p.sources.first?.excerpt?.lang, "ar")
        XCTAssertEqual(p.status?.auditAttempts, 3)
    }

    func testDerivedCounts() throws {
        let p = try load()
        XCTAssertEqual(p.start, 30)
        XCTAssertEqual(p.end, 39)
        XCTAssertEqual(p.verseCount, 10)
        XCTAssertEqual(p.narrationCount, 12)
        XCTAssertEqual(p.source(id: "s2")?.work, "al-Mizan fi Tafsir al-Quran")
        XCTAssertNil(p.source(id: "s999"))
        XCTAssertEqual(p.readingMinutes, max(1, p.essay.en.split(separator: " ").count / 200 + 1))
    }

    func testLocalizedTextFallsBackToEnglish() {
        let t = LocalizedText(en: "Hello", ur: nil, ar: nil)
        XCTAssertEqual(t.text(for: .urdu), "Hello")
        XCTAssertEqual(t.text(for: .arabic), "Hello")
        XCTAssertEqual(t.availableLanguages, [.english])
        let u = LocalizedText(en: "Hello", ur: "ہیلو", ar: nil)
        XCTAssertEqual(u.text(for: .urdu), "ہیلو")
        XCTAssertEqual(u.availableLanguages, [.english, .urdu])
    }
}
```

**Step 2: Run test to verify it fails**

Run the test command with `-only-testing:ThaqalaynTests/PassageModelsTests`. Expected: compile error `cannot find type 'Passage' in scope`.

**Step 3: Write minimal implementation**

```swift
// Thaqalayn/Models/PassageModels.swift
//
//  Passage commentary models: one commentary per ruku, produced by
//  scripts/passages.py and shipped as Data/passages_<surah>.json keyed by the
//  passage index within the surah. See docs/plans/2026-09-05-passage-commentary-design.md.
//

import Foundation

/// English plus optional Urdu and Arabic renderings of one text field.
struct LocalizedText: Codable, Hashable {
    let en: String
    let ur: String?
    let ar: String?

    func text(for language: CommentaryLanguage) -> String {
        switch language {
        case .english: return en
        case .urdu: return ur ?? en
        case .arabic: return ar ?? en
        }
    }

    var availableLanguages: [CommentaryLanguage] {
        var langs: [CommentaryLanguage] = [.english]
        if ur != nil { langs.append(.urdu) }
        if ar != nil { langs.append(.arabic) }
        return langs
    }
}

struct Passage: Codable, Identifiable, Hashable {
    let id: String
    let surah: Int
    let index: Int
    let range: [Int]
    let title: LocalizedText
    let essay: LocalizedText
    let verses: [PassageVerseEntry]
    let perspectives: LocalizedText?
    let sources: [PassageSource]
    let status: PassageStatus?

    var start: Int { range[0] }
    var end: Int { range[1] }
    var verseCount: Int { end - start + 1 }
    var narrationCount: Int { verses.reduce(0) { $0 + $1.narrations.count } }

    func source(id: String) -> PassageSource? { sources.first { $0.id == id } }
    func entry(forVerse verse: Int) -> PassageVerseEntry? { verses.first { $0.verse == verse } }

    /// Whole minutes to read the understanding screen at 200 words a minute, at least 1.
    var readingMinutes: Int {
        var words = essay.en.split(separator: " ").count
        for v in verses {
            words += (v.note?.en ?? "").split(separator: " ").count
            words += v.narrations.reduce(0) { $0 + $1.text.en.split(separator: " ").count }
        }
        words += (perspectives?.en ?? "").split(separator: " ").count
        return max(1, words / 200 + 1)
    }
}

struct PassageVerseEntry: Codable, Identifiable, Hashable {
    let verse: Int
    let heading: LocalizedText?
    let note: LocalizedText?
    let narrations: [Narration]
    var id: Int { verse }
}

struct Narration: Codable, Identifiable, Hashable {
    let id: String
    let speaker: String
    let addressee: String?
    let arabic: String
    let chain: String?
    let text: LocalizedText
    let source: String
}

struct SourceExcerpt: Codable, Hashable {
    let lang: String
    let text: String
}

struct PassageSource: Codable, Identifiable, Hashable {
    let id: String
    let kind: String
    let work: String
    let author: String
    let tradition: String
    let tier: String
    let locus: String
    let url: String
    let excerpt: SourceExcerpt?
    let gloss: String?
    let grades: [String]?

    /// Marker number, so "s12" renders as [12].
    var number: Int { Int(id.dropFirst()) ?? 0 }
}

struct PassageStatus: Codable, Hashable {
    let gatheredAt: String?
    let auditAttempts: Int?
    let auditedAt: String?
    let assembledAt: String?

    enum CodingKeys: String, CodingKey {
        case gatheredAt = "gathered_at"
        case auditAttempts = "audit_attempts"
        case auditedAt = "audited_at"
        case assembledAt = "assembled_at"
    }
}
```

If decoding the real fixture fails on `grades` (a corpus hit may carry non-string gradings), change `grades` to `[String]?` decoded leniently via a custom `init(from:)` that maps each element with `String(describing:)`. Report if you had to.

**Step 4: Run test to verify it passes**

Expected: `Executed 3 tests, with 0 failures`.

**Step 5: Commit**

Ask first. `git add Thaqalayn/Models/PassageModels.swift ThaqalaynTests/PassageModelsTests.swift ThaqalaynTests/Fixtures/passage_2_4.json`, message `reader: passage models`.

---

### Task 2: Passage index from the ruku field

**Files:**
- Create: `Thaqalayn/Models/PassageIndex.swift`
- Create: `ThaqalaynTests/PassageIndexTests.swift`
- Modify: `Thaqalayn/Services/DataManager.swift` (add `passageIndex` built after `quranData` loads)

`Verse.ruku` (`Models/QuranModels.swift:50`) is a global running ruku number. Passages are numbered 1-based within the surah, exactly as `scripts/passage_pipeline/rukus.py` does it, so ids match the data files.

**Step 1: Write the failing test**

```swift
// ThaqalaynTests/PassageIndexTests.swift
import XCTest
@testable import Thaqalayn

final class PassageIndexTests: XCTestCase {
    private func index() throws -> PassageIndex {
        let url = Bundle.main.url(forResource: "quran_data", withExtension: "json")!
        let data = try JSONDecoder().decode(QuranData.self, from: Data(contentsOf: url))
        return PassageIndex(quran: data)
    }

    func testCounts() throws {
        let idx = try index()
        XCTAssertEqual(idx.passages(forSurah: 2).count, 40)
        XCTAssertEqual(idx.passages(forSurah: 1).count, 1)
        XCTAssertEqual((1...114).reduce(0) { $0 + idx.passages(forSurah: $1).count }, 556)
    }

    func testAdamPassage() throws {
        let idx = try index()
        let p = idx.passage(surah: 2, index: 4)!
        XCTAssertEqual(p.start, 30)
        XCTAssertEqual(p.end, 39)
        XCTAssertEqual(p.id, "2:4")
        XCTAssertEqual(p.verses, Array(30...39))
        XCTAssertNil(idx.passage(surah: 2, index: 41))
    }

    func testPassageForVerse() throws {
        let idx = try index()
        XCTAssertEqual(idx.passage(surah: 2, containing: 141)?.index, 16)
        XCTAssertEqual(idx.passage(surah: 2, containing: 253)?.index, 33)
        XCTAssertEqual(idx.passage(surah: 1, containing: 7)?.index, 1)
        XCTAssertNil(idx.passage(surah: 2, containing: 300))
    }

    func testNextPassage() throws {
        let idx = try index()
        XCTAssertEqual(idx.next(after: idx.passage(surah: 2, index: 4)!)?.id, "2:5")
        XCTAssertNil(idx.next(after: idx.passage(surah: 2, index: 40)!))
    }
}
```

**Step 2: Run test to verify it fails**

Expected: `cannot find type 'PassageIndex' in scope`.

**Step 3: Write minimal implementation**

```swift
// Thaqalayn/Models/PassageIndex.swift
import Foundation

/// One ruku of one surah, the unit of the passage reader. Exists for every
/// surah whether or not commentary has been generated for it.
struct PassageRef: Hashable, Identifiable {
    let surah: Int
    let index: Int
    let start: Int
    let end: Int

    var id: String { "\(surah):\(index)" }
    var verses: [Int] { Array(start...end) }
    var verseCount: Int { end - start + 1 }
    var rangeLabel: String { start == end ? "\(start)" : "\(start) to \(end)" }
}

/// Passage boundaries for all 114 surahs, derived once from quran_data.json.
struct PassageIndex {
    private let bySurah: [Int: [PassageRef]]

    init(quran: QuranData) {
        var out: [Int: [PassageRef]] = [:]
        for surah in quran.surahs {
            guard let verses = quran.verses[String(surah.number)] else { continue }
            var groups: [Int: [Int]] = [:]
            for (key, rec) in verses {
                guard let n = Int(key) else { continue }
                groups[rec.ruku, default: []].append(n)
            }
            let refs = groups.keys.sorted().enumerated().map { i, ruku -> PassageRef in
                let vs = groups[ruku]!
                return PassageRef(surah: surah.number, index: i + 1, start: vs.min()!, end: vs.max()!)
            }
            out[surah.number] = refs
        }
        bySurah = out
    }

    func passages(forSurah surah: Int) -> [PassageRef] { bySurah[surah] ?? [] }

    func passage(surah: Int, index: Int) -> PassageRef? {
        let refs = passages(forSurah: surah)
        guard index >= 1, index <= refs.count else { return nil }
        return refs[index - 1]
    }

    func passage(surah: Int, containing verse: Int) -> PassageRef? {
        passages(forSurah: surah).first { $0.start <= verse && verse <= $0.end }
    }

    func next(after ref: PassageRef) -> PassageRef? { passage(surah: ref.surah, index: ref.index + 1) }
    func previous(before ref: PassageRef) -> PassageRef? { passage(surah: ref.surah, index: ref.index - 1) }
}
```

In `DataManager`: add `@Published var passageIndex: PassageIndex?` next to `quranData` (`DataManager.swift:14`) and set it right after `quranData` is assigned inside `loadQuranData()` (`DataManager.swift:60-85`): `self.passageIndex = PassageIndex(quran: decoded)`. Check the `QuranData.verses` type in `Models/QuranModels.swift:12-15` and adapt the two lookups if the dictionary keys differ from `String`.

**Step 4: Run test to verify it passes**

Expected: `Executed 4 tests, with 0 failures`. Then run the build command; expected success.

**Step 5: Commit**

Ask first. `git add Thaqalayn/Models/PassageIndex.swift ThaqalaynTests/PassageIndexTests.swift Thaqalayn/Services/DataManager.swift`, message `reader: passage index from the ruku field`.

---

### Task 3: PassageStore and passage progress

**Files:**
- Create: `Thaqalayn/Services/PassageStore.swift`
- Create: `Thaqalayn/Services/PassageProgress.swift`
- Create: `ThaqalaynTests/PassageStoreTests.swift`
- Create: `ThaqalaynTests/PassageProgressTests.swift`
- Modify: `Thaqalayn/Services/ProgressManager.swift` (two small additions)
- Modify: `Thaqalayn/Services/PremiumManager.swift` (add `canAccessUnderstanding`)

**Step 1: Write the failing tests**

```swift
// ThaqalaynTests/PassageStoreTests.swift
import XCTest
@testable import Thaqalayn

@MainActor
final class PassageStoreTests: XCTestCase {
    func testLoadsBundledPassage() {
        let store = PassageStore()
        let p = store.passage(surah: 2, index: 4)
        XCTAssertEqual(p?.title.en, "Adam and the angels")
        XCTAssertTrue(store.hasCommentary(surah: 2, index: 4))
        XCTAssertFalse(store.hasCommentary(surah: 2, index: 6))
        XCTAssertNil(store.passage(surah: 3, index: 1))
        XCTAssertEqual(store.passageCount(withCommentary: 2), 5)
        XCTAssertEqual(store.passageCount(withCommentary: 3), 0)
    }
}
```

```swift
// ThaqalaynTests/PassageProgressTests.swift
import XCTest
@testable import Thaqalayn

final class PassageProgressTests: XCTestCase {
    let adam = PassageRef(surah: 2, index: 4, start: 30, end: 39)

    func testReadWhenEveryVerseRead() {
        let all = Set((30...39).map { "2:\($0)" })
        XCTAssertTrue(PassageProgress.isRead(adam, readVerseKeys: all))
        XCTAssertFalse(PassageProgress.isRead(adam, readVerseKeys: all.subtracting(["2:35"])))
        XCTAssertFalse(PassageProgress.isRead(adam, readVerseKeys: []))
    }

    func testCountsReadPassages() {
        let refs = [PassageRef(surah: 2, index: 1, start: 1, end: 7),
                    PassageRef(surah: 2, index: 2, start: 8, end: 20), adam]
        let keys = Set((1...7).map { "2:\($0)" } + (30...39).map { "2:\($0)" })
        XCTAssertEqual(PassageProgress.readCount(refs, readVerseKeys: keys), 2)
    }
}
```

Also in `PassageStoreTests`, add:

```swift
    func testUnderstandingGate() {
        XCTAssertTrue(PremiumManager.shared.canAccessUnderstanding(surahNumber: 1))
        XCTAssertEqual(PremiumManager.shared.canAccessUnderstanding(surahNumber: 2), PremiumManager.shared.isPremium)
    }
```

**Step 2: Run tests to verify they fail**

Expected: `cannot find 'PassageStore' in scope`, `cannot find 'PassageProgress' in scope`.

**Step 3: Write minimal implementation**

```swift
// Thaqalayn/Services/PassageStore.swift
import Foundation

/// Lazily loads Data/passages_<surah>.json (one file per surah, keyed by the
/// passage index as a string) and caches it. A missing file means no
/// commentary has been generated for that surah yet.
@MainActor
final class PassageStore: ObservableObject {
    static let shared = PassageStore()

    private var cache: [Int: [String: Passage]] = [:]
    private var missing: Set<Int> = []

    init() {}

    private func load(surah: Int) -> [String: Passage] {
        if let cached = cache[surah] { return cached }
        if missing.contains(surah) { return [:] }
        guard let url = Bundle.main.url(forResource: "passages_\(surah)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([String: Passage].self, from: data) else {
            missing.insert(surah)
            return [:]
        }
        cache[surah] = decoded
        return decoded
    }

    func passage(surah: Int, index: Int) -> Passage? { load(surah: surah)[String(index)] }
    func hasCommentary(surah: Int, index: Int) -> Bool { passage(surah: surah, index: index) != nil }
    func passageCount(withCommentary surah: Int) -> Int { load(surah: surah).count }
}
```

```swift
// Thaqalayn/Services/PassageProgress.swift
import Foundation

/// Passage read state derived from the per-verse progress that ProgressManager
/// already stores and syncs. A passage is read when every verse in it is read.
enum PassageProgress {
    static func isRead(_ ref: PassageRef, readVerseKeys: Set<String>) -> Bool {
        ref.verses.allSatisfy { readVerseKeys.contains("\(ref.surah):\($0)") }
    }

    static func readCount(_ refs: [PassageRef], readVerseKeys: Set<String>) -> Int {
        refs.filter { isRead($0, readVerseKeys: readVerseKeys) }.count
    }
}
```

In `ProgressManager.swift`, add (next to `isVerseRead` at `:491`):

```swift
    /// Keys "surah:verse" of every verse marked read. Used by the passage reader.
    var readVerseKeys: Set<String> {
        Set(verseProgress.values.filter { $0.isRead }.map { $0.verseKey })
    }

    func isPassageRead(_ ref: PassageRef) -> Bool {
        PassageProgress.isRead(ref, readVerseKeys: readVerseKeys)
    }

    /// Reaching the end of a passage marks every verse in it read, once.
    func markPassageRead(_ ref: PassageRef) {
        for v in ref.verses where !isVerseRead(surahNumber: ref.surah, verseNumber: v) {
            markVerseAsRead(surahNumber: ref.surah, verseNumber: v)
        }
    }
```

Read `ProgressManager.swift:396-456` first: `verseProgress` may be a dictionary or an array and `isVerseRead` may take different labels; match the real names. If `markVerseAsRead` awards sawab and posts haptics per verse, add a `quiet: Bool = false` parameter path or call a shared private helper so marking ten verses at once does not fire ten haptics; keep the sawab (one per verse is the existing rule) and call `saveProgress()` and `scheduleSync()` once at the end.

In `PremiumManager.swift` after `canAccessQuiz` (`:125-133`):

```swift
    /// The single gate of the passage reader: the Understand button. Surah 1 is free.
    func canAccessUnderstanding(surahNumber: Int) -> Bool {
        if surahNumber == 1 { return true }
        return isPremium
    }
```

**Step 4: Run tests to verify they pass**

Expected: `PassageStoreTests` 2 tests, `PassageProgressTests` 2 tests, 0 failures. Build succeeds.

**Step 5: Commit**

Ask first. Files: the four new files plus `ProgressManager.swift`, `PremiumManager.swift`. Message `reader: passage store, passage progress, understanding gate`.

---

### Task 4: Citation markup

**Files:**
- Create: `Thaqalayn/Utilities/PassageMarkup.swift`
- Create: `ThaqalaynTests/PassageMarkupTests.swift`

Essay, notes and perspectives carry markers like `[1]`. On screen they render as superscript numbers the reader can tap to open the source sheet. `Text(AttributedString)` renders `.link` attributes as tappable and `OpenURLAction` intercepts the URL, so markers become links `thaqalayn-source://<n>`.

**Step 1: Write the failing test**

```swift
// ThaqalaynTests/PassageMarkupTests.swift
import XCTest
@testable import Thaqalayn

final class PassageMarkupTests: XCTestCase {
    func testSegments() {
        let segs = PassageMarkup.segments("Tabatabai reads it [1] as a request [12].")
        XCTAssertEqual(segs, [.text("Tabatabai reads it "), .marker(1), .text(" as a request "), .marker(12), .text(".")])
        XCTAssertEqual(PassageMarkup.segments("No markers."), [.text("No markers.")])
        XCTAssertEqual(PassageMarkup.segments(""), [])
    }

    func testMarkerNumbers() {
        XCTAssertEqual(PassageMarkup.markerNumbers("a [3] b [1] c [3]"), [3, 1])
    }

    func testAttributedStringCarriesLinks() {
        let attr = PassageMarkup.attributed("Read [2] this.", baseFont: .systemFont(ofSize: 16), color: .black, accent: .blue)
        var links: [URL] = []
        for run in attr.runs { if let l = run.link { links.append(l) } }
        XCTAssertEqual(links, [URL(string: "thaqalayn-source://2")!])
        XCTAssertEqual(String(attr.characters), "Read 2 this.")
        XCTAssertEqual(PassageMarkup.sourceNumber(from: URL(string: "thaqalayn-source://2")!), 2)
        XCTAssertNil(PassageMarkup.sourceNumber(from: URL(string: "https://example.com")!))
    }
}
```

**Step 2: Run test to verify it fails**

Expected: `cannot find 'PassageMarkup' in scope`.

**Step 3: Write minimal implementation**

```swift
// Thaqalayn/Utilities/PassageMarkup.swift
import SwiftUI
import UIKit

/// Citation markers "[n]" inside passage prose. Rendered as superscript links so
/// a tap opens the source sheet for source s<n>.
enum PassageMarkup {
    enum Segment: Equatable {
        case text(String)
        case marker(Int)
    }

    static let scheme = "thaqalayn-source"
    private static let markerRegex = try! NSRegularExpression(pattern: #"\[(\d+)\]"#)

    static func segments(_ text: String) -> [Segment] {
        guard !text.isEmpty else { return [] }
        var out: [Segment] = []
        var cursor = text.startIndex
        let ns = text as NSString
        for m in markerRegex.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
            guard let whole = Range(m.range, in: text), let numRange = Range(m.range(at: 1), in: text) else { continue }
            if cursor < whole.lowerBound { out.append(.text(String(text[cursor..<whole.lowerBound]))) }
            out.append(.marker(Int(text[numRange]) ?? 0))
            cursor = whole.upperBound
        }
        if cursor < text.endIndex { out.append(.text(String(text[cursor...]))) }
        return out
    }

    /// Distinct marker numbers in order of first appearance.
    static func markerNumbers(_ text: String) -> [Int] {
        var seen: [Int] = []
        for case .marker(let n) in segments(text) where !seen.contains(n) { seen.append(n) }
        return seen
    }

    static func url(forSource n: Int) -> URL { URL(string: "\(scheme)://\(n)")! }

    static func sourceNumber(from url: URL) -> Int? {
        guard url.scheme == scheme else { return nil }
        return Int(url.host ?? "")
    }

    /// Prose with markers turned into small raised accent-coloured numbers that link
    /// to `thaqalayn-source://n`. `baseFont` is the already scaled body font.
    static func attributed(_ text: String, baseFont: UIFont, color: UIColor, accent: UIColor) -> AttributedString {
        var result = AttributedString()
        let markerFont = baseFont.withSize(baseFont.pointSize * 0.62)
        for seg in segments(text) {
            switch seg {
            case .text(let s):
                var a = AttributedString(s)
                a.font = baseFont
                a.foregroundColor = color
                result.append(a)
            case .marker(let n):
                var a = AttributedString("\(n)")
                a.font = markerFont
                a.foregroundColor = accent
                a.baselineOffset = baseFont.pointSize * 0.35
                a.link = url(forSource: n)
                result.append(a)
            }
        }
        return result
    }
}
```

**Step 4: Run test to verify it passes**

Expected: 3 tests, 0 failures.

**Step 5: Commit**

Ask first. Message `reader: citation markup`.

---

### Task 5: Surah passages screen and the SurahDetailView wrapper

**Files:**
- Create: `Thaqalayn/Views/Passages/SurahPassagesView.swift`
- Modify: `Thaqalayn/Views/SurahDetailView.swift` (replace the whole file with a thin wrapper; keep `GoToVerseSheet`)
- Delete: `Thaqalayn/Views/FullScreenCommentaryView.swift`

This task removes the old surah screen and its dead five-chip code in one move, because the wrapper is what every call site uses. It will not compile until Task 6 adds `PassageView`, so Tasks 5 and 6 are committed together; the build check comes at the end of Task 6.

**Step 1: Rewrite `SurahDetailView.swift`**

Keep `GoToVerseSheet` (`SurahDetailView.swift:204-324`) verbatim. Replace everything else with:

```swift
//
//  SurahDetailView.swift
//  Thaqalayn
//
//  Entry point every navigation site uses to open a surah. Since the passage
//  reader (2026-09) it is a thin wrapper over SurahPassagesView: a surah is a
//  list of its passages; targetVerse opens the passage that holds the verse.
//

import SwiftUI

struct SurahDetailView: View {
    let surahWithTafsir: SurahWithTafsir
    let targetVerse: Int?
    let targetConceptId: String?

    init(surahWithTafsir: SurahWithTafsir, targetVerse: Int? = nil, targetConceptId: String? = nil) {
        self.surahWithTafsir = surahWithTafsir
        self.targetVerse = targetVerse
        self.targetConceptId = targetConceptId
    }

    var body: some View {
        SurahPassagesView(surahWithTafsir: surahWithTafsir, targetVerse: targetVerse, targetConceptId: targetConceptId)
    }
}
```

**Step 2: Write `SurahPassagesView`**

Spec (mock "Surah" screen):

- Background and screen modifiers per Conventions. Custom header (nav bar hidden): back chevron (`dismiss`), title = `surah.englishName`, sub line `"\(englishNameTranslation) · \(revelationType) · \(passages.count) passages · \(readCount) read"`, right side two chips: `magnifyingglass` (go to verse) and `play.fill` (Listen, whole surah: `Task { await AudioManager.shared.playVerseSequence(surahWithTafsir.verses, in: surah, startingFrom: 0) }`, exactly as `ModernSurahHeader` does at `SurahDetailView.swift:368`).
- List: `ScrollView` + `LazyVStack(spacing: 0)` of rows, one per `PassageRef` from `DataManager.shared.passageIndex?.passages(forSurah:)`. Row: leading glyph `Text("ع").font(EmType.arabic(20))` in `themeManager.accentColor`; title `EmType.serif(17, .semibold)` = `PassageStore.shared.passage(surah:index:)?.title.en` or `"Verses \(ref.rangeLabel)"` when no commentary; sub line `"\(ref.rangeLabel)"` (plus `" · coming soon"` in tertiary text when no commentary, small); trailing state: `checkmark` in accent when `progressManager.isPassageRead(ref)`, the word `reading` in accent when `ref == lastReadRef`, else nothing. Rows separated by `themeManager.dividerColor` hairlines. The `reading` row gets a faint accent background (`themeManager.accentColor.opacity(0.08)`, corner radius 10).
- Row tap: `PressableNavLink { PassageView(surahWithTafsir:, ref:) } label: { row }`.
- `lastReadRef`: from `ProgressManager.shared.lastReadInfo` when its `surahNumber == surah.number`, via `passageIndex.passage(surah:containing:)`.
- Go to verse: `.sheet` with the existing `GoToVerseSheet(versesCount:onGoToVerse:)`; on a number, set `pendingTarget = (verse, nil)` which drives a hidden `NavigationLink(isActive:)` to `PassageView(surahWithTafsir:, ref: containing, scrollToVerse: verse, openConceptId: nil)`.
- Deep link: `.onAppear`, if `targetVerse != nil`, after 0.3s set the same `pendingTarget = (targetVerse, targetConceptId)` so the passage is pushed automatically (this is how Continue Reading, bookmarks, search, notifications and widgets land on a passage).
- Bottom overlay `SurahAudioPlayerView()` when `audioManager.currentPlayback != nil`, as the old screen did at `SurahDetailView.swift:150-156`.
- Managers: `ThemeManager.shared`, `ProgressManager.shared`, `AudioManager.shared`, `DataManager.shared`, `PassageStore.shared` (all `@ObservedObject`/`@StateObject` per how each is declared today).

**Step 3: Delete `FullScreenCommentaryView.swift`**

`git rm Thaqalayn/Views/FullScreenCommentaryView.swift`. Its only external references were in the old `SurahDetailView` body and in `VerseSummaryView`/`QuickOverviewView` via `onViewFullCommentary` (handled in Task 7).

No build yet. Proceed to Task 6.

---

### Task 6: Passage screen

**Files:**
- Create: `Thaqalayn/Views/Passages/PassageView.swift`

Spec (mock "Passage" screen):

- Init: `PassageView(surahWithTafsir: SurahWithTafsir, ref: PassageRef, scrollToVerse: Int? = nil, openConceptId: String? = nil)`.
- Header: back chevron (title "‹ \(surah.englishName)" style like other screens: chevron only), right: `TextSizeButton(isPanelOpen: $showTextSizePanel)` and a play chip that plays this passage: `playVerseSequence(versesInRange, in: surah, startingFrom: 0)` where `versesInRange = surahWithTafsir.verses.filter { ref.start...ref.end ~= $0.number }`. Eyebrow `"Passage \(ref.index) of \(total) · verses \(ref.rangeLabel)"`, title `passage?.title.en ?? "Verses \(ref.rangeLabel)"` in `EmType.serif(30, .semibold)`, sub `"\(ref.verseCount) verses · \(minutes) min"` where minutes = `max(1, totalTranslationWords / 200 + 1)`.
- Verses: `ScrollViewReader` + `ScrollView` + `LazyVStack(spacing: 0)`, one `PassageVerseRow` per verse in range with `.id("verse_\(n)")`. Row: `EmNumeralCircle(n: verse.number, size: 30)`; Arabic `Text(verse.arabicText).font(EmType.arabic(27 * scale)).lineSpacing(12 * scale).multilineTextAlignment(.trailing).frame(maxWidth: .infinity, alignment: .trailing).environment(\.layoutDirection, .rightToLeft)`; translation `EmType.serif(17 * scale, .medium)` with `.lineSpacing(6 * scale)`; hairline divider. Tapping a row toggles `selectedVerse`; the selected row shows an action row below the translation: `VerseRecitationButton(surahNumber:verseNumber:size: 32)`, a bookmark heart (use `BookmarkManager` exactly as `ModernVerseCard.toggleBookmark()` at old `SurahDetailView.swift:601-622`, copy that logic), and a Gems chip (`sparkles`) that presents `VerseSummaryView` via `.fullScreenCover(item: $selectedVerseForSummary)` gated by `premiumManager.canAccessOverview(surahNumber:)`, otherwise `PaywallView(context: .inSurah(surah, "Gems"))`. The currently playing verse (`audioManager.currentPlayback?.surahNumber == surah.number && verseNumber == n`) gets a faint accent background, and playback auto-scrolls like the old screen (`SurahDetailView.swift:134-141`).
- After the last verse, the **Understand** button: `EmCard`-style gold card (accent border, `accentColor.opacity(0.10)` fill) with leading `Text("ع").font(EmType.arabic(22))`, title "Understand this passage" `EmType.serif(18, .semibold)`, sub in secondary text: when commentary exists `"Essay · \(passage.narrationCount) narrations · \(passage.readingMinutes) min"`, else `"Understanding for this passage is coming in an update"` and the card is dimmed (`opacity 0.55`) and not tappable. Trailing: chevron, or a `PREMIUM` capsule (accent text on `accentColor.opacity(0.14)`, `.emEyebrow(size: 10, tracking: 1.5)`) when `!premiumManager.canAccessUnderstanding(surahNumber:)`. Tap: if gated, `showingPaywall = true` with `paywallContext = .inSurah(surah, "Understanding")` (`.sheet`); else push `UnderstandingView(surahWithTafsir:, ref:, passage:)` via a hidden `NavigationLink(isActive:)`.
- Below it, **Next passage** plain card: title "Next passage", sub `"\(nextTitle) · \(next.rangeLabel)"`, chevron; `PressableNavLink` to `PassageView(surahWithTafsir:, ref: next)`. Hidden when `next == nil`.
- Marking read: a zero-height `Color.clear.frame(height: 1).onAppear { progressManager.markPassageRead(ref) }` placed after the Understand button, so reaching the end marks the passage.
- `scrollToVerse`: `.onAppear` waits 0.4s then `proxy.scrollTo("verse_\(n)", anchor: .center)`; if `openConceptId != nil`, after a further 0.45s present `VerseSummaryView` for that verse with `initialConceptId` (mirrors old `SurahDetailView.swift:116-133`).
- `.textSizePanelOverlay(isOpen: $showTextSizePanel, topPadding: 60, trailingPadding: 20)`, bottom `SurahAudioPlayerView()` overlay when playing, `.sheet(isPresented: $showingPaywall) { PaywallView(context: paywallContext) }`.
- `VerseSummaryView(verse:surah:onViewFullCommentary:initialConceptId:)` still takes `onViewFullCommentary` until Task 7; pass `{}` for now.

**Step: Build**

Run the build command. Fix compile errors until `BUILD SUCCEEDED`. Common ones: `EmNumeralCircle` argument labels, `PaywallContext.inSurah` signature (`PaywallView.swift:37-41`), `BookmarkManager` API (`Services/BookmarkManager.swift`), how `DataManager.shared.passageIndex` is published.

**Step: Commit (Tasks 5 and 6 together)**

Ask first. `git add Thaqalayn/Views/Passages/SurahPassagesView.swift Thaqalayn/Views/Passages/PassageView.swift Thaqalayn/Views/SurahDetailView.swift && git rm Thaqalayn/Views/FullScreenCommentaryView.swift`, message `reader: surah passage list and passage screen replace the verse-card reader`.

---

### Task 7: Understanding screen and source sheet

**Files:**
- Create: `Thaqalayn/Views/Passages/UnderstandingView.swift`
- Create: `Thaqalayn/Views/Passages/SourceSheet.swift`
- Modify: `Thaqalayn/Views/VerseSummaryView.swift` (remove the layer2 fallback and the "Read In-Depth Commentary" CTA; drop `onViewFullCommentary`)
- Modify: `Thaqalayn/Views/QuickOverviewView.swift` (drop `onViewFullCommentary`, `:215-225, :402, :583`)
- Modify: `Thaqalayn/Views/Passages/PassageView.swift` (drop the `{}` argument)

Spec (mock "Understanding" screen):

- Init `UnderstandingView(surahWithTafsir:, ref: PassageRef, passage: Passage)`.
- Header: back chevron; right: `TextSizeButton` and a Listen chip. Eyebrow `"Understanding · \(surah.englishName) \(ref.rangeLabel)"`, title `passage.title.text(for: lang)` in `EmType.serif(30, .semibold)`.
- Language pills: only when `passage.essay.availableLanguages.count > 1`; pills for each available language (`displayName` from `CommentaryLanguage`), selection bound to `CommentaryLanguageManager.shared.selectedLanguage` (read `Services/CommentaryLanguageManager.swift` for the API). With English only, no pills. RTL: when `lang.isRTL`, essay, notes and perspectives get `.multilineTextAlignment(.trailing)` and `.environment(\.layoutDirection, .rightToLeft)`.
- Listen: `TafsirReader.shared` (`Services/TafsirReader.swift`, `speak(text:language:)`, `togglePlayPause()`, `stop()`, published `isPlaying`/`isPaused`). Text = essay, then each verse entry's heading, note and narration English, then perspectives, joined with blank lines, all in `lang`. Chip shows `play.fill` / `pause.fill`. `.onDisappear { TafsirReader.shared.stop() }`.
- Essay: paragraphs split on `"\n\n"`; each is `Text(PassageMarkup.attributed(paragraph, baseFont: serifUIFont(17 * scale), color: UIColor(themeManager.primaryText), accent: UIColor(themeManager.accentColor))).lineSpacing(6 * scale)`. To get the serif `UIFont`, add a small helper in `UnderstandingView` that resolves the same family name `EmType.serif` uses (read `EmeraldComponents.swift:13-22` for the exact font name) with `UIFont(name:size:) ?? .systemFont(ofSize:)`. Wrap the content in `.environment(\.openURL, OpenURLAction { url in if let n = PassageMarkup.sourceNumber(from: url) { openSource(n); return .handled }; return .systemAction })`.
- Section "Verse by verse" (`EmDivider(label:)`), only if `passage.verses` is non-empty. Each entry: header row `EmNumeralCircle(n:size: 26)` + heading `EmType.serif(17, .semibold)`; note in `EmType.serifItalic(16 * scale)` secondary text with markers via `PassageMarkup.attributed`; each narration as a block with a 2pt accent left rule: speaker `EmType.serif(15, .semibold)` (+ `" to \(addressee)"` in secondary when present), English text `EmType.serif(16 * scale, .medium)` italic-free, Arabic `EmType.arabic(20 * scale)` trailing aligned RTL, then a source line `.emEyebrow(size: 10, tracking: 1)`: `"Sourced · \(source.work) · \(source.locus)"` as a `Button` that calls `openSource(source.number)`. The Arabic of a narration is reading content and scales; it is shown collapsed by default behind a small "Arabic" toggle per narration? No: show it always, the design shows verbatim Arabic on the source sheet and the English in place. Decision: English in place, Arabic on the source sheet only. Keep the narration block to speaker, text, source line.
- Section "Perspectives": only when `passage.perspectives != nil`; same paragraph rendering as the essay.
- Section "Sources": `EmDivider(label: "Sources")` then one compact row per `passage.sources` in id order: `[n]` number in accent, `work`, `author` secondary, `locus` tertiary; tap opens the sheet. This is the reader's bibliography and lets a reader browse without hunting for markers.
- Next passage card at the bottom (same component as PassageView; extract `NextPassageCard(surahWithTafsir:next:)` into `PassageView.swift` or a shared file and reuse it).
- Source sheet: `.sheet(item: $openedSource)` presenting `SourceSheet(source: PassageSource, passage: Passage, surahName: String)` with `.presentationDetents([.medium, .large])`. Content: eyebrow `"Source \(n) · \(tradition == "sunni" ? "Sunni" : "Shia") · \(kind == "hadith" ? "narration" : "commentary")"`; title `work` `EmType.serif(24, .semibold)`; author secondary; locus tertiary; if `excerpt != nil`: `EmDivider(label: "Excerpt")`, Arabic `EmType.arabic(22 * scale)` RTL trailing, then `gloss` in `EmType.serifItalic(16 * scale)`; if the source is cited by narrations (`passage.verses.flatMap(\.narrations).filter { $0.source == source.id }`), for each show speaker, `chain` (secondary, small) and the narration `arabic` at `EmType.arabic(20 * scale)`; grades if present as a tertiary line `"Grading: \(grades.joined(", "))"`; a `Link("Open on \(host)", destination: URL(string: url)!)` at the bottom in accent. Tier C (no excerpt) shows work, author, locus and the link only.
- `VerseSummaryView`: delete `textBasedOverviewView`'s `getLayer2Short` branch and the `EmGoldCTA("Read In-Depth Commentary")` (`:112-130`, `:236-260` legacy), so the fallback is just the "Overview not available for this verse." text; remove `onViewFullCommentary` from its init and from `QuickOverviewView` (`:215-225`, `:402`, `:583`) and from all callers (grep `onViewFullCommentary`).

**Step: Build**

Build must succeed. Then commit (ask first): `reader: understanding screen with tappable citations and source sheet`.

---

### Task 8: Home, Continue Reading, search, deep links, What's New

**Files:**
- Modify: `Thaqalayn/Views/DeepDive/SurahListRow.swift` and the `ModernSurahCard` it uses (find with `grep -rn "struct ModernSurahCard" Thaqalayn`): subtitle gains `" · \(passageCount) passages"`; if the card shows a verse-based completion, switch it to `"\(read) of \(total) passages"` using `ProgressManager.shared.readVerseKeys` + `PassageProgress.readCount`.
- Modify: `Thaqalayn/Views/TodayView.swift` `EmContinueReadingCard` (`:927-`) and `ContinueReadingCard` (`:409-`): the line that names the verse becomes the passage title and position: `"\(title) · passage \(index) of \(total)"`, where the passage is `DataManager.shared.passageIndex?.passage(surah: info.surahNumber, containing: info.verseNumber)` and the title comes from `PassageStore.shared` (fallback `"Verses \(rangeLabel)"`). Resume already opens `SurahDetailView(targetVerse:)`, which now pushes the passage; no other change.
- Modify: `Thaqalayn/ThaqalaynApp.swift` `handleDeepLink` (`:54-80`): add `thaqalayn://passage?surah=2&index=4` which resolves the passage's first verse through `DataManager.shared.passageIndex` and posts `NavigateToVerse` with that verse (reuse `handleVerseDeepLink`'s notification, `:116-145`). Document the route in the comment block above `handleDeepLink`.
- Modify: `Thaqalayn/Models/WhatsNewItem.swift`: add `case passage(surah: Int, index: Int)` to `WhatsNewDestination` (`:13-26`) and a catalog entry at the top of `WhatsNewCatalog.all` (`:41`): sfSymbol `"text.book.closed"`, releaseDate later than the current newest entry (read the file), title `"Understanding, passage by passage"`, blurb `"Al-Baqarah now opens as passages. Read the verses, then Understand the passage: an essay, verse notes, narrations and their sources, all tappable."`, cta `"Open al-Baqarah"`, destination `.passage(surah: 2, index: 1)`.
- Modify: `Thaqalayn/Views/WhatsNewCard.swift` `open()` (`:40-76`): handle `.passage` by opening `URL(string: "thaqalayn://passage?surah=\(s)&index=\(i)")` via `UIApplication.shared.open` after the 0.12s delay (the app already routes that URL).

**Step: Build**, then commit (ask first): `reader: surah list, continue reading, deep link and what's new for passages`.

---

### Task 9: Remove the five-layer types and re-point the last consumers

**Files:**
- Modify: `Thaqalayn/Models/QuranModels.swift`: slim `TafsirVerse` (`:198-296`) to `let quickOverview: QuickOverviewData?` plus `init(quickOverview:)`; delete `TafsirLayer` (`:525-571`); keep `CommentaryLanguage` (`:576-610`), `TafsirData`, `SurahWithTafsir`, `VerseWithTafsir`.
- Modify: `Thaqalayn/Services/DataManager.swift`: delete `getTafsirText(for:layer:)` and `cleanTafsirText` (`:193-337`).
- Modify: `Thaqalayn/Services/PremiumManager.swift`: delete `canAccessLayer` (`:138-151`).
- Modify: `Thaqalayn/Services/NotificationManager.swift:132-136`: replace the layer text with the first gem: `if preferences.includeTafsir, let insight = verse.tafsir?.quickOverview?.concepts.first?.coreInsight, !insight.isEmpty { body += "\n\n💡 " + String(insight.prefix(150)) + "..." }` (check the real property names in `VerseConcept`, `QuranModels.swift:168-186`).
- Modify: `Thaqalayn/Services/ThemeManager.swift:206-217`: delete the five layer chip colours if nothing else references them (grep `chipFoundation|chipKnowledge|chipProgress|chipBrand|chipComparative`).
- Delete: `Thaqalayn/Views/Onboarding/FiveLayersScreen.swift`; remove it from `OnboardingFlowView.swift:44` (and any page-count constant there).
- Modify: `Thaqalayn/Views/PaywallView.swift:96-108, 388-445`: the `LayerInfo` ladder becomes four rows describing the passage reader: `("Essay", "The passage told once, in order")`, `("Verse by verse", "Notes on the verses that need them")`, `("Narrations", "From the Imams, with their sources")`, `("Perspectives", "Where Shia and Sunni readings differ", isGold: true)`; keep the visual component, change the copy and the section title from "5 layers" wording to "Understanding". Do not rewrite the rest of the paywall.
- `grep -rn "TafsirLayer\|canAccessLayer\|getLayer2\|layer1\b\|FullScreenCommentaryView\|ModernTafsirTabs\|TafsirLayerSelector\|FiveLayersScreen" Thaqalayn ThaqalaynWidgets` must return nothing (preview blocks included: `VerseSummaryView.swift:342-361`, `QuickOverviewView.swift:571-576`, old `SurahDetailView` previews are gone with the file).
- `Thaqalayn/Views/TafsirSourcesView.swift` (Settings, sources page) still describes five layers: leave its prose but add one leading paragraph: "Passage commentary (2026) is written from the sources listed on each passage's source sheet. The notes below describe the earlier layered commentary." Flag it for the user as copy to revisit.

**Step: Build, then run all passage tests**

`-only-testing:ThaqalaynTests/PassageModelsTests -only-testing:ThaqalaynTests/PassageIndexTests -only-testing:ThaqalaynTests/PassageStoreTests -only-testing:ThaqalaynTests/PassageProgressTests -only-testing:ThaqalaynTests/PassageMarkupTests`. Also run the whole `ThaqalaynTests` bundle once to be sure nothing else broke.

Commit (ask first): `reader: remove the five-layer commentary types and re-point gems, notifications, paywall copy`.

---

### Task 10: Run in the simulator and screenshot every screen

**Files:**
- Create: screenshots in the scratchpad, then `docs/plans/2026-09-05-passage-reader-screens/` (PNG, committed only if the user wants them)

Steps:

1. `xcrun simctl boot "iPhone 16 Pro" 2>/dev/null; open -a Simulator`.
2. `xcodebuild build -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' -derivedDataPath build -quiet`.
3. `xcrun simctl install booted build/Build/Products/Debug-iphonesimulator/Thaqalayn.app && xcrun simctl launch booted MAHR.Partner.Thaqalayn`.
4. Wait 6s (splash). `xcrun simctl io booted screenshot 01-launch.png`. If onboarding or sign-in blocks the app, stop and tell the user; they will step through it in the simulator window.
5. `xcrun simctl openurl booted "thaqalayn://verse?surah=2&verse=1"` and wait 3s: this lands on the Passage screen for 2:1 via the surah passage list. Screenshot `02-passage.png`. Then `xcrun simctl openurl booted "thaqalayn://passage?surah=2&index=4"`; screenshot `03-passage-adam.png`.
6. The Understanding screen and the source sheet need taps. Hand over to the user for those, or, if `xcrun simctl` UI scripting is unavailable, ask the user to tap Understand and take the screenshots with Cmd+S in Simulator.
7. Read the screenshots (the Read tool shows PNGs) and fix visual defects: clipped Arabic, wrong fonts, missing theme background, chip contrast, spacing against the mock. Rebuild and reshoot until it matches the mock's structure.

Report: the screenshots, what deviates from the mock, and anything the user should tap through.

Commit (ask first) only if code changed in this task: `reader: visual fixes from the first simulator run`.

---

## After this plan

- Gems split: `scripts/passages.py extract-gems N` for all 114 surahs into `gems_N.json`, re-point `DataManager.loadTafsirData`, `scripts/generate_widget_daily.py:24,107` and `scripts/build_widget_reflections.py:33,57`, then delete `tafsir_*.json` (about 165 MB) at the release that ships the popular set. Startup currently decodes all 114 tafsir files; the split cuts that by 85 percent.
- `TafsirSourcesView` copy rewrite for the passage reader.
- Urdu and Arabic passages: `LocalizedText` already carries `ur`/`ar`, the language pills appear automatically once the data has them.
- Passage-level narrations (`"verse": null` in the design) are not in the writer's output yet; when they appear, render them under the essay.
