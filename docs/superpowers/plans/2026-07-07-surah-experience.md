# "Inside the Sūrah" (Surah Experience) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship an immersive per-surah experience (pilots: Yūsuf 12, Yāsīn 36, al-Raḥmān 55, al-Mulk 67) that reveals each surah's soul as a guided narrative descent, reusing the Deep Dive engine.

**Architecture:** Each surah experience IS a `DeepDive` value rendered by the existing `DeepDiveView` scroll-snap engine. Engine gets one new beat (`closing`, replacing `dua` for surah dives) plus an optional `onReadSurah` hand-off closure, and the reflection beat's hard-coded copy is parameterized. A new `SurahExperienceCatalog` registry feeds a new Journeys-hub section and a split-row strip on that surah's card in the Quran-tab list (no entry inside `SurahDetailView`). Content is authored per surah from the app's own 5-layer tafsir JSON via a distill → draft → user-approval → translate → build pipeline.

**Tech Stack:** SwiftUI (iOS), Swift-embedded trilingual content (`LocalizedText`), Python for tafsir extraction/validation, subagents for distillation/translation.

**Spec:** `docs/superpowers/specs/2026-07-07-surah-experience-design.md`

## Global Constraints

- NEVER use an em dash in any copy or code comment; use a plain dash.
- No fallback logic anywhere; fail fast with clear errors.
- All reading content scales with `ReadingSettingsManager.shared.scale` (multiply font size AND line spacing); chrome (eyebrows, refs, pills, buttons) stays fixed. The `DeepDiveView` engine already does this via `s`.
- Premium gating shows a "Premium" accent chip, NEVER a `lock.fill` icon; locked taps route to `PaywallView`.
- All user-facing copy trilingual EN/UR/AR via `LocalizedText` (content) or `JourneyStrings` (chrome).
- Qur'an Arabic and verse references are single-string (identical across languages) and must match `Thaqalayn/Thaqalayn/Data/quran_data.json` verbatim.
- Every verse beat is anchored to a single surah:ayah so `VerseRecitationButton` plays real recitation. No dua beat and no TTS in surah experiences.
- Every pilot uses EXACTLY 3 movements: the engine's stepper hard-codes 3 (the `romans` array, the 3-dot depth meter, "Depth N of 3"). Do not propose 4+ movements in any brief; that needs an engine generalization that is out of scope.
- No XCTest / no test target. Per-task gate = `xcodebuild -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1 | tail -5` prints `BUILD SUCCEEDED`. `#Preview` blocks must be wrapped in `#if DEBUG`.
- The user does simulator install/launch/visual verification themselves; do not run simctl.
- Do NOT `git commit`; the user commits. Stop after each task and report.
- New Swift files: just create them in the right folder; Xcode 16 synced folder groups pick them up (no pbxproj edits). If SourceKit/LSP reports "cannot find type in scope" on new files, it is a stale index; trust xcodebuild.
- Never run more than two subagents concurrently; batch into waves of two.
- Python work: `source .venv/bin/activate` first.
- Every narration and fadail claim must carry a citable Shia source; if a claim cannot be cited, drop it.

## File Map

| File | Action | Responsibility |
|---|---|---|
| `Thaqalayn/Models/DeepDive.swift` | Modify | Add `closing` beat case; parameterize `reflectionPrompt` |
| `Thaqalayn/Views/DeepDive/DeepDiveView.swift` | Modify | Render `closing`; `onReadSurah` hook; parameterized reflection |
| `Thaqalayn/Content/YaqinDeepDive.swift` | Modify | Pass explicit reflection subline/nextLabel (copy unchanged) |
| `Thaqalayn/Content/SabrDeepDive.swift` | Modify | Pass corrected reflection subline/nextLabel |
| `Thaqalayn/Services/PremiumManager.swift` | Modify | `canAccessSurahExperience(_:)` |
| `Thaqalayn/Services/DeepLinkRouter.swift` | Modify | `pendingSurahExperienceId` |
| `Thaqalayn/Utilities/JourneyStrings.swift` | Modify | Section/eyebrow/CTA strings |
| `Thaqalayn/Services/SurahExperienceCatalog.swift` | Create | Descriptor registry for the four pilots |
| `Thaqalayn/Views/DeepDive/SurahExperienceCard.swift` | Create | Hub card (mirrors DeepDiveCard) |
| `Thaqalayn/Views/DeepDive/SurahExperienceListStrip.swift` | Create | Attached strip on the surah's list row (Quran tab) |
| `Thaqalayn/Views/JourneyHubView.swift` | Modify | Third section + tap/deep-link handling |
| `Thaqalayn/ContentView.swift` | Modify | `ModernSurahCard` gets a squared-bottom variant |
| `Thaqalayn/Views/HomeView.swift` | Modify | Row wrapper + fullScreenCover + paywall gating |
| `Thaqalayn/Models/WhatsNewItem.swift` | Modify | `.surahExperience` destination + Yūsuf entry |
| `Thaqalayn/Views/WhatsNewCard.swift` | Modify | Route new destination |
| `Thaqalayn/Content/SurahYusufDive.swift` | Create | Yūsuf content (Task 8-9) |
| `Thaqalayn/Content/SurahYasinDive.swift` | Create | Yāsīn content (Task 10) |
| `Thaqalayn/Content/SurahRahmanDive.swift` | Create | al-Raḥmān content (Task 11) |
| `Thaqalayn/Content/SurahMulkDive.swift` | Create | al-Mulk content (Task 12) |
| `docs/plans/surah-experience/<surah>-brief.md` | Create | Distillation briefs (working docs) |
| `docs/plans/surah-experience/<surah>-script.md` | Create | Approved trilingual scripts |

---

### Task 1: Engine - `closing` beat + `onReadSurah` hook

**Files:**
- Modify: `Thaqalayn/Models/DeepDive.swift`
- Modify: `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

**Interfaces:**
- Consumes: existing `DeepDiveSection`, `DeepDivePalette`, `JourneyStrings.done(_:)`.
- Produces: `DeepDiveSection.closing(tag:titleAr:essence:line:)`; `DeepDiveView(dive:onClose:onReadSurah:)` where `onReadSurah: (() -> Void)? = nil`. Later tasks (5, 6) pass `onReadSurah`; content tasks (9-12) end their section list with `.closing`.

- [ ] **Step 1: Add the `closing` case to `DeepDiveSection`** in `Thaqalayn/Models/DeepDive.swift`. After the `dua` case (line ~77) add:

```swift
    /// The final beat of a sūrah experience: restates the sūrah's essence and
    /// hands off to reading the full sūrah. Replaces `dua` for sūrah dives -
    /// a sūrah experience is an understanding journey, not a devotional close.
    case closing(tag: LocalizedText, titleAr: String, essence: LocalizedText, line: LocalizedText)
