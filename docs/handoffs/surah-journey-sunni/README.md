# Handoff Package - "Inside the Surah" (Surah Journey) -> Sunni app (AlBayan)

> **For the implementing Claude (in the AlBayan repo):** This package is a self-contained port plan for the **"Inside the Surah"** immersive experience (a.k.a. the Surah Journey). Everything you need is in this folder - you are assumed to have **zero access** to the source (Thaqalayn) repo. The complete engine + all six built surahs' source live under `src/`; the full authored text of each surah lives under `text/`; the authoring skill and its reference guides live under `reference/`.

**Source:** Thaqalayn (Shia) - "Inside the Surah" shipped as the al-Fatiha flagship, then al-Baqara, Al Imran, al-Nisa, Yusuf, al-Rahman.
**Target:** AlBayan (Sunni sibling iOS app, SwiftUI).
**Goal:** Rebuild the feature with the **exact same engine and structure**, wired into **AlBayan's own theme + premium/Today infrastructure**, with **every word of content re-authored from Sunni sources**.

---

## 1. What you're building

An immersive, full-screen, one-sitting **"descent" through a single surah**: a vertical, paged sequence of cinematic "beats" (an opening threshold, an orientation, verse cards with reflections, movement dividers, narrations, a climax, an interactive close, a handoff to reading the surah). It is an **understanding journey**, not a reading view and not a devotional - the reader comes out knowing the surah's shape, its turns, and its heart.

It has **two entry points** in the app:

1. **Journey hub, "Inside the Surah" shelf** - a horizontal shelf of poster cards (tab 4), peer to the "Sacred Seasons" and "Deep Dives" shelves.
2. **Quran tab, the surah's own list row** - the surah card gains an attached **"Read & Tafsir | Journey"** mode toggle. The Journey tab opens the descent.

**Gating:** al-Fatiha is **free** (the flagship teaser at the top of the Quran tab); every other surah is **premium**. A gated reader is not bounced - they get a **veiled preview** (the threshold + orientation, then a "veil" beat that names what lies beneath and opens the paywall).

The **same engine** (`DeepDive` model + `DeepDiveView` renderer) also powers Thaqalayn's *theme* Deep Dives (Sabr, Tawakkul, Yaqin, Shukr). Those are **out of scope** for this handoff, but if AlBayan wants them later they port the identical way - only the content differs. This package covers the **six surah experiences** only.

---

## 2. Read this first - the 3-layer principle

Every file in this port falls into exactly one of three layers. **Do not blur them.**

| Layer | What it is | What you do |
|---|---|---|
| **Engine** (sect-agnostic, mostly theme-agnostic) | `DeepDive.swift` (the data model + beat enum), the extraction/verse tooling | **Copy verbatim** from `src/`. Pure Swift data types. Zero Shia content. |
| **UI** (theme-coupled) | `DeepDiveView.swift` (the renderer) + the shelf/card/row/toggle views + backgrounds | **Reuse the structure, re-skin the primitives.** The renderer's *logic* (paging, the beat switch, the veiled-preview cut, reading-scale) is portable; its *look* references Thaqalayn theme primitives (`EmType`, `EmCard`, `ThemeManager`, `tm.accentColor`, fonts). Rebind those to AlBayan's design system. See §6 + §7. |
| **Content** (Shia -> Sunni) | The six `Surah*Dive.swift` files, and their plain-text dumps in `text/` | **Re-author every word from Sunni sources.** The structure and beat choices are an excellent template; the tafsir, narrations, sourcing, and honorifics are Shia and must be replaced. See §8. |

**The engine is genuinely portable as-is.** `DeepDive.swift` contains no sectarian content and no UI - copy it. The renderer is portable in *shape* but coupled to theme primitives - port it against AlBayan's design system. The content is a **template to learn from**, not text to copy.

---

## 3. What AlBayan already provides - do NOT rebuild

You confirmed AlBayan already has these. Hook into them; don't recreate them.

