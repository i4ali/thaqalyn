# Passage Pilot Runbook - al-Baqarah 2:1 to 2:5

Gate to batch: all five pass audit with a mean of at most 1.5 attempts, and you are
happy with the drafts as a reader.

The whole loop below is packaged as the `/passages` skill
(`.claude/skills/passages/SKILL.md`): `/passages 2:6-2:10`, `/passages 36`, or
`/passages next 2 --surah 2`.

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

## Results - al-Fatiha 1:1 (2026-09-05)

Surah 1 is a single passage covering all seven verses. Procedure followed as
written; one rewrite was needed.

| passage | stage  | attempts | first try | hours | sources |
|---------|--------|----------|-----------|-------|---------|
| 1:1     | passed | 2        | no        | 0.6   | 66      |

Agent runs: writer 218K tokens, 15 min; audit 1 162K tokens, 7 min, FAIL (31 of
32 supported, 1 stretched); rewrite 171K tokens, 4.5 min; audit 2 192K tokens,
7 min, PASS (32 of 32). About 740K tokens in all.

Why it failed once: the verse 7 note joined two of Tusi's identifications under
one attribution, "all the commentators, Shia and Sunni, take those under wrath to
be the Jews and the astray the Christians". The block attaches the consensus
formula to the Jews only and grounds the Christians identification on a verse
and a report from the Prophet. The rewrite split the sentence. Rule for the
writer prompt: when a block grounds two claims differently, do not join them
under one attribution.

Findings:

