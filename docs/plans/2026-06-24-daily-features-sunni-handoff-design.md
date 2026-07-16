# Design — Sunni Handoff Package for Daily Challenge & Daily Crossword

**Date:** 2026-06-24
**Status:** Approved (brainstorming complete → writing-plans)
**Goal:** Produce a self-contained handoff package so a Claude session working in the sibling **Sunni** iOS app (AlBayan) can rebuild the **Daily Challenge** (v6.4) and **Daily Crossword** (v6.5) features with the *exact same structure* but Sunni content.

## Source features (Thaqalayn)

The two features are architectural near-twins:

- Shared `LocalizedText {en, ur?, ar?}` content model.
- Bundled JSON content file + a `Provider` that deterministically picks "today's" item by **day-of-year mod count**, cached in UserDefaults.
- A `Manager` with a pure `next(streak, today, yesterday)` function, persisted to UserDefaults via `yyyy-MM-dd` day keys. **Local only — no cloud sync, no points, badges retired/filtered.**
- Premium gate: one-liner `canAccessX() -> Bool { isPremium }`.
- Today-tab card, 3 states (locked→paywall / pending→sheet / done).
- An onboarding demo slide.
- Theme-coupled play UI (Em* components, `ThemeManager`, `CommentaryLanguageManager`/RTL).

Two differences that matter:
- **Content origin** — Crossword has a pipeline (`scripts/crossword/`: `bank.json` → `generate.py` criss-cross → `daily_crosswords.json` → `validate.py`). Daily Challenge is hand-authored JSON (72 items, no script).
- **Text scaling** — Daily Challenge reading content scales with `ReadingSettingsManager`; Crossword is deliberately fixed-size chrome.

## Decisions (from scoping)

1. **Content scope:** Ship structure + pipeline + adaptation rules. **No pre-written Sunni content** — the target authors it.
2. **Target infra:** AlBayan already has a **Today tab** and **premium/paywall** → package hooks into them, does not rebuild them. Neither feature uses cloud sync (the "no Supabase" answer is moot).
3. **Theme:** AlBayan does **not** share the Em* theme system → engine ports verbatim; **UI is rebuilt in AlBayan's own theme** via a mapping table, not copied line-for-line.
4. **Delivery:** Self-contained — target assumes no access to this repo.
5. **Structure:** **Approach B** — a package folder.

### Two baked-in assumptions (stated in the package, to be verified by the target/user)
- AlBayan has its own theme system + fonts to map the UI onto.
- AlBayan supports the same en/ur/ar + RTL multilingual model; if English-only, `ur`/`ar` become optional/dropped.

## Package layout (Approach B)

```
docs/handoffs/daily-features-sunni/
├── README.md              # shared foundations, theme-token mapping, adaptation ruleset, master checklist
├── 01-daily-challenge.md  # models/manager/provider (verbatim, in src/), content schema + authoring spec, UX specs, content notes
├── 02-daily-crossword.md  # models/manager/provider + scripts/crossword pipeline (verbatim, in src/), puzzle schema, bank authoring spec, UX specs, content notes
└── src/                   # verbatim-portable artifacts the target copies directly
    ├── DailyChallengeModels.swift, DailyChallengeManager.swift, DailyChallengeProvider.swift, DailyChallengeStrings.swift
    ├── DailyCrosswordModels.swift, DailyCrosswordManager.swift, DailyCrosswordProvider.swift, DailyCrosswordStrings.swift
    └── crossword/         # bank.json (Shia REFERENCE — replace), generate.py, validate.py
```

## Key principle (carried from `docs/specs/dhul-hijjah-journey-export.md`)

Separate three layers:
- **Sect-agnostic engine** (models, manager, provider, scripts, persistence) → copy verbatim.
- **Themed UI** (play screen, card, onboarding) → rebuild in AlBayan's theme via a mapping table + UX spec.
- **Content** (JSON / word bank) → author fresh Sunni content per the adaptation ruleset.

## Shia→Sunni adaptation ruleset (reused + extended)

- **Honorifics:** `(a)`/`عليه السلام` for Imams → removed; Prophet ﷺ; Companions `(ra)`.
- **Sources:** Mafatih al-Jinan / al-Kafi / al-Sahifa al-Sajjadiyya → Bukhari, Muslim, Tirmidhi, Riyad as-Salihin, Hisn al-Muslim, al-Adhkar al-Nawawi.
- **Content swaps:** drop/recast Twelve-Imams enumeration, Imamate-as-divine-office, Ghadeer, Du'a Kumayl, Khums-as-distinctive-pillar, Karbala-as-devotion. Crossword: replace the 9 `ahlulbayt` bank terms + `SHIA`/`BAYT`/`KUFA` clues; keep the ~86 neutral terms.
- **Schema:** keep trilingual `{en, ur, ar}`; English-only target drops `ur`/`ar`.

## House rules to transfer (from CLAUDE.md)
- No fallback logic unless explicitly requested.
- Reading content scales with the reading text-size control (applies to Daily Challenge content; **not** the Crossword grid/chrome).
- Both features are **local-only**; the bookmark cloud-sync architecture does **not** apply here (preempt over-engineering).

## Next step
Invoke writing-plans methodology to author the package (the package's per-feature checklists + acceptance criteria are the plan for AlBayan's build).
