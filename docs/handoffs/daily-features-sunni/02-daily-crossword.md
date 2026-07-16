# Feature 2 — Daily Crossword (Sunni port)

> Read `README.md` first (3-layer principle, theme mapping, adaptation ruleset, shared foundations). This doc adds Daily-Crossword specifics. It mirrors Daily Challenge almost exactly — same streak engine, same provider pattern, same 3-state card — plus a **content pipeline**.

**What it is:** one small criss-cross mini-crossword per day (≈6 interlocking words, 5–7 cell grid). Tap the Today card → solve on a grid with an on-screen keyboard → solved overlay → streak updates. Premium-gated, local-only, streak-only.

**User flow:**
1. Today card **pending** → tap.
2. Sheet shows today's puzzle (deterministic — same for everyone that calendar day): a grid + clue bar + keyboard.
3. User fills cells; optional hint reveals a letter. When every cell is correct → solved overlay (time, streak).
4. Streak advances; card flips to **done**.

---

## Files in AlBayan

| File | Layer | Action |
|---|---|---|
| `Models/DailyCrosswordModels.swift` | Engine | **Copy verbatim** from `src/` (reuses `LocalizedText` from the challenge models) |
| `Services/DailyCrosswordManager.swift` | Engine | **Copy verbatim** from `src/` |
| `Services/DailyCrosswordProvider.swift` | Engine | **Copy verbatim** from `src/` |
| `Views/DailyCrosswordStrings.swift` | UI chrome strings | Copy from `src/`; review tone |
| `Data/daily_crosswords.json` | Content (generated) | **Generate** via the pipeline below; add to the app bundle/target |
| `scripts/crossword/bank.json` | Content (Shia ref) | **Replace** terms (keep format) — see word-bank spec |
| `scripts/crossword/generate.py` | Engine (pipeline) | Copy from `src/crossword/`; **change output path** |
| `scripts/crossword/validate.py` | Engine (pipeline) | Copy from `src/crossword/`; **change path** |
| `Views/DailyCrosswordView.swift` | UI | **Rebuild** (grid + keyboard + solved overlay) from the UX spec |
| `Views/DailyCrosswordCard.swift` | UI | **Rebuild** (3-state card, README §4.6) |
| `Views/Onboarding/DailyCrosswordScreen.swift` | UI | **Rebuild** the onboarding slide (optional) |

---

## Engine (copy verbatim)

Models reproduced for standalone reading; full files in `src/`.

```swift
struct CrosswordEntry: Codable, Identifiable, Hashable {
    let num: Int
    let dir: String            // "A" (across) or "D" (down)
    let answer: String         // A–Z solution, uppercased
    let clue: LocalizedText    // {en, ur, ar}
    let cells: [[Int]]         // [[row,col], …], length == answer.count
    var id: String { "\(num)\(dir)" }
    var isAcross: Bool { dir == "A" }
    func cell(at i: Int) -> CellPos { CellPos(r: cells[i][0], c: cells[i][1]) }
}

struct CellPos: Hashable, Codable { let r: Int; let c: Int }

struct DailyCrossword: Codable, Identifiable {
    let id: String
    let rows: Int
    let cols: Int
    let entries: [CrosswordEntry]
    let cellNumbers: [String: Int]   // "r,c" -> entry number

    var solution: [CellPos: Character] {   // rebuilt from entries; not persisted
        var m: [CellPos: Character] = [:]
        for e in entries {
            let a = Array(e.answer)
            for (i, rc) in e.cells.enumerated() { m[CellPos(r: rc[0], c: rc[1])] = a[i] }
        }
        return m
    }
    func number(at p: CellPos) -> Int? { cellNumbers["\(p.r),\(p.c)"] }
}

struct DailyCrosswordCompletion: Codable {
    let dayKey: String          // "yyyy-MM-dd"
    let puzzleId: String
    let seconds: Int            // solve time
    let usedHint: Bool
    let completedAt: Date
}

struct DailyCrosswordStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletedDayKey: String? = nil
    static func next(_ s: DailyCrosswordStreak, todayKey: String, yesterdayKey: String) -> DailyCrosswordStreak {
        var n = s
        if s.lastCompletedDayKey == todayKey { return n }
        n.currentStreak = (s.lastCompletedDayKey == yesterdayKey) ? s.currentStreak + 1 : 1
        n.longestStreak = max(n.longestStreak, n.currentStreak)
        n.lastCompletedDayKey = todayKey
        return n
    }
}
```

