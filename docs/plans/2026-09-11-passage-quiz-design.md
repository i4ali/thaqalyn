# Passage Quiz - Design

**Date:** 2026-09-11
**Status:** Draft for review. Covers the generator (agents, skill, scripts, data shape). The app screens are a separate piece of work.

## Problem

The surah quizzes were removed in v9.0 with the five-layer tafsir they were written
from. The passage commentary is the reading unit now, so the quiz should be too: a
short check of what the reader just read, one per passage, 556 in all.

The old quizzes had two faults to avoid. They were written from memory, so they
tested things the commentary never said. And they were one format, multiple choice
with a few true or false, which reads as a test rather than a game.

## Decisions (2026-09-11)

1. **Five questions per passage, always.** Two multiple choice, one true or false,
   one fill the gap and one who said it; a third multiple choice stands in for who
   said it when the passage has too few narrations. (Until 2026-09-12 the last two
   were any two of fill the gap, who said it and which verse; see decision 7.)
2. **Every question is a single tap.** Every type is a prompt, a list of options
   and the index of the right one. True or false has the fixed options True and
   False. The app needs one question component with four framings.
3. **Answerable from the passage alone.** Every question carries an anchor: where
   in the passage it comes from and a verbatim quote that settles the answer. A
   script rejects any quote that is not in the passage. The commentary is already
   audited against its sources, so a quiz that only tests what the commentary says
   inherits that audit. Nothing is fetched.
4. **A reviewer agent rules on every question** before the quiz can ship: right
   answer, exactly one right option, every distractor wrong by the passage, no
   trivia. Same loop as the writer and auditor for passages: fail goes back to the
   writer with the review, the third fail parks the passage.
5. **Separate data file.** Quizzes ship as `Data/quiz_<surah>.json` keyed by
   passage index, next to `passages_<surah>.json`, never inside it. A quiz can be
   regenerated without touching audited commentary and committed on its own.
6. **Quizzes come from shipped passages.** The writer reads
   `Data/passages_<surah>.json`, not the work directory, so a quiz can be made for
   any shipped passage on any checkout.
7. **Which verse dropped (2026-09-12).** After the al-Baqarah run the user cut the
   type: a reader has to remember what each numbered verse says to answer it, and
   the reader pass had found its headings gave the answer away in eight quizzes.
   The 17 al-Baqarah quizzes that used it had that question rewritten as fill the
   gap and re-reviewed; surah 1 was unaffected.

## What a quiz tests

Understanding of the passage: what the verses say, what the commentary says they
mean, how the story runs, who says what in the narrations. Not:

- which scholar held a view (Tabatabai, Tabrisi and the rest may appear in a
  prompt as context, never as the thing being guessed);
- source numbers, chains, book titles, counts, dates;
- anything the passage does not say, however well known;
- a right or wrong between the traditions in Perspectives. A perspectives
  question asks what a tradition holds, neutrally.

## Question types

| type | prompt | options | rule the script enforces |
|---|---|---|---|
| `multipleChoice` | a question about the passage | 4 | one right, three plausible and wrong |
| `trueFalse` | a statement | `True`, `False` | statement is a claim from the passage or its clean negation |
| `fillGap` | a sentence from the passage with one gap written `____` | 4 | prompt with the right option in the gap is a verbatim span of the passage |
| `whoSaid` | a narration's words, "Who said this?" | 4 speakers | right option equals the narration's `speaker`; needs 2 or more narrations in the passage |

