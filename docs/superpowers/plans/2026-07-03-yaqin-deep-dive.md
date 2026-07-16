# Yaqīn Deep Dive — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship "Deep Dives" — immersive, single-sitting, scroll-snap thematic descents — as a peer section inside a rebranded **Journeys** tab, with **Yaqīn** (certainty) as the first dive, natively rebuilt in SwiftUI from `MajlisYaqeen.jsx`.

**Architecture:** A data-driven engine. `DeepDive` (model) + `YaqinDeepDive` (content) feed one reusable immersive `DeepDiveView` (vertical scroll-snap "descent"). Placement mirrors the existing Journey system exactly: a `DeepDiveCatalog` (like `JourneyDescriptor.all`) and a `DeepDiveCard` (like `JourneyCard`) render a second, equal-styled section in `JourneyHubView`, opening the dive via `.fullScreenCover`. The immersive view keeps its own fixed cinematic dark treatment across both app themes; it reuses existing infrastructure for audio, text-scaling, and chrome.

**Tech Stack:** SwiftUI (iOS 17+), existing `Em*` component library, `AudioManager`/`VerseRecitationButton`, `TafsirReader`/`DuaListenButton`, `ReadingSettingsManager`, `TabBarVisibility`.

## Global Constraints

- **No fallback logic** unless explicitly required — throw/precondition on impossible states, don't silently degrade (project CLAUDE.md).
- **All reading content scales** with `ReadingSettingsManager.shared.scale` (steps `[0.9, 1.0, 1.15, 1.3, 1.5]`): Arabic, translations, reflections, narration bodies, the duʿā. **Do NOT scale** chrome: kickers/eyebrows, verse refs, source citations, movement numerals, buttons.
- **Every duʿā/ziyārat shows a Listen control** — the closing duʿā MUST use `DuaListenButton(arabic:)`. Qur'an āyāt use `VerseRecitationButton(surahNumber:verseNumber:)` (real recitation), NOT TTS.
- **No em dashes** in any copy — use a plain hyphen.
- **No XCTest / no test target.** Per-task gate = `xcodebuild` succeeds + the task's `#Preview` renders. Behavior verification via removable `#if DEBUG` previews.
- **Xcode synced folders**: new files are picked up by dropping them in the folder — no `.pbxproj` edits.
- **Immersive view theming**: `DeepDiveView` uses its own fixed "descent" palette (dark green-black + gold, harmonized to accent `#D6B25E`) regardless of `ThemeManager` theme. It is an immersive mode, like a film.
- **Content source of truth**: section copy is ported verbatim from `MajlisYaqeen.jsx` EXCEPT the two sourcing fixes in Task 2. Do not paraphrase the rest.
- **Build command** (adjust simulator to your usual device/UDID):
  `xcodebuild -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1 | tail -20`

## Design (approved via mockups)

- `docs/mockups/journeys-merged-deepdives-v2.html` — the merged Journeys tab: **Sacred Seasons** section (existing journey cards, unchanged) leads; **Deep Dives** section (same card style) follows. Each section highlights only its own live item (`NEXT UP` / `FEATURED`). Neither outweighs the other.
- `MajlisYaqeen.jsx` — the immersive experience: source of truth for section order, copy, and interactions (recite toggles, expandable depths, reflection "hold this thought", "tap to say Āmīn", depth stepper, progress-driven background).

## File Structure

- Create `Thaqalayn/Models/DeepDive.swift` — model: `DeepDive`, `DeepDiveSection`, `Depth`, `BridgeVerse`, `ActInfo`.
- Create `Thaqalayn/Content/YaqinDeepDive.swift` — `extension DeepDive { static let yaqin }` (all content).
- Create `Thaqalayn/Services/DeepDiveCatalog.swift` — `DeepDiveDescriptor` + `.all` + status (mirrors `JourneyCatalog`).
- Create `Thaqalayn/Views/DeepDive/DeepDiveView.swift` — the immersive scroll-snap experience.
- Create `Thaqalayn/Views/DeepDive/DeepDiveBackground.swift` — progress-driven descent background (color interp, motes, vignette).
- Create `Thaqalayn/Views/DeepDive/DeepDiveCard.swift` — hub card (mirrors `JourneyCard`).
- Modify `Thaqalayn/Views/JourneyHubView.swift` — add the two labeled sections + deep-dive `.fullScreenCover`.
- Modify `Thaqalayn/Utilities/JourneyStrings.swift` — new section/label strings.

---

### Task 1: `DeepDive` data model

**Files:**
- Create: `Thaqalayn/Models/DeepDive.swift`

