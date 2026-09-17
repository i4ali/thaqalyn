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
