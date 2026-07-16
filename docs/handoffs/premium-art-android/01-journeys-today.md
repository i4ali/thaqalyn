# 01 - Journey shelf posters + Today seasonal heroes

## A. Journey covers

5 images in `assets/journeys/`, all 1170x900 px: `ramadan_cover.jpg`, `hajj_cover.jpg`, `muharram_cover.jpg`, `fatimiyya_cover.jpg`, `arbaeen_cover.jpg`.

One cover per journey is attached in the journey catalog (iOS: `JourneyCatalog.swift`, `coverAssetName` per descriptor). That SINGLE field feeds five surfaces: the hub shelf poster, the "All journeys" list tile, the journey header band, the veiled locked-day preview, and the paywall hero (when the paywall opens from that journey). Wire it the same way on Android: one cover reference on the journey model, consumed everywhere.

### A1. Hub shelf poster (the main showcase)

iOS: `JourneyShelf.swift` `ShelfCard.posterFace` (:96-157). A horizontal shelf of tall poster cards:

- Card: **190 x 238 dp** (4:5), `RoundedRectangle(18)` continuous corners, clipped.
- Image: `ContentScale.Crop` filling the card. Every cover is composed 4:5 with a deliberately dark top third; the title always sits in that dark "sky".
- Top scrim (this one IS an overlay, unlike the header bands): vertical `LinearGradient` from the TOP edge to the CENTER of the card: black 0.60 at top, black 0.26 mid, transparent at center. It never reaches the subject in the lower half.
- Text overlay, top-leading, padding 14dp:
  - Eyebrow: either a PREMIUM chip (9sp bold, tracking 1.4, accent color, accent-tinted capsule with hairline stroke) or a small-caps status label (10sp bold, tracking 1.6): LIVE / "in N days" / ENDED / READY / SOON. Accent color when live/ready/premium, muted otherwise.
  - Title: serif 19sp semibold, white, text shadow black 0.55, blur 8, y-offset 2.
- Border: 1dp stroke, accent color at 0.4 alpha when the journey is available, theme stroke color otherwise.
- Unavailable/coming-soon: whole poster at **0.82 alpha** (lighter dimming than text rows on purpose).
- Card shadow: black 0.34, radius 22, y-offset 10.
- Fallback when a journey has no cover: the card renders the old icon-chip glass layout instead. Never show a broken/empty poster.

Theme: the shelf poster renders in BOTH themes (art, scrim, and white title are theme-independent; only stroke color comes from the theme).

### A2. Poster zoom (navigation transition)

The "poster zoom" is a shared-element navigation transition, not an idle animation: tapping a shelf poster grows the poster into the full-screen journey/descent view (iOS `matchedTransitionSource` + `navigationTransition(.zoom)`).

- Enabled ONLY when opened from the shelf. The same item opened from an "All N" list or a deep link opens with a normal transition.
- The tap fires after a ~0.12 s delay so the press-down squish plays before the cover slides up (house press-feedback convention).
- Compose equivalent: shared-element / container-transform (e.g. `SharedTransitionLayout` with the poster image as the shared element, keyed on the journey id), gated on "came from shelf". Treat this as nice-to-have polish; ship the art first.

### A3. Journey header cover band (inside the journey screen)

Midnight Emerald theme ONLY. The journey detail header (title + progress card) gets the journey's cover as a top-aligned background band, using exactly the same masked-fade treatment as the Explore covers - see `03-explore-covers.md` for the `CoverHeaderBand` composable and mask stops (0.92 / 1.0 / 1.0 / 0.0 at offsets 0 / 0.18 / 0.62 / 1.0).

Two legibility adjustments when the cover is present (iOS `EmJourneyHeader`, `EmeraldComponents.swift:440-544`):
- Heading-to-progress-card spacing widens 18dp -> 30dp.
- The glass progress card gets a solid backing: rounded rect 20dp filled `#06120E` at 0.45 alpha, so it stays readable over bright art.

The standard/legacy theme header renders no cover art.

### A4. Veiled locked-day preview

When a non-subscriber taps a locked journey day, a full-screen preview opens with the journey cover as a heavily veiled backdrop (iOS `VeiledDayPreview.swift:199-216`):

- Cover image full-screen, `ContentScale.Crop`, scaled up **1.22x** (overscan so the blur never samples the edges), **blur radius 44** (opaque), clipped, then a plain black overlay at **0.52 alpha**.
- Over the veil: eyebrow, the day's theme/opening line, a short list of what waits inside (dua, N verses, reflection), a premium note, and the upgrade CTA.
- This screen is always dark regardless of app theme. Gold/cream accent palette (see README palette table).
- Compose note: `Modifier.blur(44.dp)` needs API 31+. Below that, fall back to a pre-blurred bitmap (render once with `RenderEffect`/RenderScript alternative) or just the black overlay at a heavier ~0.7 alpha; do not skip the veil entirely.

The Deep Dive descent uses the same veil recipe with a lighter 0.46 overlay - see `02-deepdive-covers.md`. Keep the two visually identical apart from that alpha.

## B. Today seasonal heroes

6 images in `assets/today/`, all 1170x653 px (wide banner): `ramadan_hero.jpg`, `hajj_hero.jpg`, `muharram_hero.jpg`, `fatimiyya_hero.jpg`, `arbaeen_hero.jpg`, `everyday_hero.jpg`.

Midnight Emerald theme ONLY. The standard theme keeps its flat accent-gradient "Daily Reminder" banner with no art.

### B1. Season selection (Hijri month/day)

iOS: `TodayView.swift:862-891`, `ReminderSeason.current(month:day:)` using the Islamic calendar:

| Hijri date | Hero |
|---|---|
| Month 9 (Ramadan) | `ramadan_hero` |
| Month 12 (Dhu al-Hijja) | `hajj_hero` |
| Month 1, day 1-10 | `muharram_hero` |
| Month 1, day 11+ | `arbaeen_hero` |
| Month 2, day 1-20 | `arbaeen_hero` |
| Month 5, day 8-15 | `fatimiyya_hero` |
| Everything else | `everyday_hero` |

### B2. Hero card rendering

iOS: `EmDailyReminderHero`, `TodayView.swift:895-987`. The daily-verse card on the Today tab:

- Full-width card, min height 136dp (grows with the verse text), `RoundedRectangle(22)` continuous corners, clipped.
- Base color under the art: `#06110D`. Image `ContentScale.Crop` filling the card.
- Two scrims layered OVER the art (overlays, not masks):
  1. Horizontal legibility gradient, start (text side) to end: black 0.88 at 0.0, 0.60 at 0.38, 0.16 at 0.64, 0.00 at 0.84. Darkens the text side, leaves the warm focal glow on the far side.
  2. Bottom gradient: `#06110D` at 0.5 alpha at the bottom fading to clear by center.
- RTL: for Urdu (RTL) the ART is mirrored horizontally (scaleX = -1) so its dark side stays under the text; the scrims and text follow layout direction as normal.
- Content on top: sparkle icon + "A reminder for today" eyebrow in bright accent; the verse headline serif 24sp semibold (Urdu: arabic-script font 22sp), primary text color, shadow black 0.55 blur 10 y 1; a "Surah - s:v" source line at 0.72 alpha.
- Border: 1dp accent at 0.14 alpha. Shadow: black 0.42, radius 20, y-offset 10.
- The whole card is tappable (opens the verse) with a press-squish, and long-press exposes share.
