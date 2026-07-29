# Premium art & conversion - remaining work

Backlog from the funnel audit of 2026-07-14. Research page: `docs/plans/2026-07-14-premium-art-funnel.html`.
Card-treatment mockup: `docs/plans/2026-07-14-cover-art-treatments.html`.

**Credits: 64 spent, ~656 left.** A 2K still is 2 credits (nano_banana_pro), a 5s 1080p loop is 10
(kling3_0_turbo), an 8s Seedance loop is 20-72. Stills are effectively free; video is the only real line.

---

## Shipped 2026-07-14 (all build-green, not committed)

- **15 cover images** (`assets/premium-art/covers/`) + 15 imagesets (1.93 MB, 3x slot). One per gated unit:
  8 Inside-the-Surah + 7 Deep Dives, including the 8 "Soon" ones.
- **Shelf posters** - `ShelfCard.posterFace()` in `JourneyShelf.swift`. Art fills the 190x238 card, title
  in the art's dark sky. Covers all three shelves, so the **five journey covers that were already in the
  bundle finally appear on the shelf that advertises them**.
- **List-row tiles** - shared `EmCoverTile` (EmeraldComponents.swift) replaces `EmIconChip` on
  `SurahExperienceCard` / `DeepDiveCard`.
- **Dive threshold** - `DeepDiveView.thresholdCover()`. The cover is the doorway; it dissolves into
  `DeepDiveBackground` over the first scroll.
- **Contextual paywall** - `PaywallContext` in PaywallView.swift. 19 trigger sites; the hero shows the art
  of the thing the user just reached for. Only `ContentView:736` (profile "Upgrade" row) stays generic,
  correctly - that user is browsing, not blocked.
- **The veil** - a locked dive now *opens*: threshold + orientation, then a veil beat naming every movement
  beneath it. `visibleSections` filters gated beats out of the view hierarchy, so the gate is structural,
  not a visual overlay.
- **Paywall copy fixes** - "Inside the Surah" added to the feature list (it was gated but never listed);
  Seasonal Journeys now names Arbaeen (it advertised 4 while 5 are gated).

---

## Shipped 2026-07-14 (round 2) - items 1, 2, 7, all build-green, not committed

- **Item 1 - Paywall motion.** `PaywallView.swift`: slow Ken Burns push on the hero art
  (`heroArt`, anchor matches the crop alignment, reduce-motion gated); entrance stagger cascading
  down the ladder + feature rows (`staggeredRow`, one continuous index); price counts up from zero
  on appear in the store's real currency (`CountUpPrice` is `Animatable`; new
  `PurchaseManager.getPriceComponents()` exposes the Decimal + `priceFormatStyle`). Plus the app's
  first `symbolEffect` - a variable-color shimmer on the "Gems / MOST LOVED" sparkles glyph.
- **Item 2 - Shared-element zoom.** Shelf poster -> descent, via `matchedTransitionSource` on
  `ShelfCard` + `.navigationTransition(.zoom)` on the three `fullScreenCover` destinations in
  `JourneyHubView`. Scoped to the shelf: `transitionID` rides on the presented wrappers and is set
  only on the `fromShelf` tap path, so "All N" lists and deep links present with the default
  transition (no off-screen source). iOS 18 zoom API; **worth a simulator check** - it is the one
  behaviour a green build cannot confirm.
- **Item 7 - Veil on journey days.** New shared `VeiledDayPreview.swift` (always dark, reuses
  `DeepDivePalette` so the app has one veil): shows the day's theme + its opening line (the
  `tafsirFocus`), then names what waits beneath (supplication, N verses, reflection) and opens the
  contextual paywall - never a lock. All 5 journeys (`Muharram/Ramadan/Hajj/Fatimiyya/Arbaeen`) now
  push it for a locked day instead of jumping to the paywall; Arbaeen labels units "Station N". New
  `dayVeil*` strings in `JourneyStrings` (EN/UR/AR). Note: preview -> paywall is a 3-deep modal
  stack (hub cover -> preview -> paywall); supported, but the other thing to eyeball in the sim.

---

