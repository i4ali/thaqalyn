# 02 - Deep Dive / Inside-the-Surah covers

15 images in `assets/deepdives/`, all 1170x1463 px (4:5 portrait).

## Which cover belongs to which experience

Surah experiences (iOS `SurahExperienceCatalog.swift`):

| File | Experience | Status on iOS (2026-07-15) |
|---|---|---|
| `fatiha_cover.jpg` | Al-Fatiha (surah 1) | Available, FREE flagship (not premium-gated) |
| `baqara_cover.jpg` | Al-Baqara (2) | Available, premium |
| `aliimran_cover.jpg` | Al Imran (3) | Available, premium |
| `nisa_cover.jpg` | Al-Nisa (4) | WITHDRAWN (available:false) - ship the asset, keep the entry hidden until relaunched |
| `yusuf_cover.jpg` | Yusuf (12) | Available, premium |
| `yasin_cover.jpg` | Yasin (36) | Coming soon |
| `rahman_cover.jpg` | Al-Rahman (55) | Coming soon |
| `mulk_cover.jpg` | Al-Mulk (67) | Coming soon |

Theme Deep Dives (iOS `DeepDiveCatalog.swift`):

| File | Deep Dive | Status |
|---|---|---|
| `yaqin_cover.jpg` | Yaqin (certainty) | Available, premium |
| `sabr_cover.jpg` | Sabr (patience) | Available, premium |
| `tawakkul_cover.jpg` | Tawakkul | Coming soon |
| `shukr_cover.jpg` | Shukr | Coming soon |
| `ikhlas_cover.jpg` | Ikhlas | Coming soon |
| `taqwa_cover.jpg` | Taqwa | Coming soon |
| `rida_cover.jpg` | Rida | Coming soon |

Covers are deliberately attached to coming-soon entries too - the art is what makes the roadmap worth buying into. Coming-soon rows show the art dimmed, not hidden.

Like the journeys, ONE cover field on the catalog entry feeds every surface: shelf poster, list tile, descent threshold, descent veil, and the paywall hero when the paywall opens from that entry.

## Where the covers render

### 1. Hub shelf posters

Same shared poster component and values as the journey shelf - see `01-journeys-today.md` section A1 (190x238dp card, radius 18, top scrim 0.60 -> 0.26 -> clear, serif title, PREMIUM chip, 0.82 alpha when coming soon). The Deep Dive and Inside-the-Surah shelves on the hub screen reuse it verbatim, including the poster-zoom transition (A2).

### 2. "All N" list rows - mini poster tile

iOS `EmCoverTile` (`EmeraldComponents.swift:323-344`), used on Deep Dive, Surah-experience, and journey list cards:

- **54 x 68 dp** (4:5) thumbnail, `RoundedRectangle(12)` continuous, `ContentScale.Crop`, 1dp theme stroke.
- Coming-soon: tile at 0.7 alpha AND the whole row card at 0.72 alpha, with a "Soon" outline pill.
- Premium-gated available entries: a PREMIUM chip (accent text in accent-tinted capsule). NEVER a lock icon - house rule.
- Fallback when no cover: the old icon chip. These rows render in BOTH themes.

### 3. Immersive descent (DeepDiveView) - threshold cover

The descent screen is always dark (theme-independent). The cover is the "doorway" behind the opening beat (iOS `DeepDiveView.swift:161-197`):

- Full-screen, `ContentScale.Crop`, clipped, over base color `#040A07`.
- Two overlays on the art:
  1. Vertical gradient of black: alpha 0.50 at 0.0, 0.66 at 0.34, 0.74 at 0.62, 0.60 at 1.0 (the art glows through the middle-dark wash).
  2. Radial gradient centered on screen: transparent until 0.32 of the radius, black 0.55 at the edge; radius = max(width, height) * 0.62 (vignette).
- Scroll-linked dissolve: the cover's alpha = `1 - clamp(pagesScrolled / 0.85, 0, 1)` where `pagesScrolled = scrollProgress * (pageCount - 1)`. It has fully dissolved just before the reader finishes the first beat. In Compose, drive this from the pager/scroll offset.

### 4. Descent veil (locked readers)

For a premium descent opened by a non-subscriber, the final scroll beat is a veil page built on the same cover: crop to full screen, scale 1.22x, blur radius 44 (opaque), black overlay at **0.46** alpha. Identical recipe to the journey locked-day veil (01, section A4 - including the API 31 blur note) except the lighter overlay, because this veil carries less text.

### 5. Paywall hero (context cover)

Every gated tap that routes to the paywall passes the entry's cover along as paywall context, so the paywall hero band shows the very thing being bought. Covered in `04-paywall-onboarding.md` (top-anchored crop for these 4:5 covers, fallback to the dome when no context).

## Gating recap for these entries

- Al-Fatiha: free for everyone (flagship).
- Other available entries: premium-gated; locked tap -> paywall with that entry's cover as context.
- Coming soon: not tappable into content; dimmed art + "Soon" pill.
- Withdrawn (al-Nisa): hidden from all lists/shelves, asset kept for relaunch.