- **Manager** (`src/DailyCrosswordManager.swift`): `@MainActor` singleton; `@Published` `streak`, `lastCompletion`, `isCompletedToday`. Note the crossword tracks `isCompletedToday` as a **stored** published bool plus a `dcw_completedDayKey` UserDefaults string, refreshed by `refreshForToday()` on foreground (the challenge derives it from `lastCompletion`). `complete(seconds:usedHint:)` advances the streak. Copy verbatim.
- **Provider** (`src/DailyCrosswordProvider.swift`): identical to the challenge provider — loads `daily_crosswords.json`, `dayOfYear % count` cached per date, `refreshIfDayChanged()`. Copy verbatim.

**Grid model note:** the grid is **sparse** — only cells that belong to some entry exist; blocked cells are simply absent from every `cells` array. Letters are **A–Z transliteration** (e.g. `SALAH`, `IMAN`), so the grid + keyboard are always Latin/LTR even in Urdu/Arabic mode; **only the clues localize**.

---

## Content pipeline (bank → generate → validate)

```
scripts/crossword/bank.json  --(generate.py)-->  Data/daily_crosswords.json  --(validate.py)--> ✓
        ^ you author Sunni terms here          ^ generated; bundled into the app
```

The whole pipeline is **pure Python stdlib, deterministic** (fixed seed). Run it from the AlBayan repo:

```bash
python3 scripts/crossword/generate.py     # writes Data/daily_crosswords.json
python3 scripts/crossword/validate.py     # asserts the output is well-formed; exits non-zero on failure
```

### Required script adaptation
Both scripts hardcode the source app's output path:
```python
OUT = os.path.normpath(os.path.join(HERE, "..", "..", "Thaqalayn", "Data", "daily_crosswords.json"))
```
**Change `"Thaqalayn"` to AlBayan's app source-dir name** in *both* `generate.py` and `validate.py` so the file lands in AlBayan's bundle `Data/` folder.

### `generate.py` — what it does
- Loads `bank.json`, keeps answers that are **A–Z, length 3–6** as the word pool.
- Assembles **criss-cross** minis: place a first word, then repeatedly add words that **cross** an existing letter, enforcing a clean layout — every added word must (a) cross ≥1 existing letter with a matching letter, (b) not run parallel-adjacent to another word, (c) have free ends (no letter immediately before/after). Bounded to `max_dim`.
- Generates `count` **distinct** puzzles (dedups by placement signature), numbers entries left-to-right/top-to-bottom, emits the app schema.
- Entry point: `generate(count, target=6, max_dim=7, seed=11, max_attempts=80000)` → called with `count=365`.

| Param | Default | Meaning |
|---|---|---|
| `count` | 365 | puzzles to emit (one per day-of-year). Fewer is fine; `dayOfYear % count` still works. |
| `target` | 6 | words per puzzle (it stops once a puzzle reaches this) |
| `max_dim` | 7 | max grid width/height (keeps it phone-friendly, ~5–7) |
| `seed` | 11 | deterministic RNG seed — same bank + seed ⇒ identical output. Change it to reshuffle. |
| `max_attempts` | 80000 | backtracking budget across all puzzles |

### `validate.py` — the gate
Asserts, for every puzzle: unique id; every answer is in the bank and matches `[A-Z]{3,6}`; `dir ∈ {A,D}`; `cells` length == answer length; **trilingual clue present** (`en`, `ur`, `ar`); no duplicate slots; **crossing letters are consistent** (shared cells agree); ≥1 crossing; `cellNumbers` keys exactly equal the entry start cells. Prints `ALL <n> PUZZLES VALID` or fails non-zero.

> If AlBayan is **English-only**, the validator's trilingual assertion (`for k in ("en","ur","ar")`) will fail. Either author `ur`/`ar` anyway, or relax that one check to require only `en`. Decide per README §4.1.

