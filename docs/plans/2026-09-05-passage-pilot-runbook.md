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
