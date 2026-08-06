# The Road Home - Learning Path for New Muslims (Design)

Date: 2026-08-06
Status: Approved (brainstorming session)

## Summary

A new "Learning Paths" category on the Journeys tab, launching with **The Road Home** - a guided, station-based curriculum for a brand-new revert to Islam, taught through the Shia school from day one with zero assumed knowledge. About 30 stations across 5 stages. Each station is a fixed-template lesson that cross-links into existing app content (verses, duas, deep dives, surah experiences, Foods, seasonal journeys), so the app's whole library becomes the journey's course material.

## Decisions made

| Question | Decision |
|---|---|
| Audience | Brand-new revert to Islam (not a Sunni-to-Shia track); zero assumed knowledge |
| Scope | Full curriculum, ~30 stations / 5 stages, a months-long companion |
| Progression | Guided path with soft locks: recommended order, one "Continue" card, everything visible and tappable |
| Station format | Fixed lesson template (same rhythm every station) |
| Premium | Stage 1 entirely free; Stages 2-5 premium (accent "Premium" capsule, veiled preview, no lock icons) |
| Naming | Shelf section: **Learning Paths**. Journey: **The Road Home** - "A path for new Muslims" |
| Architecture | Purpose-built typed Swift content (not JSON), mirroring deep-dive authoring |
| Languages | English first; `LocalizedText` slots so UR/AR drop in later |
| Reminder | Daily learning reminder notification, default ON at 5:00 PM, configurable in Settings |
| Artwork | Reuse the existing `RidaCover` asset (lamp in an arched window - a light left on for the one coming home); no new art generated |
| In-station resume | Stations track the furthest template block reached; reopening an in-progress station offers "Resume where you left off" |

## Concept

"Revert" is the design key: the person is not converting but returning. The path opens with fitra and the covenant of Alast (7:172, 30:30) and closes with the soul called home (89:27-30, "Return to your Lord well pleased"). Station vocabulary follows the road metaphor: stages of the road, stations along it.

## Curriculum

Stage and station titles are working names; final copy is authored at implementation. Links marked -> are the in-station cross-links; content ids are verified against catalogs at authoring time.

### Stage 1 - The Door (free)

| # | Station | Core idea | Cross-links |
|---|---|---|---|
| 1 | You Are Not New Here | Fitra; revert = return; the covenant | 7:172, 30:30 -> al-A'raf surah experience |
| 2 | One God | Tawhid | 112 (Ikhlas), 2:255 -> Ikhlas deep dive |
| 3 | The Messenger | Who Muhammad is | 33:21, 21:107 -> Prophetic Stories |
| 4 | The Book | What the Qur'an is, how to approach it | 17:9 -> Fatiha surah experience (also free) |
| 5 | The Family | Gentle Ahlul Bayt intro | 33:33, 42:23 |
| 6 | The Shahada (landmark) | Saying it, what it commits you to | 3:18; practice: say the shahada |

### Stage 2 - Standing Before God (premium begins)

| # | Station | Core idea | Cross-links |
|---|---|---|---|
| 7 | Wudu | Purification, step by step | 5:6 -> wudu dua |
| 8 | The Call and the Times | Adhan, prayer times, qibla | 4:103 |
| 9 | Your First Salah | Fajr, step by step | 29:45 -> Salah deep dive |
| 10 | The Words You Say | What the recitations mean | 1:1-7 -> Fatiha experience |
| 11 | Sujud and the Turbah | Why Shia prostrate on earth | 96:19 |
| 12 | When You Miss, When You Doubt | Qada, mercy, habit-building | 2:286, 39:53 -> comfort duas |

### Stage 3 - The Household

| # | Station | Core idea | Cross-links |
|---|---|---|---|
| 13 | Ghadir | The announcement | 5:67, 5:3 |
| 14 | Ali | The first Imam | 5:55 |
| 15 | Fatima | The lady of light | 108 -> Kawthar surah experience |
| 16 | The Twelve | The line of Imams | 4:59 |
| 17 | Karbala (landmark) | Husayn's stand | 2:154 -> Muharram journey |
| 18 | The Awaited One | The twelfth Imam | 21:105 |

