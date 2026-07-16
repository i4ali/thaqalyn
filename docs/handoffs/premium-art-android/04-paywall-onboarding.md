# 04 - Paywall hero band + onboarding shrine video

## A. Paywall hero band

Asset: `assets/paywall/paywall_hero_dome.jpg`, 1170x1017 px. A night-shrine dome still. iOS reference: `Thaqalayn/Views/PaywallView.swift:186-268`.

### Placement and size

- First element of the paywall's scrolling column, directly under the close (X) row and above the tier ladder / feature rows.
- Fixed band height: **348 dp**, full screen width. The screen's content column has 20dp horizontal padding; the hero band escapes it and bleeds edge-to-edge (iOS does `.padding(.horizontal, -20)`; in Compose just place the band outside the padded column, or use a negative-inset layout).
- `ContentScale.Crop`, clipped, non-interactive, hidden from accessibility.

### Context covers

The hero image is swappable: when the paywall is opened from a specific locked feature that has its own cover art (e.g. an Inside-the-Surah experience), that feature's cover is shown instead of the dome. Default and fallback is always `paywall_hero_dome`.

- Dome (landscape-ish 1170x1017): crop anchored **center**.
- Context covers (portrait 4:5, they overflow the wide band): crop anchored **top**, so the composed sky/subject stays in frame.

### Fade (alpha mask, same technique as the Explore covers - see 03)

Vertical gradient alpha mask, top to bottom:

| Stop | Alpha |
|---|---|
| 0.00 | 0.72 |
| 0.12 | 1.00 |
| 0.55 | 1.00 |
| 1.00 | 0.00 |

The art fades to transparent into the screen background at the bottom - no hard edge, no dark scrim on top.

### Text over the band

Fixed light colors regardless of theme (the art is dark in both): ivory `#F1E8D6` for the headline, gold `#ECD49A` for accents, each with a black drop shadow (alpha 0.45-0.5, blur radius 8-14) for legibility.

### Motion ("paywall motion")

All motion is skipped when the system's remove/reduce-animations accessibility setting is on.

1. **Ken Burns drift on the hero art**: scale animates 1.0 -> 1.09 and back forever, ease-in-out, **22 s per leg**, autoreversing. Scale anchor: center for the dome, top for context covers (grow away from the headline).

```kotlin
val drift = rememberInfiniteTransition(label = "heroDrift").animateFloat(
    initialValue = 1f, targetValue = 1.09f,
    animationSpec = infiniteRepeatable(
        tween(22_000, easing = EaseInOut),
        RepeatMode.Reverse,
    ), label = "heroDrift",
)
// on the Image: Modifier.graphicsLayer {
//     scaleX = drift.value; scaleY = drift.value
//     transformOrigin = TransformOrigin(0.5f, if (isContextCover) 0f else 0.5f)
// }
```

2. **Content cascade**: on entrance, each row below the hero (tier ladder rows, feature rows) fades in (alpha 0 -> 1) and rises (translationY 14dp -> 0), ease-out 0.5 s, staggered by `index * 50 ms`.

3. **Price count-up**: the displayed price animates from 0 to the real price, ease-out 0.7 s. Re-runs if the store price loads after the screen appears.

### Background ambience

The paywall sits on the emerald background with a soft glow + starfield aura behind everything (iOS `darkScreenAura(glowOpacity: 0.40, starCount: 18)`). If the Android paywall already has its emerald background, keep it; the hero band just needs to fade into whatever is behind it.

## B. Onboarding shrine video

Asset: `assets/onboarding/shrine_hero_loop.mp4` - HEVC (H.265), 1080x1920 portrait, 24 fps, 7.25 s, ~300 KB, silent, authored as a seamless loop. iOS reference: `Thaqalayn/Views/Onboarding/Components/ShrineHeroVideoLayer.swift`, used only by onboarding screen 1 (`HadithScreen.swift`).

HEVC note: hardware HEVC decode is standard on Android 5+ era chipsets the app targets, but if you see devices without it, transcode once to H.264:
`ffmpeg -i shrine_hero_loop.mp4 -c:v libx264 -crf 20 -pix_fmt yuv420p -movflags +faststart shrine_hero_loop_h264.mp4`

### Placement

Full-screen layer behind the content of onboarding page 1 only (behind the hadith card and title), edge-to-edge, faded in with ease-out 1.0 s after a 0.2 s delay on first appearance.

### Player behavior (Media3 / ExoPlayer)

- Ship in `res/raw/shrine_hero_loop.mp4` (raw resource) or assets; play via ExoPlayer.
- Seamless loop: `repeatMode = Player.REPEAT_MODE_ONE` (the clip is authored so the seam is invisible).
- Muted: `volume = 0f`. Do NOT take audio focus - build `AudioAttributes` with `handleAudioFocus = false` so the user's own audio (Quran recitation, music) keeps playing. iOS uses the ambient/mix-with-others session for exactly this reason.
- Do not keep the screen awake for it.
- Scale: aspect-fill crop (`RESIZE_MODE_ZOOM` on `PlayerView`, or `VIDEO_SCALING_MODE_SCALE_TO_FIT_WITH_CROPPING` with a `SurfaceView`).
- Lifecycle: play only while onboarding page 1 is the current page AND the app is foregrounded; pause otherwise. Release the player when onboarding is left.

### Scrim over the video

Unlike the image covers, the video gets a normal black scrim ON TOP (not a mask), darkening the title zone and the bottom "continue" zone:

| Stop | Black alpha |
|---|---|
| 0.00 | 0.28 |
| 0.22 | 0.04 |
| 0.58 | 0.04 |
| 1.00 | 0.40 |

`Brush.verticalGradient` in a `Box` over the player, non-interactive.

### Fallbacks

- If the remove-animations accessibility setting is on, or the video fails to load: do not show the video. iOS falls back to its procedural embers/doves layer; on Android fall back to whatever static onboarding background page 1 already has (optionally a still frame exported from the video).
- The video is used nowhere else in the app. The paywall hero is the separate `paywall_hero_dome.jpg` still, not this video.