- **A Journey hub / "grow" tab** with horizontal shelves - you add one "Inside the Surah" shelf.
- **A Quran/surah list** - you attach the mode toggle to rows whose surah has an experience.
- **A premium manager + paywall** - gate with a one-liner (`canAccessSurahExperience`) and present your existing paywall for locked taps.
- **A "What's New"/Today spotlight** (if present) - add one entry per shipped surah.
- **A global reading text-size control** - the renderer must scale reading body copy by it (see §6.3). If AlBayan's control is named differently, rebind to it.
- **A deep-link router** - add one pending-id field so a Today card can open an experience on another tab.

Everything else in this package you build.

---

## 4. Architecture map

```
JOURNEY HUB (tab 4)                         QURAN TAB (surah list)
  └─ "Inside the Surah" shelf                 └─ SurahListRow
       └─ SurahExperienceCard  ─┐                  └─ ModernSurahCard + JourneyModeToggle ─┐
                                │                                                          │
                    handleSurahExperienceTap                                        handleTap
                                │                                                          │
                                └──────────────►  fullScreenCover  ◄──────────────────────┘
                                                        │
                                                  DeepDiveView(dive:onClose:onReadSurah:
                                                               coverAssetName:lockedPaywallContext:)
                                                        │
                            ┌───────────────────────────┼───────────────────────────┐
                            ▼                           ▼                            ▼
                    reads DeepDive               renders each             veiled-preview cut
                    (model + sections)           DeepDiveSection beat     if lockedPaywallContext != nil
                            │
                    SurahExperienceCatalog.all  ──►  .dive: DeepDive  ──►  Surah<Name>Dive.swift (content)
```

### Files in `src/` (copy these; re-skin the UI ones)

| File | Layer | Role |
|---|---|---|
| `DeepDive.swift` | **Engine** | The data model. `DeepDive` (one experience), `DeepDiveSection` (the beat enum - every screen type), plus `ActInfo`, `Depth`, `BridgeVerse`. **Copy verbatim.** Depends only on `LocalizedText` (see §5). |
| `DeepDiveView.swift` | **UI** | The 1,300-line renderer. Paged vertical scroll; a `switch` over `DeepDiveSection` into one `*Page` builder per beat; reading-scale; the veiled-preview gate; interactive beats (`release`, `count`, `refrain`). Port the structure; rebind theme primitives. |
| `DeepDiveBackground.swift` | **UI** | The animated gradient/particle backdrop that deepens as you descend. Re-skin colors. |
| `DeepDiveCard.swift` | **UI** | Hub card for a *theme* dive (reference for card styling; the surah card is below). |
| `SurahExperienceCard.swift` | **UI** | Hub card for a surah experience (poster/eyebrow/PREMIUM chip/chevron). |
| `SurahListRow.swift` | **UI** | The Quran-list row = surah card + attached Journey mode toggle, one combined border. |
| `JourneyModeToggle.swift` | **UI** | The "Read & Tafsir | Journey" segmented control that breathes/glows to invite the tap. |
| `SurahExperienceCatalog.swift` | **Engine-ish** | The static registry: one `SurahExperienceDescriptor` per surah (id, surahNumber, title/subtitle, cover, `available`, `dive`). **This is where you register each ported surah.** |
| `content/Surah*Dive.swift` (×6) | **Content** | The six built experiences, verbatim. Your **template** - study the structure, re-author the words. |

### Files in `text/` (the content, human-readable)

Plain-text, beat-by-beat dumps of all six experiences - the same words the app shows, without the Swift. Read these to see **how the writing works**; author the Sunni versions the same way. Generated mechanically by `reference/extract_text.py` (verbatim - no paraphrase). See §9.

### Files in `reference/` (the authoring method)

