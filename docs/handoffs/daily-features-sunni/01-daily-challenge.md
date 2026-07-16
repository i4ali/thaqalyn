# Feature 1 — Daily Challenge (Sunni port)

> Read `README.md` first (3-layer principle, theme mapping, adaptation ruleset, shared foundations). This doc only adds Daily-Challenge specifics.

**What it is:** one bite-sized question per day, in one of 4 formats. Tap the Today card → answer in a sheet → see the explanation → streak updates. Premium-gated, local-only, streak-only.

**User flow:**
1. Today card shows **pending** (premium, not done today) → tap.
2. Sheet presents today's challenge (deterministic — same for everyone that calendar day).
3. User answers (or reveals, for flashcards). Correct/incorrect feedback + explanation appears.
4. On completion the streak advances; the card flips to **done** with the streak count; re-opening is a no-op for scoring.

---

## Files in AlBayan

| File | Layer | Action |
|---|---|---|
| `Models/DailyChallengeModels.swift` | Engine | **Copy verbatim** from `src/` (also defines `LocalizedText`, used by the crossword too) |
| `Services/DailyChallengeManager.swift` | Engine | **Copy verbatim** from `src/` |
| `Services/DailyChallengeProvider.swift` | Engine | **Copy verbatim** from `src/` |
| `Views/DailyChallengeStrings.swift` | UI chrome strings | Copy from `src/`; review tone (already sect-neutral) |
| `Data/daily_challenges.json` | Content | **Author** (Sunni) — schema + rules below. Must be added to the app bundle/target. |
| `Views/DailyChallengeView.swift` | UI | **Rebuild** in AlBayan's theme from the UX spec below |
| `Views/DailyChallengeCard.swift` | UI | **Rebuild** (3-state card, README §4.6) |
| `Views/Onboarding/DailyChallengeScreen.swift` | UI | **Rebuild** the onboarding slide (optional but matches source) |

---

## Engine (copy verbatim)

The full files are in `src/`. The data models (small, central) are reproduced here so this doc stands alone.

```swift
enum DailyChallengeFormat: String, Codable {
    case multipleChoice
    case trueFalse
    case flashcard
    case fillInBlank
}

// LocalizedText — see README §4.1 (reused by the crossword; define once)

struct DailyChallenge: Codable, Identifiable {
    let id: String                 // stable, e.g. "dc_001"
    let format: DailyChallengeFormat
    let topic: String              // free-string tag; Sunni set below
    let prompt: LocalizedText      // question / statement / flashcard front / sentence-with-blank
    let options: [LocalizedText]?  // multipleChoice + fillInBlank only
    let correctIndex: Int?         // MC/fill-in → option index; trueFalse → 1=true, 0=false; flashcard → nil
    let answer: LocalizedText?     // flashcard back
    let explanation: LocalizedText? // shown after answering
    let arabicText: String?        // optional verse/du'a, shown verbatim, NEVER translated
    let source: String?            // optional citation, e.g. "Qur'an 2:255"

    var trueFalseAnswer: Bool? {   // convention: 1 = true, 0 = false
        guard format == .trueFalse, let i = correctIndex else { return nil }
        return i == 1
    }
}

struct DailyChallengeCompletion: Codable {
    let dayKey: String             // "yyyy-MM-dd"
    let challengeId: String
    let format: DailyChallengeFormat
    let wasCorrect: Bool
    let completedAt: Date
}

struct DailyChallengeStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletedDayKey: String? = nil
}
```

- **Manager** (`src/DailyChallengeManager.swift`): `@MainActor` singleton, `@Published` `streak` + `lastCompletion`, `isCompletedToday`, `complete(challenge:wasCorrect:)`, `completeFlashcard(challenge:gotIt:)`, the pure `nextStreak(...)` (README §4.2), UserDefaults load/save. It ships a `#if DEBUG _selfCheckStreak()` — **this is your logic verification** (call it from a debug button; it asserts fresh→1, consecutive→2, gap→reset, same-day→no-op). Keep it for the build, strip before ship.
- **Provider** (`src/DailyChallengeProvider.swift`): loads `daily_challenges.json`, resolves today by `dayOfYear % count` cached per date, `refreshIfDayChanged()`. Copy verbatim.

> The manager/provider have **no Shia content and no theme code** — they compile as-is once `LocalizedText`/`CommentaryLanguage` resolve (README §4.1).

---

## Content — schema & Sunni authoring spec