**Interfaces:**
- Produces: `DeepDive` (id, titleEn, titleAr, subtitle, sfSymbol, estMinutes, acts: `[ActInfo]`, sections: `[DeepDiveSection]`); `DeepDiveSection` enum (8 cases below); `Depth`, `BridgeVerse`, `ActInfo` structs.

- [ ] **Step 1: Create the model file**

```swift
//  DeepDive.swift — data for one immersive "deep dive" (see DeepDiveView).
import SwiftUI

/// The three-part structure metadata (ʿIlm / ʿAyn / Ḥaqq al-Yaqīn for the Yaqīn dive).
struct ActInfo: Identifiable { let number: Int; let ar: String; let tr: String; let name: String; var id: Int { number } }

struct Depth: Identifiable { let ar: String; let tr: String; let label: String; let desc: String; let reference: String?; let embodies: String; var id: String { tr } }

struct BridgeVerse { let surah: Int; let ayah: Int; let arabic: String; let translation: String; let reference: String }

/// One full-screen beat. Cases mirror the `type`s in MajlisYaqeen.jsx.
enum DeepDiveSection {
    case open(kicker: String, titleAr: String, titleEn: String, subtitle: String, line: String)
    case verse(act: Int, tag: String, surah: Int, ayah: Int, arabic: String, translation: String, reference: String, reflection: String)
    case depths(act: Int, tag: String, reference: String, items: [Depth])
    case act(act: Int, line: String, bridge: BridgeVerse?)
    case narration(act: Int, tag: String, source: String, body: String, reflection: String)
    case climax(act: Int, tag: String, source: String, arabic: String, translation: String, body: String, reflection: String)
    case reflectionPrompt(tag: String, prompt: String, placeholder: String)
    case dua(tag: String, intro: String, arabic: String, translation: String, source: String, note: String)

    /// Act number for the stepper (0 = open, 4 = reflection/dua close).
    var act: Int {
        switch self {
        case .open: return 0
        case .verse(let a, _, _, _, _, _, _, _): return a
        case .depths(let a, _, _, _): return a
        case .act(let a, _, _): return a
        case .narration(let a, _, _, _, _): return a
        case .climax(let a, _, _, _, _, _, _): return a
        case .reflectionPrompt, .dua: return 4
        }
    }
}

struct DeepDive: Identifiable {
    let id: String
    let titleEn: String
    let titleAr: String
    let subtitle: String
    let sfSymbol: String
    let estMinutes: Int
    let acts: [ActInfo]
    let sections: [DeepDiveSection]

    func actInfo(_ n: Int) -> ActInfo? { acts.first { $0.number == n } }
    /// First section index of each act — drives the persistent depth stepper.
    func firstIndex(ofAct n: Int) -> Int? { sections.firstIndex { $0.act == n } }
}
```

- [ ] **Step 2: Build**

Run the build command. Expected: **BUILD SUCCEEDED** (file compiles; nothing references it yet).

- [ ] **Step 3: Commit**

```bash
git add Thaqalayn/Models/DeepDive.swift
git commit -m "feat(deepdive): add DeepDive data model"
```

---

### Task 2: Yaqīn content

**Files:**
- Create: `Thaqalayn/Content/YaqinDeepDive.swift`

**Interfaces:**
- Consumes: `DeepDive`, `DeepDiveSection`, `Depth`, `BridgeVerse`, `ActInfo` (Task 1).
- Produces: `DeepDive.yaqin`.

- [ ] **Step 1: Transcribe content from `MajlisYaqeen.jsx`**

Port every section in order from the `sections` array in `MajlisYaqeen.jsx` into `DeepDive.yaqin`, mapping JSX `type` → `DeepDiveSection` case. `acts` = the `ACTS` object (1: ʿIlm al-Yaqīn / The Knowing, 2: ʿAyn al-Yaqīn / The Witnessing, 3: Ḥaqq al-Yaqīn / The Living). `depths` items = the `depths` array. Verse `surah`/`ayah`: Takāthur 102:5, Baqarah 2:260, Anbiyāʾ 21:69, Qaṣaṣ 28:7; bridge (act 3) = Ḥijr 15:99. Closing dua = Ṣaḥīfa Sajjādiyya #20 (`DUA_AR`/`DUA_TR`), source "Imam ʿAlī ibn al-Ḥusayn · al-Ṣaḥīfa al-Sajjādiyya".

