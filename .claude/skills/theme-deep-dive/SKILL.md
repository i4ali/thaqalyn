---
name: theme-deep-dive
description: Author a new theme "Deep Dive" (Yaqin/Sabr/Tawakkul/Shukr family) for the Thaqalayn iOS app - a single-sitting descent through a spiritual theme like Ikhlas, Taqwa, Rida, shown on the Journeys tab. Use when asked to create/build "the next deep dive", a deep dive for a named theme ("make the Ikhlas deep dive", "build Taqwa"), or a new entry in the deep-dive roadmap. Runs research → spine → design+mock → implement → build → 3-auditor audit with two approval gates, letting each theme find its own shape instead of forcing the house template. NOT for surah experiences - those use /inside-the-surah.
---

# Theme Deep Dive - author a new themed descent

You are building one immersive, full-screen "descent" through a spiritual THEME for the
Thaqalayn app: a sequence of beats rendered by `DeepDiveView` from a single data file,
listed in `DeepDiveCatalog`. The shipped theme dives - Yaqin, Sabr, Tawakkul, Shukr - are
your reference, not your cage. (Surah experiences share the engine but have their own
skill: `/inside-the-surah`.)

## THE PRIME DIRECTIVE (read twice)

**The house pattern is a GUIDE, not a mold. Fit the theme; never force the theme into the
pattern.** If the theme fits an old template naturally, that is fine too - reuse is not a
failure. Forcing is.

The four shipped dives happen to share a lot: three movements with Arabic station names, a
threshold `.depths` map, a Karbala summit, an interactive close, a Sahifa dua, a closing
"The X is yours to keep." Every one of those is a **fact about those four themes, not a
law**. For each, derive - never default:

1. **The spine metaphor is the identity.** Yaqin = depths of knowing, Sabr = stations of
   bearing, Tawakkul = motions of the hand, Shukr = tongues of thanks. Each new dive needs
   its own organizing image, distinct from all shipped ones. A spine that would fit several
   themes equally well fits none.
2. **Derive the movement count** from the theme's own natural joints (a classical
   tripartite from the tradition, a two-fold tension, one held idea). Three is common
   because the tradition loves triads - it is still a finding, not a target. The force-fit
   tell: a thin "movement" padded out to hit a number.
3. **The summit is where the theme's supreme enactment lives.** All four dives summit at
   Karbala because those themes' truest embodiments are there. Earn it again only if THIS
   theme's peak is genuinely at Karbala (it often is - but check; a theme like Ikhlas may
   peak at the Mubahala or in Surah al-Insan). If two dives visit the same scene, the new
   one must see it through a genuinely different lens, and the design doc must name the
   echo as deliberate (Shukr revisiting Sabr's Last Night is the precedent).
4. **An interactive close is EARNED, not required.** Only invent one when a physical
   gesture maps to the theme's meaning: press-hold-release IS entrustment (`release`,
   Tawakkul), tapping a count you must lose IS 16:18 (`count`, Shukr). Yaqin and Sabr
   close with the plain `reflectionPrompt` and are complete. If no gesture embodies the
   theme, do not bolt on a gimmick - use `reflectionPrompt`, or reuse an existing
   interactive beat ONLY if its meaning truly matches.
5. **Every beat earns its place.** A beat present only because the other dives have it
   gets cut.

## The no-reuse ledger (hard rule)

Before designing, build a ledger of everything the shipped dives already used - every
verse (surah:ayah), every narration/scene, every figure-moment, every Sahifa dua - from
the content files AND their design docs (`docs/plans/*-deep-dive-design.md`). Nothing on
the ledger may be reused. Also collect **reserved material**: design docs explicitly bank
material for future dives (e.g. the al-Insan feeding narrative 76:8-9 is reserved for
Ikhlas - Shukr used only 76:22). Reserved material belongs to its designated dive.

## Scope of every run

- **English first.** Bare string literals for `LocalizedText` fields; UR/AR localization
  is a later pass (Sabr/Tawakkul/Shukr precedent). Qur'an Arabic and hadith anchors are
  authored now, in the **plain (non-Uthmani) orthography** the theme dives use - there is
  NO byte-check against `quran_data.json` for theme dives (that check is surah-dive only).
- **Two approval gates**: the SPINE (Stage 1) and the DESIGN (Stage 2). No Swift before both.
- Premium-gated by default via the catalog; the engine handles gating, veil, recitation,
  Listen buttons, and reading scale - no per-dive code for any of those.

---

## Pipeline

### Stage 0 - Immerse and research (no output to user yet)

1. **Read all shipped theme dives in full** (`Thaqalayn/Content/{Yaqin,Sabr,Tawakkul,Shukr}DeepDive.swift`)
   plus their design docs (`docs/plans/2026-07-16-tawakkul-deep-dive-design.md`,
   `2026-07-17-shukr-deep-dive-design.md`) - the docs carry the voice, the sourcing-table
   format, and the reserved-material notes. Read `references/beat-vocabulary.md` (this skill).
2. **Confirm the topic.** `DeepDiveCatalog.swift` holds the roadmap: the first
   `available: false` entry is the default next dive (its title/sfSymbol/cover already
   exist). Confirm with the user before assuming.
