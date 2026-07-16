# Handoff Package — Daily Challenge & Daily Crossword → Sunni app (AlBayan)

> **For the implementing Claude (in the AlBayan repo):** This package is a self-contained port plan. Build it task-by-task from the per-feature docs. If you have the `superpowers:executing-plans` skill, use it; otherwise work the **Master port checklist** at the bottom of this file in order. You are assumed to have **zero access** to the source (Thaqalayn) repo — everything you need is in this folder, including verbatim source files under `src/`.

**Source:** Thaqalayn (Shia) — Daily Challenge shipped v6.4 (build 63), Daily Crossword shipped v6.5 (build 64).
**Target:** AlBayan (Sunni sibling iOS app, SwiftUI).
**Goal:** Rebuild both features with the **exact same structure and behavior**, but with **Sunni content** and wired into **AlBayan's own theme + existing Today/premium infrastructure**.

---

## 1. What you're building

Two small, self-contained "daily habit" features that live as cards on the **Today/home tab** and are **premium-gated**:

- **Daily Challenge** — one bite-sized question per day in one of 4 formats (multiple-choice, true/false, flashcard, fill-in-the-blank). Tap the card → answer in a sheet → see the explanation. Maintains a **daily streak**.
- **Daily Crossword** — one small criss-cross mini-crossword per day (≈6 interlocking words on a 5–7 cell grid). Tap the card → solve on a grid with an on-screen keyboard → solved overlay. Maintains a **daily streak**.

Both are **local-only** (no account, no cloud sync), **streak-based** (no points, no badges), and show the **same item to every user on a given calendar day**.

---

## 2. Read this first — the 3-layer principle

Every file in this port falls into exactly one of three layers. **Do not blur them.**

| Layer | What it is | What you do |
|---|---|---|
| **Engine** (sect-agnostic, theme-agnostic) | Models, Managers, Providers, the crossword Python pipeline | **Copy verbatim** from `src/`. Pure logic + UserDefaults + JSON. Zero Shia content, zero theme coupling. |
| **UI** (theme-coupled) | Play screen, Today card, onboarding slide | **Rebuild in AlBayan's theme** using the UX spec in each feature doc + the theme-mapping table in §5. Do **not** copy the Thaqalayn view code — it references theme primitives you don't have. |
| **Content** (Shia → Sunni) | `daily_challenges.json`, the crossword word bank → `daily_crosswords.json` | **Author fresh Sunni content** following the schema + the adaptation ruleset in §7 and the per-feature notes. |

The engine is genuinely portable as-is: `DailyChallengeManager`, `DailyCrosswordManager`, both `Provider`s, all model structs, and the Python scripts contain **no sectarian content and no UI**.

---

## 3. What AlBayan already provides — do NOT rebuild

You confirmed AlBayan already has these. Hook into them; don't recreate them.

- **Today / home tab** — a scrolling home screen where day-cards live. You will insert two cards (`DailyChallengeCard`, `DailyCrosswordCard`) into it, and add day-rollover refresh calls on app-foreground (see §4).
- **Premium manager + paywall** — an `isPremium`-style flag and a paywall sheet. The features gate on it via a one-liner (see §4) and present your existing paywall when a free user taps a locked card.

Everything else in this package you build.

---

## 4. Shared foundations (both features depend on these)

These patterns are identical across the two features. Understand them once here; each feature doc then only points back.

### 4.1 `LocalizedText` — the trilingual content primitive (VERBATIM)

Both features' content uses this one struct. It lives in `src/DailyChallengeModels.swift` and is **reused** by the crossword models (do not duplicate it).

```swift
struct LocalizedText: Codable, Hashable {
    let en: String
    let ur: String?
    let ar: String?

    func text(for language: CommentaryLanguage) -> String {
        switch language {
        case .english, .french: return en
        case .urdu:   return (ur?.isEmpty == false ? ur! : en)
        case .arabic: return (ar?.isEmpty == false ? ar! : en)
        }
    }
}
```

