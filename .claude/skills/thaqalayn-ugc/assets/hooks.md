# Hooks for the Thaqalayn presenter

Pattern (from the 2026-09-16 trend pull, 295 videos across TikTok and Instagram in the Quran-app vertical): a claim or confession, a specific number, the result, then Thaqalayn named once at the end as the lead-in to the demo. 53-63 words each, so 12-15 s per take. Comma-join sentences where he should not pause; the model treats a period as permission to stop for half a second.

What the competitors do: Quranify (1-2.5M views per clip) runs a faceless "confession then reveal" format ("Just scroll if you're not Muslim", "Muslims please don't hate me for this", then "I made this Quran app for you"). Lumo (526k) and Ali Explains Deen (182k in 6 days) run the talking-head format this presenter uses: a fear or curiosity hook, a sincere 40-60 s reflection, the app named once near the end. Nobody does either format for a Shia audience. Full table and sources: `~/ugc/thaqalayn/hooks.md`.

Every claim must stay inside what the app ships: passage commentary with Ahlul Bayt narrations and a five-question quiz for surahs 1 to 14 (Fatiha through Ibrahim), duas (Kumayl, Tawassul, Ziyarat Ashura, Nudba, Ahd, Iftitah) with word-by-word recitation, Muharram, Ramadan, Fatimiyya, Hajj and Arbaeen journeys, Deep Dives, streaks, rings and badges. Check `Thaqalayn/Thaqalayn/Data/passages_*.json` before claiming a surah has passages.

## Status