### Why criss-cross (not a dense 5×5)
A fully-packed square grid (every cell filled) needs every row *and* column to be a valid word — that demands thousands of 5-letter entries. A curated Islamic-terms bank (~100 words) can't sustain that without padding in junk vocabulary. The criss-cross approach keeps **every answer a real, meaningful term**, fits a phone screen, and guarantees solvability. Keep it.

---

## Word-bank authoring spec (`bank.json`)

`src/crossword/bank.json` is the **Shia reference** — keep its **format**, replace its **terms**.

### Entry format
```json
{
  "_note": "Transliterated term bank. answer = A–Z only; trilingual clues required.",
  "entries": [
    { "answer": "DUA",  "theme": "practice", "clue_en": "Personal supplication to God",
      "clue_ur": "اللہ سے ذاتی دعا و مناجات", "clue_ar": "المناجاةُ الشخصيَّة ورفعُ الحاجة إلى الله" },
    { "answer": "ADAM", "theme": "prophets", "clue_en": "The first human being and prophet",
      "clue_ur": "پہلے انسان اور نبی", "clue_ar": "أوَّلُ البشر والأنبياء" }
  ]
}
```

### Rules
- `answer`: **A–Z uppercase, 3–6 letters** (the generator ignores anything outside 3–6; the validator rejects non-`[A-Z]`). Use standard transliterations.
- `clue_en`/`clue_ur`/`clue_ar`: all required (English-only project → see the validator note above).
- `theme`: free tag for your own balance; not used by the algorithm.
- **Volume:** aim for **~90–120 terms** with a good mix of lengths (lots of 3–4 letter words to act as connectors). The Shia bank has 96; that produced 365 distinct puzzles. Too few short words ⇒ the generator can't reach `count` distinct puzzles.

### Sunni term set
**Keep** (already sect-neutral, ~86 of the 96): Qur'anic surah names/letters (SURA, AYAH, QAF, SAD, NUN, NOOR, TUR), prophets (ADAM, NUH, HUD, MUSA, ISA), ritual/practice (DUA, FAJR, ZUHR, ASR, ISHA, HAJJ, SAWM, EID, WUDU, RAKA, IMAN), concepts (DIN, NUR, RUH, ILM, HAQ, SABR, NABI, RABB, AMAL), history (BADR, UHUD), places (MINA, SAFA, AQSA).

**Replace** the Shia-specific entries (per README §7):
| Remove / recast | Why | Suggested Sunni additions (all A–Z, 3–6 letters) |
|---|---|---|
| ALI, HASAN, ZAHRA, SADIQ, BAQIR, KAZIM, JAWAD, MAHDI | Twelve-Imams enumeration | Companions & Rightly-Guided Caliphs: ABU (3), UMAR (4), UTHMAN (6), BILAL (5), HAMZA (5), KHALID (6), AISHA (5); prophets: LUT (3), SALIH (5), IDRIS (5) |
| IMAM (defined as "divinely-appointed leader") | Imamate doctrine | If kept, reclue neutrally: "One who leads the congregational prayer" |
| SHIA ("followers of the Ahl al-Bayt") | sect identity | Drop; add neutral terms: TAQWA (5), SUNNAH (6), UMMAH (5) |
| BAYT (clued "as in Ahl al-___") | leads to Imamate framing | Keep BAYT, neutral clue: "House; the Kaʿba is Bayt Allah" |
| KUFA ("seat of Imam Ali's rule") | Shia-centric clue | Recast: "Early garrison city in Iraq" — or drop |

Keep plenty of short (3–4 letter) connectors so the generator can interlock words and reach `count` distinct puzzles. Re-source any clue citations to Sunni references.

---

## Puzzle JSON schema (app format — produced by `generate.py`)

A `daily_crosswords.json` is a **JSON array** of puzzle objects. Sparse grid; `cellNumbers` maps `"r,c"` → entry number for the cells where an entry starts.

Minimal **consistent** illustration (neutral content — `DUA` across crossing `ADAM` down at the shared `A`):

```json
[
  {
    "id": "dcw_0001",
    "rows": 4,
    "cols": 3,
    "entries": [
      { "num": 1, "dir": "A", "answer": "DUA",
        "clue": { "en": "Personal supplication to God", "ur": "…", "ar": "…" },
        "cells": [[0,0],[0,1],[0,2]] },
      { "num": 2, "dir": "D", "answer": "ADAM",
        "clue": { "en": "The first human being and prophet", "ur": "…", "ar": "…" },
        "cells": [[0,2],[1,2],[2,2],[3,2]] }
    ],
    "cellNumbers": { "0,0": 1, "0,2": 2 }
  }
]
```

