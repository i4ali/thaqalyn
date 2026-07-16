# 03 - Explore tab section covers

8 images in `assets/explore/`, all 1170x1452 px (roughly 4:5 portrait), dark night-shrine art composed so the top third is dark sky (text sits over it).

## Where each image goes

| File | Screen | Band height |
|---|---|---|
| `explore_cover.jpg` | Explore tab overview (header behind "DISCOVER" eyebrow + title + subtitle) | 440 dp |
| `ahlulbayt_cover.jpg` | Ahl al-Bayt in the Quran | 280 dp |
| `daily_duas_cover.jpg` | Daily Duas | 280 dp |
| `fasting_cover.jpg` | Fasting in the Quran | 280 dp |
| `foods_cover.jpg` | Foods of the Quran | 280 dp |
| `life_moments_cover.jpg` | Life Moments | 280 dp |
| `prophetic_parallels_cover.jpg` | Prophetic Parallels | 280 dp |
| `prophetic_stories_cover.jpg` | Prophetic Stories | 280 dp |

iOS reference: shared component `EmCoverBand` / `emCoverHeaderBand` in `Thaqalayn/Utilities/EmeraldComponents.swift:556-607`; call sites e.g. `ExploreView.swift:386` (440), `AhlulbaytQuranView.swift:236`, `DuasView.swift:112`, `FoodsView.swift:90` (all 280).

## The treatment (identical on all 8 - build it ONCE as a shared composable)

The cover is a fixed-height, full-bleed band placed BEHIND the screen's header text stack, top-aligned:

- Image scaled with `ContentScale.Crop`, clipped to the band, aligned to the top of the screen.
- The band bleeds behind the status bar (draw edge-to-edge; do not apply status-bar padding to the band itself, only to the header text on top of it).
- The band is non-interactive and hidden from accessibility (decorative).
- No corner radius. No parallax or stretch-on-scroll - the band is fixed height and simply scrolls off with the content.
- On these screens iOS hides the nav bar background so the art reaches the very top edge. On Android, make the status bar transparent / draw edge-to-edge on these screens.

### The fade is an ALPHA MASK, not a scrim

This is the one detail that is easy to get wrong. The art itself fades to transparent at the bottom so it melts into the emerald background. There is NO dark overlay on top of the art.

Vertical gradient applied as an alpha mask (top to bottom):

| Stop | Alpha |
|---|---|
| 0.00 | 0.92 |
| 0.18 | 1.00 |
| 0.62 | 1.00 |
| 1.00 | 0.00 |

Compose implementation - draw the gradient with `BlendMode.DstIn` over the image inside an offscreen layer:

```kotlin
@Composable
fun CoverHeaderBand(
    @DrawableRes art: Int,
    height: Dp,
    modifier: Modifier = Modifier,
) {
    val maskBrush = Brush.verticalGradient(
        0.00f to Color.Black.copy(alpha = 0.92f),
        0.18f to Color.Black,
        0.62f to Color.Black,
        1.00f to Color.Transparent,
    )
    Image(
        painter = painterResource(art),
        contentDescription = null,
        contentScale = ContentScale.Crop,
        alignment = Alignment.TopCenter,
        modifier = modifier
            .fillMaxWidth()
            .height(height)
            .graphicsLayer(compositingStrategy = CompositingStrategy.Offscreen)
            .drawWithContent {
                drawContent()
                drawRect(brush = maskBrush, blendMode = BlendMode.DstIn)
            },
    )
}
```

Usage pattern: `Box { CoverHeaderBand(R.drawable.ahlulbayt_cover, 280.dp); HeaderTextStack(Modifier.statusBarsPadding()) }` as the first item of the screen's scrolling column.

## Theme gating

Cover art renders ONLY under the Midnight Emerald theme. In the standard/legacy themes these screens keep their plain text headers with no art. Gate the band on your theme flag (the Android equivalent of `ThemeManager.shared.isMidnightEmerald`).

There are no dark/light asset variants - one JPG per screen, used as-is.

## Header text on top of the band (for reference)

The text stack over the art (already existing on Android, listed for visual parity):
- Eyebrow: system 11sp bold, letter tracking ~3, accent color (e.g. "DISCOVER", "DAILY DUAS").
- Title: serif semibold 34-40sp (Explore overview and most details 36, Life Moments 40, Foods 34).
- Subtitle: system 13.5sp.
- Padding: horizontal 20dp, top ~16dp below status bar (Explore overview uses top 62dp), bottom 14dp.
- Text needs no extra shadow - the covers are composed with dark sky where the text sits.
- RTL (Urdu/Arabic): the header stack mirrors; the art does not.