### Stage 4 - A Life That Worships

| # | Station | Core idea | Cross-links |
|---|---|---|---|
| 19 | Halal on Your Plate | Food law basics | 2:168 -> Foods |
| 20 | The Fast | Ramadan | 2:183 -> Fasting verses, Ramadan journey |
| 21 | Money That Purifies | Khums, zakat, charity | 2:261, 8:41 -> al-Anfal surah experience |
| 22 | Following Knowledge | Taqlid, marja | 21:7, 9:122 |
| 23 | Modesty and Adab | Dress, conduct, akhlaq | 24:30-31, 25:63 |
| 24 | Your People | Community; telling your family | 49:10, 3:103 |

### Stage 5 - The Deep Roots

| # | Station | Core idea | Cross-links |
|---|---|---|---|
| 25 | Justice | Adl, why Shia name it a root | 21:47 |
| 26 | The Return | Ma'ad; death and resurrection | 2:156 |
| 27 | Talking to God | Dua as a way of life | 40:60, 2:186 -> Dua Kumayl, duas library |
| 28 | Ziyarat | Visiting the visited | -> Arbaeen journey, Ziyarat Ashura |
| 29 | Patience in the In-Between | Trials of a new Muslim | 2:153, 94:5-6 -> Sabr deep dive |
| 30 | The Road Ahead (landmark) | Closing; where to go next in the app | 89:27-30 |

Landmark stations (6, 17, 30) use the same template plus a fuller celebratory close - not separate deep-dive builds.

## Journeys tab presence and progression UX

- A fourth `JourneyShelf`, **"Learning Paths"**, placed first on the Journeys tab, holding one poster `ShelfCard` for The Road Home.
- **Artwork**: reuse the existing `RidaCover` asset (lamp burning in an arched stone window). It reads as "a light left on for the returning traveler" - the journey's exact metaphor - and is season-neutral. Alternatives considered and rejected: `ArbaeenCover` (literal road imagery but mourning-coded with black flags, and already the active Arbaeen poster on the same tab) and `HajjCover` (the House, but monumental rather than intimate, also an active poster on the same tab). `RidaCover`'s only current use is the unbuilt Rida deep dive's coming-soon card; when that dive ships, generate fresh Rida art then.
- Tapping opens the **path view**: header with progress ("14 of 30 stations"), a prominent **Continue** card for the next uncompleted station, then stages as titled groups of station rows.
- **Soft locks**: undone stations render dimmed but always tappable. No hard sequential locking.
- **Premium**: stations in Stages 2-5 show the accent "Premium" capsule (house rule: never a lock icon) and open a veiled preview (VeiledDayPreview pattern) leading to `PaywallView`.
- **Progress**: Codable struct -> UserDefaults, like the seasonal journey managers, but with no Hijri year reset (the path is not seasonal). Device-local, matching all other journeys.
- **Three station states**: not started / in progress / complete. A station becomes "in progress" the moment any block progress is recorded; "complete" only via the Mark complete button. In-progress rows show a half-filled ring instead of a checkmark, and the Continue card targets an in-progress station before the next unstarted one, with its subtitle naming the resume point ("Resume at 'In the Qur'an'").

## Station screen (fixed template)

Five blocks, in the app voice, on the standard adaptive background:

