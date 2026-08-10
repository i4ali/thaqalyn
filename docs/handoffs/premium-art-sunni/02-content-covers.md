# 02 - Covers for gated content units

One 1170x1463 (4:5) cover per gated content unit in AlBayan's catalog - deep dives, surah experiences, or whatever AlBayan's equivalents are - **including every coming-soon entry**. The art is what turns the roadmap into something a lifetime purchase is buying into; a coming-soon row shows its art dimmed, never hidden.

As with journeys: ONE `coverAssetName` on the catalog descriptor feeds shelf poster, list tile, reader threshold, reader veil, and paywall context.

Subject guidance: each unit's own content picks the subject (Thaqalayn examples, all sect-neutral: Yusuf = the well under starlight; al-Mulk = the night sky as dominion; Sabr = the olive tree; Shukr = overflowing abundance). Research the unit's actual theme, pick one concrete symbol or place, apply the README composition rules. If a unit is free-flagship (Thaqalayn's al-Fatiha), it still gets a cover - the art system is about premium *feel*, not only gating.

## Where the covers render

### 1. Hub shelf posters

Reuse the exact shared poster component from `01-journeys-today.md` A1 (190x238, radius 18, top scrim, serif title, PREMIUM chip, 0.82 coming-soon dim, poster-zoom transition). Do not build a second poster.

### 2. List rows - mini poster tile

A small shared tile replaces the old icon chip on list cards:

- **54 x 68 pt** (4:5), `RoundedRectangle(12, .continuous)`, `.scaledToFill()`, `.clipped()`, 1pt theme stroke.
- Coming-soon: tile at 0.7 opacity AND the row card at 0.72, with a "Soon" outline pill.
- Premium-gated available entries: PREMIUM chip (accent capsule). Never a lock icon.
- No cover -> the old icon chip. Renders in all themes.

### 3. Reader threshold (if AlBayan has an immersive full-screen reader)

The always-dark reader opens on the cover as a "doorway" behind the opening beat, over `thresholdBase`:

- Full-screen `.scaledToFill()`, `.clipped()`.
- Two overlays ON TOP of the art (scrim, not mask), deliberately heavy - the opening beat lays a large gold title mid-frame and every cover has a bright light source:

```swift
// 1. Vertical wash
LinearGradient(stops: [
    .init(color: .black.opacity(0.50), location: 0.00),
    .init(color: .black.opacity(0.66), location: 0.34),
    .init(color: .black.opacity(0.74), location: 0.62),
    .init(color: .black.opacity(0.60), location: 1.00),
], startPoint: .top, endPoint: .bottom)

// 2. Radial vignette: clear until 0.32 of radius, black 0.55 at edge,
//    radius = max(width, height) * 0.62
```

Tested and rejected alternative: ghosting the art to 40% opacity instead of scrimming. It is worse on BOTH counts - bright areas still punch through the text AND the art washes out. Full art + heavy scrim.

- Scroll-linked dissolve into the reader's procedural background: `coverOpacity = 1 - min(pagesScrolled / 0.85, 1)` where `pagesScrolled = scrollProgress * (pageCount - 1)`. Measuring in pages (not raw progress) makes the handoff land identically whether a reader has 12 beats or 30.

### 4. Reader veil (locked units open, they do not bounce)

A locked unit **opens** for everyone; the gate is structural, not a wall:

- Show only the free prefix of the content (Thaqalayn: the threshold + the orientation beat - the unit's own pitch), then a veil page. Gated beats never enter the view hierarchy, so there is nothing to scroll past.
- Veil page: the unit's cover blurred past legibility - same recipe as the journey-day veil (01-A4: 1.22x overscan, blur 44 opaque) with a lighter **0.46** black overlay - plus the NAMES of every movement beneath (a wall says something exists; a veil says what). Names only - adding Arabic terms crowded the layout at phone width and was rejected.
- Gold CTA ("Continue the descent" register) -> paywall with this unit's cover as context. No lock glyph.

### 5. Paywall context

Every gated tap passes the entry's cover + a naming eyebrow (e.g. "DEEP DIVE - SABR") to the paywall so the hero band shows the very thing being bought. Spec in `04-paywall-onboarding.md`. Fallback when an entry has no cover: the default paywall hero.
