# Passage Quiz - Runbook

Results and findings from `/quiz` runs, newest at the bottom. Design:
`2026-09-11-passage-quiz-design.md`. Procedure: `.claude/skills/quiz/SKILL.md`.

## Results - al-Fatihah 1:1 (2026-09-12)

First run of the loop, one passage, straight after the pipeline was built.

| passage | types in order | writes | reviews | writer | reviewer |
|---|---|---|---|---|---|
| 1:1 | MC, whoSaid, TF, MC, fillGap | 1 | 1 (PASS) | 59K tokens, 1 min 37 s | 21K tokens, 55 s |

- The writer ran as a general agent following `passage-quiz-writer.md` by hand,
  because agent files written mid-session only register at the next session
  start; it validated with `quiz-validate` after its one write. The reviewer ran
  as the real `passage-quiz-reviewer` agent once the types registered.
- Anchors: essay, note on verse 4, narrations n4, n10 and n16. Answer slots 0, 1,
  1, 2, 0. No `whichVerse` this time; the passage has seven verses so it was
  available.
- The reviewer's reasons were specific and checkable (each distractor named as
  contradicted by the passage).

### Reader notes (taste, not rule)

- q5 (fill the gap on the narration for verse 7) offers "companions of the
  Prophet" as a wrong option next to "Ahl al-Bayt". Right by the passage, but
  in a Shia app that pairing reads as pointed. Candidate line for the writer
  prompt: distractors should be wrong by the passage, not a jab at anyone.
- q1's stem "the surah's opening invocation of God" is a little abstract for
  the first question; "the Bismillah" would land faster. Taste only.
- Every question is answerable from the passage and none is trivia.

### Open after this run

- Measure the real `passage-quiz-writer` agent (with its hook) on the next run;
  the 59K above includes reading the agent file and the brief.
- Decide whether to add the "not a jab" line to the writer prompt before running
  a whole surah.

## Results - al-Baqarah 2:1 to 2:40 (2026-09-12)

Second run of the loop, the whole surah in one session, two agent slots, straight after the 1:1 pilot. The user asked to stop after surah 2 while it was running, so surahs 3 to 12 were not started.