## Shipped 2026-07-14 (round 3) - item 4, build-green, not committed

- **Item 4 - Explore art.** Cinematic emerald-night cover art on the Explore tab + all 7 detail screens
  (Life Moments, Daily Duas, Foods, Fasting, Prophetic Stories, Prophetic Parallels, Ahl al-Bayt). New
  shared `EmCoverBand` + `.emCoverHeaderBand(_:height:)` (and an `…IfEmerald` variant) in
  `EmeraldComponents.swift`, factored from the `EmJourneyHeader` cover treatment: top-bleeding, edge-fades
  into the emerald body, title set in the art's dark sky. The overview header is pulled full-width so the
  hero scrolls behind the status bar (`.ignoresSafeArea(edges: .top)`); the 7 detail screens attach the
  band to their fixed emerald header and hide the nav-bar background **in emerald only**
  (`toolbarBackground` gated on `isMidnightEmerald`), so the legacy themes are untouched. 8 new imagesets
  (~1.8 MB, 1170-wide JPGs). Art via Higgsfield `nano_banana_pro` (18 credits, incl. one Prophetic Stories
  regen to kill a white matte border). Band heights 280 (detail) / 440 (overview) - eyeball in the sim.

---

## Shipped 2026-07-14 (round 4) - item 5, build-green, not committed

- **Item 5 - Today hero.** The daily-reminder hero (`EmDailyReminderHero`, `TodayView.swift`) is no
  longer a flat gold-gradient block: it's a Hijri-seasonal cover-art band with the day's verse in cream
  serif over a left/bottom legibility scrim. New `ReminderSeason` enum picks the art from the current
  Islamic month/day (`IslamicCalendarManager`), windows mirroring `JourneyAnnouncements`: Ramadan (9),
  Muharram 1-10, Arbaeen (11 Muharram - 20 Safar), Fatimiyya (Jumada I, 8-15), Hajj/Dhul-Hijjah (12), and
  an everyday default for the rest of the year. 6 wide bands composed dark-on-the-text-side with the warm
  focal glow opposite; the art mirrors horizontally for Urdu (RTL) so the dark side stays under the text.
  6 new imagesets (~0.4 MB). Art via Higgsfield `nano_banana_pro` (12 credits). Emerald-only (the hero
  lives in `EmeraldTodayView`), so legacy themes are untouched.

---

## Shipped 2026-07-18 (Tier 1 - shipped art, new surfaces) - build-green, not committed

Zero new generations; every change reuses art already in the bundle. Mockups: `mockups/tier1-art/`.

- **Discovery carousel posters.** New shared `PosterCarouselCard` (Components/): full-bleed cover
  art, serif title over a left scrim, quiet gold "Explore" affordance, whole card tappable
  (EmPressStyle), art+scrim mirror for RTL (EmDailyReminderHero rule). All four cards
  (Duas/LifeMoments/PropheticStories/AhlulbaytQuran) are now thin wrappers over it, and all four
  are trilingual (three were English-only). Crop biased 26% up because covers are 4:5 dark-top.
- **Leaf detail cover bands.** All 7 leaf screens (DuaDetail, FoodDetail, LifeMomentDetail,
  StoryDetail, ParallelDetail, AhlulbaytEntryDetail, FastingCategoryDetail) now show their
  parent's `EmCoverBand` (height 300, emerald-gated, fixed behind the scroll) +
  `toolbarBackground(.hidden)` in emerald, so list -> detail keeps the art continuous.
- **Welcome screen.** Rebuilt around the shrine hero loop (`ShrineHeroVideoLayer`, 440pt top band,
  masked fade + title scrim), fixed emerald-night palette, gold CTA replaces the purple one,
  the two same-action auth buttons merged into one "Create Account or Sign In". Reduce-motion /
  missing-video falls back to `ShrineDovesLayer`.
- **Onboarding reuse.** SurahExperienceScreen: text-in-halo hero replaced by a fanned cover deck
  (Yusuf/Yasin/Rahman/Mulk covers) cross-fading on the existing 2.6s cycle.
  SeasonalFeaturesScreen: spotlight card now crowned by the season's `TodayHero*` band
  (132pt, masked fade); big glyph block dropped, NEXT UP pill got a dark backing.

