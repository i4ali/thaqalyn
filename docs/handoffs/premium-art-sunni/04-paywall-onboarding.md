# 04 - Paywall hero band + onboarding hero video

## A. Paywall hero band

Asset: one default hero, 1170 x ~1017 (a "crown jewel" subject in AlBayan's style - Thaqalayn used its signature dome; pick AlBayan's signature place from the approved style bible). Purpose-compose it for this near-square band; do not crop a 4:5 poster down to it.

### Placement and size

- First element of the paywall's scrolling column, under the close (X) row, above the tier ladder / feature rows.
- Fixed height **348 pt**, full screen width - it escapes the column's 20pt horizontal padding (`.padding(.horizontal, -20)`) and bleeds edge-to-edge.
- `.scaledToFill()`, `.clipped()`, non-interactive, `.accessibilityHidden(true)`.

### Context covers (the contextual paywall)

The hero is swappable. Define a `PaywallContext { coverAssetName: String?, eyebrow: String }` passed by every gated tap, so the hero shows the very thing the user just reached for and the eyebrow names it ("DEEP DIVE - SABR"). Rules learned on Thaqalayn:

- **Keep the headline the whole-library sell** ("Everything. Forever." register). Context swaps the art and eyebrow ONLY - shrinking the headline to one unit shrinks what is being sold.
- Crop anchor: default hero = `.center`; context covers are 4:5 and overflow the wide band hugely, so they MUST anchor `.top` (`alignment: .top` on the fill frame) or the crop rides the bright subject up under the headline.
- Fallback is always the default hero. Wire context at every gated entry point; the one context-free entry should be a browsing entry (profile "Upgrade" row), not a blocked tap.

### Fade - alpha mask, same technique as 03

```swift
.mask(LinearGradient(stops: [
    .init(color: .black.opacity(0.72), location: 0.00),
    .init(color: .black,               location: 0.12),
    .init(color: .black,               location: 0.55),
    .init(color: .clear,               location: 1.00),
], startPoint: .top, endPoint: .bottom))
```

No hard edge, no dark scrim on top - the art melts into the screen background.

### Text over the band

Fixed light colors regardless of theme (the art is always dark): ivory headline + gold accents (AlBayan's tokens), each with a black drop shadow (0.45-0.5, blur 8-14). Do not use theme body-text colors here - a light-theme text color vanishes on dark art.

### Motion (all gated on `accessibilityReduceMotion`)

1. **Ken Burns drift on the hero**: scale 1.0 -> 1.09, `.easeInOut(duration: 22).repeatForever(autoreverses: true)`. Anchor `.center` for the default hero, `.top` for context covers (grow away from the headline).
2. **Entrance cascade**: each row below the hero fades in (0 -> 1) and rises (y 14 -> 0), ease-out 0.5s, staggered `index * 0.05s` - one continuous index across ladder + feature rows.
3. **Price count-up**: displayed price animates 0 -> real price, ease-out 0.7s, in the store's real localized currency (make the price view `Animatable` over a `Decimal` + the store's `priceFormatStyle`; never hardcode a currency). Re-run if the price loads after appear.

## B. Onboarding hero video

One silent seamless loop, 1080x1920 portrait, HEVC, ~7s, target under ~1.5 MB, behind onboarding page 1 only.

### Generation (Higgsfield; see README section 6)

1. Generate the hero master STILL first, composed like a cover: subject in the bottom third, near-black sky above = the text zone. Get it user-approved.
2. Image-to-video with **start frame = end frame = that same job id** and a locked-off camera prompt: no push, pull, pan, or crane - only subtle ambient motion (drifting light, embers, sky shimmer). Camera moves expose the frame edges and warp the composition.
3. Kill the loop seam: ffmpeg tail-to-head crossfade - xfade the last ~0.75s into the head, then concat so the cut lands mid-clip. Verify by watching 3 loops.
4. Grade fixes are free in ffmpeg (`colorbalance`, `eq`) - do not re-render for color.
5. Encode: `ffmpeg -i loop.mp4 -c:v libx265 -crf 27 -tag:v hvc1 -movflags +faststart shrine-equivalent_loop.mp4`.

### Player behavior

- Bundle in app resources; play with `AVPlayerLooper` on an `AVQueuePlayer`, `isMuted = true`.
- Audio session: `.ambient` with `.mixWithOthers` so the video NEVER interrupts the user's own audio (recitation, music). This is mandatory.
- Fade the layer in ease-out 1.0s after a 0.2s delay on first appear.
- Play only while page 1 is current AND the app is foregrounded; pause otherwise; tear down when onboarding ends. Do not keep the screen awake.
- Aspect-fill (`.resizeAspectFill`).

### Scrim over the video

Unlike the image bands, the video gets a normal black scrim ON TOP, darkening the title zone and the bottom continue zone:

```swift
LinearGradient(stops: [
    .init(color: .black.opacity(0.28), location: 0.00),
    .init(color: .black.opacity(0.04), location: 0.22),
    .init(color: .black.opacity(0.04), location: 0.58),
    .init(color: .black.opacity(0.40), location: 1.00),
], startPoint: .top, endPoint: .bottom)
```

Text/cards over video need real dark backing (Thaqalayn: near-black glass at ~0.5 alpha + hairline gold stroke) - a 5%-white glass card is invisible over moving footage.

### Fallbacks

- Reduce Motion on, or the asset fails to load: show the page's static background (optionally a still exported from the video). Never a black hole, never a spinner.
- The video is used nowhere else; the paywall hero is its own still image.