You author `daily_challenges.json`: a **JSON array** of `DailyChallenge` objects. Thaqalayn ships **72** entries; author a comparable pool (≥ 60 recommended so days don't repeat for two months). `id`s are stable strings like `dc_001`.

### Field rules by format

| Format | `prompt` | `options` | `correctIndex` | `answer` | `arabicText` |
|---|---|---|---|---|---|
| `multipleChoice` | the question | 3–4 choices | index of correct option | nil | optional |
| `trueFalse` | the statement | nil | **1 = true, 0 = false** | nil | optional |
| `flashcard` | the front (question) | nil | nil | the back (shown on reveal) | optional |
| `fillInBlank` | sentence with a `____` blank | 3 choices for the blank | index of correct option | nil | usually the full āyah/phrase |

`explanation` is shown after answering for every format. `source` is an optional citation string. **`arabicText` is rendered verbatim and never translated** — use it for a Qur'an āyah or a du'a.

### Schema illustrations (structure only — sect-neutral; author your full Sunni set)

These show the shape using universal content. **They are examples of the format, not your content set.**

```json
[
  {
    "id": "dc_001", "format": "multipleChoice", "topic": "quran",
    "prompt": { "en": "How many chapters (surahs) are in the Qur'an?",
                "ur": "قرآن میں کتنی سورتیں ہیں؟",
                "ar": "كم عدد السور في القرآن الكريم؟" },
    "options": [ {"en":"100"}, {"en":"114"}, {"en":"120"}, {"en":"99"} ],
    "correctIndex": 1,
    "explanation": { "en": "The Qur'an has 114 surahs, beginning with al-Fatiha." },
    "arabicText": null, "source": null
  },
  {
    "id": "dc_002", "format": "trueFalse", "topic": "practice",
    "prompt": { "en": "There are five daily obligatory prayers." },
    "options": null, "correctIndex": 1, "answer": null,
    "explanation": { "en": "Fajr, Dhuhr, Asr, Maghrib, and Isha — five each day." },
    "arabicText": null, "source": null
  },
  {
    "id": "dc_003", "format": "fillInBlank", "topic": "quran",
    "prompt": { "en": "\"Iyyaka naʿbudu wa iyyaka ____\"" },
    "options": [ {"en":"nastaʿin (we seek help)"}, {"en":"nahmadu (we praise)"}, {"en":"nadhkuru (we remember)"} ],
    "correctIndex": 0,
    "explanation": { "en": "Al-Fatiha 1:5 — 'You alone we worship, and You alone we ask for help.'" },
    "arabicText": "إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ", "source": "Qur'an 1:5"
  },
  {
    "id": "dc_004", "format": "flashcard", "topic": "quran",
    "prompt": { "en": "What does 'Bismillahir-Rahmanir-Rahim' mean?" },
    "options": null, "correctIndex": null,
    "answer": { "en": "In the name of God, the All-Merciful, the Ever-Merciful." },
    "explanation": { "en": "It opens almost every surah and is recited before acts of worship." },
    "arabicText": "بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ", "source": null
  }
]
```

(`ur`/`ar` shown on the first entry; populate all three for every string if AlBayan is trilingual — otherwise `en` only, see README §4.1.)

### Sunni topic set

`topic` is a free string used only for your own curation/balance (not shown to users, not used by logic). Suggested Sunni set: `"quran"`, `"dua"`, `"seerah"` (life of the Prophet ﷺ), `"companions"` (Sahaba / the Rightly-Guided Caliphs), `"practice"` (salah, fasting, hajj, zakah), `"history"` (Badr, Uhud, Hijrah). **Drop Thaqalayn's `"ahlulbayt"` and `"event"` (Ghadeer/Ashura) topics** — see adaptation notes.

### Authoring checklist
- [ ] ≥ 60 entries, balanced across the Sunni topic set and across the 4 formats.
- [ ] Every `prompt`/`options`/`answer`/`explanation` populated for each supported language.
- [ ] `correctIndex` valid (within `options` for MC/fill-in; 1/0 for true-false; nil for flashcard).
- [ ] Sources use Sunni references (README §7).
- [ ] `arabicText` correct and pointed (āyah/du'a), never a translation.
- [ ] Apply the adaptation ruleset — no Imamate/Twelve-Imams/Ghadeer/Kumayl/Khums content.

---

## Daily-Challenge content adaptation notes (source → Sunni)

Thaqalayn's pool is **heavily Shia**. Replace, don't translate. Concrete source items and their Sunni handling:

| Source challenge (Shia) | Action |
|---|---|
| "Imam Ali (a) was born inside the Kaʿba" (true/false, `ahlulbayt`) | Drop. Replace with a shared-tradition fact (e.g., a Badr/Uhud true-false, or a Qur'an fact). |
| "Who is the first Imam in **Shia Islam**?" → "first of the **Twelve Imams**" | Drop the Imamate framing entirely. |
| Ghadeer Khumm / Eid al-Ghadeer (`event`) | Remove. Use shared seerah/history (Hijrah, the Farewell Sermon's universal themes, Badr). |
| Ashura / Karbala as commemoration | Remove devotional framing. If used at all, treat as neutral history. |
| Du'a Kumayl, "recited Thursday nights" (Imam Ali → Kumayl) | Remove. Use du'as from Hisn al-Muslim / Bukhari-Muslim (e.g., Sayyid al-Istighfār). |
| Khums "distinctive obligation in Shia jurisprudence" | Remove or recast zakah in the Sunni framework. |
| Mafatih al-Jinan citations | Re-source to Sunni collections (README §7). |
| `(a)` / `عليه السلام` honorifics on Imams | Remove; Prophet ﷺ; Companions `(ra)`. |

Aim for content that a mainstream Sunni reader recognizes immediately: Qur'an, the Prophet ﷺ and his Companions, the five pillars, the well-known battles and the Hijrah.

---

## UX spec — play screen (`DailyChallengeView`, rebuild in AlBayan's theme)

A full-screen sheet. Use AlBayan theme tokens per README §5. **Reading content scales with the reading text-size control (README §6); chrome does not.**

**Layout (top → bottom):**
1. **Header** — small eyebrow ("DAILY CHALLENGE" / localized) + a close control. (chrome, fixed)
2. **Prompt** — `prompt.text(for: language)`, prominent. *(scales)* If `arabicText` present, show it verbatim in the Arabic font below/above the prompt. *(scales)*
3. **Answer area — by format:**
   - **multipleChoice / fillInBlank:** a vertical list of option buttons (`options[i].text(for:)`). On tap: lock selection, mark the chosen one and the `correctIndex` one (correct = accent/green, wrong-choice = red), then reveal the explanation. *(option text scales)*
   - **trueFalse:** two buttons, True / False. Correct = `correctIndex == 1`. Same reveal behavior.
   - **flashcard:** show the front (prompt); a "Reveal" affordance flips to `answer`. Then two buttons — "Got it" / "Review again" — **both mark the day done** (self-graded; `completeFlashcard(challenge:gotIt:)`). *(answer scales)*
4. **Explanation** — after answering, `explanation.text(for:)`. *(scales)*
5. **Primary CTA** — e.g. "Done" (your gold button) dismisses the sheet.

**Behavior:**
- On a scoring answer call `manager.complete(challenge:wasCorrect:)`; flashcards call `completeFlashcard(challenge:gotIt:)`. Guarded so a day counts once.
- Respect RTL: set `layoutDirection` to `.rightToLeft` for Urdu/Arabic on the text/stacks (skip if English-only).
- No timer, no points — just answer → explanation → done.

---

## UX spec — Today card (`DailyChallengeCard`, rebuild)

Three states (README §4.6), as a card button:
- **Locked** (free user): a "Premium" capsule + lock glyph; subtitle invites upgrade; tap → present AlBayan's paywall.
- **Pending** (premium, not done today): inviting title ("Daily Challenge"), a short prompt/teaser, a CTA chevron; tap → present `DailyChallengeView`.
- **Done** (premium, done today): checkmark + "Done today" + current streak (e.g. "🔥 5"); not tappable.

Read state from `PremiumManager` (README §4.5) + `DailyChallengeManager.shared.isCompletedToday` + `.streak.currentStreak`. Use `Haptics.press()`-equivalent on tap.

---

## UX spec — onboarding slide (`DailyChallengeScreen`, optional)

A single slide in AlBayan's onboarding carousel: a looping mini-demo that auto-cycles through the formats (e.g. an MC question resolving to its correct answer, then a flashcard flip), with a one-line value prop ("A new challenge every day — keep your streak") and the streak flame. Pure presentation; wire it as one page in your existing onboarding flow. Skip if AlBayan's onboarding isn't a match.

---

## Acceptance criteria (verify before calling it done)

- [ ] `xcodebuild build` is clean (scheme = AlBayan's).
- [ ] Card cycles **locked → pending → done** correctly with premium toggled and after completing.
- [ ] Answering advances the streak; re-opening the same day does not double-count (`#if DEBUG _selfCheckStreak()` passes; manual: complete today, force-quit, reopen — still "done", streak unchanged).
- [ ] Simulating a date roll (next calendar day) shows a new challenge and the card returns to **pending**; completing on the consecutive day yields streak +1; skipping a day resets to 1.
- [ ] All 4 formats render and reveal correctly; `arabicText` shows verbatim; explanation appears after answering.
- [ ] Reading text-size control scales prompt/options/answer/explanation/arabicText (and only those).
- [ ] RTL correct for Urdu/Arabic (if trilingual).
- [ ] Content contains **no** Imamate/Twelve-Imams/Ghadeer/Kumayl/Khums material; sources are Sunni.