| passage | types in order | writes | reviews | reader notes |
|---|---|---|---|---|
| 2:1 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | four of five prompts name Tusi or Tabrisi ("How does Tusi read...", "Tusi holds..."); answers are content not attribution, but the surface reads scholar-heavy. q5 "sealing a book" gap is a fair image test. Anchors: essay, n2 on v2, notes v3 and v6, perspectives. |
| 2:2 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | same type order as 2:1 and q1 again opens "How does al-Tabrisi read..."; q5 fillGap prompt is a lowercase mid-sentence fragment ("he walks only in the flashes - the flashes being the ____"), reads oddly on its own. Otherwise sound; q4 T/F on perspectives is a clean negation. |
| 2:3 | MC, whoSaid, TF, MC, whichVerse | 1 | 1 (PASS) | q5 whichVerse gives itself away: the right option's heading "Earth first, then the heavens" restates the prompt, so a skimmer gets it. q1 and q4 both "how does <scholar> read" openers. q2 weeping-mountain whoSaid is a good recognisable quote. |
| 2:4 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | q1 and q2 are the writer prompt's own worked examples (the example passage is 2:4), so this quiz is partly copied. q4 T/F restates al-Jubbai's two-descents note verbatim as True; a skimmer who saw "al-Jubbai" would guess True. q5 has three headed options and one bare "Verse 39", which makes the odd one out easy to spot. |
| 2:5 | MC, whoSaid, TF, fillGap, MC | 1 | 1 (PASS) | best of the surah so far: varied order, q3 T/F is a clean negation a skimmer would get wrong, q5 on zann as certainty tests the passage's actual point. q2 whoSaid quote is long and name-heavy but recognisable. |
| 2:6 | MC, TF, MC, whoSaid, whichVerse | 1 | 1 (PASS) | q2 T/F on the day nothing avails being death, not the Resurrection, is the passage's real point and a skimmer would get it wrong. q5 whichVerse heading "The gate and the word" half-leaks the prompt's "prostrating at the gate". |
| 2:7 | MC, whoSaid, TF, MC, fillGap | 1 | 1 (PASS) | q3 T/F on whether the root of la ta'thaw means mild or severe corruption is a lexical detail, closer to memory than understanding. q4 options mix three paraphrases with one direct quotation, and the quotation is the answer, so form gives it away. q5 fillGap is again a lowercase fragment and "prophets" is guessable without reading. |
| 2:8 | MC, whoSaid, TF, fillGap, MC | 1 | 1 (PASS) | q4 fillGap on the cow being "yellow" is answerable from general knowledge, so it tests memory of the verse. q2 whoSaid frames the exchange in the prompt instead of a bare quote, a nice variation. q3 T/F on pen-on-Sabbath, take-on-Sunday is a real comprehension check. |
| 2:10 | MC, whoSaid, TF, MC, fillGap | 1 | 1 (PASS) | q5 fillGap "leadership of this world" has three plausible distractors and tests the passage's specific reading. q1 is the fifth quiz in ten to open "How does Tabatabai read...". q4 on the ransom-kept, killing-ban-broken contradiction is a real comprehension check. |
| 2:9 | whoSaid, MC, TF, MC, fillGap | 1 | 1 (PASS) | first quiz to open with a whoSaid, good for variety. q3 T/F swaps "harder" for "softer", which anyone who knows the verse gets without reading; weak. q5 fillGap lowercase fragment again; "first believer" against "first Muslim" is a fine line a reader may argue with. q4 on the common people following corrupt jurists is a strong comprehension check. |
| 2:11 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | q4 T/F swaps "disobey" for "obey" in a well-known verse, like 2:9 q3: a word-flip on the translation, not a test of the commentary. q5 fillGap distractor "saddest" is one nobody would pick. q3 on Quran-and-Torah faith bound together is a good understanding check. |
| 2:12 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | q5 whichVerse heading "The better reward" repeats the prompt's "reward would have been better", third leak of this kind (2:3, 2:6). q4 T/F that Solomon was faithless is a gimme for anyone who knows the verse. q3 on fisq as "going out" of Moses' law is the quiz's best question. |
| 2:14 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | q4 is another T/F built on the verse text (never pleased unless he follows their creed). q5 whichVerse heading "Reading the Book truly" leaks the prompt again. q1 and q3 both frame with "Tabatabai". q2 whoSaid describes the exchange, good. |
| 2:13 | MC, whoSaid, TF, MC, fillGap | 2 | 2 (FAIL, PASS) | first FAIL: q4 asked what the book al-Burhan holds of "until Allah issues His edict", attribution to a source; rewrite replaced it with a narration-anchored MC on why demanding signs is reckless, which is better. q3 T/F copies a grammar phrase ("interrogative of confirmation that amounts to affirmation") verbatim as True, memory of jargon. q5 fillGap sentence lacks its subject ("...and finds in the verse proof"). |
| 2:15 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | q5 whichVerse heading "The prayer of Abraham" answers the prompt "Abraham's prayer" outright (fifth leak of this kind). q1 opens "How does Tabatabai read" again. q4 T/F on the partitive "from our progeny" is a good understanding check. |
| 2:17 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | weakest so far: q1, q4 and q5 all anchor on the verse translation, so three of five are answerable from the Quran text without the commentary (q4 flips "will not follow your qiblah", q5 "recognize their sons" is common knowledge). Only q3 on the Kaaba as Ibrahim's qibla tests the passage. |
| 2:16 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | q1 opens "How does al-Mizan explain", a book name in the prompt, the same shape the reviewer failed in 2:13 q4 (al-Burhan); the reviewer is not consistent on this. q5 fillGap "If you are asked for the ____, bear it" is guessable from "bear" alone. q2 whoSaid and q4 T/F on sibghah as dyeing are good. |
| 2:18 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | q1 asks for the essay's one word ("a race"), recall of phrasing. q5 fillGap "remembrance" is handed over by the quoted "Remember Me" in the same prompt. q4 T/F with "only the Book and nothing more" is another verse-text negation. q3 on "except" read as "and not" is a fair nuance check. |
| 2:19 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | q5 whichVerse heading "The One God" answers "no deity except Him" on sight. q4 T/F on concealment reaching to muffling meaning is a good understanding check. q2 bird's-crop narration is recognisable. |
| 2:21 | MC, whoSaid, TF, fillGap, MC | 1 | 1 (PASS) | q5's stem ("meant to make us wonder at them rather than express God's wonder") all but states the answer "wonder cannot be ascribed to God". q3 herdsman T/F and q4 "slaughtered" gap are sound. q1 opens "How does Tabatabai read" again. |
| 2:20 | MC, whoSaid, MC, TF, whichVerse | 2 | 2 (FAIL, PASS) | second FAIL, same cause as 2:13: q3 asked what Ibn Kathir holds the compeers to be, with the other Perspectives positions as distractors. The rewrite moved q3 to the verse 166 text, so q3, q4 and q5 now all sit on verses 166 to 167, and q5's option "Verse 166: The followed disown the followers" hands the reader q3's answer. |
| 2:22 | MC, whoSaid, TF, MC, fillGap | 1 | 1 (PASS) | solid: q3 T/F on a free man not killed for a slave and q5 ithm/janaf gap both test the commentary. q4 names Fayd Kashani but asks for his reading, the same shape the reviewer failed elsewhere; passed here. |
| 2:23 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | q4 T/F (white streak marks nightfall) is a verse-text gimme. q5 fillGap stem "Tabatabai takes it as bringing ____ near to judges" has a dangling "it", and "gifts" is arguably as apt as "money" for a bribe. q3 on witnessing the month as presence in one's town is a good one. |
| 2:25 | MC, whoSaid, TF, MC, whichVerse | 1 | 1 (PASS) | like 2:17, three of five (q1, q3, q5) anchor on the verse translation; q3 T/F "still have a share in the Hereafter" is a gimme. q4 on sorting people by what they ask for, then by hypocrisy and sincerity, is the only question that needs the essay. |
| 2:24 | MC, whoSaid, TF, MC, fillGap | 1 | 1 (PASS) | q3 T/F on the sacred month being Dhu al-Qada, not Ramadan, is a detail check but drawn from the note, fair. q4 on "the moderate" in spending is the best. q5 "miqat" gap needs a reader to have registered the term. |
| 2:26 | MC, fillGap, MC, TF, whoSaid | 1 | 1 (PASS) | new type order, whoSaid closing; good for variety. q3 "Allah's help is indeed near" is a verse gimme. q4 T/F with "the scholars all agree" tips False by its absolute wording. q2 "rank" gap and q1 changing a blessing are good. |
| 2:27 | MC, whoSaid, TF, MC, whichVerse | 1 | 1 (PASS) | q5 whichVerse heading "Where marriage stops" answers a prompt about wedlock; q4 and q5 both sit on verse 221. q1 on fighting in the sacred month being grave yet outweighed and q3 on mixing with orphans' property are good understanding checks. |
| 2:28 | MC, whoSaid, TF, MC, whichVerse | 1 | 1 (PASS) | q5 whichVerse with four bare "Verse N" options avoids the heading leak but becomes a test of remembering which verse number holds "quru", which no reader tracks. q2 names the speaker "Abu al-Hasan" as the brief does; readers may not place him as Imam al-Kazim. q1 and q4 are good. |
| 2:29 | MC, whoSaid, TF, fillGap, MC | 1 | 1 (PASS) | strong legal-ruling quiz: q3 on temporary marriage not restoring lawfulness, q4 "consummated", q5 divorce in jest binds all test what the commentary says. q1 is verse text but a real condition, not a word flip. |
| 2:31 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | q5 heading "A parting gift" restates the prompt's "parting provision". q3 asks which prayer al-Qummi's recitation adds after "the middle prayer", a variant-reading detail closer to trivia. q4 T/F is verse text. q1 and q2 are good. |
| 2:30 | MC, whoSaid, TF, MC, fillGap | 1 | 1 (PASS) | q3 T/F "a widow observes no waiting period" is a gimme. q4 on the pregnant widow waiting the later of the two terms is a good check. q1 opens "How does Tabatabai explain" again. q5 "proposal" gap is fair. |
| 2:32 | MC, whoSaid, TF, MC, whichVerse | 1 | 1 (PASS) | three verse-translation anchors again (q3, q4, q5); q5 heading "The Ark as sign" restates the prompt. q1 on "Die" as a creative command is the one question that needs the essay; q2 good. |
| 2:33 | MC, whoSaid, TF, whichVerse, MC | 1 | 1 (PASS) | q4 whichVerse heading "David kills Goliath" names a different aspect of verse 251 than the prompt asks, so no leak: the shape the others should copy. q3 T/F swapping whose act patience and victory are is a real check. q5 good. |
| 2:34 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | q3 on the kursi as "His knowledge" with "His throne" as the trap is well built. q4 T/F on compulsion and belief is a good one. q5 fillGap "wali" is guessable for anyone who knows the verse. q1 and q4 both name Tabatabai. |
| 2:35 | MC, whoSaid, MC, TF, fillGap | 1 | 1 (PASS) | q5 fillGap asks which bird was fourth in the narration's list, recall of a list item. q1 and q3 both frame with "al-Safi", a book name, passed by the reviewer. q4 T/F is verse text. q1 on the sun as a plainer instance of the same proof is good. |
| 2:36 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | weak: q1, q4 and q5 are verse text, q5 heading "The burnt orchard" restates "left burnt", and q3's distractors (ritual prayer, deny charity, abrogated) are ones nobody would pick. Only q2 needs the passage. |
| 2:37 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | q5 heading "The poor of the Suffa" answers a prompt about "the poor straitened", and q1 already used "the poor of the Suffa" as a distractor, so the term is primed. q4 T/F on guiding versus bringing to the reward is a good check. q3 verse text. |
| 2:38 | MC, whoSaid, MC, TF, whichVerse | 1 | 1 (PASS) | q5 asks which verse was the last revealed: a fact about the verse, not a point of the commentary, and the bare "Verse 281" among three headed options marks it out (as in 2:4). q4 T/F is verse text. q1 on giving that never stops and q3 on the usurer's fall of standing are good. |
| 2:40 | MC, whoSaid, TF, MC, fillGap | 1 | 1 (PASS) | q4's prompt writes "wus' (capacity)" and q5's gap is "capacity", so q4 hands q5 its answer; q5 is also one of the best-known lines in the Quran. q3 on who speaks "We make no distinction" and q4 on wus' as room below full endurance are good. |
| 2:39 | MC, fillGap, TF, whoSaid, MC | 1 | 1 (PASS) | q2, q5 are verse text and q5's "retained pledge" is guessable from the verse alone. q3 on pledging not being confined to travel is a real commentary check. q1 debtor dictates is fair. |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer (first draft) | 40 | 34K | 26K to 47K | 3 min 14 s | 1.3M tokens, 129 min |
| reviewer | 42 | 21K | 19K to 29K | 1 min 05 s | 921K tokens, 46 min |
| writer (rewrite) | 2 | 28K | 24K to 32K | 1 min 44 s | 56K tokens, 3 min |