```

And extend the `act` computed property's final line from:

```swift
        case .reflectionPrompt, .dua:                      return 4
```

to:

```swift
        case .reflectionPrompt, .dua, .closing:            return 4
```

- [ ] **Step 2: Add `onReadSurah` to `DeepDiveView`** in `Thaqalayn/Views/DeepDive/DeepDiveView.swift`. Below `var onClose: () -> Void` add:

```swift
    /// Present on sūrah experiences: invoked by the closing beat's
    /// "Read the full sūrah" button. nil hides the button (theme dives).
    var onReadSurah: (() -> Void)? = nil
```

- [ ] **Step 3: Wire `closing` into `placeInfo` and `content`.** In `placeInfo(_:)` add a case above `default`:

```swift
        case .closing:                  return ("The Close", 3)
```

In `content(_:_:)` add before the closing brace of the switch:

```swift
        case let .closing(tag, titleAr, essence, line):
            closingPage(tag(lang), titleAr, essence(lang), line(lang), show)
```

- [ ] **Step 4: Add the `closingPage` renderer.** Add after `duaPage`/`aminBlock` (keep `// MARK: Renderers` grouping):

```swift
    private func closingPage(_ tag: String, _ titleAr: String, _ essence: String, _ line: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            tagLabel(tag, show).padding(.bottom, 26)
            Text(titleAr).font(EmType.arabic(56)).foregroundColor(DeepDivePalette.goldBright)
                .shadow(color: DeepDivePalette.goldBright.opacity(0.2), radius: 20)
                .reveal(show, 0.2, reduce: reduceMotion)
            Text(essence).font(EmType.serifItalic(20 * s)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center).lineSpacing(5 * s).padding(.top, 20).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.45, reduce: reduceMotion)
            hairline.padding(.vertical, 26).reveal(show, 0.7, reduce: reduceMotion)
            Text(line).font(.system(size: 14 * s)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.7, reduce: reduceMotion)
            VStack(spacing: 12) {
                if let onReadSurah {
                    Button(action: onReadSurah) {
                        Text(JourneyStrings.readTheFullSurah(lang))
                            .font(.system(size: 13, weight: .semibold)).tracking(1)
                            .foregroundColor(Color(red: 0.12, green: 0.09, blue: 0.03))
                            .padding(.horizontal, 26).padding(.vertical, 13)
                            .background(Capsule().fill(
                                LinearGradient(colors: [DeepDivePalette.gold, DeepDivePalette.goldBright],
                                               startPoint: .leading, endPoint: .trailing)))
                    }
                    .buttonStyle(.plain)
                }
                Button(action: onClose) {
                    Text(JourneyStrings.done(lang)).font(.system(size: 11, weight: .regular)).tracking(2)
                        .foregroundColor(DeepDivePalette.gold).padding(.horizontal, 22).padding(.vertical, 11)
                        .overlay(Capsule().stroke(DeepDivePalette.gold.opacity(0.24), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 30).reveal(show, 1.0, reduce: reduceMotion)
        }
    }
```

Note: `JourneyStrings.readTheFullSurah` lands in Task 3. If executing Task 1 standalone before Task 3, add the string now (see Task 3 Step 3 for exact code) so the build stays green - and skip that string in Task 3.

- [ ] **Step 5: Build.** Run: `xcodebuild -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1 | tail -5` - Expected: `BUILD SUCCEEDED`. (Yaqin/Sabr behavior unchanged: no sections use `closing` yet, `onReadSurah` defaults nil.)

---

### Task 2: Engine - parameterize the reflection beat's hard-coded copy

Today `reflectionPage` hard-codes Yaqīn-specific, English-only copy ("You've descended all three depths - knowing, witnessing, living... Before the prayer, name the certainty you long for.") and the bob label "And one prayer" (`DeepDiveView.swift:530,534`). This is wrong for Sabr today (it says "certainty") and would be wrong for surah dives (no prayer follows). Parameterize it.

**Files:**
- Modify: `Thaqalayn/Models/DeepDive.swift`
- Modify: `Thaqalayn/Views/DeepDive/DeepDiveView.swift`
- Modify: `Thaqalayn/Content/YaqinDeepDive.swift`
- Modify: `Thaqalayn/Content/SabrDeepDive.swift`

**Interfaces:**
- Produces: `DeepDiveSection.reflectionPrompt(tag:prompt:placeholder:subline:nextLabel:)` - two new trailing `LocalizedText` params. Content tasks 9-12 must supply them.

- [ ] **Step 1: Extend the case** in `DeepDive.swift`:

```swift
    case reflectionPrompt(tag: LocalizedText, prompt: LocalizedText, placeholder: LocalizedText, subline: LocalizedText, nextLabel: LocalizedText)
```

(The `act` switch already matches `.reflectionPrompt` without binding; no change there.)

- [ ] **Step 2: Update the renderer.** In `DeepDiveView.swift` change the dispatch:

```swift
        case let .reflectionPrompt(_, prompt, _, subline, nextLabel):
            reflectionPage(prompt(lang), subline(lang), nextLabel(lang), show)
```

and the renderer:

```swift
    private func reflectionPage(_ prompt: String, _ subline: String, _ nextLabel: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            Text("✦").font(.system(size: 20)).foregroundColor(DeepDivePalette.gold).padding(.bottom, 22)
                .reveal(show, reduce: reduceMotion)
            Text(prompt).font(EmType.serif(34)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.15, reduce: reduceMotion)
            Text(subline)
                .font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.66))
                .multilineTextAlignment(.center).lineSpacing(3 * s).padding(.top, 16).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.35, reduce: reduceMotion)
            bob(nextLabel, show).padding(.top, 34)
        }
    }
```

- [ ] **Step 3: Update Yaqīn's call site** (`YaqinDeepDive.swift`, find `.reflectionPrompt(`). Keep the existing three arguments untouched and append (copy preserved verbatim from the old hard-coded engine string):

```swift
                subline: LocalizedText(
                    en: "You've descended all three depths - knowing, witnessing, living. The map is yours. Before the prayer, name the certainty you long for.",
                    ur: "آپ تینوں گہرائیوں میں اتر چکے ہیں - جاننا، دیکھنا، جینا۔ نقشہ اب آپ کا ہے۔ دعا سے پہلے، اُس یقین کا نام لیں جس کی آپ کو تلاش ہے۔",
                    ar: "لقد نزلتَ الأعماق الثلاثة - أن تعلم، أن ترى، أن تعيش. الخريطة لك. قبل الدعاء، سمِّ اليقين الذي تشتاق إليه."),
                nextLabel: LocalizedText(en: "And one prayer", ur: "اور ایک دعا", ar: "ودعاءٌ واحد")
```