1. **The Heart of It** - 2-3 warm teaching paragraphs. Scales with `ReadingSettingsManager` (house rule).
2. **In the Qur'an** - verse cards; tap opens that verse via the `.navigateToVerse` route.
3. **Take It With You** - link cards to duas (with `DuaListenButton` on the dua screen), deep dives, surah experiences, Foods, journeys, and - where the station has a clear anchor surah - that surah's quiz. Quiz links are optional per station, assigned at authoring time (every surah has quiz data: `Data/quiz_1.json` ... `quiz_114.json`). Examples: One God -> Surah al-Ikhlas quiz, The Book -> Surah al-Fatiha quiz (free), Wudu -> Surah al-Ma'ida quiz, Fatima -> Surah al-Kawthar quiz. Presented via `QuizView(surah:onDismiss:)` full-screen cover (the `SurahDetailView` pattern), gated by the existing `PremiumManager.canAccessQuiz(surahNumber:)`.
4. **Try This Today** - one small concrete action.
5. **Mark station complete** - updates progress, advances the Continue point.

**Pick up where you left off**: because the template's blocks are fixed, they double as resume anchors. As the reader scrolls, the manager records the furthest block whose header has appeared (`blockProgress: [stationId: blockIndex]` in the progress struct - no fragile scroll offsets). Reopening an in-progress station shows a small "Resume - In the Qur'an" pill under the header; tapping it scrolls to that block. Reading a station never auto-completes it; only the button does.

## Architecture

- `Models/RevertPath.swift` - `RevertPath > PathStage > PathStation`; template section types; typed link enum:
  `enum StationLink { case verse(surah: Int, verse: Int), dua(id: String), deepDive(id: String), surahExperience(id: String), journey(id: String), quiz(surahNumber: Int), explore(ExploreDestination) }`
  Compile-checked links: a station can never point at nothing.
- `Content/RoadHomeStage1.swift` ... `RoadHomeStage5.swift` - typed content, one file per stage, `LocalizedText` fields (EN now, UR/AR later).
- `Services/RevertPathCatalog.swift` - descriptor registry mirroring `DeepDiveCatalog` (future paths join this shelf).
- `Services/RevertPathManager.swift` - progress (completed station ids, per-station `blockProgress` for in-station resume, continue point, completion %), UserDefaults persistence, no year reset.
- `Views/RevertPath/RoadHomeJourneyView.swift` (path view) and `RoadHomeStationView.swift` (template screen); shelf wiring in `JourneyHubView` per the established six-step recipe.
- `PremiumManager.canAccessRoadHomeStation(_:)` - free while the station's stage is 1; else premium. Follows `canAccessArbaeenStation`.
- Strings: section label + vocabulary in `JourneyStrings` (EN/UR/AR).
- What's New: entry in `WhatsNewCatalog.all` with EN/UR/AR copy and a new `WhatsNewDestination` case (routing handled in `WhatsNewCard.open()`), plus `DeepLinkRouter.pendingRevertStationId` + consume method.
- Dua links follow the Life Moments precedent (`duas.first { $0.id == id }` -> `DuaDetailView`); consider adding a `DuasManager.byId(_:)` helper.

## Daily learning reminder

- New fields on `NotificationPreferences`: `learningReminderEnabled` (default **true**) and `learningReminderTime` (default **5:00 PM**), decoded with `decodeIfPresent` so existing users' stored preferences pick up the defaults.
- Scheduling in `NotificationManager`, same pattern as Daily Verse: daily instances at the chosen time whose content teases the next uncompleted station ("The road continues - Station 7: Wudu"), refreshed on app-active and on station completion. Suppressed once the path is 100% complete.
- Tap deep-links into the next station via `DeepLinkRouter.pendingRevertStationId` - a Continue button on the lock screen.
- Settings: "Learning reminder" toggle + time picker beside the Daily Verse controls in `SettingsView`; copy in EN/UR/AR.
- iOS constraint: delivered only to users who granted notification permission (onboarding already asks). Default-on means on for everyone who has or later grants permission.

## Out of scope (explicitly)

- UR/AR content for the stations (slots exist; authored later, matching recent ships).
- Supabase sync of path progress (all journeys are device-local today).
- A second learning path (the shelf and catalog are built to take one later).
- Purpose-built per-station quiz content (stations link to the existing surah quizzes instead) and badges.

## Next steps

1. Visual mock of the path view and station screen (user-requested gate before implementation).
2. Implementation plan via writing-plans.