- `inside-the-surah-SKILL.md` - the **full authoring pipeline** Thaqalayn uses to build a new surah experience (research -> blueprint -> script -> implement -> build -> audit, with two approval gates). Adapt it to Sunni sourcing.
- `beat-vocabulary.md` - **every beat type explained** and when to use it. Read this alongside §5.
- `technical-integration.md` - the exact wiring steps to add a new dive (catalog entry, verse-Arabic pull, What's New, `#if DEBUG` preview).
- `audit.md` - the three-auditor flow/theology/readability QA pass used before shipping each surah.
- `extract_text.py` - the tool that produced `text/` (kept for provenance; re-runnable on your own ported files).

---

## 5. The data model (Engine - copy verbatim)

One file: `src/DeepDive.swift`. A `DeepDive` is pure data; `DeepDiveView` renders it. Adding a surah is a pure content addition - a new `Surah<Name>Dive.swift` returning a `static let`.

```swift
struct DeepDive: Identifiable {
    let id: String
    let titleEn: String
    let titleAr: String
    let subtitle: LocalizedText
    let sfSymbol: String
    let estMinutes: Int
    var stageNoun: String = "Depth"   // the movement-card noun: Depth / Station / Motion / Movement
    let acts: [ActInfo]               // the movements (see the Prime Directive: derive the count)
    let sections: [DeepDiveSection]   // the ordered beats
}
```

### `DeepDiveSection` - the beat vocabulary

Each case is one full-screen beat. The `act:` int groups beats into movements and drives the persistent depth stepper (`act 0` = opening/orientation, `act 4` = the close). Full explanations in `reference/beat-vocabulary.md`; the ones the six surahs use:

| Beat | Purpose |
|---|---|
| `.open` | The threshold: kicker, Arabic + English title, one hook line. |
| `.orientation` | "How this works + the promise" - what you'll leave knowing. The end of the free preview. |
| `.act` | A movement divider. `connector` names the thread back to the prior movement; optional `bridge` verse. |
| `.verse` | A Quran verse card: Arabic (verbatim), translation, reference, and a reflection. The workhorse. |
| `.depths` | An at-a-threshold "map" of the journey (use `act: 0`, before Movement I). Optional - most surahs skip it. |
| `.narration` | A hadith/tradition beat: source, body, reflection. |
| `.response` | A call-and-response "He answers" beat (used in al-Fatiha for the division-of-the-prayer hadith qudsi). |
| `.climax` | The peak beat: a source verse + body + reflection. |
| `.refrain` | al-Rahman's recurring question: the verse glows and the reader answers it (interactive). 13 params. |
| `.reflectionPrompt` | An interactive "name the line you'll mean" close. |
| `.release` / `.count` | Theme-dive interactive closes (entrustment / gratitude). Surah dives generally use `.closing`. |
| `.closing` | The surah-experience finale: restates the essence and hands off to reading the full surah. |

> **`LocalizedText` dependency.** Every prose field is a `LocalizedText` (en + optional ur/ar). It's the same trilingual primitive used across the app; if AlBayan already has it (the daily-features handoff ships it in `DailyChallengeModels.swift`), **reuse that one - do not duplicate**. Bare string literals satisfy it via `ExpressibleByStringLiteral`, so English-only content compiles as `line: "..."`. Qur'an Arabic and references stay single-string (identical across languages).

---

## 6. The renderer (UI - port the structure, re-skin the primitives)

`src/DeepDiveView.swift`. Big but mechanical. The parts you must preserve vs. re-skin:

### 6.1 Structure (preserve)
- A `GeometryReader` + paged `ScrollView` (`.scrollTargetBehavior(.paging)`), one full-screen page per section.
- `body`'s core is `page(_:index:)` -> `content(_:_:_:)` which `switch`es over `DeepDiveSection` into one `*Page(...)` builder per beat. Keep this shape - it's how new beats stay isolated.
- A progress hairline, a close button, and a persistent "depth stepper" (`placeBar`) driven by `section.act` and `dive.acts.count`.
- Entrance reveals (`reveal(_:_:reduce:)`) honoring `accessibilityReduceMotion`.

### 6.2 The veiled-preview gate (preserve - this is the paywall UX)
```swift
private var isLocked: Bool { lockedPaywallContext != nil }
private var visibleSections: [DeepDiveSection] {
    isLocked ? Array(dive.sections.prefix { $0.act == 0 }) : dive.sections
}
```
A gated reader sees exactly the `act 0` beats (`.open` + `.orientation`), then a **veil page** that names what's beneath and opens `PaywallView(context: lockedPaywallContext)`. The cut is drawn by the *content* (every dive has exactly one `.open` and one `.orientation`), not a page count. Keep this - it's why al-Fatiha can be free and the rest premium without separate code paths.

### 6.3 Reading text-size (preserve - accessibility requirement)
```swift
@StateObject private var reading = ReadingSettingsManager.shared
private var s: CGFloat { reading.scale }
```
Reading **body** copy (verse Arabic, translations, reflections, narration bodies, prose lines) is multiplied by `s`. **Chrome does not scale** (eyebrows, tags, references, section labels, buttons). Rebind `ReadingSettingsManager.shared` to AlBayan's reading-scale control. This is a hard rule in both apps - do not hardcode around it.

### 6.4 Re-skin (rebind to AlBayan's design system)
Search-and-replace the Thaqalayn theme primitives for AlBayan's equivalents:
- `EmType.serif(size, weight)` -> AlBayan's serif font ramp.
- `EmCard`, `EmIconChip`, `EmCoverTile`, `EmPressStyle`, `EmHeading`, `EmType` -> AlBayan card/press/heading primitives.
- `ThemeManager.shared` / `tm.accentColor`, `tm.primaryText`, `tm.secondaryText`, `tm.strokeColor`, `tm.accentChip` -> AlBayan theme tokens.
- `DeepDiveBackground` gradient colors -> AlBayan's palette (keep the "deepens as you descend" behavior).
- `JourneyStrings.*`, `CommentaryLanguageManager` -> AlBayan's localized-strings + language manager.

---

## 7. Integration points (wire into AlBayan)

All six wiring points, with the exact Thaqalayn code to mirror. Full files are in `src/`; the shared-file excerpts are inlined here.

### 7.1 Registry - `SurahExperienceCatalog.swift` (copy + edit)
One `SurahExperienceDescriptor` per surah. `available: true, dive: .surah<Name>` when built; `available: false, dive: nil` for a "coming soon" roadmap card. `byId` / `bySurahNumber` are the lookups the UI uses. **This is the single place you register a ported surah.**

### 7.2 Premium gating - one method
```swift
func canAccessSurahExperience(_ id: String) -> Bool {
    if id == "surah-fatiha" { return true }   // free flagship teaser
    return isPremium
}
```
Add this to AlBayan's premium manager. Everything else gates off it.

### 7.3 Journey hub shelf (mirror `JourneyHubView`)
- `surahItems` maps the catalog to shelf poster items; status = `.ready` / `.premium` / `.soon` via `canAccessSurahExperience` + `available`.
- A `JourneyShelf(label: "Inside the Surah", items: surahItems, ...)` added to the hub body.
- `handleSurahExperienceTap(_:)` presents the descent after the press squish (gated readers get the veiled preview, not a bounce); coming-soon taps show a "coming soon" overlay.
- A `.fullScreenCover(item: $presentedSurahExperience)` builds `DeepDiveView(dive:onClose:onReadSurah:coverAssetName:lockedPaywallContext:)`. `lockedPaywallContext` is `nil` when the reader has access, else a `PaywallContext` carrying the cover + eyebrow.

### 7.4 Quran list-row strip (mirror `SurahListRow` + `JourneyModeToggle`)
For a surah with `SurahExperienceDescriptor.bySurahNumber(n)?.available == true`, the row draws the surah card with a squared bottom + an attached `JourneyModeToggle` (Read | Journey) under one continuous border. The Read tab opens the reading view; the Journey tab presents `DeepDiveView` (same `fullScreenCover` shape as the hub, including the `onReadSurah` handoff that posts `.navigateToVerse` to open the full surah after the descent).

### 7.5 Deep link - one field on the router
```swift
@Published var pendingSurahExperienceId: String? = nil
```
Consumed in the Journey hub on appear + on change:
```swift
private func consumePendingSurahExperience() {
    guard let id = router.pendingSurahExperienceId else { return }
    router.pendingSurahExperienceId = nil
    guard SurahExperienceDescriptor.byId(id)?.dive != nil else { return }
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
        presentedSurahExperience = PresentedSurahExperience(id: id)  // gate still honored at present
    }
}
```

### 7.6 What's New / Today spotlight (one entry per shipped surah)
```swift
enum WhatsNewDestination: Equatable {
    case deepDive(String)
    case surahExperience(String)   // <- add this case
}
```
Add a `WhatsNewItem` with `destination: .surahExperience("surah-<id>")`, and handle it in the card's `open()`:
```swift
case .surahExperience(let experienceId):
    router.pendingSurahExperienceId = experienceId
    selectedTab = 4   // switch to the Journey hub; it opens the experience
```
(If AlBayan has no What's New system, skip this point.)

### 7.7 Onboarding (optional)
Thaqalayn has a `SurahExperienceScreen` in onboarding that teases the format. Optional; port only if AlBayan's onboarding wants it.

---

## 8. Content adaptation - Shia -> Sunni (the real work)

The six surahs are your **structural template**. Keep the *architecture* of each (the beat sequence, the movement logic, the "no spoilers / every beat earns its place" discipline from the SKILL). **Re-author every word from Sunni sources.** Concretely:

1. **Sourcing.** Thaqalayn cites al-Mizan (Tabatabai), Tafsir Nur al-Thaqalayn, Majma al-Bayan, and Ahl al-Bayt narrations. Replace with **Sunni tafsir** (e.g. Ibn Kathir, al-Tabari, al-Qurtubi, al-Baghawi, al-Sa'di) and **Sunni hadith collections** (Bukhari, Muslim, the Sunan, etc.). Verify every narration in a Sunni source before it ships.
2. **Honorifics & framing.** Thaqalayn uses "the Imams (alayhi al-salam)", "the Ahl al-Bayt", Imam Ali / al-Baqir / al-Sadiq as tafsir authorities. Reframe to Sunni convention: the Prophet ﷺ, the Companions (radiya Allahu anhu), the mufassirun. The al-Fatiha dive's climax leans on **Hadith al-Thaqalayn** ("the Book and my family") - re-author that beat's payoff from a Sunni angle (e.g. the Book and the Sunnah / the well-guided path), keeping the *structure* (the surah's plea answered by what God left you).
3. **Distinctly-Shia beats.** al-Rahman's `.refrain` reply ("None of Your favors, my Lord, do I deny") is attributed to Imam Ja'far al-Sadiq via *Thawab al-A'mal*. This exact reply **is** a narration in Sunni-accepted form too (Ibn Kathir and others record the Prophet ﷺ teaching it); re-source it accordingly. Audit each beat for attribution like this.
4. **House style (both apps).** No em dashes (use " - "). Plain English spelling, **no transliteration diacritics** (no macrons/under-dots; ayn/hamza -> straight apostrophe between letters). Qur'an Arabic verbatim from your Quran data (byte-for-byte; pull programmatically, don't hand-type - it drifts to NFC).
5. **Languages.** Author **English first** (Yusuf is fully trilingual; the rest are English-only in the source). Add Urdu/Arabic in a later pass, exactly as Thaqalayn does.

**Use the `inside-the-surah` skill** (`reference/inside-the-surah-SKILL.md`) as your authoring process, swapping its Shia-sourcing rules for Sunni ones. Its "Prime Directive" (fit the surah, don't force the template; derive the movement count) applies unchanged.

---

## 9. The `text/` folder - how to read it

Six files, one per built surah, in Quran order:

| File | Surah | Notes |
|---|---|---|
| `01-al-fatiha.txt` | al-Fatiha (1) | The **free flagship**. Conversation shape; `.response` "He answers" beats; climax = Hadith al-Thaqalayn (re-author for Sunni). |
| `02-al-baqara.txt` | al-Baqara (2) | Thematic-spine strategy for a huge surah (2 movements + a coda). |
| `03-al-imran.txt` | Al Imran (3) | Two-panel diptych ("chosen households"). |
| `04-al-nisa.txt` | al-Nisa (4) | One-trust spine (rewritten from scratch for comprehension). |
| `05-yusuf.txt` | Yusuf (12) | Full narrative arc, threshold map. **Fully trilingual** (en/ur/ar all shown). |
| `06-al-rahman.txt` | al-Rahman (55) | Hymn with the recurring `.refrain` question, answered 4×. |

Each file leads with a **META** block (id, titles, subtitle, movements) then every **BEAT** in order with its fields (`arabic`, `translation`, `reference`, `reflection`, `body`, `source`, ...). Trilingual fields print `[en] / [ur] / [ar]`; English-only fields print one line. The text is **verbatim** from the Swift - it's a mechanical dump, so nothing is paraphrased or summarized. The corresponding `src/content/Surah*Dive.swift` is the same content with the code structure if you need field types.

---

## 10. Master port checklist

Work top to bottom. Don't start content until the engine renders one dive end-to-end.

- [ ] **Engine.** Copy `DeepDive.swift` verbatim. Confirm `LocalizedText` exists in AlBayan (reuse; don't duplicate); if missing, port it.
- [ ] **Renderer.** Port `DeepDiveView.swift`: keep the paging + beat `switch` + veiled-preview + reading-scale; rebind every theme primitive (§6.4) to AlBayan's design system. Port `DeepDiveBackground`.
- [ ] **Cards/rows.** Port `SurahExperienceCard`, `SurahListRow`, `JourneyModeToggle` against AlBayan's card/toggle styling.
- [ ] **Registry.** Add `SurahExperienceCatalog` with al-Fatiha first (`available: true`), the rest as stubs (`available: false`) until authored.
- [ ] **Gating.** Add `canAccessSurahExperience` (§7.2) to AlBayan's premium manager.
- [ ] **Hub shelf.** Add the "Inside the Surah" shelf + `handleSurahExperienceTap` + `fullScreenCover` + `consumePendingSurahExperience` (§7.3, §7.5).
- [ ] **Quran row.** Attach the mode toggle to surahs that have an experience (§7.4), incl. the `onReadSurah` handoff.
- [ ] **Deep link.** Add `pendingSurahExperienceId` to the router (§7.5).
- [ ] **Content - al-Fatiha first.** Re-author `01-al-fatiha.txt` from Sunni sources into `SurahAlFatihaDive.swift`. Pull verse Arabic programmatically. Wrap the `#Preview` in `#if DEBUG`.
- [ ] **Build green** (`xcodebuild`, no XCTest). Ignore SourceKit "cannot find type" false positives on new files.
- [ ] **Audit** each surah with the three-auditor pass (`reference/audit.md`), swapping Shia -> Sunni theology checks.
- [ ] **What's New** entry per shipped surah (§7.6), if AlBayan has the system.
- [ ] Repeat the content loop for al-Baqara, Al Imran, al-Nisa, Yusuf, al-Rahman - in whatever order suits AlBayan's roadmap.

---

## 11. Non-negotiables (both apps)

- **No em dashes**, anywhere. Use " - ".
- **Plain English spelling** - no transliteration diacritics.
- **Reading text-size compliance** in the renderer (§6.3) - body copy scales, chrome does not.
- **Qur'an Arabic verbatim** from your Quran data, pulled programmatically (never hand-typed).
- **Verify every narration** in a Sunni source before it ships.
- **Premium = a "Premium" chip, never a lock icon.**
- al-Fatiha is **free**; every other surah is **premium**.