Whole surah: about 2.4M agent tokens and 179 agent-minutes for 40 passages, roughly 58K tokens and 4 min 28 s of agent time per passage. Wall clock with two slots was about 2 h 20 min. The real writer is cheaper than the 59K measured on 1:1, which had read the agent file and the brief by hand.

### Review outcomes

- 38 of 40 passed first review. Two failed once and passed on the rewrite: 2:13 q4 ("what does al-Burhan hold of the edict") and 2:20 q3 ("what does Ibn Kathir hold the compeers to be"). Both were Perspectives questions that named the scholar or book as the holder of a view, with the other Perspectives positions as distractors. Nothing was parked.
- The reviewer was not consistent on that shape: 2:16 q1 ("How does al-Mizan explain"), 2:22 q4 ("how does Fayd Kashani read") and 2:35 q1 and q3 ("al-Safi") passed with the same construction. The reviewer's reasons were otherwise specific and checkable.
- The validator rejected at least one write on 2:16 (six tool uses, 47K); every other writer got through on the first write.

### Type order across the surah

| order | quizzes |
|---|---|
| MC, whoSaid, MC, TF, whichVerse | 10 |
| MC, whoSaid, MC, TF, fillGap | 9 |
| MC, whoSaid, TF, MC, fillGap | 7 |
| MC, whoSaid, TF, MC, whichVerse | 5 |
| MC, whoSaid, TF, fillGap, MC | 4 |
| MC, TF, MC, whoSaid, whichVerse | 1 |
| whoSaid, MC, TF, MC, fillGap | 1 |
| MC, fillGap, MC, TF, whoSaid | 1 |
| MC, whoSaid, TF, whichVerse, MC | 1 |
| MC, fillGap, TF, whoSaid, MC | 1 |

