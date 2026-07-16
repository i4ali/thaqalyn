# Doves over the Shrine (HadithScreen) Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a procedural "doves wheeling over a rim-lit shrine" ambient layer to onboarding screen 1 (`HadithScreen`), per the approved spec `docs/superpowers/specs/2026-07-07-hadith-doves-onboarding-design.md` and mockup `mockups/hadith-doves-onboarding.html` (variant B).

**Architecture:** One new self-contained view file, `ShrineDovesLayer.swift`, containing a static `Canvas`-drawn shrine silhouette (bottom-anchored, gold rim-lit dome) and a `TimelineView(.animation)` + `Canvas` dove flock (entry sweep -> seamless orbital wheeling), following the existing `FloatingEmbers` pattern in `HadithScreen.swift`. The layer slots into HadithScreen's ZStack between `FloatingEmbers` and the content.

**Tech Stack:** SwiftUI only (Canvas, TimelineView, GraphicsContext). No dependencies, no image/video assets.

## Global Constraints

- NO automated tests: this project ships iOS work without an XCTest target. The verification gate for every task is a green `xcodebuild` build; the user does all Simulator visual verification themselves.
- NO `git commit` steps: the user commits everything personally. Never commit or stage.
- Build command (run from repo root `/Users/muhammadimranali/Documents/development/thaqalyn`):
  `xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' build`
  Expected final line: `** BUILD SUCCEEDED **`.
