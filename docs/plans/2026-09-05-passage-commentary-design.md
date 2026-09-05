# Passage Commentary - Design

**Date:** 2026-09-05
**Status:** Draft for review. Reader flow approved in mocks; pipeline and schema pending sign-off.

## Problem

Commentary is generated per verse in five layers (Foundation, Classical Shia,
Contemporary, Ahlul Bayt, Comparative), about 200 words each, in three languages.

| | |
|---|---|
| Verses | 6,236 |
| English words | 6.42 million (about 1,030 per verse) |
| Text fields, three languages | 93,540 |
| Tafsir JSON in the bundle | 191 MB |
| Citation audit, surahs 1 to 3 | 876 faults on about 290 verses; 619 in the Ahlul Bayt layer, 108 high |

Three things are wrong, and the volume is a symptom of all of them:

1. **Wrong unit.** Tafsir is written by passage. Al-Mizan comments on 2:30-39 as one
   story and on 2:228-242 as one block. Generating per verse tells a ten-verse
   story ten times and gives "Alif Lam Mim" a thousand words.
2. **Written from memory.** The generator wrote fluent, plausible, invented hadith
   and scholarly attributions. Auditing afterwards cannot keep up: three surahs
   audited after considerable effort.
3. **Templated.** Whole layers are boilerplate with the verse title substituted in
   (2:255 is the reference example: 847 words, none about the verse).

**Decision.** Replace the five layers with one commentary per passage, generated
from scratch, written only from fetched sources, machine-validated, audited by a
separate agent, and shown to the user with its citations.

**Not reused:** the `tafsir_N.json` layer text, the citation audit ledger and
registry under `audits/`, and the `tafsir-generator`, `citation-auditor` and
`citation-fixer` agents as they stand. **Reused:** the `quickOverview` data (Gems
is a separate feature and stays), the `ruku` field on every verse in
`quran_data.json`, and the fetch and search helpers in `scripts/citation_audit.py`
(altafsir.com by tafsir number, thaqalayn.com hadith corpus, English al-Mizan
volumes), which move into the new script.

## Decisions (2026-09-05)

1. **Sources on screen: confirmed.** Three tiers, set per source record by the
   gather script from the work cited, never by the writer or the app:
   - Tier A, public domain (Tabari, Qummi, Furat, Tibyan, Majma, Ibn Kathir,
     Qurtubi, Razi, Durr, Safi, Burhan, the classical hadith collections): work,
     author, locus, chain for narrations, Arabic excerpt in full, English gloss, link.
   - Tier B, in copyright, original language (al-Mizan Arabic, Nemooneh Persian):
     same, but one sentence quoted.
   - Tier C, copyrighted translations (WOFIS al-Mizan English, Nemooneh English):
     work, translator, locus, link. No quotation.
   Mock: "Source Sheet" artifact.
2. **Release: confirmed.** Ship when the popular set is done (order below). Passages
   not yet generated show "Understanding for this passage is coming in an update"
   on the Understand button. Old reader removed at that release.
3. **Sunni sources only in Perspectives: confirmed.** The essay, notes and
   narrations cite Shia works only.
4. **Title review: confirmed.** The script produces a review table of passage titles
   and verse headings per surah; the user approves or edits before assemble.

## The reader (approved)

Three pushed screens, each doing one thing. Detail in the mock "Passage Reading".

- **Surah** is a list of its passages: ع, title, verse range, read state. Play
  whole surah. Search by verse number opens the passage that holds it.
- **Passage** is its verses, Arabic and translation. Play, Bookmark and Gems appear
  on the tapped verse. At the end: **Understand this passage** and **Next passage**.
  Reaching the end marks the passage read.
- **Understanding** is pushed from Understand: language picker (EN/UR/AR), Listen,
  text size. Essay with superscript citation markers, then **Verse by verse** (only
  verses with a note or narrations), then **Perspectives** (only where present),
  then Next passage. Tapping a marker or a narration's source line opens the
  **Source sheet**.
- **Premium** chip on the Understand button outside al-Fatihah. Verses, lists and
  Gems are free.
- Removed: In-Depth button, five-chip Commentary, `TafsirLayer`.

## Content model

**Unit:** the ruku. 556 across the Quran, median 10 verses, 40 in al-Baqarah, one
in each short surah. Derived from `quran_data.json` (`ruku` is a global running
number starting at 1 in al-Fatihah; passages are numbered 1-based within their
surah, so the Adam passage 2:30-39 is passage 4 of al-Baqarah, id `2:4`).

**File:** `Thaqalayn/Thaqalayn/Data/passages_N.json`, one per surah, keyed by
passage index. `tafsir_N.json` is deleted per surah once its passages ship;
`quickOverview` is extracted first into `gems_N.json` (same per-verse shape).

