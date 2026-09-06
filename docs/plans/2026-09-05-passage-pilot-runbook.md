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