35 of 40 quizzes open MC then whoSaid. Only five vary the opening (2:9, 2:26, 2:33, 2:39, 2:6). The "q1 from early, q5 from the close" rule plus the adjacency rule pushes the writer to the same shape every time.

### Reader notes (taste, not rule)

- fillGap prompts copied as mid-sentence fragments (2:2 q5); writer could be told to start the gap sentence at a sentence boundary or capitalise. Openers: q1 in 2:1 and 2:2 both "How does <scholar> read..."; watch for sameness.
- whichVerse options with headings can leak the answer when the heading paraphrases the asked point (2:3 q5). Writer could be told: if the heading names the point, ask about something else in that verse or use bare "Verse N" for all four.
- whichVerse option lists mixing headed and bare "Verse N" (2:4 q5) mark the bare one out; T/F that copies a note sentence as True (2:4 q4) is a memory check more than understanding.
- MC options should match in form (2:7 q4: one verbatim quote among paraphrases marks the answer).
- T/F built by flipping one word of the verse translation (2:9 q3, 2:11 q4) is answerable from memory of the verse; T/F should sit on a point the commentary makes. fillGap distractors need to be tempting (2:11 q5 "saddest").
- the one FAIL so far came from a prompt naming a tafsir book (al-Burhan) as the holder of a view; the writer prompt's "not which scholar held a view" line could add "or which book". T/F that reproduces a technical phrase (2:13 q3) rewards recall, not understanding.
- cap verse-translation anchors at one per quiz (2:17 has three); the quiz is meant to check the commentary, and the validator's "three different parts" floor lets translation dominate.
- reviewer inconsistency on book names in prompts (2:13 q4 failed, 2:16 q1 passed); a line in the writer prompt settling it (name the reading, not the book) would remove the coin flip.
- both FAILs so far are "what does <scholar or book> hold" questions on Perspectives; the writer prompt's Perspectives line ("a perspectives question asks what a tradition holds") is being read as licence to name the scholar. Also: when a whichVerse lists headings, check that no heading answers an earlier question (2:20 q5 vs q3).
- whichVerse has two failure modes seen this surah: headings that restate the prompt (2:3, 2:6, 2:12, 2:14, 2:15, 2:19, 2:27) and bare numbers that test numbering (2:28). The fix is in the prompt wording: ask for the verse by a point the commentary makes about it, and give headings that name a different aspect of each verse.
- one question can leak another's answer (2:40 q4 to q5, 2:20 q5 to q3, 2:37 q1 to q5); the writer prompt could add "no option or prompt may contain another question's answer".