Sim eyeball list: leaf-band scroll behavior (band is fixed, content scrolls over the fade),
carousel poster crop per card, Welcome video start/fallback, deck cross-fade rhythm.

## Shipped 2026-07-18 (Tier 2) - build-green, not committed

4 credits of new art (nano_banana_pro 2K x2 concepts + celebration plate; balance ~545). Mockups: `mockups/tier2-art/`.

- **Qur'an tab hero.** New `QuranTabCover` imageset ("book of light" - open mushaf whose pages are pure
  light, no script so no AI-garbled Arabic; user picked it over the closed-mushaf concept, both masters in
  `assets/premium-art/quran-tab/`). `EmeraldHomeView` wears it via `EmCoverBand` (h340,
  `.background(alignment: .top)`), heading dropped 78pt into the art's sky, greeting icons got a dark
  chip backing. The flagship tab now opens on art like every other main tab.
- **Celebration moments.** New `CelebrationDoves` imageset (doves rising out of golden light, 9:16) +
  shared `CelebrationBackdrop` / `CelebrationConfetti` (Components/CelebrationBackdrop.swift - the plate
  with a 4-stop legibility scrim, and BadgeAwardView's theme-aware `ConfettiPiece` rain packaged for
  full-screen use). Wired: crossword `solvedOverlay`, challenge `completionLayer` (backdrop emerald-only,
  confetti both themes), quiz results (backdrop when `isGood` + emerald; the rainbow-circle
  `QuizConfettiPiece` deleted in favour of the shared piece).
- **Settings premium row.** `emeraldPremiumSection` at the top of Settings - serif title, one-line pitch,
  gradient PREMIUM chip (never a lock), opens `PaywallView()`; premium users see a quiet stroked
  "ACTIVE" chip and the row is disabled. Settings finally has a road to the paywall.

**Dropped by user decision (2026-07-18): the onboarding upsell wall (old item 3). Do not re-propose.**

Sim eyeball list: band crop on the Qur'an tab (title must sit in the dark sky; bias the crop if the glow
rides up), celebration scrim vs gold CTA, confetti over the quiz card.

## Remaining

### ~~1. Motion on the paywall~~ - DONE (round 2)

The paywall is still **completely motionless**: no transition, no reveal, no parallax, nothing but the
button-press squish. It is the one screen that asks for money.

**The originally-budgeted 20-credit ambient loop is now the wrong answer.** That was scoped before the hero
became contextual. There are now ~20 possible hero images and you cannot shoot 20 loops; a loop would only
serve the single context-free entry, which is the least important of the nineteen.

Do this instead, in SwiftUI, for zero credits:
- A slow Ken Burns drift / scale on the still hero (serves all 20 heroes).
- Entrance stagger on the layer ladder and feature rows.
- The price counting up on appear.

`PaywallView.swift:heroArt` (~:170) and `featureRows` (~:310).

### ~~2. Shared-element transitions~~ - DONE (round 2)

`matchedGeometryEffect` is used **zero times** in the app. Now that the covers exist, a shared-element
transition from shelf poster -> dive threshold is exactly what makes the art feel expensive rather than
pasted in. Same for `symbolEffect`, unused across ~150 SF Symbols.

### 3. Onboarding - no upsell at all

13 screens (`OnboardingFlowView.swift:17`), 9 of them bare gradient + SF Symbol, ending on an account form.
**Nobody is ever asked to pay during onboarding.** Now nearly free: a closing "here is everything inside"
wall of the 15 covers, then the paywall.

Art for the 9 bare screens: ~18 credits.

### ~~4. Explore tab - the most inert screen in the app~~ - DONE (round 3)

`ExploreView.swift` emerald body: **0 art, 0 gradients, 0 animations.** Seven detail screens behind it
(Duas, Foods, LifeMoments, PropheticStories, PropheticParallels, AhlulbaytQuran, FastingVerses), all equally
bare. The `EmJourneyHeader.coverAssetName` infra already exists - this is one template plus seven images.

