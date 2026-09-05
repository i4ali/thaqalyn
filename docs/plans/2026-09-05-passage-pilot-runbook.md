# Passage Pilot Runbook - al-Baqarah 2:1 to 2:5

Gate to batch: all five pass audit with a mean of at most 1.5 attempts, and you are
happy with the drafts as a reader.

## Per passage

1. `passages.py gather 2:N` (main session, once). Check `unavailable` in the output; a
   missing al-Mizan or al-Burhan block is worth a retry. The gather output also reports
   how many hadith corpus hits were dropped for not quoting the verse; only hits that
   quote the verse opening are kept.
2. Launch `passage-writer` with `Write passage 2:N`. At most two agents at a time. The
   writer saves the packet to `passages_work/2/0N/brief.md` (the work dir is zero-padded, so 2:4 is `2/04`) and reads it in pages; a
   ten-verse packet is about 400 KB.
3. `passages.py validate 2:N` must print valid (the hook already enforced it).
4. Launch `passage-auditor` with `Audit passage 2:N`.
5. `passages.py audit-check 2:N`. On FAIL, launch `passage-writer` with
   `Rewrite passage 2:N; read the latest audit first`, then audit again. Third FAIL:
   stop and read the audit yourself; the fix is in the prompts, not in the loop.
6. `passages.py status --surah 2` to see where everything stands.

## Per surah

7. `passages.py titles 2`, edit `passages_work/2/titles.json`, set `approved: true`
   per passage, then `passages.py titles 2 --apply`.
8. `passages.py assemble 2` writes `Thaqalayn/Thaqalayn/Data/passages_2.json`.
9. `passages.py metrics 2` for the gate numbers.

## What to read for, as a reader

- Does the essay tell the passage once, in order, in a voice you would put your name to?
- Are the narrations the ones that interpret the verse, or filler that merely quotes it?
- Is anything cited that a reader tapping the source sheet would not find?
- Is Perspectives present only where the traditions genuinely differ?

Adjust the "How to write" section of `passage-writer.md` for taste problems.
Adjust `validate.py` only for rules that should be mechanical.

## Results (2026-09-05)

```
passage  stage     attempts  first  hours  sources
2:1      passed           1   True    0.6       61
2:2      passed           3  False    0.8       96
2:3      passed           1   True    0.9       76
2:4      passed           3  False    1.0       87
2:5      passed           1   True    1.1       62

5 passed, first-try 3/5, mean attempts 1.8
```

Output: `Thaqalayn/Thaqalayn/Data/passages_2.json`, 169 KB, five passages.

| id | essay words | verse entries | narrations | sources | perspectives words |
|---|---|---|---|---|---|
| 2:1 | 244 | 5 | 7 | 16 | 107 |
| 2:2 | 400 | 7 | 9 | 25 | 114 |
| 2:3 | 356 | 9 | 14 | 28 | 100 |
| 2:4 | 382 | 6 | 12 | 25 | 113 |
| 2:5 | 232 | 6 | 10 | 22 | 101 |

Gate: all five passed, but mean attempts is 1.8 against the 1.5 target. Both
failures were attribution problems the validator cannot see (a speaker named from
the isnad rather than the block, a reported view handed to the author), caught by
the auditor and fixed by targeted rewrites. The pass rule was tightened mid-pilot
so that any `stretched` verdict fails; under the original narrations-only rule 2:4
would have passed on attempt 1 with a wrong speaker in Perspectives.

Costs per agent run: writer 180K to 260K tokens and 10 to 14 minutes for a fresh
draft, about 235K tokens and 4 minutes for a rewrite (the packet is re-read in
full either way); auditor 160K to 250K tokens and 5 to 9 minutes.

Findings for the next batch:

- Auditor strictness varies between runs: the second audits of 2:2 and 2:4 flagged
  items the first audits had passed (an uncited sentence; "al-Tabrisi's first
  reading" for an impersonally reported view). Expect some churn from that alone.
- The writer prompt gained a "Speakers and names" rule after 2:4 (speaker from the
  chain's last link, no epithets the block lacks, reported views attributed to
  their source). 2:1, 2:3 and 2:5, written after it, passed first time.
- Speaker naming is not normalised across passages ("Ali ibn al-Husayn" beside
  "Imam al-Baqir", "Amir al-Mu'minin" beside "Imam Ali", "The Prophet" beside
  "the Messenger of God"). A house list of speaker names, enforced by the
  validator, would fix this mechanically.
- Some al-Burhan and al-Kafi blocks carry a grading (for example `ضعيف`) inside
  the text that the draft does not surface; the `grades` field is filled only for
  hadith-corpus hits. Decide whether weak-graded narrations should be included or
  labelled.
- Hadith corpus search is noisy: 261 of 275 raw hits across the five passages were
  dropped for not quoting the verse. The filter kept 4 to 6 real hits per passage.
- Rewrites re-read the whole packet. A targeted rewrite mode (failing targets plus
  their blocks only) would cut rewrite cost by most of its 235K tokens.
- Polemical narrations appear where the sources carry them (2:4 n7 on the pulpit,
  2:2 on Ghadir). Editorial policy on these is a reader decision, not a rule.