- [ ] **Step 4: Update Sabr's call site** (`SabrDeepDive.swift`) with corrected station wording:

```swift
                subline: LocalizedText(
                    en: "You've descended all three stations - enduring, accepting, at peace. The map is yours. Before the prayer, name the trial you are carrying.",
                    ur: "آپ تینوں منزلوں سے گزر چکے ہیں - صبر، رضا، اطمینان۔ نقشہ اب آپ کا ہے۔ دعا سے پہلے، اُس آزمائش کا نام لیں جو آپ اٹھائے ہوئے ہیں۔",
                    ar: "لقد نزلتَ المحطات الثلاث - صبرًا ورضًا وطمأنينة. الخريطة لك. قبل الدعاء، سمِّ البلاء الذي تحمله."),
                nextLabel: LocalizedText(en: "And one prayer", ur: "اور ایک دعا", ar: "ودعاءٌ واحد")
```

- [ ] **Step 5: Build.** Run: `xcodebuild -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build 2>&1 | tail -5` - Expected: `BUILD SUCCEEDED`.

---

### Task 3: Plumbing - premium gate, deep-link id, chrome strings

**Files:**
- Modify: `Thaqalayn/Services/PremiumManager.swift` (after `canAccessDeepDive`, ~line 238)
- Modify: `Thaqalayn/Services/DeepLinkRouter.swift`
- Modify: `Thaqalayn/Utilities/JourneyStrings.swift` (in the `// MARK: - Hub` region)

**Interfaces:**
- Produces: `PremiumManager.canAccessSurahExperience(_ id: String) -> Bool`; `DeepLinkRouter.pendingSurahExperienceId: String?`; `JourneyStrings.insideTheSurah(_:)`, `.surahJourneyEyebrow(_:)`, `.readTheFullSurah(_:)`.

- [ ] **Step 1: PremiumManager** - append inside the class:

```swift
    // MARK: - Surah Experience Access Control

    /// Sūrah experiences ("Inside the Sūrah") are premium features - every
    /// sūrah journey requires premium. There is no free teaser here; Yaqīn
    /// plays that role for the Deep Dives section.
    func canAccessSurahExperience(_ id: String) -> Bool { isPremium }
```

- [ ] **Step 2: DeepLinkRouter** - append below `pendingDeepDiveId`:

```swift
    /// Sūrah-experience id (e.g. "surah-yusuf") to auto-open once the Journey
    /// hub becomes the active tab. Set by a What's New card tap; consumed (and
    /// cleared) by JourneyHubView.
    @Published var pendingSurahExperienceId: String? = nil
```

- [ ] **Step 3: JourneyStrings** - append after `premium(_:)`:

```swift
    // Sūrah experiences ("Inside the Sūrah") - hub section, card eyebrow, closing CTA.
    static func insideTheSurah(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Inside the Sūrah", ur: "سورہ کے اندر", ar: "في قلب السورة")
    }
    static func surahJourneyEyebrow(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Sūrah Journey", ur: "سورہ کا سفر", ar: "رحلة السورة")
    }
    static func readTheFullSurah(_ l: CommentaryLanguage) -> String {
        pick(l, en: "Read the full sūrah", ur: "مکمل سورہ پڑھیں", ar: "اقرأ السورة كاملة")
    }
```

(If Task 1 already added `readTheFullSurah`, keep the single copy here.)

- [ ] **Step 4: Build.** Same command - Expected: `BUILD SUCCEEDED`.

---

### Task 4: SurahExperienceCatalog

**Files:**
- Create: `Thaqalayn/Services/SurahExperienceCatalog.swift`

**Interfaces:**
- Consumes: `DeepDive`, `LocalizedText`.
- Produces: `SurahExperienceDescriptor` with `id: String`, `surahNumber: Int`, `title: LocalizedText`, `titleAr: String`, `sfSymbol: String`, `subtitle: LocalizedText`, `available: Bool`, `dive: DeepDive?`; statics `all`, `byId(_:)`, `bySurahNumber(_:)`. Content tasks flip `available` and attach `.dive`.

- [ ] **Step 1: Write the file:**

```swift
//
//  SurahExperienceCatalog.swift
//  Thaqalayn
//
//  Static registry of the immersive "Inside the Sūrah" experiences shown in the
//  Journeys tab below the Deep Dives, and surfaced as a split-row strip on the
//  matching sūrah's card in the Quran-tab list. Mirrors DeepDiveCatalog's shape; a sūrah experience
//  is simply available or coming soon. All entries are premium-gated
//  (PremiumManager.canAccessSurahExperience).
//

import SwiftUI

/// One sūrah experience in the hub. Static registry - see `SurahExperienceDescriptor.all`.
struct SurahExperienceDescriptor: Identifiable {
    /// Stable id - also the deep-link id (DeepLinkRouter.pendingSurahExperienceId).
    let id: String
    /// The sūrah this experience belongs to - drives the list-row strip lookup.
    let surahNumber: Int
    let title: LocalizedText   // e.g. "Sūrah Yūsuf" / "سورۂ یوسف" / "سورة يوسف"
    let titleAr: String        // e.g. "يُوسُف"
    let sfSymbol: String       // card icon
    let subtitle: LocalizedText // one-line descriptor (EN / UR / AR)
    /// True when the experience is built and openable. False = "coming soon".
    let available: Bool
    /// The experience content, present only when `available`.
    let dive: DeepDive?

    static let all: [SurahExperienceDescriptor] = [
        SurahExperienceDescriptor(
            id: "surah-yusuf",
            surahNumber: 12,
            title: LocalizedText(en: "Sūrah Yūsuf", ur: "سورۂ یوسف", ar: "سورة يوسف"),
            titleAr: "يُوسُف",
            sfSymbol: "moon.stars",
            subtitle: LocalizedText(en: "The most beautiful of stories - loss, patience, reunion",
                                    ur: "بہترین قصہ - جدائی، صبر، وصال",
                                    ar: "أحسن القصص - فقدٌ وصبرٌ ولقاء"),
            available: false, dive: nil
        ),
        SurahExperienceDescriptor(
            id: "surah-yasin",
            surahNumber: 36,
            title: LocalizedText(en: "Sūrah Yāsīn", ur: "سورۂ یٰسین", ar: "سورة يس"),
            titleAr: "يس",
            sfSymbol: "heart",
            subtitle: LocalizedText(en: "The heart of the Qur'an - and what it keeps asking you",
                                    ur: "قرآن کا دل - اور اس کا آپ سے سوال",
                                    ar: "قلب القرآن - وما يسألك عنه"),
            available: false, dive: nil
        ),
        SurahExperienceDescriptor(
            id: "surah-rahman",
            surahNumber: 55,
            title: LocalizedText(en: "Sūrah al-Raḥmān", ur: "سورۂ رحمٰن", ar: "سورة الرحمن"),
            titleAr: "الرَّحْمَٰن",
            sfSymbol: "water.waves",
            subtitle: LocalizedText(en: "One question, asked thirty-one times",
                                    ur: "ایک سوال، اکتیس بار",
                                    ar: "سؤالٌ واحد، إحدى وثلاثون مرة"),
            available: false, dive: nil
        ),
        SurahExperienceDescriptor(
            id: "surah-mulk",
            surahNumber: 67,
            title: LocalizedText(en: "Sūrah al-Mulk", ur: "سورۂ ملک", ar: "سورة الملك"),
            titleAr: "الْمُلْك",
            sfSymbol: "crown",
            subtitle: LocalizedText(en: "The protector - whose hand holds the kingdom",
                                    ur: "محافظ سورہ - بادشاہی کس کے ہاتھ میں ہے",
                                    ar: "السورة الحامية - بيد مَن الملك"),
            available: false, dive: nil
        ),
    ]

    static func byId(_ id: String) -> SurahExperienceDescriptor? { all.first { $0.id == id } }
    static func bySurahNumber(_ n: Int) -> SurahExperienceDescriptor? { all.first { $0.surahNumber == n } }
}
```