- Gather quirk: altafsir's al-Tibyan pages for al-Fatiha carry the verse header
  of N but the commentary of N+1 (the block labelled verse 1 discusses "al-hamdu
  lillah", the one labelled 3 discusses the malik/maalik readings). Both agents
  worked from content, which is right, but the labels can mislead. Probably
  specific to al-Fatiha, where Tusi treats the basmala as verse 1.
- Unavailable on altafsir for this surah: Tafsir al-Qummi on verses 1 to 4 and
  7, Furat on 1 to 5, al-Razi on verse 1. Qummi and Furat still contributed
  through al-Safi and al-Burhan quotations.
- The first draft rendered Tusi's "al-khass wa al-amm" literally as "the
  particular and the general". The rewrite prompt asked for "Shia and Sunni".
  Worth adding to the writer prompt's naming rules.
- One al-Kafi narration (verse 7, n16) opens its chain with a dangling "from
  him", copied verbatim from the block. Policy: resolve the pronoun from the
  block's previous chain or drop the first link.
- Provenance the draft does not surface: the verse 5 narration (n10) is
  introduced by al-Safi as "a report through the Sunni route from al-Sadiq"
  (wa fi riwaya ammiyya); the verse 4 al-Kafi narration (n9) carries a weak
  grading. Both auditors recorded these as notes, not verdicts. Decide whether
  such qualifiers should appear in the app.
- The Qummi narration on verse 7 renders "al-nussab" as "those hostile to the
  Ahl al-Bayt", following the packet's own gloss. Decide whether to say
  "the Nasibis" plainly.
- Speaker names in this passage: the Prophet, Amir al-Muminin, Imam al-Sadiq,
  Imam Ali ibn al-Husayn. Consistent within the passage; the cross-passage
  house list is still open.
- Procedure gap: `titles --apply` does not record approval. When the user
  approves the generated titles, the orchestrator must set `approved: true` in
  `passages_work/S/titles.json` before `--apply` and `assemble`.

## Results - al-Baqarah 2:6 (2026-09-05)

Verses 47 to 59, run via `/passages next surah baqarah passage`. Procedure
followed as written; one rewrite was needed.

```
passage  stage     attempts  first  hours  sources
2:6      passed           2  False    0.5      103

6 passed, first-try 3/6, mean attempts 1.8
```

| id | essay words | verse entries | narrations | sources | perspectives words |
|---|---|---|---|---|---|
| 2:6 | 409 | 6 | 8 | 24 | 106 |

Output: `Thaqalayn/Thaqalayn/Data/passages_2.json`, 194 KB, six passages.

Agent runs: writer 255K tokens, 10 min; audit 1 244K tokens, 6 min, FAIL (27 of
28 supported, 1 stretched); rewrite 255K tokens, 5 min; audit 2 245K tokens,
6 min, PASS (28 of 28). About 1.0M tokens in all.

Why it failed once: the essay credited Tabrisi with the "summary then detail"
answer to why the reminder is repeated. In Majma al-Bayan that answer is one of
two reported views (`wa-qila aydan`); Tabrisi's own answer (`qulna`) is that the
blessings are the root of the gratitude owed, so the reminder needed
reinforcing. The same summary-then-detail point is al-Tusi's own in al-Tibyan,
so the rewrite gave Tabrisi his real answer and moved the other to al-Tusi.
Same failure class as 2:4 and 1:1: a reported view handed to the author.

Findings:

- Gather: Furat empty for the whole range, Tafsir al-Qummi missing on 50, 52,
  53, 56, 58, 59. Al-Mizan came as two large blocks for the thirteen verses,
  which was enough. 74 hadith corpus hits dropped, one kept (Kitab al-Ghayba,
  the Prophet's "gate of hitta" saying in the Khayf sermon).
- Coverage thin spot: verses 54 to 56 are one summary clause in the essay, and
  verse 55 (the demand to see God, the thunderbolt) gets no treatment anywhere,
  though four blocks were available for it. Not a rule failure; a note for the
  writer prompt's coverage guidance.
- The essay says "the four denials of the second verse" for verse 48. Readers
  see verse numbers, not positions; the prompt should ask for verse numbers.
- Speaker names still drift across passages: the Prophet is "The Messenger of
  God" here, "The Prophet" in 2:2, "the Messenger of God" in 2:3, "The Prophet
  Muhammad" in 2:4. House list still open.
- Three narrations carry no chain because al-Burhan gives none past the
  attribution (two to al-Askari, one to al-Sadiq). The auditor accepted this.
- Auditor process note: `audit-check` keys targets by marker number, one
  verdict per unique marker even when cited twice. The second auditor's first
  file used ordinals and was rejected as malformed, then corrected.
- Polemical narrations present where al-Burhan carries them: "Children of
  Israel are us in particular" and the Prophet's "my name is Israil" on 47,
  "we and our family requite for our Shia" on 48, the likeness of Muhammad and
  Ali at the gate on 58. Reader decision, as before.

## Results - al-Baqarah 2:7 to 2:40 (2026-09-06)

The rest of the surah, run overnight via `/passages next surah baqarah passage
/loop`. Procedure followed as written, with the deviations listed below. All 34
passages passed; none parked. Wall clock about ten hours (21:38 to 07:24),
106 agent runs (34 writers, 53 audits, 19 rewrites), about 17.3M agent tokens
and 12.8 agent-hours. Median cost per passage about 500K tokens; the largest
(2:25, fourteen verses, 126 blocks) 660K.

```
passage  stage     attempts  first  hours  sources
2:7      passed           2  False    0.4       18
2:8      passed           3  False    0.6       59
2:9      passed           2  False    0.9       80
2:10     passed           1   True    0.9       32
2:11     passed           1   True    1.2       82
2:12     passed           2  False    1.4       55
2:13     passed           2  False    1.7       66
2:14     passed           1   True    0.8       76
2:15     passed           1   True    0.3       62
2:16     passed           1   True    0.3       95
2:17     passed           2  False    1.6       52
2:18     passed           1   True    1.4       43
2:19     passed           1   True    2.5       85
2:20     passed           1   True    2.6       29
2:21     passed           2  False    2.9       71
2:22     passed           1   True    2.9       57
2:23     passed           3  False    3.5       64
2:24     passed           2  False    2.7       72
2:25     passed           1   True    3.8      126
2:26     passed           1   True    3.0       55
2:27     passed           2  False    4.0       43
2:28     passed           2  False    3.6       66
2:29     passed           2  False    4.3       30
2:30     passed           1   True    4.4       43
2:31     passed           2  False    4.2       58
2:32     passed           1   True    4.1       56
2:33     passed           2  False    5.1       47
2:34     passed           1   True    5.0       39
2:35     passed           1   True    5.3       29
2:36     passed           2  False    5.4       47
2:37     passed           2  False    5.2       61
2:38     passed           1   True    5.3       60
2:39     passed           2  False    6.0       21
2:40     passed           1   True    6.0       29

40 passed, first-try 20/40, mean attempts 1.6
```

Output: `Thaqalayn/Thaqalayn/Data/passages_2.json`, 1.2 MB, forty passages.
Across the 34 new passages: 10,267 essay words, 201 verse entries, 347
narrations, 711 cited source blocks, 3,447 words of perspectives.

### Why passages failed (19 rewrites, 2 passages needed two)

Attribution is still the dominant class. Twelve of the 21 stretched verdicts
put a reported view in the author's mouth: Razi's "most literalist exegetes"
widened to "most exegetes" (2:7); Tabrisi "takes" one of four referents he
lists with `أو` (2:8); al-Suddi's report credited to Qurtubi (2:9); a `وقيل`
view given to Tabrisi (2:13); three glosses Majma reports from al-Suddi,
Qatada and two `قيل` credited to Tabrisi (2:21); "or season" imported from
Majma into an al-Tibyan citation (2:23); a `قيل` occasion from Abd al-Rahman
ibn Zayd stated flatly as Majma's (2:31); Abu Muslim's account relayed by
Razi given to Razi (2:33); al-Kalbi's kin report folded into a three-name
occasion (2:37); al-Rabi and al-Suddi's "in the way of Allah" narrowed to
"jihad" (2:36); "answers that reproach" tying 194 to the wrong occasion
(2:24); "explains that" where al-Tibyan gives `يحتمل امرين` (2:8, second
fail). Add the modality class: "among them" placing a `مع كون` observation
inside Tabatabai's seven points (2:23, second fail); "barely a row" for "a row
or two" (2:31); the fear put in the raiders' own mouths where Majma says
`فظن قوم` (2:27).

New this run, the rendering class: English that omits or adds against its own
Arabic field. 2:28's n4 dropped the limiting clause `ولم يعن في أدبارهن`,
widening a ruling; 2:27's n6 carried a closing clause absent from its Arabic;
2:36's n8 imported "small" from a parallel block; 2:39's n1 narrowed `جاز
أمره` to property. The auditor checks text against text, so an English
rendering must stay inside the quoted span.

Uncited claims (5): occasion-of-revelation sentences carrying no marker
(2:12, 2:13, 2:17, 2:31) and one sentence naming four authorities whose marker
sat on the next line (2:29). 2:17's was carried only by Sunni blocks, so it had
to be reworded to the verse's own terms rather than cited.

Two passages went to a third audit (2:8, 2:23). In both, the second auditor
failed a line the first had explicitly passed. Auditor strictness varies, as
the pilot warned; budget one extra audit per ten passages for it.

### Deviations from the procedure

- Gathering ran as one detached sequential chain for 2:8 to 2:40 (about 70
  minutes) instead of per-passage. Two passages (2:15, 2:16) failed on
  altafsir curl timeouts and were re-gathered; ten had al-Burhan empty on one
  to three verses and were re-gathered once each. Every retry returned the
  identical block set, so those are genuine gaps on altafsir, not transient.
- Title approval was taken once for the whole surah at the end, per the
  per-surah step, rather than per batch. `titles --apply` still does not
  record approval; the orchestrator set `approved: true` on all 34 by script.
- Rewrite prompts carried the auditor's minor notes (chain heads, a dropped
  word, paragraph breaks) alongside the failing target when the fix was cheap.
  Every such pass kept the supported material byte-identical, and no second
  audit failed on a tidy-up.
- The 2:6 content and runbook entry from the previous session were still
  uncommitted; they are folded into this run's commits.

### Reader notes (taste and policy, not rule failures)

- Speaker names are the loudest problem and are now urgent for the writer
  prompt. Across 34 passages the Prophet appears as "the Prophet", "The
  Prophet", "the Prophet Muhammad", "The Prophet Muhammad", "Prophet
  Muhammad", "the Messenger of God" and "the Messenger of Allah". Ali is
  "Imam Ali", "Amir al-Muminin" and "Ali ibn Abi Talib", sometimes two in one
  passage (2:22, 2:17). Al-Sajjad is "Imam al-Sajjad", "Imam Ali ibn
  al-Husayn" and "Ali ibn al-Husayn". Al-Kazim is "Imam al-Kazim", "Imam
  Musa ibn Jafar" and "Abu al-Hasan"; al-Jawad "Imam al-Jawad", "Abu Jafar
  al-Thani", "Imam Abu Jafar the Second" and "Imam Abu Jafar". 2:13 copied
  Tafsir al-Imam's patronymic frames verbatim ("Ali ibn Muhammad ibn Ali ibn
  Musa al-Rida"). Unresolved kunyas ("Abu al-Hasan", "Abu Jafar") appear as
  speakers in eight passages. A house list of the fourteen plus the Prophet,
  with the kunya-to-name map, belongs in the writer prompt's naming rule.
- Non-Imam speakers in narration slots: Ibn Abbas (2:9, 2:33, 2:38), Zayd ibn
  Ali (2:33), and once a compiler's own gloss, "Ali ibn Ibrahim" (2:30). Decide
  whether companions belong in narrations and whether compiler glosses must be
  notes.
- Sunni reports inside narrations: al-Zamakhshari's Rabi al-Abrar via Ibn
  Umar (2:33) reached a narration slot because al-Burhan quotes it. The rule
  keys on the citing block's tradition, not the report's origin.
- Essay paragraphing: six essays arrived as one unbroken paragraph (2:23,
  2:26, 2:27, 2:28, 2:29, 2:33); the rewrites added breaks without changing
  words where a rewrite happened anyway, but 2:26 stands as one block. The
  writer prompt should require three to five paragraphs; the validator could
  check for at least one blank line.
- Two drafts (2:19, 2:30) use curly quotes where every other draft uses
  straight; the validator does not normalise punctuation.
- Word ceilings: writers twice reported essays over the stated 250 ceiling
  (254, 257) that the validator accepted. The validator's count and the
  prompt's stated budget differ; align them.
- Coverage thin spots the auditors kept naming: the Throne Verse gets one
  paragraph on al-Qayyum (2:34); 264 to 266 are one descriptive sentence
  (2:36); 192 and 193 have no prose of their own (2:24); 145 to 147 one
  sentence (2:17); the last three verses of most long passages are compressed.
  Not rule failures, but the prompt's coverage guidance could ask for at least
  one sentence per verse.
- Polemical narrations are present wherever al-Burhan, al-Safi, Furat and
  Tafsir al-Imam carry them, and in the second half of the surah they sharpen:
  Ali fighting the companions at the Camel and Basra as "those who
  disbelieved" (2:33, three narrations plus perspectives); the warning of
  2:264 "revealed about Uthman and ran on in Muawiya" against Qurtubi's Uthman
  (2:36); "no one is upon the creed of Abraham except us and our Shia" (2:16);
  the river as the allegiance of Ali (2:33); the stones that fall when adjured
  by the five (2:9); the mubahala-style "put to death the liar among us and
  among our opponents" (2:11). Nine passages lean on Tafsir al-Imam al-Askari
  for a third or more of their narrations (2:9 has eight of thirteen). The
  editorial policy question from the pilot is now the main open decision for
  the app.
- Textual-variant claims carried by al-Qummi surface in 2:31 (the Imam
  reciting "the middle prayer, the afternoon prayer") and 2:11 (Jibril's
  reading "concerning Ali"). Both are cited and hedged after rewrite; decide
  how the app presents them.
- Gradings still unsurfaced: al-Kafi's `ضعيف` on 2:10 n5 and 2:11 n5 were
  noted by auditors and appear nowhere in the drafts.
- Two writers hit shadda-before-vowel ordering in altafsir text that broke the
  verbatim check (2:17, 2:35); both repaired by copying spans byte for byte.
  A normalising comparison in the validator would remove the trap.
- Gather filing quirks: an al-Safi block indexed under 282 comments on 279 to
  281 (2:39); s21 under 170 glosses 171 (2:21). Same class as the al-Fatiha
  off-by-one.
- Perspectives were genuine differences in 31 of 34 passages. The thin ones:
  2:23 (only the name of the man in the occasion), 2:39 (Tusi and Ibn Kathir
  largely agree), 2:25 (Qurtubi agrees with the Shia reading on 207). One
  perspectives section (2:20) opened "The blocks part over ...", leaking
  pipeline jargon into reader text.

## Results - Al Imran 3:1 to 3:20 (2026-09-06)

The whole surah, run via `/passages surah 3 /loop`. Procedure followed as
written, with the deviations listed below. All 20 passages passed; none
parked. Wall clock about five hours (07:31 to 12:26), 70 agent runs (20
writers, 35 audits, 15 rewrites), about 13.8M agent tokens and 9.0
agent-hours. Mean cost per passage about 690K tokens; the cheapest first-try
passages (3:15, 3:16) about 320K, the dearest (3:8, three audits and two
rewrites) about 1.5M.

```
passage  stage     attempts  first  hours  sources
3:1      passed           1   True    0.3       57
3:2      passed           2  False    0.6       88
3:3      passed           1   True    0.4       71
3:4      passed           1   True    0.9       88
3:5      passed           1   True    0.6       79
3:6      passed           3  False    1.3       52
3:7      passed           2  False    1.3       63
3:8      passed           3  False    2.0       72
3:9      passed           3  False    2.1       62
3:10     passed           3  False    2.6       67
3:11     passed           3  False    2.9       55
3:12     passed           1   True    2.9       64
3:13     passed           2  False    3.3       53
3:14     passed           2  False    3.3       85
3:15     passed           1   True    3.5       39
3:16     passed           1   True    3.6       52
3:17     passed           1   True    3.8      101
3:18     passed           2  False    3.9       63
3:19     passed           1   True    4.1       72
3:20     passed           1   True    4.1       63

20 passed, first-try 10/20, mean attempts 1.8
```

Output: `Thaqalayn/Thaqalayn/Data/passages_3.json`, 656 KB, twenty passages.
Across the surah: 7,421 essay words, 142 verse entries, 189 narrations, 444
cited source blocks, 2,087 words of perspectives. (Counted on whitespace
after stripping markers; the validator's count runs a few words lower on
essays that join words with punctuation, so 3:3, 3:8, 3:10 and 3:13 show 403
to 414 here against the validator's 397 to 400.)

| id | essay words | verse entries | narrations | sources | perspectives words |
|---|---|---|---|---|---|
| 3:1 | 367 | 7 | 10 | 22 | 102 |
| 3:2 | 399 | 9 | 11 | 23 | 91 |
| 3:3 | 409 | 7 | 8 | 25 | 92 |
| 3:4 | 382 | 9 | 14 | 29 | 102 |
| 3:5 | 370 | 10 | 10 | 21 | 117 |
| 3:6 | 350 | 4 | 7 | 19 | 103 |
| 3:7 | 379 | 6 | 7 | 21 | 112 |
| 3:8 | 414 | 9 | 12 | 27 | 94 |
| 3:9 | 397 | 6 | 7 | 21 | 105 |
| 3:10 | 412 | 7 | 9 | 26 | 102 |
| 3:11 | 398 | 5 | 12 | 22 | 115 |
| 3:12 | 400 | 5 | 6 | 22 | 103 |
| 3:13 | 403 | 6 | 10 | 23 | 115 |
| 3:14 | 368 | 9 | 10 | 22 | 100 |
| 3:15 | 256 | 5 | 7 | 15 | 100 |
| 3:16 | 234 | 7 | 7 | 20 | 103 |
| 3:17 | 399 | 11 | 11 | 27 | 119 |
| 3:18 | 375 | 6 | 6 | 16 | 101 |
| 3:19 | 359 | 8 | 17 | 21 | 105 |
| 3:20 | 350 | 6 | 8 | 22 | 106 |

### Why passages failed (15 rewrites across 10 passages, 16 findings)

Attribution again leads, six findings: a `qila` observation in al-Safi
credited to Fayd (3:7); a gloss al-Tibyan gives to al-Hasan and other
exegetes credited to Tusi (3:7); a `qila` occasion in Majma credited to
Tabrisi (3:8); a gloss al-Tibyan gives to Mujahid, Qatada, Ibn Jurayj and
al-Rabi folded into Tusi's own sentence (3:8); the first of two `qila`
readings made al-Tusi's own (3:9); and one "since" clause giving al-Jubbai's
reason to al-Balkhi, whose stated reason differs (3:11, the joined-reasons
subtype first seen in 1:1).

New this run, the scope class, four findings: a claim hung on the wrong
block (3:2, the who-saw-whom dispute sits in al-Tibyan, not the Majma block
cited); an occasion applied to six verses where Majma limits it to four
(3:9); a "what is to be spent" gloss listed among Majma's views on what
`birr` means, because the excerpt ellipsized across the next lemma (3:10);
and Qurtubi's ikhtilaf point, which sits under 3:103, hung on 3:105 (3:11).

Substance and modality, three findings: Qatada's "two clear signs" rendered
as both "left standing" when his point is that the Prophet has passed and
only the Book remains (3:10); "asked for a day like Badr" imported from
uncited Sunni blocks where the cited Majma has men who missed Badr longing
for martyrdom (3:14); "turned back" for an intention Majma reports only as
talk (3:18). Rendering, one: a narration's English opening a clause before
its Arabic (3:6). Uncited, two: both perspectives openers of the form "Both
traditions place the verse at ..." with no marker (3:6, 3:13); the blocks
were cited in the next sentence each time.

Five passages went to a third audit (3:6, 3:8, 3:9, 3:10, 3:11), and in
every one the second auditor failed a line the first had explicitly passed.
All five passed on the third. That is two and a half extra audits per ten
passages, against the one per ten the al-Baqarah run budgeted; strictness
variance is the largest single cost in the loop now.

### Deviations from the procedure

- Gathering ran as one detached chain for all twenty (07:31 to 08:06, no
  errors). Al-Mizan was present for every verse. Al-Burhan was empty on one
  to six verses in fourteen passages; 3:3, 3:5 and 3:6 were re-gathered once
  and returned identical block sets, so the remaining gaps were not retried.
  Furat was empty for most of the surah; Tafsir al-Qummi missing on scattered
  verses.
- Rewrite prompts carried the auditor's minor notes as tidy-ups when cheap
  (a missing chain, a rendering that added a demonstrative or a pronoun
  shift, a reciter disambiguated from an exegete of the same name). No second
  audit failed on a tidy-up, and none of the tidy-ups introduced a new
  finding.
- The 3:17 writer built `draft.json` with a scratchpad script instead of the
  Write tool, so the write hook did not run; the writer invoked the validator
  itself and the orchestrator validated again before audit.
- Title approval was taken once for the surah at the end. `titles --apply`
  still does not record approval; the orchestrator set `approved: true` on
  all twenty by script after the user approved the table.

### Reader notes (taste and policy, not rule failures)

- Name drift is unchanged and now spans scholars as well as speakers. The
  Prophet appears as "the Prophet", "The Prophet", "Prophet Muhammad" and
  "the Messenger of God"; al-Kazim as "Imam Musa ibn Jafar" (3:1, 3:20),
  "Musa ibn Jafar" (3:4) and "Imam al-Kazim" (3:5); al-Sajjad as "Ali ibn
  al-Husayn" (3:3), "Imam al-Sajjad" (3:11) and "Imam Ali ibn al-Husayn"
  (3:14, 3:19); an unresolved kunya "Abu al-Hasan" as speaker in 3:13.
  Scholars are "al-Tusi" and "al-Tabrisi" in 3:1 to 3:4 and 3:9, "Tusi" and
  "Tabrisi" from 3:5 on, sometimes both forms inside one essay (3:13); Fayd
  is "Fayd Kashani" in 3:1 and 3:5 and "Fayd" in 3:7; "Qatada" and "Qatadah"
  both occur. A house list for speakers and a spelling list for the seven
  named commentators belong in the writer prompt.
- Non-Imam speakers in narration slots are frequent: the compiler gloss "Ali
  ibn Ibrahim" in 3:5, 3:8 (four of twelve), 3:13, 3:15, 3:19 (three); the
  Companions Ibn Abbas (3:2, 3:16), Ibn Masud (3:16), Hudhayfa (3:15), Abu
  Rafi (3:18), Ubayy ibn Kab (3:11); and one compound speaker "Imam
  al-Husayn and Imam al-Sadiq" for a story about them giving sugar (3:10).
  Several "narrations" are third-person narratives about the speaker rather
  than his words (3:2 n1, 3:14 n4).
- Two writers exercised editorial judgment on polemic and said so: 3:11
  trimmed Ubayy ibn Kab's rebuke at Abu Bakr's sermon to its interpretive
  core; 3:18 left out an al-Burhan report on 178 about the Prophet's
  daughters as "off-verse polemic". Everywhere else the polemic is present
  where the sources carry it, and in this surah it is sharp: "people of
  apostasy after the Prophet except three" (3:15), Ali as the cord of God
  and the rope from the people (3:11, 3:12), "the way of Allah is Ali and
  his progeny" (3:17), the Umayyads taking the sovereignty (3:3), al-Sadiq
  cursing the Murjia beside Qurtubi's al-Shabi on Uthman's killing (3:19),
  the Prophet "eager for Ali to hold the affair after him" on 3:128 (3:13),
  and perspectives that set Abu Bakr against Ali as "the grateful" (3:15)
  and as those consulted (3:17). The editorial policy decision is now
  overdue.
- Textual-variant claims are more frequent than in al-Baqarah: "the progeny
  of Muhammad" with "a letter put in place of a letter" (3:4), "let there be
  among you imams" (3:11), "you were the best imams" with "in the reading of
  Ali" (3:12), and two narrations on one verse rejecting "abased" for "weak"
  and "few" (3:13). Raj'a narrations appear in 3:9, 3:17 and 3:19. Both
  classes are cited correctly; how the app presents them is the same open
  decision as before.
- Pipeline jargon leaked into perspectives twice: "The Shia blocks press
  further" (3:6) and "The Shia blocks read it forward" (3:15). Qarai's
  square-bracket insertions were copied into essay quotes ("I shall take
  you[r soul]", "the best nation [ever]"). Curly quotes in 3:1, 3:9, 3:15 and
  3:20 against straight quotes elsewhere; 3:4 mixes both in one essay.
- Chains open with a dangling "his father" (the compiler's) in 3:4 (three
  narrations), 3:14 and 3:20, the pronoun problem from 1:1; several chains
  are abridged at the head (3:6, 3:8, 3:10, 3:19, 3:20), which auditors noted
  but accepted.
- Coverage thin spots the auditors kept naming: verse 60 skipped in 3:6
  though four blocks treat it; 87 and 88 never narrated in 3:9; 76 skipped
  in 3:8; 136, 138 and 142 skipped in 3:14; 177 not addressed in 3:18; the
  last two or three verses of most long passages compressed into a clause.
  Same recommendation as before: one sentence per verse in the writer prompt.
- Perspectives were genuine differences in all twenty. The mildest: 3:6
  (both agree on the Najran mubahala; the difference is the inference) and
  3:14 (the same riposte from three mouths).
- Essays that read best as a reader: 3:5, 3:12, 3:14, 3:19. The 3:17 title
  is the first with a colon.
- Auditor notes worth a policy line: an al-Mizan hedge (`la'alla`) stated
  flatly (3:18); a compilation said to "take" a position its narrations
  carry (3:15); Arabic fields longer than the English renders in three
  narrations of 3:19, visible if the app shows both side by side.

## Results - an-Nisa 4:1 to 4:24 (2026-09-06)

The whole surah, run via `/passages surah 4 passage 1 /loop until surah
complete`. Procedure followed as written, with the deviations listed below.
All 24 passages passed; none parked. Wall clock about five and a half hours
(12:47 to 18:13), 82 agent runs (24 writers, 41 audits, 17 rewrites), about
14.6M agent tokens and 10 agent-hours. Mean cost per passage about 605K
tokens; the cheapest first-try passages (4:15, 4:24) about 275K, the dearest
(4:1, three audits and two rewrites) about 1.6M, then 4:22 and 4:11 at about
1.1M each.

```
passage  stage     attempts  first  hours  sources
4:1      passed           3  False    0.8       99
4:2      passed           1   True    0.3       34
4:3      passed           2  False    0.7       62
4:4      passed           2  False    1.1       36
4:5      passed           1   True    1.1       61
4:6      passed           2  False    1.6       77
4:7      passed           1   True    1.4       63
4:8      passed           1   True    1.7       80
4:9      passed           2  False    2.1       73
4:10     passed           2  False    2.0       38
4:11     passed           2  False    2.5      111
4:12     passed           2  False    2.6       31
4:13     passed           1   True    2.8       41
4:14     passed           2  False    2.9       28
4:15     passed           1   True    3.1       34
4:16     passed           1   True    3.1       42
4:17     passed           2  False    3.6       30
4:18     passed           2  False    3.4       63
4:19     passed           2  False    4.1       44
4:20     passed           2  False    4.0       54
4:21     passed           1   True    4.2       68
4:22     passed           3  False    4.6       64
4:23     passed           2  False    4.7       58
4:24     passed           1   True    4.9       41

24 passed, first-try 9/24, mean attempts 1.7
```

Output: `Thaqalayn/Thaqalayn/Data/passages_4.json`, 764 KB, twenty-four
passages. Across the surah: 7,719 essay words, 140 verse entries, 236
narrations, 501 cited source blocks, 2,463 words of perspectives (whitespace
count after stripping markers, as before).

| id | essay words | verse entries | narrations | sources | perspectives words |
|---|---|---|---|---|---|
| 4:1 | 389 | 8 | 17 | 28 | 109 |
| 4:2 | 249 | 4 | 8 | 13 | 100 |
| 4:3 | 346 | 8 | 14 | 24 | 86 |
| 4:4 | 237 | 3 | 9 | 17 | 101 |
| 4:5 | 363 | 5 | 11 | 22 | 113 |
| 4:6 | 396 | 6 | 13 | 30 | 106 |
| 4:7 | 350 | 6 | 10 | 26 | 82 |
| 4:8 | 394 | 8 | 11 | 26 | 106 |
| 4:9 | 387 | 7 | 15 | 26 | 99 |
| 4:10 | 246 | 5 | 8 | 17 | 104 |
| 4:11 | 362 | 8 | 13 | 30 | 93 |
| 4:12 | 244 | 4 | 5 | 13 | 109 |
| 4:13 | 238 | 5 | 10 | 19 | 95 |
| 4:14 | 248 | 4 | 8 | 13 | 110 |
| 4:15 | 248 | 4 | 8 | 15 | 94 |
| 4:16 | 365 | 5 | 5 | 17 | 98 |
| 4:17 | 241 | 3 | 7 | 14 | 115 |
| 4:18 | 394 | 7 | 12 | 25 | 94 |
| 4:19 | 400 | 7 | 10 | 18 | 101 |
| 4:20 | 247 | 7 | 10 | 20 | 120 |
| 4:21 | 389 | 5 | 8 | 21 | 109 |
| 4:22 | 361 | 9 | 9 | 21 | 111 |
| 4:23 | 383 | 7 | 8 | 23 | 102 |
| 4:24 | 242 | 5 | 7 | 23 | 106 |

### Why passages failed (17 rewrites across 15 passages, 17 findings)

Attribution again leads, eight findings: Abu Ali al-Farisi's second
construction of the accusative "al-arham" credited to Tabrisi (4:1); the
confinement of 4:7 to parents and children, which al-Razi reports as his
companions' reply, credited to al-Razi (4:1, second audit); the third of
three `qila` glosses of "grace and mercy" made Tabrisi's own (4:17); a `qala
qawm` reading from Aisha, Qatadah and al-Suddi presented as al-Tusi's own
addition (4:19); a ruling "many scholars" derive, which Ibn Kathir only rates
the sounder view, credited to Ibn Kathir (4:20); the joined-reasons subtype
twice, al-Tusi's ground for preferring al-Zajjaj's "hypocrites" reading hung
on al-Zajjaj (4:6) and Abu Ali's denial merged into al-Tusi's lutf gloss
(4:9); and a new subtype, blended adjacent reports, the question framing of
Samaa's al-Sadiq report attached to Humran's al-Baqir "We are those" from the
same block (4:10).

Scope, two: Tabrisi's "at the contract" qualifier attached to al-Tusi's
block (4:3); Majma's reason for the partitive "min" ("no servant can perform
them all") hung on the al-Tibyan citation (4:18).

Modality, three: the ill-omen reading of "from you" stated as the meaning
where al-Tibyan reports two views (4:11); the writer's "not hesitation but
favour" given to al-Tusi, who glosses `asa` with `la'alla` (4:14); al-Tusi's
epistemic hedge on lutf ("of whose state it is not known") stated as fact in
the essay while the draft's own source gloss had it right (4:23).

Collective claims, two: an unmarked "the Sunni commentators anchor the clause
in one event" where al-Tabari reports disagreement and al-Razi gives no
occasion (4:4); "the Shia commentators take the other report" where Tabrisi
and al-Tusi list the Uhud account too (4:12). The second exposed a
perspectives paragraph built on a difference the blocks did not carry; the
rewrite re-anchored it on how each side ranks the two reports it holds.

Substance, one: Furat's likeness reports ("in you there is a likeness of
Jesus") written as if the pronoun of "his death" were turned toward Ali
(4:22). Rendering, one: a narration's English opening a framing clause before
its Arabic and quoting a shortened al-Baqara 7 unlabelled (4:22, second
audit).

Two passages went to a third audit (4:1, 4:22), both because the second
auditor failed a line the first had explicitly passed; both passed on the
third. That is one extra audit per twelve passages, against two and a half
per ten in Al Imran. Strictness variance is smaller this run but not gone.

### Deviations from the procedure

- 4:1 was gathered alone (12:47 to 12:49) so its writer could start; 4:2 to
  4:24 ran as one detached chain (12:50 to 13:20, no errors). Al-Mizan was
  present on every verse. Al-Burhan was empty on scattered verses in twelve
  passages; 4:18, 4:21 and 4:22 were re-gathered once and returned identical
  block sets. Furat was empty almost everywhere; Tafsir al-Qummi missing on
  scattered verses. Block counts ran from 28 (4:14) to 111 (4:11).
- Rewrite prompts carried the auditor's minor notes as tidy-ups when cheap
  (an addressee corrected to the block in 4:4 and 4:20, compiler framing
  moved out of narration text into the chain field in 4:6, a "the blocks
  part" opener reworded in 4:20). None produced a new finding.
- Eight writers (4:2, 4:3, 4:4, 4:6, 4:13, 4:18, 4:19, 4:22) built
  `draft.json` with a scratchpad script that slices Arabic spans byte-exact
  from the packet, so the write hook did not run; each ran the validator
  itself and the orchestrator validated again before audit. This is now the
  norm rather than the exception: the validate step, not the hook, is the
  gate.
- The 4:1 brief has four single lines of 15k to 44k characters (the Uyun
  letter on the reasons for rulings, a long al-Kafi abrogation hadith) that
  exceed the Read tool's per-call cap; the rewrite writer previewed them with
  `cut`. Worth wrapping or truncating long blocks in `brief`.
- 4:17's writer found two packet blocks keyed to the wrong verse (al-Burhan
  s10 carries 4:105 narrations under 113; Kitab al-Ghayba s30 quotes 4:83)
  and 4:23's packet had an empty Tafsir al-Qummi page (s17); none was cited.
  A check on `gather`'s verse keying is due.
- Title approval was taken once for the surah at the end; the user approved
  all 24 as generated and the orchestrator set `approved: true` by script,
  since `titles --apply` still does not record approval.

### Reader notes (taste and policy, not rule failures)

- Name drift is now inside single passages, not only across them. Al-Kazim
  is "Imam al-Kazim" and "Musa ibn Jafar" in 4:7; "Tabrisi" and "Tabatabai"
  bare beside "al-Tusi" articled in 4:6, 4:7, 4:11 and 4:12. The tenth Imam
  is "Ali ibn Muhammad al-Askari" (4:18) and "Imam al-Hadi" (4:23). The
  unresolved kunya comes three ways: "Abu al-Hasan the First" (4:9, 4:14),
  "Imam Abu al-Hasan" (4:20), "Abu al-Hasan" (4:21). Imam Ali is "Imam Ali"
  (4:2, 4:8, 4:13, 4:17) and "Amir al-Muminin" (4:14, 4:16). The Prophet
  appears five ways: "Prophet Muhammad", "The Prophet Muhammad", "the Prophet
  Muhammad", "the Prophet", "the Messenger of God". Joint reports four ways:
  "Imam al-Baqir or Imam al-Sadiq", "Imam al-Baqir and Imam al-Sadiq", "Imam
  al-Sadiq and Imam al-Baqir", "al-Sadiqayn". "Qatada" and "Qatadah" both
  occur. The house list for speakers and the spelling list for commentators
  are the cheapest fix left in the writer prompt.
- Non-Imam speakers in narration slots: the compiler gloss "Ali ibn Ibrahim"
  (4:9 twice, 4:14 twice, 4:20 three times); the Companion Zayd ibn Thabit
  (4:13); the tabi'i Shahr ibn Hawshab relaying al-Baqir, with the Imam in
  the text and the transmitter in the speaker slot (4:22); al-Mamun's
  courtier Harthama ibn Ayan (4:16); the angel Jibril (4:15); and third-person
  stories about the speaker (Imam al-Hasan and the slave-girl 4:11, the
  Prophet and Salman 4:19).
- Compiler framing inside narration text: "Reported in Majma al-Bayan from
  al-Baqir: ... Reported in Majma al-Bayan from al-Baqir: ..." (4:6, moved
  to the chain field in the rewrite), "Our companions have narrated from the
  two masters al-Baqir and al-Sadiq that ..." (4:9, shipped). A line in the
  writer prompt: the text field carries the words, the chain field the
  framing.
- Polemic: writers applied opposite policies in adjacent passages again.
  4:7's writer dropped al-Qummi's identification of the "self-purifiers" of
  4:49 with the three caliphs and said so. 4:6, 4:9, 4:14, 4:16, 4:17 and
  4:20 carried theirs: "those who usurped the right of the Commander of the
  Faithful" (4:6), "removing the caliphate from its place" and "enmity to
  Ali" (4:9), "those who withdrew from Amir al-Muminin and did not fight with
  him" (4:14), "those who altered it after the Messenger was gone, as the
  Jews and Christians did after Moses and Jesus" (4:16), Imam Ali refusing a
  Ramadan congregation imam and the lizard as al-Ashath's and Jarir's "imam
  on the Day of Resurrection" (4:17), "so-and-so, so-and-so and so-and-so"
  who believed and disbelieved at Ghadir, and Banu Umayya "agreeing not to
  return the affair to Banu Hashim" (4:20). The surah also carries the core
  Imami readings at full strength and correctly sourced: ulu al-amr as the
  Imams with the infallibility argument (4:8, 4:11), the Imams as the
  witnesses of 4:41 (4:6), the Jabir list of twelve caliphs (4:8), "hold to
  Ali; by Allah, he will save you" (4:18), the manifest light as Ali (4:24).
  The editorial policy decision is the largest open item and now blocks
  consistency, not only taste.
- Textual-variant narrations ("thus was it revealed", "Gabriel brought this
  verse down thus") appear in 4:7, 4:9 (two), 4:23 (two) and 4:24. Only 4:7's
  writer framed them, with a note from Muhsini that such reports do not
  prove the Quran deficient; the reader is not told who Muhsini is. Same open
  decision as before; if the app keeps them, the 4:7 note is the model.
- Perspectives were genuine differences in most passages, and several are
  the strongest in the corpus so far: ulu al-amr (4:8), the consensus
  proof-text against the infallible Imams (4:17), the Prophet's istighfar
  and isma (4:16), God's knowledge and essence (4:23), the same Shahr ibn
  Hawshab exchange traced to al-Baqir and to Ibn al-Hanafiyya (4:22). The
  mild kind in 4:4 (Awtas captives on both sides), 4:10 (three uses of one
  verse), 4:19 (which occasion leads), 4:21 (the Shia add an application).
  4:8 and 4:11 took the same axis in consecutive passages. The unmarked
  opener "Both traditions ..." or "The two traditions ..." occurs in 4:12
  (failed), 4:14, 4:15, 4:19 and 4:21 (passed): auditors are inconsistent on
  it, so the writer prompt should forbid it outright. Pipeline jargon leaked
  once ("The blocks part", 4:20, fixed in the rewrite).
- Coverage thin spots the auditors kept naming: verses carried nowhere in
  their passage, 45 (4:7), 121 (4:18), 161 (4:22); verses in the entries but
  skipped by the essay, 42 (4:6), 70 (4:9), 79 (4:11), 134 (4:19), 151 and
  152 (4:21, the passage's turn from threat to reward), 175 (4:24). Essays
  are short for long passages (4:11, 362 words for eleven verses; 4:20, 247
  for seven; 4:21 stops at 150). The one-sentence-per-verse rule is still the
  recommendation, and the four-verse passages (4:12, 4:14, 4:15) were the
  ones where every verse got an entry.
- Gradings inside al-Kafi blocks (`da'if`) went unsurfaced in 4:6 (s77) and
  4:22 (n9), as in earlier runs.
- "Qarai's oppressed renders mustad'afin" in a 4:14 note is the same house
  form as 2:15 and `passages_2.json`; keep or drop as policy, but it names
  the translator to the reader.
- Narrations abridged with "..." inside the English are frequent (4:13
  three, 4:17 five of seven, 4:18 two, 4:11 three); the lizard report in
  4:17 is three fragments joined. Curly quotes in 4:2 only.
- Essays that read best as a reader: 4:8, 4:16, 4:19, 4:22, 4:3. 4:12, 4:14,
  4:15 and 4:24 are single unbroken paragraphs.
- Auditor notes worth a policy line: "Tabrisi answers" for a reply Majma
  gives as "our companions answered" (4:24, passed because he continues in
  the first person); a Kafi block's preamble "my father wrote in his letter
  to me" that may make the words the father's, passed on the chain test
  (4:20); a Shia block cited inside perspectives (4:12, 4:14), which the
  house rule does not bar.

## 2026-09-08: model pin and prose gate

- Passage 2:3 shipped the sentence "Tusi notes that a sky without pillars and
  an earth without support could be the work of nothing created [14]". The
  block (al-Tibyan, s14) says a created thing has no power over the like of
  that: the claim was supported, the English inverted the negation, and the
  audit passed it because it rules on support only.
- `passage-writer` and `passage-auditor` moved from `model: opus` (which
  resolved to Opus 5) to `model: claude-opus-4-8`. Surahs 1 to 4 were written
  under the alias; results from surah 5 on are Opus 4.8. Re-measure the cost
  lines in the skill on the first three passages of surah 5.
- The auditor now also lists `prose` flags (`where`, verbatim `sentence`,
  `note`): sentences a reader stumbles on or misreads, never style. Prose does
  not fail the audit; `status` shows the passage as `polish` and the new
  `passage-polisher` agent rewrites only the flagged sentences, keeping every
  marker, so the existing audit still covers the draft. `assemble` will not
  take a passage with an outstanding flag. A flag resolves itself once its
  sentence is no longer in the draft (`scripts/passage_pipeline/prose.py`).
- Sweep procedure for passages that passed before the gate existed (surahs 1
  to 4), kept here and not in the skill, which covers new generation only:
  agent `passage-prose-reader`, prompt `Scan passages S:I S:I ...` with up to
  ten ids per launch, two launches at a time; it reads only `draft.json` and
  writes `passages_work/S/II/prose.json`. Then `passages.py prose --surah S`
  lists every outstanding flag with its note; present that table before
  polishing. Flagged passages show as `polish` in `status`; run
  `passage-polisher` (`Polish passage S:I`) one per passage, read the before
  and after pairs in `polish.json`, and `assemble S` merges the new text. The
  old audit still covers a polished draft because the markers did not move, so
  no re-audit is needed. `prose-check S:I` validates a reader file.
- Dry run of the new loop on 5:1 (al-Maaida 1 to 5, 53 blocks, Furat
  unavailable): writer 220,598 tokens and 16 minutes, auditor 174,085 tokens
  and 6 minutes, both confirmed as `claude-opus-4-8` in the agent transcripts.
  Audit PASS first try, 16 targets supported, no uncited claims, no prose
  flags; `status` shows `passed`. The polish path was exercised by the unit
  tests only; the first real polish will come from the surah 1 to 4 sweep.
  Not titled or assembled yet; it joins the rest of surah 5.
- 5:2 (al-Maaida 6 to 11, 42 blocks; Qummi unavailable for 8 to 10, Furat
  for 6 to 10): writer 172,585 tokens and 16 minutes, auditor 124,384 tokens
  and 6 minutes. Audit PASS first try, 15 verdicts supported (8 markers, 7
  narrations), no uncited claims, no prose flags. Reader notes: verses 8 to
  10 carry no verse entry (the narrations cluster on 6, 7 and 11, and the
  auditor judged coverage complete); the verse 11 note lists three candidate
  attackers against a marker whose shown excerpt names only Banu al-Nadir
  (the auditor ruled the block supports it). Not titled or assembled yet.
- Sweep results, surahs 1 to 4 (85 passages), run 2026-09-08. Reader: nine
  launches of up to ten drafts, 69K to 146K tokens and 4 to 9 minutes each,
  1.12M tokens in all. Flags: surah 1 none, surah 2 five (2:3, 2:17, 2:21,
  2:23, 2:38), surah 3 none, surah 4 two (4:13, 4:17). Kinds caught: an
  inverted negation (2:3), a clause that does not parse (2:17), a garbled
  compression with no antecedent (2:21), an event order reversed against the
  block (2:23), a count that promised three views and gave two (2:38), a
  dangling modifier (4:13), and "others ... others" merging two parties
  (4:17). Nothing flagged was style; the readers named a few dense sentences
  they let pass. Polisher: seven runs, 18K to 34K tokens and about a minute
  each, 208K in all; every passage kept its audit PASS and returned to
  `passed`. The 2:38 fix needed a second turn: the polisher, seeing only the
  gloss, had changed "three views" to "two"; the block does name the third
  (usury by the verse, every debt by analogy), so it was added and the s8
  excerpt extended to carry it. `assemble 2` and `assemble 4` merged the seven
  sentences; the data diff is those lines, the s8 excerpt and gloss, and the
  per-passage timestamps.
- Follow-up outside the sweep: the readers noticed five markers whose shown
  excerpt does not match the sentence carrying it (4:21 [26]; 4:24 [8], [10],
  and perspectives [4]; 4:15 [6]). Checked: the excerpts really are about
  something else. The full block may still support the claim, which is what
  the audit ruled on, but the excerpt the reader sees beside the marker is
  wrong. Needs a sourcing pass, not the polisher.

## Results - al-Maaida 5:1 to 5:3 (2026-09-08)

First passages written and audited on Opus 4.8. Run one passage at a time
(5:1 as the dry run of the prose gate, 5:2 and 5:3 on request), so one slot
was in use at any time. Titles approved as generated; `assemble 5` created
`passages_5.json` with all three.

| passage | verses | blocks | writer | auditor | audit | prose |
|---|---|---|---|---|---|---|
| 5:1 | 1-5 | 53 | 220,598 tok, 16 min | 174,085 tok, 6 min | PASS first try, 16 targets | none |
| 5:2 | 6-11 | 42 | 172,585 tok, 16 min | 124,384 tok, 6 min | PASS first try, 15 targets | none |
| 5:3 | 12-19 | 60 | 189,997 tok, 12 min | 164,099 tok, 5 min | PASS first try, 18 targets | none |

3 passed, first-try 3/3, mean attempts 1.0. Cost lines in the skill updated
to these ranges (writer 170K to 220K, auditor 125K to 175K). Unavailable
works: Furat for every verse of 5:1 to 5:3 except 5:11; Qummi for 5:8 to
5:10, 5:12 and 5:16 to 5:18; al-Burhan for 5:16 to 5:18 (probed directly
after the gather: the site returns empty for those verses, not a fetch
failure).

### Why passages failed

None failed. No rewrite, no polish.

### Deviations from the procedure

- The first gather of 5:3 died on a 45 second altafsir timeout for verse 15
  (curl exit 28). A direct probe of the same URL answered in under a second;
  the retry gathered all 60 blocks. `gather` has no cache and no per-work
  retry, so a transient timeout costs the whole two-minute fetch.
- 5:3 shipped its narration ids per verse (n1 under every verse, n1 and n2
  under 14) where every one of the 87 passages before it numbers them once
  across the passage. The validator did not check this; the app's source
  sheet keys a flattened list of narrations on the id, and audit targets are
  `verses.V.narrations.ID`. Added the rule to `validate.py` with a test
  (`narration n1 appears twice; ids must be unique across the passage`), a
  line to the writer prompt's schema example, and confirmed all 87 shipped
  drafts still validate. The fix went through the resident writer agent by
  follow-up message (ids only, verified by a field diff against a snapshot),
  and the resident auditor re-ruled the renumbered draft into a fresh
  `audit.1.json` after the stale one was moved out of the work dir, so
  `metrics` still counts one attempt. The stale audit had passed on content;
  the re-audit returned the same 18 verdicts.

### Reader notes (taste and policy, not rule failures)

- Verses without narrations get no verse entry (5:2 skips 8 to 10, 5:3 skips
  16 to 18); 5:1 had one per verse. The essay gives each skipped verse a
  sentence and the auditor judged coverage complete both times. Decide
  whether an entry per verse is wanted; if so it is a writer-prompt note.
- Speaker names drift again: 5:3 has "Ali ibn Ibrahim al-Qummi" where 5:2 and
  twenty shipped narrations say "Ali ibn Ibrahim", and "Prophet Muhammad"
  where "the Prophet" is the commonest of five shipped forms. The house list
  is still the open fix.
- 5:2's verse 11 note lists three candidate attackers against one marker whose
  shown excerpt names only Banu al-Nadir. The auditor ruled the full block
  supports it. Same excerpt-narrower-than-claim pattern as 4:15 and 4:24,
  for the sourcing pass.
- 5:3 verse 14 n3 opens its English with "Ali said:" although the speaker
  field already carries it; the auditor noted the trailing verse lemma in
  quotes is the block's own. Cosmetic.
- 5:3's perspectives entry opens with the unmarked "Both traditions treat the
  twelve chiefs as a sign ..." framing sentence that the an-Nisa run wanted
  banned; this auditor accepted it.
- Polemical narrations present where the sources carry them (5:2 the broken
  covenant of wilaya; 5:3 Qummi's ta'wil of 5:13 as the covenant of the
  Commander of the Faithful and the light of 5:15 as the Imams). Perspectives
  in both passages are genuine Sunni/Shia splits (the covenant of 5:7; the
  twelve chiefs of 5:12).

## Results - al-Maaida 5:4 to 5:9 (2026-09-08)

Run with two slots after the user asked for the whole surah, then stopped at
5:9 on the user's instruction; 5:10 to 5:16 are gathered and waiting. Titles
for 5:4 to 5:9 approved as generated; `assemble 5` merged them, so
`passages_5.json` holds 5:1 to 5:9.

| passage | verses | blocks | writer | audit 1 | rewrite | audit 2 |
|---|---|---|---|---|---|---|
| 5:4 | 20-26 | 38 | 133,612 tok, 10 min | FAIL, 1 stretched (108K, 5 min) | 28,122 tok, 1 min | PASS (104K, 4 min) |
| 5:5 | 27-34 | 57 | 195,633 tok, 12 min | FAIL, 1 stretched (183K, 8 min) | 36,257 tok, 2 min | PASS (175K, 6 min) |
| 5:6 | 35-43 | 63 | 189,870 tok, 14 min | PASS, 26 targets (164K, 6 min) | | |
| 5:7 | 44-50 | 54 | 187,042 tok, 11 min | PASS, 13 targets (158K, 4 min) | | |
| 5:8 | 51-56 | 62 | 184,905 tok, 18 min | PASS, 21 targets (167K, 6 min) | | |
| 5:9 | 57-66 | 71 | 218,732 tok, 16 min | PASS, 19 targets (173K, 7 min) | | |

Surah so far: 9 passed, first-try 7/9, mean attempts 1.2, no prose flags in
any of the eleven audits. Rewrites on Opus 4.8 cost 28K to 36K tokens and one
to two minutes: the writer reads the audit and fixes the named target without
re-reading the packet, against about 235K on Opus 5. Skill cost lines updated.

### Why passages failed (2 rewrites, 2 findings)

- 5:4 verses.21 n3: "أبناء الأبناء" (the grandsons) rendered "the grandsons'
  sons", one generation too many. Rendering over-reach.
- 5:5 essay[3]: the "same envy" mechanism behind the People of the Book's
  rejection is al-Mizan's (s1) but was credited to Tabrisi under [3], whose
  block frames their offence as covenant-breaking and outrages. Attribution
  imported across blocks, the pilot's usual failure.

### Deviations from the procedure

- The first 5:4 auditor died on the weekly Opus 4.8 limit (HTTP 429, reset
  4pm Chicago) before writing anything; relaunched fresh after the reset.
- Gathers for 5:5 to 5:16 ran as one detached shell chain (nohup) with one
  automatic retry per passage, since a background command is capped at ten
  minutes and twelve gathers take about twenty-five. All twelve succeeded on
  the first attempt. Every al-Burhan block the gathers reported empty (24
  verses) was probed directly afterwards: all genuinely empty on the site.
- User asked (2026-09-08) not to run `passage-prose-reader` as a second
  opinion on new passages; the auditor's prose list is the only gate.

### Reader notes (taste and policy, not rule failures)

- Polemical policy still applied inconsistently by adjacent writers: 5:6
  carries "the enemies of Ali abide in the Fire" and 5:8 the Kufan-figures
  narration on 5:53, while 5:7's writer explicitly left out the packet's
  khums report naming Abu Bakr and a Zayd ibn Thabit tail, citing the open
  policy.
- 5:8 verse 52's narration (Banu Umayya's destruction "seven days after the
  burning of Zayd") is supported but a reader cannot see why it sits under
  "the sickness in the hearts". Relevance, for the writer prompt.
- 5:9's essay is one unbroken 309-word paragraph (every other surah 5 essay
  has two to four) and cites verse numbers in parentheses mid-sentence, a
  style no other passage uses. The paragraph-break rule is still open.
- 5:8 and 5:9 abbreviate "ibn" as "b." in names (Ubada b. al-Samit, Rifaa b.
  Zayd); every other passage spells it out. House list.
- Speaker forms: 5:5 "Imam al-Sajjad" where shipped passages use "Ali ibn
  al-Husayn" in two forms; "Abu Ja'far" (5:4) against "Abu Jafar" (5:2) in
  chains.
- Perspectives: the "Both traditions ..." opener appears in 5:4 unmarked and
  in 5:6 with a marker; 5:7 and 5:9 close on a "Both agree ..." sentence.
  Auditors accepted all four.
- Genuine splits well chosen throughout: the twelve chiefs (5:3), "made you
  kings" (5:4), graded versus optional hiraba penalties (5:5), al-wasila
  (5:6), the rabbaniyyun (5:7), the verse of guardianship (5:8), "what was
  sent down to them" as walaya or Quran (5:9).


## Results - al-Maaida 5:10 to 5:16 (2026-09-08)

Run on Fable 5.1 as orchestrator with the writer and auditor still pinned to
Opus 4.8, two slots, in loop mode (writers first, each audit launched as its
writer's slot freed). All seven passed on the first audit with no prose flags,
so no rewrite and no polish ran. Titles approved as generated; `assemble 5`
merged them, so `passages_5.json` now holds the whole surah, 5:1 to 5:16.

| passage | verses | blocks | writer | audit 1 |
|---|---|---|---|---|
| 5:10 | 67-77 | 78 | 204,390 tok, 12 min | PASS, 19 targets (185K, 7 min) |
| 5:11 | 78-86 | 54 | 143,008 tok, 10 min | PASS, 15 targets (128K, 6 min) |
| 5:12 | 87-93 | 55 | 173,518 tok, 10 min | PASS, 13 targets (158K, 6 min) |
| 5:13 | 94-100 | 57 | 179,872 tok, 13 min | PASS, 21 targets (156K, 6 min) |
| 5:14 | 101-108 | 61 | 187,979 tok, 11 min | PASS, 19 targets (172K, 5 min) |
| 5:15 | 109-115 | 62 | 163,177 tok, 11 min | PASS, 16 targets (147K, 6 min) |
| 5:16 | 116-120 | 35 | 108,909 tok, 9 min | PASS, 15 targets (112K, 4 min) |

Surah total: 16 passed, first-try 14/16, mean attempts 1.1. The seven
writers cost 1.16M tokens and the seven audits 1.06M; wall clock for the
batch was about 2.5 hours with two slots. Not one audit verdict below
supported in seven passages, against two stretched in 5:4 to 5:9 and 19
rewrites in the al-Baqarah pilot.

### Why passages failed

None failed.

### Deviations from the procedure

- `titles 5 --apply` and `assemble 5` only take entries whose `approved`
  flag is true, so after the user chose "approve all as generated" the flag
  was flipped for 5:10 to 5:16 by a one-line script before re-running both.
  An `--approve-all` flag on `titles` would remove that hand step.
- Loop mode: a fallback wakeup (20 to 25 minutes) was scheduled after every
  launch in case a completion notification never arrived; none fired, every
  agent notified on its own.
- No `passage-prose-reader` pass, per the user's 2026-09-08 instruction.

### Reader notes (taste and policy, not rule failures)

- 5:10 verse 75 carries the same Imam al-Rida report twice (n7 from
  al-Burhan quoting Uyun akhbar al-Rida, n8 from Uyun directly). Duplicate
  across two blocks of one source; a dedupe rule for the writer prompt.
- 5:11 verses 81 and 83 to 86 have no entries at all; the essay covers
  them. The auditor let two added qualifiers stand: "Meccan" on Razi's
  polytheists and "unjust" on the ruler in al-Sadiq's report.
- 5:12 verse 92's narration ("none perished except over abandoning our
  guardianship") is the al-Safi reading of "turn away", but a reader cannot
  see the link to "obey and beware" from the entry. Relevance, as in 5:8.
  "al-Hasan" in the perspectives is bare and could be read as the Imam
  rather than al-Basri; the house list should fix the form. The auditor
  passed "Qurtubi lists ten companions" where Qurtubi says "a group" and
  the count is inferred.
- 5:13 verse 98's hadith qudsi is labelled speaker "Imam al-Sadiq" though
  the words are God's, relayed through the Prophet and Jibril; the speaker
  rule reads the last link of the chain and has no case for qudsi reports.
- 5:14 verse 101's Safiyya report is the packet's polemical Umar narration,
  kept; verse 105 pairs the Prophet's "take care of yourself" hadith with
  al-Sadiq's "revealed concerning taqiyya". n1's English drops the
  "praised station" intercession clause of the Arabic (auditor noted, not
  flagged). Essay is 370 words and calls the bequest verses "its hardest
  law", editorial framing no block asserts.
- 5:15 verses 110 and 111 (Imam al-Rida to Ibn al-Sikkit; why the disciples
  are so named) are condensed summaries with reported speech rather than
  renderings of the Arabic; the 60-word cap is pushing long reports into
  paraphrase. "The Quran is all reproach, and its inner meaning is a
  drawing near" (verse 109) is faithful but opaque on one pass. n5 renders
  "أخوان" as "fish" following the Sunni parallels' "أحوات".
- 5:16 places citation markers after the full stop ("...father. [1]");
  every other passage in the surah puts them before. Marker placement is
  not in the writer prompt. Its verse 118 narration comes from an al-Burhan
  block relaying al-Durr al-Manthur (chain names al-Durr), which is within
  the rule since the block is Shia tier A.
- Speaker forms for the Prophet now come in three: "The Prophet" (5:10),
  "The Prophet Muhammad" (5:14), "the Prophet Muhammad" (5:16). House list.
- Genuine splits well chosen throughout: the occasion of 67 (5:10), the
  alliance of 80 (5:11), the occasion of 87 (5:12), the sea's "food" and the
  expiation's scope (5:13), abrogation of the testimony verses (5:14), "we
  have no knowledge" (5:15), "the truthful" (5:16).

## Results - al-An'am 6:1 to 6:20 (2026-09-08 to 09)

Run on Fable 5.1 as orchestrator, writer and auditor on Opus 4.8, two slots,
loop mode. Gathers for all twenty passages ran as one detached chain (6:1 at
19:07, done 19:37, every passage on the first attempt; al-Mizan and
al-Burhan present in every packet). Writers started as soon as their own
packet landed rather than after the whole chain. Titles approved as
generated; `assemble 6` wrote `passages_6.json` with all twenty passages.

| passage | verses | blocks | writer | audit 1 | rewrite | audit 2 |
|---|---|---|---|---|---|---|
| 6:1 | 1-10 | 64 | 169,025 tok, 13 min | PASS, 20 targets (153K, 6 min) | | |
| 6:2 | 11-20 | 56 | 161,242 tok, 12 min | FAIL, 1 stretched (150K, 7 min) | 61,275 tok, 3 min | PASS (137K, 5 min) |
| 6:3 | 21-30 | 67 | 170,264 tok, 12 min | FAIL, 1 stretched (175K, 7 min) | 40,630 tok, 2 min | PASS (167K, 5 min) |
| 6:4 | 31-41 | 78 | 229,860 tok, 17 min | PASS, 19 targets (190K, 5 min) | | |
| 6:5 | 42-50 | 57 | 165,504 tok, 11 min | PASS, 20 targets (147K, 6 min) | | |
| 6:6 | 51-55 | 39 | 138,983 tok, 11 min | PASS, 13 targets (113K, 5 min) | | |
| 6:7 | 56-60 | 37 | 129,961 tok, 11 min | PASS, 18 targets (106K, 5 min) | | |
| 6:8 | 61-70 | 57 | 198,609 tok, 16 min | PASS, 17 targets (163K, 9 min) | | |
| 6:9 | 71-82 | 70 | 199,806 tok, 12 min | PASS, 18 targets (179K, 6 min) | | |
| 6:10 | 83-90 | 45 | 119,873 tok, 10 min | PASS, 14 targets (161K, 4 min) | | |
| 6:11 | 91-94 | 45 | 184,341 tok, 16 min | PASS, 14 targets (134K, 4 min) | | |
| 6:12 | 95-100 | 48 | 169,773 tok, 14 min | PASS, 17 targets (135K, 6 min) | | |
| 6:13 | 101-110 | 89 | 211,110 tok, 12 min | FAIL, 1 stretched (192K, 8 min) | 51,505 tok, 2 min | PASS (217K, 7 min) |
| 6:14 | 111-121 | 83 | 243,090 tok, 17 min | PASS, 20 targets (215K, 10 min) | | |
| 6:15 | 122-129 | 75 | 172,683 tok, 11 min | PASS, 21 targets (171K, 8 min) | | |
| 6:16 | 130-140 | 84 | 202,772 tok, 12 min | PASS, 14 targets (172K, 5 min) | | |
| 6:17 | 141-144 | 32 | 105,330 tok, 9 min | FAIL, 1 stretched (103K, 4 min) | 29,751 tok, 1 min | PASS (103K, 5 min) |
| 6:18 | 145-150 | 44 | 123,358 tok, 8 min | PASS, 16 targets (118K, 5 min) | | |
| 6:19 | 151-154 | 36 | 140,683 tok, 12 min | FAIL, 1 stretched (147K, 6 min) | 38,204 tok, 1 min | PASS (156K, 8 min) |
| 6:20 | 155-165 | 99 | 248,456 tok, 18 min | FAIL, 1 stretched (198K, 7 min) | 43,993 tok, 2 min | PASS (198K, 7 min) |

Surah total: 20 passed, first-try 14/20, mean attempts 1.3, no prose flags
in any of the 26 audits. Writers 3.48M tokens, rewrites 0.27M, audits
4.10M; wall clock about 3.7 hours from the first gather to the last PASS.
Rewrites cost 30K to 61K tokens and one to three minutes.

### Why passages failed (6 rewrites, 6 findings, all attribution)

- 6:2 perspectives[8]: the Imams' narration on "whomever it may reach" was
  presented as agreeing with the object reading and adding the Imam; in
  s8 the "everyone it reaches" gloss is Tabrisi's own, and the Imams give a
  distinct nominative reading (the Imam as the one who reaches and warns).
- 6:3 essay[2]: a view Tabrisi records with qeel from Muqatil (the
  polytheists professing monotheism to escape) credited to Tabrisi as his
  own explanation.
- 6:13 perspectives[4]: Imam al-Rida's "the sights in the hearts" (a
  narration Tabrisi cites via al-Ayyashi) credited to Tabrisi, whose own
  gloss reads the sights as the eyes.
- 6:17 perspectives[16]: a view Tabari reports from al-Hasan and Anas (the
  harvest due is the obligatory zakat) credited to Tabari himself.
- 6:19 perspectives[24]: "innovations" attached to Ibn Kathir's block, where
  the word does not occur; it is in Tabari, Suyuti and Razi. Fixed by
  splitting the marker and adding the Tabari source.
- 6:20 perspectives[56]: "in this community", from a hadith Ibn Kathir
  cites and rejects, attached to his general reading.

Five of six are in perspectives, and every one is the pilot's usual
failure: a view the block reports from someone else credited to the
author or the Imams. The "Speakers and names" rule in the writer prompt
does not yet reach reported views inside a commentator's block (qeel, "some
said", a cited narration); that is the next prompt edit.

### Deviations from the procedure

- Writers launched as each packet landed instead of after all twenty
  gathers; the gather chain ran detached in the background as before.
- 6:14's writer applied its last two edits with a Python write rather than
  the Write tool, so the PostToolUse validator did not run on them; the
  writer ran `validate 6:14` by hand and it passed, and the orchestrator
  validated again before the audit.
- Two auditors (6:16, 6:20) first wrote verdict targets with a sequential
  marker index instead of the bracketed source number, got `malformed` from
  `audit-check`, and corrected themselves. Worth one line in the auditor
  prompt: targets are keyed by the number inside the brackets.
- `titles 6 --apply` needed the `approved` flags flipped by script after
  "approve all as generated", as for surah 5.
- Loop mode with a fallback wakeup after every launch; none fired.
- No `passage-prose-reader` pass, per the 2026-09-08 instruction.

### Reader notes (taste and policy, not rule failures)

- Speaker forms drift within one surah. The Prophet: "Prophet Muhammad"
  (6:2), "the Prophet" (6:4), "the Prophet Muhammad" (6:8, 6:15, 6:19).
  The seventh Imam: "Imam al-Kazim" (6:4, 6:10, 6:12, 6:18) against "Imam
  Musa ibn Jafar" (6:14). "Imam al-Sajjad" (6:19). "Abdullah ibn Abbas"
  (6:1) against "Ibn Abbas" (6:6). The house list is overdue.
- The tafsir author as speaker: "Ali ibn Ibrahim al-Qummi" is the speaker of
  four narrations that are his own glosses (6:3 verses 27 and 28, 6:15
  verses 122 and 128). Those belong in a verse note. 6:1 verse 1 lists
  "Abdullah ibn Abbas" as speaker of a mi'raj report whose words are the
  Prophet's and God's; 6:2 has a joint "Imam al-Baqir and Imam al-Sadiq".
- Reporter framing inside the narration text, although the speaker field
  already names the Imam: "Al-Sadiq said ..." four times in 6:2, "I asked
  Abu Abdillah" (6:7, 6:9), "In the report of Abi al-Jarud" (6:7), "Abu
  Abdillah was asked" (6:9), "Ibn Abbas said that" (6:6), "In a tradition,
  Imam al-Baqir said that" (6:16). The writer prompt should ask for the
  Imam's words only.
- The 60-word cap is cutting narrations mid-sentence with an ellipsis: 6:7
  verse 58, 6:10 verse 84, 6:13 verse 108. 6:15 verses 110 and 111 and
  6:2 verse 11 are condensed third-person summaries instead.
- Duplicates across passages, invisible to the validator because the
  sources differ: the Angel of Death's helpers (6:7 verse 60 and 6:8 verse
  61); the surah revealed whole with seventy thousand angels (6:1 verse 1
  from al-Rida, 6:20 verse 155 from al-Sadiq).
- Perspectives repeat one topic: the free-will or divine-will split (Razi
  or Ibn Kathir against Tusi and Tabrisi) carries 6:4, 6:5, 6:15 and 6:18.
  6:8's contrast is thin (both agree at the core, differ on reach) and 6:16
  and 6:17 open on "Both traditions agree". 6:18's essay and perspectives
  repeat the same Tusi sentence nearly verbatim.
- Essay paragraphing still varies: one paragraph in 6:2 (399 words), 6:6,
  6:12 and 6:18; two to four elsewhere. 6:3 places markers after the full
  stop, the rest before. 6:18's essay skips verse 147 (auditor noted,
  passed).
- 6:11 verse 93's narration never names its subject in English (the "he"
  who wrote "All-knowing" and apostatised is Ibn Abi Sarh). 6:13 verse 103
  opens "It is the encompassing of the imagination" without the question.