- The Xcode project uses Xcode 16 synced folder groups: creating the file inside `Thaqalayn/Views/Onboarding/Components/` is enough. Do NOT edit `project.pbxproj`.
- SourceKit/IDE diagnostics on new or freshly edited Swift files ("cannot find type in scope") are stale-index false positives. Trust `xcodebuild` output only.
- Never use the em dash character in any code, comment, or copy. Use a plain dash.
- No fallback logic; the animation layer is pure drawing so no error paths are expected.
- All ambient layers must be `allowsHitTesting(false)` so the screen's tap-to-continue keeps working everywhere.
- `Color(hex:)` already exists in the project (used throughout `HadithScreen.swift`).
- Design coordinates are authored in a 390pt-wide design space (the mockup's system) and scaled by `size.width / 390` at draw time; shrine and orbit anchor to the bottom edge.

---

### Task 1: ShrineSilhouette (static rim-lit shrine)

**Files:**
- Create: `Thaqalayn/Views/Onboarding/Components/ShrineDovesLayer.swift`

**Interfaces:**
- Consumes: `Color(hex:)` extension (exists project-wide), `OnboardingBackground` (exists, preview only).
- Produces: `struct ShrineDovesLayer: View` (public entry point used by Task 3) and `private struct ShrineSilhouette: View` (internal to this file). Task 2 will extend `ShrineDovesLayer.body` in this same file.

- [ ] **Step 1: Create the file with the shrine silhouette and a preview**

Create `Thaqalayn/Views/Onboarding/Components/ShrineDovesLayer.swift` with exactly this content:

```swift
//
//  ShrineDovesLayer.swift
//  Thaqalayn
//
//  Ambient "doves over the shrine" layer for the Hadith of Thaqalayn
//  onboarding screen: a rim-lit shrine silhouette anchored to the bottom
//  edge, with soft-glow ivory doves sweeping in and wheeling above the
//  dome. Pure procedural drawing (Canvas + TimelineView), same pattern as
//  FloatingEmbers in HadithScreen. Approved design:
//  docs/superpowers/specs/2026-07-07-hadith-doves-onboarding-design.md,
//  mockup mockups/hadith-doves-onboarding.html (variant B).
//
//  All coordinates are authored in a 390pt-wide design space and scaled
//  by size.width / 390 at draw time.
//

import SwiftUI

struct ShrineDovesLayer: View {
    var body: some View {
        ZStack {
            ShrineSilhouette()
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Shrine silhouette (rim-lit dome, minarets, portal, windows)

private struct ShrineSilhouette: View {
    private static let gold = Color(hex: "ECD49A")
    private static let fillColor = Color(hex: "04100C")

    var body: some View {
        Canvas { context, size in
            var ctx = context
            let s = size.width / 390
            // Anchor the 244pt-tall design space to the bottom edge.
            ctx.translateBy(x: 0, y: size.height - 244 * s)
            ctx.scaleBy(x: s, y: s)
            Self.draw(in: ctx)
        }
    }

    private static func draw(in context: GraphicsContext) {
        // Soft gold glow behind the dome
        context.fill(
            Path(ellipseIn: CGRect(x: 195 - 86, y: 86 - 62, width: 172, height: 124)),
            with: .radialGradient(
                Gradient(colors: [gold.opacity(0.30), .clear]),
                center: CGPoint(x: 195, y: 86),
                startRadius: 0,
                endRadius: 86
            )
        )

        // Onion dome: two mirrored bulging curves meeting at a point
        var dome = Path()
        dome.move(to: CGPoint(x: 150, y: 132))
        dome.addCurve(to: CGPoint(x: 187, y: 54),
                      control1: CGPoint(x: 140, y: 96),
                      control2: CGPoint(x: 158, y: 72))
        dome.addCurve(to: CGPoint(x: 195, y: 40),
                      control1: CGPoint(x: 191, y: 51),
                      control2: CGPoint(x: 193, y: 49))
        dome.addCurve(to: CGPoint(x: 203, y: 54),
                      control1: CGPoint(x: 197, y: 49),
                      control2: CGPoint(x: 199, y: 51))
        dome.addCurve(to: CGPoint(x: 240, y: 132),
                      control1: CGPoint(x: 232, y: 72),
                      control2: CGPoint(x: 250, y: 96))
        dome.closeSubpath()

        // One dark silhouette path: dome, drum, cornice, building, minarets
        var silhouette = Path()
        silhouette.addPath(dome)
        silhouette.addRect(CGRect(x: 154, y: 130, width: 82, height: 20))
        silhouette.addRoundedRect(
            in: CGRect(x: 144, y: 148, width: 102, height: 10),
            cornerSize: CGSize(width: 3, height: 3)
        )
        silhouette.addRect(CGRect(x: 30, y: 176, width: 330, height: 68))
        silhouette.addRoundedRect(
            in: CGRect(x: 14, y: 196, width: 362, height: 48),
            cornerSize: CGSize(width: 4, height: 4)
        )
        silhouette.addPath(minaret(centerX: 67))
        silhouette.addPath(minaret(centerX: 321))
        context.fill(silhouette, with: .color(fillColor))

        // Minaret finials (dark, part of the silhouette)
        for x: CGFloat in [67, 321] {
            var finial = Path()
            finial.move(to: CGPoint(x: x, y: 44))
            finial.addLine(to: CGPoint(x: x, y: 30))
            context.stroke(finial, with: .color(fillColor), lineWidth: 2)
            context.fill(
                Path(ellipseIn: CGRect(x: x - 2.2, y: 28 - 2.2, width: 4.4, height: 4.4)),
                with: .color(fillColor)
            )
        }

        // Gold rim light along the dome's upper edge, fading downward
        context.stroke(
            dome,
            with: .linearGradient(
                Gradient(stops: [
                    .init(color: gold.opacity(0.81), location: 0),
                    .init(color: gold.opacity(0.13), location: 0.7),
                    .init(color: .clear, location: 1),
                ]),
                startPoint: CGPoint(x: 195, y: 40),
                endPoint: CGPoint(x: 195, y: 132)
            ),
            lineWidth: 2.2
        )

        // Glowing central finial
        var domeFinial = Path()
        domeFinial.move(to: CGPoint(x: 195, y: 40))
        domeFinial.addLine(to: CGPoint(x: 195, y: 22))
        context.stroke(domeFinial, with: .color(gold.opacity(0.9)), lineWidth: 2)
        context.fill(
            Path(ellipseIn: CGRect(x: 195 - 2.6, y: 19 - 2.6, width: 5.2, height: 5.2)),
            with: .color(gold.opacity(0.95))
        )

        // Warm portal arch
        var portal = Path()
        portal.move(to: CGPoint(x: 167, y: 244))
        portal.addLine(to: CGPoint(x: 167, y: 198))
        portal.addQuadCurve(to: CGPoint(x: 195, y: 162), control: CGPoint(x: 167, y: 170))
        portal.addQuadCurve(to: CGPoint(x: 223, y: 198), control: CGPoint(x: 223, y: 170))
        portal.addLine(to: CGPoint(x: 223, y: 244))
        context.fill(portal, with: .color(gold.opacity(0.10)))
        context.stroke(portal, with: .color(gold.opacity(0.35)), lineWidth: 1.4)

        // Faintly lit windows
        for x: CGFloat in [96, 126, 256, 286] {
            context.fill(
                Path(roundedRect: CGRect(x: x, y: 196, width: 8, height: 14), cornerRadius: 3),
                with: .color(gold.opacity(0.5))
            )
        }
    }

    /// Tapered shaft, two balcony bands, and an onion cap, mirrored around centerX.
    private static func minaret(centerX: CGFloat) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: centerX - 5, y: 244))
        p.addLine(to: CGPoint(x: centerX - 3, y: 72))
        p.addLine(to: CGPoint(x: centerX + 3, y: 72))
        p.addLine(to: CGPoint(x: centerX + 5, y: 244))
        p.closeSubpath()
        p.addRoundedRect(
            in: CGRect(x: centerX - 10, y: 118, width: 20, height: 6),
            cornerSize: CGSize(width: 2, height: 2)
        )
        p.addRoundedRect(
            in: CGRect(x: centerX - 10, y: 162, width: 20, height: 6),
            cornerSize: CGSize(width: 2, height: 2)
        )
        p.move(to: CGPoint(x: centerX - 7, y: 72))
        p.addCurve(to: CGPoint(x: centerX, y: 44),
                   control1: CGPoint(x: centerX - 7, y: 57),
                   control2: CGPoint(x: centerX - 3, y: 51))
        p.addCurve(to: CGPoint(x: centerX + 7, y: 72),
                   control1: CGPoint(x: centerX + 3, y: 51),
                   control2: CGPoint(x: centerX + 7, y: 57))
        p.closeSubpath()
        return p
    }
}

#Preview {
    ZStack {
        OnboardingBackground(tilt: .peach)
        ShrineDovesLayer()
    }
}
```

- [ ] **Step 2: Build to verify**

Run from repo root:
```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' build
```
Expected: `** BUILD SUCCEEDED **`. (Ignore any SourceKit "cannot find type" noise in the editor; only the build output counts.)

---

### Task 2: DoveFlockCanvas (entry sweep + orbital wheeling)

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/Components/ShrineDovesLayer.swift`

**Interfaces:**
- Consumes: `ShrineSilhouette` and `ShrineDovesLayer` from Task 1 (same file).
- Produces: `private struct DoveFlockCanvas: View`, composed into `ShrineDovesLayer.body` UNDER the shrine (so doves are occluded when their orbit carries them behind the dome). `ShrineDovesLayer`'s public interface is unchanged.

- [ ] **Step 1: Wire the flock into ShrineDovesLayer's body**

In `ShrineDovesLayer.swift`, replace:

```swift
struct ShrineDovesLayer: View {
    var body: some View {
        ZStack {
            ShrineSilhouette()
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
```

with:

```swift
struct ShrineDovesLayer: View {
    var body: some View {
        ZStack {
            DoveFlockCanvas()
            ShrineSilhouette()
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
```

- [ ] **Step 2: Add DoveFlockCanvas to the same file**

Append the following at the end of `ShrineDovesLayer.swift`, ABOVE the `#Preview` block:

```swift
// MARK: - Dove flock (entry sweep + orbital wheeling above the dome)

/// Soft-glow ivory doves. Two are already wheeling above the dome when the
/// screen appears; a flock of five then sweeps in from the upper-left,
/// crosses the sky strip above the title, descends the right edge, and each
/// dove settles seamlessly into its own tilted elliptical orbit. While
/// wheeling, doves alternate flapping and gliding. Honours Reduce Motion by
/// drawing a static scatter of gliding doves instead.
private struct DoveFlockCanvas: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var startDate = Date()

    private struct Dove {
        let preexisting: Bool
        let delay: Double          // seconds before the entry sweep starts
        let duration: Double       // entry sweep duration
        let orbitRadiusX: Double   // design pts
        let orbitRadiusY: Double   // design pts
        let orbitSpeed: Double     // radians per second
        let thetaStart: Double     // orbit phase at t = 0
        let thetaArrival: Double   // orbit phase where the entry bezier lands
        let p0x: Double, p0y: Double   // entry bezier, 390pt design space
        let p1x: Double, p1y: Double
        let p2x: Double, p2y: Double
        let size: Double           // design pts
        let flapFreq: Double       // radians per second
        let flapPhase: Double
        let glidePhase: Double
    }

    private struct Pose {
        let x: Double
        let y: Double
        let headingX: Double
        let headingY: Double
        let scale: Double
        let alpha: Double
        let entering: Bool
    }

    private static let ivory = Color(hex: "F3EAD6")
    private static let orbitTilt = -0.10

    // Generated once and shared - stable across redraws.
    private static let doves: [Dove] = {
        var flock: [Dove] = []
        // Two doves already wheeling when the screen appears
        for _ in 0..<2 {
            flock.append(Dove(
                preexisting: true,
                delay: 0, duration: 0,
                orbitRadiusX: .random(in: 96...136),
                orbitRadiusY: .random(in: 20...28),
                orbitSpeed: .random(in: 0.34...0.48),
                thetaStart: .random(in: 0...(2 * .pi)),
                thetaArrival: 0,
                p0x: 0, p0y: 0, p1x: 0, p1y: 0, p2x: 0, p2y: 0,
                size: .random(in: 7.5...9),
                flapFreq: .random(in: 9...12),
                flapPhase: .random(in: 0...(2 * .pi)),
                glidePhase: .random(in: 0...(2 * .pi))
            ))
        }
        // The entry-sweep flock: staggered, arrivals spread around the orbit.
        // thetaStart is back-computed so the orbit continues seamlessly from
        // the moment the entry bezier lands at thetaArrival.
        for i in 0..<5 {
            let delay = 0.35 + Double(i) * 0.26 + Double.random(in: 0...0.12)
            let duration = Double.random(in: 2.5...3.0)
            let speed = Double.random(in: 0.30...0.58)
            let thetaArrival = Double.random(in: -0.7...0.9)
            flock.append(Dove(
                preexisting: false,
                delay: delay, duration: duration,
                orbitRadiusX: .random(in: 92...140),
                orbitRadiusY: .random(in: 19...29),
                orbitSpeed: speed,
                thetaStart: thetaArrival - speed * (delay + duration),
                thetaArrival: thetaArrival,
                p0x: -46 - Double(i) * 26,
                p0y: 58 + Double(i) * 7 + .random(in: 0...8),
                p1x: 96 + .random(in: 0...40),
                p1y: 16 + Double(i) * 6 + .random(in: 0...16),
                p2x: 428 + .random(in: 0...25),
                p2y: 250 + .random(in: 0...70),
                size: .random(in: 12.5...15),
                flapFreq: .random(in: 10...13),
                flapPhase: .random(in: 0...(2 * .pi)),
                glidePhase: .random(in: 0...(2 * .pi))
            ))
        }
        return flock
    }()

    var body: some View {
        Group {
            if reduceMotion {
                Canvas { context, size in
                    Self.draw(context, size: size, t: 0, animated: false)
                }
            } else {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let t = timeline.date.timeIntervalSince(startDate)
                        Self.draw(context, size: size, t: t, animated: true)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }

    private static func draw(_ context: GraphicsContext, size: CGSize, t: Double, animated: Bool) {
        let s = Double(size.width) / 390

        guard animated else {
            // Reduce Motion: a calm static scatter of gliding doves.
            for dove in doves.prefix(4) {
                let p = orbitPosition(theta: dove.thetaStart, dove: dove, size: size, scale: s)
                let ahead = orbitPosition(theta: dove.thetaStart + 0.02, dove: dove, size: size, scale: s)
                let pose = Pose(x: p.x, y: p.y,
                                headingX: ahead.x - p.x, headingY: ahead.y - p.y,
                                scale: 0.62, alpha: 1, entering: false)
                drawDove(context, dove: dove, pose: pose, t: 0, scale: s, frozenGlide: true)
            }
            return
        }

        for dove in doves {
            guard let pose = pose(for: dove, t: t, size: size, scale: s) else { continue }
            drawDove(context, dove: dove, pose: pose, t: t, scale: s, frozenGlide: false)
        }
    }

    /// Orbit: tilted ellipse centered above the dome (dome tip sits at
    /// height - 204 * s; the orbit center rides slightly above it).
    private static func orbitPosition(theta: Double, dove: Dove, size: CGSize, scale s: Double) -> (x: Double, y: Double) {
        let cx = Double(size.width) / 2
        let cy = Double(size.height) - 228 * s
        let ex = cos(theta) * dove.orbitRadiusX * s
        let ey = sin(theta) * dove.orbitRadiusY * s
        return (cx + ex * cos(orbitTilt) - ey * sin(orbitTilt),
                cy + ex * sin(orbitTilt) + ey * cos(orbitTilt))
    }

    /// Entry sweep: cubic bezier whose endpoint IS the orbit point at
    /// thetaArrival, so the sweep hands off into the orbit with no jump.
    private static func entryPoint(_ dove: Dove, u: Double, size: CGSize, scale s: Double) -> (x: Double, y: Double) {
        let p3 = orbitPosition(theta: dove.thetaArrival, dove: dove, size: size, scale: s)
        let x0 = dove.p0x * s, y0 = dove.p0y * s
        let x1 = dove.p1x * s, y1 = dove.p1y * s
        let x2 = dove.p2x * s, y2 = dove.p2y * s
        let v = 1 - u
        let x = v * v * v * x0 + 3 * v * v * u * x1 + 3 * v * u * u * x2 + u * u * u * p3.x
        let y = v * v * v * y0 + 3 * v * v * u * y1 + 3 * v * u * u * y2 + u * u * u * p3.y
        return (x, y)
    }

    private static func easeInOut(_ u: Double) -> Double {
        u < 0.5 ? 2 * u * u : 1 - pow(-2 * u + 2, 2) / 2
    }

    private static func pose(for dove: Dove, t: Double, size: CGSize, scale s: Double) -> Pose? {
        if !dove.preexisting {
            let tl = t - dove.delay
            if tl < 0 { return nil }
            if tl < dove.duration {
                let u = easeInOut(tl / dove.duration)
                let p = entryPoint(dove, u: u, size: size, scale: s)
                let ahead = entryPoint(dove, u: min(1, u + 0.01), size: size, scale: s)
                return Pose(x: p.x, y: p.y,
                            headingX: ahead.x - p.x, headingY: ahead.y - p.y,
                            scale: 1 - 0.38 * u,
                            alpha: min(1, tl / 0.4),
                            entering: true)
            }
        }
        let theta = dove.thetaStart + dove.orbitSpeed * t
        let p = orbitPosition(theta: theta, dove: dove, size: size, scale: s)
        let ahead = orbitPosition(theta: theta + 0.02, dove: dove, size: size, scale: s)
        return Pose(x: p.x, y: p.y,
                    headingX: ahead.x - p.x, headingY: ahead.y - p.y,
                    scale: 0.62, alpha: 1, entering: false)
    }

    private static func drawDove(_ context: GraphicsContext, dove: Dove, pose: Pose, t: Double, scale s: Double, frozenGlide: Bool) {
        let ds = dove.size * pose.scale * s
        let heading = atan2(pose.headingY, pose.headingX)
        // Gentle banking only - the glyph stays mostly screen-aligned.
        let bank = min(0.45, max(-0.45, heading * 0.22))

        // Wing lift: full flapping while entering, alternating flap/glide
        // while wheeling, frozen slight-V under Reduce Motion.
        let lift: Double
        if frozenGlide {
            lift = ds * 0.20
        } else {
            var amp = 1.0
            if !pose.entering {
                let gate = sin(t * 0.35 + dove.glidePhase)
                amp = gate > 0 ? 0.35 + 0.65 * gate : 0.18
            }
            lift = sin(t * dove.flapFreq + dove.flapPhase) * ds * 0.55 * amp + ds * 0.18 * (1 - amp)
        }

        var ctx = context
        ctx.translateBy(x: pose.x, y: pose.y)
        ctx.rotate(by: .radians(bank))

        // Halo
        ctx.fill(
            Path(ellipseIn: CGRect(x: -ds * 2.1, y: -ds * 2.1, width: ds * 4.2, height: ds * 4.2)),
            with: .radialGradient(
                Gradient(colors: [ivory.opacity(0.20 * pose.alpha), .clear]),
                center: .zero,
                startRadius: 0,
                endRadius: ds * 2.1
            )
        )

        // Wings: two quadratic curves from wingtip to body to wingtip,
        // stroked with round caps and a soft glow.
        var wings = Path()
        wings.move(to: CGPoint(x: -ds, y: -lift))
        wings.addQuadCurve(to: .zero, control: CGPoint(x: -ds * 0.45, y: ds * 0.22))
        wings.addQuadCurve(to: CGPoint(x: ds, y: -lift), control: CGPoint(x: ds * 0.45, y: ds * 0.22))

        var wingCtx = ctx
        wingCtx.addFilter(.shadow(color: ivory.opacity(0.7 * pose.alpha), radius: ds * 0.35))
        wingCtx.stroke(
            wings,
            with: .color(ivory.opacity(0.95 * pose.alpha)),
            style: StrokeStyle(lineWidth: max(1.1, ds * 0.24), lineCap: .round)
        )

        // Body
        ctx.fill(
            Path(ellipseIn: CGRect(x: -ds * 0.20, y: -ds * 0.07, width: ds * 0.40, height: ds * 0.26)),
            with: .color(ivory.opacity(0.9 * pose.alpha))
        )
    }
}
```

- [ ] **Step 3: Build to verify**

Run from repo root:
```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' build
```
Expected: `** BUILD SUCCEEDED **`.

---

### Task 3: Integrate into HadithScreen

**Files:**
- Modify: `Thaqalayn/Views/Onboarding/HadithScreen.swift:18-25` (the top of the ZStack)

**Interfaces:**
- Consumes: `ShrineDovesLayer` from Tasks 1-2; existing `isVisible` state and `FloatingEmbers` in `HadithScreen.swift`.
- Produces: final user-visible feature. No API changes.

- [ ] **Step 1: Add the layer to the ZStack**

In `Thaqalayn/Views/Onboarding/HadithScreen.swift`, replace:

```swift
        ZStack {
            OnboardingBackground(tilt: .peach)

            // Ambient drifting gold embers behind the card
            FloatingEmbers()
                .opacity(isVisible ? 1 : 0)
                .animation(Animation.easeOut(duration: 1.2).delay(0.5), value: isVisible)
```

with:

```swift
        ZStack {
            OnboardingBackground(tilt: .peach)

            // Ambient drifting gold embers behind the card
            FloatingEmbers()
                .opacity(isVisible ? 1 : 0)
                .animation(Animation.easeOut(duration: 1.2).delay(0.5), value: isVisible)

            // Doves wheeling above the rim-lit shrine silhouette
            ShrineDovesLayer()
                .opacity(isVisible ? 1 : 0)
                .animation(Animation.easeOut(duration: 1.0).delay(0.2), value: isVisible)
```

(The layer sits after FloatingEmbers and before the content VStack, so embers drift behind, doves and shrine render above them, and all text/cards stay on top.)

- [ ] **Step 2: Build to verify**

Run from repo root:
```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'platform=iOS Simulator,id=00CE7494-2523-4F1B-AF96-30D7969096C1' build
```
Expected: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Hand off to the user for visual verification**

The user verifies in the Simulator themselves (agent stops at green build). Verification notes for the user:
- Onboarding only shows on first launch. To re-see it: `xcrun simctl uninstall booted MAHR.Partner.Thaqalayn` is NOT enough; also flush UserDefaults with `defaults delete` per the fresh-install reset procedure (bundle id `MAHR.Partner.Thaqalayn`).
- Expected: two doves already wheeling at fade-in; five-dove sweep from upper-left at ~0.4s crossing above the title, descending the right edge, settling into orbits above the rim-lit dome; flap/glide alternation while wheeling; tap-to-continue still works everywhere on screen.
- Reduce Motion (Settings -> Accessibility -> Motion): static shrine + 4 gliding doves, no movement.