**Two sourcing fixes (do NOT copy the JSX verbatim here):**
1. **Narration (ʿĀshūrāʾ)** — set `source: "Radiance of his face at Karbalāʾ — narrated of Hilāl ibn Nāfiʿ"` and reword the body so the "nearness of the Beloved" line reads as reflection, not quoted narration: keep "as the arrows fell thicker, the face of Ḥusayn only grew more luminous" (attested), move the "closer the meeting, the brighter the certainty" into the section's `reflection`, not the narrated `body`.
2. **Climax (Zaynab)** — set `source: "Sayyida Zaynab, in the court of Ibn Ziyād — Kufa"` (not "before the throne").

- [ ] **Step 2: Verify no em dashes**

Run: `grep -n "—" Thaqalayn/Content/YaqinDeepDive.swift` → Expected: no output.

- [ ] **Step 3: Build** — Expected: **BUILD SUCCEEDED**.

- [ ] **Step 4: Commit**

```bash
git add Thaqalayn/Content/YaqinDeepDive.swift
git commit -m "feat(deepdive): add Yaqīn content with corrected sourcing"
```

---

### Task 3: Descent background (progress-driven)

**Files:**
- Create: `Thaqalayn/Views/DeepDive/DeepDiveBackground.swift`

**Interfaces:**
- Produces: `DeepDiveBackground(progress: CGFloat)` (0…1); `DeepDivePalette` constants (`gold #C9A55C`, `goldBright #E3C37E`, `cream #ECE7DB`, bg stops from JSX `BG_STOPS`).

- [ ] **Step 1: Implement background** — port `BG_STOPS`, `VIG_STOPS`, `interp`, `lerpColor`, the rising light-motes, and the vignette from `MajlisYaqeen.jsx` into a SwiftUI view driven by a `progress` binding. Honor `@Environment(\.accessibilityReduceMotion)` — freeze motes/animation when true.

```swift
//  DeepDiveBackground.swift — the "descent": background color interpolates with
//  scroll progress; gold motes rise; a vignette deepens mid-descent.
import SwiftUI

enum DeepDivePalette {
    static let gold = Color(hex: "C9A55C"); static let goldBright = Color(hex: "E3C37E")
    static let cream = Color(hex: "ECE7DB"); static let mute = Color(hex: "8F9A8C"); static let faint = Color(hex: "5C665D")
    static let bgStops: [(CGFloat, Color)] = [(0,Color(hex:"0F1712")),(0.32,Color(hex:"0B110D")),(0.55,Color(hex:"070A08")),(0.72,Color(hex:"040605")),(0.82,Color(hex:"020403")),(0.9,Color(hex:"06100B")),(1,Color(hex:"0B140F"))]
    static func bg(_ p: CGFloat) -> Color { /* piecewise lerp over bgStops */ }
}
```

- [ ] **Step 2: Build + `#Preview`** — add `#Preview` showing the background at `progress` 0.0, 0.5, 1.0. Expected: BUILD SUCCEEDED; preview shows deepening green-black.

- [ ] **Step 3: Commit** `feat(deepdive): add progress-driven descent background`.

---

### Task 4: `DeepDiveView` scaffold + scroll-snap + close + stepper

**Files:**
- Create: `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

**Interfaces:**
- Consumes: `DeepDive`, `DeepDiveBackground`, `DeepDivePalette`.
- Produces: `DeepDiveView(dive: DeepDive, onClose: () -> Void)`.

- [ ] **Step 1: Scaffold** — full-screen `ScrollView(.vertical)` with `.scrollTargetBehavior(.paging)` and `.scrollTargetLayout()`; one full-height `section` per `dive.sections` element (use `ForEach(Array(dive.sections.enumerated()), id: \.offset)`). Track scroll progress (0…1) via `.onScrollGeometryChange` (iOS 18) or a `GeometryReader` offset reader (iOS 17) → drive `DeepDiveBackground(progress:)`. Add the top progress hairline. Render each section as a `Text(String(describing:))` placeholder for now. Add a top-left close button (chevron.down in an `.ultraThinMaterial` circle) calling `onClose`. Add `.hideTabBar()`.

- [ ] **Step 2: Persistent depth stepper** — port the bottom stepper (acts I/II/III) from the JSX; visible only when the current section's `act` is 1–3; tapping an act scrolls to `dive.firstIndex(ofAct:)`. Track `currentIndex` from scroll position.

- [ ] **Step 3: Build + `#Preview`** — `#Preview { DeepDiveView(dive: .yaqin, onClose: {}) }`. Expected: paging scroll works, background deepens, stepper appears on acts, close button present.

- [ ] **Step 4: Commit** `feat(deepdive): DeepDiveView scaffold with paging + stepper`.

---

### Task 5: Section renderers — open / act / depths / verse

