# Passage hub (2026-09-13)

The passage flow was redesigned around a hub screen ("Direction B" of the
2026-09-13 design canvas, chosen over a linear "one next step" bar).

## Flow

```
Surah list  ->  Passage hub  ->  Read the verses     (Finish reading  -> back to hub)
    ring        title, first    ->  Understand          (Finish          -> back to hub)
    per row     verse, three    ->  Test yourself       (Back to passage -> back to hub)
                stages, bar     ->  Next passage        (next hub)
```

- `SurahPassagesView` rows push `PassageHubView`. Each row shows a ring of one
  arc per stage the passage offers, gold for each stage done, plus the best
  quiz score, the bookmark heart and "reading". The Quiz and Read/Unread
  swipe actions are gone (the hub and the reader carry them); only the Save
  swipe stays, without full swipe.
- `PassageHubView` shows the eyebrow, title, a ring with "n of m", the opening
  verse (or a "Passage complete" seal once every stage is done), the stage rows
  on a path, a quiet "Next passage" link while incomplete, and a pinned bottom
  bar with the next step: Start reading / Understand this passage / Test
  yourself / Next passage / Back to the surah. Gated stages show the PREMIUM
  capsule and open the paywall.
- `PassageView` ends with one control, "Finish reading" (the journey toggle):
  marks the passage read and pops back after a beat; green "Marked as read"
  once read, tap to unmark. The Understand card, Test yourself button, pinned
  Understand bar and Next passage card are gone; the next passage is reached
  from the hub (2026-09-13 device pass: a Next passage link under Finish
  reading was tried and removed).
- `UnderstandingView` ends with "Finish" (same toggle): marks the passage
  understood and pops back; green "Understood" once done, tap to unmark.
- `QuizView` is unchanged; its Back to passage now pops to the hub.

## Stages and state

- `PassageStages` (Models) computes the available stages for a passage:
  Read always, Understand when the commentary has shipped, Test when the quiz
  has. `doneCount`, `total`, `next`, `isComplete` feed the ring and the bar.
- Read = every verse read (`ProgressManager`, synced, unchanged).
- Understood = `PassageStageStore` (Services), a local UserDefaults set of
  passage ids, deliberately not synced, like `QuizResultsStore` (see the
  quiz plan's decision 4). Tested = `QuizResultsStore` best score.

## Deep links

- Verse links (Continue Reading, bookmarks, search, notifications, go to
  verse) still open the reader at the verse.
- `thaqalayn://passage?surah=S&index=I` now opens the passage's hub: the
  NavigateToVerse notification carries `passage`, `PendingDeepLink` carries
  `passageIndex`, and it is threaded HomeView -> EmeraldHomeView ->
  SurahDetailView -> SurahPassagesView, which pushes the hub. Every What's
  New `.passage` card therefore lands on the hub.

## Deliberately not done

- No cloud sync for "understood" (local, same reasoning as quiz scores).
- Passages without commentary show the Understand row disabled ("Coming in
  an update") and no Test row; such a passage is complete once read.
- The reader opened from a verse link pops to the surah list on Finish
  reading, not to a hub, since no hub is beneath it.