3. **Build the no-reuse ledger** (above) and gather the theme's material: candidate verses
   (check text via `quran_data.json`), classical treatments of the theme from the Ahl
   al-Bayt corpus (al-Kafi's thematic chapters, Misbah al-Shari'a, al-Sahifa
   al-Sajjadiyya, al-Irshad), and 2-3 candidate spine metaphors.

### Stage 1 - SPINE  ← GATE 1

Present **2-3 candidate spines** with a recommendation and trade-offs - each as a compact
preview: working title, movement structure (Arabic + translit + English name per
movement), key verses, the summit, and the payoff/turn. AskUserQuestion with previews
works well here. Then settle, with the user:
- the spine (and movement count - derived, per the Prime Directive);
- the **summit** (with any deliberate cross-dive echo named);
- the **interactive close** (existing `reflectionPrompt` / existing interactive beat /
  new engine beat - present the mechanics if new, and only if the gesture embodies the theme).

Do not proceed until these are chosen.

### Stage 2 - DESIGN  ← GATE 2

1. **Verify every source verbatim FIRST** - before drafting copy. Web-search each
   narration/dua to its named source (al-Kafi with volume/page where findable, al-Irshad,
   Sahifa dua number); pull each verse's text from `quran_data.json` and transcribe to
   plain orthography. A beat whose source cannot be verified does not get drafted.
2. **Draft all beats' final copy** in the house voice: spare literary prose, " - " never
   an em dash, plain English spelling (no transliteration diacritics - see
   `scripts/strip_diacritics.py` rules), curly quotes only inside quoted speech,
   reflections 2-3 sentences. Typical run: 14-16 beats, estMinutes 5.
3. **Render a visual mock** - the user reviews real pixels, not ASCII. Copy the design
   system of `docs/mockups/shukr_mock.html` (phone frames, emerald/gold palette, local
   fonts), one frame per distinctive beat and one per state of any new interactive beat,
   then render + open per `references/technical-integration.md`.
4. **Present the design** (identity, arc, identity moves, architecture, sourcing table,
   what is deliberately NOT used) with the mock. **Stop for approval.** Iterate.
5. On approval, write `docs/plans/YYYY-MM-DD-<theme>-deep-dive-design.md` mirroring the
   Shukr design doc's sections (summary/identity, architecture, new-beat spec if any,
   full per-beat content as transcription source of truth, sourcing table, catalog +
   What's New, out of scope). Do not commit - the user commits.

### Stage 3 - IMPLEMENT

Follow `references/technical-integration.md`. Write an implementation plan
(`docs/plans/YYYY-MM-DD-<theme>-deep-dive.md`) with complete code, then execute it -
subagent waves of **max two**, each wave ending in a build gate:
- Wave 1: engine changes if a new beat was earned (`DeepDive.swift` + `DeepDiveView.swift`
  are one atomic unit - the exhaustive switch will not compile between them).
- Wave 2: the content file, transcribed **verbatim** from the design doc.
- Wave 3: catalog flip + What's New entry (required for every dive).
Skip any code-quality-review stage; keep build + behavior-guardrail checks.

### Stage 4 - BUILD

Run the final `xcodebuild` YOURSELF (never trust only an implementer's green) plus the
guardrail greps in `references/technical-integration.md` (added-line em-dash check,
diacritics report, no `lock.fill`, fixed strings present). Ignore SourceKit
"cannot find type in scope" on new files - stale-index false positives; the green
`xcodebuild` is the truth. No XCTest. Do not launch the simulator - the user does the
device pass themselves.

### Stage 5 - AUDIT (flag-only, three agents)  ← REQUIRED for every new dive

Once the build is green, run the audit per `references/audit.md`: **three** auditors in
**two waves** - A and B together, then C (never more than two at once):
- **Auditor A - Flow, shape & the ledger**: walks every beat in order; coherence, pacing,
  transitions, template-not-forced, interactive-close earned, no-reuse ledger honored.
- **Auditor B - Theology, sourcing & Arabic**: Shia sourcing, honorifics, narration
  attributions, Arabic correctness (plain-orthography SEMANTIC check against the canonical
  text - not a byte-check), excerpt-vs-recitation anchoring.
- **Auditor C - Readability**: every English string read as a tired first-time phone
  reader; first-pass comprehension is the bar.

All three **report only - they do not edit anything**. Consolidate into one ranked list
(Blocker / Should-fix / Polish), present it, and **stop**. The user picks which findings
to fix; apply ONLY the approved ones, then re-run the build gate. Unapproved findings are
recorded in the design doc as "known, accepted".

### Stage 6 - Close out

Update the auto-memory (a `project_<theme>_deep_dive.md` note: shipped date, spine, any
new beat, UR/AR pending, any material newly reserved for future dives + `MEMORY.md`
line). Remind the user of the What's New `releaseDate` placeholder. Hand off for the
user's simulator pass and commit.

---

## Guardrails

- **Two gates are mandatory.** Never write Swift before the spine AND design are approved.
- **Auditors never fix.** Findings are applied only after explicit user approval, one by one.
- **Max two subagents at a time** - waves, always.
- **Never auto-commit** - the user commits themselves.
- **No em dashes**, anywhere, ever (" - " only). No transliteration diacritics in English.
  No `lock.fill` (premium is signaled by the catalog chrome, not locks).
- A new dive is a shipped user-facing feature → the What's New entry is required (EN/UR/AR).
- The design doc is the single source of truth for content - implementers transcribe, never
  rewrite.
