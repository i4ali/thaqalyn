# Doves over the Shrine - HadithScreen onboarding background

Date: 2026-07-07
Status: approved via animated mockup (`mockups/hadith-doves-onboarding.html`, variant B)

## Goal

Give onboarding screen 1 (`HadithScreen.swift`, Hadith of Thaqalayn) a premium ambient
background: soft-glow ivory doves wheeling above a rim-lit shrine silhouette, evoking the
doves that circle the shrines of the Imams. Pure procedural SwiftUI - no video, no image
assets, no dependencies.

## Approved design decisions

1. **Composition**: shrine silhouette anchored to the bottom of the screen (central onion
   dome + drum, two minarets with balconies and caps, low building mass), doves flying above.
2. **Shrine treatment (mockup variant B)**: gold-gradient rim light on the dome's upper
   edge, glowing gold finial, soft radial gold glow behind the dome, warm portal arch
   outline, four faintly lit windows. Silhouette fill near-black emerald (`#04100C`) so it
   reads against the `#081310` sky.
3. **Dove style**: stylized soft-glow ivory (`#F3EAD6` family) - radial-gradient halo,
   two quadratic-curve wing strokes with round caps and slight blur glow, small ellipse
   body. Clearly doves, not photorealistic.
4. **Choreography**:
   - Two doves are already wheeling above the dome when the screen fades in.
   - At ~0.4s a flock of five sweeps in from the upper-left, crosses the sky strip above
     the title (y < ~80pt), descends along the right edge, and each dove settles seamlessly
     into its own elliptical orbit above the dome. The whole sweep lands within the
     screen's 5-second auto-advance window.
   - While wheeling, doves alternate flapping and gliding (wings frozen in a slight V),
     at individual speeds, radii, and phases, all orbiting the same direction.
5. **Tooling**: procedural SwiftUI only. No Higgsfield/Kling video (banding on dark
   gradients, seam on loop, bundle size), no AI still asset (variant B is fully
   drawable as paths).

## Architecture

One new file: `Thaqalayn/Views/Onboarding/Components/ShrineDovesLayer.swift`
(Xcode 16 synced folder - just drop the file in, no pbxproj edit).

- `ShrineDovesLayer: View` - public entry point; composes the two sub-layers in order:
  `DoveFlockCanvas` below, `ShrineSilhouette` above (so doves are occluded when their
  orbit carries them behind the dome - free depth cue).
- `ShrineSilhouette: View` - a single static `Canvas` drawing paths: dome (two mirrored cubic
  beziers to a point), drum + cornice, minarets (tapered shafts, two balcony bands, onion
  caps, finials), building mass. Gold rim = same dome path stroked with a vertical
  gold-to-clear `LinearGradient`; dome back-glow = radial gradient ellipse; four lit
  window capsules + portal arch stroke. Anchored bottom, full width, `ignoresSafeArea`,
  `allowsHitTesting(false)`.
- `DoveFlockCanvas: View` - `TimelineView(.animation)` + `Canvas`, exactly the
  `FloatingEmbers` pattern already in `HadithScreen.swift`:
  - Static `[Dove]` parameter array generated once (`static let`), deterministic draw as
    a pure function of elapsed time `t`.
  - Entry doves: cubic bezier `P0..P3` with `P3 = orbitPos(thetaArrival)` and
    `theta0 = thetaArrival - speed * (delay + duration)` so the handoff from sweep to
    orbit is seamless; ease-in-out along the curve; alpha ramps in over 0.4s; scale
    eases 1.0 -> 0.62 (depth).
  - Orbit: tilted ellipse (tilt ~ -0.10 rad) centered above the dome, radii and angular
    speeds per dove (all same direction), flap = sine on wing lift, glide modulation via
    a slow sine gate.
  - Slight banking: glyph rotates by `heading * 0.22`, clamped to +/-0.45 rad.

### Layer order in HadithScreen's ZStack

`OnboardingBackground` -> `FloatingEmbers` (unchanged) -> `ShrineDovesLayer` -> content
VStack. The layer fades in with the existing `isVisible` animation like the embers do.

### Layout metrics (expressed as fractions, base 390x844)

- Shrine height ~244pt at 390pt width, scaled by width; dome tip lands ~y = 0.76H.
- Orbit center: (0.5W, ~0.73H); rx ~92-140pt, ry ~19-29pt (scaled by width).
- Dove sizes: entry 12.5-15pt shrinking to x0.62 in orbit; preexisting doves 7.5-9pt.

## Accessibility and performance

- **Reduce Motion**: no sweep, no wheeling - a single static frame (shrine + 3-4 gliding
  doves scattered above the dome), mirroring how `FloatingEmbers` degrades.
- Seven doves + existing embers in GPU-drawn Canvases: negligible cost. All ambient
  layers `allowsHitTesting(false)` so the screen's tap-to-continue still works everywhere.

## Explicitly out of scope / unchanged

- The 5-second auto-advance, title, hadith card, and hint text are untouched.
- `FloatingEmbers` stays as-is.
- No What's New entry: onboarding is only shown to new users, so there is no destination
  an existing user could visit - the announce-in-What's-New rule doesn't apply.
- No premium gating, no reading-text-size implications (no reading content added).

## Verification

- `xcodebuild` green (scheme Thaqalayn, UDID destination per usual).
- User verifies visually in Simulator (fresh install to see onboarding; bundle id
  `MAHR.Partner.Thaqalayn` - `defaults delete` to flush UserDefaults, per the
  fresh-install reset procedure).
- Reduce Motion path checked by toggling the setting.