- [ ] **Step 2: Build.** Same command - Expected: `BUILD SUCCEEDED`.

---

### Task 5: Hub - SurahExperienceCard + third section + deep-link

**Files:**
- Create: `Thaqalayn/Views/DeepDive/SurahExperienceCard.swift`
- Modify: `Thaqalayn/Views/JourneyHubView.swift`

**Interfaces:**
- Consumes: `SurahExperienceDescriptor`, `PremiumManager.canAccessSurahExperience`, `JourneyStrings.insideTheSurah/surahJourneyEyebrow/premium/soon`, `DeepDiveView(dive:onClose:onReadSurah:)`, `DeepLinkRouter.pendingSurahExperienceId`, `Notification.Name.navigateToVerse` (defined in `ContentView.swift:12`; MainTabView listens and routes to the Quran tab).
- Produces: hub UI; `PresentedSurahExperience` wrapper (file-local to JourneyHubView).

- [ ] **Step 1: Write the card** (mirrors `DeepDiveCard` deliberately - same EmCard/EmIconChip layout so the three hub sections read as peers):

```swift
//
//  SurahExperienceCard.swift
//  Thaqalayn
//
//  Hub card for one "Inside the Sūrah" experience. Deliberately the SAME
//  EmCard/EmIconChip/serif layout as JourneyCard and DeepDiveCard so the three
//  hub sections read as peers. All sūrah experiences are premium-gated: available
//  cards show a PREMIUM chip to non-subscribers (never a lock), a plain eyebrow to
//  subscribers; coming-soon cards are dimmed with a "Soon" marker.
//

import SwiftUI

struct SurahExperienceCard: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let descriptor: SurahExperienceDescriptor
    let onTap: () -> Void

    /// An available experience the user cannot yet open (premium-gated, not
    /// subscribed). Coming-soon cards are not "locked" - they read as "Soon".
    private var locked: Bool {
        descriptor.available && !premiumManager.canAccessSurahExperience(descriptor.id)
    }

    var body: some View {
        Button(action: onTap) {
            EmCard(glow: descriptor.available,
                   borderColor: descriptor.available ? tm.accentColor.opacity(0.4) : nil) {
                HStack(spacing: 14) {
                    EmIconChip(sfSymbol: descriptor.sfSymbol, active: descriptor.available)
                    VStack(alignment: .leading, spacing: 4) {
                        if locked {
                            premiumPill
                        } else {
                            Text(JourneyStrings.surahJourneyEyebrow(lang).uppercased())
                                .emEyebrow(lang, size: 10.5, tracking: 2)
                                .foregroundColor(tm.accentColor)
                        }
                        Text(descriptor.title(lang))
                            .font(EmType.serif(22, .semiBold))
                            .foregroundColor(tm.primaryText)
                        Text(descriptor.subtitle(lang))
                            .font(.system(size: 13))
                            .foregroundColor(tm.secondaryText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    trailingGlyph
                }
                .padding(16)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
            }
            .opacity(descriptor.available ? 1 : 0.72)
        }
        .buttonStyle(EmPressStyle())
    }

    /// "PREMIUM" chip in the app's accent-chip treatment - no lock glyph, matching
    /// DeepDiveCard / DailyCrosswordCard.
    private var premiumPill: some View {
        Text(JourneyStrings.premium(lang).uppercased())
            .font(.system(size: 9, weight: .bold)).tracking(1.4)
            .foregroundColor(tm.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(tm.accentChip))
            .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
    }

    @ViewBuilder private var trailingGlyph: some View {
        if descriptor.available {
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.accentColor)
        } else {
            Text(JourneyStrings.soon(lang))
                .font(.system(size: 9, weight: .heavy)).tracking(1.4)
                .foregroundColor(tm.tertiaryText)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
        }
    }
}
```

- [ ] **Step 2: Add the hub section.** In `JourneyHubView.swift`:

(a) Below `struct PresentedDeepDive` add:

```swift
/// Identifiable wrapper so `.fullScreenCover(item:)` can key on a sūrah-experience id.
struct PresentedSurahExperience: Identifiable { let id: String }
```

(b) Below `@State private var presentedDive` add:

```swift
    /// Set when an available sūrah experience is tapped - drives its descent.
    @State private var presentedSurahExperience: PresentedSurahExperience?
```

(c) In `body`, after the Deep Dives `ForEach` (`ForEach(DeepDiveDescriptor.all) { ... }`) add:

```swift
                    EmDivider(label: JourneyStrings.insideTheSurah(lang))
                        .padding(.horizontal, 4).padding(.top, 14).padding(.bottom, 2)

                    ForEach(SurahExperienceDescriptor.all) { d in
                        SurahExperienceCard(descriptor: d) { handleSurahExperienceTap(d) }
                    }
```

(d) After the deep-dive `.fullScreenCover(item: $presentedDive)` add:

```swift
        .fullScreenCover(item: $presentedSurahExperience) { p in
            if let d = SurahExperienceDescriptor.byId(p.id), let dive = d.dive {
                DeepDiveView(dive: dive,
                             onClose: { presentedSurahExperience = nil },
                             onReadSurah: {
                                 // Dismiss the descent, then hand off to the Quran tab -
                                 // MainTabView's .navigateToVerse listener stashes the deep
                                 // link and switches tabs; HomeView pushes the sūrah.
                                 presentedSurahExperience = nil
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                     NotificationCenter.default.post(
                                         name: .navigateToVerse, object: nil,
                                         userInfo: ["surah": d.surahNumber, "verse": 1])
                                 }
                             })
            }
        }
```

