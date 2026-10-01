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

## Results - Aal-i-Imraan 3:1 to 3:20 (2026-09-15)

Run under `/loop` from `/quiz next one until surah 14`. All 20 quizzes passed their first review; `quiz_3.json` assembled with 20 quizzes: 40 multiple choice, 20 true or false, 20 fill the gap, 20 who said it. Before the run the four open writer-prompt items from the surah 2 reports were added to the writer's "How to write" section: at most one anchor per quiz on a verse translation; "the close" means the essay's closing paragraph or the perspectives, not the last verse; true or false sits on a commentary point, never a verse line with one word flipped; no book title names the holder of a view; and a new line asking the writer to vary the opening type.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 3:1 | MC, TF, MC, fillGap, whoSaid | 1 PASS | good: q2 T/F on a narration point, q4 "mother of the Book"; q1 distractors weak |
| 3:2 | MC, whoSaid, fillGap, TF, MC | 1 PASS | two translation anchors (q3, q5); q3 gap "wares" is translator recall, "gardens" a distractor nobody picks |
| 3:3 | TF, MC, whoSaid, MC, fillGap | 1 PASS | strong; q5 gap "taqiyya" on the perspectives, but the 35-word prompt nearly names it |
| 3:4 | whoSaid, MC, TF, fillGap, MC | 1 PASS | strong; q4 "A Word of Allah is ____" answerable without the note, prompt lists four commentators |
| 3:5 | fillGap, whoSaid, MC, TF, MC | 1 PASS | q1 "muhaddatha" is the only Arabic term among English distractors; q4 T/F on what "by Allah's leave" qualifies is recall |
| 3:6 | fillGap, MC, TF, whoSaid, MC | 1 PASS | q4 quote "myself and my brother ... Fatimah my mother" makes whoSaid a Hasan/Husayn coin flip; q1 gap prompt 40 words |
| 3:7 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q1 gap "lord" is the verse's famous phrase; q2, q4, q5 good commentary checks |
| 3:8 | whoSaid, MC, fillGap, TF, MC | 1 PASS | three narration anchors; q3 gap "trust" is a strong meaning gap |
| 3:9 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 quote is a bare verse paraphrase so the speaker is a guess; q4 "illusion" and q5 "both traditions agree" are good |
| 3:10 | fillGap, whoSaid, MC, TF, MC | 1 PASS | q1 "khums" beside anfal and fay is fillable without the note; q3 first-house-for-worship good |
| 3:11 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q2 "saved you from it" is the model question; q4 T/F on a narration's point |
| 3:12 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q4 40-word gap prompt hands over "God" in its second half; q3 T/F "only a single reading" is about the note, not the meaning |
| 3:13 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q4 "tooth" is a known Uhud detail; q2 why a Badr verse sits in the Uhud story is a real understanding question |
| 3:14 | TF, MC, whoSaid, fillGap, MC | 1 PASS | best of the surah: Uhud spoils reproof, night-and-day riposte, usury definition |
| 3:15 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 "I will fight for what he fought for" points at Ali; q4 gap prompt 32 words |
| 3:16 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q1 quote is an occasion report with no personal voice, speaker a guess among four; q2, q4, q5 good |
| 3:17 | fillGap, whoSaid, MC, TF, MC | 1 PASS | q1 opens on a minor gloss ("trade") with a 30-word prompt; q4 Imams vs believers and q5 barzakh are good |
| 3:18 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q1 "disobeyed" is a tight one-line gap, the best gap shape; q4 is the only True answer in the surah |
| 3:19 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q5 T/F "same direction" is a smart way to quiz the comparison without siding; q2 "basin" is recall |
| 3:20 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 ruin quote vivid; q5 keep-and-add framing good; q4 "Negus" is name recall |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 20 | 44K | 34K to 67K | 5 min 9 s | 886K tokens, 103 min |
| reviewer | 20 | 23K | 22K to 26K | 1 min 13 s | 470K tokens, 24 min |

About 1.36M agent tokens for the surah, roughly 95 minutes wall clock with two slots. Writers are heavier than in surah 2 (28K mean for a one-question rewrite there; a full write with the longer prompt is 44K).

### Review outcomes

20 of 20 PASS first time. No rewrites, nothing parked. Two writers had their first Write rejected by the validator because the anchor quote crossed a curly-quoted phrase in the brief (3:18 n3, 3:19 perspectives); both shortened the quote and passed on the second Write.

### Type order across the surah

| opener | count |
|---|---|
| whoSaid | 7 |
| fillGap | 7 |
| MC | 3 |
| TF | 3 |

The vary-the-opening line worked: surah 2 opened MC then whoSaid in 35 of 40, here only 3 of 20 open MC. The sameness moved to the close: 18 of 20 end on MC, because "q5 from the essay's close or the perspectives" is nearly always answered with a multiple choice on the perspectives. 3:3 (fillGap on the perspectives) and 3:19 (T/F on the perspectives) show the other two shapes work.

Translation anchors: 3 in the surah (3:1 q4, 3:2 q3 and q5); only 3:2 broke the one-per-quiz cap, against 12 of 17 gaps on verse text in the surah 2 re-run. True or false: 19 of 20 answers are False; the "false about half the time" line is ignored because the writer builds each statement as the negation of the note.

### Reader notes (taste, not rule)

- whoSaid has two weak shapes: a quote with no personal voice (3:9 verse paraphrase, 3:16 occasion report) where the speaker is a guess among Imams; and a quote that names the speaker's own relations (3:6 "my brother ... my mother", 3:15 "what he fought for") where it is a giveaway. The good ones are sayings with a voice: 3:8 the trust, 3:12 "a best nation that kills...", 3:20 the ruin.
- fillGap prompts run to 30 to 40 words for a one-word gap (3:6, 3:12, 3:15, 3:17); 3:18's twelve-word "at Uhud both had been ____" is the shape to ask for. Several gaps sit on a term the reader knows before reading (3:7 lord, 3:10 khums, 3:13 tooth, 3:4 Messiah, 3:20 Negus); the good gaps are the commentator's reason or gloss (3:9 illusion, 3:8 trust, 3:18 disobeyed, 3:3 taqiyya).
- Perspectives questions found three safe framings this surah: what one named scholar holds and why (3:4, 3:10), what both traditions agree on (3:9), and whether the traditions apply a principle the same way (3:19 T/F). None was flagged for side-taking.
- T/F built as "the note says X, prompt says not-X" is now the default; the one True (3:18) reads as a memory check. Better T/F either state a claim the commentary makes in other words, or negate a claim a skimmer would assume.

### Deviations from the procedure

- The four open writer-prompt items from the surah 2 reports and a vary-the-opening line were added before the run, as the "not a jab" line was before surah 2.
- Commits deferred to the end of the loop rather than after this surah, so the loop does not block while the user is away.
- The 4:1 writer was launched in the free slot while 3:20 was still in review, before surah 3 was assembled.
- Costs logged for every run, since the writer prompt changed.

### Open after this run

- Writer prompt: (1) whoSaid quotes must carry the speaker's own voice, never a bare verse paraphrase or a third-person occasion report, and never name the speaker's own relations; (2) fillGap prompts at most about 15 words, and the gap sits on the commentator's reason or gloss, not a term the reader knows before reading; (3) make half the T/F statements True by restating a commentary claim in other words; (4) let q5 take any type, so the close is not always multiple choice.
- quiz.py: anchor matching could normalise curly quotes on both sides, which would have saved the two rejected first Writes. Nothing rule-shaped was missed by the validator.

## Results - An-Nisaa 4:1 to 4:24 (2026-09-15)

Same `/loop` run. All 24 quizzes passed their first review; `quiz_4.json` assembled with 24 quizzes: 48 multiple choice, 24 true or false, 24 fill the gap, 24 who said it. After surah 3's report, four more lines went into the writer's "How to write" section before 4:3 was launched (4:1 and 4:2 were written on the surah 3 prompt): who-said-it quotes must carry the speaker's own voice (no verse paraphrase, no third-person occasion report, no line naming the speaker's own relations or deeds); fill-the-gap prompts about fifteen words with the gap on the commentator's reason or gloss, not a term the reader already knows; true or false True about half the time by restating a commentary claim; and q5 may be any type.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 4:1 | TF, MC, whoSaid, fillGap, MC | 1 PASS | old prompt; q2 orphan-girls reason and q5 Tabrisi reading good; q4 gap "heirs" guessable from "bequest that damages the" |
| 4:2 | fillGap, whoSaid, MC, TF, MC | 1 PASS | old prompt; q1 gap "family's" is a thin possessive; kalala and two-sixths questions are understanding |
| 4:3 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q2 "before death" with "at the final breath" as the trap is a fine distinction; q3 gap on a commentator reading |
| 4:4 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q1 gap "acts" on Tabrisi's principle; q2 Khawarij stepdaughter answer; first True close |
| 4:5 | MC, fillGap, whoSaid, TF, MC | 1 PASS | q3 "in the book of Ali: seven" is distinctive; q4 True restates the note |
| 4:6 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 who appoints the arbiters, with "the husband" as a tempting trap; q4 gap "disbeliever" follows from "the faithless" in the prompt |
| 4:7 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q1 gap "face" of the earth with dust/clay/sand; q5 self-purification is the essay's point |
| 4:8 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q3 broken-brick saying vivid; q5 infallibility ground is the key argument; q4 True on a reason |
| 4:9 | fillGap, MC, TF, whoSaid, MC | 1 PASS | q2 mediator-not-verdict good; q4 short saying, speaker a guess between al-Baqir and al-Sadiq |
| 4:10 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q1 twelve-word gap on a narration gloss, the shape asked for; q5 doubt-vs-proof |
| 4:11 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q4 nine-word gap "returning it is obligatory" with "recommended" as the trap, model gap; q5 "lying comes of need" |
| 4:12 | MC, whoSaid, TF, MC, fillGap | 1 PASS | q5 seven-word gap on the essay's thesis ("conduct, not profession"), ideal close; q3 T/F on Banu Mudlij |
| 4:13 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 covenant reason and q5 best-reward-for-all distinction; q4 gap "chronically disabled" given away by "the blind" |
| 4:14 | fillGap, TF, MC, whoSaid, MC | 1 PASS | q1 gap "goad" short and metaphor-bearing; q5 tagged v100 though it glosses v97 (reviewer noted, answerable) |
| 4:15 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q3 gap "praying" with "facing the enemy" as the trap; q4 why al-Baqir cites Sulayman |
| 4:16 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 rebuke to Abu Hanifah has a strong voice; q5 Bashir's end is a story check |
| 4:17 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q1 effect-not-intent True opener; q2 quote names prophets and Imams so any Imam fits |
| 4:18 | whoSaid, MC, TF, MC, fillGap | 1 PASS | q1 three kinds of injustice is a known Ali line; q5 gap "partitive" is the only technical word among plain distractors |
| 4:19 | TF, fillGap, MC, whoSaid, MC | 1 PASS | q3 affection-not-maintenance is a fine distinction; q5 distractors odd but the answer is the essay point |
| 4:20 | TF, MC, whoSaid, MC, fillGap | 1 PASS | q2 unfold-a-summary-faith and q4 forbidding wrong for the able; q5 gap ends with no punctuation (span match forced it) |
| 4:21 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q1 "little" because for other than Allah; q3 al-Tusi on the lowest reach |
| 4:22 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q3 gap "being pleased with the deed" with "descent" as the exact skimmer's trap, best gap of the surah; al-Sajjad whoSaid has bite |
| 4:23 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q4 gap "Mary" with "the Holy Spirit" as trap tests the passage's distinctive reading |
| 4:24 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q5 closes-where-it-opened structural check; q3 gap "plain" on Qurtubi's reason |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 24 | 54K | 37K to 75K | 7 min 8 s | 1.30M tokens, 171 min |
| reviewer | 24 | 23K | 21K to 27K | 1 min 16 s | 561K tokens, 30 min |

About 1.86M agent tokens for the surah, roughly 110 minutes wall clock with two slots. The writer is a quarter heavier than in surah 3 (54K against 44K, 7 min against 5) after the four new prompt lines; the reviewer is unchanged.

### Review outcomes