```json
{
  "4": {
    "id": "2:4",
    "surah": 2,
    "index": 4,
    "range": [30, 39],
    "title": { "en": "Adam and the angels", "ur": "…", "ar": "…" },
    "essay": {
      "en": "The passage opens with an announcement, not a creation … Tabatabai reads khalifa as one who exercises delegated authority on behalf of another [1] …",
      "ur": "…", "ar": "…"
    },
    "verses": [
      {
        "verse": 30,
        "heading": { "en": "The viceroy announced", "ur": "…", "ar": "…" },
        "note": { "en": "Khalifa: one who holds delegated authority. The angels ask from knowledge, not objection. [1][2]", "ur": "…", "ar": "…" },
        "narrations": [
          {
            "id": "n1",
            "speaker": "Imam al-Baqir",
            "addressee": "Zurara",
            "arabic": "…verbatim from the source block…",
            "text": { "en": "Asked what the angels knew when they said 'one who corrupts and sheds blood' …", "ur": "…", "ar": "…" },
            "source": "s4"
          }
        ]
      }
    ],
    "perspectives": {
      "en": "Both traditions read the prostration as honouring Adam, not worship [3][7] …",
      "ur": "…", "ar": "…"
    },
    "sources": [
      {
        "id": "s1",
        "kind": "tafsir",
        "work": "al-Mizan fi Tafsir al-Quran",
        "author": "Allamah Tabatabai",
        "tradition": "shia",
        "locus": "on al-Baqarah 30 to 33",
        "url": "https://www.altafsir.com/…tTafsirNo=56&tSoraNo=2&tAyahNo=30…",
        "excerpt": { "lang": "ar", "text": "…one or two sentences, verbatim…" },
        "gloss": "…English rendering of the excerpt…",
        "show_excerpt": true
      },
      {
        "id": "s4",
        "kind": "hadith",
        "work": "al-Burhan fi Tafsir al-Quran",
        "author": "Sayyid Hashim al-Bahrani",
        "tradition": "shia",
        "locus": "on al-Baqarah 30, via Zurara",
        "url": "…",
        "excerpt": { "lang": "ar", "text": "…" },
        "show_excerpt": true
      }
    ],
    "status": {
      "written_at": "2026-09-08T…", "writer_model": "…",
      "audited_at": "…", "audit_pass": true,
      "translated_at": null
    }
  }
}
```

Rules encoded by the validator, not the prompt:

- **Budgets.** Title 6 words max. Essay 250 to 400 words for passages of 8 or more
  verses, 120 to 250 below that. Note 40 words max. Narrations 3 per verse max,
  60 words each. Perspectives 60 to 120 words, optional. Heading 5 words max.
- **Citations.** Every sentence that attributes a position, reports an occasion of
  revelation, quotes a narration, or names a scholar carries at least one `[n]`.
  Every `[n]` resolves to a source id. Every source is used at least once.
- **Narrations** must come from a hadith-kind source block and carry the Arabic
  verbatim from that block. No narration without `arabic` and `source`.
- **Tradition.** `sunni` sources may be referenced only from `perspectives`.
- **Style.** Plain English spelling, no transliteration diacritics, no em dashes,
  Qarai translation wording when quoting the verse. Markers keep their positions in
  the Urdu and Arabic renderings.
- **Coverage.** A verse entry exists only if it has a note or a narration. Whether
  the essay covers the whole passage is the auditor's judgement, not a mechanical
  rule.
- **Passage-level narrations** (about the passage rather than one verse) are
  allowed with `"verse": null` and render under the essay.

## Pipeline

One CLI, `scripts/passages.py`, owns state. Agents never write into
`Thaqalayn/Thaqalayn/Data/`. Work happens under `passages_work/<surah>/<index>/`.

```
gather  ->  write  ->  validate  ->  audit  ->  (rewrite loop)  ->  translate  ->  assemble
script      agent      script       agent                          agents        script
```

### 1. Gather (script, deterministic)

`passages.py gather 2:5` fetches and caches, for every verse in the range, the
commentary block of each source, deduplicated because tafsirs group verses:

| Role | Sources (altafsir.com tafsir no.) |
|---|---|
| Essay backbone | al-Mizan (56), Majma al-Bayan (3), al-Tibyan (39) |
| Narrations | al-Burhan (110), Tafsir al-Qummi (38), al-Safi (41), Furat al-Kufi (45), Majma's narrations, thaqalayn.com corpus hits for the verses |
| Perspectives only | al-Tabari (1), Ibn Kathir (quran.com), al-Qurtubi (5), al-Razi (4), al-Durr al-Manthur (26) |
| Where available | English al-Mizan (WOFIS, surahs 1 to 6:83), Nemooneh English |

