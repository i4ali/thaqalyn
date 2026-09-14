---
name: quiz
description: Generate the five-question quiz for shipped Quran passages in the Thaqalayn app - run the write, validate, review, rewrite and assemble loop for a passage, a range, or a surah. Use when asked to generate, write, run or continue passage quizzes ("/quiz 2:4", "/quiz 2:6-2:10", "quizzes for surah 36", "continue the quiz pipeline").
---

# Quiz - run the passage quiz pipeline

You are the orchestrator. Scripts do every deterministic step; two agents do the
writing and the reviewing; you launch them, check results, and stop at the gates.
Design: `docs/plans/2026-09-11-passage-quiz-design.md`. Results and findings:
`docs/plans/2026-09-11-passage-quiz-runbook.md`.

## Arguments

`$ARGUMENTS` is one of:

- a surah number: `36` (every shipped passage of the surah whose quiz has not passed)
- a range: `2:6-2:10` (passages 6 to 10 of al-Baqarah)
- a list: `2:6 2:8`
- `next N` with optional `--surah S`: take the output of
  `.venv/bin/python scripts/passages.py quiz-next --surah S --count N`

A quiz can only be written for a passage that is shipped in
`Thaqalayn/Thaqalayn/Data/passages_<surah>.json`. A target that is not shipped is
skipped and named in the report; generate the passage first with `/passages`.

State lives in `passages_work/<surah>/<index>/` (`quiz.json`, `quiz_review.<n>.json`,
gitignored) and is derived from files; run
`.venv/bin/python scripts/passages.py quiz-status --surah S` at any time.

## Hard rules

1. **Never more than two agents at a time.** One free slot, one launch.
2. **Never edit a quiz by hand.** Fixes go through the writer agent. Never edit
   `quiz.py` for taste; adjust the "How to write" section of
   `.claude/agents/passage-quiz-writer.md` instead.
3. **Never write into `Thaqalayn/Thaqalayn/Data/` except through `quiz-assemble`.**
4. **Ask before every commit** (AskUserQuestion), no co-author trailer. Content
   (`quiz_N.json`) is committed separately from code.
5. **Ask decisions in plain language**: say what happened to the content and what
   each option costs; keep tool names out of the question.
6. **Four question types only**: two multiple choice, one true or false, one fill
   the gap, one who said it (a third multiple choice when the brief does not list
   who said it). The "which verse" type was removed on 2026-09-12 because a reader
   cannot remember what a numbered verse says; `quiz-validate` rejects it. Never
   ask the writer for one, and if an older quiz still holds one, treat it as a
   rewrite: replace that question with fill the gap and re-review.

## Procedure

### 0. Preflight

```
.venv/bin/python scripts/passages.py quiz-status --surah S
```

### 1. Fill the two slots, and refill each one as it frees

Whenever a slot is free, launch the highest item on this list that exists:

1. **Rewrite** a quiz whose stage is `reviewed` (latest review FAIL) and that has
   fewer than 3 reviews. Agent `passage-quiz-writer`, prompt:
   `Rewrite the quiz for passage S:I; read the latest review first.` followed by
   each failed question's id and reason, then
   `Keep every question the review marked ok exactly as it is.`
2. **Review** a quiz whose stage is `drafted` and valid (a fresh quiz, or one
   rewritten since its last review). Agent `passage-quiz-reviewer`, prompt
   `Review the quiz for passage S:I`.
3. **Write** a quiz for a shipped passage whose stage is `none`. Agent
   `passage-quiz-writer`, prompt `Write the quiz for passage S:I`.

After a writer finishes: `.venv/bin/python scripts/passages.py quiz-validate S:I`
must print `quiz is valid` (the agent's PostToolUse hook already enforced it).

After a reviewer finishes: `.venv/bin/python scripts/passages.py quiz-review-check S:I`.
PASS means every question is ok and `quiz-status` shows the passage `passed`.
FAIL goes back to item 1. A **third FAIL parks the passage**: stop launching for
it, and tell the user what the reviewer keeps finding; the fix is in the writer
prompt, not in the loop.

Costs: measure tokens and minutes per writer and reviewer run on the first
surah and record them in the runbook.

### 2. Read each passed quiz as a reader

Print `passages_work/S/II/quiz.json` and read the five questions against the
passage as a reader would meet them. Note for the report anything that is taste
rather than rule:

- Would a reader who understood the passage get it right, and one who skimmed
  get it wrong?
- Does any question feel like a test of memory rather than understanding?
- Is any distractor one nobody would pick?
- Does the mix feel varied across the surah, or does every quiz open the same way?

Do not fix these yourself. Rule problems the validator missed become a note
against `quiz.py`; taste problems become a note against the writer prompt.

### 3. Per surah: assemble

When every target quiz has passed:

```
.venv/bin/python scripts/passages.py quiz-assemble S
```

It only takes quizzes that are passed and valid, merges into
`Thaqalayn/Thaqalayn/Data/quiz_S.json`, and is safe to run again later for more
passages.

### 4. Report and commit

Report a table per passage: type order (for example `MC, whoSaid, TF, fillGap, MC`; only MC, TF, fillGap and whoSaid exist),
review attempts, and reader notes; then any deviation from this procedure and
the measured costs. Append it to the runbook under a dated Results heading.

Then AskUserQuestion for the commits: code and docs (if any changed) in one
commit, `quiz_S.json` in its own commit.