> **Assumption — confirm before starting:** AlBayan supports the same **en / ur / ar + RTL** multilingual model and has a `CommentaryLanguage` enum (or equivalent) + a language manager. If AlBayan is **English-only**, then: make `text(for:)` just return `en`, keep `ur`/`ar` optional (authors leave them nil), and skip every RTL/`layoutDirection` line in the UI specs. Decide this first — it changes the content-authoring volume 3×.

### 4.2 The streak engine (VERBATIM — pure function)

Streaks are computed by a **pure transition function** over `yyyy-MM-dd` day-key strings. This is timezone-robust (it compares calendar-day strings, never timestamps). Daily Challenge's version:

```swift
static func nextStreak(_ s: DailyChallengeStreak, todayKey: String, yesterdayKey: String) -> DailyChallengeStreak {
    var result = s
    if s.lastCompletedDayKey == todayKey {
        return result                 // already counted today — no-op
    } else if s.lastCompletedDayKey == yesterdayKey {
        result.currentStreak += 1     // consecutive day
    } else {
        result.currentStreak = 1      // first ever, or chain broken
    }
    result.longestStreak = max(result.longestStreak, result.currentStreak)
    result.lastCompletedDayKey = todayKey
    return result
}
```

(The crossword's `DailyCrosswordStreak.next(...)` is the same logic in two-line form.) Rules: continuing yesterday → +1; any gap of 2+ days → reset to 1; `longestStreak` is preserved across resets; same-day re-call is a no-op.

### 4.3 Day-key helper (VERBATIM)

```swift
static func dayKey(for date: Date = Date(), calendar: Calendar = .current) -> String {
    let c = calendar.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04d-%02d-%02d", c.year ?? 0, c.month ?? 0, c.day ?? 0)
}
```

### 4.4 The Provider "today's item" pattern (VERBATIM)

Each feature has a `Provider` singleton that loads its bundled JSON once and resolves **today's** item deterministically: `index = dayOfYear % all.count`, cached per calendar date in UserDefaults so it's stable within a day and the same for every user. On app-foreground, `refreshIfDayChanged()` re-resolves across the date boundary. See `src/DailyChallengeProvider.swift` / `src/DailyCrosswordProvider.swift` — copy verbatim.

### 4.5 Premium gate (one-liner — adapt the hook)

Thaqalayn exposes `func canAccessDailyChallenge() -> Bool { isPremium }` and `canAccessDailyCrossword()` on its `PremiumManager`. **Map these to AlBayan's premium manager.** Either add the two methods to AlBayan's manager, or in the cards call AlBayan's existing `isPremium` directly. The card logic only ever asks one boolean question: *is this user premium?*

### 4.6 The Today-card 3-state pattern (UI — rebuild)

Each feature's card is a button with exactly three states:

```
if !premium            -> .locked   // show a "Premium" capsule + lock; tap => present paywall
else if completedToday -> .done     // checkmark + current streak; NOT tappable
else                   -> .pending  // inviting CTA; tap => present the play sheet
```

### 4.7 Persistence: local-only (VERBATIM) — and an explicit non-goal

All state is `UserDefaults` + `Codable` JSON. **There is no cloud sync, and you must not add it.** Thaqalayn's `docs/BOOKMARK_SYNC_ARCHITECTURE.md` (offline-first Supabase sync) is used by other features but **deliberately does NOT apply here** — these are device-local daily habits. Do not introduce Supabase, accounts, or sync for these features.

UserDefaults keys (keep identical so behavior matches; namespace is fine to keep or rename consistently):

| Feature | Keys |
|---|---|
| Daily Challenge | `dailyChallengeStreak`, `dailyChallengeLastCompletion`, provider cache `ThaqalaynDailyChallengeCache` |
| Daily Crossword | `dcw_streak`, `dcw_lastCompletion`, `dcw_completedDayKey`, provider cache `ThaqalaynDailyCrosswordCache` |

> If you prefer, rename the `Thaqalayn…` cache keys to `AlBayan…` — just keep each feature's set internally consistent.

### 4.8 No badges, no points (simplify)

Thaqalayn awards **streak only** — no reward points, no badges. (It carries retired `dailyChallenge*`/`crossword*` badge enum cases purely for decode-safety of old saved data, then filters them out everywhere.) **You are starting clean: omit all badge/points plumbing entirely.** Do not port the retired-badge enum cases or the filter — AlBayan has no legacy data to stay compatible with.

---

## 5. Theme-token mapping table (UI layer)

The Thaqalayn views are built on its "Midnight Emerald" theme primitives. When you rebuild the UI, map each to AlBayan's equivalent. Where AlBayan has no equivalent, the **Fallback** column is a minimal self-contained implementation you can drop in.

| Thaqalayn token | What it is | Map to in AlBayan / Fallback |
|---|---|---|
| `ThemeManager.shared.isMidnightEmerald` | Bool: is the dark serif theme active | Your theme flag, or just `true`/remove the branch and use one styling path |
| `…primaryText` / `secondaryText` / `tertiaryText` | Foreground text colors (3 weights) | Your text color tokens |
| `…accentColor` / `accentBright` / `accentChip` | Gold accent family | Your accent color family |
| `…accentGradient` | Gold gradient (CTAs, solved seal) | Your accent gradient, or a `LinearGradient` of your accent |
| `…strokeColor` | 1px hairline border | Your separator/border color |
| `…glassSurface` | Card fill (frosted) | Your card/surface background |
| `…onAccentText` | Text color over accent fills | Your on-accent (usually near-black/white) |
| `…primaryBackground` / `EmeraldBackground()` / `AdaptiveModernBackground()` | Full-screen backgrounds | Your screen background view |
| `EmCard(glow:cornerRadius:) { … }` | Rounded card container w/ surface + stroke | Your card container, or a `RoundedRectangle` w/ surface fill + stroke |
| `EmGoldCTA(title:sfSymbol:)` | Primary gold button | Your primary button style |
| `EmIconChip(sfSymbol:size:)` | Accent-gradient circle w/ SF Symbol | A `Circle().fill(accentGradient)` + `Image(systemName:)` |
| `EmType.serif(size, weight)` | Serif display font | Your title font (`.system(.., design: .serif)` is a fine fallback) |
| `EmType.arabic(size)` | Arabic-diacritic-aware font | Your Arabic font; fallback `.system(size:)` (the Thaqalayn handoff history notes Arabic-font names differ between the apps — use AlBayan's) |
| `emEyebrow(language, size, tracking)` | Uppercase tracked label | Your small-caps/eyebrow style |
| `EmPressStyle` / `EmPressStyle.gentle` | Press-squish + haptic `ButtonStyle` | Your press style; fallback: a `ButtonStyle` scaling to `0.97` on press + `UIImpactFeedbackGenerator(.light)` |
| `Haptics.press()` | Light impact haptic | `UIImpactFeedbackGenerator(style: .light).impactOccurred()` |
| `CommentaryLanguageManager.shared.selectedLanguage` / `.isRTL` | Current language + RTL flag | Your language manager (or drop, if English-only — see §4.1) |
| `ReadingSettingsManager.shared.scale` | Reading text-size multiplier | Your reading-size control — **Daily Challenge only** (see §6) |

---

## 6. House rules (from Thaqalayn `CLAUDE.md` — apply in AlBayan too)

1. **No fallback logic** unless explicitly requested. When something can't load, fail clearly (the providers `fatalError` if their bundled JSON is missing — keep that; a missing content file is a build/bundling bug, not a runtime condition to paper over).
2. **Reading text-size scaling.** AlBayan has (per Thaqalayn) a global reading text-size control. Reading *content* must scale with it; chrome must not.
   - **Daily Challenge:** the prompt, options, explanation, flashcard answer, and `arabicText` **scale** (`size * scale`, and scale `lineSpacing` too).
   - **Daily Crossword:** the grid letters, numbers, clue chrome, and keyboard are **fixed-size** — do **not** wire the reading-size control. (The crossword is chrome, not reading content. This is a deliberate decision in the source.)
3. **Local-only.** See §4.7 — no cloud sync.

---

## 7. Shia → Sunni content adaptation ruleset (master)

This is the reusable ruleset (consistent with Thaqalayn's existing `docs/specs/dhul-hijjah-journey-export.md`). Per-feature specifics are in each feature doc.

| Item | Shia (source) | Sunni replacement |
|---|---|---|
| **Honorifics** | `(a)` / `عليه السلام` after the Imams; Imam-specific reverence | Remove the Imams' `(a)`. **Keep** `ﷺ` for the Prophet and `(as)` / "(peace be upon him)" for **prophets** (Adam, Musa, Isa…). Companions & the Prophet's family → "(may Allah be pleased with him/her)" / `(ra)`. |
| **Devotional vocatives** | "Yā Ḥusayn", "Yā Zahrā", direct calls to the Imams | Remove entirely. |
| **Leadership / Imamate** | "Imam" as a *divinely-appointed, infallible* office; the **Twelve Imams** enumeration (1st = Ali, 6th = al-Sadiq, etc.) | Drop the Twelve-Imams framing and "divinely-appointed leader" definition. Use "Imam" only in the generic Sunni sense (prayer leader / great scholar) if at all. |
| **Hadith / du'a sources** | al-Kafi, Mafatih al-Jinan, al-Sahifa al-Sajjadiyya, Nahj al-Balagha | Sunni canon: **Sahih al-Bukhari, Sahih Muslim, the four Sunan (Abi Dawud, Tirmidhi, al-Nasa'i, Ibn Majah), Muwatta Malik, Riyad as-Salihin, Hisn al-Muslim, al-Adhkar (al-Nawawi)**. Re-attribute every source string. Remove Ziyarat Ashura, Hadith al-Kisa (Shia narration), maqtal literature. |
| **Tafsir sources** | al-Mizan (Tabatabai), Shia tafsir | **Ibn Kathir, al-Tabari, al-Qurtubi, al-Sa'di** (not al-Mizan/Tabatabai). |
| **Distinctly Shia events/practices** | Ghadeer Khumm (as appointment of Ali), Ashura/Karbala as devotional mourning, Du'a Kumayl (Thursday nights), Khums as a distinctive pillar | Remove or recast historically/neutrally — **no mourning/azadari framing**. Prefer broadly-shared topics: Badr, Uhud, Hijrah, the Rightly-Guided Caliphs, the Mothers of the Believers, the major Companions. Ashura may appear as a *fasting* day; Karbala only as neutral history. |
| **Ahl al-Bayt framing** | "Ahl al-Bayt" as the theological cornerstone / "Shia = followers of Ahl al-Bayt" | The Prophet's family is honored in Sunni Islam too — keep respectful mentions, drop the sect-defining gloss and the Imamate doctrine attached to it. |
| **Sect identity terms** | `SHIA`, "Shia jurisprudence", etc. | Remove explicit sect-identity content; keep universal Islamic vocabulary. |
| **Re-annotated verses** | Verses with distinctly Shia readings (e.g. 108:1, 33:33, 3:61, 42:23) | Use the mainstream Sunni reading; don't carry over Shia-specific glosses. |
| **Trilingual schema** | `{en, ur, ar}` | Keep the shape. If English-only (see §4.1), drop `ur`/`ar`. |

**Golden rule:** the *engine* never changes; only **strings the user reads** (clues, prompts, options, explanations, sources) change. When in doubt, choose content **shared across both traditions** (Qur'an, the Prophet ﷺ, prayer, fasting, hajj, prophets, broadly-accepted history) so the feature reads as mainstream Sunni.

> **Shipping gate:** all authored Sunni content (challenge pool + crossword bank/clues) should get a **qualified Sunni scholar review before release** — automated adaptation catches structure, not every doctrinal nuance.

> **Also check hardcoded Swift strings**, not just JSON: the `*Strings.swift` chrome files (and any titles/labels you write) must read as Sunni-neutral. These two features have no notification bodies (unlike some ported features), so JSON + chrome strings are the whole surface.

---

## 8. Master port checklist

Work top-to-bottom. Detailed steps live in the two feature docs. **Verification is build + behavior + the crossword validator — there is no XCTest suite** (the source ships iOS work without unit tests; logic is checked via a removable `#if DEBUG` self-check and `xcodebuild build`).

- [ ] **0. Confirm assumptions** (§4.1 multilingual; §5 you have theme tokens to map). Resolve English-only vs trilingual now.
- [ ] **1. Shared model file** — copy `src/DailyChallengeModels.swift` (it defines `LocalizedText`, reused by the crossword). Ensure `CommentaryLanguage` exists or adapt per §4.1.
- [ ] **2. Daily Challenge** — follow `01-daily-challenge.md` (engine → content → UI → onboarding → wire into Today → gate → verify).
- [ ] **3. Daily Crossword** — follow `02-daily-crossword.md` (engine → Sunni word bank → run pipeline → UI → onboarding → wire into Today → gate → verify).
- [ ] **4. Today-tab wiring** — insert `DailyChallengeCard()` then `DailyCrosswordCard()` into AlBayan's home; on `scenePhase == .active` call `DailyChallengeProvider.shared.refreshIfDayChanged()`, `DailyCrosswordProvider.shared.refreshIfDayChanged()`, and `DailyCrosswordManager.shared.refreshForToday()`.
- [ ] **5. Premium hook** — §4.5.
- [ ] **6. Onboarding** — add the two demo slides into AlBayan's onboarding carousel (specs in each feature doc).
- [ ] **7. Verify** — `xcodebuild build` clean; both cards show locked→pending→done; streaks increment across a simulated date change; crossword `validate.py` passes on the generated file; RTL correct (if multilingual).
- [ ] **8. Content review** — a qualified Sunni scholar reviews the challenge pool + crossword bank/clues before release (§7 shipping gate).
- [ ] **9. Commit** at each feature boundary.

---

## 9. File manifest (`src/`)

| File | Layer | Action |
|---|---|---|
| `src/DailyChallengeModels.swift` | Engine | Copy verbatim (defines `LocalizedText` too) |
| `src/DailyChallengeManager.swift` | Engine | Copy verbatim |
| `src/DailyChallengeProvider.swift` | Engine | Copy verbatim |
| `src/DailyChallengeStrings.swift` | UI chrome strings | Copy; review wording for your tone (sect-neutral already) |
| `src/DailyCrosswordModels.swift` | Engine | Copy verbatim (reuses `LocalizedText`) |
| `src/DailyCrosswordManager.swift` | Engine | Copy verbatim |
| `src/DailyCrosswordProvider.swift` | Engine | Copy verbatim |
| `src/DailyCrosswordStrings.swift` | UI chrome strings | Copy; review wording |
| `src/crossword/generate.py` | Engine (pipeline) | Copy; **change the output path** to AlBayan's `Data/` dir |
| `src/crossword/validate.py` | Engine (pipeline) | Copy; **change the path** to match |
| `src/crossword/bank.json` | Content (Shia **reference**) | **Replace content** — keep the format, swap the terms per `02-daily-crossword.md` |

> Content files **not** included by design (you author them): `daily_challenges.json`, `daily_crosswords.json` (generated). Thaqalayn's own play/card/onboarding view files are **not** included — they're theme-coupled; rebuild from the UX specs.