- 6:12 verse 95's "two clays" hadith is graded weak in its al-Kafi block;
  the grading is not surfaced (known finding).
- Polemical narrations kept where the sources carry them: the "two
  satans" Habtar and Zurayq (6:14), Banu Umayya (6:3), Mu'awiya (6:11),
  Marwan (6:8), al-Zubayr's lent faith (6:12), the descendants of Husayn's
  killers (6:20), Ali's wilaya readings throughout.
- Genuine splits well chosen: the two terms and bada (6:1), man balagha
  (6:2), Abu Talib (6:3), the Prophet's inclination at 6:52 (6:6), unseen
  knowledge and the manifest Book (6:7), Abraham's "This is my Lord" (6:9),
  "a people who never disbelieve" (6:10), transcendence (6:11), abode and
  lodging (6:12), vision of God (6:13), naming at slaughter (6:14), jinn
  messengers (6:16), the harvest due (6:17), the sects verse (6:20).

## Results - al-A'raf 7:1 to 7:24 (2026-09-09)

Run on Fable 5.1 as orchestrator, writer and auditor on Opus 4.8, two slots,
loop mode. The first gather chain lost 7:2 and 7:3 to altafsir curl timeouts
(the fetch has no retry, and one failed request aborts the whole gather), so
the chain was restarted at 05:57 as a bash loop that retries a passage up to
four times until its `sources.json` exists; no retry was needed after that
and all twenty-four packets were in by 06:32, al-Mizan and al-Burhan present
in every one. Writers started as each packet landed. Titles approved as
generated; `assemble 7` wrote `passages_7.json` (426 KB) with all
twenty-four passages.