24 of 24 PASS first time. No rewrites, nothing parked. Three writers had a first Write rejected by the validator and fixed it themselves: 4:8 (fill-the-gap prompt reworded as "Scholar holds that..." instead of a verbatim span), 4:10 (who-said-it speaker had to match the brief's exact spelling "the Messenger of God"), 4:20 (a trailing full stop on the gap prompt broke the exact-span match because the source runs into a semicolon).

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 9 | | MC | 18 |
| fillGap | 7 | | TF | 3 |
| whoSaid | 5 | | fillGap | 3 |
| MC | 3 | | | |

Openers stay varied. The "q5 may be any type" line moved 6 of 24 closes off multiple choice (2 of 20 in surah 3); the rest still close on a multiple choice about the perspectives or the essay's last paragraph. Translation anchors: 0 in the surah. True or false: 16 of 24 True (1 of 20 in surah 3), so the "half True" line overshot but the statements now restate a claim rather than flip a note. Gap prompts: 10 of 24 still run past 20 words (longest 31), the rest sit at 7 to 15; the short ones (4:10, 4:11, 4:12, 4:14, 4:15, 4:22) are the surah's best questions.

### Reader notes (taste, not rule)

- The new who-said-it line shows in the quotes chosen: 4:16 the rebuke to Abu Hanifah, 4:8 the broken brick, 4:6 the tooth-stick, 4:5 "in the book of Ali: seven", 4:22 al-Sajjad on the heavens. Still guessable where the saying is a general maxim (4:9 submission, 4:19 God-wariness) or names the Imams as a class (4:17).
- Gaps on the commentator's reason are now the norm and the best of them beat anything in surahs 2 and 3: 4:22 "being pleased with the deed" against "descent from those killers", 4:12 "conduct, not profession", 4:11 "obligatory" against "recommended", 4:23 "Mary" against "the Holy Spirit". Weak ones give the answer in the prompt's other clause (4:6 "the faithless" to "disbeliever", 4:13 "the blind" to "chronically disabled") or gap a technical word among plain ones (4:18 "partitive").
- True statements that restate a claim read well (4:17 effect-not-intent, 4:8 why the shade is deep, 4:15 the Ahl al-Bayt ruling); the False ones are still note-with-one-word-reversed (4:1, 4:2, 4:14, 4:20, 4:22). Aim for a mix nearer half.
- Perspectives questions kept to the safe framings (one named scholar's reason, a reported majority view, a T/F on an attributed position); no side-taking flagged in 24 reviews.

### Deviations from the procedure

- Four writer-prompt lines added mid-surah, after 4:1 and 4:2 had been written on the surah 3 prompt; the surah 3 report's open items were applied without waiting for the user, as before.
- 5:1 launched in the free slot while 4:24 was still being written; surah 4 was assembled after 4:24 passed.
- Commits deferred to the end of the loop.

### Open after this run

- Writer prompt: (1) "about fifteen words" for gap prompts is being read loosely; say "at most twenty words" if the long ones matter; (2) the True share overshot to two thirds, so say "about half"; (3) a gap's other clause must not paraphrase the answer (4:6, 4:13).
- quiz.py: the fill-the-gap span match could tolerate a trailing full stop on the prompt (4:20), and the anchor match could normalise curly quotes (carried from surah 3). Also worth a check: a question's `verse` should match the verse its anchor sits on (4:14 q5 tagged v100 on a v97 gloss); the validator only checks the verse is inside the passage.

## Results - Al-Maaida 5:1 to 5:16 (2026-09-15)

Same `/loop` run, on the writer prompt as refined after surah 4 (gap prompts at most twenty words and the other clause must not paraphrase the answer; True about half, not more). 15 of 16 passed first review; 5:13 failed once and passed on its second review. `quiz_5.json` assembled with 16 quizzes: 32 multiple choice, 16 true or false, 16 fill the gap, 16 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 5:1 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q3 gap "wilaya" against three other obligations is a real narration point; q5 slaughter reason understanding |
| 5:2 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q3 gaps "wilaya" again, back to back with 5:1; q1 who-said-it prompt is a 35-word paraphrase, not a quote |
| 5:3 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q4 gap "Commander of the Faithful ... and the Imams" is given away by its second half; q5 why the gap in apostles is stressed is good |
| 5:4 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q3 gap "four leagues" with "the whole earth" as the verse-echo trap; q4 earth-turned quote vivid |
| 5:5 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q2 gap "patient endurance" against "equal retaliation" is a strong gap; q4 giving-it-life comparison |
| 5:6 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q3 T/F on the timing of Safwan's pardon is a real understanding check; q4 nine-word gap "bribe" |
| 5:7 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q4 gap "two cases" with "two witnesses" as trap; q2 is the surah's one translation anchor |
| 5:8 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q4 wali as awla is the key point; q5 True on the ring narration is well known, recall |
| 5:9 | MC, TF, whoSaid, MC, fillGap | 1 PASS | q1 why befriending mockers is forbidden and q4 "hand is tied" meaning are strong; q5 gap "Islam" easy |
| 5:10 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q1 Ghadir declaration is a gimme who-said-it; q3 gap "love" on will versus approval is a real theological point (prompt lacks closing punctuation) |
| 5:11 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q2 forbidding-wrong proof and q5 taqiyya rule good; q3 gap "tyrant" against believing/righteous thin |
| 5:12 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q2 frivolous-oath definition and q5 rebuke of self-denial; q3 chess-and-nuts saying distinctive |
| 5:13 | whoSaid, MC, fillGap, MC, TF | 2 (FAIL, PASS) | q3 first gapped "salted fish" for the sea's food, which Perspectives marks as a Shia/Sunni divide; rewritten to the atonement counterparts (ostrich to camel) |
| 5:14 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q3 "This verse was revealed concerning ____" (taqiyya) is a bare five-word prompt, third wilaya/taqiyya gap in the surah; q4 False on Magian witnesses is a real detail |
| 5:15 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q2 "one who has a mother is no god" is the essay's argument; q4 gap "certainty" on why the disciples asked |
| 5:16 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q2 why "son of Mary" names the mother is a strong essay check; q3 gap "seizing" not death |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer (16 writes, 1 rewrite) | 17 | 55K | 40K to 85K | 7 min 25 s | 931K tokens, 126 min |
| reviewer | 17 | 23K | 21K to 32K | 1 min 21 s | 394K tokens, 23 min |

About 1.33M agent tokens for the surah, roughly 80 minutes wall clock with two slots. The one FAIL cost a 42K rewrite and a 23K second review. 5:9's writer was the heaviest of the run so far (85K, 14 min).

### Review outcomes

15 of 16 PASS first time; 5:13 FAIL then PASS. The FAIL was the reviewer's rule 5 (taking a side in Perspectives): the gap sat on a narration's gloss ("salted fish" for the sea's food) that the passage's own Perspectives section names as the point where Tabrisi and Ibn Kathir divide. The reviewer called it a judgment call; the writer prompt has no line for it, since the question was anchored on a verse note narration, not on the perspectives. The rewrite kept the other four questions byte for byte. No validator rejections this surah.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| whoSaid | 7 | | MC | 10 |
| TF | 6 | | TF | 5 |
| MC | 2 | | fillGap | 1 |
| fillGap | 1 | | | |

Closes off multiple choice: 6 of 16 (6 of 24 in surah 4, 2 of 20 in surah 3). True or false: 13 of 16 True; the "about half, not more" line has not pulled it back. Translation anchors: 1 (5:7 q2). Gap prompts: 1 of 16 over 20 words (5:2, 28 words), against 10 of 24 in surah 4, so "at most twenty" landed.

### Reader notes (taste, not rule)

- Three gaps in the surah sit on "wilaya" or "taqiyya" (5:1, 5:2, 5:14) and two more name the Imams or the Commander of the Faithful as the answer (5:3, 5:8 T/F). Each is fair on its own passage, but a reader doing al-Maaida in order meets the same answer five times. A surah-level check for repeated gap answers would catch it.
- Who-said-it is the weakest type where the saying is famous (5:10 Ghadir) or where the prompt is a paraphrase rather than a quote (5:2). The good ones remain the distinctive glosses: 5:11 pigs and monkeys, 5:12 chess and nuts, 5:13 hands and spears, 5:16 "he has not said it, and he will say it".
- Short gaps on a commentator's reason are now the norm: 5:5 "patient endurance", 5:7 "two cases", 5:15 "certainty", 5:16 "seizing". Two gaps still give the answer away in the other clause (5:3 "and the Imams", 5:6 none).
- Perspectives questions kept to the safe framings, and the one failure came from a verse-note narration whose gloss happened to be the disputed point. That is a reviewer catch the writer cannot anticipate from the brief's anchor list alone; a line telling the writer to check the perspectives before gapping any narration gloss on a verse the perspectives discuss would cover it.

### Deviations from the procedure

- Two small writer-prompt refinements (gap prompt at most twenty words, True about half not more, the other clause must not paraphrase the answer) were applied after the surah 4 report, before 5:4 was launched; 5:1 to 5:3 were written without them.
- 6:1 launched in the free slot while 5:16 was still being written; surah 5 was assembled after 5:16 passed.
- Commits still deferred to the end of the loop.

### Open after this run

- Writer prompt: (1) before gapping or quizzing a narration's gloss, check whether the perspectives name that gloss as a point of difference between the traditions, and if so ask about something else (5:13); (2) True or false has run 13 of 16 True; the line may need "make two or three of every five quizzes False".
- quiz.py or the assemble step: a surah-level scan for repeated fill-the-gap answers (5:1, 5:2 and 5:14 all gap wilaya or taqiyya) and repeated who-said-it quotes, reported as a warning.

## Results - Al-An'aam 6:1 to 6:20 (2026-09-15 to 16)

Same `/loop` run, on the writer prompt as refined after surah 5 (check the perspectives before quizzing a narration's or note's gloss; two or three quizzes in five should have a False answer). 19 of 20 passed first review; 6:7 failed once and passed on its second review. `quiz_6.json` assembled with 20 quizzes: 40 multiple choice, 20 true or false, 20 fill the gap, 20 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 6:1 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q1 three orders is a strong structure check; q3 gap "suspended" term with "fixed" as trap tests the two-terms point |
| 6:2 | whoSaid, MC, TF, MC, fillGap | 1 PASS | q2 proof of the Resurrection and q5 gap "revelation" against "reason"; q1 quote is a general maxim |
| 6:3 | MC, whoSaid, MC, TF, fillGap | 1 PASS | q4 False on the Abu Talib reading is a good shape (what a tradition rejects); q2 pardon quote vivid |
| 6:4 | TF, MC, fillGap, MC, whoSaid | 1 PASS | q3 "patience is to faith as the head to the body" is a famous line, recall; q1 False on the three foundations good |
| 6:5 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q4 hardship versus punishment and q5 False on the blind/seer gloss are understanding |
| 6:6 | MC, whoSaid, TF, MC, fillGap | 1 PASS | q3 lam-of-outcome False is a fine point; q5 shared-agreement gap "honour" |
| 6:7 | TF, MC, fillGap, whoSaid, MC | 2 (FAIL, PASS) | q5 "what does Tusi hold about the Unseen" failed as scholar attribution, a framing many earlier reviews passed; rewritten to the shared gloss of the keys of the Unseen |
| 6:8 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 repeats 6:7 q4 (same angel-of-death narration, same speaker) back to back; q3 and q5 understanding |
| 6:9 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q2 Azar as grandfather or uncle and q5 why Abraham did not speak in belief are the key Shia points, framed as attributed readings |
| 6:10 | MC, fillGap, whoSaid, TF, MC | 1 PASS | q1 debate-is-sound conclusion strong; q2 gap "succession" with "prophethood" as trap |
| 6:11 | MC, whoSaid, TF, MC, fillGap | 1 PASS | q3 False on al-Ummi is the best T/F of the surah; q5 gap "transcendence" is a bare seven-word prompt |
| 6:12 | whoSaid, MC, TF, MC, fillGap | 1 PASS | q2 why not travel early in the night; q5 gap "angels" given away by "hidden from sight" |
| 6:13 | TF, MC, fillGap, MC, whoSaid | 1 PASS | q4 why abusing idols was forbidden is the best question here; q2 "what do commentators divide over" neutral |
| 6:14 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q3 judge-not-ruler reason strong; q5 forgetful omission ruling framed as the Imams' ruling |
| 6:15 | TF, MC, whoSaid, MC, fillGap | 1 PASS | q4 punishment-not-barring well framed; q5 gap "choice" on Tabatabai's theodicy, prompt lacks closing punctuation |
| 6:16 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q2 proof before punishment and q5 refuting compulsion; q1 who-said-it is a bare report |
| 6:17 | MC, fillGap, TF, whoSaid, MC | 1 PASS | q1 God-alone-produces argument and q5 harvest due apart from zakat; q3 False on "and back" a fine catch |
| 6:18 | whoSaid, TF, MC, fillGap, MC | 1 PASS | q4 gap "intellects" for the inward proof is the best question; q1 al-Baqir ruling has a voice |
| 6:19 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q1 gap "forgiveness" on why shirk stands first, with "mercy" as trap; q5 "read it the same way" False |
| 6:20 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q1 repeats 6:1 q2 (the all-at-once revelation narration); q3 gap "concealment" striking |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer (20 writes, 1 rewrite) | 21 | 54K | 32K to 75K | 7 min 25 s | 1.14M tokens, 155 min |
| reviewer (20 first, 1 second) | 21 | 22K | 21K to 26K | 1 min 11 s | 468K tokens, 25 min |

About 1.61M agent tokens for the surah, roughly 100 minutes wall clock with two slots. Four writers had a first Write rejected and fixed it themselves (6:8 twice: a lead-in that was not a verbatim span, then a trailing full stop; 6:15 a trailing full stop against a space-semicolon in the essay).

### Review outcomes

19 of 20 PASS first time; 6:7 FAIL then PASS. The FAIL was rule 4 (scholar attribution) on "what does Tusi hold about knowledge of the Unseen", a "what does <scholar> hold" framing on the perspectives that the reviewer accepted in at least fifteen other quizzes across surahs 3 to 6 (4:3 q5, 4:24 q3, 5:6 q5, 6:4 q4, 6:14 q5, 6:15 q4, 6:17 q5, 6:18 q5 among them). This is the same coin flip the surah 2 report recorded. The rewrite replaced it with the two traditions' shared gloss ("five matters known to God alone"), the framing that has never failed.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 7 | | MC | 9 |
| TF | 7 | | fillGap | 6 |
| whoSaid | 5 | | TF | 3 |
| fillGap | 1 | | whoSaid | 2 |

Closes are now genuinely mixed: 11 of 20 end on something other than multiple choice (6 of 24 in surah 4, 6 of 16 in surah 5). Gap prompts: none over 20 words. Translation anchors: 3 (6:1, 6:6, 6:8), all inside the one-per-quiz cap. True or false: 2 of 20 True. The "two or three in five should be False" line sent the writer to nearly all False, as the "True about half" line had sent it to nearly all True in surahs 4 and 5; the writer treats each ratio line as a rule to satisfy every time rather than a mix to aim at.

### Reader notes (taste, not rule)

- Two narrations were quizzed twice in the surah, once each in neighbouring quizzes: the angel-of-death helpers (6:7 q4 who-said-it, 6:8 q1 who-said-it, same speaker) and the all-at-once revelation with seventy thousand angels (6:1 q2 who-said-it, 6:20 q1 T/F). The passages share the narration, so the writer cannot see the repeat from one brief; the surah-level scan proposed after surah 5 would catch both.
- The neutral perspectives shapes held up: what both traditions share (6:6, 6:7 rewrite), what they divide over (6:13, 6:20), whether they read a verse the same way (6:19 False), what one tradition rejects (6:3 Abu Talib False). "What does <named scholar> hold" is the one shape that draws the reviewer's coin flip.
- Gaps are short and mostly on a commentator's reason (6:19 forgiveness, 6:10 succession, 6:18 intellects, 6:15 choice); the weak ones are bare glosses with no surrounding sense (6:11 "pure ____", 6:12 "angels" given away by "hidden from sight").
- Who-said-it still splits between voiced sayings (6:3 pardon, 6:8 tooth-stick, 6:12 two clays, 6:18 al-Baqir's ruling) and bare reports where the speaker is a guess (6:2, 6:16).

### Deviations from the procedure

- The two surah 5 lines (perspectives check, False share) were added to the writer prompt before 6:1 launched; all 20 were written on the same prompt.
- 7:1 launched in the free slot while 6:20 was still being written; surah 6 was assembled after 6:20 passed.
- Commits still deferred to the end of the loop.

### Open after this run

- Writer prompt: replace the ratio wording for true or false with a concrete instruction the writer can satisfy per quiz without over-correcting across the surah, for example "alternate: if the passage index is odd make the statement True, if even make it False". Also: prefer the shared, divided-over, same-way and rejected framings for perspectives questions over "what does <scholar> hold", which the reviewer sometimes reads as attribution.
- quiz.py or assemble: the surah-level repeat scan (gap answers, who-said-it narration ids) would have flagged 6:7/6:8 and 6:1/6:20. Still open: trailing punctuation tolerance in the gap span match (three writers hit it this surah) and curly-quote normalisation.

## Results - Al-A'raaf 7:1 to 7:24 (2026-09-16)

Same `/loop` run, on the writer prompt as refined after surah 6 (true or false alternates by passage index; prefer the perspectives framings that name no side). All 24 passed first review; no rewrites and no validator rejections reported. `quiz_7.json` assembled with 24 quizzes: 48 multiple choice, 24 true or false, 24 fill the gap, 24 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 7:1 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q3 gap "triumph" against reward/guidance/mercy is near-synonym recall; q2 haraj gloss fair |
| 7:2 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 Iblis argued by analogy is strong; q4 gap "envy" with knowledge/wheat/immortality as the traps a reader brings is excellent |
| 7:3 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q5 held-together framing has distractors nobody picks; q1 garment-of-Godwariness has a voice |
| 7:4 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q5 rhetorical-question force is a good essay check; q4 gap "angel of death" with "Imam of the age" as trap |
| 7:5 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q2 compulsionists' view is a real check; q1 gap "believers" guessable from "gates open for them" |
| 7:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q3 gap "leave" for "forget" is a real narration gloss; q4 structural turn-back |
| 7:7 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q2 six-days reason has a voice; q4 winds as proof of resurrection |
| 7:8 | fillGap, whoSaid, MC, TF, MC | 1 PASS | q5 shared point with the divergences as distractors is a clever neutral shape; q1 gap "prophethood" good |
| 7:9 | TF, MC, whoSaid, MC, fillGap | 1 PASS | q5 gap "phrase" ("they part on one ____") is a meta-gap with no content, weakest close |
| 7:10 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q1 why "she-camel of Allah"; q3 weeping-on-entry saying distinctive |
| 7:11 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q1 how a sign came without a named miracle and q3 not-every-act-is-disbelief are strong |
| 7:12 | fillGap, MC, TF, whoSaid, MC | 1 PASS | q3 False on istidraj is a strong check; q1 gap "law of history" |
| 7:13 | TF, MC, whoSaid, MC, fillGap | 1 PASS | q5 gap "dark-skinned" given away by "so the whiteness stood out"; q4 change of style |
| 7:14 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q2 Pharaoh's promise reveals weakness; q3 gap "Shu'ayb" in the staff chain |
| 7:15 | MC, TF, whoSaid, MC, fillGap | 1 PASS | q4 land passes between nations; q5 gap "promise" is an eight-word shared-point gap |
| 7:16 | MC, TF, whoSaid, fillGap, MC | 1 PASS | q5 bound-to-the-senses reading and q2 False on the ill omens are understanding |
| 7:17 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q3 gap "surplus of knowledge" strong; q4 True on Tusi's point about the arrogant |
| 7:18 | MC, TF, MC, whoSaid, fillGap | 1 PASS | q1 sense-bound people; q5 gap "diverge" is a second meta-gap |
| 7:19 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 tablets picked up shows no turning from the Torah; q4 gap ummi as mother-town |
| 7:20 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q1 ummi gap repeats 7:19 q4 back to back (and 6:11 q3); q4 why the plague came |
| 7:21 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q2 forbidding wrong stays obligatory is strong; q1 gap "catch" on Satan's whisper clever |
| 7:22 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q3 leading astray on Resurrection Day and q2 "Greatest Name" with "gift of prophecy" as the essay-rejected trap are strong |
| 7:23 | whoSaid, MC, TF, MC, fillGap | 1 PASS | q5 gap "free will" is a third meta-gap; q1 istidraj gloss has a voice |
| 7:24 | whoSaid, TF, MC, fillGap, MC | 1 PASS | q3 idols create nothing; q4 gap "holds back" on the Godwary's remembrance |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 24 | 55K | 42K to 77K | 7 min 43 s | 1.33M tokens, 185 min |
| reviewer | 24 | 22K | 20K to 23K | 1 min 5 s | 522K tokens, 26 min |

About 1.85M agent tokens for the surah, roughly 120 minutes wall clock with two slots.

### Review outcomes

24 of 24 PASS first time. The cleanest surah so far: no FAIL, no rewrite, and no validator rejection reported by any writer.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| whoSaid | 9 | | MC | 10 |
| MC | 8 | | TF | 9 |
| fillGap | 5 | | fillGap | 5 |
| TF | 2 | | | |

True or false: 12 of 24 True, exactly half; the alternate-by-passage-index rule did what the ratio wording never managed (1 of 20, 16 of 24, 13 of 16, 2 of 20 in surahs 3 to 6). Translation anchors: 7, all within the one-per-quiz cap. Gap prompts: 1 of 24 over 20 words (7:16, 22 words). Perspectives anchors: 23 of 24 quizzes carry a perspectives question.

### Reader notes (taste, not rule)

- The neutral perspectives framings recommended after surah 6 are now in almost every quiz and have gone formulaic. Three closes gap a word that describes the disagreement rather than its content (7:9 "they part on one phrase", 7:18 "the traditions diverge", 7:23 "divide over free will"), and eight more ask "what do they divide over" or "do they read it the same way". These test whether the reader noticed that the perspectives section disagrees, not what either tradition says. The good perspectives questions test content: 7:8 the shared point with the two divergences as distractors, 7:22 the shared reading of the covenant, 7:2 al-Tusi on Adam's "sin" with wrong readings as distractors.
- Best questions of the surah test a commentator's reason: 7:2 Iblis and analogy, 7:12 istidraj, 7:21 forbidding wrong stays obligatory, 7:11 how a sign came without a named miracle, 7:22 leading astray on Resurrection Day.
- Gaps: strong when the distractors are what a reader brings from elsewhere (7:2 "envy" against knowledge/wheat/immortality, 7:22 "Greatest Name" against "gift of prophecy"), weak when the other clause gives the answer (7:13 "dark-skinned ... so the whiteness stood out", 7:5 "believers ... gates open").
- Repeat across neighbours: the ummi gloss (Mecca as mother of towns, not illiteracy) is 7:19 q4 and 7:20 q1, and was 6:11 q3. Who-said-it openers ran 9 of 24 with a stretch of three in a row (7:1 to 7:3).

### Deviations from the procedure

- Two writer-prompt lines from the surah 6 report were added before 7:2 launched (7:1 was written on the surah 5 prompt).
- 8:1 launched in the free slot while 7:24 was still being written; surah 7 was assembled after 7:24 passed.
- Commits still deferred to the end of the loop.

### Open after this run

- Writer prompt: a perspectives question must test the content of a reading (what both hold, or what one named tradition holds and why), never the bare fact that they disagree; no gap on words like "diverge", "differ", "phrase" or the name of the disputed topic. Keep "what do they divide over" for cases where the answer is itself a substantive point.
- quiz.py or assemble: the surah-level repeat scan (still open since surah 5) would have caught the ummi gloss in 7:19/7:20.

## Results - Al-Anfaal 8:1 to 8:10 (2026-09-16)

Same `/loop` run. The writer prompt gained one line after the surah 7 report, before 8:3 launched: a perspectives question must test the content of a reading, never the bare fact that the traditions disagree (8:1 and 8:2 were written before it). All 10 passed first review. `quiz_8.json` assembled with 10 quizzes: 20 multiple choice, 10 true or false, 10 fill the gap, 10 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 8:1 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q1 awards-to-no-faction is a good essay check; q2 gap "best" against chosen/foremost is synonym recall; q5 still a shape about the disagreement (old prompt) |
| 8:2 | TF, fillGap, MC, whoSaid, MC | 1 PASS | q1 False on who held the wells; q5 divide-over answer (Badr-only versus every believer) is itself substantive, so the shape works here |
| 8:3 | MC, TF, fillGap, whoSaid, MC | 1 PASS | q4 misleading-trials saying is a strong Ali line; q5 tests the content of the Shia reading (guardianship) though its distractors are ones nobody picks |
| 8:4 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q3 gap "denial" on the shared point tests content, the new line working; q2 Dar al-Nadwa plot detail |
| 8:5 | whoSaid, TF, MC, fillGap, MC | 1 PASS | q3 fifth as daily gain and q5 why each side looked few are understanding; no perspectives question (writer avoided the disputed fifth) |
| 8:6 | fillGap, MC, TF, MC, whoSaid | 1 PASS | q4 why Satan took Suraqa's shape and q1 gap on the unnamed host are good; al-Sajjad waterskin narration vivid |
| 8:7 | fillGap, MC, TF, whoSaid, MC | 1 PASS | q1 gap "few" with faithful/righteous/patient as traps; q5 keep-and-add framing tests content |
| 8:8 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q1 False on escaping God; q3 seven-word structural gap "force to peace"; q4 Aws/Khazraj report has no personal voice |
| 8:9 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q3 gap "three" on the flight ruling and q4 True on abrogating the ten ratio are understanding; q5 God-kept-him-free-of-sin tests the Shia reading's content |
| 8:10 | MC, TF, MC, whoSaid, fillGap | 1 PASS | q3 walaya as inheritance through brotherhood is a real point; q5 gap "loyalty" on the shared point |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 10 | 62K | 50K to 77K | 9 min 3 s | 618K tokens, 90 min |
| reviewer | 10 | 22K | 21K to 24K | 1 min 13 s | 224K tokens, 12 min |

About 0.84M agent tokens for the surah, roughly 55 minutes wall clock with two slots. Writers are heavier again (62K against 55K in surah 7); the prompt has grown with each report and the surah 8 passages carry long perspectives.

### Review outcomes

10 of 10 PASS first time. One validator rejection: 8:8's first gap sat on an essay clause with stray spaces before punctuation ("war , and"), which the exact-span match does not normalise; the writer moved the gap to a clean sentence.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 4 | | MC | 7 |
| TF | 3 | | TF | 1 |
| fillGap | 2 | | whoSaid | 1 |
| whoSaid | 1 | | fillGap | 1 |

True or false: 5 of 10 True, half again by the parity rule. Translation anchors: 2. Perspectives anchors: 8 of 10. No gap prompt over 20 words. Closes drifted back to multiple choice (7 of 10) now that the perspectives close is a content question rather than a "diverge" gap or "same way" T/F.

### Reader notes (taste, not rule)

- The surah 7 line took: from 8:3 on, every perspectives question asks for the content of a reading (8:3 guardianship, 8:4 "denial", 8:7 keep-and-add, 8:9 free of sin, 8:10 "loyalty"), and none gaps a word about the disagreement. 8:2's "what do they divide over" happens to have a substantive answer (Badr-only versus every believer), which is the one case the line allows.
- Best questions: 8:8 False on escaping God, 8:9 "three" and the abrogated ten ratio, 8:6 why Satan took Suraqa's shape, 8:10 walaya as inheritance through brotherhood, 8:3 the misleading-trials line.
- Weak spots are the same as before: synonym gaps (8:1 "best", 8:3 "falsehood"), a who-said-it on a report with no personal voice (8:8 Aws and Khazraj), and perspectives distractors nobody would pick (8:3 "rebuilding the city of Medina").
- The exact-span match for gaps now has three known friction points from the briefs' text: curly quotes (surah 3), trailing punctuation against a semicolon or comma (surahs 4, 6), and stray spaces before punctuation (8:8). All three are in the source text, not the writer's copy.

### Deviations from the procedure

- One writer-prompt line added after the surah 7 report; 8:1 and 8:2 were written before it.
- 9:1 launched in the free slot while 8:10 was still being written; surah 8 was assembled after 8:10 passed.
- Commits still deferred to the end of the loop.

### Open after this run

- quiz.py: the gap span match should normalise whitespace around punctuation and curly quotes on both sides before comparing (three friction points now recorded). The surah-level repeat scan is still open.
- Writer prompt: nothing new; the surah 7 perspectives line and the surah 6 parity rule are both holding.

## Results - At-Tawba 9:1 to 9:16 (2026-09-16)

Same `/loop` run, no prompt change during the surah (the surah 8 report added nothing). All 16 passed first review. `quiz_9.json` assembled with 16 quizzes: 32 multiple choice, 16 true or false, 16 fill the gap, 16 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 9:1 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q3 basis of the four-month argument tests the content of a reading; q4 gap "prayer" with zakat as the verse-borrowed trap is good |
| 9:2 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q4 walija definition is understanding; q5 False with Khuza'a as the trap tests the Imams' reading; q3 Ali quote is a verse echo, speaker a guess |
| 9:3 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q4 gap "religion" with the reason in the other clause is a good essay gap; q3 shared point vindicating Ali tests content; q1 verse recall on a translation anchor |
| 9:4 | TF, MC, whoSaid, MC, fillGap | 1 PASS | q1 False on numbers at Hunayn is the passage's central point; q5 gap "Magians" with Sabians and Samaritans as traps; q4 content of the Shia ruling on impurity |
| 9:5 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q2 lordship as obedience not worship is the key point; q4 gap "consecutive" fine; q5 tests the Shia reading's content (the Qaim) |
| 9:6 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 brother-of-war line has a strong voice; q3 False on Suraqa is a story check; q5 shared point keeps the composure dispute off the answer key |
| 9:7 | TF, fillGap, MC, whoSaid, MC | 1 PASS | q1 True on reproach-not-fault and its reason tests content; q4 short maxim, speaker a guess |
| 9:8 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q1 gap "zakat" against khums, sadaqa and kharaj is a real distinction; q5 False on the timing is a story check |
| 9:9 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q2 "cubit by cubit" has the Prophet's voice; q3 Lot against the other peoples of v70; q5 distractor "hypocrites who repent" is one nobody picks; q1 True near the essay wording |
| 9:10 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q4 Ali drawing water for dates; q5 False on seventy as abundance; q3 gap "marks" is synonym-style; q2 on the translation is verse memory |
| 9:11 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q2 funeral-prayer ban scope is a real check; q1 gap "reckoning" is a theme word a skimmer guesses |
| 9:12 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q2 blame on the well-off against the cleared groups; q4 "Filth, whose refuge is hell" is the verse line, and "the virtuous" is a distractor nobody picks |
| 9:13 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q1 opens on the perspectives with a one-tradition framing; q4 water gloss is a good note check; q3 gap "pure Imams" is a Shia reader's first guess; q5 True near the essay wording |
| 9:14 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 why "buying" is a figure of speech is the best question of the surah; q3 False on Abraham's promise turns on the narration; q5 "Torah foretold Tabuk" is a distractor nobody picks; q4 gap prompt reads as a fragment |
| 9:15 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q4 "is a bedouin" line has a voice; q5 one-tradition framing on the Truthful; q3 gap "limit" guessable; q2 on the translation is verse memory |
| 9:16 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q1 False on standing duty versus one-time order is a real reading check; q5 one-reading-and-why on v128; q3 on the translation is verse memory |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 16 | 61K | 43K to 80K | 8 min 36 s | 969K tokens, 138 min |
| reviewer | 16 | 22K | 21K to 24K | 1 min 10 s | 357K tokens, 19 min |

About 1.33M agent tokens for the surah, roughly 78 minutes wall clock with two slots kept full. Writer mean is level with surah 8 (61K against 62K); 9:2 was the heaviest single write of the run so far at 80K and 13 minutes, 9:15 (a four-verse passage) the lightest at 43K.

### Review outcomes

16 of 16 PASS first time, no rewrites. Validator rejections on first write: 9:4 (single against double quotes in the gap span, the writer changed the span). 9:13 took 10 tool uses and 9:16 six, which points to two or three more rejections, but the writer reports did not say what they were; the log records only the tool-use counts.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 7 | | MC | 9 |
| MC | 3 | | TF | 6 |
| whoSaid | 3 | | fillGap | 1 |
| fillGap | 3 | | whoSaid | 0 |

True or false: 8 of 16 True, exactly half by the parity rule. Translation anchors: 5, one each in 9:3, 9:10, 9:12, 9:15 and 9:16, every one a multiple choice of the form "according to verse N, what ...". Perspectives anchors: 13 of 16; 9:10, 9:11 and 9:12 skipped the perspectives because the only point there was the disputed one. Anchor spread over the surah: essay 28, narration 28, perspectives 13, note 6, translation 5. No gap prompt over 20 words. The "vary the opening" line and the parity rule together push true or false to the front: 7 of 16 openers, against 3 in surah 8.

### Reader notes (taste, not rule)

- The perspectives line is holding: every perspectives question asks for the content of a reading, as a shared point (9:3, 9:6, 9:9), one tradition's reading (9:5, 9:8, 9:13, 9:15) or one reading and its reason (9:1, 9:14, 9:16). The three passages that skipped the perspectives did so because the disputed gloss was the only thing there, which is the right call under the surah 5 line.
- Best questions: 9:14 why "buying" is a figure of speech, 9:4 False on the numbers at Hunayn, 9:5 lordship as obedience not worship, 9:16 standing duty against a one-time order, 9:11 the scope of the funeral-prayer ban, 9:12 blame on the well-off against the cleared groups, 9:8 zakat against khums, sadaqa and kharaj.
- New pattern: the one translation anchor the prompt allows has turned into a fixture. Five of the last seven quizzes spend a multiple choice on "according to verse N, what does it say", which a reader answers from the verse they just read. The prompt now says none unless the commentary parts cannot carry five questions.
- Recurring: distractors nobody picks in perspectives questions (9:9, 9:12, 9:13, 9:14; 8:3 before). The prompt now says take them from the passage's other readings, not from inventions. Synonym or theme-word gaps (9:10 "marks", 9:11 "reckoning", 9:15 "limit") and True statements that lean on the essay's wording (9:9, 9:13, 9:15) continue at about one a quiz; neither is a rule problem.
- 9:14 q4's gap prompt "Of this verse he said: until He makes them ____ ..." passes the whole-sentence rule on its capital but reads as a fragment. One case; watch rather than fix.

### Deviations from the procedure

- Two writer-prompt lines added after this report (translation anchors, perspectives distractors); 10:1 was already writing on the old prompt when they landed.
- 10:1 launched in the free slot while 9:16 was under review; surah 9 was assembled after 9:16 passed.
- Commits still deferred to the end of the loop.

### Open after this run

- quiz.py: the gap span match normalisation (whitespace before punctuation, trailing punctuation, curly and single quotes) is still open, with 9:4 a fourth case. The surah-level repeat scan is still open.
- Writer: the two lines above. Watch whether the translation-anchor line moves the fifth question onto the notes, which are under-used (6 anchors in 80).

## Results - Yunus 10:1 to 10:11 (2026-09-16)

Same `/loop` run. Two writer-prompt lines landed after the surah 9 report (no translation anchor unless the commentary parts cannot carry five questions; perspectives distractors from the passage's other readings, not inventions); 10:1 was already writing on the old prompt, 10:2 to 10:11 used the new one. All 11 passed first review. `quiz_10.json` assembled with 11 quizzes: 23 multiple choice, 11 true or false, 11 fill the gap, 10 who said it (10:8 has one narration, so a third multiple choice took the who-said-it slot).

| passage | type order | reviews | reader note |
|---|---|---|---|
| 10:1 | MC, fillGap, TF, whoSaid, MC | 1 PASS | q5 shared point on the letters tests content; q4 stars-from-the-bearers line has a voice; q2 gap prompt shipped without a full stop (span match) |
| 10:2 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q4 False on the unnamed generations (Ad and Thamud) is a good narration check; q2 who-said-it answer Ali ibn Ibrahim is the only non-Imam option, odd one out; q3 seven-word gap sentence |
| 10:3 | MC, fillGap, whoSaid, TF, MC | 1 PASS | q3 three-things line has a voice; q2 "The same ____ plays out at sea" is six words with no context; q5 shared point on the vision of God, but Imam Ali's narration reads the enhancement as this world |
| 10:4 | fillGap, MC, TF, whoSaid, MC | 1 PASS | q4 two-verses line has a voice; q3 False on careful reasoning is clean; q2 names Imam al-Baqir's narration as the reading with distractors from other verses; q1 gap prompt shipped without a full stop |
| 10:5 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q2 anger-only-at-the-refuser line has a voice; q1 gentle-not-threat reading is understanding; q3 gap "vile" is an adjective a skimmer guesses |
| 10:6 | whoSaid, MC, TF, MC, fillGap | 1 PASS | q2 why the promise cannot fail and q3 False on bodily illness are understanding; q1 who-said-it quote is six words, speaker a guess; closes on a gap |
| 10:7 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q4 righteous dream as this world's good news is the passage's best point; q5 True on "Shia narrations keep faith and piety while adding content" is a meta-statement, the shape the surah 7 line was meant to stop |
| 10:8 | MC, TF, MC, fillGap, MC | 1 PASS | q3 dharr as the earlier rejection is a real note check; q5 tests the content of one seal reading but puts the other tradition's reading in the wrong slot; no who-said-it (one narration) |
| 10:9 | TF, MC, whoSaid, MC, fillGap | 1 PASS | q2 Harun and Ali parallel is the content of the Shia reading; q4 staff and q5 "professes" are story facts every reader knows before reading |
| 10:10 | fillGap, MC, TF, whoSaid, MC | 1 PASS | q3 False on forced faith is the passage's point; q2 the angels objection tests the narration; q5 the theologians' reading sits among the distractors |
| 10:11 | TF, fillGap, MC, whoSaid, MC | 1 PASS | q3 forgiveness without repentance is the content of the Shia reading; q4 recitation-reward saying has little voice |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 11 | 64K | 36K to 78K | 10 min 41 s | 700K tokens, 118 min |
| reviewer | 11 | 23K | 21K to 24K | 1 min 14 s | 250K tokens, 14 min |

About 0.95M agent tokens for the surah, roughly 66 minutes wall clock with two slots. Writer time is up (10 min 41 s against 8 min 36 s in surah 9) more than tokens (64K against 61K); 10:8 took 17 minutes for 36K tokens, so the slowness is the model, not the prompt.

### Review outcomes

11 of 11 PASS first time, no rewrites. Validator rejections on first write: 10:1 (trailing full stop against a semicolon in the note) and 10:3 (one rejection, cause not reported). 10:4 pre-empted the same rejection by dropping the full stop. Both 10:1 q2 and 10:4 q1 shipped with a gap prompt that ends without punctuation, which is the first time the span-match friction has left a visible mark in the app data rather than costing a writer round trip.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 6 | | MC | 8 |
| fillGap | 2 | | fillGap | 2 |
| TF | 2 | | TF | 1 |
| whoSaid | 1 | | whoSaid | 0 |

True or false: 6 of 11 True, the parity rule exactly. Translation anchors: 0 (the surah 9 line took at once; 10:1 on the old prompt also had none). Perspectives anchors: 11 of 11. Anchor spread: essay 25, narration 17, perspectives 11, note 2. The fifth question did not move to the notes as hoped; the essay took the slot. Openers swung back to multiple choice (6 of 11) after true or false led surah 9.

### Reader notes (taste, not rule)

- The translation-anchor line worked: no "according to verse N" question in the surah.
- The perspectives-distractor line half worked. 10:5, 10:9, 10:10 and 10:11 draw their wrong options from the passage, as asked. But "the passage's other readings" pulled in the other tradition's reading of the same point twice (10:8 the seal as punishment, 10:10 the theologians' reading), which the older rule forbids. The line now says so explicitly.
- Two gap prompts (10:2, 10:3) are six- and seven-word fragments with no context. The prompt had a ceiling of twenty words and no floor; it now asks for about ten to twenty, one clause that says what the sentence is about.
- 10:7 q5 is a meta true-or-false about the traditions ("keep faith and piety while adding content") rather than the content of a reading; one case, the surah 7 line still stands, watch it.
- 10:2 q2 answers "Ali ibn Ibrahim" among three Imams and the Prophet: the odd one out gives it away, and the quote is a lexical gloss with no voice. The who-said-it rule wants a saying in the speaker's own voice; a compiler's gloss never has one.
- 10:9 q4 and q5 test story facts (the staff, Pharaoh's profession) every reader knows before reading. The gap rule already says not on a term the reader knows before reading; the same idea applies to multiple choice and is not written down.
- Best questions: 10:7 righteous dream, 10:2 False on the unnamed generations, 10:6 why the promise cannot fail, 10:8 dharr, 10:10 False on forced faith, 10:11 forgiveness without repentance, 10:9 Harun and Ali.
- 10:6's writer read the source draft.json to check anchor spans against stripped markers; the agent is meant to read only the brief. Harmless here, but it is the writer working around the span-match friction.

### Deviations from the procedure

- Two writer-prompt refinements after this report (the other tradition's reading never a distractor; gap prompt floor of about ten words); 11:1 and 11:2 were already writing when they landed.
- 11:1 launched in the free slot while 10:11 was under review; surah 10 was assembled after 10:11 passed.
- Commits still deferred to the end of the loop.

### Open after this run

- quiz.py, now a real defect rather than friction: two shipped gap prompts have no terminal punctuation because the exact-span match rejects a full stop where the source continues with a semicolon or a stray space. The match should strip trailing punctuation and whitespace before punctuation on both sides before comparing, and quiz-assemble or the app should render a gap prompt with a full stop. Also the repeat scan.
- Writer prompt: the two refinements above. Consider a line that the "known before reading" test applies to every type, not only the gap.

## Results - Hud 11:1 to 11:10 (2026-09-16)

Same `/loop` run. Two prompt refinements landed after the surah 10 report (the other tradition's reading is never a distractor; gap prompts about ten to twenty words); 11:1 and 11:2 were already writing on the earlier text, 11:3 to 11:10 used the refined one. All 10 passed first review. `quiz_11.json` assembled with 10 quizzes: 20 multiple choice, 10 true or false, 10 fill the gap, 10 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 11:1 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q4 "most correct in deed, not most in number" is the passage's best point; q2 gap "hearing" guessable from "recited"; q5 True on the shared reading is clipped |
| 11:2 | fillGap, MC, TF, whoSaid, MC | 1 PASS | q3 False on paid in both lives; q2 Qudayd scoff is a good story check; q5 witness as Ali with the Sunni readings (Gabriel, the Prophet, the Book) in the wrong slots, written before the refinement |
| 11:3 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q3 why Noah disclaims the three powers; q5 one-reading framing with passage glosses as distractors, the refinement working on its first quiz; q2 al-Qummi as the odd non-Imam option |
| 11:4 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q4 why Noah called his son and q5 False on the shared rejection (adultery claim) are understanding; q2 "the Shia of the House" against animals and elders, distractors nobody picks |
| 11:5 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q5 True on plural apostles for one messenger is a good note check; q4 ring-and-nostril wind line is vivid; no perspectives question |
| 11:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q5 False on why they are called wrongdoers (disbelief wrongs oneself); q4 faces yellow, red, black; passage has no perspectives section |
| 11:7 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q3 forbearance-not-objection and q5 what Tabatabai rejects both test a reading's content; two scholar-framed prompts in one quiz |
| 11:8 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 baqiyyat Allah as the lawful remainder and q5 the Qaim title make a good pair; q1 is the third brother-in-tribe question in four quizzes |
| 11:9 | fillGap, whoSaid, MC, TF, MC | 1 PASS | q3 Arafa as the witnessed day; q5 shared point on who leaves the Fire; q1 gap "followers" is synonym-style |
| 11:10 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q2 ruler-and-purse line has a voice; q3 False on sparing a town for a counselor; q5 the excepted per the Shia narrations |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 10 | 52K | 45K to 61K | 6 min 56 s | 521K tokens, 69 min |
| reviewer | 10 | 23K | 21K to 25K | 1 min 11 s | 228K tokens, 12 min |

About 0.75M agent tokens for the surah, roughly 41 minutes wall clock with two slots. The writer is back to surah 4 weight (52K against 64K in surah 10) with no prompt cut, so the surah 10 heaviness was the passages, not the prompt.

### Review outcomes

10 of 10 PASS first time, no rewrites. One likely validator rejection (11:8, six tool uses, cause not reported). No shipped gap prompt lost its full stop this surah.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 3 | | MC | 6 |
| fillGap | 3 | | TF | 4 |
| TF | 2 | | fillGap | 0 |
| whoSaid | 2 | | whoSaid | 0 |

True or false: 5 of 10 True by the parity rule. Translation anchors: 0. Perspectives anchors: 8 of 10 (11:6 has no perspectives section; 11:5 used a note instead). Anchor spread: narration 20, essay 19, perspectives 8, note 3. The openers are the most even of the run so far.

### Reader notes (taste, not rule)

- Both surah 10 refinements took on their first quiz. From 11:3 on, no gap prompt is under ten words, and no perspectives distractor is the other tradition's reading of the same point (11:3, 11:7, 11:10 draw theirs from other passage glosses; 11:4 and 11:9 use shared-point framings). 11:2, written before the line, is the last quiz with Sunni readings in the wrong slots.
- Repeat across neighbouring quizzes is now the largest remaining taste problem: "was he their brother in tribe or in religion" is q1 of 11:5, 11:6 and 11:8, because each of those passages opens with "to X their brother Y" and carries the same narration. The writer sees one brief at a time and cannot know. A surah-level scan is still the right fix; a cheaper one is to add to the brief the prompts already passed for earlier passages of the same surah so the writer can avoid them.
- Who-said-it on a compiler's gloss appeared again (11:3 al-Qummi, after 10:2). The prompt now says not to build the who-said-it on a compiler or exegete.
- Best questions: 11:1 most correct in deed, 11:4 why Noah called his son, 11:6 why Thamud are called wrongdoers, 11:8 baqiyyat Allah as remainder and as title, 11:9 Arafa as the witnessed day, 11:10 ruler and purse.
- Synonym-style and guessable gaps continue at about one in two quizzes (11:1 "hearing", 11:3 "praiseworthy", 11:5 "prophethood", 11:6 "ill fortune", 11:9 "followers"). The gap rule asks for the commentator's reason or gloss; these are on the gloss but the sentence gives the answer away. No new line; the fix would be to ask the writer to check that the other clause does not imply the gap, which the prompt already says for paraphrase.

### Deviations from the procedure

- One writer-prompt line added after this report (no who-said-it on a compiler's gloss); 12:1 and 12:2 were already writing when it landed.
- 12:1 launched in the free slot while 11:9 was under review; surah 11 was assembled after 11:9 passed.
- Commits still deferred to the end of the loop.

### Open after this run

- quiz.py: span-match normalisation (still open, no new shipped artifact this surah) and the surah-level repeat scan, now with a concrete three-in-four case. Proposal for the brief: list the passed prompts of earlier passages in the same surah under a "Already asked in this surah" heading.
- Writer prompt: the compiler line above.

## Results - Yusuf 12:1 to 12:12 (2026-09-16)

Same `/loop` run. One prompt line landed after the surah 11 report (no who-said-it on a compiler's gloss); 12:1 and 12:2 were already writing, 12:3 to 12:12 used it. All 12 passed first review. `quiz_12.json` assembled with 12 quizzes: 24 multiple choice, 12 true or false, 12 fill the gap, 12 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 12:1 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q4 True on why Jacob warned Joseph is a real reading check; q3 gap "envy" is the story fact every reader knows; q5 on v4 after q4 on v5 |
| 12:2 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 worldly-judgment-not-religion and q3 False on "not aware" test the readings; q4 gap "dog" is a real gloss detail |
| 12:3 | MC, TF, MC, whoSaid, fillGap | 1 PASS | q3 "my Lord" as her husband per most commentators; q5 gap "trap" closes well; no perspectives question (v24 dispute) |
| 12:4 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q5 why the household confined Joseph (shield, not punish) with passage distractors; q3 is a third-person report, speaker a guess |
| 12:5 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q4 gap "preaching" before interpreting is the essay's point; q5 what the forgetting dispute turns on has a substantive answer; q1 paraphrases the saying without quote marks |
| 12:6 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q2 three kinds of dreams has a teaching voice; q5 rain after famine with plan-step distractors; q5 options end with full stops |
| 12:7 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q3 praise-when-compelled has a voice; q5 fabrication against the Quran is what one tradition rejects; q2 is the verse's own words; q5 on v52 after q4 on v55 |
| 12:8 | MC, TF, fillGap, whoSaid, MC | 1 PASS | q5 reliance does not mean abandoning the means; q2 False on the test-of-honesty reading; q3 gap "wound" is a guessable metaphor |
| 12:9 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q3 the brothers' own ruling as the legal opening is the surah's best question; q5 cry pointed to the old theft; q4 gap "belt" is a real narration detail |
| 12:10 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q3 False on Jacob concluding Joseph dead; q2 beautiful patience as no complaint; q5 repeats 12:2 q5's point (the scheme became the means of his rise) |
| 12:11 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q4 prostration as worship directed to Allah with Joseph as its direction; q2 error as grief not religion; q3 two pardons line has a voice |
| 12:12 | fillGap, whoSaid, MC, TF, MC | 1 PASS | q3 hidden shirk by degrees against the two rejected readings; q5 why the Shia read v110 as the peoples; q1 gap "earthquake" in a list of three is memory |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 12 | 60K | 40K to 79K | 8 min 44 s | 722K tokens, 105 min |
| reviewer | 12 | 23K | 22K to 24K | 1 min 21 s | 277K tokens, 16 min |

About 1.0M agent tokens for the surah, roughly 61 minutes wall clock with two slots.

### Review outcomes

12 of 12 PASS first time, no rewrites. One validator rejection (12:1, a framing prefix on the gap sentence). No shipped gap prompt lost its full stop.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 4 | | MC | 10 |
| TF | 4 | | fillGap | 1 |
| whoSaid | 2 | | TF | 1 |
| fillGap | 2 | | whoSaid | 0 |

True or false: 6 of 12 True by the parity rule. Translation anchors: 0. Perspectives anchors: 7 of 12; five quizzes (12:1, 12:2, 12:3, 12:8, 12:10) skipped the perspectives because the only point there was a disputed gloss (originated speech, brothers as prophets, verse 24, the eldest brother's name), which is the surah 5 line working on a surah whose perspectives are dispute-heavy. Anchor spread: essay 26, narration 25, perspectives 7, note 2. Openers stay even; closes drifted back to multiple choice, 10 of 12, the worst of the run.

### Reader notes (taste, not rule)

- The multiple-choice close is a persistent drift (9 of 16 in surah 9, 8 of 11, 6 of 10, now 10 of 12). The "q5 may be any type" line does not hold on its own. The prompt now keys the close to the passage index the way the true-or-false answer is keyed: even index closes on something other than multiple choice.
- Two quizzes are out of passage order (12:1 q5 on verse 4 after q4 on verse 5; 12:7 q5 on verse 52 after q4 on verse 55) because the essay's closing paragraph and the perspectives can sit on an earlier verse. The prompt's "in the order of the passage" is listed under the validator's rules but the validator does not check it; either quiz.py should check ascending verse numbers or the prompt should say the close may break the order.
- Repeat across quizzes: 12:2 q5 and 12:10 q5 both ask about the brothers' scheme becoming the means of Joseph's rise, the essay's frame for the whole surah. Same cause as the surah 11 case; the brief does not tell the writer what earlier quizzes asked.
- Best questions: 12:9 the brothers' own ruling, 12:11 prostration as worship directed to Allah, 12:12 hidden shirk by degrees, 12:5 preaching before interpreting, 12:8 reliance and the means, 12:4 shield not punish.
- The compiler line held from 12:3 on (no who-said-it on a compiler's gloss). Voice-less who-said-it items continue at about one in three (12:4 third-person report, 12:5 paraphrased without quote marks, 12:9 a maxim).
- Small style drift: 12:6 q5's options end with full stops, the only quiz so far to do so; 12:4 spells "Imam al-Ridha" where the brief and every other quiz have "al-Rida".

### Deviations from the procedure

- One writer-prompt line added after this report (even-index close is not multiple choice); 13:1 and 13:2 were already writing when it landed.
- 13:1 and 13:2 launched together in the two free slots after 12:12 passed; surah 12 was assembled in the same turn.
- Commits still deferred to the end of the loop.

### Open after this run

- quiz.py: ascending verse order is stated in the writer prompt as a validator rule but not enforced (two cases this surah); the span-match normalisation and the surah-level repeat scan remain open, the repeat scan now with cases in surahs 5, 6, 7, 11 and 12.
- Writer prompt: the close-parity line above. Watch for a spelling check on speaker names (al-Rida against al-Ridha), which quiz.py could enforce against the brief's speaker list for options as well as the right answer.

## Results - Ar-Ra'd 13:1 to 13:6 (2026-09-16)

Same `/loop` run. One prompt line landed after the surah 12 report (even-index close is not multiple choice); 13:1 and 13:2 were already writing, 13:3 to 13:6 used it. All 6 passed first review. `quiz_13.json` assembled with 6 quizzes: 12 multiple choice, 6 true or false, 6 fill the gap, 6 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 13:1 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q1 one Lord governs, not merely a maker, is a real distinction; q2 pillars-you-do-not-see line has a voice; q5 shared report that the Prophet pointed to Ali |
| 13:2 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q4 water-that-never-reaches-the-mouth against the passage's other images; q2 "within what larger point does al-Mizan set" is a book-name framing with distractors nobody picks; q5 False is a flipped essay line |
| 13:3 | fillGap, whoSaid, MC, TF, MC | 1 PASS | q3 what the righteous dreaded (scrutiny, not wrong) is a good narration check; q4 True on the Shia wilayah reading is tradition-level; q1 gap "equality" guessable |
| 13:4 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q4 onlookers take no heed; q3 Tuba tree line has a voice; q2 prompt says "the essay" where the claim sits in the perspectives; q5 False is a flipped essay line |
| 13:5 | MC, fillGap, TF, whoSaid, MC | 1 PASS | q4 one-part-of-seventy fire line; q2 gap "provision" for "mere words" is a real gloss; options in q1 and q5 start lowercase |
| 13:6 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q4 loss-of-the-scholars line has a voice; q1 messengers with wives; q5 False on "leave it open" is a statement about what the narrations do, not what they say |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 6 | 57K | 45K to 64K | 10 min 17 s | 341K tokens, 62 min |
| reviewer | 6 | 24K | 21K to 28K | 1 min 29 s | 142K tokens, 9 min |

About 0.48M agent tokens for the surah, roughly 35 minutes wall clock with two slots. 13:6 took 22 minutes for 57K tokens, the slowest write of the run; the transcript file did not grow for the first 20 minutes, so the time went to a single long generation, not to retries.

### Review outcomes

6 of 6 PASS first time, no rewrites. One likely validator rejection (13:3, six tool uses).

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 3 | | MC | 3 |
| fillGap | 2 | | TF | 3 |
| whoSaid | 1 | | fillGap | 0 |
| TF | 0 | | whoSaid | 0 |

True or false: 3 of 6 True by the parity rule. Translation anchors: 0. Perspectives anchors: 6 of 6. Anchor spread: essay 13, narration 11, perspectives 6, note 0. All six quizzes in verse order. The close-parity line took at once: 13:4 and 13:6 (even) close on true or false, 13:3 and 13:5 (odd) on multiple choice.

### Reader notes (taste, not rule)

- The close-parity line works the way the true-or-false parity line did; the drift to a multiple-choice close is stopped without a ratio the writer can over-correct on.
- Three perspectives questions are tradition-level statements rather than the content of a reading: 13:3 q4 (the Shia narrations tie the covenant to wilayah, True), 13:6 q5 (the Shia narrations leave it open, False), and 13:2 q2 (within what larger point al-Mizan sets the verse). All passed, and each does carry a substantive answer, but the shape is "what the tradition does" rather than "what the tradition says". Two of the three are true-or-false items on the perspectives; the true-or-false type invites this shape because a claim about a tradition is easy to negate. Watch before adding a line.
- Two flipped-essay-line false statements (13:2 q5, 13:4 q5) are the easy kind the true-or-false rule warns about; both are on the essay's closing sentence, which is the one place the "q5 from the close" line and the "False on even index" line meet. A False close on the essay's last sentence will tend to be a flip.
- Style slips: 13:5 has lowercase option starts, 13:4 q2 labels a perspectives claim as the essay's. Neither is a rule; quiz.py could normalise option capitalisation at assemble time.
- Best questions: 13:1 one Lord governs, 13:3 what the righteous dreaded, 13:4 onlookers take no heed, 13:2 the water simile, 13:6 loss of the scholars.

### Deviations from the procedure

- No prompt change after this report.
- 14:1 launched in the free slot while 13:6 was still writing; surah 13 was assembled after 13:6 passed.
- Commits still deferred to the end of the loop.

### Open after this run

- quiz.py: unchanged list (span-match normalisation, verse-order check, repeat scan, speaker-name spelling against the brief), plus option capitalisation at assemble time.
- Writer prompt: nothing new. Two things to watch in surah 14: tradition-level true-or-false items on the perspectives, and False closes that flip the essay's last sentence.

## Results - Ibrahim 14:1 to 14:7 (2026-09-16)

Same `/loop` run, the last surah in scope. No prompt change during the surah. All 7 passed first review. `quiz_14.json` assembled with 7 quizzes: 14 multiple choice, 7 true or false, 7 fill the gap, 7 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 14:1 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q2 preferring this world as denying the Hereafter, oneness and prophethood; q4 True on one day as mercy and punishment is the reconciliation; q1 gap "clear road" guessable |
| 14:2 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q3 the literal "hands into their mouths" behind the smoothed translation is a good check; q4 gap prompt "he said: the ____" is a bare fragment |
| 14:3 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q1 the false assumption behind "return" is a real essay check; q4 the imam extension of the ashes parable, phrased tradition-level; q3 gap "truth" guessable |
| 14:4 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q2 gap "compel" on Tusi's no-authority gloss is a real reason gap; q4 asks what the Sunni commentators hold (date palm), the one-tradition framing on the other side; q5 False on excluding the grave is clean |
| 14:5 | TF, fillGap, MC, whoSaid, MC | 1 PASS | q3 spending as an obligation beyond zakat; q2 gap "permission" is good but shipped without a full stop (span match, third shipped case); q4 falling-short line has a voice |
| 14:6 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q4 what Shia scholars conclude from the plea for his parents; q3 name-your-need line has a voice; q5 on v37 after q4 on v41, out of order |
| 14:7 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q2 Tabatabai's similitude reading of the earth narrations is the passage's best point; q3 pure-bread line is vivid; q1 gap "wronged" guessable from "wrongdoer" |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 7 | 52K | 41K to 67K | 7 min 5 s | 367K tokens, 50 min |
| reviewer | 7 | 22K | 20K to 23K | 1 min 4 s | 152K tokens, 8 min |

About 0.52M agent tokens for the surah, roughly 29 minutes wall clock with two slots.

### Review outcomes

7 of 7 PASS first time, no rewrites, no validator rejections reported. 14:5 q2 shipped without a terminal full stop (the span-match friction, third shipped case after 10:1 and 10:4).

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| fillGap | 3 | | MC | 4 |
| MC | 3 | | TF | 3 |
| TF | 1 | | fillGap | 0 |
| whoSaid | 0 | | whoSaid | 0 |

True or false: 4 of 7 True by the parity rule. Translation anchors: 0. Perspectives anchors: 5 of 7 (14:1 and 14:7 skipped disputed-only perspectives). Anchor spread: essay 14, narration 13, perspectives 5, note 3. The close-parity line held again (odd indices close on multiple choice, even on true or false). One quiz out of verse order (14:6).

### Reader notes (taste, not rule)

- Best questions: 14:7 similitude reading, 14:4 "compel", 14:2 the literal clause, 14:3 the false assumption, 14:6 what the plea for his parents implies, 14:5 obligation beyond zakat.
- 14:4 q4 is the first quiz to ask what the Sunni commentators hold as the one-tradition framing; it reads fine and takes no side, so the framing works in both directions.
- Guessable gaps remain the most common soft spot (14:1, 14:3, 14:7), each a word implied by the rest of its sentence. The gap rule already says the other clause must not paraphrase the answer; these are implication rather than paraphrase, and a line against that would be hard to state without making gaps impossible.
- Nothing new in the who-said-it items; all seven have a voice.

### Deviations from the procedure

- No prompt change.
- Commits deferred to the end of the loop; the loop ends with this report, so the commit question follows now.

## Run summary - surahs 3 to 14 (2026-09-15 evening to 2026-09-16 morning)

| surah | passages | first-review passes | rewrites | parked | tokens | wall clock |
|---|---|---|---|---|---|---|
| 3 Aal-i-Imraan | 20 | 20 | 0 | 0 | 1.36M | 95 min |
| 4 An-Nisaa | 24 | 24 | 0 | 0 | 1.86M | 110 min |
| 5 Al-Maaida | 16 | 15 | 1 (5:13) | 0 | 1.33M | 80 min |
| 6 Al-An'aam | 20 | 19 | 1 (6:7) | 0 | 1.61M | 100 min |
| 7 Al-A'raaf | 24 | 24 | 0 | 0 | 1.85M | 120 min |
| 8 Al-Anfaal | 10 | 10 | 0 | 0 | 0.84M | 55 min |
| 9 At-Tawba | 16 | 16 | 0 | 0 | 1.33M | 78 min |
| 10 Yunus | 11 | 11 | 0 | 0 | 0.95M | 66 min |
| 11 Hud | 10 | 10 | 0 | 0 | 0.75M | 41 min |
| 12 Yusuf | 12 | 12 | 0 | 0 | 1.00M | 61 min |
| 13 Ar-Ra'd | 6 | 6 | 0 | 0 | 0.48M | 35 min |
| 14 Ibrahim | 7 | 7 | 0 | 0 | 0.52M | 29 min |
| total | 176 | 174 | 2 | 0 | 13.9M | about 14.5 h |

178 writer runs (9.83M tokens) and 178 reviewer runs (4.04M tokens). Both rewrites passed on the second review. Every surah assembled into `Thaqalayn/Thaqalayn/Data/quiz_3.json` to `quiz_14.json`, all untracked.

Writer-prompt lines added during the run, in order, each after the surah that motivated it: surah 2 open items and vary-the-opening (before 3); voice in who-said-it, gap on the gloss, True about half, q5 any type (after 3); gap prompt at most twenty words, other clause not a paraphrase (after 4); check the perspectives before gapping a gloss (after 5); True by passage parity, prefer no-side framings (after 6); perspectives must test content not the fact of disagreement (after 7); no translation anchor unless needed, perspectives distractors from the passage (after 9); never the other tradition's reading as a distractor, gap prompt about ten to twenty words (after 10); no who-said-it on a compiler's gloss (after 11); close by passage parity (after 12). The parity rules (True on odd, non-multiple-choice close on even) are the two that held without drift; ratio lines over-corrected.

Open items for quiz.py, none implemented during the run: normalise the gap span match (trailing punctuation, whitespace before punctuation, curly and single quotes; three shipped prompts lack a full stop: 10:1 q2, 10:4 q1, 14:5 q2); enforce ascending verse order (12:1, 12:7, 14:6 out of order); a surah-level repeat scan or an "already asked" list in the brief (cases in surahs 5, 6, 7, 11, 12); check option speaker spellings against the brief (12:4 "al-Ridha"); normalise option capitalisation at assemble time (13:5).

## Results - Al-Hijr 15:1 to 15:6 (2026-09-21)

New `/loop` run ("next one, till last surah"), the first surah after the 3 to 14 run. No prompt change during the surah. All 6 passed first review. `quiz_15.json` assembled with 6 quizzes: 12 multiple choice, 6 true or false, 6 fill the gap, 6 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 15:1 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q1 regret only after this life closes is the essay's point; q2 caller narration has a voice; q3 and q5 both open "How does Tabatabai read", the same framing twice in one quiz; q4 gap "truth" guessable from "bars one from" |
| 15:2 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q1 mansions of the sun and moon is the essay's gloss; q2 metals-by-weight narration has a voice; q3 gap "reality" is Tabatabai's own term, a real reason gap, but shipped without a full stop (span match, fourth shipped case); q5 False on a single Sunni meaning tests the many-senses point |
| 15:3 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q1 raised by religion, knowledge and deeds is the essay's lesson; q2 ruh-from-rih line has a voice; q3 True on jinn not angel is the note's real point; q4 gap "power" fair, "command" a live distractor; q5 tryst of them all is verse wording, three distractors nobody would pick |
| 15:4 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q2 docile-mounts line has a strong voice; q3 gap "affliction" is Tabrisi's gloss, "hunger" a live distractor; q4 who ordained Lot's wife's fate is the Qadariyya narration's point, but "God" is guessable from the framing; q5 False on occasion of revelation tests Tabatabai's correspondence reading; q5 on v47 after q4 on v60, out of order |
| 15:5 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q3 True on "By your life" sworn on the Prophet is the passage's best point; q2 four-angels narration has a voice; q4 gap "outward" fair, "hidden" a live distractor, but shipped without a full stop (fifth shipped case); q5 who the Shia narrations mean by the percipient, one-tradition framing; q4 and q5 both on v75 |
| 15:6 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q2 pardon-without-reproach line has a voice; q3 gap "worry" fair, with a full stop; q4 Quraysh as those who split into bands is the Shia reading with passage-drawn distractors; q5 False on fighting cancelling forbearance is the essay's close; q1 "Whom does Tabatabai identify" is the third Tabatabai-framed opener in the surah |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 6 | 40K | 33K to 52K | 4 min 18 s | 240K tokens, 26 min |
| reviewer | 6 | 20K | 20K to 21K | 38 s | 121K tokens, 4 min |

About 0.36M agent tokens for the surah, roughly 17 minutes wall clock with two slots. Writers ran faster than in surahs 3 to 14 (4 min against 7); the reviewer cost is unchanged.

### Review outcomes

6 of 6 PASS first time, no rewrites. One validator rejection: 15:5 q4 first came with a trailing full stop inside the gap span and was fixed on the writer's second write. 15:2 q3 and 15:5 q4 shipped without a terminal full stop (the span-match friction, fourth and fifth shipped cases after 10:1, 10:4 and 14:5).

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 5 | | MC | 3 |
| TF | 1 | | TF | 3 |
| fillGap | 0 | | fillGap | 0 |
| whoSaid | 0 | | whoSaid | 0 |

True or false: 3 of 6 True by the parity rule (True on 15:1, 15:3, 15:5; False on 15:2, 15:4, 15:6). Translation anchors: 0. Perspectives anchors: 5 of 6 (15:3 skipped the disputed straight-path gloss). Anchor spread: essay 12, narration 11, perspectives 5, note 2. The close-parity line held (odd indices close on multiple choice, even on true or false). Five of six open on multiple choice, and every quiz has who-said-it in slot 2: the opening varies less than in surah 14. One quiz out of verse order (15:4).

### Reader notes (taste, not rule)

- Best questions: 15:5 "By your life" sworn on the Prophet, 15:4 the docile-mounts voice and the correspondence-not-occasion True/False, 15:3 jinn not angel, 15:6 forbearance not cancelled by the command to fight, 15:2 the many-senses point.
- Tabatabai as the named subject of a prompt appears in 15:1 (twice), 15:2, 15:6 and 15:4 (q5): five prompts in six quizzes ask what Tabatabai reads or identifies. Accurate to the passages, which lean on him, but the surah reads as a Tabatabai quiz. A writer-prompt line to vary the framing (ask what the passage or the essay says, name the scholar only when the perspectives split) would spread it out.
- Who-said-it sat in slot 2 in all six quizzes. Not a rule problem, but with the multiple-choice opener it makes every quiz open the same way.
- Guessable gaps: 15:1 "truth" (implication, as in surah 14). The other five gaps carry real meaning with a live distractor each.
- 15:3 q5 has three distractors nobody would pick ("emptied for the dedicated servants", "one gate reserved for Iblis"). The verse wording makes the answer obvious.

### Deviations from the procedure

- No prompt change.
- The free slot after 15:5's review went to the 16:1 writer before 15:6 was reviewed, so surah 16 started while surah 15 was still open. Per-surah assemble and report were still done in order.
- Commits deferred to the end of the loop, per the run's pattern.

## Results - An-Nahl 16:1 to 16:16 (2026-09-21)

Same `/loop` run. No prompt change during the surah; one clarification added after it (below). All 16 passed first review. `quiz_16.json` assembled with 16 quizzes: 32 multiple choice, 16 true or false, 16 fill the gap, 16 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 16:1 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q1 True on the edict as the reckoning drawing near is the essay's opening point; q2 three-armies line has a voice; q3 knowledge of Him is the essay's purpose clause; q4 gap "water" is verse wording, guessable against clay, dust, blood; q5 "no path is straight" is a distractor nobody would pick |
| 16:2 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q2 gap "Imams" on the pillars gloss is the passage's sharpest point, and "mountains" is the distractor a skimmer picks, a real gap; q3 Pole Star line has a voice; q4 forgives the shortfall is the note's point; q5 False on "still hold the power to give" tests the essay's three lacks |
| 16:3 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q2 "does not will their reward" is the essay's gloss, a real check; q3 gap "pilgrims" guessable from "during the Hajj"; q4 cupping-glass oath has a strong voice; q5 asks what the traditions agree on, three distractors nobody would pick; q4 and q5 both on v25 |
| 16:4 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q1 undoing of the plot as a figure is al-Mizan's reading, "literal earthquake" a live distractor; q2 taqwa gathers all good has a voice; q3 myths of the ancients is verse wording, guessable; q4 gap "lovers" fair; q5 False on the Qummi reading leaving out the Qa'im tests the content; q2 and q3 both on v30 |
| 16:5 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q1 the idolaters' conclusion that warnings were pointless is the essay's argument; q3 True on eagerness cannot guide; q4 gap "deliberate" on the will gloss is a real gap, "hesitate" live; q5 raj'a as what the Shia narrations tie the oath to, one-tradition framing; q5 on v38 after q4 on v40, out of order |
| 16:6 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q3 prophecy fixed in ordinary men is the essay's real point; q2 People of the Reminder line has a voice; q4 gap on the phrase "one group after another" with "only the ringleaders first" live, a good gap; q1 verse wording; q2 and q3 both on v43 |
| 16:7 | whoSaid, MC, fillGap, TF, MC | 1 PASS | first who-said-it opener of the surah; q1 two-makers argument has a voice; q2 two-imams gloss is the narration's real point; q3 gap "worship and obedience" fair; q4 True on daughters-to-God is verse wording, easy; q5 the two-way split of description is the essay's close; q1 and q2 both on v51 |
| 16:8 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q1 room to repent is the essay's reason; q2 Night of Decree line has a voice, but the prompt splices a paraphrase after the quote; q3 gap "adorned" fair; q4 the Household as the further clarification, framed as "a reading", "a people who have faith" live; q5 False on rain as a sign God will not raise the dead is a bare negation |
| 16:9 | fillGap, MC, whoSaid, TF, MC | 1 PASS | q1 gap "chokes" on the milk narration is a real gap; q3 honey-cure line has a voice; q4 True on knowledge not in our hands; q5 bee as the Imams in the Shia allegory with distractors from the same allegory, a good perspectives item; q5 on v69 after q4 on v70, out of order |
| 16:10 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q1 duty of fair provision is the note's reading; q2 grandchildren line has a voice; q3 "He has no peer" is the essay's reason; q4 gap "permission" fair; q5 False on Tabatabai reading the parables only as praise, "only" makes it a clean negation |
| 16:11 | MC, TF, whoSaid, fillGap, MC | 1 PASS | q1 ease not distance is Tabatabai's reading, a real check; q2 True on the soul starting empty; q3 Mars and Saturn line has a voice; q4 gap "hot" guessable from "heat alone"; q5 asks what the traditions differ over, the bare fact of disagreement the prompt rules out; the reviewer passed it |
| 16:12 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q1 verse wording, "plead but not propitiate" live; q2 imam-for-every-nation line has a voice; q3 the chain of witnesses with its reverse as a distractor is a real check; q4 gap on the phrase "the Commander of the Faithful"; q5 False on hearsay tests Tabatabai's direct-sight point; q1 to q3 all on v84 |
| 16:13 | whoSaid, fillGap, MC, TF, MC | 1 PASS | q1 justice-and-kindness gloss has a voice; q2 gap "society" is Tabatabai's term, "government" live; q3 asks on what the traditions part, the fact of disagreement again; q4 True on body not religion is the narration's real point; q5 verse wording with the believers as the one live distractor |
| 16:14 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q2 gap "pure" with "holy" as the outside-knowledge distractor is the surah's best gap; q3 non-Arabic speech is the note's real argument; q5 False on taqiyya forbidden tests the Shia reading; q1 abrogation guessable; q5 on v106 after q4 on v108, out of order |
| 16:15 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q4 passing out of faith is the narration's real point; q2 loaves line has a voice; q3 gap "permission" with "rather than obligation" in the prompt makes "obligation" a dead distractor and the gap guessable; q5 False on mercy for the unrepentant is a bare negation; parity slip: the writer read the surah number as the index, so this odd passage closed on a False true or false |
| 16:16 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q1 why Abraham is "a nation" is the narration's real point; q2 gap "burden" fair, "covenant" live; q3 disputation line has a voice; q4 the Messenger's patience after the verse is the narration's payoff, "carried out the mutilation" live; q5 False on everyone standing on Abraham's creed tests the Shia reading; q5 on v123 after q4 on v126, out of order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 16 | 38K | 32K to 49K | 3 min 53 s | 604K tokens, 62 min |
| reviewer | 16 | 20K | 19K to 21K | 34 s | 316K tokens, 9 min |

About 0.92M agent tokens for the surah, roughly 39 minutes wall clock with two slots.

### Review outcomes

16 of 16 PASS first time, no rewrites. Three validator rejections, all an option over twelve words (16:1 q5, 16:6, 16:12 q1), each fixed on the writer's second write. Every gap prompt shipped with its full stop; the span-match friction did not recur.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 11 | | TF | 9 |
| TF | 2 | | MC | 7 |
| whoSaid | 2 | | fillGap | 0 |
| fillGap | 1 | | whoSaid | 0 |

True or false: 7 of 16 True. The parity rules held for 15 of 16 (odd closes on multiple choice with a True statement, even on true or false with a False one); 16:15 broke both because the writer took "index" to mean the surah number. Translation anchors: 0. Perspectives anchors: 11 of 16 (none in 16:1, 16:2, 16:6, 16:7, 16:15). Anchor spread: essay 36, narration 27, perspectives 11, note 6. Four quizzes out of verse order (16:5, 16:9, 16:14, 16:16), all the same shape: a perspectives close anchored to an earlier verse than q4. The opening varied more than in surah 15: five quizzes open on something other than multiple choice, and who-said-it sits in slots 1, 2, 3 and 4 across the surah.

### Reader notes (taste, not rule)

- Best questions: 16:2 the Imams-as-pillars gap, 16:14 the "pure" gap with "holy" as the trap, 16:6 prophecy fixed in ordinary men, 16:12 the chain of witnesses with its reverse as a distractor, 16:9 the bee as the Imams, 16:16 the Messenger's patience.
- Two perspectives questions test the fact of disagreement rather than a reading (16:11 q5 "what do they differ over", 16:13 q3 "on what do they part"), which the prompt already rules out except when the answer is itself substantive; the reviewer accepted both as substantive. No prompt change; noted for the next case.
- Guessable gaps: 16:1 "water", 16:3 "pilgrims", 16:11 "hot", 16:15 "permission" (its contrast word sits in the prompt). The other twelve gaps are real, and three sit on phrases rather than single words (16:6, 16:12, 16:14 style), which read well.
- Out-of-order perspectives closes are now the common case (4 of 16 here, 1 of 6 in surah 15). The ascending-order check listed under open items for `quiz.py` would catch them; the writer follows the "q5 from the close" line and the close is the perspectives, which may cite an earlier verse.
- 16:8 q2 splices a paraphrase after the closing quote mark inside a who-said-it prompt. One case; the prompt says the quote is the narration's words.

### Deviations from the procedure

- Prompt clarification after the surah: both parity lines now say "the passage index (the number after the colon, not the surah number)", motivated by 16:15.
- Surah 17's first two writers started while 16:16 was still open, as with surah 15.
- Commits deferred to the end of the loop.

## Results - Al-Israa 17:1 to 17:12 (2026-09-21)

Same `/loop` run, first surah after the parity clarification. No prompt change during the surah. All 12 passed first review. `quiz_17.json` assembled with 12 quizzes: 24 multiple choice, 12 true or false, 12 fill the gap, 12 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 17:1 | MC, TF, fillGap, whoSaid, MC | 1 PASS | q1 awake not in a dream is the exegetes' point, "in spirit while his body stayed" a live distractor; q2 True on Noah's gratitude is the narration's reason; q3 gap "nations" fair but the prompt runs to twenty-six words; q4 forgiving-Lord line has a voice; q5 pattern repeated in this community is the Shia reading with passage-drawn distractors |
| 17:2 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q1 leapt up before his creation was complete is the narration's surprising point, with the forbidden tree as the trap a skimmer picks; q2 gap "deeds" is Tabatabai's gloss; q3 worldly destruction after a warner is the note's reading; q4 doubled-letter line has a voice; q5 False on "minor aside" is a bare negation |
| 17:3 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q2 "Fie" line has a strong voice; q4 True on spending outside obedience as squandering is the narration's point; q5 widens and narrows provision is the essay's close with two live distractors; q1 need for care greatest is guessable; q3 gap "worship" guessable from "repents" and "turns back"; q1 and q2 both on v23 |
| 17:4 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q3 gap on the phrase "rightful vengeance" from the shared perspectives point is a real gap; q4 the heart questioned about what it resolves upon, with hearing and sight as the traps, the quiz's best; q2 evil-way line has a voice; q1 guessable; q5 False with sons and daughters swapped is the one-word-flip pattern, on the essay's charge rather than a verse line |
| 17:5 | whoSaid, MC, fillGap, TF, MC | 1 PASS | who-said-it opener; q2 seizing a sovereignty none but He can hold is al-Mizan's argument; q3 gap "cracking" on the timber narration is a real gap, "groaning" live; q4 True on the Basmala aloud is the Shia reports' content; q5 originate-then-restore is the essay's reason, "only stones and iron" a distractor nobody would pick |
| 17:6 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q4 annihilation by death is the narration's surprising reading, with earthquake and famine as the traps, the quiz's best; q2 five-resolute line has a voice; q3 gap on the phrase "repel harm", "forgive sins" live; q1 courteous speech guessable; q5 False on the vision as a reward tests "set as a trial" |
| 17:7 | fillGap, MC, whoSaid, TF, MC | 1 PASS | fill-gap opener; q1 gap "locusts" is Tabrisi's image, "moths" live; q2 threat not permission is Tusi's reading; q3 unlawful-wealth line has a voice; q4 True on believers' souls; q5 intrinsic dignity plus an added measure is the essay's close, "carriage over land and sea" a live distractor from the verse; q4 and q5 both on v70 |
| 17:8 | MC, TF, whoSaid, MC, fillGap | 1 PASS | first fill-gap close of the run; q1 what all traditions share on "imam" is a good no-side framing; q2 False by inverting the narration's condition, a real check a skimmer gets wrong; q3 wilaya line has a voice; q4 the community intended though the Prophet is addressed; q5 gap "prophethood" fair, "revelation" live |
| 17:9 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 quote opens with an ellipsis, a fragment; q2 the praiseworthy station as the great intercession; q3 True on the two readings of the entrance prayer restates the note but runs long; q4 gap "Qaim" fair; q5 a man absorbed in secondary causes is al-Mizan's reading, but its three distractors are recycled from earlier questions, so a reader eliminates by memory |
| 17:10 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q1 the Spirit as God's command with the three rival readings as distractors is a real check; q2 Spirit-not-Jibril line has a voice; q3 "knows how He would take it, yet never will" is the narration's subtle point, the quiz's best; q4 gap "letters" fair, "tongues" live; q5 False on every demand within a prophet's power tests the essay's distinction; q1 and q2 both on v85 |
| 17:11 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q1 True on the human-apostle objection is the verse's own claim, easy; q2 asks "who reported this" about an angel's words, a reporter rather than a speaker, the first such framing this run; q3 the Sa'ir valley is a narration detail, nearer trivia than understanding; q4 gap "free choice" is the Shia reading's content, a real gap; q5 exposing the greed is the essay's close |
| 17:12 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q2 nine-signs list has a voice, and the reviewer checked the list is uniquely al-Kazim's; q4 the middle voice as a standing rule for ritual prayer is the perspectives' content, with the wilaya inversion live; q1 bewitched guessable; q3 gap "gradually" guessable from "separate parts, not all at once"; q5 False on many names meaning many gods is a bare negation |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 12 | 36K | 29K to 46K | 3 min 24 s | 429K tokens, 41 min |
| reviewer | 12 | 20K | 19K to 21K | 36 s | 243K tokens, 7 min |

About 0.67M agent tokens for the surah, roughly 30 minutes wall clock with two slots.

### Review outcomes

12 of 12 PASS first time, no rewrites. One validator rejection (17:10 q3, option over twelve words), fixed on the second write. Every gap prompt shipped with its full stop.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 8 | | MC | 6 |
| whoSaid | 2 | | TF | 5 |
| fillGap | 1 | | fillGap | 1 |
| TF | 1 | | whoSaid | 0 |

True or false: 6 of 12 True. Both parity rules held for 12 of 12 after the clarification (odd closes on multiple choice with a True statement, even on a non-multiple-choice with a False one), and 17:8 is the run's first fill-gap close. Translation anchors: 0. Perspectives anchors: 6 of 12. Anchor spread: essay 26, narration 26, perspectives 6, note 2. Every quiz in ascending verse order, the first surah of the run with none out of order. Four openers other than multiple choice.

### Reader notes (taste, not rule)

- Best questions: 17:6 annihilation by death, 17:10 "knows how He would take it, yet never will", 17:4 what the heart is questioned about, 17:2 Adam leaping up too soon, 17:8 the inverted-condition True/False, 17:7 locusts.
- Narration-anchored multiple choice where the narration's reading surprises (17:2 q1, 17:6 q4, 17:10 q3) is the strongest pattern in the surah: the distractors are what a reader assumes and the answer is what the passage says.
- Guessable gaps: 17:3 "worship", 17:12 "gradually" (the prompt's other clause paraphrases). The other ten gaps are real, and the phrase gaps (17:4, 17:6) read well.
- 17:9 q5 reuses the answers of q2, q3 and q4 as distractors, so a reader who got those right eliminates by memory. One case; a line against recycling a quiz's own earlier answers as distractors would be easy to state.
- 17:11 q2 asks who reported an angel's words rather than who spoke them. Accurate to the narration, but the who-said-it prompt shape is "who said this", and a reporter framing invites the compiler's-gloss confusion ruled out after surah 11.
- Bare negations in the False statements (17:2 q5 "minor aside", 17:12 q5 "worshipping more than one God") are the weakest True/False items; the strong ones invert a condition or swap a subject (17:8 q2, 17:10 q5).

### Deviations from the procedure

- No prompt change.
- Surah 18's first two writers started while 17:12 was still open.
- Commits deferred to the end of the loop.

## Results - Al-Kahf 18:1 to 18:12 (2026-09-21)

Same `/loop` run. No prompt change during the surah. All 12 passed first review. `quiz_18.json` assembled with 12 quizzes: 25 multiple choice, 12 true or false, 12 fill the gap, 11 who said it (18:8 had no usable speaker in its brief, so a third multiple choice stands in, as the rules allow).

| passage | type order | reviews | reader note |
|---|---|---|---|
| 18:1 | whoSaid, MC, TF, fillGap, MC | 1 PASS | who-said-it opener; q1 severe-punishment-is-Ali line has a voice; q2 "God's daughters" is known outside the passage, a well-known fact made into a multiple choice; q3 True on concealment under compulsion is the Shia reading's content; q4 old men named youths for their faith is the narration's surprise, a real gap; q5 no unheard-of wonder is Tabatabai's real point, the quiz's best |
| 18:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | q1 gap "faith" on the youths narration repeats 18:1 q4 almost word for word (the same narration ships in both passages), a cross-quiz repeat the per-quiz review cannot see; q2 no creed without clear evidence is Tusi's point; q3 increase-in-faith line has a voice; q4 God's kindness in the resting place is Majma's reading; q5 False on disagreeing over any belief at all is a bare negation; q3 and q5 out of order |
| 18:3 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q2 most townsfolk were Magians is the essay's reason, with "only a little silver" as the trap from the verse; q1 turn-them-twice line has a voice; q4 True on raising them among resurrection-deniers; q5 believers raising a mosque is the Shia reading with a live distractor from the number dispute; q3 gap "idolatry" guessable from "forced back into" |
| 18:4 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q2 solar reconciled with lunar is the note's real reason, the quiz's best; q4 "the prayer" as the gloss on the company of supplicants is the narration's surprise; q1 forty-days ruling has a voice; q3 gap "send away" fair, "appoint as guides" live; q5 False on rejecting the wilaya tie is a bare negation; q3 and q4 both on v28 |
| 18:5 | MC, fillGap, whoSaid, TF, MC | 1 PASS | q2 gap "shirk" on Tabatabai's diagnosis of the boast is a real reason gap, the quiz's best; q3 "I marvel" line has a voice; q4 True on regret over wealth not faith is the note's point; q5 what both traditions share is a good no-side framing; q1 rich man and poor neighbour is guessable; q2 prompt runs to twenty-six words |
| 18:6 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q3 only his own deed, with "nothing at all, not even his deeds" live, is a real check; q2 tilth line has a voice; q1 the arrogant deceived by riches is Tabrisi's target; q4 gap on the one-word command "Read" is thin, a memory of a narration detail; q5 False on love of the Ahl al-Bayt not counted is a bare negation; q5 on v46 after q4 on v49, out of order |
| 18:7 | fillGap, MC, whoSaid, TF, MC | 1 PASS | fill-gap opener; q1 gap "obedience" with "worship" as the trap is a real gap; q3 why Shia commentators hold Iblis was no angel, a one-tradition-and-why framing with fire-versus-light live; q2 jinn-among-angels line has a voice; q5 certain knowledge not supposition is the essay's close; q1 to q3 all on v50; the jinn-not-angel point overlaps 15:3 q3 across surahs |
| 18:8 | MC, fillGap, MC, TF, MC | 1 PASS | no who-said-it, third multiple choice in its place, so an even index closed on multiple choice; q1 souls in God's hand is the narration's story point; q2 gap "punishment" guessable from "extermination that destroyed"; q3 bearers of good news and warners is verse wording; q4 False on never turning to mercy is a bare negation; q5 both traditions on the night visit is a good no-side framing; q5 on v54 after q4 on v58, out of order |
| 18:9 | fillGap, MC, TF, whoSaid, MC | 1 PASS | fill-gap opener; q1 gap "knowledgeable" is the narration's reason for the journey, "powerful" live; q2 the vanished fish as the sign is the essay's point; q3 True on knowledge not in the Tablets is the narration's real point; q4 is a paraphrased "who related this" rather than a quoted who-said-it, the second reporter framing after 17:11; q5 a likeness for Ali and the Imams, its distractors nobody would pick |
| 18:10 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q3 intensity of their love as why the parents would follow the boy is the narration's real point, the quiz's best; q4 four-sentences treasure line has a voice; q1 fears drowning is guessable from the verse; q2 gap "graver" against three antonyms is guessable; q5 False on acting by his own judgment is a bare negation; q4 and q5 both on v82 |
| 18:11 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 neither prophet nor king line has a voice; q2 divides by wrongdoer and believer is the essay's reading of the choice; q4 gap "taqiyya" on the barrier narration is a real reason gap, the quiz's best; q3 True on not knowing how to build houses is a narration detail; q5 second blast that raises the dead is the essay's close, "first blast" live |
| 18:12 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q1 hell as ironic hospitality is Tabatabai's reading, a real check; q3 gap "benefits" on the worst-loss gloss is a real reason gap with "suffers" as the trap; q4 God's words as His act and bestowed existence is the essay's real point; q2 People of the Book line has a voice; q5 False on nothing to do with the Family is a bare negation; q2 and q3 both on v104 |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 12 | 36K | 28K to 42K | 3 min 27 s | 429K tokens, 41 min |
| reviewer | 12 | 20K | 19K to 21K | 36 s | 240K tokens, 7 min |

About 0.67M agent tokens for the surah, roughly 29 minutes wall clock with two slots.

### Review outcomes

12 of 12 PASS first time, no rewrites. One validator rejection (18:9 q5, option over twelve words), fixed on the second write. Every gap prompt shipped with its full stop.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 5 | | MC | 7 |
| whoSaid | 4 | | TF | 5 |
| fillGap | 3 | | fillGap | 0 |
| TF | 0 | | whoSaid | 0 |

True or false: 6 of 12 True, parity held on every statement. The close parity held for 11 of 12: 18:8 is even but closed on multiple choice because with no who-said-it its three multiple-choice questions could only sit in slots 1, 3 and 5. Translation anchors: 0. Perspectives anchors: 11 of 12. Anchor spread: essay 24, narration 22, perspectives 11, note 3. Three quizzes out of verse order (18:2, 18:6, 18:8), all the perspectives-close shape. Seven openers other than multiple choice, the most varied surah of the run.

### Reader notes (taste, not rule)

- Best questions: 18:4 solar reconciled with lunar, 18:10 the parents' love, 18:5 the "shirk" gap, 18:11 the "taqiyya" gap, 18:12 hell as ironic hospitality and the "benefits" gap, 18:1 no unheard-of wonder, 18:7 the "obedience" gap.
- First cross-quiz repeat of the run: 18:1 q4 and 18:2 q1 gap the same narration line ("named them youths for their faith"), because the passage data carries the narration under both v10 and v13. The writer sees one passage at a time, and the reviewer one quiz. This is the surah-level repeat scan listed under the open items for `quiz.py`; a cheaper fix is an "already asked in this surah" list in the brief.
- 18:8 without a who-said-it: the rule that a third multiple choice replaces it worked, but the alternation rule then forced an even index to close on multiple choice. Not worth a prompt line; it needs the brief to have no speaker, which is rare.
- Guessable gaps: 18:3 "idolatry", 18:8 "punishment", 18:10 "graver" (antonym distractors). Nine of twelve gaps are real, and the reason gaps (shirk, taqiyya, obedience, benefits) are the surah's strongest items.
- Bare negations remain the weak True/False pattern: 18:2, 18:4, 18:6, 18:8, 18:10, 18:12 all negate a claim outright, and a reader who never read the passage still answers False. The strong False items elsewhere invert a condition or swap a subject (17:8, 17:10); a line asking for that shape would lift the even-index quizzes.
- 18:9 q4 is the second "who related this" framing (after 17:11 q2), asking for the reporter of a paraphrased scene rather than the speaker of a quoted line.

### Deviations from the procedure

- No prompt change.
- Surah 19's first two writers started while 18:12 was still open.
- Commits deferred to the end of the loop.

## Results - Maryam 19:1 to 19:6 (2026-09-21)

Same `/loop` run. No prompt change during the surah. All 6 passed first review. `quiz_19.json` assembled with 6 quizzes: 12 multiple choice, 6 true or false, 6 fill the gap, 6 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 19:1 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q5 the three days as when a person is most desolate is the narration's reason, the quiz's best; q1 True on concealing a supplication is the essay's point; q2 property versus prophethood asks what the commentators divide over, the fact-of-disagreement shape, though the answer is the substantive point; q3 Yahya and Husayn namesake line has a voice; q4 gap on the phrase "Here I am" fair, "I hear you" live |
| 19:2 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q1 a well-made man while remaining an angel, with "a fully human being" as the trap the note denies, is a real check; q3 prophet-not-messenger line has a voice; q4 those who dispute over him is the note's gloss; q2 gap "silence" is a well-known verse fact, guessable; q5 False on God needing an heir is a bare negation; no perspectives section in this passage |
| 19:3 | TF, MC, fillGap, whoSaid, MC | 1 PASS | q1 True on the maternal grandfather is the Shia view's content and its reason; q3 gap "reproach" on Tusi's second reading is a real gap, though "flowers" and "kindness" are distractors nobody would pick; q4 truthful-repute line has a voice; q5 name versus quality is how the traditions divide, again the fact-of-disagreement shape with a substantive answer; q2 level path is verse wording |
| 19:4 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q3 nearness not physical height, with "fourth heaven" as the trap, is the quiz's best; q4 gap "carelessness" on the neglect gloss is a real gap, "forgetfulness" live, but shipped without a full stop (sixth shipped case); q5 False on which Ishmael Tabatabai leans toward tests the perspectives content; q2 waited-a-year line has a voice; q1 guessable; q5 on v54 after q4 on v59, out of order |
| 19:5 | fillGap, MC, TF, whoSaid, MC | 1 PASS | fill-gap opener; q1 gap "denial" on the commentators' reading of the boast is a real gap, shipped without a full stop (seventh shipped case); q2 created before from nothing is the essay's answer, with "earlier peoples God destroyed" as a live distractor from the same passage; q4 worship-as-obedience line has a strong voice; q5 what both readings share is a good no-side framing; q5 on v71 after q4 on v82, out of order |
| 19:6 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q1 leaving them to the devils they chose, with "forcing them to sin" as the trap, is a real check; q2 counting-of-breaths line has a voice; q3 gap "thorns" on the trees narration is a vivid real gap; q4 walayah of Ali as what Shia tafsir identifies the love with, one-tradition framing; q5 False on hearing a murmur is a bare negation |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 6 | 37K | 34K to 40K | 3 min 32 s | 221K tokens, 21 min |
| reviewer | 6 | 21K | 20K to 21K | 33 s | 124K tokens, 3 min |

About 0.35M agent tokens for the surah, roughly 19 minutes wall clock with two slots.

### Review outcomes

6 of 6 PASS first time, no rewrites. Two validator rejections, both a trailing full stop inside the gap span (19:4 q4, 19:5 q1), each fixed by dropping the full stop, so both shipped without one (sixth and seventh shipped cases). The span-match normalisation listed under the open items for `quiz.py` would remove this friction outright.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 3 | | MC | 3 |
| TF | 2 | | TF | 3 |
| fillGap | 1 | | fillGap | 0 |
| whoSaid | 0 | | whoSaid | 0 |

True or false: 3 of 6 True; both parity rules held for 6 of 6. Translation anchors: 0. Perspectives anchors: 5 of 6 (19:2 has no perspectives section). Anchor spread: essay 11, narration 9, perspectives 5, note 5. Two quizzes out of verse order (19:4, 19:5), both the perspectives-close shape.

### Reader notes (taste, not rule)

- Best questions: 19:1 the three desolate days, 19:4 nearness not height, 19:2 the angel as a well-made man, 19:6 left to the devils they chose and the "thorns" gap, 19:5 the worship-as-obedience voice.
- Two more "what do they divide over" perspectives items (19:1 q2, 19:3 q5), making four in the run (with 16:11, 16:13). Each time the answer is a substantive point, which the prompt allows, but the shape is now the writer's default when the perspectives split; the shared-point framing (18:5, 18:8, 19:5, 20:1) reads better and the prompt could prefer it.
- Guessable gaps: 19:2 "silence" (a famous verse fact, the kind the prompt rules out). The other five are real.
- Bare-negation False statements: 19:2 q5, 19:6 q5. The strong even-index item this surah (19:4 q5, which Ishmael Tabatabai leans toward) swaps a subject rather than negating.

### Deviations from the procedure

- No prompt change.
- Surah 20's first two writers started while 19:6 was still open.
- Commits deferred to the end of the loop.

## Results - Taa-Haa 20:1 to 20:8 (2026-09-21)

Same `/loop` run. No prompt change during the surah. All 8 passed first review. `quiz_20.json` assembled with 8 quizzes: 16 multiple choice, 8 true or false, 8 fill the gap, 8 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 20:1 | whoSaid, MC, TF, fillGap, MC | 1 PASS | who-said-it opener; q1 Ta Ha as a name of the Prophet has a voice; q2 reassurance not exhaustion is the essay's point; q3 True on the two fears is the narration's surprising gloss, the quiz's best; q4 gap "affirming" on Qummi's reading of a rhetorical question, "denying" live; q5 both traditions refuse a bodily sense is a good no-side framing; verse order runs 1, 2, 12, 9, 5 |
| 20:2 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q3 kunya Abu Musab line has a strong voice; q4 each creature guided to its own kind is the narration's surprise, the quiz's best; q1 equal to the mission's weight is al-Mizan's reading, a real check; q2 gap "manners" guessable against obstacles, rewards, proofs; q5 False on al-Mizan making the shared task prophethood tests the perspectives content; q5 on v32 after q4 on v50, out of order |
| 20:3 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q4 True on Moses lacking the lights that supported Ibrahim is the narration's surprising point, the quiz's best; q2 two-creating-angels line has a voice; q1 "what does this verse name" is thin, a note summary with three distractors nobody would pick; q3 gap "divides" guessable from "dispute and then confer in secret"; q5 pointing to the hereafter is the essay's close; q1 and q2 both on v55 |
| 20:4 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q2 yearning-one line has a strong voice; q4 gap "created" on the narration against divine motion is a real reason gap; q3 the seventy men, with "the whole of the Children of Israel" as the trap; q1 staff parts the sea is guessable; q5 False on disagreeing over the first three conditions is a fact-of-disagreement negation; verse order 77, 84, 83, 81, 82 |
| 20:5 | TF, MC, whoSaid, fillGap, MC | 1 PASS | q4 gap "generous" as why God spared the Samiri is the narration's surprise, the quiz's best, "repentant" the trap; q2 feared factions and bloodshed is the essay's reason, "Musa had ordered him to wait" live; q5 why Tabatabai rejects the calf coming alive, a one-tradition-and-why framing with passage distractors; q3 enmity-between-brothers line has a voice; q1 True on Harun's warning is verse content; q2 and q3 both on v94 |
| 20:6 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q5 False on al-Mizan reading the Imams narrations as outward rather than inner meaning is a real swap that tests the essay's distinction, the quiz's best; q3 eyes-perceiving argument has a voice; q4 al-Qa'im and the Sufyani is a note detail, nearer trivia; q1 level plain is verse wording; q2 gap "naked" is a well-known hadith phrase, guessable |
| 20:7 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q2 tree of wheat has a voice and is the narration's surprise; q3 gap on the phrase "narrowed provision" fair, with the other two readings in the prompt as scaffolding; q4 True on blindness of heart is the narration's point; q1 the warning's content is guessable, "whisperer cast out" live; q5 ruined homes as signs is verse wording; q3 and q4 both on v124 |
| 20:8 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q1 decree at Adam's descent is the essay's real point, the quiz's best; q3 singled-out-for-prayer line has a voice; q4 the deniers' plea is the essay's argument, "former scriptures never reached them" live; q2 gap "regret" fair but shipped without a full stop (eighth shipped case); q5 False on Tabari settling the question in this world swaps the timing, a real check |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 8 | 36K | 30K to 48K | 3 min 23 s | 288K tokens, 27 min |
| reviewer | 8 | 21K | 20K to 21K | 34 s | 164K tokens, 5 min |

About 0.45M agent tokens for the surah, roughly 38 minutes wall clock with two slots (interleaved with the tail of surah 19).

### Review outcomes

8 of 8 PASS first time, no rewrites. One validator rejection (20:2 q3, option over twelve words), fixed on the second write. One gap prompt shipped without a full stop (20:8 q2, eighth shipped case).

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 6 | | MC | 4 |
| whoSaid | 1 | | TF | 4 |
| TF | 1 | | fillGap | 0 |
| fillGap | 0 | | whoSaid | 0 |

True or false: 4 of 8 True; both parity rules held for 8 of 8. Translation anchors: 0. Perspectives anchors: 5 of 8. Anchor spread: essay 15, narration 16, perspectives 5, note 4; the first surah where narrations out-anchor the essay. Three quizzes out of verse order (20:1, 20:2, 20:4); 20:1 and 20:4 wander in the middle, not only at the close. Who-said-it sat in slot 2 or 3 in every quiz but 20:1.

### Reader notes (taste, not rule)

- Best questions: 20:5 the "generous" gap, 20:2 each creature to its own kind, 20:3 the lights that supported Ibrahim, 20:6 outward versus inner meaning, 20:8 the decree at Adam's descent, 20:1 the two fears.
- The narration-surprise pattern carried the surah: five of the eight best items are a narration's unexpected gloss with the reader's assumption as the trap.
- Guessable gaps: 20:2 "manners", 20:3 "divides", 20:6 "naked" (a famous hadith phrase). Five of eight are real.
- The even-index False statements improved: 20:2, 20:6 and 20:8 all swap a subject or a timing rather than negating outright; only 20:4 q5 is a bare negation, and it is the fact-of-disagreement shape.
- 20:3 q1 ("what does this verse name") and 20:6 q4 (the Sufyani) are note summaries closer to recall than understanding.

### Deviations from the procedure

- No prompt change.
- Surah 21's first two writers started while 20:8 was still open.
- Commits deferred to the end of the loop.

## Results - Al-Anbiyaa 21:1 to 21:7 (2026-09-22)

Same `/loop` run, resumed in a new session. No prompt change during the surah. 21:1 to 21:3 were written (and 21:1 reviewed) at the tail of the previous session; the rest ran here. All 7 passed first review. `quiz_21.json` assembled with 7 quizzes: 14 multiple choice, 7 true or false, 7 fill the gap, 7 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 21:1 | TF, whoSaid, MC, fillGap, MC | 1 PASS | q2 "wronged the Family of Muhammad" has a partisan voice; q3 bewildered men is Majma's reading, "sincere request for a proof" live; q4 gap "revelation" guessable, wealth, immortality and kingship are distractors nobody would pick; q5 Tabari recording Ali's saying is a one-tradition framing, but the right option is the longest and stands out; verses 1, 3, 5, 7, 7 in order |
| 21:2 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q5 False on prophet versus imam is a real swap, the quiz's best; q4 gap "wisdom" with "justice" a live trap; q2 falsehood-never-stands line has a voice; q3 the name "argument of mutual hindrance" is term recall, nearer trivia; q1 luxury and homes is verse wording; in order |
| 21:3 | MC, fillGap, whoSaid, TF, MC | 1 PASS | q1 rain and growth as the narrations' sense of "interwoven" is the surprise, the quiz's best, and each distractor is a real verse of the passage; q2 gap "life" guessable from "every living thing from water"; q3 health-and-wealth line has a voice; q4 True restates the essay's gloss, thin; q5 mockery closing on the mockers, "idolaters hoped his death" live; q1 and q2 both on v30 |
| 21:4 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q2 gap "learned" for "We diminish it" is the narration's surprise, the quiz's best; q4 no scales for idolaters has a voice; q1 turning the challenge back, with Torah and naming-idols distractors nobody would pick; q3 deficiency in the hearers guessable; q5 False "only justice, not the prophets and Imams" is a bare only-not negation; q4 and q5 both on v47 |
| 21:5 | MC, fillGap, whoSaid, TF, MC | 1 PASS | q4 True on Abraham calling by the right of Muhammad and his family before the fire cooled is the narration's surprise, the quiz's best; q1 rushd as innate grasp, "victory over the fire" live; q2 gap "quietly" is given away by "only one man overheard" in the prompt; q3 Abraham did not lie has a voice; q5 unasked gift, "in answer to his own prayer" live; in order |
| 21:6 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q4 al-Rida's reading of Jonah's thought as certainty about provision, with "God had no power" as the assumed trap, is the narration's surprise, the quiz's best; q2 David rebuked for eating from the treasury has a strong voice; q5 False on the two traditions recording different rulings tests the perspectives' real point; q1 long affliction, "loss of his family" live; q3 gap "Jerusalem" guessable next to "and Syria", shipped without a full stop (ninth shipped case); closes on v78 after v87, out of order |
| 21:7 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q4 gap "Ismail" as the recording angel is a note-level proper noun, nearer trivia, though "al-Sijill" is a live trap from the same narration; q2 shining faces line has a strong voice; q5 raj'a as what Shia narrations take the barred return for, one-tradition framing, but Gog and Magog, the scroll and idols as fuel are other verses' content nobody would pick; q1 recorded and not wasted is guessable; q3 True restates the essay; closes on v95 after v104, out of order |

### Costs (real agents, with hooks; runs measured this session only)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 4 | 37K | 32K to 42K | 3 min 44 s | 150K tokens, 15 min |
| reviewer | 6 | 21K | 20K to 21K | 44 s | 125K tokens, 4 min |

The three writers for 21:1 to 21:3 and the 21:1 reviewer ran in the previous session and are not in the table. Scaled to the surah, about 0.4M agent tokens; roughly 11 minutes wall clock in this session with two slots (the last slot was handed to surah 22's first writer while 21:6 was still under review).

### Review outcomes

7 of 7 PASS first time, no rewrites. One validator rejection (21:6 q3): the writer's gap prompt ended in a full stop, the essay sentence continues ("Jerusalem and Syria, ..."), so the exact-span check refused it and the writer dropped the stop. That is the mechanism behind the ninth stop-less gap: whenever the gap sentence is a clause inside a longer essay sentence, the exact-span rule and the full-sentence rule pull against each other. Note against `quiz.py`: allow a trailing full stop on the prompt when the span match succeeds without it.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 6 | | MC | 4 |
| TF | 1 | | TF | 3 |
| whoSaid | 0 | | fillGap | 0 |
| fillGap | 0 | | whoSaid | 0 |

True or false: 4 of 7 True; both parity rules held for 7 of 7. Translation anchors: 0. Perspectives anchors: 5 of 7. Anchor spread: essay 16, narration 13, perspectives 5, note 1. Two quizzes out of verse order (21:6, 21:7), both by closing on an earlier verse after a later one. Who-said-it sat in slot 2 in five quizzes, slot 3 in one, slot 4 in one.

### Reader notes (taste, not rule)

- Best questions: 21:6 Jonah's thought as certainty about provision, 21:5 calling by the right of Muhammad and his family, 21:4 "We diminish it" as the death of the learned, 21:3 rain and growth for "interwoven", 21:2 prophet versus imam.
- The narration-surprise pattern held: four of the five best are a narration's unexpected gloss with the reader's assumption as the trap.
- Guessable gaps: 21:1 "revelation", 21:3 "life", 21:5 "quietly" (the prompt itself says only one man overheard), 21:6 "Jerusalem" (next to "and Syria"). Three of seven are real: 21:2 "wisdom", 21:4 "learned", 21:7 "Ismail".
- Distractors nobody would pick: 21:1 q4, 21:4 q1, 21:7 q5. The one-tradition perspectives questions (21:1 q5, 21:7 q5) fill their distractors from other verses' content, so the right option stands out by topic alone.
- Two memory items: 21:2 q3 (the name of the argument) and 21:7 q4 (the angel's name).
- Six of seven quizzes open on multiple choice; the surah reads samey at the top even where the middles vary.

### Deviations from the procedure

- No prompt change.
- Surah 22's first writer started while 21:6 was still under review.
- Commits deferred to the end of the loop.

## Results - Al-Hajj 22:1 to 22:10 (2026-09-22)

Same `/loop` run. No prompt change during the surah. 9 of 10 passed first review; 22:8 failed once and passed on the rewrite. `quiz_22.json` assembled with 10 quizzes: 20 multiple choice, 10 true or false, 10 fill the gap, 10 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 22:1 | whoSaid, MC, fillGap, TF, MC | 1 PASS | who-said-it opener, the child-turns-grey line has a strong voice; q3 gap "miscarriage" as al-Baqir's gloss of "unformed" is the narration's surprise, the quiz's best, "embryo" a live trap; q5 the compulsionists' claim as what al-Tabrisi and al-Tusi refute is a one-tradition-and-why framing, but the distractors are other verses' content nobody would pick; q2 Satan drives him to the Blaze is guessable; q4 True restates al-Mizan's conclusion, thin; in order |
| 22:2 | MC, TF, whoSaid, MC, fillGap | 1 PASS | q2 False on the deniers being "content" that Ali was named helper is a real swap of the note's "enraged", the quiz's best; q3 sun's 360 mansions has a strong voice; q1 fringe as weak footing, "devotion so firm" a live inversion; q4 iron clubs at the top of the Fire is the narration's image, rest and shade distractors nobody would pick; q5 gap "Banu Umayya" with "the Quraysh" a live trap, the first fill-the-gap closer of the run; closes on v19 after v22, out of order |
| 22:3 | whoSaid, MC, TF, fillGap, MC | 1 PASS | a three-verse passage, so three of five questions sit on v25; q4 gap "striking a servant" as part of deviation is the narration's surprise, the quiz's best; q5 Tusi's occasion at Hudaybiyya with the Muawiya-doors line as a live trap from the passage; q1 thousand-years fragrance has a voice; q2 path of Islam and the Garden, "no god but God" a live trap from Tabrisi's other gloss; q3 True restates the narration, thin; in order |
| 22:4 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q3 gap "chess" as the abomination of idols is the narration's surprise, the quiz's best, dice and gambling live; q4 severing a sanctity amounts to shirk is the narration's real point, "leaving the faith" live; q1 purify My House as the Family of Muhammad has a partisan voice; q2 days of tashriq is a fact question, first-ten-days and Arafat both live for a hajj-aware reader; q5 False "drop the outward sense" swaps the perspectives' keep-and-add; q3 and q4 both on v30; closes on v29 after v30, out of order |
| 22:5 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q2 content one and beggar has a voice; q5 what the two traditions agree on, with the point of disagreement as the trap, is a fact-of-agreement shape, but a fair one; q3 gap "body" next to "and need" is a reason gap, "place" and "time" live; q1 every believing nation, distractors (Muslims invented it, God needs it) nobody would pick; q4 True restates the note, thin; closes on v34 after v38, out of order |
| 22:6 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q4 the neglected well as the silent Imam has a strong voice and is the narration's surprise, the quiz's best; q1 be patient before the fighting verse, "migrate to Medina" live; q3 consolation is the essay's point, "threaten the Meccans" live; q2 gap "law" on al-Mizan's wider reading, "covenant" live, shipped without a full stop (tenth shipped case, same mechanism as 21:6); q5 False "only Meccan companions and no later figures" is an only-and-no-later negation; closes on v41 after v45, out of order |
| 22:7 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q3 gap "voice" on the muhaddath as one who hears without seeing is the note's real distinction, the quiz's best, "whisper" live; q2 inmates of hell line has a partisan voice; q4 True on both traditions rejecting the gharaniq words is a fact-of-agreement shape; q1 fixes his task as a warner, the distractors are other verses' wording; q5 sovereignty God's alone is guessable; q3 and q4 both on v52; in order |
| 22:8 | MC, whoSaid, fillGap, MC, TF | FAIL, PASS | q5 False on Badr as the renewed wrong (Karbala is the answer) is a real swap of the perspectives' two events, the quiz's best; q2 "revealed concerning the Commander of the Faithful" is a one-line attribution with little voice, and after the rewrite the distractors (Ali, the Prophet, al-Rida) leave al-Sadiq as the only plausible narrator; q3 gap "left their homes for God" is guessable against Badr, Muharram and refusing to migrate; q1 after death, "only the slain" live; q4 reach misses nothing is the essay's phrase; three questions on v58; closes on v60 after v63, out of order |
| 22:9 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q2 the mansak as the Imam for every nation has a strong voice and is the narration's surprise, the quiz's best; q1 resurrection not barzakh is al-Mizan's real distinction, "barzakh" a live trap; q3 True on Tabari's Mina reading, phrased "Sunni exegetes reported from Tabari", clunky; q4 gap "evidence" beside "neither argument nor", guessable; q5 the Fire, famine and exile distractors nobody would pick; q2 and q3 both on v67; in order |
| 22:10 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q1 the green fly with four wings has a strong voice, who-said-it opener; q2 al-Hadi's rebuke of one who likens God to creation is the narration's surprise, the quiz's best, "worships idols openly" the assumed trap; q4 revelation stays protected, "messengers may err" the live inversion; q3 gap "successors" beside "the prophets and their", guessable; q5 False "whole Muslim community" swaps the perspectives' Imams reading; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 10 | 34K | 29K to 41K | 3 min 8 s | 341K tokens, 31 min |
| rewrite | 1 | 26K | | 1 min 4 s | 26K tokens, 1 min |
| reviewer | 11 | 21K | 20K to 23K | 50 s | 231K tokens, 9 min |

About 0.6M agent tokens for the surah, roughly 23 minutes wall clock with two slots (the last slot went to surah 23's first writer while 22:10 was still under review).

### Review outcomes

9 of 10 PASS first time. 22:8 FAIL on q2 (who said it): narration n1 gives the line "revealed concerning the Commander of the Faithful in particular" to Imam al-Sadiq, but the passage's perspectives credit the same statement to a report from Imam al-Baqir, and al-Baqir was an option. The writer kept al-Sadiq as the answer and dropped al-Baqir from the options; the second review passed. Note against the writer prompt: when a passage carries the same statement under two narrators, the other narrator must not be a distractor, which the prompt does not say yet, and the rewrite found it on its own.

One validator rejection (22:6 q2): trailing full stop on a gap prompt whose essay sentence continues, the same exact-span mechanism as 21:6. Tenth stop-less gap shipped. The `quiz.py` note from surah 21 stands.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 6 | | MC | 5 |
| whoSaid | 4 | | TF | 4 |
| TF | 0 | | fillGap | 1 |
| fillGap | 0 | | whoSaid | 0 |

True or false: 5 of 10 True; both parity rules held for 10 of 10. Translation anchors: 0. Perspectives anchors: 9 of 10, the highest so far. Anchor spread: essay 19, narration 17, perspectives 9, note 5. Five quizzes out of verse order (22:2, 22:4, 22:5, 22:6, 22:8), every one by closing on an earlier verse after a later one: the perspectives close is anchored to a mid-passage verse, so the parity rule that puts the perspectives question last pulls the verse order out of line. Who-said-it opened four quizzes, the most varied top of any surah yet.

### Reader notes (taste, not rule)

- Best questions: 22:4 "chess" as the abomination of idols, 22:1 "miscarriage" as the unformed, 22:6 the neglected well as the silent Imam, 22:9 the mansak as the Imam, 22:10 likening God to creation, 22:2 the deniers "content" versus enraged, 22:8 Badr versus Karbala.
- Six of the seven best are a narration's unexpected gloss; the surah's narrations are rich in glosses that swap a reader's assumption.
- Guessable gaps: 22:8 "left their homes for God", 22:9 "evidence", 22:10 "successors". Seven of ten are real, the best gap rate of the run.
- Distractors nobody would pick: 22:1 q5, 22:2 q4, 22:5 q1, 22:9 q5. The one-tradition perspectives questions still fill their distractors from other verses' content.
- Thin True statements: 22:1 q4, 22:3 q3, 22:5 q4 restate a note or conclusion. The False statements (22:2, 22:4, 22:6, 22:8, 22:10) are all real swaps; the even-index False rule keeps producing the better items.
- Fact-of-agreement shape twice (22:5 q5, 22:7 q4).
- 22:9 q3 reads clunkily ("Sunni exegetes reported from Tabari"); the reviewer let it through as parseable.

### Deviations from the procedure

- No prompt change.
- Surah 23's first writer started while 22:10 was still under review.
- Commits deferred to the end of the loop.

## Results - Al-Muminoon 23:1 to 23:6 (2026-09-22)

Same `/loop` run. No prompt change during the surah. All 6 passed first review. `quiz_23.json` assembled with 6 quizzes: 13 multiple choice, 6 true or false, 6 fill the gap, 5 who said it (23:5 has one narration only, so it carries a third multiple choice).

| passage | type order | reviews | reader note |
|---|---|---|---|
| 23:1 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q1 the Garden made to speak has a strong voice, who-said-it opener; q2 Meccan zakat as giving of wealth generally is Tabatabai's real reasoning, "fixed alms at Medina" the live trap, the quiz's best; q3 True on inheriting the forfeited dwellings is the narration's surprise; q4 gap "spirit" for "another creature", "intellect" live; q5 the one Lord who deserves worship is guessable and the longest option; in order |
| 23:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener, the first of the run; q1 gap "most pressing" on why Noah begins with tawhid is a reason gap, "final" live; q4 refuge from being wronged but not from being tested is the narration's surprise, the quiz's best; q3 the landing supplication taught by the Prophet, phrased "Who taught this?", a fair variant; q2 lord it over them, "true prophet" a distractor nobody would pick; q5 False on Lot for Ad or Thamud is a real swap; in order |
| 23:3 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener; q2 al-Tusi's contradiction (following a man a loss, worshipping an idol not) is the essay's sharpest point, the quiz's best, though the right option is the only one in a different grammatical shape; q4 Kufa, the mosque, the Euphrates has a strong voice; q3 gap "plant matter" for ghutha, "sea foam" a live trap; q5 fact-of-agreement shape with Iraq and Syria as the two sides' answers for traps, a fair one; q1 True restates the essay, thin; q4 and q5 both on v50; in order |
| 23:4 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q4 creation rests on truth not appetite is the essay's real reasoning, the quiz's best, though the right option is the longest; q1 one community as the Family of Muhammad, "the people of Islam" the assumed trap; q3 "none took the lead before him" has a voice, phrased "Who said it?"; q2 gap "rejoicing" is verse wording, guessable; q5 False phrased as "something other than the wilayat", a double negative that makes a reader work for the wrong reason; in order |
| 23:5 | MC, fillGap, MC, TF, MC | 1 PASS | no who-said-it (one narration), the first of the run; q1 the heart as seat of understanding is Tabatabai's real distinction, "merely stores what the senses gather" the live trap, the quiz's best; q5 the Unseen as what has not yet come to be, "what has already come to pass" a live inversion; q2 gap "lies" for myths of the ancients, guessable; q3 "To Allah" anchored on the verse translation, the first translation anchor of the run, verse wording; q4 True on the two-gods argument restates the essay; in order |
| 23:6 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q3 wretched by their own deeds is the narration's point, "promptings of the devils" the assumed trap, the quiz's best; q4 the patience of Ali, Fatimah, Hasan and Husayn has a partisan voice, with Ibn Masud as the surprising narrator; q1 the Mina warning as the occasion, one-tradition framing with other passage events as distractors nobody would pick; q2 gap "reward and punishment" in the barzakh, "questioning and trial" a live trap; q5 False "a long list of prayers rather than a single one" is a real swap of the essay's close; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 6 | 37K | 32K to 45K | 3 min 38 s | 219K tokens, 22 min |
| reviewer | 6 | 20K | 20K to 21K | 45 s | 123K tokens, 5 min |

About 0.34M agent tokens for the surah, roughly 17 minutes wall clock with two slots (the last slot went to surah 24's first writer while 23:6 was being written). 23:4, the longest passage (verses 51 to 77), was the most expensive writer of the run at 45K tokens and 5 min 23 s.

### Review outcomes

6 of 6 PASS first time, no rewrites, no validator rejections. Every gap prompt shipped with a full stop.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 3 | | MC | 3 |
| whoSaid | 1 | | TF | 3 |
| TF | 1 | | fillGap | 0 |
| fillGap | 1 | | whoSaid | 0 |

True or false: 3 of 6 True; both parity rules held for 6 of 6. Translation anchors: 1 (23:5 q3, the first of the run). Perspectives anchors: 3 of 6. Anchor spread: essay 14, narration 12, perspectives 3, translation 1, note 0. All six quizzes in verse order, the first surah of the run with none out of order; the three perspectives closes happened to sit on late verses. Openers were the most varied yet: four different types across six quizzes.

### Reader notes (taste, not rule)

- Best questions: 23:1 Meccan zakat, 23:2 tested but not wronged, 23:3 al-Tusi's contradiction, 23:4 creation rests on truth, 23:5 the heart above the senses, 23:6 wretched by their own deeds.
- The balance shifted toward the essay: four of the six best are an essay's reasoning with the reader's assumption as the trap, only two a narration's gloss. This surah's essays argue more than they gloss.
- Guessable gaps: 23:4 "rejoicing" (verse wording), 23:5 "lies". Four of six are real.
- Longest-option tells: 23:1 q5, 23:4 q4; 23:3 q2's right option is the only one in a different grammatical shape.
- 23:4 q5's double negative ("something other than the wilayat" is False) is the one statement a reader could miss for the wrong reason. Note against the writer prompt: an even-index False statement should assert a wrong positive, not negate the right one.
- Distractors nobody would pick: 23:2 q2, 23:6 q1.

### Deviations from the procedure

- No prompt change.
- Surah 24's first writer started while 23:6 was being written.
- Commits deferred to the end of the loop.

## Results - An-Noor 24:1 to 24:9 (2026-09-22)

Same `/loop` run, the last surah with shipped passages. No prompt change during the surah. All 9 passed first review. `quiz_24.json` assembled with 9 quizzes: 18 multiple choice, 9 true or false, 9 fill the gap, 9 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 24:1 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener; q5 grace and mercy as the Messenger and the guardianship of the Imams is the narration's surprise, the quiz's best, with the passage's legal content as live traps; q4 gap "returned to him" after the husband's recantation is a ruling gap, "parted from him" the assumed trap; q2 the group is one man has a voice but the quote opens mid-sentence, clunky; q3 the Imams' standing-ban reading, one-tradition framing with other rulings of the passage as distractors, fair; q1 True is a compound statement (order of revelation and the promised way), a reader could hesitate on either half; in order |
| 24:2 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q2 gap "all" in "do not say all that you do know" is the narration's turn of thought, the quiz's best, "some" the assumed trap; q4 belie your hearing and sight against your brother has a strong voice, with the other narrators as distractors; q1 exposed the liars and cleared the innocent, "earned them a reward" live; q3 never repeat the calumny is guessable; q5 False "leaves guilt unresolved" is a fact-of-agreement negation; q4 and q5 both on v19; in order |
| 24:3 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q3 True on a believer's limbs not testifying against him is the narration's surprise, the quiz's best; q1 pure only through God's grace, "by their own effort" the live trap, but the right option is the longest; q4 gap "forbade" is given away by the prompt's "the fornicator marries only a fornicatress"; q2 mutual pardon has little voice and the quote is unquoted in the prompt; q5 forgiveness and a noble provision is verse wording; q4 and q5 both on v26; in order |
| 24:4 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, the fall of the sandal has a voice; q3 gap "face" on what may be seen of a non-kin woman is the narration's ruling, "hair" the live trap, the quiz's best; q5 False "binding obligation" swaps the perspectives' recommendation, a real swap; q4 poverty no barrier, "must delay until wealthy" the assumed trap; q2 shield private matters is guessable and the longest option; q1 and q2 both on v27; in order |
| 24:5 | TF, MC, whoSaid, fillGap, MC | 1 PASS | true-or-false opener; q4 gap "Satan" for giving up trade, said three times, is the narration's surprise, the quiz's best, "the miser" the assumed trap; q5 the layered darkness as the rulers who seized power, one-tradition framing with the mirage and the oil from the same verses as live traps; q3 five lights has a voice; q2 the second reading of "His Light" as sun, moon and stars, a two-readings shape that works; q1 True restates al-Mizan's comparison, thin; three questions on v35, the Light Verse; in order |
| 24:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q1 the rooster angel has a strong voice, who-said-it opener; q2 verses 41 to 46 as an argument for the Light verse is Tabatabai's structural point, the quiz's best; q3 gap "people" for those on two feet is guessable next to snakes and beasts, shipped without a full stop (eleventh shipped case, same mechanism); q4 fact-of-agreement shape, distractors (idols, hoarding, prayer) nobody would pick; q5 False "reaches no verdict, leaving their state undecided" is a bare negation of the essay's close; in order |
| 24:7 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener; q4 gap "prayer" is the narration's paradox (no zakat, no prayer), the quiz's best, but the answer word already sits in the prompt, which the reviewer noted and let through; q2 the sheet reading "honourable obedience" has a strong voice; q3 hearing, obedience, trust and patience is a list-recall item, nearer memory; q1 True restates Tabatabai; q5 never frustrate Allah, "an oath that they will march out" a live trap from v53; in order |
| 24:8 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q1 gap "undressed" at the three hours is al-Tusi's reason for the ruling, "asleep" the assumed trap, the quiz's best; q4 only to the extent of need, "with the owner's spoken permission" live; q3 head-covering and cloak, phrased as a question-and-answer who-said-it, a fair variant; q2 slaves and pre-pubescent children is note recall; q5 False "only together, never alone" swaps the essay's "together or separately", a real swap; q1 and q2 on v58, q4 and q5 on v61; in order |
| 24:9 | fillGap, TF, MC, whoSaid, MC | 1 PASS | a three-verse passage, three of five questions on v63; q4 affliction in his religion or an unrewarded wound has a voice, phrased "Who gave this gloss?", with Ibn Abbas as a live trap from the perspectives; q2 True on the Hanzala occasion at Uhud is narration content, a fact a reader either remembers or not; q1 gap "Friday prayer" in Tusi's list, "pilgrimage season" live; q3 Tabatabai's reading of the summons, "the trumpet blast" a distractor nobody would pick; q5 fact-of-agreement shape with the two sides' narrowings as traps, fair; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 9 | 38K | 32K to 48K | 4 min 0 s | 344K tokens, 36 min |
| reviewer | 9 | 21K | 20K to 26K | 51 s | 190K tokens, 8 min |

About 0.53M agent tokens for the surah, roughly 26 minutes wall clock with two slots. 24:4 (verses 27 to 34, the hijab and marriage rulings) was the most expensive writer of the whole run at 48K tokens and 6 min 14 s; 24:7's reviewer was the slowest reviewer of the run at 1 min 48 s, having weighed the gap-word-in-prompt case.

### Review outcomes

9 of 9 PASS first time, no rewrites. One validator rejection (24:6 q3): trailing full stop on a gap prompt whose source sentence continues with a semicolon, the same exact-span mechanism as 21:6 and 22:6. Eleventh stop-less gap shipped. The `quiz.py` note stands.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 3 | | MC | 5 |
| MC | 2 | | TF | 4 |
| whoSaid | 2 | | fillGap | 0 |
| fillGap | 2 | | whoSaid | 0 |

True or false: 5 of 9 True; both parity rules held for 9 of 9. Translation anchors: 0. Perspectives anchors: 6 of 9. Anchor spread: narration 20, essay 17, perspectives 6, note 2; the second surah where narrations out-anchor the essay. All nine quizzes in verse order. Openers are the most even of any surah: no type opened more than three. Who-said-it sat in every slot from 1 to 4.

### Reader notes (taste, not rule)

- Best questions: 24:1 grace and mercy as the Messenger and the Imams, 24:2 "do not say all that you do know", 24:3 the limbs that do not testify, 24:4 "face", 24:5 "Satan" said three times, 24:6 the argument for the Light verse, 24:7 no zakat no prayer, 24:8 "undressed".
- Six of the eight best are a narration's gloss or ruling; the legal surah's narrations carry the quizzes.
- Real gaps: 24:1, 24:2, 24:4, 24:5, 24:8, 24:9. Guessable: 24:3 (given away by the prompt), 24:6 (next to snakes and beasts), 24:7 (answer word already in the prompt). Note against the writer prompt: the gap word must not appear elsewhere in the prompt, which the prompt does not say yet; 24:7 q4 is the first shipped case.
- Thin True statements: 24:1 q1 (compound), 24:5 q1, 24:7 q1. 24:9 q2 is a fact of the occasion of revelation rather than understanding.
- Bare negations among the False statements: 24:2 q5, 24:6 q5. The others (24:4, 24:8) are real swaps.
- Fact-of-agreement shape three times (24:2 q5, 24:6 q4, 24:9 q5), the most of any surah; the perspectives of this surah agree more than they differ.
- Longest-option tells: 24:3 q1, 24:4 q2.
- 24:1 q2's quote opens mid-sentence ("this is in carrying out...") and 24:3 q2's quote is unquoted in the prompt; both read clunkily.

### Deviations from the procedure

- No prompt change.
- Commits deferred to the end of the loop.

## Run summary - surahs 21 to 24 (2026-09-22)

One `/loop` session, 14:02 to 15:12, about 70 minutes wall clock. 32 quizzes written and passed (7 + 10 + 6 + 9); one FAIL (22:8, who-said-it ambiguity), fixed on one rewrite; three validator rejections, all the gap-prompt full-stop case. About 1.75M agent tokens in this session (surah 21 partly written in the previous session).

| surah | quizzes | first-review pass | rewrites | agent tokens | wall clock |
|---|---|---|---|---|---|
| 21 | 7 | 7 | 0 | 0.28M (4 writers, 6 reviewers measured) | 11 min |
| 22 | 10 | 9 | 1 | 0.60M | 23 min |
| 23 | 6 | 6 | 0 | 0.34M | 17 min |
| 24 | 9 | 9 | 0 | 0.53M | 26 min |

Every surah with shipped passages (1 to 24) now has a quiz file. The next quiz surah is whichever surah the passage pipeline ships next (25 is in progress there).

Notes carried out of the run, for the next prompt or validator change:

- `quiz.py`: allow a trailing full stop on a gap prompt when the exact-span match succeeds without it (three validator rejections and three stop-less gaps shipped this run; eleven in total).
- Writer prompt: when a passage carries the same statement under two narrators, the other narrator must not be a distractor (22:8).
- Writer prompt: the gap word must not appear elsewhere in the prompt (24:7 q4), and the prompt must not paraphrase the answer (21:5 q2, 24:3 q4).
- Writer prompt: an even-index False statement should assert a wrong positive rather than negate the right one (23:4 q5's double negative, 21:4 q5, 22:6 q5, 24:6 q5).
- Writer prompt: in a one-tradition perspectives question, at least one distractor should come from the same verse, not another verse's content (21:1 q5, 21:7 q5, 22:1 q5, 24:9 q3).

## Results - Al-Furqaan 25:1 to 25:6 (2026-09-30)

First surah of a `/loop` run over surahs 25 to 44, three agent slots (the user capped this run at three). No prompt change. All 6 passed first review. `quiz_25.json` assembled with 6 quizzes: 12 multiple choice, 6 true or false, 6 fill the gap, 6 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 25:1 | fillGap, whoSaid, MC, TF, MC | 1 PASS | fill-the-gap opener; q1 gap "decisive" is al-Sadiq's gloss on Quran vs Furqan, the quiz's best, "abrogated" a live trap; q2 taqdir as the setting of limits has a voice, al-Rida against al-Sadiq and al-Baqir; q3 helpers as People of the Book, "Meccan poets" live; q4 True restates Tabatabai's descending demands, thin; q5 one-tradition framing with distractors drawn from verses 1 and 2 of the same passage, fair; in order |
| 25:2 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q2 Ali as the noblest of the twelve hours has a strong voice; q3 gap "pretext" is Tabatabai's turn, the quiz's best, the other options nobody would pick; q1 gardens in this world, "the Garden promised" the live trap; q4 besought by the Godwary, the note's second reason (the angels) left out so only one option fits; q5 False swaps who is tested (the afflicted, not the rich), a real swap, though a reader might think the rich are tested too; in order |
| 25:4 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q4 desire as a god means obeying it in place of God, "deny that God exists" the live trap, the quiz's best; q5 False "equally astray, neither given the means" is a real swap of the essay's reason; q2 the pine tree Shah Darakht with "O brother of Tamim" has a strong voice; q3 gap "clay" for sijjil, "brimstone" the live trap, but it is a word gloss nearer memory; q1 distractors (reward, miracles, gardens) nobody would pick; in order |
| 25:3 | TF, MC, whoSaid, fillGap, MC | 1 PASS | true-or-false opener; q2 the angels seen at death before the Resurrection, "only on the Day of Resurrection" the live trap, the quiz's best; q5 al-Jubba'i's reason (a bodily vision is impossible), distractors drawn from verses 21 and 30 of the same passage, fair; q3 the widened grave has a voice; q4 gap "guardian" beside Ali is guessable in this app; q1 True restates Tabatabai, thin; q5 returns to v21 after v27, out of verse order (perspectives close) |
| 25:5 | fillGap, whoSaid, MC, TF, MC | 1 PASS | fill-the-gap opener; q1 gap "sunrise" places the twilight in the morning, "sunset" the assumed trap, the quiz's best; q3 jihad with the Quran, "the sword" the live trap, a real understanding point; q2 approach water as mercy has a voice; q4 True restates the guardianship narration of the two seas, narration content; q5 cousin and son-in-law, distractors from the passage's other glosses (Adam and the rib from the same verse), fair, right option the longest; in order |
| 25:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, "a guarded secret of Muhammad's family" has a strong voice; q2 al-Tusi's peace-and-fighting reconciliation, "later abrogated" the live trap, the quiz's best; q3 gap "stinginess" in the pebbles demonstration, "wastefulness" and "balance" live from the same narration; q4 misdeeds changed into good deeds, "conceal his misdeeds" live; q5 False "values them for their own sake" is a real positive claim against the essay's close; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 6 | 53K | 40K to 73K | 6 min 40 s | 321K tokens, 40 min |
| reviewer | 6 | 24K | 23K to 24K | 59 s | 142K tokens, 6 min |

About 0.46M agent tokens for the surah, roughly 18 minutes wall clock with three slots. Writers ran longer and heavier than in surahs 21 to 24 (38K, 4 min): 25:3 (verses 21 to 34) took 73K tokens and 10 min 38 s, the most expensive writer of any surah so far; its report shows it weighed which perspectives glosses were disputed before choosing anchors.

### Review outcomes

6 of 6 PASS first time, no rewrites, no validator rejections.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| fillGap | 2 | | MC | 3 |
| MC | 2 | | TF | 3 |
| TF | 1 | | fillGap | 0 |
| whoSaid | 1 | | whoSaid | 0 |

True or false: 3 of 6 True; both parity rules held for 6 of 6. Translation anchors: 0. Perspectives anchors: 4 of 6. Anchor spread: essay 13, narration 12, perspectives 4, note 1. Five of six in verse order; 25:3 closes on a perspectives question about verse 21. Who-said-it sat in slot 2 four times out of six, the one pattern that repeats.

### Reader notes (taste, not rule)

- Best questions: 25:1 "decisive", 25:2 "pretext", 25:3 the angels at death, 25:4 desire as a god, 25:5 twilight before "sunrise", 25:6 peace not cancelled by fighting.
- The perspectives closers now draw distractors from the same passage's other glosses (25:1, 25:3, 25:5), which answers the surah 21 to 24 note on one-tradition questions.
- Real gaps: 25:1, 25:2, 25:5, 25:6. Guessable: 25:3 "guardian" beside Ali. 25:4 "clay" is a word gloss, nearer memory.
- False statements are real swaps this surah (25:2, 25:4, 25:6); no bare negations.
- Thin True statements: 25:1 q4 and 25:3 q1 restate Tabatabai.
- Longest-option tell: 25:5 q5.

### Deviations from the procedure

- Three slots instead of four, at the user's request; free slots started surah 26 while surah 25 finished.
- Commits deferred to the end of the loop.

## Results - Ash-Shu'araa 26:1 to 26:11 (2026-09-30)

Same `/loop` run, three slots. No prompt change. All 11 passed first review. `quiz_26.json` assembled with 11 quizzes: 23 multiple choice, 11 true or false, 11 fill the gap, 10 who said it (26:9 has no narrations, notes or perspectives, so it carries a third multiple choice).

| passage | type order | reviews | reader note |
|---|---|---|---|
| 26:1 | whoSaid, MC, fillGap, TF, MC | 1 PASS | who-said-it opener, the letters as divine names has a voice; q4 True on entrenched habit rather than God's prior knowledge is Tabatabai's theological point, the quiz's best; q2 gentle reproach, "prophecy of his martyrdom" the live trap, but the right option is the longest; q3 gap "the Day of Resurrection", "their deathbeds" live; q5 the Cry heralding al-Qa'im, distractors from verses 2, 5 and 7, fair; q5 returns to v4 after v8 (perspectives close) |
| 26:3 | MC, TF, fillGap, whoSaid, MC | 1 PASS | q1 delay not death lest the people be drawn to Moses, "feared his magic" the live trap, the quiz's best; q3 gap "challenge" for a command in form, "warning" live; q4 the staff melting like lead has a strong voice; q2 True restates the magicians' resolve, narration content; q5 fact-of-agreement shape, distractors (begged, fled, renounced) nobody who read verse 50 would pick; in order |
| 26:2 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q3 the prophets described God by His acts not by limit or part is the narration's theology, the quiz's best; q1 most did not believe, "finally came to believe" the live trap; q2 the Qa'im reciting Moses's words has a voice; q4 gap "worshipped" in Haman's taunt, "mighty" and "supreme" live; q5 False "only a single proof" is a bare count negation of al-Tusi's two proofs, thin; q4 and q5 both on v32; no perspectives question (the only disputed gloss avoided); in order |
| 26:4 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q2 gap "suffice" for "He will guide me" is al-Baqir's turn, the quiz's best, but the anchor quote opens on a dangling apostrophe; q3 the sea rebuking Moses has a strong voice, phrased "Who narrated"; q1 religion and land, "theft of his treasures" live from v58; q4 angels turning the mounts back, right option the longest; q5 False swaps the Arab idolaters for the Children of Israel, a real swap, though a reader who knows Abraham is also Israel's forefather may hesitate; in order |
| 26:5 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q1 Abraham asking as one who knows nothing so they are held to their case, "truly did not know" and "to mock the idols" live, the quiz's best; q3 True on the kinsman who strayed is the Shia reading, a perspectives statement that holds; q4 gap "none in it but Him" is a four-word span, the sound heart's definition, distractors from v88 live; q2 judge by God's judgement not analogy has a voice; q5 denial nothing new, "a promise they will soon believe" live; in order |
| 26:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, the thousand years save fifty is a fact more than a voice; q4 the laden ark as made ready and finished, "weighed down with pairs of every animal" the assumed trap, the quiz's best; q2 the plural apostles as the prophets back to Adam, framed as the Shia narrations, distractors from the same verse, fair; q3 gap "contempt" is guessable beside "riffraff"; q5 False "unique to Noah's episode" asserts a wrong positive, fair; q1 and q2 both on v105; in order |
| 26:7 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 the plural apostles because rejecting one is rejecting all, "denied Noah before Hud" the live trap, the quiz's best; q1 Noah foretelling Hud has a voice, phrased "Who reported"; q3 True on every building a burden restates the Prophet's narration, narration content; q4 gap "anger" in al-Qummi's gloss, "greed" live; q5 the closing refrain, distractors with "only" nobody would pick, and the second passage running where the refrain is the closer (26:6, 26:7); q1 and q2 both on v123; in order |
| 26:8 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q4 all punished because all consented is Imam Ali's moral point, "hid the man" the live trap, the quiz's best; q1 gap "rebuke" is derivable from the clause after the colon, guessable; q3 "hollow" for bewitched has a voice; q2 the nine chiefs, other options nobody would pick; q5 False "unique to Salih's story" is the third quiz running on the refrain (26:6 q5 TF, 26:7 q5 MC, 26:8 q5 TF), a repetition across the surah; in order |
| 26:9 | MC, TF, MC, fillGap, MC | 1 PASS | a passage with no narrations, notes or perspectives, so three multiple choice and no who-said-it; q4 gap "believed" on why Lot names only his household, "repented" live, the quiz's best; q2 True on Tabatabai's argument from creation, thin; q1 and q3 are anchored on verse translations (no reward, the threat of banishment), recall of what a verse says, nearer memory, the first quiz of the run with two translation anchors (forced: the essay is the only other part); q5 Lot's wife guiding the corrupt, distractors nobody would pick; in order |
| 26:11 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener; q3 the proof stands against them though they disbelieve, "they repent" the live trap, the quiz's best; q2 the merit of the non-Arabs has a voice, but the quote opens mid-sentence in lower case; q4 gap "comfort" needs the narration's context (the grieved dream of the Bani Umayya), which the prompt leaves out, so any of the four fits the sentence alone; q5 fact-of-agreement shape (the feast both record), distractors from other verses; q1 True is compound (warning and defense), thin; in order |
| 26:10 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q1 "Shu'ayb said to them" without "their brother" as not their kinsman, distractors true of Shu'ayb but no explanation of the wording, the quiz's best; q2 Ali patrolling the Kufa markets has a strong voice, with Ibn Abbas as a distractor and "The Prophet" capitalised against the house "the Prophet"; q3 gap "contempt" in "They answer with contempt" repeats 26:6 q3 word for word in shape; q4 the dare to mock him, "to test whether the sky would give shade" live; q5 False the cloud gave shade, a real swap; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 11 | 55K | 41K to 79K | 6 min 58 s | 604K tokens, 77 min |
| reviewer | 11 | 24K | 22K to 28K | 1 min 8 s | 267K tokens, 12 min 30 s |

About 0.87M agent tokens for the surah, roughly 37 minutes wall clock with three slots. 26:10 (verses 176 to 191) was the most expensive writer of the run so far at 79K tokens and 12 min 5 s; 26:7's reviewer the slowest at 2 min 1 s.

### Review outcomes

11 of 11 PASS first time, no rewrites, no validator rejections.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 6 | | MC | 6 |
| whoSaid | 3 | | TF | 5 |
| fillGap | 1 | | fillGap | 0 |
| TF | 1 | | whoSaid | 0 |

True or false: 6 of 11 True; both parity rules held for 11 of 11. Translation anchors: 2, both in 26:9, forced by a passage whose only other part is the essay. Perspectives anchors: 6 of 11. Anchor spread: essay 26, narration 20, perspectives 6, translation 2, note 1. Ten of eleven in verse order; 26:1 closes on a perspectives question about verse 4. Multiple choice opened six of eleven, the heaviest single opener since surah 20.

### Reader notes (taste, not rule)

- Best questions: 26:2 the prophets described God by His acts, 26:3 delay not death, 26:4 "suffice", 26:5 Abraham asking as one who knows nothing, 26:6 the laden ark made ready, 26:7 rejecting one is rejecting all, 26:8 all punished because all consented, 26:10 "Shu'ayb said to them".
- The surah's refrain drew three quizzes in a row (26:6 q5, 26:7 q5, 26:8 q5), two of them the same False shape ("unique to this story"). Each quiz is right alone; a reader doing the surah in order meets the same question three times. Note against the writer prompt: in a surah with a refrain, test it at most once.
- 26:6 q3 and 26:10 q3 are the same fill-the-gap sentence shape ("They answer with contempt"), both guessable from what follows the colon; 26:8 q1 "rebuke" is the same mechanism. Note against the writer prompt: a gap should not be recoverable from the clause after a colon.
- Real gaps: 26:4 "suffice", 26:5 "none in it but Him", 26:9 "believed", 26:2 "worshipped". Guessable: 26:6, 26:8, 26:10. 26:11 q4 "comfort" needs the narration's context, which the prompt leaves out.
- Thin True statements: 26:11 q1 (compound), 26:9 q2. Bare negation: 26:2 q5 ("only a single proof"). Real swaps: 26:4, 26:6, 26:8, 26:10.
- 26:9 q1 and q3 ask what a verse says (no reward, banishment), recall rather than understanding; the passage offered nothing else beyond the essay.
- Clunky quotes: 26:4 q2's anchor opens on a dangling apostrophe; 26:11 q2's quote opens mid-sentence in lower case. 26:10 q2 writes "The Prophet" against the house "the Prophet".
- Longest-option tells: 26:1 q2, 26:4 q4.

### Deviations from the procedure

- Three slots, at the user's request; free slots started surah 27 while surah 26 finished.
- Commits deferred to the end of the loop.

## Results - An-Naml 27:1 to 27:7 (2026-09-30)

Same `/loop` run, three slots. No prompt change. All 7 passed first review. `quiz_27.json` assembled with 7 quizzes: 14 multiple choice, 7 true or false, 7 fill the gap, 7 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 27:1 | fillGap, MC, TF, whoSaid, MC | 1 PASS | fill-the-gap opener; q2 "immaculate is Allah" as beyond a body confined by place, "the fire has become holy ground" the live trap, the quiz's best; q1 gap "Seeker" in Ta Seen is the same gloss 26:1 q1 asked as who-said-it, a repeat across adjacent surahs and a word to remember; q3 True on Tabrisi and Tusi's disconnected exception, a perspectives statement that holds; q4 without leprosy has little voice; q5 plain magic, right option the longest and the distractors nobody would pick; in order |
| 27:2 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, "God has taught us the speech of the birds" has a strong voice; q4 the decree dims the sight, al-Sadiq against Abu Hanifa, the quiz's best; q3 gap "remembrance" in the ant's fear, "worship" live; q5 False "already faith in the technical sense" is a real swap of Tabatabai's note; q2 "the front kept back for the rear" is a phrase gloss, with "the rear sent ahead" its mirror as the only live trap; in order |
| 27:3 | fillGap, TF, MC, whoSaid, MC | 1 PASS | fill-the-gap opener; q1 gap "ruling" is the council's irony (strong men who leave the decision to her), "fighting" the live trap, the quiz's best; q2 True on the gift as a test (a king accepts, a prophet refuses), a real understanding point; q4 the seventy-three letters has a strong voice; q3 Asaf as proof and successor, framed as the Shia commentators, distractors from the same verse (the afreet), fair; q5 the glass floor, right option the longest; q3 and q4 both on v40; in order |
| 27:4 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q2 the three things no prophet escapes has a strong voice, the quiz's best; q3 gap "angels" is the essay's detail beyond the verse, "the earthquake" the live trap; q4 "remained behind" as left in the punishment, "followed a little later to safety" live; q1 bring a sign if truthful is verse wording carried in a narration, recall; q5 False "a different lesson" is a bare negation of "a single lesson", thin; in order |
| 27:6 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q2 a nearer worldly punishment, perhaps Badr, "only the final resurrection" the live trap, the quiz's best; q1 gap "far-fetched" is guessable and the prompt opens on "this" with no referent; q3 "We are those He chose" has a voice; q4 the word falling as the threat becoming due, "lifespans had run out" live; q5 False swaps "approaching" for "still far off" in the Sunni reading, a real swap in a perspectives statement; q4 and q5 both on v82; in order |
| 27:5 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener; q5 rising degrees of being cut off from the Hereafter, "stages leading back to belief" the live trap, the quiz's best; q2 an imam of guidance beside an imam of misguidance has a strong voice; q3 the distressed one as the Qa'im, "any believer in distress" the natural reading and the live trap; q4 gap "the Hour" in Imam Ali's gloss, "the Throne" live; q1 True restates the essay's turn to worship, thin; in order |
| 27:7 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q2 worship out of love, the worship of the noble, has a strong voice, the quiz's best; q1 the raj'a reading is circular: the prompt says "only a group" and the answer repeats it, with distractors nobody would pick (the reviewer noted the circularity and let it through); q3 gap "increase me" sits in a 37-word prompt, the longest of the run, forced by the passage's long undisputed narrations; q5 the signs as the Imams on their return, distractors from the same passage; q4 True restates the essay's ring close, thin; q2 and q3 both on v89; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 7 | 61K | 50K to 78K | 8 min 5 s | 424K tokens, 57 min |
| reviewer | 7 | 25K | 23K to 26K | 1 min 15 s | 173K tokens, 9 min |

About 0.60M agent tokens for the surah, roughly 33 minutes wall clock with three slots. Writers keep climbing (53K in surah 25, 55K in 26, 61K here); 27:7 took 78K tokens and 12 min 16 s, having looked for a gap sentence clear of both disputed glosses.

### Review outcomes

7 of 7 PASS first time, no rewrites, no validator rejections.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| fillGap | 3 | | MC | 4 |
| MC | 2 | | TF | 3 |
| whoSaid | 1 | | fillGap | 0 |
| TF | 1 | | whoSaid | 0 |

True or false: 4 of 7 True; both parity rules held for 7 of 7. Translation anchors: 0. Perspectives anchors: 4 of 7. Anchor spread: essay 14, narration 14, perspectives 4, note 3. All seven in verse order.

### Reader notes (taste, not rule)

- Best questions: 27:1 beyond a body confined by place, 27:2 the decree dims the sight, 27:3 "ruling", 27:4 the three things no prophet escapes, 27:5 rising degrees of being cut off, 27:6 perhaps Badr, 27:7 worship out of love.
- 27:7 q1 is circular: the prompt says "only a group" and the right option repeats it. The reviewer noted it and passed it. This is the "prompt must not paraphrase the answer" note from surahs 21 to 24, now with a shipped case in a multiple choice.
- 27:1 q1 gaps "Seeker" in Ta Seen, the same gloss 26:1 q1 asked as who-said-it; a reader going surah by surah meets it twice.
- Real gaps: 27:3 "ruling", 27:4 "angels", 27:5 "the Hour", 27:2 "remembrance". Guessable: 27:6 "far-fetched" (whose prompt also opens on "this" with no referent). 27:7 q3's prompt is 37 words, under the validator's 40 but well above the writer's 20-word guide.
- Thin True statements: 27:5 q1, 27:7 q4. Bare negation: 27:4 q5 ("a different lesson"). Real swaps: 27:2, 27:6.
- Longest-option tells: 27:1 q5, 27:3 q5.

### Deviations from the procedure

- Three slots; free slots started surah 28 while surah 27 finished.
- Commits deferred to the end of the loop.

## Results - Al-Qasas 28:1 to 28:8 (2026-09-30)

Same `/loop` run, three slots. No prompt change. 7 of 8 passed first review; 28:8 failed once and passed on one rewrite. `quiz_28.json` assembled with 8 quizzes: 16 multiple choice, 8 true or false, 8 fill the gap, 8 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 28:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q4 al-Tusi's companions holding the killing was not evil (commanded, only its delay better), "self-defense" the live trap, the quiz's best; q3 "May this name bring you joy - the Shia" has a strong voice; q1 gap "grew a beard" for full maturity is a surprising gloss but a thing to remember; q2 the Israelite and the Copt, "two Israelites" live; q5 False "reassured and safe" is a positive claim nobody who read the flight would take; three questions on v15; in order |
| 28:1 | whoSaid, MC, TF, fillGap, MC | 1 PASS | who-said-it opener, "they slaughter our sons and spare our women" has a strong voice; q2 the plural "from them" as al-Qummi's reason the verses are not about Moses, the quiz's best, distractors wrong reasons rather than the other tradition; q4 gap "inspiration" not prophecy, "guidance" live, but the prompt opens on "this revelation" with no referent; q5 God turning the child away, where the right option carries "not a ban" and the first option is that ban, a pairing that points at the answer; q3 True on all who saw Moses loving him, narration content; in order; the writer took 92K tokens and 16 tool calls, the heaviest of the run |
| 28:3 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener; q5 the Quran does not name the host, "names him directly as Shu'ayb" the popular belief and the live trap, the quiz's best; q3 "walk behind me" as the proof of trust, "refused wages" live; q2 nothing but bread has a strong voice; q4 gap "open" on either term, "fixed" live; q1 True restates al-Mizan's aside, thin; q4 and q5 both on v28; in order |
| 28:4 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q2 the Euphrates, Karbala and the tree as Muhammad has the strongest voice, the quiz's best; q1 night, cold and lost from al-Mizan, the other options nobody would pick; q3 gap "leprosy" for the white hand is the same gloss 27:1 q4 asked, a repeat across adjacent surahs; q4 Moses' arm by Aaron is given away by verse 35 itself; q5 False "one and the same class" of leader is a statement nobody would believe, thin; in order |
| 28:5 | whoSaid, MC, TF, fillGap, MC | 1 PASS | q2 the story told as a mercy to warn an unwarned people, "the Meccans demanded a Book like Moses'" the live trap, the quiz's best; q1 no nation destroyed from heaven since the Torah save the apes has a voice, with Ibn Abbas a distractor; q5 fact-of-agreement shape (unguided opinion as the root), fair, and the answer is the shortest option; q4 gap "grace" is al-Tusi's technical term with "mercy" a near synonym, a test of vocabulary, and the prompt opens on "this" with no referent; q3 True restates the leaf narration, narration content; in order |
| 28:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q3 gap "taqiyya" as the good that repels evil is the narration's surprise, "patience" the assumed trap, the quiz's best; q4 verse 56 settles nothing about Abu Talib's fate, framed as the Shia commentators, "proves the Prophet guided him" live; q5 False "destroys a town as soon as it prospers" asserts a wrong positive, fair; q2 found described in their books, fair; q1 who-said-it is a paraphrase ("he said it means one Imam after another") rather than a quote, little voice, and writes "The Prophet" against the house "the Prophet"; in order |
| 28:7 | TF, fillGap, MC, whoSaid, MC | 1 PASS | true-or-false opener; q3 the leaders strayed by choice not compulsion, "God had decreed and compelled them" the live trap, the quiz's best; q4 Munkar at the grave has a voice; q2 gap "avenge" against "defend", "protect" and "rescue" is near-synonym recall, and "him" (Ali) has no referent in the prompt; q5 the community cannot choose the Imam, distractors lifted from verses 67, 69 and 73 that answer nothing about "no choice", and the right option the longest; q1 True restates Tabrisi, thin; q1 and q2 both on v61; in order |
| 28:8 | fillGap, MC, whoSaid, MC, TF | 2 (FAIL, PASS) | fill-the-gap opener; first review failed q2 for naming "Tabatabai" in a passage that only ever says "al-Mizan"; the rewrite asks "How does the commentary read", and the other four were kept; q2 the delusion of crediting one's own skill, "honest gratitude for a God-given talent" the live trap, the quiz's best; q3 strutting in a garment as the companion of Korah has a strong voice; q4 the world as carrion, right option the longest; q5 False swaps the raj'a for the Prophet's death, a real swap; q1 gap "next" is guessable from "this world"; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 8 | 62K | 46K to 92K | 8 min 12 s | 493K tokens, 66 min |
| rewrite | 1 | 29K | - | 1 min 5 s | 29K tokens |
| reviewer | 9 | 25K | 23K to 29K | 1 min 10 s | 222K tokens, 10 min |

About 0.74M agent tokens for the surah, roughly 34 minutes wall clock with three slots. 28:1 (verses 1 to 13) was the heaviest writer of the whole run at 92K tokens and 16 tool calls, 12 min 56 s. A one-question rewrite is cheap: 29K tokens and a minute, against 62K and eight minutes for a fresh quiz.

### Review outcomes

7 of 8 PASS first time. 28:8 FAIL on q2: the prompt named "Tabatabai" where the passage only ever says "al-Mizan", so linking the two needs outside knowledge. The rewrite dropped the name ("How does the commentary read..."); second review PASS. No validator rejections.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| whoSaid | 3 | | MC | 4 |
| fillGap | 2 | | TF | 4 |
| TF | 2 | | fillGap | 0 |
| MC | 1 | | whoSaid | 0 |

True or false: 4 of 8 True; both parity rules held for 8 of 8. Translation anchors: 0. Perspectives anchors: 8 of 8, the first surah where every quiz draws on the perspectives. Anchor spread: narration 16, essay 15, perspectives 8, note 1. All eight in verse order. Multiple choice opened only once.

### Reader notes (taste, not rule)

- Best questions: 28:1 the plural "from them", 28:2 the killing commanded and only its delay better, 28:3 the Quran does not name the host, 28:4 the Euphrates and Karbala, 28:5 the story told as a mercy, 28:6 "taqiyya", 28:7 by choice not compulsion, 28:8 crediting one's own skill.
- The 28:8 failure is a naming rule the writer prompt does not state: name a source the way the passage names it. Most passages say "Tabatabai" and some say "al-Mizan", and the writer used the more common name.
- Cross-surah repeats: 28:4 q3 gaps "leprosy" for the white hand, which 27:1 q4 already asked.
- Near-synonym gaps: 28:5 "grace" against "mercy", 28:7 "avenge" against "defend", "protect" and "rescue". Both test a word rather than an idea.
- Prompts with no referent: 28:1 q4 ("this revelation"), 28:5 q4 ("in this"), 28:7 q2 ("him" for Ali).
- Obvious False statements: 28:2 q5 ("reassured and safe"), 28:4 q5 ("one and the same class"). Real swaps: 28:6, 28:8.
- 28:6 q1 who-said-it is a paraphrase, not a quote; 28:6 q1 and 26:10 q2 write "The Prophet" capitalised.
- 28:1 q5 pairs "a legal ban" with a right option ending "not a ban", which points at the answer. 28:4 q4 is given away by the verse itself (Moses' arm by Aaron).
- Longest-option tells: 28:7 q5, 28:8 q4.

### Deviations from the procedure

- Three slots; free slots started surah 29 while surah 28 finished.
- Commits deferred to the end of the loop.

## Results - Al-Ankaboot 29:1 to 29:7 (2026-09-30)

Same `/loop` run, three slots. No prompt change. All 7 passed first review. `quiz_29.json` assembled with 7 quizzes: 14 multiple choice, 7 true or false, 7 fill the gap, 7 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 29:2 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q3 the return, not the hope of provision, as the real motive for worship is the essay's sharpest point, the quiz's best, with the right option the shortest; q1 trial as a divine norm, "the tested are always spared" live; q2 Noah's two thousand three hundred years is a number to remember, little voice; q4 gap "guardian" beside Ali is guessable in this app (as 25:3 q4); q5 False "nothing to do with the resurrection" is a bare negation, thin; no perspectives in this passage; q1 and q2 both on v14; in order |
| 29:1 | fillGap, whoSaid, MC, TF, MC | 1 PASS | fill-the-gap opener; q2 the meeting is the resurrection, not seeing Him with the eye, has a voice and a theological point, the quiz's best; q1 gap "proven" under trial is guessable from "bare profession is not the point"; q3 the three enemies of the striving, a list to recall; q4 True on Sad ibn Abi Waqqas's mother is occasion-of-revelation fact, and a long compound prompt; q5 the Sunni sifting by strength of faith, framed as one tradition, distractors nobody would pick and the right option the longest; in order |
| 29:3 | TF, fillGap, MC, whoSaid, MC | 1 PASS | true-or-false opener; q3 the covenant does not reach the wrongdoers as the Shia reason for the purified line, distractors drawn from the same passage, the quiz's best; q4 breaking wind in their gatherings has a voice; q2 gap "reward" in this world and the next, "provision" live; q5 "spread corruption in the earth" for the corruptive lot, distractors the passage's other groups, fair; q1 True is a statement about what one verse does relative to another, hard to hold on one reading and thin; q2 and q3 both on v27; in order |
| 29:5 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q2 "the remembrance of Allah is greater" as God's remembrance of His servants, "a worshipper's remembrance outweighs the prayer" the common reading and the live trap, the quiz's best; q1 the test of accepted prayer has a voice; q4 True on the unlettered Prophet leaving no ground for "copied" is a real argument, not a restatement; q5 the recited Book as the sufficient sign, "a fresh miracle" live; q3 gap "fighting" is the expected abrogation word and the prompt opens on "this"; options in q2 and q5 end in full stops, against the house style; no perspectives question (the only disputed gloss avoided); q1 and q2 both on v45; in order |
| 29:4 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q2 gap "determinists" is the free-will argument (had the wrong been God's doing they would not be wrongdoers), the quiz's best, though the prompt opens on "this"; q1 "Lot is in it" as an honor to Lot, "to warn Lot to flee" live; q4 the knower as one who acts on what he understood has a voice, the option written "the Prophet Muhammad" against the house "the Prophet"; q3 the spider's house, distractors nobody would pick; q5 False "Shia and Sunni agree" tests whether the traditions agree rather than what either holds, the bare-disagreement shape; q4 and q5 both on v43; in order |
| 29:6 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q3 do not obey corrupt kings, the earth is vast, has a strong voice, the quiz's best; q5 False "left free to go on worshipping other gods" asserts a wrong positive against the completed proof, fair; q4 the Arabs killing children fearing hunger is occasion fact, with invented distractors (hoarding, overcharging) nobody would pick; q2 the Quraysh, a name to recall; q1 gap "Book" is guessable after "inimitable", and the prompt opens on "this witness"; no perspectives in this passage; in order |
| 29:7 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener; q2 "Let them enjoy" as a threat not a permission, "a genuine permission" the plain reading and the live trap, the quiz's best; q4 "I am that virtuous one" has a strong voice, written "The Prophet" against the house "the Prophet"; q3 gap "seized" against "safe", "guided" and "blessed", which the contrast with "a safe sanctuary" gives away; q5 the Family of Muhammad and their followers, framed as the Shia narrations, distractors nobody would pick; q1 True restates al-Tabrisi, thin; q4 and q5 both on v69; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 7 | 63K | 47K to 79K | 8 min 45 s | 438K tokens, 61 min |
| reviewer | 7 | 24K | 23K to 25K | 1 min 2 s | 167K tokens, 7 min |

About 0.61M agent tokens for the surah, roughly 39 minutes wall clock with three slots. 29:4 (verses 31 to 44) was the heaviest writer at 79K tokens and 12 min 30 s; its report says it passed over a polemical narration and a third-person retelling before choosing the who-said-it.

### Review outcomes

7 of 7 PASS first time, no rewrites, no validator rejections.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| fillGap | 2 | | MC | 4 |
| MC | 2 | | TF | 3 |
| TF | 2 | | fillGap | 0 |
| whoSaid | 1 | | whoSaid | 0 |

True or false: 4 of 7 True; both parity rules held for 7 of 7. Translation anchors: 0. Perspectives anchors: 4 of 7 (29:2 and 29:6 have no perspectives). Anchor spread: essay 18, narration 10, perspectives 4, note 3; the essay carries this surah. All seven in verse order.

### Reader notes (taste, not rule)

- Best questions: 29:1 the meeting is the resurrection, 29:2 the return not the hope of provision, 29:3 the covenant does not reach the wrongdoers, 29:4 "determinists", 29:5 God's remembrance of His servants, 29:6 the earth is vast, 29:7 a threat not a permission.
- 29:4 q5 asks whether the traditions agree ("Shia and Sunni agree... the Family of Muhammad", False). It tests the fact of disagreement rather than what either tradition holds, the shape the writer prompt steers away from.
- Guessable gaps: 29:1 "proven", 29:2 "guardian" beside Ali (as 25:3), 29:5 "fighting", 29:6 "Book" after "inimitable", 29:7 "seized" against "a safe sanctuary". Real gaps: 29:3 "reward", 29:4 "determinists".
- Prompts that open on "this" with no referent: 29:4 q2, 29:5 q3, 29:6 q1. Fourth surah running where this shows up; note against the writer prompt.
- Thin True statements: 29:3 q1 (hard to parse), 29:7 q1; 29:5 q4 is a True that carries an argument. Bare negation: 29:2 q5. Wrong positive (fair): 29:6 q5.
- Speaker naming drifts: "The Prophet" (29:7 q4) and "the Prophet Muhammad" (29:4 q4) against the house "the Prophet". Options ending in full stops in 29:5.
- Longest-option tell: 29:1 q5.

### Deviations from the procedure

- Three slots; free slots started surah 30 while surah 29 finished.
- Commits deferred to the end of the loop.

## Results - Ar-Room 30:1 to 30:6 (2026-09-30)

Same `/loop` run, three slots. No prompt change. All 6 passed first review. `quiz_30.json` assembled with 6 quizzes: 12 multiple choice, 6 true or false, 6 fill the gap, 6 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 30:3 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener, and a True that carries the surah's argument (creation and management are one work), not a restatement; q5 signs vindicate reasoned reflection, "automatic, effortless knowledge" the live trap, the quiz's best; q2 the Imam knowing a man by colour and voice has a voice; q3 a refutation of the heretics, distractors the other signs of the list; q4 gap "lighter" is given by the verse's "more simple for Him", and shipped without a full stop after one validator rejection (the twelfth stop-less gap); q4 and q5 both on v27; in order |
| 30:1 | TF, fillGap, MC, whoSaid, MC | 1 PASS | true-or-false opener; q5 Rome's near victory set first so the small promise kept argues for the great one is Tabatabai's reading of the whole surah, the quiz's best, but the right option is the longest; q4 "in their graves, at the rising of the Qaim" has a voice; q1 True is compound (Quraysh rejoiced, the Muslims grieved) but both halves are the story's hinge; q2 gap "prophecy" on what both traditions share, guessable beside "foretold", with "astrology" a distractor; q3 the outcome in both states rests with God, distractors nobody would pick; in order; the writer ran 20 min 34 s, the longest of the run |
| 30:4 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q4 usury of two kinds, one lawful, has a voice and a ruling a reader would not expect, the quiz's best; q1 the parable from yourselves, "slaves deserve an equal share" the literal misreading and the live trap; q3 relief brings back partners, "they give thanks" the hopeful trap; q2 gap "oneness" in the fitrah, guessable in a passage about partners; q5 False "partners share in creating" is a statement nobody who read the passage would take, thin; in order |
| 30:2 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q4 "He does not revive it with rain; rather God raises up men who revive justice" has the strongest voice and the surprise, the quiz's best; q1 the originator can raise the dead, distractors nobody would pick; q2 gap "hope" is guessable after "despair"; q3 the evening glorification, a devotional reward to remember, with the right option the longest; q5 False "proof the world has no Maker" is a statement nobody would take; q4 and q5 both on v19; in order; the writer ran 23 min, the longest of the run |
| 30:5 | MC, fillGap, whoSaid, TF, MC | 1 PASS | q2 gap "rain" for the life of the sea creatures is the narration's surprise, "tide" the assumed trap, the quiz's best; q1 tasting only part because God pardons much, "the rest is stored up for the Day" live; q3 the righteous deed sent ahead like a servant boy has a voice; q4 True on reviving dead earth as al-Qummi's answer to the deniers repeats 30:2 q5 in the same surah; q5 dead and deaf, right option the longest; q1 and q2 both on v41; in order |
| 30:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, "How could He be hidden from you, when He has shown you His power in your own self?" has the strongest voice, the quiz's best; q2 the hour's misjudgement mirrors turning truth into falsehood, distractors (prayers, hoarding, mockery) nobody would pick; q3 gap "correct", fair; q4 Ali fell silent at Ibn al-Kawwa's recitation is a story detail, and the right option the shortest; q5 False "the Sunni reading limits it to the prophets" is a real swap of a broad reading; q5 returns to v56 after v60 (perspectives close) |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 6 | 61K | 54K to 66K | 12 min 41 s | 364K tokens, 76 min |
| reviewer | 6 | 23K | 23K to 24K | 57 s | 139K tokens, 6 min |

About 0.50M agent tokens for the surah, roughly 44 minutes wall clock with three slots. Tokens held steady but two writers ran far longer than their size: 30:1 took 20 min 34 s and 30:2 took 23 min 5 s for 58K and 66K tokens, against about 8 minutes for the same tokens elsewhere. Their four tool calls match every other writer, so the time went to slow model turns, not to rework.

### Review outcomes

6 of 6 PASS first time, no rewrites. One validator rejection (30:3 q4): a trailing full stop on a gap prompt whose essay sentence ends in a semicolon, the same exact-span mechanism as surahs 21 to 24. Twelfth stop-less gap shipped.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 3 | | MC | 3 |
| TF | 2 | | TF | 3 |
| whoSaid | 1 | | fillGap | 0 |
| fillGap | 0 | | whoSaid | 0 |

True or false: 3 of 6 True; both parity rules held for 6 of 6. Translation anchors: 0. Perspectives anchors: 3 of 6. Anchor spread: essay 17, narration 10, perspectives 3. Five of six in verse order; 30:6 closes on a perspectives question about verse 56. Fill the gap sat in slot 2 or 3 in every quiz.

### Reader notes (taste, not rule)

- Best questions: 30:1 the small promise kept argues for the great one, 30:2 men who revive justice, 30:3 reasoned reflection, 30:4 usury of two kinds, 30:5 "rain" for the sea creatures, 30:6 His power in your own self.
- 30:3 q1 is a True statement that carries the surah's argument (creation and management are one work), the kind the thin restatements elsewhere should become.
- Same-surah repeat: 30:5 q4 asks al-Qummi's reading of the revived earth as an answer to the deniers, which 30:2 q5 already asked.
- Guessable gaps: 30:1 "prophecy" beside "foretold", 30:2 "hope" after "despair", 30:3 "lighter" (given by the verse's "more simple for Him"), 30:4 "oneness" in a passage about partners. Real gap: 30:5 "rain".
- Obvious False statements: 30:2 q5 ("proof the world has no Maker"), 30:4 q5 ("partners share in creating"). Real swap: 30:6 q5.
- Longest-option tells: 30:1 q5, 30:2 q3, 30:5 q5. Shortest-option tell: 30:6 q4.

### Deviations from the procedure

- Three slots; free slots started surah 31 while surah 30 finished.
- Commits deferred to the end of the loop.

## Results - Luqman 31:1 to 31:3 (2026-09-30)

Same `/loop` run, three slots. No prompt change. All 3 passed first review; 31:3 was then sent back by the orchestrator's reader pass for one question and passed a second review. `quiz_31.json` assembled with 3 quizzes: 6 multiple choice, 3 true or false, 3 fill the gap, 3 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 31:1 | MC, fillGap, TF, whoSaid, MC | 1 PASS | q1 the Book called wise because it makes truth and falsehood plain of itself, "only the wise can grasp it" the live trap, the quiz's best; q3 True on the singing-girl invited to weddings is a ruling a reader would not guess, narration content; q4 singing among the things promised the Fire has a voice; q2 gap "divine oneness" is the first of a three-part list and guessable; q5 the idols create nothing, "the idols share in creating" nobody would pick; no perspectives in this passage; q3 and q4 both on v6; in order |
| 31:2 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q3 the two verses on parents are God's own words set inside Luqman's counsel, "Luqman's words to his son" the natural reading and the live trap, the quiz's best; q1 wisdom as the mean between ignorance and misused cleverness, "the gift of prophethood" live; q2 injustice of three kinds has a voice; q4 gap "pursuer" for trivial sins is the narration's image, "record" and "witness" live; q5 False "Shia narrations reject the literal duty" is a real swap of "keep and add"; q5 returns to v14 after v16 (perspectives close) |
| 31:3 | fillGap, MC, TF, whoSaid, MC | 2 (PASS, PASS after an orchestrator rewrite) | fill-the-gap opener; the first review passed all five, but q5 (what both traditions affirm) took its three wrong options from the traditions' own readings of verses 20 and 22, the Ahl al-Bayt guardianship among them, so the quiz marked those readings wrong, against the writer prompt's distractor rule; sent back for q5 only, the rewrite uses wrong options the passage refutes (following forefathers, a clear scripture, God's words exhausted), which nobody would pick but take no side; q3 True on created in stages yet raised as a single soul is the narration's answer to an objection, the quiz's best; q4 learning from a knower is not knowledge of the unseen has a voice; q2 the Prophet consoled, "they will soon accept" live; q1 gap "oneness" guessable; q5 returns to v20 after v34 (perspectives close) |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 3 | 60K | 54K to 68K | 8 min 5 s | 181K tokens, 24 min |
| rewrite | 1 | 39K | - | 2 min 56 s | 39K tokens |
| reviewer | 4 | 24K | 23K to 25K | 56 s | 96K tokens, 4 min |

About 0.32M agent tokens for the surah, roughly 30 minutes wall clock.

### Review outcomes

3 of 3 PASS first time. No validator rejections.

One deviation: the reader pass sent 31:3 back after its PASS. Its q5 asked what the Household's reports and the Sunni exegetes both affirm, and its three wrong options were the traditions' own readings of verses 20 and 22: the inward blessing as the guardianship of the Ahl al-Bayt, al-Tabari's outward blessing as what the tongue professes, and Ibn Abbas's "there is no god but God" for the firmest handle. The quiz would have shown the Ahl al-Bayt reading as a wrong answer. The writer prompt already forbids this ("never the other tradition's reading of the same disputed point"; "never set ... another tradition up as the wrong option beside Ahl al-Bayt"), but the reviewer checked only that the question asked for common ground and passed it. The rewrite kept q1 to q4 and replaced q5's wrong options with statements the passage refutes; second review PASS. A scan of every multiple choice in surahs 25 to 31 found no other quiz with a tradition's reading of the same disputed point in a wrong slot.

Note against the reviewer prompt: in a perspectives question, a wrong option that is either tradition's reading of the point in question is a fail, even when the prompt asks for common ground.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 2 | | MC | 2 |
| fillGap | 1 | | TF | 1 |

True or false: 2 of 3 True; both parity rules held for 3 of 3. Translation anchors: 0. Perspectives anchors: 2 of 3 (31:1 has no perspectives). Anchor spread: essay 7, narration 6, perspectives 2. Only 31:1 is in verse order; 31:2 and 31:3 close on a perspectives question about an earlier verse.

### Reader notes (taste, not rule)

- Best questions: 31:1 wise because it makes truth plain of itself, 31:2 God's own words set inside Luqman's counsel, 31:3 as a single soul.
- 31:3 q5's rewritten wrong options (following forefathers, a clear scripture, God's words exhausted) take no side but nobody would pick them; the fact-of-agreement shape again leaves little to choose between.
- Guessable gaps: 31:1 "divine oneness", 31:3 "oneness". Real gap: 31:2 "pursuer".

### Deviations from the procedure

- The 31:3 send-back after a PASS, above.
- For a few seconds four agents ran against the user's cap of three: the 31:3 rewrite was launched while three writers ran, and the 32:1 review after it. The review was stopped before it wrote anything and relaunched when a slot freed.
- Commits deferred to the end of the loop.

## Results - As-Sajda 32:1 to 32:3 (2026-09-30)

Same `/loop` run, three slots. No prompt change. All 3 passed first review. `quiz_32.json` assembled with 3 quizzes: 6 multiple choice, 3 true or false, 3 fill the gap, 3 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 32:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q2 "the guilty" as specifically the deniers of the resurrection, "everyone who has committed any sin" the natural reading and the live trap, the quiz's best; q3 the night prayer's reward left unstated has a voice; q5 False swaps the Sunni nearer and greater punishments, a real swap; q4 iron maces at the top of hell is a story detail with the narration's other stages as traps, recall; q1 gap "destinies" is a structural word, fair; q1 and q2 both on v12; in order |
| 32:3 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q2 "The imams in the Book of God are two: an imam of justice and an imam of tyranny" has the strongest voice, the quiz's best; q1 the Torah rejected too as the Prophet's consolation, "Moses never faced rejection" live; q4 True on faith availing only the one who believed before is the narration's teaching, stated plainly; q3 gap "head" in patience is to faith as the head to the body, against "root", "pillar" and "foundation", recall of an image; q5 waiting meets waiting, right option the longest; q2 and q3 both on v24; no perspectives question (the only disputed point, the imams of v24, avoided); in order |
| 32:1 | MC, whoSaid, fillGap, TF, MC | 1 PASS | q3 gap "not yet come to be" defines the Unseen by time rather than by sight, "been hidden from sight" the assumed trap, the quiz's best; q1 the truth from your Lord to an unwarned people, fair; q5 disbelief in meeting their Lord as the real fault, distractors from other verses; q2 the days of creation is a weekday list to recall, with "the Prophet Muhammad" against the house "the Prophet"; q4 True that "the passage holds" creation firm either way rests on al-Tabari's reconciliation in the perspectives, which the reviewer weighed as borderline and passed; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 3 | 57K | 46K to 72K | 7 min 22 s | 170K tokens, 22 min |
| reviewer | 3 | 26K | 23K to 32K | 1 min 31 s | 78K tokens, 4 min 30 s |

About 0.25M agent tokens for the surah, roughly 20 minutes wall clock, overlapping surah 31. 32:1's reviewer was the slowest of the run at 2 min 46 s and 32K tokens, weighing whether q4 took a side.

### Review outcomes

3 of 3 PASS first time. No validator rejections.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 2 | | MC | 2 |
| fillGap | 1 | | TF | 1 |

True or false: 2 of 3 True; both parity rules held for 3 of 3. Translation anchors: 0. Perspectives anchors: 2 of 3. Anchor spread: narration 7, essay 6, perspectives 2. All three in verse order.

### Reader notes (taste, not rule)

- Best questions: 32:1 the Unseen as what has not yet come to be, 32:2 the guilty as the deniers of the resurrection, 32:3 the two imams of justice and tyranny.
- 32:1 q4 is a True statement that credits "the passage" with al-Tabari's reconciliation of the two recitations; the reviewer weighed it as borderline. It holds, but a reader may take a Sunni exegete's conclusion as the passage's own.
- 32:3 q3 gaps "head" in patience is to faith as the head to the body, against "root", "pillar" and "foundation": any of the four makes the image work, so it tests memory of the image.
- 32:1 q2 is a weekday list; the option "the Prophet Muhammad" again drifts from the house "the Prophet".

### Deviations from the procedure

- Three slots; free slots started surah 33 while surah 32 finished.
- Commits deferred to the end of the loop.

## Results - Al-Ahzaab 33:1 to 33:9 (2026-09-30)

Same `/loop` run, three slots. One prompt change during the surah (below). All 9 passed first review; 33:2's q4 was sent back by the orchestrator before its review. `quiz_33.json` assembled with 9 quizzes: 18 multiple choice, 9 true or false, 9 fill the gap, 9 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 33:1 | whoSaid, MC, TF, fillGap, MC | 1 PASS | who-said-it opener, "I mean you, but let the neighbor hear" has a strong voice and is the quiz's best; q2 the command to trust signals resistance was hard by ordinary means, "the enemies were too few" live; q4 gap "obedience" in al-Mizan's unrestricted closeness, "kinship" and "inheritance" live, though the prompt opens on "this closeness"; q5 authority in the line of Husayn, framed as the Shia reading, with wrong options that are not al-Tabari's inheritance reading; q3 True on zihar is a legal definition, thin; q4 and q5 both on v6; in order |
| 33:2 | whoSaid, MC, TF, MC, fillGap | 1 PASS (q4 sent back by the orchestrator before review) | who-said-it opener, Muhammad raised above Hud by eight thousand angels, a wind of mercy against Ad's wind of wrath, has a strong voice and is the quiz's best; q2 the promised victory and the empires dismissed as delusion, "the safety of their homes" live; q3 False "poorly built" against al-Sadiq's high-built homes, a real swap; q4 as written put both traditions' readings of the hinderers of v18 in wrong slots and went back to the writer before review; the rewrite's wrong options are refuted by the passage and take no side; q5 gap "firm" against "calm", "tall" and "proud" is guessable; fill-the-gap closer, the first of the run; in order |
| 33:3 | fillGap, whoSaid, MC, TF, MC | 1 PASS | fill-the-gap opener; q1 gap "duty" in al-Mizan's reading of the past tense (imitating the Prophet as a fixed, standing duty), "choice" the live trap, the quiz's best; q2 the Prophet foretelling the confederates has a voice; q3 the pledge of v23 as fidelity to the Imams' wilayah, framed as the Shia narrations, but two wrong options are the Shia-leaning readings of v25 (Ali killing Amr, Ibn Masud's "through Ali"), wrong only as answers about v23; the reviewer passed it and it falls outside the tightened same-point rule, a taste note; q4 True on Banu Qurayza and Sad ibn Muadh's judgment is a long compound fact of the story; q5 Khaybar for the untrodden land, with Mecca, Tabuk and Ta'if as places a reader knows from outside, recall; in order |
| 33:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, remembrance the one thing without a limit has a strong voice; q2 God's own blessing as forgiveness and mercy, set against the angels' prayer as the live trap, the quiz's best; q4 the self-offering as the Prophet's privilege alone, fair; q3 gap "generous" to his wives against "patient" and "gentle", recall of a word; q5 False "mothers, daughters and sisters among the women he was free to marry" is a statement no reader would take, thin; in order |
| 33:4 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q3 "for our good-doer a double reward, for our wrongdoer a double punishment", said in anger at the claim the Household are forgiven, has the strongest voice, the quiz's best; q1 gap "divorce" in al-Hasan's reading (a choice between the worlds, not a divorce), fair, though the prompt opens on "this"; q5 False "the cloak report appears only in Shia readings" tests a shared transmission rather than the divided point, fair; q2 Zaynab's words, narration recall; q4 keep to their homes, distractors nobody would pick; options in q2 and q4 end in full stops; q4 and q5 both on v33; in order |
| 33:5 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q5 al-Tusi on "not the father of any man among you" denying fatherhood only of grown men, not of Hasan and Husayn, the quiz's best; q1 faith settles in the heart, Islam governs marriage and inheritance, has a voice; q3 gap "ex-wives" of adopted sons, "widows" live; q2 turning from God's choice to their own, but the prompt's "those people" has no referent; q4 True that the phrase was revealed about Zayd is an occasion fact; q4 and q5 both on v40; in order |
| 33:7 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener; q3 gap "purification" in the three blessings (mercy from God, purification from the angels, supplication from people) is the narration's distinction, the quiz's best; q4 "whoever harms a hair of you harms me" has a strong voice, with the right option written "Prophet Muhammad"; q5 Ali and Fatima named before the ruling extends to all, framed as the Shia reading, distractors from the passage's other content; q2 like their mothers in prohibition, the sisters, daughters and aunts nobody would pick; q1 True is a long occasion fact; q1 and q2 both on v53; in order |
| 33:8 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q4 Tabatabai's guardian (the whole matter) against helper (only part), with the mirror as the live trap, the quiz's best; q1 the occasion of the cloak command is recall of a report; q2 gap "stop" in "the wording implies they did in fact ____" is a nine-word fragment whose "they" and "the wording" have no referent, so any of the four fits; q3 who-said-it on "Accursed" is mostly verse text with little of the speaker's voice; q5 False "make no plea" is a bare negation, thin; in order; one validator rejection (a stray closing quote in an anchor) |
| 33:9 | fillGap, whoSaid, MC, TF, MC | 1 PASS | fill-the-gap opener; q2 "Woe to you, Abbad! Has it deceived you that your belly and private parts are chaste?" has the strongest voice, the quiz's best; q3 obedience specified as the wilaya of Ali and the Imams, from the narration on v71 (not the flagged point), distractors from other verses; q1 gap "men" in the Israelites' slander of Moses, recall; q4 True restates the essay on the Trust dividing its bearers, thin; q5 fact-of-agreement shape (man took up what the heavens declined), wrong options that contradict the verse and take no side; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 9 | 61K | 48K to 80K | 8 min 15 s | 552K tokens, 74 min |
| rewrite | 1 | 30K | - | 1 min 37 s | 30K tokens |
| reviewer | 9 | 25K | 24K to 28K | 1 min 21 s | 227K tokens, 12 min |

About 0.81M agent tokens for the surah, roughly 33 minutes wall clock with three slots. 33:4 (verses 28 to 34, the verse of purification) was the heaviest writer at 80K tokens and 12 min 21 s.

### Review outcomes

9 of 9 PASS on their reviews. 33:2 as first written repeated 31:3's fault: q4 asked what both traditions share about verses 9 to 20 and set both traditions' readings of the hinderers of verse 18 (Muqatil's Abdullah ibn Ubayy, al-Qummi's man of the Emigrants at Amr's crossing) as wrong options. The orchestrator sent q4 back before review; the rewrite replaced them with options the passage refutes, and the first review passed it. One validator rejection (33:8: a stray closing quote in an anchor span).

Prompt change, after the second case: one sentence in each prompt. The writer's Distractors rule now says the ban on the other tradition's reading of a disputed point holds in a "what both traditions share" question too, naming 31:3 and 33:2. The reviewer's criterion 5 now fails a wrong option that is either tradition's reading of the very point the question asks about. First wording reached any point the Perspectives divide over; narrowed to the point the question asks about after 33:3's reviewer passed q3, whose wrong options include the Shia readings of verse 25 in a question about verse 23. That is the same class as 25:5 q5 and 26:11 q5, which were let through earlier, and it stays a taste note. Quizzes written after the change (33:4 to 33:9) have no case of either kind.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| whoSaid | 4 | | MC | 5 |
| fillGap | 3 | | TF | 3 |
| TF | 1 | | fillGap | 1 |
| MC | 1 | | whoSaid | 0 |

True or false: 5 of 9 True; both parity rules held for 9 of 9. Translation anchors: 0. Perspectives anchors: 8 of 9. Anchor spread: narration 17, essay 17, perspectives 8, note 3. All nine in verse order. 33:2 is the first quiz of the run to close on fill the gap. Multiple choice opened only once; who-said-it opened four times.

### Reader notes (taste, not rule)

- Best questions: 33:1 "I mean you, but let the neighbor hear", 33:2 raised above Hud by eight thousand angels, 33:3 imitation as a fixed, standing duty, 33:4 double reward and double punishment, 33:5 fatherhood denied only of grown men, 33:6 God's blessing as forgiveness and mercy, 33:7 "purification", 33:8 guardian and helper, 33:9 "Woe to you, Abbad".
- Who-said-it carries this surah: seven of the nine best are a narration's voice or gloss.
- Weak gaps: 33:8 q2 "stop" (a nine-word fragment whose "they" has no referent), 33:2 q5 "firm", 33:6 q3 "generous", 33:9 q1 "men".
- Obvious or bare False statements: 33:6 q5 (mothers, daughters and sisters free to marry), 33:8 q5 ("no plea"). Real swaps: 33:2 q3, 33:4 q5.
- Prompts with no referent: 33:1 q4 ("this closeness"), 33:4 q1 ("this"), 33:5 q2 ("those people"), 33:8 q2.
- Speaker naming: "Prophet Muhammad" (33:7 q4) against the house "the Prophet". Options ending in full stops in 33:4.

### Deviations from the procedure

- 33:2's q4 went back to the writer on the orchestrator's check before any review, as in 31:3.
- The prompt change above, made mid-surah.
- Commits deferred to the end of the loop.

## Results - Saba 34:1 to 34:6 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 6 passed first review. `quiz_34.json` assembled with 6 quizzes: 14 multiple choice, 6 true or false, 6 fill the gap, 4 who said it (34:1 and 34:4 have a single narration, so a third multiple choice stands in).

| passage | type order | reviews | reader note |
|---|---|---|---|
| 34:1 | MC, fillGap, MC, TF, MC | 1 PASS | no who-said-it available (one narration), three multiple choice; q3 the Pen created first and told to write, "the Throne" and "the first intellect" live, the quiz's best; q1 the three foundations of the surah, the wrong triads nobody would pick; q2 gap "deeds" that ascend, "prayers" and "supplications" live, but the prompt opens on "these"; q4 True restates the essay on the Hour's purpose, thin; q5 the grounds of the soundest Sunni reading ("the wording is general"), wrong options the other Sunni views of the same phrase as reasons, a Sunni-internal attribution question in a Shia app that leaves the Shia reading (Ali) unasked; in order |
| 34:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q2 iron softened so David would not eat from the public treasury is Imam Ali's surprise, "to arm his soldiers" the assumed trap, the quiz's best; q3 "not statues of men and women, but figures of trees" has a voice and a point; q4 the prominent towns as those who carry the household's teaching, an inner reading framed as the note's, fair; q1 gap "gratitude" names the passage's frame, fair; q5 False "Iblis held compelling authority" restates the verse's denial, thin; in order |
| 34:3 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener, and a True that carries the argument (lordship requires ownership, all ownership denied); q3 gap "angels'" as those from whose hearts the fear is lifted, "believers'" the assumed trap, the quiz's best; q4 al-Sadiq's rhetorical question (how did one who never left Medina reach east and west) has a voice; q2 fact-of-agreement shape (intercession only by God's leave), wrong options nobody would pick and none a tradition's reading of who may intercede; q5 one God with no partner, distractors nobody would pick; q2 and q3 both on v23; in order |
| 34:4 | MC, TF, MC, fillGap, MC | 1 PASS | one narration only, three multiple choice; q3 remorse hidden even in the punishment because they disliked their enemies' gloating is the narration's surprise, "hoped to still be forgiven" the assumed trap, the quiz's best; q2 False "a new reaction never shown in life" swaps the note's lifelong habit, a real swap; q4 gap "arrogance" (ease breeds arrogance against the truth), "doubt" and "envy" live, in a 25-word prompt; q1 the Meccan polytheists, recall; q5 provision by His wisdom, the right option the only one not phrased "As...", a form tell; in order |
| 34:5 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener; q4 gap "imitation" (with no scripture and no warner, rejection rests on stubborn imitation), "pride" the live trap, the quiz's best; q3 every lawful dirham spent lawfully replaced, "no return in this world" live; q2 the doubled reward opens "O Abu Muhammad", which fits two Imams, fair; q1 True restates the affluent's boast, thin; q5 earlier nations mightier than Quraysh, right option the longest; q1 and q2 both on v37; in order |
| 34:6 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q2 gap "predestinarians" (the verse ties straying to the self, not the decree) is al-Tusi's free-will point, the quiz's best, a sibling of 29:4's "determinists"; q4 guidance sought where it cannot be reached has a voice; q3 the Sufyani's army swallowed before al-Mahdi, carried by both channels per the note, with other destroyed hosts as traps and the right option the longest; q1 no flaw of madness, the right option the only one not phrased "Because", and the distractors nobody would pick; q5 False "belief accepted at last" asserts a wrong positive, fair; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 6 | 62K | 56K to 79K | 8 min 34 s | 375K tokens, 51 min |
| reviewer | 6 | 25K | 22K to 28K | 1 min 18 s | 149K tokens, 8 min |

About 0.52M agent tokens for the surah, roughly 30 minutes wall clock with three slots.

### Review outcomes

6 of 6 PASS first time, no rewrites, no validator rejections. No wrong option in the surah is a tradition's reading of the point its question asks about.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 3 | | MC | 4 |
| TF | 2 | | TF | 2 |
| fillGap | 1 | | fillGap | 0 |
| whoSaid | 0 | | whoSaid | 0 |

True or false: 3 of 6 True; the True/False parity held for 6 of 6 and the closer parity for 5 of 6 (34:4, an even passage with three multiple choice, must close on multiple choice). Translation anchors: 0. Perspectives anchors: 2 of 6. Anchor spread: essay 17, narration 8, note 3, perspectives 2; the essay carries this surah. All six in verse order.

### Reader notes (taste, not rule)

- Best questions: 34:1 the Pen, 34:2 iron softened so David would not eat from the treasury, 34:3 the fear lifted from the angels' hearts, 34:4 remorse hidden from the enemies' gloating, 34:5 "imitation", 34:6 "predestinarians".
- 34:1 q5 asks the grounds of the soundest Sunni reading of "those who have been given knowledge", with the other Sunni views as wrong reasons. It takes no side, but it leaves the Shia reading of the same phrase (Ali) unasked in a Shia app; a note for the writer prompt's framing preference.
- Form tells: 34:4 q5 and 34:6 q1 phrase the right option differently from the three wrong ones ("By His wisdom" against "As..."; no "Because").
- Thin statements: 34:1 q4, 34:2 q5, 34:5 q1. True that carries an argument: 34:3 q1.
- Free will against determinism recurs (29:4 "determinists", 34:6 "predestinarians"), each once in its surah; fine.

### Deviations from the procedure

- Three slots; free slots started surah 35 while surah 34 finished.
- Commits deferred to the end of the loop.

## Results - Faatir 35:1 to 35:5 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 5 passed first review. `quiz_35.json` assembled with 5 quizzes: 10 multiple choice, 5 true or false, 5 fill the gap, 5 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 35:2 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, self-admiration's degrees (an evil deed made to seem fair) has a voice and is the quiz's best; q2 resurrection begun by rain for forty mornings is the narration's surprise, "the trumpet" the assumed trap; q4 kinship ties the one thing that lengthens life, "charity" live; q3 gap "obeying God" in Qatada's reading, the other options nobody would pick, and the prompt opens on "its"; q5 False "the idols will defend their worshippers" is a statement nobody would take; in order |
| 35:1 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener; q4 Satan gains mastery only once the servant turns from God's remembrance has a voice and a point, the quiz's best; q2 the mercy read widely (temporary marriage, what flows on the Imam's tongue), framed as the Shia narrations, wrong options from verses 3 and 5 rather than the Sunni readings, fair, and the right option the longest; q3 gap "consoled" against "warned" and "rebuked", fair; q1 True restates the essay on the angels, thin; q5 two promised ends, right option the longest; in order |
| 35:4 | MC, whoSaid, fillGap, MC, TF | 1 PASS | q1 the variety of colors as divine ordering, not water alone, "water is the single cause" the live trap, the quiz's best; q2 the learned as one whose deed confirms his word has a voice, with Ibn Abbas (who also speaks on "the learned") as a fair distractor; q5 False swaps the Shia reports' foremost (the Imam) with the average (one who knows the Imam), a real swap inside one reading; q3 gap "fear and hardship" as the grief of this world, recall of a pair; q4 a life long enough to heed, right option the longest; in order |
| 35:3 | fillGap, whoSaid, MC, TF, MC | 1 PASS | fill-the-gap opener; q2 God does not seize the innocent for the guilty nor children for the fathers' sins has a voice and a principle, the quiz's best; q3 the contrasts (blind and seer, dark and light) as believer against disbeliever, "the rich Lord against needy creation" live; q1 gap "impossible" against "burdensome" in al-Tibyan's gloss, a fine distinction; q4 True limits the Prophet's charge to warning, a real point stated plainly; q5 every age its Imam, framed as the Shia sources, wrong options that are not Ibn Kathir's reading; in order |
| 35:5 | TF, MC, whoSaid, fillGap, MC | 1 PASS | true-or-false opener; q2 a lord must be a creator and the partners created nothing, the quiz's best; q3 "Allah is the carrier of the Throne" has a voice; q5 the respite as a worldly reprieve until death or the Resurrection, right option the longest; q1 True restates the essay, thin; q4 gap "triad" in "both traditions draw the same ____ from the Book" is a structural word that names no content, close to the barred "differ"/"phrase" gaps, a memory of one word; in order; the writer ran 21 min 17 s for 61K tokens |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 5 | 65K | 52K to 78K | 11 min 41 s | 325K tokens, 58 min |
| reviewer | 5 | 25K | 24K to 26K | 1 min 12 s | 124K tokens, 6 min |

About 0.45M agent tokens for the surah, roughly 37 minutes wall clock with three slots. 35:5's writer ran 21 min 17 s for 61K tokens and four tool calls, the second slow-turn case after 30:1 and 30:2.

### Review outcomes

5 of 5 PASS first time, no rewrites, no validator rejections. No wrong option in the surah is a tradition's reading of the point its question asks about.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 2 | | MC | 3 |
| whoSaid | 1 | | TF | 2 |
| fillGap | 1 | | fillGap | 0 |
| MC | 1 | | whoSaid | 0 |

True or false: 3 of 5 True; both parity rules held for 5 of 5. Translation anchors: 0. Perspectives anchors: 4 of 5. Anchor spread: essay 13, narration 8, perspectives 4. Four of five in verse order; 35:4 closes on a perspectives statement about verse 32.

### Reader notes (taste, not rule)

- Best questions: 35:1 Satan's mastery only after turning from remembrance, 35:2 self-admiration's degrees, 35:3 the innocent not seized for the guilty, 35:4 divine ordering, not water alone, 35:5 a lord must be a creator.
- 35:5 q4 gaps "triad" in "both traditions draw the same ____ from the Book": a structural word that names no content, a cousin of the barred "differ" and "phrase" gaps. Note against the writer prompt: a gap in a perspectives sentence must sit on what the traditions hold, not on a word that labels it.
- Obvious False statements: 35:2 q5 (the idols will defend their worshippers). Real swap: 35:4 q5.
- Thin True statements: 35:1 q1, 35:5 q1. True that carries a point: 35:3 q4.
- Longest-option tells: 35:1 q2 and q5, 35:4 q4, 35:5 q5.

### Deviations from the procedure

- Three slots; free slots started surah 36 while surah 35 finished.
- Commits deferred to the end of the loop.

## Results - Yaseen 36:1 to 36:5 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 5 passed first review. `quiz_36.json` assembled with 5 quizzes: 10 multiple choice, 5 true or false, 5 fill the gap, 5 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 36:1 | TF, MC, whoSaid, fillGap, MC | 1 PASS | true-or-false opener; q4 gap "likeness" (Tusi: the collars are not literal chains, as the Quran speaks elsewhere of deaf ears), "punishment" the assumed trap, the quiz's best; q3 the word due against those who do not affirm the wilaya has a voice; q2 Ya Seen as "O hearer of the revelation", a gloss to remember, with fair distractors; q5 fact-of-agreement shape (a preserved record), wrong options from other verses nobody would pick; q1 True restates Tabatabai's frame, thin; q1 and q2 both on v1; in order |
| 36:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q4 the man worshipped God because He is worthy of worship, "hoping for paradise" and "fear of the Fire" the live traps, the quiz's best; q5 False "the final Paradise of the resurrection" swaps the essay's barzakh reading, a real swap; q2 the omen drawn from the prophets, with its mirror as the trap; q1 gap "nearer creatures", fair; q3 "three things from which no prophet was left immune" is the same narration 27:4 q2 already asked as who-said-it, a repeat across surahs; q2 and q3 both on v18; in order |
| 36:3 | fillGap, whoSaid, MC, TF, MC | 1 PASS | fill-the-gap opener; q5 the single Cry as the first blast of the trumpet, opening the Return, the quiz's best, with the right option the longest; q3 the sun and moon as the authority of day and night, a surprising name to recall; q1 gap "lordship and godhood", fair, but the prompt opens on "them"; q2 the drop falling on plants and trees is a description with little of the speaker's voice; q4 True on before as sins and behind as punishment restates a gloss, recall; in order |
| 36:4 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, al-Rida reading "who raised us from our place of sleep" as the rising of the master of creation has a voice; q4 creation begging to be brought to account even to the Fire is al-Qummi's surprise, "to be sent back to repent" the assumed trap, the quiz's best; q2 the recompense as the deeds themselves, "every sin forgiven at the Trumpet" nobody would pick; q3 gap "canopies" against "curtains" and "veils", recall of a word; q5 False "how difficult it would be for Him" is a bare inversion, thin; in order; one validator rejection (a dropped comma in an anchor) |
| 36:5 | TF, fillGap, MC, whoSaid, MC | 1 PASS | true-or-false opener, and a True that carries al-Qummi's point (old age refutes those who say nature alone shapes a person); q3 the worshippers mustered for their idols, not the reverse, with the reverse as the live trap, the quiz's best; q4 "how astonishing is the one who denies death while he sees people dying" has a strong voice; q2 gap "herds" as al-Tabrisi's proof of the Provider, recall; q5 the One who produced them first, the verse's famous answer, with distractors nobody would pick; in order; the writer ran 19 min 7 s for 56K tokens |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 5 | 59K | 56K to 65K | 10 min 12 s | 297K tokens, 51 min |
| reviewer | 5 | 25K | 25K to 26K | 1 min 9 s | 125K tokens, 6 min |

About 0.42M agent tokens for the surah, roughly 39 minutes wall clock with three slots. 36:5's writer ran 19 min 7 s for 56K tokens, another slow-turn case.

### Review outcomes

5 of 5 PASS first time. One validator rejection (36:4: a dropped comma inside an anchor quote).

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 2 | | MC | 3 |
| fillGap | 2 | | TF | 2 |
| whoSaid | 1 | | fillGap | 0 |
| MC | 0 | | whoSaid | 0 |

True or false: 3 of 5 True; both parity rules held for 5 of 5. Translation anchors: 0. Perspectives anchors: 1 of 5; the writers kept off the surah's disputed points (the manifest Imam, the forerunners, "place of rest", beholding God, the bone-denier). Anchor spread: essay 12, narration 9, note 3, perspectives 1. All five in verse order. Multiple choice never opened.

### Reader notes (taste, not rule)

- Best questions: 36:1 "likeness" for the collars, 36:2 worshipping God because He is worthy of it, 36:3 the Cry as the first blast, 36:4 creation begging for its account, 36:5 the worshippers mustered for their idols.
- Cross-surah repeat: 36:2 q3's who-said-it ("three things from which no prophet was left immune") is the narration 27:4 q2 already asked.
- Recall-of-a-word gaps: 36:4 "canopies", 36:5 "herds". Real gap: 36:1 "likeness".
- True statements that carry a point: 36:5 q1. Thin: 36:1 q1, 36:3 q4. Bare inversion: 36:4 q5.
- 36:3 q2's who-said-it (the drop falling on plants and trees) is a description with little voice.

### Deviations from the procedure

- Three slots; free slots started surah 37 while surah 36 finished.
- Commits deferred to the end of the loop.

## Results - As-Saaffaat 37:1 to 37:5 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 5 passed first review. `quiz_37.json` assembled with 5 quizzes: 10 multiple choice, 5 true or false, 5 fill the gap, 5 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 37:1 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q3 True that Tabatabai holds the old cosmology behind the shooting stars shown false and the verses possibly similitudes for unseen realities is a real point stated plainly, the quiz's best; q1 al-Qummi's ranks reaching beyond the angels, "only the angels" the live trap; q2 the stars as cities tied to pillars of light has a voice; q4 gap "clings to the hand" for the viscous clay, recall of a gloss; q5 the Day of Judgement as the parting of truth from falsehood, distractors from the passage's other scenes; no perspectives in this passage; in order |
| 37:3 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener; q2 "his followers" read by Tabatabai as Noah, not Muhammad, with the rejected reading as the live trap, the quiz's best; q4 his going to his Lord as turning to Him in worship has a voice; q5 al-Tabrisi's both names related but Ishmael more evident, a nuanced report with no Isaac option, fair though it leans on who said what; q3 gap "doubt" for the sound heart, "envy" and "pride" live, recall; q1 True that Noah called only after despairing, a real point; in order |
| 37:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q2 the followers and leaders both share the punishment, "the leaders alone are punished" the live trap, the quiz's best; q4 the mocking companion seen down in hell, fair; q3 the attendants bring the known provision before it is asked has a little voice, with "the Prophet Muhammad" as an option; q1 gap "family of Muhammad" for those wronged is guessable in this app (as 25:3 and 29:2 "guardian"); q5 False "Quraysh took the Zaqqum as a warning" is a statement nobody would take; in order |
| 37:4 | TF, MC, whoSaid, MC, fillGap | 1 PASS | true-or-false opener; q2 Tabatabai holding the reports of Ilyas alive and immortal weak and unsupported by the verses, "they prove he was raised alive" the live trap, the quiz's best; q4 ba'l as owner (a Bedouin the ba'l of his camel) is al-Qummi's surprise, recall; q1 False "long life and great wealth" against al-Tabrisi's favor that cuts off harm, a real swap; q3 "I remembered Ilyas the prophet" has little voice; q5 gap "stones" for Lot's people is a well-known fact of the story, guessable; fill-the-gap closer, the second of the run; q2 and q3 both on v123; in order |
| 37:5 | whoSaid, fillGap, MC, TF, MC | 1 PASS | who-said-it opener, "What judgement is fairer than the lot, when the affair is entrusted to Allah?" has a strong voice; q3 al-Suddi reading the jinn made kin to God as the angels, "the invisible spirits themselves" the literal trap, the quiz's best; q5 the might that gives honour to the prophets, distractors from Jonah's story; q2 gap "wilaya" in "Allah offered my ____" is guessable in this app; q4 True on al-Qummi's application to Banu Umayya is a reported reading, framed "one reading"; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 5 | 59K | 51K to 69K | 8 min 37 s | 295K tokens, 43 min |
| reviewer | 5 | 26K | 24K to 30K | 1 min 17 s | 132K tokens, 6 min |

About 0.43M agent tokens for the surah, roughly 26 minutes wall clock with three slots.

### Review outcomes

5 of 5 PASS first time, no rewrites, no validator rejections.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 2 | | MC | 3 |
| MC | 1 | | TF | 1 |
| fillGap | 1 | | fillGap | 1 |
| whoSaid | 1 | | whoSaid | 0 |

True or false: 3 of 5 True; both parity rules held for 5 of 5. Translation anchors: 0. Perspectives anchors: 1 of 5 (37:1 has no perspectives; the others kept off the disputed points: the questioning of verse 24, Ishmael or Isaac, Il Yasin, "blameworthy"). Anchor spread: essay 12, narration 6, note 6, perspectives 1. All five in verse order. The surah's refrain ("Peace be upon ... thus do We reward the virtuous") drew no question, unlike Ash-Shu'araa's.

### Reader notes (taste, not rule)

- Best questions: 37:1 the old cosmology shown false, 37:2 both parties share the punishment, 37:3 "his followers" as Noah, 37:4 the reports of Ilyas alive held weak, 37:5 the jinn as the angels.
- Guessable gaps in this app: 37:2 "family of Muhammad", 37:5 "wilaya" (with 25:3 and 29:2 "guardian", the fourth and fifth of the run). 37:4 "stones" is a well-known fact of Lot's story. Note against the writer prompt: a gap whose answer is the app's own frame (wilaya, guardian, the Family) is guessable, however meaningful.
- Obvious False statement: 37:2 q5. Real swap: 37:4 q1.
- Who-said-it with little voice: 37:4 q3.

### Deviations from the procedure

- Three slots; free slots started surah 38 while surah 37 finished.
- Commits deferred to the end of the loop.

## Results - Saad 38:1 to 38:5 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 5 passed first review. `quiz_38.json` assembled with 5 quizzes: 10 multiple choice, 5 true or false, 5 fill the gap, 5 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 38:1 | MC, TF, fillGap, whoSaid, MC | 1 PASS | q3 gap "power" in Tabatabai's reading of "a thing intended", "wealth" the live trap, the quiz's best; q4 Pharaoh the Impaler explained has a vivid voice; q5 al-Tusi's "of the factions" as the party of Iblis, distractors from other phrases of the passage; q2 True on Quraysh plugging their ears and fleeing is narration content; q1 the musadah reading of the letter Saad, with the other early readings of Saad as wrong options: they are wrong as glosses of musadah, not as readings, and the reviewer weighed this for three minutes and passed it, but it sits close to the same-point line and tests an etymology; in order |
| 38:3 | whoSaid, MC, TF, fillGap, MC | 1 PASS | who-said-it opener, "He is not disobeyed as one overcome, nor obeyed under compulsion" has a strong voice and is the quiz's best; q2 al-Tabrisi refuting that all falsehood is God's doing, fair; q5 both traditions relay the ring story and both hold voices rejecting it, a fact-of-agreement shape whose wrong options (accept as history, reject with no dissent, ignore) are real alternatives, fair; q3 True on the sun returned for Solomon's missed prayer is narration content; q4 gap "destiny" in a 30-word prompt; q4 and q5 both on v34; q5 returns to v34, in order |
| 38:2 | MC, fillGap, whoSaid, MC, TF | 1 PASS | q3 "O Abu al-Salt, I am God's proof over His creation" (the proof knows every tongue) has a strong voice, the quiz's best; q2 gap "blessing" joined to power in Imam al-Baqir's gloss, "wisdom" live; q1 the single Cry as the first blast of the trumpet repeats 36:3 q5 across adjacent surahs; q4 both traditions relay the Uriya tale and both carry voices rejecting it, the same question as 38:3 q5 on the lost ring, twice in two passages; q5 False "no charge about how he must judge" is a bare negation, thin; in order |
| 38:4 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, Job tried without sin because the prophets are infallible, has a voice and is the quiz's best; q2 the oath kept with one blow of a hundred stalks, fair; q4 the maidens as the dark-eyed houris, "the wives they had on earth" the live trap; q3 gap "this world" for "the abode", "the Garden" live; q5 False "honored by their enemies" on the missing men is a statement no reader would take, though it rightly tests what both readings share; in order |
| 38:5 | TF, fillGap, MC, whoSaid, MC | 1 PASS | true-or-false opener; q3 "created with My two hands" as by His power and strength, "hands like His creatures" the literal trap, the quiz's best; q4 the day of the known time as Iblis slaughtered on the rock in Jerusalem has a startling voice; q5 the tidings learned at the rising of al-Qaim, framed as Shia narration, wrong options verse phrases rather than the Sunni readings (the reviewer checked "Day of Retribution" against Ikrima's "Day of Resurrection"); q2 gap "expiations" in "the ranks, the ____ and the good deeds", recall of a list; q1 True on "just a warner" as denying worldly aims, a real point; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 5 | 60K | 51K to 76K | 7 min 44 s | 300K tokens, 39 min |
| reviewer | 5 | 28K | 25K to 36K | 1 min 38 s | 139K tokens, 8 min |

About 0.44M agent tokens for the surah, roughly 25 minutes wall clock with three slots. 38:1's reviewer took 3 min 23 s and 36K tokens, weighing whether q1's wrong options (the other early readings of the letter Saad) sat on the same-point line.

### Review outcomes

5 of 5 PASS first time. One validator rejection (38:3: an anchor that crossed a quote boundary in a narration).

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 2 | | MC | 3 |
| whoSaid | 2 | | TF | 2 |
| TF | 1 | | fillGap | 0 |
| fillGap | 0 | | whoSaid | 0 |

True or false: 3 of 5 True; both parity rules held for 5 of 5. Translation anchors: 0. Perspectives anchors: 5 of 5. Anchor spread: narration 9, essay 9, perspectives 5, note 2. All five in verse order.

### Reader notes (taste, not rule)

- Best questions: 38:1 "power" as the charge against the Prophet, 38:2 the proof who knows every tongue, 38:3 "not disobeyed as one overcome", 38:4 Job tried without sin, 38:5 the two hands as power.
- The same perspectives question twice in two passages: 38:2 q4 (the Uriya tale) and 38:3 q5 (the lost ring) both ask how the traditions handle a story, with "both relay it and both carry voices rejecting it" as the answer. Each is fair alone; together they read as a template.
- Cross-surah repeat: 38:2 q1 asks the single Cry as the first blast of the trumpet, as 36:3 q5 did.
- 38:1 q1 asks what the word musadah means in one early reading of the letter Saad, with the other early readings as wrong options. It passed as a gloss of the word, not a ruling on the readings, but it tests an etymology.
- Thin statements: 38:2 q5 (bare negation), 38:4 q5 (a statement no reader would take).

### Deviations from the procedure

- Three slots; free slots started surah 39 while surah 38 finished.
- Commits deferred to the end of the loop.

## Results - Az-Zumar 39:1 to 39:8 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. 7 of 8 passed first review; 39:3 failed once and passed on one rewrite. `quiz_39.json` assembled with 8 quizzes: 16 multiple choice, 8 true or false, 8 fill the gap, 8 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 39:2 | whoSaid, MC, fillGap, MC, TF | 1 PASS | q4 the limbs testify only against the one on whom the word of punishment is due, "every soul, believer or disbeliever" the live trap, the quiz's best, and the same teaching 24:3 q5 used; q2 the hope that he might yield to their gods, fair; q5 False swaps the fleeting world for lasting reward, a real swap; q1 who-said-it is a paraphrased scene (a company at the gate of Paradise), asked "Who narrated this scene?", little voice; q3 gap "Garden" for the families made ready is guessable; in order |
| 39:1 | MC, fillGap, whoSaid, TF, MC | 1 PASS | q5 al-Tabrisi's reason God does not will His servants' unbelief (willing it would force Him to be pleased with it), framed as one reading, with wrong options from the passage and not al-Qurtubi's contrary view, the quiz's best; q3 "Does the one who says this claim Allah lacked the power to create Adam's wife from other than his rib?" has a strong voice; q4 True on "no bearer bears another's burden" freeing the children of unbelievers, a real point; q1 the surah as a response to pressure to give up tawhid, fair; q2 gap "placenta" in the three darknesses, recall; in order |
| 39:5 | MC, whoSaid, TF, fillGap, MC | 1 PASS | q1 Tabatabai reconciling God taking souls with the angel of death (angels as intermediary means), "the angel takes them independently" the live trap, the quiz's best; q2 the self ascending in sleep while the spirit stays, linked like a sunbeam, has a voice; q3 True on the Shia narrations pairing "God mentioned alone" with obedience to the family of Muhammad, framed as one tradition; q4 gap "resurrection" is guessable, and the prompt opens on "them"; q5 provision by His will, right option the longest; options end in full stops in q1 and q5; q1 and q2 both on v42; in order |
| 39:4 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q1 the lie against God as the claim that He has partners, "a denial of the resurrection" the live trap, the quiz's best; q3 al-Qummi's reading of the threat as "Exempt us from Ali", a polemical note carried as the source has it, with invented distractors; q4 created upon the recognition of Him has a voice, though the narration also quotes the Prophet, a near miss for the who-said-it; q2 gap "cause" in "their will there being the full ____ of what they attain" is hard to parse on one reading; q5 False "the Prophet is made a keeper over them" asserts the opposite of the essay, fair; in order |
| 39:3 | MC, whoSaid, fillGap, TF, MC | 2 (FAIL, PASS) | first review failed q5, which had the reader affirm that the Siffin reports tell against the Companions all being diligent scholars rewarded either way, Tabatabai's critique on the point where the traditions divide; the rewrite asks how the address ends (it turns to the Prophet, who will contend before their Lord), which takes no side but is a structural recall with distractors nobody would pick; q2 fainting at the Quran is from Satan, the true state softening, tenderness, tears and fear, has a strong voice and is the quiz's best; q1 the light as a mount to tell truth from falsehood, "a lamp in the heart" live; q3 gap "shackled" so only the face wards off the fire, "raised" live; q4 True that the words announced the Prophet's own death, narration content; in order |
| 39:7 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener; q4 the two blasts and Israfil descending with the Trumpet has a voice and is the quiz's best; q2 the "partner" as association in the guardianship of Ali, framed as the Shia narrations, not al-Tabari's reading in a wrong slot, but one wrong option ("ingratitude for the support given by Ali") is the passage's Shia gloss of v66, wrong only as an answer about v65 (the 33:3 class, a taste note); q3 gap "measure" against "limit" and "likeness", near synonyms; q5 the Book with the prophets and the martyrs, close to the verse's wording; q1 True restates the essay's setting, thin; in order |
| 39:6 | MC, fillGap, MC, whoSaid, TF | 1 PASS | q2 gap "expansive" for Imam Ali's word on "do not despair of God's mercy", "merciful" the live trap, the quiz's best; q4 God delegated His religion to His Prophet but not creation or provision has a voice and a point; q1 the summons both reminds and draws toward mercy, fair; q3 al-Qummi's Quran-and-wilaya reading, invented distractors nobody would pick; q5 False "a reading only Shia narrations give" tests whether a reading is shared rather than what it holds, near the bare-agreement shape (as 29:4 q5); q5 returns to v56 after v62 (perspectives close) |
| 39:8 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q4 al-Qummi reading "judgment will be made between them" as an allusion to the people of paradise and the fire, "already finished in the past" the live trap, the quiz's best; q3 the eight gates of Paradise has a voice, cut before the speaker's own line; q2 the wary made safe and pleased with their dwelling, distractors from verse 71; q1 gap "unbelief" is guessable; q5 False "a seal on the beginning only, not the return" swaps Tabatabai's pairing, fair; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 8 | 60K | 47K to 85K | 8 min 3 s | 483K tokens, 64 min |
| rewrite | 1 | 43K | - | 4 min 10 s | 43K tokens |
| reviewer | 9 | 27K | 24K to 30K | 1 min 26 s | 239K tokens, 13 min |

About 0.77M agent tokens for the surah, roughly 32 minutes wall clock with three slots. 39:6 (verses 53 to 63, "do not despair of God's mercy") was the heaviest writer at 85K tokens and 13 min 12 s.

### Review outcomes

7 of 8 PASS first time. 39:3 FAIL on q5: it asked which claim about the Companions the Siffin reports "are taken to tell against", making the reader affirm Tabatabai's critique on the point where the traditions divide (the Companions' standing). The rewrite moved q5 to how the address ends; second review PASS. No validator rejections.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 5 | | MC | 4 |
| whoSaid | 1 | | TF | 4 |
| TF | 1 | | fillGap | 0 |
| fillGap | 1 | | whoSaid | 0 |

True or false: 4 of 8 True; both parity rules held for 8 of 8. Translation anchors: 0. Perspectives anchors: 4 of 8. Anchor spread: essay 20, narration 12, note 4, perspectives 4. Seven of eight in verse order; 39:6 closes on a perspectives statement about verse 56. Multiple choice opened five of eight, the heaviest opener of the run.

### Reader notes (taste, not rule)

- Best questions: 39:1 al-Tabrisi's reason God does not will unbelief, 39:2 the limbs testify only against the one due punishment, 39:3 fainting at the Quran is from Satan, 39:4 the lie as the claim of partners, 39:5 the angels as intermediary means, 39:6 "expansive", 39:7 Israfil and the two blasts, 39:8 the people of paradise and the fire.
- 39:3's failure is the first reviewer fail of its kind: a perspectives question can report one tradition's reading, but not ask the reader to affirm that the reports refute the other tradition's doctrine. The writer prompt covers "a right side between the traditions"; the reviewer read "are taken to tell against" as the passage's own verdict.
- 39:7 q2's wrong options include the passage's Shia gloss of verse 66 in a question about verse 65, the 33:3 class; taste.
- 39:6 q5 ("a reading only Shia narrations give", False) and 29:4 q5 test whether a reading is shared rather than what it holds; near the bare-agreement shape the writer prompt bars.
- Cross-surah repeat: 39:2 q4 (the limbs testify only against the one due punishment) is the teaching 24:3 q5 used.
- 39:2 q1's who-said-it is a paraphrased scene asked as "Who narrated this scene?".
- Guessable gaps: 39:2 "Garden", 39:5 "resurrection", 39:8 "unbelief". Hard to parse: 39:4 q2 "cause".

### Deviations from the procedure

- Three slots; free slots started surah 40 while surah 39 finished.
- Commits deferred to the end of the loop.

## Results - Ghafir 40:1 to 40:9 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 9 passed first review. `quiz_40.json` assembled with 9 quizzes: 18 multiple choice, 9 true or false, 9 fill the gap, 9 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 40:3 | MC, fillGap, TF, whoSaid, MC | 1 PASS | q2 gap "court" in al-Tabrisi's reading of Pharaoh's "Let me" (a sign some urged him not to kill Moses), "army" live, the quiz's best; q3 True (Pharaoh's companions all lawfully born) and q4 (his legitimate birth prevented him) quiz the same idea from two narrations, three questions on v26; q4 has a voice; q1 manifest proofs defied, distractors nobody would pick; q5 refuge with the Creator, right option the longest; in order |
| 40:1 | fillGap, MC, whoSaid, TF, MC | 1 PASS | fill-the-gap opener; q2 "severe in retribution" placed after "forgiver of sins" so the servant stays between hope and fear, "so fear outweighs hope" the live trap, the quiz's best; q3 disputants cursed on the tongue of seventy prophets has a voice; q5 the faithless of verse 6 as Bani Umayya, framed as the Shia narrations, wrong options from the passage; q1 gap "Praiseworthy" in the gloss of Ha Meem, the third opening-letter gloss of the run (26:1, 27:1), recall; q4 True restates Tabatabai, thin; in order |
| 40:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q3 the spirits of the prophets, messengers and proofs answering "To God, the One, the All-paramount" has a voice and is the quiz's best; q2 al-Qummi's signs as the Imams, with distractors from the passage; q4 the Approaching Day as the near Resurrection, "a distant Day" the mirror trap; q1 gap "hatred" for maqt is a word gloss, and the prompt opens on "this outrage"; q5 False "the objects worshipped judge alongside Allah" is a statement no reader would take; in order |
| 40:4 | MC, whoSaid, TF, MC, fillGap | 1 PASS | q1 the hidden believer's two-sided reasoning (if he lies the harm is his, if truthful it strikes them), with the mirror as the live trap, the quiz's best; q2 "Taqiyya is part of my religion and the religion of my forefathers" has a strong voice; q3 False "his sound, unblemished hand" against al-Qummi's withered hand is a detail of a note, trivia; q4 Joseph a prophet and messenger, distractors nobody would pick; q5 gap "weak-minded" for the tower as deception, and the prompt opens on "this"; fill-the-gap closer (third of the run); three questions on v28; in order |
| 40:5 | fillGap, MC, TF, whoSaid, MC | 1 PASS | fill-the-gap opener; q2 al-Sadiq correcting Abu al-Khattab's "act as you wish" to "do whatever good you wish that is accepted", with the misquote as the live trap, the quiz's best; q4 arrogance as abandoning obedience to those one was commanded to obey has a voice; q3 True separating the morning-and-evening Fire from the everlasting Fire of the Hour, a real distinction; q5 the keepers tell them to invoke for themselves, right option the longest; q1 gap "oneness" guessable; in order |
| 40:6 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q2 Tabatabai's promise of help to the class of messengers, not every individual, "each believer triumphs in this world" the live trap, the quiz's best; q3 a fire within the Fire for every arrogant tyrant has a voice; q4 al-Tusi's greater creation as an argument against deniers of the second creation, fair; q5 False "the killed prophets were already helped in this world" in the Shia reading (help comes in the raja), a real swap framed as one tradition; q1 gap "Imams" for al-Qummi's witnesses, guessable in this app; q5 returns to v51 (perspectives close) |
| 40:9 | whoSaid, MC, fillGap, TF, MC | 1 PASS | q2 "God shows you His signs" as a lead-in to the rebuke over which signs they deny, the quiz's best, and it keeps off al-Qummi's disputed gloss; q4 True on al-Hadi citing the two verses to rule on a late convert is a narration fact in a long compound statement; q1 the reward for reciting Ha Mim al-Mu'min has little of a speaker's voice; q3 gap "castles" is recall, and shipped without a full stop (the thirteenth stop-less gap); q5 both traditions refuse Pharaoh's late faith, the three wrong options the same idea nobody would pick; in order |
| 40:7 | TF, MC, whoSaid, fillGap, MC | 1 PASS | true-or-false opener; q2 only obstinate denial turns one from signs that are plain, with its mirror as the live trap, the quiz's best; q3 "O Aban, when you reach Kufa, narrate this hadith" has a voice; q4 gap "punishment" against "wrath" in a 35-word prompt, near synonyms; q5 follow the testimony with "All praise belongs to God" is recall of a phrase; q3, q4 and q5 all on v65 and all on the testimony of oneness, one theme three times; q1 True restates the essay, thin; in order |
| 40:8 | MC, whoSaid, MC, fillGap, TF | 1 PASS | q1 the renewed mention of the disputers read as wonder at their diversion, not a new group, with "a new distinct group" as the live trap, the quiz's best; q2 denying the Book or its interpretation as polytheism has a voice; q4 gap "torment" matching how they lived, "reward" and "portion" live; q3 fuel of the Fire, distractors nobody would pick; q5 False "sincere seekers in good faith" is a statement no reader would take, though it rests on the point both readings share; q5 returns to v69 (perspectives close) |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 9 | 58K | 48K to 81K | 7 min 54 s | 526K tokens, 71 min |
| reviewer | 9 | 25K | 23K to 27K | 1 min 14 s | 227K tokens, 11 min |

About 0.75M agent tokens for the surah, roughly 38 minutes wall clock with three slots.

### Review outcomes

9 of 9 PASS first time, no rewrites, no validator rejections. One stop-less gap shipped (40:9 q3), the thirteenth.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| fillGap | 4 | | MC | 5 |
| MC | 3 | | TF | 3 |
| TF | 1 | | fillGap | 1 |
| whoSaid | 1 | | whoSaid | 0 |

True or false: 5 of 9 True; both parity rules held for 9 of 9. Translation anchors: 0. Perspectives anchors: 5 of 9. Anchor spread: essay 21, narration 15, perspectives 5, note 4. Seven of nine in verse order; 40:6 and 40:8 close on a perspectives statement about an earlier verse.

### Reader notes (taste, not rule)

- Best questions: 40:1 between hope and fear, 40:2 the spirits answering "To God, the One", 40:3 Pharaoh's "court", 40:4 the believer's two-sided reasoning, 40:5 al-Sadiq correcting Abu al-Khattab, 40:6 help promised to the class, not each one, 40:7 signs too plain to miss, 40:8 wonder, not a new group, 40:9 the signs as a lead-in to the rebuke.
- One theme asked more than once in a quiz: 40:3 q3 and q4 (Pharaoh's companions lawfully born; his legitimate birth held him back), 40:7 q3 to q5 (the testimony of oneness three times on verse 65).
- Opening-letter glosses as gaps recur: 40:1 q1 (Ha Meem), after 26:1 and 27:1; each is recall.
- Statements no reader would take: 40:2 q5, 40:8 q5. Trivia: 40:4 q3 (the withered hand of a note).
- Gap prompts opening on "this" or "them": 40:2 q1, 40:4 q5.

### Deviations from the procedure

- Three slots; free slots started surah 41 while surah 40 finished.
- Commits deferred to the end of the loop.

## Results - Fussilat 41:1 to 41:6 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 6 passed first review. `quiz_41.json` assembled with 6 quizzes: 12 multiple choice, 6 true or false, 6 fill the gap, 6 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 41:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q3 "carried to their graves, though not called riders; sent down into the tombs, though not called guests" has the strongest voice, the quiz's best; q2 the four days of sustenance as the four seasons is al-Qummi's surprise; q4 a man transformed in his own house as the humiliating punishment, narration recall; q5 False "withheld the path of truth" asserts the opposite of what both traditions share, fair; q1 gap "stretches of time" is given away by the prompt's own "not the day we measure by the earth's turning", with "ordinary earthly days" the negated option; in order |
| 41:1 | TF, fillGap, MC, whoSaid, MC | 1 PASS | true-or-false opener, and a True that carries a real distinction (al-Rahman for all, al-Rahim for the faithful); q5 Ibn Kathir reconciling a Meccan verse with zakat as the levy (charity's root commanded from the start), the quiz's best, with the right option the longest; q3 "most of them turn away" as turning from the wilaya of Ali, guessable in this app; q4 the reward for reciting the surah's close has little voice; q2 gap "plainly" set against "in sum" in the prompt itself, guessable, and shipped without a full stop after one rejection (the fourteenth); in order |
| 41:3 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener; q4 the last servant ordered to the Fire, admitted because he once thought well of God, has a strong voice and is the quiz's best; q2 the skins' reply (the God who gave all things speech gave us speech), "fear of the Fire forced them" the live trap; q3 gap "secret talk" in Ibn Mas'ud's report of three men, "hidden sins" live; q5 the enemies of Allah as deniers at large, the reading both sides share, distractors nobody would pick; q1 True restates the note, thin; in order |
| 41:4 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q3 "Yes, by God, they descend upon us and tread our carpets" has a strong voice, the quiz's best; q4 the angels as guardians from the satans, "they recorded good deeds" the live trap; q2 the worst deed as unbelief, the other phrases of the passage as traps, fair; q1 gap "mockery and idle noise", distractors nobody would pick; q5 False "found only in Shia sources" is the shared-transmission shape again (33:4, 39:6), a fact about who carries a report; q5 returns to v29 after v31 (perspectives close); one validator rejection (an anchor that ended inside a quote) |
| 41:6 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, differing over the Book that is with the Qaim has a voice; q4 al-Tusi: God bestows favor even on the unbeliever, "man earns every blessing" the live trap, the quiz's best; q2 the disputed earlier scripture as consolation, fair; q5 False swaps the conquest of Mecca (the shared reading) for the Shia reading's rising of the Qaim, a real swap; q3 gap "choice" opens "Rather, He gives them a ____" with no referent for "He" or "them"; in order |
| 41:5 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener, the question read as a denial (no one calls better), a real point; q2 "Shake hands with your enemy even if he dislikes it" has a voice and is the quiz's best; q3 from the single ordering of sun and moon to the oneness of their Lord, distractors nobody would pick; q5 patience and pardon as the reading both traditions share, but its wrong options are other verses' content that answer nothing about repelling evil; q4 gap "revelation", the prompt opens on "this verse", shipped without a full stop (the fifteenth, forced by a stripped-marker " ." in the essay); in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 6 | 61K | 46K to 79K | 8 min 1 s | 363K tokens, 48 min |
| reviewer | 6 | 25K | 24K to 25K | 1 min 5 s | 148K tokens, 7 min |

About 0.51M agent tokens for the surah, roughly 34 minutes wall clock with three slots.

### Review outcomes

6 of 6 PASS first time. Two validator rejections, both the exact-span family: 41:1 q2 (a trailing full stop on a gap prompt) and 41:4 q4 (an anchor ending inside a quotation). Two stop-less gaps shipped (41:1 q2, 41:5 q4), the fourteenth and fifteenth; 41:5's comes from a stripped citation marker that leaves " ." in the essay, so the sentence cannot end cleanly.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 3 | | MC | 3 |
| fillGap | 2 | | TF | 3 |
| whoSaid | 1 | | fillGap | 0 |
| MC | 0 | | whoSaid | 0 |

True or false: 3 of 6 True; both parity rules held for 6 of 6. Translation anchors: 0. Perspectives anchors: 6 of 6. Anchor spread: essay 11, narration 9, perspectives 6, note 4. Four of six in verse order; 41:4 and 41:5 close on a perspectives question about an earlier verse. Multiple choice never opened.

### Reader notes (taste, not rule)

- Best questions: 41:1 Ibn Kathir's Meccan zakat, 41:2 "carried to their graves, though not called riders", 41:3 the last servant who once thought well of God, 41:4 "they tread our carpets", 41:5 "shake hands with your enemy", 41:6 favor even on the unbeliever.
- The shared-transmission true or false recurs: 41:4 q5 ("found only in Shia sources", False), after 33:4, 39:6. It tests who carries a report, not what it says.
- Gaps given away by their own prompt: 41:1 q2 ("plainly" against "in sum"), 41:2 q1 ("stretches of time" against "not the day we measure").
- Prompts with no referent: 41:5 q4 ("this verse"), 41:6 q3 ("Rather, He gives them").
- 41:5 q5's wrong options are content from other verses that answer nothing about repelling evil; nobody would pick them.

### Deviations from the procedure

- Three slots; free slots started surah 42 while surah 41 finished.
- Commits deferred to the end of the loop.

## Results - Ash-Shura 42:1 to 42:5 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 5 passed first review. `quiz_42.json` assembled with 5 quizzes: 10 multiple choice, 5 true or false, 5 fill the gap, 5 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 42:1 | whoSaid, MC, fillGap, TF, MC | 1 PASS | who-said-it opener, the letters as the years of the Qa'im and Qaf a mountain of green emerald, with Ibn Abbas a fair distractor; q2 Tabatabai's "thus" as the act of revealing, a standing practice to every prophet, with the majority reading ("the surah's meanings") as the live trap, the quiz's best, though the right option is the longest; q3 gap "heaven after heaven", fair; q5 Sam son of Noah raised from a coffin at Ali's prayer, story recall with the right option the longest; q4 True on al-Qummi's forgiveness for the Shia penitent, a note restated; the fourth opening-letter gloss of the run; in order |
| 42:2 | TF, MC, whoSaid, MC, fillGap | 1 PASS | true-or-false opener, False "need not be the one who resolves their differences" is a bare negation of Tabatabai's argument, thin; q2 one religion for all prophets, forbidding division, the reading both share, with distractors nobody would pick; q3 "We are those for whom He prescribed His religion ... O family of Muhammad" has a voice; q4 al-Qummi's division from envy over Amir al-Mu'minin's excellence, "out of ignorance before knowledge reached them" the live trap against the verse, the quiz's best; q5 gap "mockery" in how the deniers hasten the Hour, "hope" live; fill-the-gap closer (fourth of the run); in order |
| 42:4 | whoSaid, MC, fillGap, MC, TF | 1 PASS | who-said-it opener, "no throbbing vein, no headache and no illness except by a sin" has a voice; q4 self-defence as a permission whose holder may act or refrain, "a duty that admits no refraining" the live trap, the quiz's best; q5 False on al-Tabari holding the abrogation, which he records and rejects, a recording-versus-holding nuance, fair; q2 the wrecking of ships as drowning for sins, fair; q3 gap "wine, gambling and unchastity" is a list to recall, shipped without a full stop after one rejection (the sixteenth); in order |
| 42:3 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener, the two tillages restated from a narration; q4 angels striking the clouds with rods, that is the lightning, has a vivid voice and is the quiz's best; q2 al-Tusi's conclusive word deferring punishment to the Hereafter, fair; q3 gap "submission" in "Performing the good deed is ____ to us" against "loyalty", hard to recover; q5 asks why Ibn Kathir doubts the report naming Fatimah and her children (the surah is Meccan), on the verse of mawadda, and no question asks the Ahl al-Bayt reading itself; the reviewer weighed it for four minutes and passed it as attributed; flagged for the user; q5 returns to v23 after v28 (perspectives close) |
| 42:5 | TF, fillGap, MC, whoSaid, MC | 1 PASS | true-or-false opener, restating Tabatabai on the opening verse, thin; q3 the Prophet's duty only to communicate, not guard their beliefs, "to compel them" the live trap, the quiz's best; q4 al-Hadi on the pairing of the obedient with houris has a voice; q2 gap "Qa'im" in the furtive look, with "Fire" a near miss the reviewer weighed (the essay has them glancing at the Fire), and the prompt is a quoted fragment; q5 the light as Ali and his wilaya, framed as the Imami narrations, but one wrong option ("a creature greater than Jibril and Mika'il") is the passage's own Shia gloss of "the Spirit", the 33:3 class; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 5 | 67K | 62K to 81K | 9 min 14 s | 337K tokens, 46 min |
| reviewer | 5 | 31K | 25K to 40K | 2 min 14 s | 153K tokens, 11 min |

About 0.49M agent tokens for the surah, roughly 34 minutes wall clock with three slots. Reviewers ran longest of the run here: 42:3's took 4 min 13 s and 40K tokens on the Ibn Kathir question, 42:5's 3 min 13 s on the "Qa'im" and "Fire" gap.

### Review outcomes

5 of 5 PASS first time. One validator rejection (42:4 q3, a trailing full stop on a gap prompt); the sixteenth stop-less gap shipped.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 3 | | MC | 3 |
| whoSaid | 2 | | fillGap | 1 |
| MC | 0 | | TF | 1 |
| fillGap | 0 | | whoSaid | 0 |

True or false: 3 of 5 True; both parity rules held for 5 of 5. Translation anchors: 0. Perspectives anchors: 4 of 5. Anchor spread: essay 10, narration 8, perspectives 4, note 3. Four of five in verse order; 42:3 closes on a perspectives question about verse 23.

### Reader notes (taste, not rule)

- Best questions: 42:1 "thus" as the act of revealing, 42:2 the division from envy over Amir al-Mu'minin, 42:3 the angels' rods as lightning, 42:4 self-defence as a permission, 42:5 the duty only to communicate.
- For the user's decision: 42:3 q5 is the verse of mawadda (42:23). It asks why Ibn Kathir doubts the report naming Fatimah and her children (the surah is Meccan, Fatimah then had no children), and no question in the quiz asks the Ahl al-Bayt reading itself. It is attributed and takes no side, so it passes the rules, but it puts the Sunni doubt, not the Shia reading, in front of the reader on this verse.
- 42:5 q5 has the passage's Shia gloss of "the Spirit" as a wrong option on the "light" question; the 33:3 class.
- Opening-letter glosses: 42:1 q1 (the letters as the years of the Qa'im), the fourth of the run.

### Deviations from the procedure

- Three slots; free slots started surah 43 while surah 42 finished.
- Commits deferred to the end of the loop.

## Results - Az-Zukhruf 43:1 to 43:7 (2026-09-30)

Same `/loop` run, three slots. No prompt change during the surah. All 7 passed first review. `quiz_43.json` assembled with 7 quizzes: 14 multiple choice, 7 true or false, 7 fill the gap, 7 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 43:1 | TF, MC, fillGap, whoSaid, MC | 1 PASS | true-or-false opener, and a True that carries al-Mizan's point (the Book clothed in Arabic so reason could reach it); q5 no offspring because a part would imply composition in the undivided One, the quiz's best, though the right option is the longest; q3 gap "knowledge" for the innate admission of the Creator, "fear" and "worship" live; q4 the riding promise (no fracture, no harm) has a voice, phrased "Who gave this counsel?"; q2 fact-of-agreement shape (the verse exalts what is with God), wrong options from other verses nobody would pick; in order |
| 43:2 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener; q1 gap "what they cannot bear for themselves" is the passage's single charge, "the sons they kept for their own line" the live trap, the quiz's best; q3 "We are God's judges on His earth and His witnesses over His creation" has a strong voice (spelled al-Kadhim, as the passage spells it); q4 both Tusi and Qurtubi hold the excuse false though they differ on divine will, fair; q2 Pharaoh flinging the taunt at Moses is easy once the prompt names Pharaoh; q5 False "the good end promised to the affluent imitators", a wrong positive, fair; in order |
| 43:3 | MC, TF, whoSaid, fillGap, MC | 1 PASS | q5 gold and silver withheld so people would not all rally to disbelief, "the faithless deserve no share" the live trap, the quiz's best; q4 gap "prophethood" as the mercy they cannot apportion, "livelihood" the thing God does apportion, a real gap; q2 True on the Shia narrations' enduring word as the Imamah in al-Husayn's line, framed as one tradition; q1 the One who originated him, "no one, since he rejected all worship" live; q3 "It is Urwa ibn Masud al-Thaqafi" is a third-person identification of an occasion, the kind of line any narrator could carry; in order |
| 43:4 | fillGap, MC, whoSaid, MC, TF | 1 PASS | fill-the-gap opener, "going blind" against deliberately turning away, the two readings of the verb, fair; q2 both did wrong so both share the punishment, "the companion already repented on his behalf" live, the quiz's best; q3 "you will know me in the squadron that fights you" has a voice, but "after me" gives the speaker away against three Imams, and the option reads "Prophet Muhammad" against the house "the Prophet"; q4 "Ali is the straight path" is an app-frame answer a skimmer guesses; q5 False on God setting up other gods, a bare negation, thin; in order; the writer turn took 21 min 46 s, second slowest of the run |
| 43:5 | TF, MC, whoSaid, fillGap, MC | 1 PASS | true-or-false opener, True on the story as an answer to the Meccans who scorned the Prophet for lacking wealth; q2 the impediment God had already lifted, fair; q3 "God does not grieve as we grieve" has a voice; q4 gap "minds" sits on the essay's quotation of verse 54, close to verse memory; q5 the consolation, his people's mockery ending as Pharaoh's did, with "gold bracelets and angels" a distractor drawn from the passage, the quiz's best; q4 (v54) follows q3 (v55) |
| 43:6 | MC, fillGap, MC, whoSaid, TF | 1 PASS | multiple-choice opener on the occasion the Shia narrations give (the Prophet likening Ali to Jesus), scoped to one tradition with no Sunni reading among the wrong options, the quiz's best; q2 gap "clamor" for the outcry, fair; q3 Jesus as a servant honored with prophethood, the right option the longest and "a god worthy of worship beside the idols" a distractor nobody picks; q4 "It is the hour of al-Qaim" has a voice; q5 False on worldly friendships enduring, fair; in order |
| 43:7 | TF, whoSaid, MC, fillGap, MC | 1 PASS | true-or-false opener, True on "no fear, no grief" spoken on the Day itself; q2 a single meal the length of the world's days has a voice; q3 "the guilty" as everyone steeped in crime, but three "Only ..." distractors against one "Everyone", a shape tell; q4 opens "Both hold" with no referent (the traditions go unnamed), on the shared point about the recording angels; q5 godhood reaching both realms, not containment, the quiz's best, though the right option is the longest; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 7 | 57K | 49K to 67K | 9 min 15 s | 398K tokens, 65 min |
| reviewer | 7 | 25K | 24K to 32K | 1 min 15 s | 178K tokens, 9 min |

About 0.58M agent tokens for the surah. 43:4's writer took 21 min 46 s, the second slowest turn of the run after 30:2; its tokens (62K) were ordinary, so the time went to thinking, not reading. 43:6's reviewer took 2 min 32 s weighing the Shia-narrations occasion question against rule 5.

### Review outcomes

7 of 7 PASS first time. No validator rejections reported by the writers.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| TF | 3 | | MC | 4 |
| fillGap | 2 | | TF | 3 |
| MC | 2 | | fillGap | 0 |
| whoSaid | 0 | | whoSaid | 0 |

True or false: 4 of 7 True; both parity rules held for 7 of 7. Translation anchors: 0. Perspectives anchors: 5. Anchor spread: essay 19, narration 8, perspectives 5, note 3. Six of seven in verse order; 43:5 puts q4 (v54) after q3 (v55).

### Reader notes (taste, not rule)

- Best questions: 43:1 no offspring because a part would imply composition, 43:2 "what they cannot bear for themselves", 43:3 gold and silver withheld lest all rally to disbelief, 43:4 both share the punishment, 43:5 the consolation in Pharaoh's end, 43:6 the Shia narrations' occasion (scoped to one tradition, no Sunni reading as a wrong option, the clean form of the perspectives question), 43:7 godhood reaching both realms.
- Longest-option tell: 43:1 q5, 43:6 q3, 43:7 q5. Shape tell: 43:7 q3 has three "Only ..." distractors against one "Everyone".
- Speaker giveaways: 43:4 q3 "after me" against three Imams, written "Prophet Muhammad" against the house "the Prophet"; 43:3 q3 is a third-person identification of an occasion.
- Guessable app-frame answer: 43:4 q4 "Ali is the straight path".
- Prompt with no referent: 43:7 q4 opens "Both hold".
- Verse memory by the back door: 43:5 q4 gaps the essay's quotation of verse 54.
- Spelling: the passage spells the seventh Imam "al-Kadhim" (43:2 q3 follows it), as in surahs 9, 11 and 20; a passage issue, outside the quiz.

### Deviations from the procedure

- Three slots; free slots started surah 44 while surah 43 finished.
- Commits deferred to the end of the loop.

## Results - Ad-Dukhaan 44:1 to 44:3 (2026-09-30)

Same `/loop` run, three slots, last surah with shipped passages. No prompt change during the surah. All 3 passed first review. `quiz_44.json` assembled with 3 quizzes: 6 multiple choice, 3 true or false, 3 fill the gap, 3 who said it.

| passage | type order | reviews | reader note |
|---|---|---|---|
| 44:1 | MC, fillGap, whoSaid, TF, MC | 1 PASS | multiple-choice opener, the surah as a warning to those who doubt this Book, "a comfort for those who already believe" live; q2 gap "measured out" on the Night of Ordainment, but the prompt "On it everything of the coming year is ____" is eight words with "it" unexplained, the short-fragment class; q3 Ha Meem as Muhammad and the night as Fatimah has a voice, the fifth opening-letter gloss of the run; q4 True that Pharaoh's people are recalled to steady the Prophet, a restatement, thin; q5 the sky and earth weeping for none but Yahya ibn Zakariyya and Husayn, the quiz's best, but it closes on a narration on the last verse, not the essay close or perspectives: the writer left the smoke dispute alone because its only other readings were the other tradition's; in order |
| 44:2 | whoSaid, MC, TF, MC, fillGap | 1 PASS | who-said-it opener, "they are the Imams from among the believers" has a voice, though the quote opens on an ellipsis and the reader must tell al-Baqir from the al-Sadiq narrations around it; q2 "the nations of their own time", with "every nation of every age" the live trap, the quiz's best; q3 False on Tubba counted among the guilty, the assumption a skimmer makes, good; q4 a creation that merely perished would be idle, wrong options from the passage's own events; q5 gap "intercession" on the shared point, "forgiveness" live, the prompt opens "Both traditions thus" with the "thus" hanging; in order |
| 44:3 | TF, MC, whoSaid, fillGap, MC | 1 PASS | true-or-false opener, True on "the sinful" as one in whom sin has settled through persistence or excess, a restatement; q2 the taunt "mighty and noble" because Abu Jahl claimed the title, "he truly stood among the honored" live, the quiz's best; q3 holding fast to God, safe in God's party, has a voice; q4 gap "rank" in the divine saying, but the prompt opens "God said: ... grant him" with "him" unexplained; q5 the closing verse as the summing-up of the whole surah, with "the first verse revealed" and "a warning aimed only at Abu Jahl" distractors nobody would pick; the perspectives (who the Godwary are) left alone; in order |

### Costs (real agents, with hooks)

| run | n | tokens mean | tokens min to max | time mean | total |
|---|---|---|---|---|---|
| writer | 3 | 60K | 57K to 64K | 7 min 53 s | 179K tokens, 24 min |
| reviewer | 3 | 24K | 23K to 25K | 1 min 2 s | 73K tokens, 3 min |

About 0.25M agent tokens for the surah.

### Review outcomes

3 of 3 PASS first time. No validator rejections reported by the writers.

### Type order across the surah

| opener | count | | closer | count |
|---|---|---|---|---|
| MC | 1 | | MC | 2 |
| whoSaid | 1 | | fillGap | 1 |
| TF | 1 | | TF | 0 |
| fillGap | 0 | | whoSaid | 0 |

True or false: 2 of 3 True; both parity rules held for 3 of 3. Translation anchors: 0. Perspectives anchors: 1 of 3. Anchor spread: narration 7, essay 6, note 1, perspectives 1. All three in verse order.

### Reader notes (taste, not rule)

- Best questions: 44:1 the sky and earth weeping for Yahya and Husayn, 44:2 "the nations of their own time", 44:3 Abu Jahl and the title he claimed.
- Perspectives left alone twice: 44:1 (the smoke) and 44:3 (who the Godwary are). Both writers said the only other readings on offer were the other tradition's, which the 31:3 rule forbids as wrong options, so they quizzed elsewhere; 44:1 then closes on a narration on the last verse rather than the essay close or perspectives. The rule working as meant, at the price of a thinner close.
- Prompts with no referent: 44:1 q2 "On it" (eight words), 44:3 q4 "grant him", 44:2 q5 "Both traditions thus".
- Opening-letter glosses: 44:1 q3 (Ha Meem as Muhammad), the fifth of the run.

### Deviations from the procedure

- Three slots.
- Commits deferred to the end of the loop.

## Run summary - surahs 25 to 44 (2026-09-30)

One `/loop` run, 11:46 to 18:47, about 7 hours wall clock with three agent slots (the user's cap for this run). 124 quizzes written and passed across 20 surahs. The reviewer failed two (28:8, 39:3); I sent back two more on the perspectives rule (31:3 after it had passed, 33:2 before review). All four were fixed by one rewrite each. Six validator rejections, all fixed by the writers; five more stop-less gaps shipped (twelfth to sixteenth). About 10.8M agent tokens: writers 7.43M (124 runs, mean 60K, about 9 min each), reviewers 3.20M (127 runs, mean 25K, about 1 min 15 s each), rewrites 0.14M.

| surah | quizzes | first-review pass | rewrites | agent tokens |
|---|---|---|---|---|
| 25 | 6 | 6 | 0 | 0.46M |
| 26 | 11 | 11 | 0 | 0.87M |
| 27 | 7 | 7 | 0 | 0.60M |
| 28 | 8 | 7 | 1 | 0.74M |
| 29 | 7 | 7 | 0 | 0.60M |
| 30 | 6 | 6 | 0 | 0.50M |
| 31 | 3 | 3 | 1 (31:3, sent back after PASS) | 0.32M |
| 32 | 3 | 3 | 0 | 0.25M |
| 33 | 9 | 9 | 1 (33:2, sent back before review) | 0.81M |
| 34 | 6 | 6 | 0 | 0.52M |
| 35 | 5 | 5 | 0 | 0.45M |
| 36 | 5 | 5 | 0 | 0.42M |
| 37 | 5 | 5 | 0 | 0.43M |
| 38 | 5 | 5 | 0 | 0.44M |
| 39 | 8 | 7 | 1 | 0.77M |
| 40 | 9 | 9 | 0 | 0.75M |
| 41 | 6 | 6 | 0 | 0.51M |
| 42 | 5 | 5 | 0 | 0.49M |
| 43 | 7 | 7 | 0 | 0.58M |
| 44 | 3 | 3 | 0 | 0.25M |

Every surah with shipped passages (1 to 44) now has a quiz file. The next quiz surah is whichever surah the passage pipeline ships next (45).

Prompt change made during the run (after 31:3 and 33:2, narrowed after 33:3): the writer's Distractors rule and the reviewer's criterion 5 now say that neither tradition's reading of the point a question asks about may be a wrong option, even in a "what both traditions share" question. From surah 34 on no wrong option was a tradition's reading of its own question's point, and in 44:1 and 44:3 the writers left the perspectives alone rather than break it.

Notes carried out of the run, for the next prompt or validator change:

- `quiz.py`: allow a trailing full stop on a gap prompt when the exact-span match succeeds without it (sixteen stop-less gaps shipped in total).
- Writer prompt: in a one-tradition perspectives question, the passage's own gloss of another verse or word from that tradition must not be a wrong option either (33:3, 42:5 q5).
- Writer prompt: a prompt names what it is about; no opening "this", "them", "Both hold" (43:7 q4), "On it" (44:1 q2) or "grant him" (44:3 q4) without the referent.
- Writer prompt: name the speaker "the Prophet", as the options list does, never "Prophet Muhammad" (29:4, 43:4); and a who-said-it line with "after me" gives the Prophet away against three Imams (43:4 q3).
- Writer prompt: the right option should not be the longest or the only one of its shape (longest-option tells through the run; 43:7 q3 three "Only ..." against one "Everyone").
- Writer prompt: avoid gaps and answers a reader of this app guesses without reading (guardian, wilaya, family of Muhammad, "Ali is the straight path" in 43:4 q4).
- Writer prompt: cross-surah repeats a reader who does several quizzes will notice: opening-letter glosses (five in the run, including Ta Seen and Ha Meem), the white hand, the "three things" narration, the Cry, the limbs bearing witness; and surah 26's refrain asked three times.
- Writer prompt: the shared-transmission true-or-false shape ("both traditions carry this report") recurs (33:4, 39:6, 41:4) and tests agreement, not content.
- Writer turns over 20 minutes with ordinary token counts: 30:1, 30:2, 35:5, 43:4. No fault in the output; the time went to thinking.

For the user's decision:

- 42:3 q5, on the verse of mawadda (42:23), asks why Ibn Kathir doubts the report naming Fatimah and her children, and no question in the quiz asks the Ahl al-Bayt reading itself. It passed the rules (attributed, no side taken), but it puts the Sunni doubt in front of the reader on this verse. A one-question rewrite would move it to the Shia narrations' reading. Decided 2026-09-30: the user chose to leave it as is.
- The passages spell the seventh Imam "al-Kadhim" in surahs 9, 11, 20 and 43 and "al-Kazim" elsewhere; quizzes follow each passage's spelling. A passage fix, outside the quiz pipeline.
