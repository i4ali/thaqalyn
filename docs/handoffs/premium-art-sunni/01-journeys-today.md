# 01 - Journey shelf posters + Today seasonal heroes

## A. Journey covers

One 1170x900 band image per journey in AlBayan's catalog (crop of that journey's 4:5 master). Attach it as a single optional `coverAssetName: String?` on the journey descriptor; that ONE field feeds all five surfaces below. `nil` = every surface falls back to its old art-less layout.

Subject guidance (adapt to AlBayan's actual journeys): Ramadan = crescent over a lantern-lit city; Hajj/Dhul-Hijjah = the empty Kaaba courtyard at night; Muharram (fast/fresh-start framing) = dawn imagery, NOT mourning; others from each journey's own theme. Composition rules from README section 4 apply to every one.

### A1. Hub shelf poster (the main showcase)

A horizontal shelf of tall poster cards:

- Card: **190 x 238 pt** (4:5), `RoundedRectangle(cornerRadius: 18, style: .continuous)`, clipped.
- Image: `.resizable().scaledToFill()` filling the card, `.clipped()`. The title always sits in the art's own dark top third.
- Top scrim (an overlay ON TOP of the art - posters use scrims, bands use masks):

```swift
LinearGradient(stops: [
    .init(color: .black.opacity(0.60), location: 0.0),
    .init(color: .black.opacity(0.26), location: 0.25),
    .init(color: .clear,               location: 0.5),
], startPoint: .top, endPoint: .bottom)
```

- Text overlay, top-leading, padding 14:
  - Eyebrow: a PREMIUM chip (9pt bold, tracking 1.4, accent color in an accent-tinted capsule with hairline stroke) or a small-caps status label (10pt bold, tracking 1.6): LIVE / "in N days" / ENDED / READY / SOON. Accent color when live/ready/premium, muted otherwise.
  - Title: serif 19pt semibold, white, shadow black 0.55 / blur 8 / y 2.
- Border: 1pt stroke, accent at 0.4 when available, theme stroke color otherwise.
- Coming-soon/unavailable: whole poster at **0.82 opacity** (deliberately lighter than the 0.72 text rows use - a coming-soon cover still has to be worth wanting).
- Card shadow: black 0.34, radius 22, y 10.
- No cover -> render the old icon-chip glass card. Never an empty poster.
- Renders in ALL themes (only the stroke color is theme-derived).

### A2. Poster zoom (navigation transition - polish, do last)

Tapping a shelf poster grows it into the full-screen journey/reader view:

- `matchedTransitionSource(id:in:)` on the poster + `.navigationTransition(.zoom(sourceID:in:))` on the presented full-screen cover (iOS 18 API).
- Scope it to the shelf tap path ONLY - the same item opened from an "All N" list or a deep link must present normally (a zoom with an off-screen source misbehaves).
- Fire navigation after a ~0.12s delay so the press-down squish plays first (press-feedback convention).

### A3. Journey header cover band (inside the journey screen)

Flagship theme only. The journey detail header gets the cover as a top-aligned band BEHIND the title + progress card, using exactly the shared masked band from `03-header-bands.md` (same mask stops). Two legibility adjustments when a cover is present:

- Heading-to-progress-card spacing widens 18 -> 30.
- The glass progress card gains a solid backing: rounded rect 20, `cardBacking` token (dark, ~0.45 alpha), so it reads over bright art.

### A4. Veiled locked-day preview

When a non-subscriber taps a locked journey day, do NOT jump to the paywall. Open a full-screen preview with the journey cover as a heavily veiled backdrop:

```swift
Image(cover)
    .resizable().scaledToFill()
    .frame(width: size.width, height: size.height)
    .scaleEffect(1.22)              // blur overscan - without it .blur vignettes at the edges
    .blur(radius: 44, opaque: true)
    .clipped()
    .overlay(Color.black.opacity(0.52))
    .ignoresSafeArea()
```

Over the veil: eyebrow, the day's theme + opening line, a short list of what waits inside (dua, N verses, reflection), a premium note, and the upgrade CTA -> paywall with this journey's cover as context. Always-dark screen regardless of theme; gold/cream text tokens. No lock glyph anywhere.

The reader veil in `02-content-covers.md` uses the identical recipe at 0.46 overlay - keep them visually identical apart from that alpha.

## B. Today seasonal heroes

One 1170x653 wide band per season + one everyday. Flagship theme only (legacy themes keep their flat gradient banner).

### B1. Season selection (Hijri month/day)

A pure function from the Islamic calendar date to an asset name. **Mirror AlBayan's own journey/announcement windows** so the hero and the journey shelf agree on what season it is. Thaqalayn's shape, adapted to a Sunni calendar (confirm the set with the user in Stage 1):

| Hijri date | Hero |
|---|---|
| Month 9 (Ramadan) | `TodayHeroRamadan` |
| Month 12 (Dhul-Hijjah) | `TodayHeroHajj` |
| Month 1, day 1-10 (Ashura fast / new year) | `TodayHeroMuharram` (dawn register, no mourning) |
| Everything else | `TodayHeroEveryday` |

Add rows only for seasons AlBayan actually observes. Anything Mawlid-related is a user decision, not yours.

### B2. Hero card rendering

The daily-verse card on the Today tab:

- Full-width card, min height 136 (grows with the verse), `RoundedRectangle(22, .continuous)`, clipped.
- Base color under the art: `heroBase` token. Image `.scaledToFill()`, `.clipped()`.
- Compose each band dark on the text side with the warm focal glow on the far side, then layer two scrims ON TOP (overlays, not masks):

```swift
// 1. Horizontal legibility gradient, leading (text side) -> trailing
LinearGradient(stops: [
    .init(color: .black.opacity(0.88), location: 0.00),
    .init(color: .black.opacity(0.60), location: 0.38),
    .init(color: .black.opacity(0.16), location: 0.64),
    .init(color: .clear,               location: 0.84),
], startPoint: .leading, endPoint: .trailing)

// 2. Bottom anchor: heroBase at 0.5 fading to clear by center
LinearGradient(colors: [heroBase.opacity(0.5), .clear], startPoint: .bottom, endPoint: .center)
```

- RTL (if AlBayan ships Urdu/Arabic UI): mirror the ART horizontally (`.scaleEffect(x: -1)`) so its dark side stays under the text; scrims and text follow layout direction normally.
- Content: sparkle icon + "A reminder for today" eyebrow in accent; verse headline serif 24pt semibold (arabic-script font 22 for Urdu), shadow black 0.55 / blur 10 / y 1; "Surah - s:v" source line at 0.72 opacity.
- Border 1pt accent at 0.14; shadow black 0.42 / radius 20 / y 10.
- Whole card tappable (opens the verse) with press-squish; long-press exposes share.