Field notes: `id` = `dcw_NNNN` (zero-padded). `cells` are `[row, col]` in answer order. The shared cell `(0,2)` holds `A` for both entries — that consistency is exactly what `validate.py` enforces. The Swift `solution` computed property rebuilds the per-cell letter map from `entries`.

**Selection:** `DailyCrosswordProvider` picks `index = dayOfYear % all.count`, cached per calendar date — same puzzle for everyone that day, stable within the day, advances at midnight (re-checked on foreground via `refreshIfDayChanged()`).

---

## UX spec — play screen (`DailyCrosswordView`, rebuild in AlBayan's theme)

Full-screen sheet. **All of this is fixed-size chrome — do NOT wire the reading text-size control** (README §6).

**Layout:**
1. **Header** (chrome) — title/eyebrow, a live **timer** (mm:ss), a **hint** button, close control.
2. **Grid** — render only cells present in some entry (sparse). Each cell: optional small **number** (top-left, from `cellNumbers`), the user's entered letter centered. Highlight the **selected cell** and the **active entry's** cells. Tap a cell to select; tap again to toggle across/down direction (when both exist).
3. **Clue bar** — the active entry's clue (`entry.clue.text(for: language)`) with prev/next affordance to move between entries. *(clue text localizes; RTL for ur/ar — but the grid stays LTR Latin)*
4. **On-screen keyboard** — A–Z (QWERTY). Tapping types into the selected cell and auto-advances along the active entry; backspace deletes/retreats. (Use this custom keyboard, not the system one — letters are Latin transliteration.)
5. **Hint** — reveals the correct letter for the selected cell; sets a `usedHint` flag passed to `complete(...)`.
6. **Solved overlay** — when every filled cell matches `solution`, show a celebratory seal, the solve time, and the new streak, with a **Done** CTA. On solve, call `DailyCrosswordManager.shared.complete(seconds:usedHint:)`.

**Behavior:** completion is guarded to once per day. No scoring beyond streak + time. Compare entered letters to `puzzle.solution` to detect "solved".

---

## UX spec — Today card (`DailyCrosswordCard`, rebuild)

Three states (README §4.6):
- **Locked** (free): "Premium" capsule + lock; tap → paywall.
- **Pending** (premium, not done): "Daily Crossword" + teaser (e.g. grid glyph); tap → present `DailyCrosswordView(puzzle: provider.today)`.
- **Done** (premium, done today): checkmark + "Solved today" + streak; not tappable.

State from `PremiumManager` (README §4.5) + `DailyCrosswordManager.shared.isCompletedToday` + `.streak.currentStreak`.

---

## UX spec — onboarding slide (`DailyCrosswordScreen`, optional)

One carousel slide: a looping demo of a tiny grid auto-filling to "solved" with a streak bump, plus a one-liner ("A new crossword every day"). Pure presentation; wire as one onboarding page. Skip if not a fit.

---

## Acceptance criteria (verify before calling it done)

- [ ] `python3 scripts/crossword/generate.py` writes `Data/daily_crosswords.json`; `python3 scripts/crossword/validate.py` prints `ALL <n> PUZZLES VALID`.
- [ ] The bank contains **no** Shia-specific terms/clues (no Twelve-Imams, no `SHIA`, no Imam-Ali-rule clue); all clues re-sourced to Sunni references; English-only-vs-trilingual decision applied consistently (bank + validator).
- [ ] `xcodebuild build` clean; `daily_crosswords.json` is in the bundle (provider `fatalError`s if missing — that's intended).
- [ ] Card cycles **locked → pending → done**; puzzle is the same on a given day, advances on the next calendar day; streak +1 on consecutive days, resets after a gap.
- [ ] Grid solves: typing fills cells, hint reveals a letter, solved overlay appears only when all cells are correct, time + streak shown.
- [ ] Grid/keyboard are fixed-size (not affected by the reading text-size control); clues localize + RTL (if trilingual) while the grid stays LTR.