~14 credits. Header slot is free above the rows at `ExploreView.swift:367-381`.

### ~~5. Today tab - the hero is a gradient rectangle~~ - DONE (round 4)

`EmDailyReminderHero` (`TodayView.swift:863-924`) is a gold gradient block with two decorative circles. It
is the most-visited screen in the app. A seasonal art band that changes with the Hijri calendar would make
the daily return feel expensive every single day.

~12 credits (6 seasonal bands).

### 6. Celebration moments - retention, and free acquisition

There is **no celebration for a streak, a journey day, a finished journey, or a solved crossword.** The only
one in the app is `BadgeAwardView`, whose confetti + halo machinery (`:349-410`) is already written and
reusable. A beautiful completion moment is the thing people screenshot.

Mechanic: free. Art: ~6 credits.

### ~~7. Extend the veil to journey days~~ - DONE (round 2)

The veil currently covers dives only. A locked journey day still goes straight to the (now contextual)
paywall. Journey days have a different structure (`MuharramDayDetailView` et al), so this is its own job:
show the day's theme and opening line, then veil.

### 8. Outside the binary

- **There is no App Store preview video.** Highest-leverage conversion asset you do not have. The shrine
  loop plus real screen recordings gets you one. ~40 credits for plates.
- **ASO screenshot refresh** with the new art (phase E). See `AppStore_Screenshots/ASO/`.

### 9. Non-art issues the audit turned up

These are accuracy/hygiene, not art, but two of them are on the screen that takes money:

- **"Listen Mode" is advertised on the paywall but is not actually gated.** `TafsirReader` / `TTSVoiceManager`
  have zero premium checks; a free user on al-Fatiha layers 1-2 gets it. Either gate it or drop the claim.
- **The paywall anchor line hardcodes USD** ("Libraries this deep run ~~$39.99/yr~~", `PaywallView.swift:~200`)
  while the real price is localized via `displayPrice`. Reads oddly on a non-USD store.
- **Dead bookmark gate.** `SupabaseService.swift:532` writes `bookmarkLimit: isPremium ? 999 : 2`, but
  `BookmarkManager.swift:193` hard-codes `10` for everyone. The 2-vs-999 value is never read back.
- **Dead reciter gate.** `PremiumManager.canAccessPremiumReciter()` always returns `true`;
  `getPremiumReciters()` returns `[]`.
- **`IslamicGeometricPattern`** (231 lines) has no call sites. **`darkScreenAura()`** is a no-op on the ~50
  emerald screens that call it (`DarkScreenAura.swift:20-21`). Some of the app's flatness is a wiring bug,
  not an art gap.

---

## Rules learned the hard way - do not re-derive these

**Every cover is composed 4:5, dark and uncluttered in the top third, subject low.** This is not decoration;
three separate design decisions depend on it, and any new cover that breaks it breaks them:

1. **Shelf poster (treatment A)** works *because* the title sits in the art's own dark sky. A bottom scrim
   (B) lands on the subject - it covered Sabr's olive tree and Arbaeen's road. A top band crop (C) shows
   only empty sky.
2. **Paywall hero must be `.top`-aligned**, not SwiftUI's default centre. The covers overflow the 348pt band
   hugely, and a centre crop rides the bright subject (a lit arch, a lantern) straight up under the 40pt
   headline.
3. **The dive threshold needs a heavy scrim, not a ghosted image.** Ghosting the art to 40% was mocked and
   is worse on *both* counts: with no scrim the bright gold light sources punch through the text, and the art
   washes out at the same time. Full art + heavy scrim reads better and looks better.

**Blur needs overscan.** `.blur()` samples past its own bounds, so a blurred full-bleed image vignettes at
every edge without a `.scaleEffect(1.22)` first (see `veiledArt`).

**House rules:** Premium chip, never a lock glyph. No em dashes. English content uses plain spelling, no
transliteration diacritics. Reading content must scale with `ReadingSettingsManager.shared`.

**Off-season review:** flip `JourneyCatalog.debugUnlockAllJourneys` to see the Sacred Seasons posters.