| passage | verses | blocks | writer | audit 1 | rewrite | audit 2 |
|---|---|---|---|---|---|---|
| 7:1 | 1-10 | 60 | 146,504 tok, 10 min | PASS, 17 targets (142K, 7 min) | | |
| 7:2 | 11-25 | 84 | 211,812 tok, 17 min | PASS, 15 targets (177K, 6 min) | | |
| 7:3 | 26-31 | 45 | 151,163 tok, 12 min | PASS, 18 targets (120K, 4 min) | | |
| 7:4 | 32-39 | 64 | 213,873 tok, 17 min | PASS, 21 targets (174K, 7 min) | | |
| 7:5 | 40-47 | 60 | 164,924 tok, 11 min | PASS, 18 targets (185K, 8 min) | | |
| 7:6 | 48-53 | 41 | 159,578 tok, 15 min | FAIL, 1 stretched (116K, 6 min) | 30,562 tok, 1 min | PASS (112K, 5 min) |
| 7:7 | 54-58 | 39 | 137,724 tok, 12 min | PASS, 12 targets (116K, 6 min) | | |
| 7:8 | 59-64 | 26 | 83,463 tok, 8 min | PASS, 10 targets (73K, 5 min) | | |
| 7:9 | 65-72 | 29 | 92,245 tok, 7 min | PASS, 15 targets (85K, 4 min) | | |
| 7:10 | 73-84 | 54 | 153,012 tok, 13 min | PASS, 15 targets (133K, 6 min) | | |
| 7:11 | 85-93 | 40 | 128,355 tok, 9 min | PASS, 12 targets (115K, 5 min) | | |
| 7:12 | 94-99 | 28 | 90,483 tok, 8 min | PASS, 11 targets (74K, 4 min) | | |
| 7:13 | 100-108 | 48 | 140,162 tok, 11 min | PASS, 16 targets (134K, 7 min) | | |
| 7:14 | 109-126 | 48 | 127,699 tok, 7 min | PASS, 12 targets (118K, 4 min) | | |
| 7:15 | 127-129 | 23 | 102,343 tok, 10 min | PASS, 12 targets (79K, 4 min) | | |
| 7:16 | 130-141 | 69 | 169,411 tok, 9 min | PASS, 11 targets (147K, 3 min) | | |
| 7:17 | 142-147 | 51 | 163,533 tok, 12 min | PASS, 13 targets (135K, 6 min) | | |
| 7:18 | 148-151 | 29 | 106,983 tok, 8 min | PASS, 13 targets (90K, 4 min) | | |
| 7:19 | 152-157 | 47 | 170,994 tok, 14 min | PASS, 15 targets (142K, 6 min) | | |
| 7:20 | 158-162 | 33 | 120,966 tok, 10 min | PASS, 17 targets (106K, 6 min) | | |
| 7:21 | 163-171 | 60 | 176,579 tok, 12 min | PASS, 18 targets (153K, 6 min) | | |
| 7:22 | 172-181 | 76 | 205,455 tok, 15 min | PASS, 24 targets (177K, 7 min) | | |
| 7:23 | 182-188 | 53 | 124,902 tok, 9 min | PASS, 13 targets (114K, 5 min) | | |
| 7:24 | 189-206 | 108 | 222,239 tok, 12 min | PASS, 20 targets (203K, 6 min) | | |

