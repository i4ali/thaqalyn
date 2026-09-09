# Understanding onboarding screen - Design

**Date:** 2026-09-09
**Status:** Approved in chat (lead claim, animation, placement), implemented the same day.

## Problem

The five-layer commentary is gone (v8.6 build 108 replaced it with passage
commentary, see `2026-09-05-passage-commentary-design.md`). The onboarding
flow lost its tafsir screen with it and nothing took its place, so a new user
meets Deep Dives and Inside the Surah before the core reader is ever named.
The rest of the app still speaks the old language in a few places: the unused
`WelcomeView` row ("Five layers of tafsir"), the Settings premium blurb ("every
dive, journey and layer"), paywall comments and the "All 114 surahs, English,
Urdu & Arabic" subtitle under the Understanding ladder, the purchase fallback
description, the "Foundation" badge on the onboarding quiz mock, and the
README.

## Decisions

1. **Lead claim: Understanding, the four parts.** The feature keeps its in-app
   name. The pitch is the shape of what you get after the verses: an essay,
   verse by verse notes, narrations of the Imams with their sources, and
   perspectives where Shia and Sunni readings differ. (Alternatives weighed:
   "every line has a source", "passages not verses". Sourcing is shown inside
   the animation rather than headlined.)
2. **Animation: the living reader.** A phone-shaped card styled like the real
   Understanding screen plays al-Fatihah's passage, "Praise and the straight
   path", through four beats while a rail beside it lights each part. Loops.
   Al-Fatihah is free, so the user meets exactly this content after onboarding.
3. **Placement: tag 2, right after Mission**, ahead of Deep Dive and Inside the
   Surah. The flow grows to 14 pages.

## The screen: `UnderstandingScreen`

Same skeleton as `DeepDiveScreen` and `SurahExperienceScreen`: shared
`OnboardingBackground`, `DeepDiveMotes`, left-aligned header, centred hero,
caption footer, staggered entrance.

- **Eyebrow** "Understanding". **Title** "Understand every passage".
- **Body** "Each surah is read in passages, a few verses that belong together.
  Read one, tap Understand, and the passage is explained in one plain essay,
  then verse by verse, with what the Imams said and where Shia and Sunni
  scholars differ. Every source is one tap away." (Rewritten after the first
  device look: the earlier colon-list sentence read as jargon and never said
  what a passage is.)
- **Hero.** Left: a 96pt column of four labels (Essay, Verse by verse, Narrations,
  Perspectives) against a vertical gold rail with four stops. Right: the reader
  card with a miniature of the real chrome (back circle, Listen capsule).
- **Loop, about 14 s, driven by one 0.35 s tick.** Beat lengths 13, 9, 10, 9
  ticks. Card content is keyed by beat and cross-fades with a vertical drift;
  lines inside a beat write in one every 0.7 s.
  1. *Essay.* Eyebrow "Al-Fatihah · 1 to 7", serif title, three real essay
     sentences, the third ending in the gold marker [1]. Two seconds in, a
     small source chip ("al-Mizan · Tabatabai · on 1 to 5") pops in under the
     marker: the tap-to-source moment, shown not claimed.
  2. *Verse by verse.* Divider label, numeral circle 4, heading "Master of the
     Day", the real note in serif italic ending in [12].
  3. *Narrations.* Gold rule, "Imam Ali ibn al-Husayn", the real narration
     ("Were all between east and west to die..."), then the line
     "Sourced · Al-Kafi · vol. 2, hadith 13".
  4. *Perspectives.* Divider label, the real opening two sentences ending in [3].
- **Rail.** Passed stops are filled gold, the active stop carries a breathing
  halo, the gold line fills from the first stop down to the active one.
- **Reduce Motion.** No timer. The card shows a compact static composite of
  the four parts and every stop is lit.
- **Footer** "Open any surah, read a passage, tap Understand".
- Content is hardcoded from `passages_1.json` so the screen is deterministic
  and independent of data loading.

## Copy retired with it

| Where | Was | Now |
|---|---|---|
| `WelcomeView` row (unreferenced view, kept in sync) | Five layers of tafsir / From foundation to Ahlul Bayt wisdom | Understanding, passage by passage / Essay, verse notes, narrations, perspectives |
| `SettingsView` premium blurb (2 places) | every dive, journey and layer | every dive, journey and passage |
| `PaywallView` ladder subtitle | All 114 surahs · English, Urdu & Arabic | Every passage, written from its sources |
| `PaywallView` unlock alert | All tafsir commentary is now available | Understanding is open for every passage |
| `PaywallView` doc comments | a locked tafsir layer, In-Depth | a locked Understanding |
| `PurchaseManager` fallback description | Unlock all 114 surahs with comprehensive tafsir commentary | Unlock Understanding for every passage, with journeys, deep dives and quizzes |
| `QuizFeatureScreen` mock badge | Foundation (layer stack icon) | al-Baqarah · 255 (book icon) |
| `README.md` | Tafsir Layers section | Passage commentary section |

Left alone: `MissionScreen` "Descend layer by layer" (Deep Dive language) and
`TafsirSourcesView`, which already leads with passage commentary.

## Progress screen follows

`ProgressTrackingScreen` (onboarding, "Track Your Progress") still showed a
verse card with a tick box and "Master the Quran, verse by verse". Reading is
counted by passage now (reaching the end of a passage marks it read), so its
mock became a slice of the real al-Baqarah passage list: "The call to worship"
read, "Adam and the angels" reading, "Children of Israel and the covenant"
unread. Two seconds in, the reading row flips to a checkmark, the subline count
goes 3 read to 4 read, and the home surah card appears with "4 of 40
passages". Subtitle "The Quran, passage by passage"; caption "Reach the end of
a passage and it is marked read. Your progress syncs across all your devices."

## Quizzes removed

The surah quiz feature had already lost its entry point with the old surah
screen; its files were still in the tree. Removed the same day: the
"Test Your Knowledge" onboarding screen (flow back to 13 pages),
`QuizView`, `QuizResultsView`, `QuizManager`, `QuizModels`, the 114
`quiz_N.json` files (1.2 MB), the quiz premium gate, and the paywall's
"Surah Quizzes" row. The Progress tab's quiz ring and "Quizzes Done" stat
went with them; the freed stat cell now shows "Passages Read" of the 556
ruku passages, and the seasonal ring moved inward to take the quiz ring's
slot. Per-passage quizzes are planned later as a fresh feature.

## Not in scope

No What's New entry (onboarding is not a feature; passages already have one).
No live data on the screen. No change to the paywall ladder rows.