(e) Add the tap handler after `handleDiveTap`:

```swift
    /// Available sūrah experiences open their descent (after the press squish);
    /// premium-gated taps get the paywall; coming-soon reuses the locked overlay.
    private func handleSurahExperienceTap(_ d: SurahExperienceDescriptor) {
        if d.available {
            if premiumManager.canAccessSurahExperience(d.id) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    presentedSurahExperience = PresentedSurahExperience(id: d.id)
                }
            } else {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                    showingPaywall = true
                }
            }
        } else {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(.easeInOut(duration: 0.2)) {
                lockedAlert = LockedJourneyAlert(title: JourneyStrings.comingSoon(lang),
                                                 detail: JourneyStrings.deepDiveOnItsWay(d.title(lang), lang),
                                                 pointer: nil)
            }
        }
    }
```

(f) Add deep-link consumption after `consumePendingDeepDive()`:

```swift
    /// Opens a sūrah experience requested from another tab (e.g. a What's New card).
    private func consumePendingSurahExperience() {
        guard let id = router.pendingSurahExperienceId else { return }
        router.pendingSurahExperienceId = nil
        guard SurahExperienceDescriptor.byId(id)?.dive != nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            // Honor the gate even via deep link: non-subscribers get the paywall.
            if premiumManager.canAccessSurahExperience(id) {
                presentedSurahExperience = PresentedSurahExperience(id: id)
            } else {
                showingPaywall = true
            }
        }
    }
```

and wire it in `.onAppear` (next to `consumePendingDeepDive()`) plus:

```swift
        .onChange(of: router.pendingSurahExperienceId) { _, _ in consumePendingSurahExperience() }
```

- [ ] **Step 3: Build.** Same command - Expected: `BUILD SUCCEEDED`. All four cards render as "Soon" (available: false) until content lands.

---

### Task 6: Surah-list split-row strip (Quran tab)

The user chose the split-row entry (mockup: `mockups/surah-experience/option-e-splitrow.png`): the surah's list card grows an attached strip below the main row. The main row still opens the surah; the strip opens the experience directly. There is NO entry inside `SurahDetailView`. The list is rendered in TWO places - `EmeraldHomeView.surahList` (emerald) and `HomeView.legacyBody` (light) - both get the strip via one shared row wrapper.

**Files:**
- Create: `Thaqalayn/Views/DeepDive/SurahExperienceListStrip.swift` (strip + row wrapper)
- Modify: `Thaqalayn/ContentView.swift` (`ModernSurahCard` gains `squaredBottom`)
- Modify: `Thaqalayn/Views/EmeraldHomeView.swift:185-191` (use the wrapper)
- Modify: `Thaqalayn/Views/HomeView.swift:111-116` (use the wrapper)

**Interfaces:**
- Consumes: `SurahExperienceDescriptor.bySurahNumber(_:)/byId(_:)`, `PremiumManager.canAccessSurahExperience`, `DeepDiveView(dive:onClose:onReadSurah:)`, `PresentedSurahExperience` (from Task 5), `Notification.Name.navigateToVerse`, `PaywallView`.
- Produces: `SurahListRow(surahWithTafsir:)` - the drop-in replacement for the `PressableNavLink { SurahDetailView } label: { ModernSurahCard }` pattern; `ModernSurahCard(surah:squaredBottom:)`.

- [ ] **Step 1: Write the strip + row wrapper:**

```swift
//
//  SurahExperienceListStrip.swift
//  Thaqalayn
//
//  The split-row entry to a sūrah's "Inside the Sūrah" experience: an attached
//  strip under that sūrah's card in the Quran-tab list. The main row keeps
//  opening the sūrah; the strip opens the experience directly. PREMIUM chip
//  (never a lock) when gated; theme-adaptive (emerald + light). Chrome - fixed
//  size, no reading-scale.
//

import SwiftUI

/// One sūrah row in the Quran-tab list: the navigation card, plus - for sūrahs
/// with a built experience - the attached experience strip. Drop-in replacement
/// for the bare PressableNavLink + ModernSurahCard pattern in both themes.
struct SurahListRow: View {
    let surahWithTafsir: SurahWithTafsir
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var presentedExperience: PresentedSurahExperience?
    @State private var showingPaywall = false

    /// The "Inside the Sūrah" experience for this sūrah, when one is built.
    private var experience: SurahExperienceDescriptor? {
        guard let d = SurahExperienceDescriptor.bySurahNumber(surahWithTafsir.surah.number),
              d.available else { return nil }
        return d
    }

    var body: some View {
        VStack(spacing: 0) {
            PressableNavLink {
                SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil)
            } label: {
                ModernSurahCard(surah: surahWithTafsir.surah, squaredBottom: experience != nil)
            }
            if let d = experience {
                SurahExperienceListStrip(descriptor: d) { handleTap(d) }
            }
        }
        .fullScreenCover(item: $presentedExperience) { p in
            if let d = SurahExperienceDescriptor.byId(p.id), let dive = d.dive {
                DeepDiveView(dive: dive,
                             onClose: { presentedExperience = nil },
                             onReadSurah: {
                                 // Dismiss the descent, then hand off to the sūrah -
                                 // MainTabView's .navigateToVerse listener stashes the
                                 // deep link and HomeView pushes SurahDetailView.
                                 presentedExperience = nil
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                     NotificationCenter.default.post(
                                         name: .navigateToVerse, object: nil,
                                         userInfo: ["surah": d.surahNumber, "verse": 1])
                                 }
                             })
            }
        }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }

    private func handleTap(_ d: SurahExperienceDescriptor) {
        if premiumManager.canAccessSurahExperience(d.id) {
            // Let the press squish play before the cover slides up.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                presentedExperience = PresentedSurahExperience(id: d.id)
            }
        } else {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showingPaywall = true }
        }
    }
}

/// The attached strip itself: moon icon, eyebrow, hook, PREMIUM chip, chevron.
struct SurahExperienceListStrip: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let descriptor: SurahExperienceDescriptor
    let onTap: () -> Void

    private var locked: Bool { !premiumManager.canAccessSurahExperience(descriptor.id) }

    private var shape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: 0, bottomLeadingRadius: 20,
                               bottomTrailingRadius: 20, topTrailingRadius: 0,
                               style: .continuous)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: descriptor.sfSymbol)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(tm.accentColor)
                Text(JourneyStrings.insideTheSurah(lang).uppercased())
                    .emEyebrow(lang, size: 10, tracking: 1.8)
                    .foregroundColor(tm.accentColor)
                Text(JourneyStrings.anImmersiveJourney(lang))
                    .font(.system(size: 12))
                    .foregroundColor(tm.secondaryText)
                    .lineLimit(1)
                Spacer(minLength: 8)
                if locked { premiumPill }
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(tm.accentColor)
            }
            .padding(.horizontal, 20).padding(.vertical, 12)
            .background(shape.fill(tm.glassSurface))
            .overlay(shape.stroke(tm.strokeColor, lineWidth: 1))
            .overlay(alignment: .top) {
                Rectangle().fill(tm.strokeColor).frame(height: 1)
            }
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
        }
        .buttonStyle(EmPressStyle())
    }

    private var premiumPill: some View {
        Text(JourneyStrings.premium(lang).uppercased())
            .font(.system(size: 9, weight: .bold)).tracking(1.4)
            .foregroundColor(tm.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(tm.accentChip))
            .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
    }
}
```