**Files:**
- Modify: `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

**Interfaces:**
- Consumes: `ReadingSettingsManager.shared.scale`, `VerseRecitationButton(surahNumber:verseNumber:)`.

- [ ] **Step 1: Reveal + type helpers** — add a `reveal(_ shown:)` modifier (opacity + translateY, matching JSX `reveal`) and font helpers: Amiri via `.custom("Amiri", size:)`, display serif via `EmType.serif`. Reading text multiplies size + `lineSpacing` by `readingSettings.scale`; chrome does not.

- [ ] **Step 2: Implement `open`, `act`, `depths` renderers** — per the JSX markup for each `type`. `depths` cards expand/collapse on tap (`@State var openDepths: Set<Int>`). `act` shows the movement numeral + `ActInfo` + optional bridge verse card.

- [ ] **Step 3: Implement `verse` renderer** — Arabic (tappable, scales), translation (scales), reference (fixed), reflection (scales), and a **`VerseRecitationButton(surahNumber: surah, verseNumber: ayah)`** in place of the JSX fake "Recite" button.

- [ ] **Step 4: Build + `#Preview`** — verify the first movement (open → verse 102:5 → depths) renders, recitation plays, text scales when `ReadingSettingsManager.shared.stepIndex` changes.

- [ ] **Step 5: Commit** `feat(deepdive): open/act/depths/verse renderers with real recitation`.

---

### Task 6: Section renderers — narration / climax / reflection / dua

**Files:**
- Modify: `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

**Interfaces:**
- Consumes: `DuaListenButton(arabic:)`.

- [ ] **Step 1: `narration` + `climax` renderers** — per JSX. Climax Arabic (Zaynab) scales; body/reflection scale; source citation fixed.

- [ ] **Step 2: `reflectionPrompt` renderer** — the "name your yaqīn" `TextEditor` + "Hold this thought" seal (local `@State` only; nothing persisted or synced). Kept-on-device note.

- [ ] **Step 3: `dua` renderer** — intro + Arabic (scales) + translation (scales) + source (fixed) + note + **`DuaListenButton(arabic:)`** + the "tap to say Āmīn" ripple. (Listen control is mandatory here.)

- [ ] **Step 4: Build + `#Preview`** — scroll to the close; duʿā Listen plays via TTS; Āmīn ripple fires.

- [ ] **Step 5: Commit** `feat(deepdive): narration/climax/reflection/dua renderers + Listen`.

---

### Task 7: `DeepDiveCatalog` (registry + status)

**Files:**
- Create: `Thaqalayn/Services/DeepDiveCatalog.swift`

**Interfaces:**
- Produces: `DeepDiveDescriptor` (id, eyebrow, titleEn, titleAr, sfSymbol, subtitle, `available: Bool`, `dive: DeepDive?`); `DeepDiveDescriptor.all`; `.byId(_:)`.

- [ ] **Step 1: Implement registry** — mirror `JourneyDescriptor` shape but simpler (no calendar). Yaqīn = `available: true, dive: .yaqin`. Include two `available: false` placeholders (Ṣabr "Patience", Tawakkul "Reliance") to match the mockup's `Soon` cards.

```swift
struct DeepDiveDescriptor: Identifiable {
    let id: String; let eyebrow: String; let titleEn: String; let titleAr: String
    let sfSymbol: String; let subtitle: String; let available: Bool; let dive: DeepDive?
    static let all: [DeepDiveDescriptor] = [
        .init(id: "yaqin", eyebrow: "Deep Dive", titleEn: "Yaqīn · Certainty", titleAr: "يَقِين",
              sfSymbol: "eye", subtitle: "A descent through three depths - Qur'an to Karbala", available: true, dive: .yaqin),
        .init(id: "sabr", eyebrow: "Deep Dive", titleEn: "Ṣabr · Patience", titleAr: "صَبْر",
              sfSymbol: "hourglass", subtitle: "Standing firm through trial", available: false, dive: nil),
        .init(id: "tawakkul", eyebrow: "Deep Dive", titleEn: "Tawakkul · Reliance", titleAr: "تَوَكُّل",
              sfSymbol: "hands.and.sparkles", subtitle: "Trusting God with the outcome", available: false, dive: nil),
    ]
    static func byId(_ id: String) -> DeepDiveDescriptor? { all.first { $0.id == id } }
}
```

- [ ] **Step 2: Build** — Expected: BUILD SUCCEEDED.
- [ ] **Step 3: Commit** `feat(deepdive): add DeepDiveCatalog registry`.

---

### Task 8: `DeepDiveCard` (hub card, same style as `JourneyCard`)