### Deviations from the procedure

- Added the pending "not a jab" distractor line to the writer prompt before the run (the open item from the 1:1 run). No jab-shaped distractor appeared in the 40 quizzes.
- Commits were deferred to the end of the surah rather than asked after assembling, so the loop would not block on a question while the user was away.
- Costs were logged for every run, not only the first surah, since this was the first surah run.

### Open after this run

- Writer prompt: (1) whichVerse headings must not restate the asked point, and all four options must be headed or all bare; (2) at most one anchor on a verse translation per quiz; (3) T/F must sit on a point the commentary makes, not a word flip in the verse; (4) no prompt or option may contain another question's answer; (5) "not which scholar or which book held a view" so the reviewer's coin flip on Perspectives questions goes away; (6) fillGap prompts start at a sentence boundary; (7) vary the opening type.
- quiz.py: nothing rule-shaped was missed by the validator this surah. Two candidate checks if wanted: a whichVerse option list that is partly headed and partly bare; a fillGap whose prompt starts lowercase.
- Decide whether the 40 assembled quizzes go out as they are or get a second pass once the writer prompt changes; the passes are rule-clean, the weaknesses above are taste.

## Results - which verse dropped, al-Baqarah re-run (2026-09-12)

After the UI mockup the user cut the `whichVerse` type: a reader has to remember what each numbered verse says to answer it, and the surah 2 reader pass had found its headings gave the answer away in eight quizzes. Changes: `quiz.py` (types, allowed types, count rule: one `fillGap` and one `whoSaid` required, a third `multipleChoice` when `whoSaid` is unavailable, `whichVerse` branch removed), the writer prompt (example q5 is now multiple choice, rules updated, two new lines: no question may contain another's answer, fill-the-gap prompts start at a sentence boundary), the reviewer prompt (rules 6 and 8), and design decision 7. The validator then marked 17 of the 40 al-Baqarah quizzes invalid; each had its which-verse question rewritten as fill the gap and the whole quiz re-reviewed. All 17 passed first time and `quiz_2.json` was re-assembled: 40 quizzes, 80 multiple choice, 40 true or false, 40 fill the gap, 40 who said it. Surah 1 needed nothing.

| passage | new question | review | reader note |
|---|---|---|---|
| 2:3 | q5 fillGap v29 'fashioned it into ____ heavens' (seven) | PASS | guessable from general knowledge, rule-clean |
| 2:4 | q5 fillGap v38 n12 'he is ____' (Ali) | PASS | tests the narration's point; stem is a bare gloss but clear |
| 2:6 | q5 fillGap v59 translation 'a ____ from the sky' (plague) | PASS | verse text; distractors blessing/rain/shelter fit the grammar |
| 2:12 | q5 fillGap v103 translation 'the ____ from Allah would have been better' (reward) | PASS | verse text; distractors mercy/provision/protection plausible |
| 2:14 | q5 fillGap v121 translation 'it is they who are the ____' (losers) | PASS | verse text, guessable; the new rule sends the writer to the passage's close, which is often a verse line |
| 2:15 | q5 fillGap v129 note 'progeny who would live at ____' (Mecca) | PASS | good: tests Tusi's reason for reading the messenger as the Prophet |
| 2:19 | q5 fillGap v163 translation 'Your god is the ____ God' (One) | PASS | weak: 'Only' and 'True' are near-synonyms of the answer, only verbatim recall separates them |
| 2:20 | q5 fillGap v167 essay 'regret attaches only to what is ____' (past) | PASS | good: the essay's closing point, not verse text |
| 2:25 | q5 fillGap v209 translation 'stumble after ____ that have come to you' (the manifest proofs) | PASS | verse text; distractors are other set phrases from the passage |
| 2:27 | q5 fillGap v221 translation 'though she should ____ you' (impress) | PASS | weak: tempt/please are near-synonyms, separated only by the translator's word |
| 2:28 | q5 fillGap v228 n13 'in which the ____ is held back and gathered' (blood) | PASS | narration's point on quru; fair |
| 2:31 | q5 fillGap v242 translation 'so that you may exercise your ____' (reason) | PASS | verse text, common line; guessable |
| 2:32 | q5 fillGap v248 note 'calm God placed in the ____' (Ark) | PASS | commentary point; 'tabernacle' and 'sanctuary' are fair traps |
| 2:33 | q4 fillGap v251 translation 'Allah gave him ____' (kingdom and wisdom) | PASS | verse text; distractors are phrases from elsewhere in the passage, fair |
| 2:36 | q5 fillGap v266 translation 'so that you may ____' (reflect) | PASS | weak: closing formula, 2:31 got the near-identical 'exercise your reason' line |
| 2:37 | q5 fillGap v273 translation 'You recognize them by their ____' (mark) | PASS | verse text; clothing/speech are tempting |
| 2:38 | q5 fillGap v281 translation 'recompensed fully for what it has ____' (earned) | PASS | weak: 'done' fits the sense; verbatim recall decides |

### Costs

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer (rewrite one question) | 17 | 28K | 24K to 40K | 1 min 43 s | 488K tokens, 29 min |
| reviewer | 17 | 21K | 20K to 24K | 0 min 59 s | 366K tokens, 16 min |

About 0.85M agent tokens for the 17, roughly 50 minutes wall clock with two slots. The prompt told the writer the type had been removed and which question to replace, since the writer's own rewrite path reads the latest review, which had every question ok.

### Reader notes

- Twelve of the 17 new gaps sit on a verse translation, and seven of those are closing formula lines a reader knows by heart (2:3 seven heavens, 2:14 losers, 2:19 One, 2:27 impress, 2:31 reason, 2:36 reflect, 2:38 earned; 2:31 and 2:36 got near-identical 'clarify His signs so that you may ...' lines). Cause: the prompt asked for a gap 'from late in the passage' and the 'q5 from the close' rule, so the writer reached for the last verse.
- The five gaps on commentary or narrations are the good ones: 2:4 'he is Ali' (n12), 2:15 'live at Mecca' (Tusi's reason), 2:20 'regret attaches only to what is past' (essay), 2:28 'the blood is held back' (n13), 2:32 'placed in the Ark' (Tabrisi).
- The reviewer now checks the two new rules (sentence-boundary prompts, cross-question leaks) and cited them in its reasons; none of the 17 tripped either.

### Open after this run

- Writer prompt: 'q5 from its close' should mean the essay's closing paragraph or the perspectives, not the last verse; and cap verse-translation anchors at one per quiz (still pending from the surah 2 run). Both would have changed most of the 12 verse-text gaps above.
- UI: mockup at https://claude.ai/code/artifact/4f154cf1-728e-4668-9d98-a8541618eb29 (list swipe with a third Quiz action, Test yourself beside Mark as read, question, answered and results screens, three other framings). Results screen ends on Try again and Back to passage, no Next passage. App-side design still to be written from it.