Surah total: 24 passed, first-try 23/24, mean attempts 1.0, no prose flags
in any of the 25 audits. Writers 3.56M tokens, the one rewrite 0.03M,
audits 3.22M, 6.81M in all; wall clock 3.6 hours from the first gather
(05:52) to the last PASS (09:29). Writers ran 83K to 222K tokens and 7 to
17 minutes; audits 73K to 203K and 3 to 8 minutes.

```
passage  stage     attempts  first  hours  sources
7:1      passed           1   True    0.3       60
7:2      passed           1   True    0.4       84
7:3      passed           1   True    0.4       45
7:4      passed           1   True    0.7       64
7:5      passed           1   True    0.7       60
7:6      passed           2  False    1.2       41
7:7      passed           1   True    1.0       39
7:8      passed           1   True    1.2       26
7:9      passed           1   True    1.3       29
7:10     passed           1   True    1.5       54
7:11     passed           1   True    1.5       40
7:12     passed           1   True    1.6       28
7:13     passed           1   True    1.7       48
7:14     passed           1   True    1.7       48
7:15     passed           1   True    1.9       23
7:16     passed           1   True    1.9       69
7:17     passed           1   True    2.2       51
7:18     passed           1   True    2.1       29
7:19     passed           1   True    2.4       47
7:20     passed           1   True    2.4       33
7:21     passed           1   True    2.7       60
7:22     passed           1   True    2.7       76
7:23     passed           1   True    2.9       53
7:24     passed           1   True    2.9      108

24 passed, first-try 23/24, mean attempts 1.0
```

