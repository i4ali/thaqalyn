---
name: passages
description: Generate sourced passage commentary for the Thaqalayn app - run the gather, write, validate, audit, rewrite, title-review and assemble loop for a surah or a range of passages, exactly as the al-Baqarah 2:1 to 2:5 pilot ran. Use when asked to generate, write, run or continue passages ("/passages 2:6-2:10", "generate passages for surah 36", "run the next five passages of al-Baqarah", "continue the passage pipeline").
---

# Passages - run the passage commentary pipeline

You are the orchestrator. Scripts do every deterministic step; two agents do the
writing and the auditing; you launch them, check results, and stop at the gates.
Design: `docs/plans/2026-09-05-passage-commentary-design.md`. Runbook with the
pilot's numbers and findings: `docs/plans/2026-09-05-passage-pilot-runbook.md`.

## Arguments

`$ARGUMENTS` is one of:

- a surah number: `36` (every passage of the surah not yet passed)
- a range: `2:6-2:10` (passages 6 to 10 of al-Baqarah)
- a list: `2:6 2:8`
- `next N` with optional `--surah S`: take the output of
  `.venv/bin/python scripts/passages.py next --surah S --count N`

Passage ids are `surah:index`, index 1-based within the surah. State lives in
`passages_work/<surah>/<index>/` (gitignored) and is derived from files; run
`.venv/bin/python scripts/passages.py status --surah S` at any time.

## Hard rules

1. **Never more than two agents at a time.** One free slot, one launch.
2. **Never edit a draft by hand.** Fixes go through the writer agent. Never edit
   `validate.py` for taste; adjust the "How to write" section of
   `.claude/agents/passage-writer.md` instead.
3. **Never write into `Thaqalayn/Thaqalayn/Data/` except through `assemble`.**
4. **Ask before every commit** (AskUserQuestion), no co-author trailer. Content
   (`passages_N.json`) is committed separately from code.
5. **Ask decisions in plain language**: say what happened to the content and what
   each option costs; keep tool names out of the question.

## Procedure

### 0. Preflight

```
.venv/bin/python -m pytest tests/passage_pipeline -q      # only if scripts changed
.venv/bin/python scripts/passages.py status --surah S
```

### 1. Gather every target passage first

```
.venv/bin/python scripts/passages.py gather S:I
```

Script, not agent; about two minutes per passage, run them sequentially in the
background. Read the output: `unavailable` lists works altafsir returned empty for
(a missing al-Mizan or al-Burhan block is worth one retry); the last line reports
hadith corpus hits dropped for not quoting the verse (expected: most of them).

### 2. Fill the two slots, and refill each one as it frees

Whenever a slot is free, launch the highest item on this list that exists:

1. **Rewrite** a passage whose latest audit is FAIL and that has fewer than 3
   audit files. Agent `passage-writer`, prompt:
   `Rewrite passage S:I; read the latest audit first.` followed by the specific
   non-supported targets from the audit, what the block actually says, and the
   fix expected, then `Keep everything the audit marked supported as it is.`
   A rewrite also clears the audit's prose flags, so do not queue a polish for
   a passage that is being rewritten.
2. **Polish** a passage whose stage is `polish` (audit PASS, prose flags still
   in the draft). Agent `passage-polisher`, prompt `Polish passage S:I`. It
   reads only the draft and the flags, rewrites only the flagged sentences,
   and keeps every marker. About 20K tokens and a minute or two.
3. **Audit** a passage whose `draft.json` is valid and newer than its latest
   audit (or has none). Agent `passage-auditor`, prompt `Audit passage S:I`.
4. **Write** a gathered passage with no draft. Agent `passage-writer`, prompt
   `Write passage S:I`.