Output: `sources.json` (the blocks the writer may cite, each with an id, url,
fetched_at, sha256 and plain text) plus `verses.json` (Arabic, Qarai, Urdu).
Cached on disk so writing and auditing are reproducible and offline. A source
that returns empty is retried once and then recorded as `unavailable`, which the
writer sees.

### 2. Write (agent `passage-writer`)

Tools: Read, Write, Bash. **No web.** Input: `verses.json`, `sources.json`, the
rules above, and on a rewrite the auditor's verdicts. Output: `draft.json` in the
schema above. It may only cite ids present in `sources.json` and may only quote
text present in those blocks. It proposes the title and verse headings.

### 3. Validate (script)

`passages.py validate 2:5` runs every rule in the content model, plus: each
`excerpt.text` and each narration `arabic` is a normalized substring of its source
block; the range matches `quran_data.json`; JSON shape. Fails fast with a list the
writer can act on. Nothing proceeds to audit until it passes.

### 4. Audit (agent `passage-auditor`)

Tools: Read, Bash. **No web.** Separate context from the writer. Reads
`draft.json` and `sources.json` and rules on every cited claim and every
narration: `supported`, `stretched`, `unsupported`, each with the supporting or
contradicting excerpt. Also flags claims that carry no marker but should. Writes
`audit.json`. **Pass** means every verdict is `supported` and nothing is uncited;
a `stretched` verdict anywhere fails (tightened 2026-09-05 after the 2:4 pilot
audit, where a wrong speaker in Perspectives was ruled stretched and would have
shipped under the original narrations-only rule). Fail returns to step 2 with
`audit.json` attached, at most twice; a third failure is parked for a human.

### 5. Translate (agents, per surah, after freeze)

The existing Urdu and Arabic translator agents, adapted to the passage schema:
title, essay, headings, notes, narration text, perspectives. Markers and `[n]`
positions preserved. Narration `arabic` is never translated. Validation hooks
adapted to the schema.

### 6. Assemble (script)

`passages.py assemble 2` merges every passed and translated draft for the surah
into `passages_N.json`, re-runs the validator on the whole file, extracts
`quickOverview` into `gems_N.json`, and reports what is still missing.

**Concurrency:** waves of two agents at a time (house rule). `passages.py next`
and `claim` hand out work as the audit script did.

## App changes (implementation plan to follow)

- **Models:** `Passage`, `PassageVerse`, `Narration`, `PassageSource`, `Gems`.
  `DataManager` loads `passages_N.json` and `gems_N.json`. `TafsirLayer` removed.
- **Views:** `SurahPassagesView` (replaces the verse-card scroll), `PassageView`,
  `UnderstandingView`, `SourceSheet`. `FullScreenCommentaryView`,
  `ModernTafsirTabs`, `ModernTafsirContent`, `TafsirLayerSelector` removed.
  `VerseSummaryView` and `QuickOverviewView` stay, opened from the verse's Gems
  action. Audio, bookmarks and go-to-verse keep their verse keys.
- **Progress:** read state per passage, set on reaching the end of `PassageView`.
  `LastReadInfo` gains the passage index; Continue Reading opens the passage.
- **Premium:** `PremiumManager.canAccessUnderstanding(surahNumber:)`, same rule as
  `canAccessLayer` today; Premium chip on the Understand button.
- **Reading text size** applies to verses, essay, notes, narrations, perspectives.
- **What's New** entry for the new reader.

## Order, pilot, release

**Pilot:** al-Baqarah passages 1 to 5 (verses 1 to 39). Measure per passage:
validator failures per draft, audit pass on first try, rewrite loops, wall time,
token cost. Gate to batch: all five pass with an average of at most one loop.

**Batch order:** al-Fatihah; Yasin; al-Kahf; al-Mulk; juz 30 (surahs 78 to 114);
al-Rahman; al-Waqi'ah; al-Baqarah; Al Imran; then sequential. The new reader
ships when this popular set is complete. Translations run per surah once its
English is frozen.

**After a surah ships:** delete its `tafsir_N.json`. Bundle projection for the
whole Quran: about 420,000 English words, 15 to 20 MB of data across three
languages, down from 191 MB.

## Open questions

- Nemooneh (Makarem Shirazi) as an essay source: English "Enlightening Commentary"
  is partial and copyrighted; the Persian original is not on altafsir. Include by
  locus only where the English exists, or leave out. Leaning leave out for v1.
- Ruku boundaries where al-Mizan groups differently (rare): keep ruku as the unit
  and let the essay say "this continues the previous passage" rather than
  merging. Confirm.
