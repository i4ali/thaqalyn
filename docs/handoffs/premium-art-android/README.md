# Premium art handoff: Thaqalayn iOS -> Android

Self-contained handoff for porting the premium art initiative (journey posters, seasonal heroes, Deep Dive covers, Explore covers, paywall hero, onboarding shrine video) to the Android app. The Android screens already exist; this package supplies the missing art plus the exact visual treatment used on iOS so the two apps match.

Prepared 2026-07-15 from the iOS repo (`thaqalyn`), app version 7.4. All iOS `file:line` references in these docs point at that repo at this date.

## What's in the box

```
assets/
  journeys/    5 journey shelf covers        1170x900   (13:10)
  deepdives/   15 Deep Dive / surah covers   1170x1463  (4:5)
  today/       6 Today seasonal heroes       1170x653   (wide)
  explore/     8 Explore section covers      1170x1452  (~4:5)
  paywall/     paywall_hero_dome.jpg         1170x1017
  onboarding/  shrine_hero_loop.mp4          1080x1920, HEVC, 24fps, 7.25s loop, silent
01-journeys-today.md      journey posters, header bands, veiled day preview, Today heroes
02-deepdive-covers.md     Deep Dive / Inside-the-Surah covers, descent threshold + veil
03-explore-covers.md      Explore hub + 7 detail screen header bands (shared composable)
04-paywall-onboarding.md  paywall hero band + motion, onboarding video player
```

36 files, ~4.8 MB total. These JPGs are the EXACT files bundled in the iOS app (already color-graded and crop-composed), not the raw masters - use them as-is for pixel parity. Full-resolution masters stay in the iOS repo under `assets/premium-art/` if ever needed.

## Importing into the Android project

- Images: drop all JPGs into `res/drawable-nodpi/` (filenames are already valid lowercase resource names, unique across the set). `nodpi` is deliberate: these are full-bleed decorative images scaled with `ContentScale.Crop`, so density variants would only waste APK size. Consider converting to WebP via Android Studio (right-click, Convert to WebP, lossy ~85) for a smaller APK; visually safe for this art.
- Video: `res/raw/shrine_hero_loop.mp4`.
- iOS point values in these docs translate 1:1 to dp, font points to sp.

## Asset manifest (iOS asset name -> file)

| iOS asset | File | Surface |
|---|---|---|
| RamadanCover / HajjCover / MuharramCover / FatimiyyaCover / ArbaeenCover | `journeys/<name>_cover.jpg` | Journey shelf poster, header band, veil, paywall context (01) |
| TodayHeroRamadan / ...Hajj / ...Muharram / ...Fatimiyya / ...Arbaeen / ...Everyday | `today/<name>_hero.jpg` | Today daily-reminder hero card (01) |
| FatihaCover, BaqaraCover, AliImranCover, NisaCover, YusufCover, YasinCover, RahmanCover, MulkCover | `deepdives/<name>_cover.jpg` | Inside-the-Surah shelf/tiles/descent (02) |
| YaqinCover, SabrCover, TawakkulCover, ShukrCover, IkhlasCover, TaqwaCover, RidaCover | `deepdives/<name>_cover.jpg` | Theme Deep Dive shelf/tiles/descent (02) |
| ExploreCover | `explore/explore_cover.jpg` | Explore tab header band, 440dp (03) |
| AhlulBaytCover, DailyDuasCover, FastingCover, FoodsCover, LifeMomentsCover, PropheticParallelsCover, PropheticStoriesCover | `explore/<name>_cover.jpg` | Explore detail header bands, 280dp (03) |
| PaywallHeroDome | `paywall/paywall_hero_dome.jpg` | Paywall hero band default (04) |
| shrine_hero_loop.mp4 | `onboarding/shrine_hero_loop.mp4` | Onboarding page 1 background video (04) |

## Cross-cutting rules (read before implementing)

1. **Theme gating.** Header-band art (Explore, journey headers) and the Today heroes render ONLY under the Midnight Emerald theme; standard theme keeps plain text headers / flat gradient banner. Shelf posters and list tiles render in both themes. The descent, veils, and paywall are always-dark surfaces independent of theme.
2. **Mask vs scrim - do not mix them up.** Header bands and the paywall hero fade the ART ITSELF to transparent via an alpha-mask gradient (Compose: `BlendMode.DstIn` in an offscreen layer; recipe in 03). Posters, Today heroes, descent threshold, and the onboarding video instead layer a black gradient scrim ON TOP of the art. Each doc states which applies.
3. **Always fill-crop.** Every image renders `ContentScale.Crop`, clipped, never letterboxed. Covers are composed 4:5 with a dark top third; titles/eyebrows sit in that dark sky.
4. **Premium is a chip, never a lock.** Gated entries show a "PREMIUM" accent capsule; no `lock` glyphs anywhere. Locked taps route to the paywall carrying that entry's cover as the paywall hero context.
5. **Missing art degrades silently.** Cards fall back to the old icon-chip layout when an entry has no cover; header bands simply don't render. Never show a placeholder/broken image.
6. **Veil recipe is shared.** Locked previews = cover scaled 1.22x + blur 44 (opaque) + black overlay (0.52 journey day / 0.46 descent). Blur needs API 31+; see fallback note in 01-A4.
7. **Reduce motion.** Ken Burns drift, entrance cascades, and the onboarding video are all skipped when the system remove-animations setting is on.

## Palette constants referenced across the docs

| Token | Value |
|---|---|
| Descent gold / gold bright | `#C9A55C` / `#E3C37E` |
| Descent cream / mute | `#ECE7DB` / `#B3BCB0` |
| Paywall ivory / gold | `#F1E8D6` / `#ECD49A` |
| Today hero base | `#06110D` |
| Descent threshold base | `#040A07` |
| Journey header card backing | `#06120E` at 0.45 alpha |

## Suggested implementation order

1. Import assets; build the shared `CoverHeaderBand` composable (03) - it unlocks 8 Explore screens plus the 5 journey headers.
2. Shelf posters + list tiles (01-A1, 02) - the highest-visibility win.
3. Today heroes with Hijri season selection (01-B).
4. Paywall hero band + context covers (04-A), then descent threshold/veils (02).
5. Onboarding video (04-B), poster-zoom transition (01-A2) last - both are polish.