| id | essay words | verse entries | narrations | sources | perspectives words | paragraphs |
|---|---|---|---|---|---|---|
| 7:1 | 336 | 5 | 6 | 14 | 94 | 4 |
| 7:2 | 361 | 6 | 9 | 12 | 84 | 4 |
| 7:3 | 240 | 5 | 8 | 13 | 106 | 4 |
| 7:4 | 342 | 4 | 7 | 18 | 110 | 4 |
| 7:5 | 343 | 4 | 7 | 15 | 92 | 3 |
| 7:6 | 244 | 3 | 4 | 11 | 97 | 1 |
| 7:7 | 217 | 4 | 5 | 11 | 107 | 1 |
| 7:8 | 233 | 1 | 2 | 8 | 100 | 2 |
| 7:9 | 310 | 4 | 4 | 12 | 89 | 3 |
| 7:10 | 362 | 5 | 5 | 13 | 98 | 1 |
| 7:11 | 322 | 4 | 5 | 10 | 0 | 4 |
| 7:12 | 248 | 2 | 2 | 10 | 104 | 1 |
| 7:13 | 336 | 2 | 3 | 15 | 99 | 3 |
| 7:14 | 329 | 3 | 4 | 10 | 94 | 4 |
| 7:15 | 232 | 3 | 4 | 11 | 97 | 2 |
| 7:16 | 345 | 4 | 4 | 10 | 102 | 3 |
| 7:17 | 253 | 4 | 6 | 12 | 106 | 1 |
| 7:18 | 246 | 3 | 4 | 11 | 90 | 2 |
| 7:19 | 247 | 3 | 6 | 13 | 92 | 1 |
| 7:20 | 244 | 3 | 6 | 12 | 98 | 3 |
| 7:21 | 326 | 5 | 6 | 15 | 91 | 4 |
| 7:22 | 380 | 6 | 11 | 23 | 109 | 3 |
| 7:23 | 250 | 3 | 3 | 11 | 98 | 3 |
| 7:24 | 361 | 6 | 6 | 16 | 95 | 4 |