| # | Angle | Status |
|---|---|---|
| H1 | confession + number | unused |
| H2 | "don't hate me" (Quranify's best hook, aimed at our audience) | unused |
| H3 | two weighty things | **final assembled 2026-09-16**: take 1 approved ("it's perfect"), captioned, two demo screen recordings cut to 5 segments (24.3 s, the quiz recorded separately as the closing screen) with a Seedance audio-only voiceover in Mehdi's voice (10 s at 480p, $1.19), joined to 39.4 s `H3_final.mp4`. Voiceover fix for "Sunni" (last two lines re-recorded as a 4 s take, $0.47). Total $5.66. Files: `~/ugc/thaqalayn/takes/H3/` |
| H4 | Dua Kumayl | unused |
| H5 | quiz numbers | unused |
| H6 | doom-scroll swap | unused |
| H7 | Muharram journey | unused |
| H8 | the Shia gap | unused |
| H9 | Fatiha challenge | unused |
| H10 | dad | unused |

Update this table after every approved take: date, cost, and where the files are.

## Scripts

| # | Script | Words | Take |
|---|---|---|---|
| H1 | I read the Quran every Ramadan for twelve years and could not tell you what a single passage actually meant. Not one. Then I found an app that breaks each passage down with the actual narrations from the Ahlul Bayt, and then quizzes you on it. Five questions. I failed my first one. It's called Thaqalayn, here's what it looks like. | 60 | 15 s |
| H2 | Shia Muslims, please don't hate me for this. I stopped opening my physical Quran. Because this app recites the surah to me, shows the translation, and then gives me the tafsir from our own scholars, not somebody else's. Forty surahs in one month, and I actually remember them. It's called Thaqalayn, let me show you. | 56 | 14 s |
| H3 | The Prophet said he was leaving us two weighty things, the Quran and his family, and that they would never separate, so why does every Quran app I've tried explain the Quran with everything except the words of his family? This one doesn't, every passage comes with narrations from the Ahlul Bayt, sources shown, it's called Thaqalayn, look at this. | 60 | 15 s |
| H4 | I've been reciting Dua Kumayl every Thursday night for years and I only just understood what I was saying. This app plays the recitation and highlights every word as it's read, Arabic, transliteration and translation, line by line. I cried at a line I had said a hundred times. It's called Thaqalayn, let me show you. | 58 | 15 s |
| H5 | I answered two hundred Quran questions this month and got sixty-one wrong. Every wrong answer showed me why, and jumped me back to the exact line I misread. That's the point. Nobody tests you after you read, so nothing sticks. This app does. It's called Thaqalayn, here's how it works. | 53 | 13 s |
| H6 | I replaced the first five minutes of doom scrolling every morning with this. It opens on one verse, one dua and one short reflection for the day, and it tracks my streak like a fitness app. Forty-one days today. Small thing, but it's the most consistent I've ever been with the Quran. It's called Thaqalayn, look. | 58 | 15 s |
| H7 | This Muharram was different for me. Instead of just crying through the majalis, I did a ten-day guided journey: one event, one dua, one reflection per day, read or just listen. By day three I understood things about Karbala I'd heard my whole life and never actually got. The app is Thaqalayn, here it is. | 58 | 15 s |
| H8 | Every Quran app I downloaded explained the verses about the Prophet's family as if they were about someone else. I'm not exaggerating. So I went looking for one built on the Quran and the Ahlul Bayt together, with the sources on screen. Took me a year to find it. It's called Thaqalayn, and this is what a passage looks like. | 62 | 15 s |
| H9 | Bet you can't tell me what Surah Al-Fatiha actually means. You've recited it ten times a day your whole life. I couldn't either. This app walks through it line by line with narrations from the Imams, then gives you five questions. I got three out of five on the surah I know best. It's called Thaqalayn. | 58 | 15 s |
| H10 | My dad memorised half the Quran and still asks me what the verses mean. So I showed him this. Recitation, translation, then tafsir from our scholars on every passage, and it reads it all aloud to you. He's done twelve surahs in two weeks and now he sends me screenshots. It's called Thaqalayn, here's what he sees. | 60 | 15 s |

H3 is the comma-joined version that was actually run. Before running any other hook, comma-join its sentences the same way (keep one question mark if there is one) and show the user the final text.

## Header lines used

| Hook | Header (two lines, split on `\|`) |
|---|---|
| H3 | `every Quran app\|got this wrong 😬📖` (same header on hook and demo, the user's choice) |

Header style: two short lines, a claim or a tease, one or two emoji on the second line, no app name. The hook header carries over the demo unchanged (user decision on H3; a payoff-style demo header was tried and reverted). Captions: 1-4 words per line, broken on sense, written against the transcript the analysis printed, every transcript word covered.

## Demo clip plan per hook

| Hook | Passage to record | Shot list (about 18 s) | Voiceover (approved wording) |
|---|---|---|---|
| H3 | Surah al-Ma'idah, passage 10 "Proclaim what was revealed" (5:67-77); backup passage 8 (5:51-56) | verse 67 open 0-3 s; scroll to the 5:67 narration, hold 3 s; tap the source, sheet with book and page, hold 2 s; swipe to Perspectives (Shia and Sunni); quiz: record the Test yourself screen separately (overview, tap, Question 1 of 5) so the last voiceover line lands on it | This is the passage "Proclaim what was revealed" from Surah al-Ma'idah. Here are the narrations on it, in English. Here's the source, book and page. Shia and Sunni readings side by side, then five questions before you move on. (39 words, about 10 s) |

Recording brief and voiceover placement are now produced by `scripts/episode.py plan` from the episode's pack.json (one voiceover sentence per shot; the assembler holds a screen longer if its sentence needs it). The H3 pack at `~/ugc/thaqalayn/episodes/H3/pack.json` is the worked example: five shots, the first four cut from one continuous recording by start/end seconds, the quiz from a second recording.

Pronunciation: Seedance said "Sunni" as "Sunnah" on the first read. Fix that worked: a prompt line `The word Sunni is pronounced "SOON-nee", two syllables, rhyming with "moony", never "sunnah".` Keep the Thaqalayn line too. Scribe hearing the right word is the check.

## B-roll screen guide (what to put in `shots` for each kind of hook)

The shots must show the thing the hook promises, in the order the voiceover names it, ending on an action. Passages exist for surahs 1 to 14 only.

| Hook promises | Record these screens, in order | Notes |
|---|---|---|
| narrations from the Ahlul Bayt, sources shown (H1, H3, H8, H9, H10) | passage list and title; a narration held still; tap its source (sheet with book and page); Perspectives; Test yourself question 1 | Strongest passage: Surah al-Ma'idah passage 10 "Proclaim what was revealed" (5:67-77), the Ghadir narration from Imam al-Baqir; backup passage 8 (5:51-56) on verse 55. For H9 use Surah al-Fatiha passage 1. |
| recitation, translation, then tafsir (H2) | surah page with Arabic and translation; tap Listen and let the recitation play a line; scroll to Understanding; Test yourself | The recitation audio is ignored in assembly unless the pack is set to keep it. |
| a dua understood word by word (H4) | Duas list; Dua Kumayl open; tap Listen so the word-by-word highlight moves; one translated line held still | Show the highlight actually moving; it is the whole point of the hook. |
| the quiz and jumping back to the line (H5) | Test yourself question; pick a wrong answer; the explanation with "see why"; the jump back to the passage line | Ends on the passage line, not the quiz, since the hook is about the jump. |
| daily habit, streaks, rings (H6) | Today tab on open (verse, dua, reflection); progress rings; a streak or badge | Record in the morning so the Today tab shows a fresh day. |
| a journey (H7 Muharram; Ramadan; Fatimiyya; Hajj; Arbaeen) | Journeys tab; the journey cover; a day open (event, dua, reflection); tap Listen | Muharram journey for H7. |

One voiceover sentence per screen, so five screens means five sentences. Hold each screen 3-4 s; the assembler extends a screen if its sentence runs longer.

## Posting copy

Sound: original audio only (35 of the top 40 videos in the pull, and 23 of the 24 studied, ran on their own audio). No music baked in; if a bed is ever wanted, a vocals-only nasheed from TikTok's library at posting time, demo section only.

Hashtags: the winners use few. Lumo used 4, Quranify 2 plus its own brand tag. Frequency in the pull: #islam and #quran on 77 videos each, #muslim 67, #fyp 53, #muslimtiktok 50, #shia 40 (37M views, the highest reach per tag), #ahlulbayt 23, #tafsir 16, #islamicapp 14, #quranapp 13.

| Hook | Caption | Hashtags |
|---|---|---|
| H3 | two weighty things, never apart. the app is Thaqalayn (link in bio) | #shia #ahlulbayt #quran #tafsir #muslimtiktok #islam #quranapp #thaqalayn |

Rules: 6 to 8 tags. Always #shia and #ahlulbayt (the audience), #quran and #islam (reach), one niche tag that matches the hook (#tafsir, #dua, #muharram, #ramadan), #quranapp or #islamicapp (discovery), and the brand tag #thaqalayn. Skip #fyp and #foryoupage; they add nothing the algorithm does not already do. Lowercase caption in the persona's voice, one line, app named once, "link in bio".