The brief tells the writer whether `whoSaid` is available for the passage; when
it is not, the quiz carries a third `multipleChoice` instead. One shipped passage
has a single narration. (`whichVerse`, four `Verse N: heading` options with the
anchor's verse right, existed until 2026-09-12; see decision 7.)

## Data

### Draft: `passages_work/<surah>/<index>/quiz.json`

```json
{
  "passage": "2:4",
  "questions": [
    {
      "id": "q1",
      "type": "multipleChoice",
      "verse": 30,
      "prompt": {"en": "How does Tabatabai read the angels' question about a viceroy on earth?"},
      "options": [
        {"en": "As an objection to God's plan"},
        {"en": "As a request to understand what puzzled them"},
        {"en": "As a warning about Iblis"},
        {"en": "As a claim to the office themselves"}
      ],
      "answer": 1,
      "explanation": {"en": "The commentary says the angels were not objecting but asking to understand, and that their closing words concede the point."},
      "anchor": {
        "where": "essay",
        "quote": "The angels' question, he insists, is not objection but a request to understand what puzzled them"
      }
    },
    {
      "id": "q3",
      "type": "whoSaid",
      "verse": 31,
      "prompt": {"en": "\"The lands, the mountains, the ravines and the valleys ... and this rug is among what He taught him.\" Who said this?"},
      "options": [{"en": "Imam al-Sadiq"}, {"en": "Imam al-Baqir"}, {"en": "Imam Ali"}, {"en": "the Prophet"}],
      "answer": 0,
      "explanation": {"en": "Asked what God had taught Adam, Imam al-Sadiq named the lands and mountains and then the rug beneath him."},
      "anchor": {"where": "verses.31.narrations.n3", "quote": "the lands, the mountains, the ravines and the valleys"}
    }
  ]
}
```

- `id` is `q1` to `q5` in order. Questions follow the passage's order.
- `verse` is the verse the question is about, within the passage range.
- `options` always present; `answer` is always an index. `trueFalse` options are
  exactly `True` and `False`.
- `anchor.where` is `essay`, `perspectives`, `verses.<verse>.note`,
  `verses.<verse>.narrations.<id>` or `verses.<verse>.translation`. `quote` is
  copied from that part, 5 to 60 words, markers dropped, straight quotes.
- `explanation` is one or two sentences, 10 to 50 words, in the passage's own
  terms, shown after the reader answers.
- Text fields are `LocalizedText` to match the passage model; only `en` for now.

### Review: `passages_work/<surah>/<index>/quiz_review.<n>.json`

```json
{
  "passage": "2:4",
  "schema": 1,
  "verdicts": [
    {"id": "q1", "verdict": "ok"},
    {"id": "q2", "verdict": "fail", "reason": "option 3 is also true by the note on verse 33"}
  ],
  "overall": "FAIL"
}
```

### Shipped: `Thaqalayn/Thaqalayn/Data/quiz_<surah>.json`

Keyed by passage index, one record per passage: `id`, `surah`, `index`, `range`,
`questions` (as in the draft), `status` (`written_at`, `review_attempts`,
`reviewed_at`, `assembled_at`). Only `quiz-assemble` writes it.

## Rules the script enforces (`quiz-validate`)

Structure: passage id matches; exactly five questions, ids `q1` to `q5`; types
exactly two `multipleChoice`, one `trueFalse`, one `fillGap` and one `whoSaid`
(a third `multipleChoice` when `whoSaid` is not allowed for this passage); no two
adjacent questions of the same type.

Per question: 4 options (2 for true or false), distinct after case folding, each
at most 12 words; `answer` in range; prompt 5 to 40 words; explanation 10 to 50
words; `verse` inside the passage range; anchor resolves and its quote is found
in that part after normalising whitespace and quote marks; `fillGap` prompt has
exactly one `____` and the filled prompt is a span of the passage; `whoSaid`
right option equals the narration's speaker and the anchor is that narration.

Across the quiz: anchors cover at least three distinct `where` values; at least
one anchor is a narration when the passage has any; the right answer is not the
same index on every four-option question. Whether the prompt gives the answer
away is the reviewer's call, not the script's.

Style, as for passages: plain spelling, no diacritics, no em dash, straight
quotes, no `[n]` markers anywhere in the quiz.

## Agents

**`passage-quiz-writer`** (`.claude/agents/passage-quiz-writer.md`, tools Read,
Write, Bash, model `claude-opus-4-8`). Reads
`.venv/bin/python scripts/passages.py quiz-brief S:I` (about 700 to 1,500 words:
verses with the Qarai translation, title, essay with markers stripped, headings,
notes, narrations with speaker and English text, perspectives, and the list of
allowed types). Writes `quiz.json` with the Write tool only. A PostToolUse hook
(`.claude/hooks/validate-passage-quiz.py`) runs `quiz-validate` and rejects the
write with the error list. On a rewrite it reads the latest review first and
changes only the failed questions. Never touches app data (the existing
protect-critical-files hook).

**`passage-quiz-reviewer`** (same tools and model). Reads the brief and
`quiz.json`; for each question rules `ok` or `fail` with a reason on: the marked
answer is right by the passage; no other option is also right by the passage;
the question is answerable from the passage alone; it tests understanding, not
trivia or scholar attribution; the prompt reads cleanly and does not give the
answer away; the explanation says why. Writes `quiz_review.<n>.json`. Never edits
the quiz.

## Skill: `/quiz`

`.claude/skills/quiz/SKILL.md`, orchestrator only. Arguments as for `/passages`:
`36`, `2:6-2:10`, `2:6 2:8`, `next N --surah S`. Procedure:

1. `quiz-status --surah S`. A target whose passage is not shipped is skipped and
   named in the report.
2. Two slots, refilled as they free, highest first: rewrite a quiz whose latest
   review is FAIL and has fewer than three reviews (writer, with the review's
   failed items in the prompt); review a valid quiz newer than its latest review;
   write a quiz for a shipped passage with none. `quiz-review-check` after every
   review. A third FAIL parks the passage.
3. Read every passed quiz as a reader (print it) and note taste problems for the
   report: trivia, a prompt that reads like a test, a distractor nobody would
   pick. Rule problems go to `quiz.py`; taste problems go to the writer prompt.
   Never edit a quiz by hand.
4. Per surah: `quiz-assemble S` merges passed quizzes into `Data/quiz_S.json`.
5. Report a per-passage table (type mix, review attempts, reader notes) and
   append it to the runbook. Ask before every commit; `quiz_S.json` in its own
   commit.

Hard rules carried over: never more than two agents at a time; never edit a quiz
by hand; never write into `Data/` except through `quiz-assemble`; ask before
commit; decisions in plain language.

## Scripts

`scripts/passage_pipeline/quiz.py`, wired into `scripts/passages.py`:

| command | does |
|---|---|
| `quiz-brief S:I` | print what the writer and reviewer read, from `Data/passages_S.json` and `quran_data.json` |
| `quiz-validate S:I` | every rule above, as a list of errors; exit 1 on any |
| `quiz-review-check S:I` | validate the latest review (ids, verdicts, reasons on fails) and print PASS or FAIL with reasons |
| `quiz-next-attempt S:I` | print the attempt number the next review file should use |
| `quiz-status --surah S` | stage per passage: `no-passage`, `none`, `drafted`, `reviewed`, `passed`, `assembled`. A review older than the quiz file is stale and the quiz counts as `drafted` |
| `quiz-next --surah S --count N` | shipped passages whose quiz has not passed |
| `quiz-assemble S` | merge passed quizzes into `Data/quiz_S.json` |

Tests in `tests/passage_pipeline/test_quiz.py` with a fixture passage: one valid
quiz, then one failing case per rule; review check; assemble.

## Costs to expect

Writer input is the brief (about 2K tokens) plus the quiz output (about 1.5K);
expect 15K to 25K tokens and one to two minutes a quiz, a rewrite less. Reviewer
about the same. For the 204 shipped passages, roughly 8M tokens across both
agents. Measure on the first surah and record it in the runbook.

## App side

Implemented on 2026-09-12 per `docs/plans/2026-09-12-passage-quiz-app.md`, which
also records the decisions made with the user (entry points, one-tap answering,
results, local-only best score, gating, fixed order, text scaling, English only).