**Files:**
- Create: `Thaqalayn/Views/DeepDive/DeepDiveCard.swift`

**Interfaces:**
- Consumes: `DeepDiveDescriptor`, `EmCard`, `EmIconChip`, `EmPressStyle`, `EmType`.
- Produces: `DeepDiveCard(descriptor:isFeatured:onTap:)`.

- [ ] **Step 1: Implement card** — copy `JourneyCard`'s exact `EmCard`/`EmIconChip`/serif layout so it reads identical. `available` → `FEATURED` pill (reuse `JourneyCard.nextUpPill` styling) + glow + `chevron.right`. `!available` → "Deep Dive" eyebrow + subtitle + a `lock` glyph, dimmed (like `.ended`).

- [ ] **Step 2: Build + `#Preview`** — Yaqīn (featured) + Ṣabr (locked) cards render identically to journey cards.
- [ ] **Step 3: Commit** `feat(deepdive): add DeepDiveCard matching JourneyCard style`.

---

### Task 9: Merge into `JourneyHubView` (two sections)

**Files:**
- Modify: `Thaqalayn/Views/JourneyHubView.swift`
- Modify: `Thaqalayn/Utilities/JourneyStrings.swift`

**Interfaces:**
- Consumes: `DeepDiveDescriptor.all`, `DeepDiveCard`, `DeepDiveView`.

- [ ] **Step 1: Strings** — add to `JourneyStrings`: `sacredSeasonsLabel`, `deepDivesLabel`, `deepDivesSub` ("explore anytime"), and broaden the header (`journeysSub` → "Live a sacred season, or descend into a theme."). English + Urdu; Arabic falls back to English (existing pattern).

- [ ] **Step 2: Restructure `body`** — change the `EmHeading` eyebrow off "Sacred Seasons"; inside the `VStack`, render: `EmDivider(label: sacredSeasonsLabel)` → the existing `ForEach(ordered)` of `JourneyCard` → `EmDivider(label: deepDivesLabel)` → `ForEach(DeepDiveDescriptor.all)` of `DeepDiveCard`. Keep Sacred Seasons first (equal weight, seasons lead).

- [ ] **Step 3: Deep-dive presentation** — add `@State private var presentedDive: PresentedDeepDive?` (`struct PresentedDeepDive: Identifiable { let id: String }`). Card tap: if `available`, after the 0.12s squish delay set `presentedDive`; else soft-haptic + a "coming soon" locked overlay (reuse `LockedJourneyOverlay` copy or a short alert). Add `.fullScreenCover(item: $presentedDive) { p in if let d = DeepDiveDescriptor.byId(p.id)?.dive { DeepDiveView(dive: d) { presentedDive = nil } } }`.

- [ ] **Step 4: Build + `#Preview`** — the hub shows both sections in the approved layout; tapping Yaqīn opens the descent; tapping Ṣabr shows the locked state.

- [ ] **Step 5: Commit** `feat(deepdive): merge Deep Dives into Journeys tab`.

---

### Task 10: Full-app verification pass

- [ ] **Step 1: Clean build** — `xcodebuild -scheme Thaqalayn -destination '…' build`. Expected: BUILD SUCCEEDED, no warnings from new files.
- [ ] **Step 2: Device/simulator walkthrough** — launch, open Journeys tab, confirm: two equal sections; Yaqīn descent scrolls with deepening background; verse recitation plays; text-size control scales verse/translation/reflection/dua but not chrome; duʿā Listen (TTS) works; Āmīn ripple; close returns to hub; reduced-motion freezes motes.
- [ ] **Step 3: Commit** any fixes. Do not auto-commit beyond task commits; the user commits releases themselves.

---

## Self-Review

- **Spec coverage:** merged tab (T9) ✓; equal-style card (T8) ✓; immersive descent (T3–T6) ✓; Yaqīn content + sourcing fixes (T2) ✓; audio (T5 recitation, T6 Listen) ✓; text-scaling (T5/T6) ✓; own-theme cinematic (T3, Global Constraints) ✓; reduced-motion (T3, T10) ✓; data-driven for future dives (T1, T7) ✓.
- **Placeholders:** section copy is pointed at `MajlisYaqeen.jsx` as a real in-repo source of truth (not a TODO); background math (`Bg`/`interp`) is specified as a direct port of named JSX functions.
- **Type consistency:** `DeepDive.yaqin` (T2) ← model (T1); `DeepDiveDescriptor.dive: DeepDive?` (T7) → `DeepDiveView(dive:)` (T4); `firstIndex(ofAct:)`/`.act` used by stepper (T4) defined in T1.