After a writer finishes: `.venv/bin/python scripts/passages.py validate S:I` must
print `draft is valid` (the agent's PostToolUse hook already enforced it). Print
the draft and read it as a reader (see below) before moving on.

After an auditor finishes: `.venv/bin/python scripts/passages.py audit-check S:I`.
PASS means every verdict is supported and nothing is uncited. FAIL goes back to
item 1. A **third FAIL parks the passage**: stop launching for it, and tell the
user what the auditor keeps finding; the fix is in the prompts, not in the loop.
PASS may still list `prose` lines under it: sentences a reader stumbles on.
Those never cause a rewrite; `status` shows the passage as `polish` and it goes
to item 2. A passage with an outstanding prose flag is not `passed` and
`assemble` will not take it.

After a polisher finishes: print `passages_work/S/II/polish.json` and read every
before and after pair. `.venv/bin/python scripts/passages.py status --surah S`
must now show the passage `passed`. If it shows `audited` instead, the polish
moved a marker and the old audit no longer covers the draft: queue an audit.

Costs to expect per run (measured on Opus 4.8 over surah 5 passages 1 to 3,
2026-09-08; the Opus 5 numbers were about 20 percent higher): writer 170K to
220K tokens and 12 to 16 minutes; auditor 125K to 175K tokens and 5 to 6
minutes; a rewrite 28K to 36K tokens and 1 to 2 minutes (the writer reads the
audit and fixes the named target without re-reading the packet; on Opus 5 it
was about 235K). A follow-up message to an agent that is still resident costs
only the delta: a six-id renumber by the writer was 2K tokens, and the auditor
re-ruling the same draft was 8K.

### 3. Read each draft as a reader

Print it (title, essay, verse entries with speakers and English, perspectives)
and note, for the final report, anything that is a taste or policy question
rather than a rule:

- Does the essay tell the passage once, in order, in a voice you would sign?
- Are the narrations the ones that interpret the verse, or filler?
- Speaker names consistent across passages? Epithets not in the block?
- Polemical narrations present where the sources carry them?
- Perspectives only where the traditions genuinely differ?

Do not fix these yourself. Rule problems the validator missed become a note
against `validate.py`; taste problems become a note against the writer prompt.
A sentence a reader would stumble on or misread is the auditor's job now (its
`prose` list); if you meet one the auditor missed, note it for the auditor
prompt rather than polishing it by hand.

### 4. Per surah: titles, assemble, metrics

When every target passage has passed:

```
.venv/bin/python scripts/passages.py titles S
```

Present the titles table (and headings on request) to the user with
AskUserQuestion: approve all as generated, or they edit
`passages_work/S/titles.json` and flip `approved: true` per passage. Then:

```
.venv/bin/python scripts/passages.py titles S --apply
.venv/bin/python scripts/passages.py assemble S
.venv/bin/python scripts/passages.py metrics S
```

`assemble` only takes passages that are passed, valid and title-approved; it
merges into `Thaqalayn/Thaqalayn/Data/passages_S.json`, so running it again
later for more passages is safe.

### 5. Report and commit

Report: the `metrics` table, which passages needed rewrites and why, any
deviation from this procedure, and the reader notes from step 3. Append the
metrics and findings to the runbook under a dated Results heading.

Then AskUserQuestion for the commits: code and docs (if any changed) in one
commit, `passages_S.json` in its own commit, so content can be reverted without
touching code.

## Known findings carried from the pilot

- Prose gate added 2026-09-08 after 2:3 shipped "could be the work of nothing
  created" (source supported, English inverted). The auditor flags sentences a
  reader stumbles on or misreads, never style; flags route to the polisher, not
  the writer. Writer and auditor were pinned to `claude-opus-4-8` the same day.

- Auditor strictness varies between runs; a second audit may flag what the first
  passed. Budget for it.
- Attribution is the usual failure: speaker taken from the isnad rather than the
  block, or an impersonally reported view credited to the author. The writer
  prompt has a "Speakers and names" rule for this.
- Speaker names are not normalised across passages yet.
- Gradings inside al-Burhan and al-Kafi blocks (for example a weak grading) are
  not surfaced in the draft.
- A targeted rewrite mode (failing targets plus their blocks only) does not exist
  yet; rewrites re-read the whole packet. In practice a follow-up message to
  the still-resident writer or auditor does the same job for 2K to 18K tokens.
- 2026-09-11: altafsir's pager had switched to JavaScript links, so every
  multi-page block fetched before that date is page one only (surahs 1 to 10;
  the al-Mizan block for Yunus 31 to 36 is nine pages). Fixed in `fetch.py`.
  Same day: altafsir returns HTTP 500 for al-Mizan on Yunus 26 to 30, 37 to
  70 and 104 to 109; `fetch_altafsir` now falls back to greattafsirs.com (same
  tafsir numbers, one page per block, silently substitutes Majma al-Bayan when
  a work has no entry, which the fetcher detects and rejects).
- 2026-09-11: audits carry `"schema": 2` and rule on every source gloss
  (`sources.<id>.gloss`); `audit-check` notes when an older audit did not.