Also add to `JourneyStrings` (Task 3 file, same region as `insideTheSurah`):

```swift
    static func anImmersiveJourney(_ l: CommentaryLanguage) -> String {
        pick(l, en: "An immersive journey", ur: "ایک عمیق سفر", ar: "رحلة غامرة")
    }
```

- [ ] **Step 2: Give `ModernSurahCard` a squared-bottom variant** (`Thaqalayn/ContentView.swift:438`). Add below the existing `let surah: Surah`:

```swift
    /// True when an experience strip is attached below - squares the bottom
    /// corners so card + strip read as one card.
    var squaredBottom = false
```

In `emeraldBody` (line ~567), replace the `EmCard { ... }` wrapper with the same content wrapped in an explicit background so the corners can be uneven (fill/stroke/shadow copied from `EmCard`'s non-elevated look):

```swift
    private var cardShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: 20,
                               bottomLeadingRadius: squaredBottom ? 0 : 20,
                               bottomTrailingRadius: squaredBottom ? 0 : 20,
                               topTrailingRadius: 20,
                               style: .continuous)
    }

    private var emeraldBody: some View {
        HStack(spacing: 16) {
            // ... existing content unchanged ...
        }
        .padding(20)
        .background(cardShape.fill(themeManager.glassSurface))
        .overlay(cardShape.stroke(themeManager.strokeColor, lineWidth: 1))
        .shadow(color: Color.black.opacity(0.28), radius: 24, x: 0, y: 8)
    }
```

In `legacyBody`, swap its `RoundedRectangle(cornerRadius: 20)` background/overlay for the same `cardShape` (keep its existing fill colors and shadow values). The card-strip seam shows the two 1px hairlines meeting; that reads as the divider, matching the mockup.

- [ ] **Step 3: Swap in the wrapper at both list sites.** In `EmeraldHomeView.surahList` replace:

```swift
            ForEach(filteredSurahs) { swt in
                PressableNavLink {
                    SurahDetailView(surahWithTafsir: swt, targetVerse: nil)
                } label: {
                    ModernSurahCard(surah: swt.surah)
                }
            }
```

with:

```swift
            ForEach(filteredSurahs) { swt in
                SurahListRow(surahWithTafsir: swt)
            }
```

In `HomeView.legacyBody`, replace the equivalent `PressableNavLink { SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil) } label: { ModernSurahCard(surah: surahWithTafsir.surah) }` inside its `ForEach` the same way (keep the existing search filter).

- [ ] **Step 4: Build.** Same command - Expected: `BUILD SUCCEEDED`. Strips are invisible until a descriptor flips `available: true`; all other rows render exactly as before (`squaredBottom` defaults false).

---

### Task 7: Yūsuf - distill the surah brief

No Swift. Produces the working brief that Task 8 drafts from. **The defining requirement: digest every verse's full tafsir, not just the eventual landmark verses.**

**Files:**
- Create: `docs/plans/surah-experience/yusuf-brief.md`
- Scratch: `<scratchpad>/tafsir_12_en.json`

**Interfaces:**
- Consumes: `Thaqalayn/Thaqalayn/Data/tafsir_12.json` (4.4 MB, trilingual+FR), `Thaqalayn/Thaqalayn/Data/quran_data.json`.
- Produces: `yusuf-brief.md` with the sections listed in Step 3.

- [ ] **Step 1: Extract English-only tafsir** (keeps agent context manageable):

```bash
source .venv/bin/activate
python3 - <<'EOF'
import json
src = json.load(open('Thaqalayn/Thaqalayn/Data/tafsir_12.json'))
slim = {}
for verse, layers in src.items():
    if not isinstance(layers, dict) or not verse.isdigit():
        continue
    slim[verse] = {k: v for k, v in layers.items()
                   if k in ('layer1','layer2','layer3','layer4','layer5')}
out = '<scratchpad>/tafsir_12_en.json'
json.dump(slim, open(out, 'w'), ensure_ascii=False, indent=1)
print(f"{len(slim)} verses -> {out}")
EOF
```

Expected: `111 verses -> ...`. (Replace `<scratchpad>` with the session scratchpad path.)

- [ ] **Step 2: Chunked distillation, waves of two agents max.** Wave 1: agent A reads verses 1-37, agent B verses 38-74. Wave 2: agent C verses 75-111. Each agent reads its slice of `tafsir_12_en.json` and returns structured notes: (1) themes per passage, (2) standout gems - verse, layer, the insight in one or two sentences, why it stands out, (3) every Ahlul Bayt narration found in layer4 with its stated source, (4) arc observations (turns, echoes, refrains). Store each wave's notes in the brief file as appendices.

- [ ] **Step 3: Synthesize the brief** (main session, reading all notes) into `docs/plans/surah-experience/yusuf-brief.md` with EXACTLY these sections:
  1. **The soul** - 2-3 candidate one-line statements of what the surah IS.
  2. **Arc / movements** - proposed 3-movement structure with names drawn from the surah (e.g. The Dream / The Test / The Reunion), each movement's span of verses and its emotional register.
  3. **Landmark verses (ranked)** - 8-12 candidates; for each: surah:ayah, why it is a landmark, the single best tafsir gem with layer + source attribution (e.g. "layer2, al-Mizan").
  4. **Narration candidates** - each with text summary + citation; note verified-on-file Yūsuf narrations (chastity 12:24, prison-reliance 12:42, well-dua, forgiveness 12:92 ʿIlal al-Sharāʾiʿ) from prior research.
  5. **Revelation context + fadail** - only citable claims, each with source; drop anything uncitable.
  6. **Proposed depth** - beat count (16-24 range per spec for Yūsuf), verse-beat count (6-10), the DEPTHS map's 3 stations, and a full proposed beat list in order.

- [ ] **Step 4: Sanity check** - confirm every verse number cited in the brief exists in surah 12 (1-111) and every gem names its layer.

---

### Task 8: Yūsuf - English script + USER APPROVAL GATE

**Files:**
- Create: `docs/plans/surah-experience/yusuf-script.md`

**Interfaces:**
- Consumes: `yusuf-brief.md`; `quran_data.json` for verse Arabic + translations.
- Produces: the approved English master script, beat-by-beat, that Task 9 translates and builds. Beat vocabulary: `open, orientation, act, verse, depths, narration, climax, reflectionPrompt, closing` (NO dua).

- [ ] **Step 1: Draft the full script.** One section per beat, in final order, honoring the brief's approved depth. For each beat give every field the Swift case needs (see `DeepDiveSection` in `DeepDive.swift`), with hand-polished narrative copy at the Yaqīn/Sabr bar - not pasted tafsir. Rules:
  - `verse` beats: copy the Arabic VERBATIM from `quran_data.json` (surah 12), single ayah each; translation may be trimmed with ellipses but never altered; reference format `Yūsuf · 12 : N`.
  - `act` beats: `connector` names the thread back from the prior movement (nil for Act I).
  - `narration`: one verified Ahlul Bayt narration with citation in the `source` field.
  - `climax`: the surah's soul in one unforgettable line (Arabic phrase from the surah + translation + body).
  - `reflectionPrompt`: prompt + subline + nextLabel (nextLabel leads INTO the closing, e.g. "One last thing" - not "And one prayer").
  - `closing`: tag, titleAr (`يُوسُف`), essence (one line), line (parting note). No dua.
  - No em dashes anywhere.

- [ ] **Step 2: Verify Arabic verbatim** for every verse/bridge beat. Schema: `q['verses']['<surah>']['<ayah>']['arabicText']` (also has `translation` / `translationUrdu`; only the ARABIC must match verbatim - our display translations are hand-written). Paste every (ayah, arabic) pair from the script doc into `CHECKS`:

```bash
source .venv/bin/activate
python3 - <<'EOF'
import json
q = json.load(open('Thaqalayn/Thaqalayn/Data/quran_data.json'))
SURAH = '12'
CHECKS = [
    # (ayah, arabic exactly as it appears in the script doc)
    (4, "إِذْ قَالَ يُوسُفُ لِأَبِيهِ ..."),
]
ok = True
for ayah, arabic in CHECKS:
    truth = q['verses'][SURAH][str(ayah)]['arabicText'].strip()
    status = 'PASS' if arabic.strip() == truth else 'FAIL'
    if status == 'FAIL': ok = False
    print(f"{SURAH}:{ayah} {status}")
raise SystemExit(0 if ok else 1)
EOF
```

Every line must print PASS (fix the script doc, not the data). Partial-verse excerpts are not allowed for `verse` beats; quote the full `arabicText`.

- [ ] **Step 3: USER APPROVAL GATE - HARD STOP.** Present the script in chat (beat list + full copy). Iterate until the user approves. Do NOT proceed to Task 9, and do NOT start any translation, before explicit approval.

---

### Task 9: Yūsuf - translate, build, announce

**Files:**
- Create: `Thaqalayn/Content/SurahYusufDive.swift`
- Modify: `Thaqalayn/Services/SurahExperienceCatalog.swift` (flip Yūsuf `available: true`, attach `dive: .surahYusuf`)
- Modify: `docs/plans/surah-experience/yusuf-script.md` (append UR/AR columns)
- Modify: `Thaqalayn/Models/WhatsNewItem.swift`
- Modify: `Thaqalayn/Views/WhatsNewCard.swift`

**Interfaces:**
- Consumes: approved `yusuf-script.md`; `DeepDive`/`DeepDiveSection` incl. `closing` and 5-param `reflectionPrompt`; urdu-translator + arabic-translator agents.
- Produces: `DeepDive.surahYusuf`; `WhatsNewDestination.surahExperience(String)`.

- [ ] **Step 1: Translate.** One wave of two agents: urdu-translator + arabic-translator, each given the approved English script. They translate ONLY prose fields (kicker, subtitle, line, tag, promise, leaveWith, translation, reflection, connector, source display text, body, prompt, subline, nextLabel, essence); Qur'an Arabic, references, and `titleAr` stay untouched. Append the translations into the script file per beat. Spot-check 3 random beats per language for register (devotional, not literal-stiff).

- [ ] **Step 2: Write `SurahYusufDive.swift`** following `SabrDeepDive.swift`'s structure exactly:

```swift
//
//  SurahYusufDive.swift
//  Thaqalayn
//
//  Fixed content for the "Inside the Sūrah - Yūsuf" experience. Rendered by
//  DeepDiveView; see docs/superpowers/specs/2026-07-07-surah-experience-design.md
//  and docs/plans/surah-experience/yusuf-script.md (approved master copy).
//

import SwiftUI

extension DeepDive {
    static let surahYusuf: DeepDive = DeepDive(
        id: "surah-yusuf",
        titleEn: "Yūsuf",
        titleAr: "يُوسُف",
        subtitle: /* from script */,
        sfSymbol: "moon.stars",
        estMinutes: /* from approved depth, e.g. 15 */,
        acts: [ /* three ActInfo from script */ ],
        sections: [ /* every beat from the script, in order, ending .reflectionPrompt then .closing */ ]
    )
}
```

Populate every field from the trilingual script (this is transcription, not authoring). The section list must contain NO `.dua`.

- [ ] **Step 3: Flip the catalog entry** - in `SurahExperienceCatalog.swift` change Yūsuf's entry to `available: true, dive: .surahYusuf`.

- [ ] **Step 4: What's New.** In `WhatsNewItem.swift` add the destination case:

```swift
    /// Open an "Inside the Sūrah" experience by id (lives in the Journey hub, tab 4).
    case surahExperience(String)
```

Add the catalog entry at the TOP of `WhatsNewCatalog.all` (releaseDate = the planned ship date; adjust day when known):

```swift
        WhatsNewItem(
            id: "surahExperience-yusuf",
            sfSymbol: "moon.stars",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 20).date ?? .distantPast,
            destination: .surahExperience("surah-yusuf"),
            titleEN: "Inside the Sūrah",
            titleUR: "سورہ کے اندر",
            titleAR: "في قلب السورة",
            blurbEN: "Sūrah Yūsuf - an immersive journey through the most beautiful of stories, from the dream to the reunion.",
            blurbUR: "سورۂ یوسف - خواب سے وصال تک، بہترین قصے کا ایک عمیق سفر۔",
            blurbAR: "سورة يوسف - رحلة غامرة عبر أحسن القصص، من الرؤيا إلى اللقاء.",
            ctaEN: "Begin the journey",
            ctaUR: "سفر شروع کریں",
            ctaAR: "ابدأ الرحلة"
        ),
```

In `WhatsNewCard.swift` extend `open()`'s switch:

```swift
        case .surahExperience(let experienceId):
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                router.pendingSurahExperienceId = experienceId
                selectedTab = 4
            }
```

- [ ] **Step 5: Add a removable debug preview** at the bottom of `SurahYusufDive.swift`:

```swift
#if DEBUG
#Preview("Sūrah Yūsuf experience") {
    DeepDiveView(dive: .surahYusuf, onClose: {})
}
#endif
```

- [ ] **Step 6: Build.** Same command - Expected: `BUILD SUCCEEDED`. Report to the user for simulator verification (hub card, list strip on Sūrah 12 in both themes, full descent, closing hand-off back to the sūrah, paywall when not premium, UR/AR passes).

---

### Task 10: Yāsīn - full content pipeline

Repeat the Yūsuf recipe for surah 36 (83 verses, `tafsir_36.json`, 2.6 MB). Same steps, own artifacts:

- [ ] **Step 1: Extract** `tafsir_36.json` → `<scratchpad>/tafsir_36_en.json` with the Task 7 Step 1 script (change both numbers). Expected: `83 verses`.
- [ ] **Step 2: Distill** - wave of two agents (verses 1-42, 43-83); notes with the same four categories as Task 7 Step 2.
- [ ] **Step 3: Brief** → `docs/plans/surah-experience/yasin-brief.md`, same six sections. Yāsīn is thematic, not one story: movements must come from its own structure (e.g. the messengers' story / the signs / resurrection), soul candidates around "the heart of the Qur'an" claim - fadail only with citations. Depth: 16-24 beats per spec.
- [ ] **Step 4: Script** → `docs/plans/surah-experience/yasin-script.md`, Task 8 rules (verse Arabic verbatim from `quran_data.json` surah 36, reference format `Yāsīn · 36 : N`, no dua, closing titleAr `يس`).
- [ ] **Step 5: Verify Arabic** (Task 8 Step 2 method, surah 36). All PASS.
- [ ] **Step 6: USER APPROVAL GATE - HARD STOP.**
- [ ] **Step 7: Translate** (one wave: urdu + arabic translators), transcribe to `Thaqalayn/Content/SurahYasinDive.swift` (`static let surahYasin`, id `"surah-yasin"`, sfSymbol `"heart"`), flip catalog entry to `available: true, dive: .surahYasin`, add `#if DEBUG` preview.
- [ ] **Step 8: Build.** Expected: `BUILD SUCCEEDED`. Report for user verification.

---

### Task 11: al-Raḥmān - full content pipeline

Repeat for surah 55 (78 verses, `tafsir_55.json`, 2.4 MB):

- [ ] **Step 1: Extract** → `<scratchpad>/tafsir_55_en.json`. Expected: `78 verses`.
- [ ] **Step 2: Distill** - wave of two agents (verses 1-39, 40-78).
- [ ] **Step 3: Brief** → `docs/plans/surah-experience/rahman-brief.md`. The refrain ("which of your Lord's favors will you deny", 31 times) is the structural spine - the movements and the DEPTHS map should honor it; include the Shia reading of the refrain from layer4 if present. Depth: mid-range (~14-18 beats).
- [ ] **Step 4: Script** → `docs/plans/surah-experience/rahman-script.md` (reference format `al-Raḥmān · 55 : N`, closing titleAr `الرَّحْمَٰن`).
- [ ] **Step 5: Verify Arabic** (surah 55). All PASS.
- [ ] **Step 6: USER APPROVAL GATE - HARD STOP.**
- [ ] **Step 7: Translate + transcribe** to `Thaqalayn/Content/SurahRahmanDive.swift` (`static let surahRahman`, id `"surah-rahman"`, sfSymbol `"water.waves"`), flip catalog, `#if DEBUG` preview.
- [ ] **Step 8: Build.** Expected: `BUILD SUCCEEDED`. Report for user verification.

---

### Task 12: al-Mulk - full content pipeline

Repeat for surah 67 (30 verses, `tafsir_67.json`, 0.7 MB) - the short-surah proof of the format:

- [ ] **Step 1: Extract** → `<scratchpad>/tafsir_67_en.json`. Expected: `30 verses`.
- [ ] **Step 2: Distill** - ONE agent reads all 30 verses (no chunking needed).
- [ ] **Step 3: Brief** → `docs/plans/surah-experience/mulk-brief.md`. Depth: 10-13 beats, ~4 verse beats per spec. Fadail (protector in the grave) only with citations.
- [ ] **Step 4: Script** → `docs/plans/surah-experience/mulk-script.md` (reference format `al-Mulk · 67 : N`, closing titleAr `الْمُلْك`).
- [ ] **Step 5: Verify Arabic** (surah 67). All PASS.
- [ ] **Step 6: USER APPROVAL GATE - HARD STOP.**
- [ ] **Step 7: Translate + transcribe** to `Thaqalayn/Content/SurahMulkDive.swift` (`static let surahMulk`, id `"surah-mulk"`, sfSymbol `"crown"`), flip catalog, `#if DEBUG` preview.
- [ ] **Step 8: Build.** Expected: `BUILD SUCCEEDED`. Report for user verification.

---

### Task 13: Final sweep

- [ ] **Step 1: Full clean build** - `xcodebuild -scheme Thaqalayn -destination 'platform=iOS Simulator,name=iPhone 16 Pro' clean build 2>&1 | tail -5`. Expected: `BUILD SUCCEEDED`, no warnings from the new files.
- [ ] **Step 2: Content grep gates** - all must return nothing:

```bash
grep -rn "—" Thaqalayn/Content/Surah*Dive.swift Thaqalayn/Services/SurahExperienceCatalog.swift || echo "no em dashes: PASS"
grep -n "\.dua(" Thaqalayn/Content/Surah*Dive.swift || echo "no dua beats: PASS"
grep -rn "lock.fill" Thaqalayn/Views/DeepDive/SurahExperienceCard.swift Thaqalayn/Views/DeepDive/SurahExperienceListStrip.swift || echo "no lock icons: PASS"
```

- [ ] **Step 3: Checklist against the spec** - confirm: four catalog entries available; hub section renders; the list strip appears on surahs 12/36/55/67 only (both themes) and every other row is unchanged; What's New entry present with correct destination; every `closing` beat is the last section; every `reflectionPrompt` has surah-appropriate subline/nextLabel; `estMinutes` reflects each surah's approved depth.
- [ ] **Step 4: Hand to the user** for final simulator verification and commit/release (remind: CloudKit does not apply here - no schema change; version bump via /bump-version when releasing).