127 narrations and 306 cited sources across the surah; 7:11 has no
perspectives because the traditions read Shu'ayb's story alike.

### Why 7:6 failed (1 rewrite, 1 finding)

- 7:6 essay[1]: "al-Mizan reads the closing two verses as turning back to
  where the sura began"; the block says a return to the beginning of the
  discourse (the "O Children of Adam" address), not the sura's opening. The
  rewrite named the address; the proof-through-the-Book half was already
  exact. An over-specified location rather than the pilot's attribution
  failure.

Auditors recorded, without failing, six judgment calls of the same shape
as surah 6's findings: "Tabrisi's gloss" for a view Tabrisi adopts from
Mujahid and al-Suddi (7:3), "Tabrisi explains" for a qeel view (7:7),
"al-Tabari and the Sunni commentators" on one Tabari marker (7:6, 7:9),
"the strongest reading" credited to Tabrisi for a jumhur view he stamps
al-aqwa (7:17), and the Abd al-Harith story framed as Adam and Eve where
the hadith centres on Eve (7:24). All ruled supported.

### Deviations from the procedure

- The gather chain was restarted with a per-passage retry loop after two
  curl timeouts; `fetch.py` itself was not changed. A retry inside
  `curl_get` (or a per-work retry in `gather`) would remove the need.
- Writers launched as each packet landed, as for surah 6.
- 7:20's auditor first wrote a file `audit-check` reported as `malformed`
  and corrected it before finishing, as 6:16 and 6:20 did.
- `titles 7 --apply` again needed the `approved` flags flipped by script
  after "approve all as generated".
- Loop mode with a fallback wakeup after every launch; none fired.
- No `passage-prose-reader` pass, per the 2026-09-08 instruction.

### Reader notes (taste and policy, not rule failures)

- Speaker forms drift more than in surah 6. Ali appears as "Imam Ali"
  (7:1, 7:5, 7:6, 7:14), "Amir al-Mu'minin" (7:11, 7:18), "Ali ibn Abi
  Talib" (7:20) and "the Commander of the Faithful" (7:22). The Prophet:
  "the Prophet" (7:10, 7:12), "The Prophet Muhammad" (7:11), "the Prophet
  Muhammad" (7:22). The fourth Imam is "Ali ibn al-Husayn" (7:11) with no
  Imam title; the twelfth is "al-Qaim" (7:19); 7:14 has "the Imam" for a
  chain that names none. Commentators drift too: "al-Tusi" and "al-Mizan"
  in 7:1 and 7:2 against "Tusi", "Tabrisi", "Tabatabai" from 7:3 on, and
  "Al-Tabatabai" in 7:4. The essay of 7:21 leaves "Abu Ja'far" unresolved.
- The tafsir author as narration speaker: "Ali ibn Ibrahim al-Qummi" is the
  speaker of five narrations that are his own glosses (7:7 verses 57 and
  58, 7:15 verses 127 and 129, 7:18 verse 149).
- Reporter framing inside narration text, worst in 7:16 where all three
  plague narrations are third-person reports ("Al-Ayyashi relates that
  al-Sadiq was asked ...", "It is narrated from al-Sadiq that ..."); also
  "He was asked ... He said" (7:1, 7:19), "I asked him" (7:3, 7:22),
  "Abu Jafar said" (7:1), "And Abu Abdillah said" (7:18), "Ali said to the
  Exilarch, who had taunted ..." (7:16).
- Six essays are a single paragraph (7:6, 7:7, 7:10 at 362 words, 7:12,
  7:17, 7:19); the rest run two to four. 7:13 puts markers after the full
  stop in its first paragraph; 7:24 adds verse numbers in parentheses after
  each sentence, a style no other passage uses; 7:4's last paragraph packs
  four markers into two sentences.
- Duplicates across passages: "the tablets of Moses are with us, the staff
  of Moses is with us, and we are the heirs of the prophets" (7:17 verse
  145 and 7:20 verse 160, different blocks); the Abu al-Sahba' al-Bakri
  sects report (7:20 verse 159 with seventy-one, 7:22 verse 181 with
  seventy-three); Ali and the Exilarch appear in 7:16 and 7:20.
- Perspectives repeat the free-will or divine-will split four times (7:12,
  7:14, 7:16, 7:23), and open on "Both traditions ..." in 7:8, 7:9, 7:13,
  7:19, 7:20 and close on it in 7:15 and 7:16. Genuine splits well chosen:
  the Mizan (7:1), Adam's infallibility (7:2, 7:18, 7:24), the naked tawaf
  and the imams of tyranny (7:3, 7:4), the men on the Heights (7:5), the
  ta'wil and al-Qa'im (7:6), restoration of the earth (7:7), the ten
  fathers (7:8), bounties as wilaya (7:9), Lot's people and the law
  (7:10), the vision of God (7:17), the light as the Imams (7:19), the
  guiding nation (7:20), the Sabbath groups (7:21), the covenant clause
  (7:22).
- Polemical narrations kept where the sources carry them: Talha and
  al-Zubayr's camel (7:5), the imams of tyranny (7:3, 7:4), the Murji'a
  (7:14), Harun ibn Sad and the Zaydiyya as "the calf-party" (7:19), the
  Exilarch exchanges (7:16, 7:20), Bal'am applied to the people of the
  qibla (7:22).
- Ellipses inside narration text: 7:3 verse 28, 7:11 verse 89 (opens on
  one), 7:14 verse 120, 7:17 verse 143, 7:20 verse 158 (a mid-sentence
  cut), 7:23 verse 182.
- 7:8 is thin (26 blocks, two narrations both on verse 59); 7:11 skips
  verse 87 in the essay body and 7:21 skips verse 170 (both auditors noted
  it, passed); 7:22 folds 177 and 178 into the surrounding discussion.
