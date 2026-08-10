# al-Kisa deep dive - implementation plan

Design doc (single source of truth for ALL content - transcribe, never rewrite):
`docs/plans/2026-08-09-kisa-deep-dive-design.md`

## Wave 1 - engine: the `salawat` beat (ONE atomic unit, two files)

### 1a. `Thaqalayn/Models/DeepDive.swift`

Add the new case directly after the `door` case declaration:

```swift
    /// The interactive close of a dive built on the gathering's answer (al-Kisa): five dim
    /// lights in a low arc - one for each soul beneath the cloak. Each tap lights the next
    /// name in the order the cloak gathered them (Muhammad ﷺ, Hasan, Husayn, Ali, Fatima);
    /// at five the arc joins into a single glow and resolves into the salawat formula. A
    /// count that COMPLETES at exactly five - the meaning-inverse of `count` (blessings
    /// cannot be counted; the beloved can). Replaces `reflectionPrompt` for such dives.
    case salawat(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
                 arabic: String, translation: LocalizedText, reference: String,
                 note: LocalizedText, nextLabel: LocalizedText)
```

In the computed `act`, extend the grouped close case to include `.salawat`:

```swift
        case .reflectionPrompt, .release, .count, .sujud, .extinguish, .door, .salawat, .dua, .closing: return 4
```

### 1b. `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

**State + fixed data** - insert after the `door` state block / `extinguishLights` array
(keep the neighborhood's comment style):

```swift
    /// The `salawat` beat's state machine (al-Kisa). Five dim lights on a low cloak-edge
    /// arc - one per soul beneath the cloak. Each tap lights the NEXT name in the order
    /// the cloak gathered them (soft haptic); at four lit the label turns ("One name
    /// remains", light haptic); the fifth tap joins the arc into a single glow and
    /// resolves into the salawat formula (success haptic). A count that COMPLETES at
    /// exactly five - the meaning-inverse of `count`. No timers.
    @State private var salawatLit = 0
    @State private var salawatDone = false

    /// One light of the salawat arc, at a fixed position in unit space, carrying its name.
    /// EN labels are fixed renderer strings for now (localization debt tracked with the
    /// dive's UR/AR pass).
    private struct SalawatLight: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let ar: String
        let en: String
    }
    /// The five souls beneath the cloak, in the order the cloak gathered them -
    /// left to right along a low arc.
    private let salawatLights: [SalawatLight] = [
        SalawatLight(id: 0, x: 0.08, y: 0.24, ar: "مُحَمَّد ﷺ", en: "Muhammad ﷺ"),
        SalawatLight(id: 1, x: 0.29, y: 0.56, ar: "الحَسَن", en: "Hasan"),
        SalawatLight(id: 2, x: 0.50, y: 0.68, ar: "الحُسَيْن", en: "Husayn"),
        SalawatLight(id: 3, x: 0.71, y: 0.56, ar: "عَلِيّ", en: "Ali"),
        SalawatLight(id: 4, x: 0.92, y: 0.24, ar: "فَاطِمَة", en: "Fatima"),
    ]
```

**placeInfo** - add alongside the other interactive cases:

```swift
        case .salawat(let tag, _, _, _, _, _, _, _): return (tag(lang), dive.acts.count)
```

**content switch** - add after the `.door` dispatch case (NO `default:` anywhere):

```swift
        case let .salawat(_, prompt, subline, arabic, translation, reference, note, nextLabel):
            salawatPage(prompt(lang), subline(lang), arabic, translation(lang), reference, note(lang), nextLabel(lang), show)
```

**Renderer** - insert a new MARK section after the `door` renderer functions, mirroring
`extinguishPage`'s structure exactly:

```swift
    // MARK: The salawat (al-Kisa) - the gathering's answer; a count that completes

    /// Idle: the prompt, the subline, and five dim lights on a low cloak-edge arc. Each
    /// tap lights the next name in the order the cloak gathered them - the order is
    /// enforced by the beat, not the finger. At four lit the label turns to "One name
    /// remains"; the fifth tap joins the arc into a single glow and resolves into the
    /// salawat formula.
    private func salawatPage(_ prompt: String, _ subline: String, _ arabic: String, _ translation: String, _ reference: String, _ note: String, _ nextLabel: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            if salawatDone {
                salawatField.padding(.bottom, 22)
                Text(arabic).font(EmType.arabic(26 * s, bold: true)).foregroundColor(DeepDivePalette.goldBright)
                    .multilineTextAlignment(.center).lineSpacing(10 * s)
                    .environment(\.layoutDirection, .rightToLeft)
                    .shadow(color: DeepDivePalette.goldBright.opacity(0.35), radius: 22)
                Text(translation).font(EmType.serifItalic(21 * s)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).lineSpacing(4 * s).padding(.top, 16).frame(maxWidth: 340)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                Text(reference.uppercased()).font(.system(size: 11, weight: .semibold)).tracking(2)
                    .foregroundColor(DeepDivePalette.gold.opacity(0.85)).padding(.top, 14)
                hairline.padding(.vertical, 22)
                Text(note).font(.system(size: 14 * s)).foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center).lineSpacing(5 * s).frame(maxWidth: 320)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                bob(nextLabel, true, 0.4).padding(.top, 30)
            } else {
                Text("✦").font(.system(size: 20)).foregroundColor(DeepDivePalette.gold)
                    .opacity(salawatLit > 0 ? 0.35 : 1)
                    .reveal(show, reduce: reduceMotion)
                Text(prompt).font(EmType.serif(34)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).padding(.top, 20)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .opacity(salawatLit > 0 ? 0.4 : 1)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: salawatLit)
                    .reveal(show, 0.15, reduce: reduceMotion)
                if salawatLit == 0 {
                    Text(subline).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.72))
                        .multilineTextAlignment(.center).lineSpacing(3 * s).padding(.top, 14).frame(maxWidth: 320)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                        .reveal(show, 0.3, reduce: reduceMotion)
                }
                salawatField
                    .padding(.top, salawatLit == 0 ? 30 : 14)
                    .reveal(show, 0.5, reduce: reduceMotion)
                Text((salawatLit == salawatLights.count - 1 ? "One name remains" : "Tap each light - greet them by name").uppercased())
                    .font(.system(size: salawatLit == salawatLights.count - 1 ? 12 : 10.5, weight: .semibold))
                    .tracking(salawatLit == salawatLights.count - 1 ? 4 : 3)
                    .foregroundColor(salawatLit == salawatLights.count - 1 ? DeepDivePalette.goldBright : DeepDivePalette.gold)
                    .shadow(color: salawatLit == salawatLights.count - 1 ? DeepDivePalette.goldBright.opacity(0.4) : .clear, radius: 12)
                    .padding(.top, 16)
                    .reveal(show, 0.6, reduce: reduceMotion)
            }
        }
        .background {
            if salawatDone {
                RadialGradient(colors: [DeepDivePalette.goldBright.opacity(0.10), .clear],
                               center: .center, startRadius: 10, endRadius: 280)
                    .allowsHitTesting(false)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: salawatDone)
    }

    /// The arc of five. The whole field takes the tap - each tap lights the next light
    /// in order, so the greeting always runs Muhammad ﷺ → Fatima, however the finger
    /// lands. On resolve the joined arc glows beneath the five and the names withdraw.
    private var salawatField: some View {
        GeometryReader { geo in
            ZStack {
                if salawatDone {
                    SalawatArc()
                        .stroke(DeepDivePalette.goldBright.opacity(0.55), lineWidth: 1.5)
                        .shadow(color: DeepDivePalette.goldBright.opacity(0.5), radius: 14)
                }
                ForEach(salawatLights) { light in
                    salawatDot(light)
                        .position(x: light.x * geo.size.width, y: light.y * geo.size.height + 24)
                }
            }
        }
        .frame(maxWidth: 310)
        .frame(height: salawatDone ? 120 : 165)
        .contentShape(Rectangle())
        .onTapGesture { tapSalawat() }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: salawatLit)
    }

    /// The joined cloak-edge curve drawn beneath the five on resolve.
    private struct SalawatArc: Shape {
        func path(in rect: CGRect) -> Path {
            var p = Path()
            p.move(to: CGPoint(x: rect.width * 0.08, y: rect.height * 0.24 + 24))
            p.addQuadCurve(to: CGPoint(x: rect.width * 0.92, y: rect.height * 0.24 + 24),
                           control: CGPoint(x: rect.width * 0.50, y: rect.height * 0.95 + 24))
            return p
        }
    }

    @ViewBuilder
    private func salawatDot(_ light: SalawatLight) -> some View {
        let isLit = light.id < salawatLit || salawatDone
        VStack(spacing: 6) {
            ZStack {
                if isLit {
                    Circle().fill(DeepDivePalette.goldBright)
                        .frame(width: 12, height: 12)
                        .shadow(color: DeepDivePalette.goldBright.opacity(0.8), radius: 12)
                } else {
                    Circle().stroke(DeepDivePalette.goldBright.opacity(0.25), lineWidth: 1)
                        .background(Circle().fill(DeepDivePalette.goldBright.opacity(0.08)).clipShape(Circle()))
                        .frame(width: 12, height: 12)
                }
            }
            .frame(width: 18, height: 18)
            if isLit && !salawatDone {
                VStack(spacing: 1) {
                    Text(light.ar).font(EmType.arabic(15)).foregroundColor(DeepDivePalette.goldBright)
                    Text(light.en.uppercased()).font(.system(size: 8, weight: .semibold)).tracking(1.2)
                        .foregroundColor(DeepDivePalette.mute)
                }
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .frame(width: 84, height: 64, alignment: .top)
    }

    private func tapSalawat() {
        guard !salawatDone else { return }
        if salawatLit < salawatLights.count - 1 {
            salawatLit += 1
            UIImpactFeedbackGenerator(style: salawatLit == salawatLights.count - 1 ? .light : .soft).impactOccurred()
        } else {
            salawatLit = salawatLights.count
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.6)) { salawatDone = true }
        }
    }
```

**Begin-again reset** - in the aminBlock reset closure, after the `door` lines:

```swift
                        salawatLit = 0; salawatDone = false
```

No timers, so no `.onDisappear` work for this beat.

## Wave 2a - content: `Thaqalayn/Content/KisaDeepDive.swift` (CREATE)

Mirror `IkhlasDeepDive.swift`'s file shape exactly (header comment naming the spine and
pointing at the design doc; `extension DeepDive { static let kisa: DeepDive = ... }`).
Engine fields from design doc §2 (id `kisa`, stageNoun/stageWord `Circle`, descendCta
`Enter`, beginCta `Enter the gathering`, mapLine `One cloak. Three circles around it.`,
endLine `The gathering disperses.`, scrollHint `Scroll to draw nearer`, estMinutes 5,
sfSymbol `moon.stars.fill`). All 17 sections transcribed VERBATIM from design doc §5 -
every string exactly as written there, bare string literals, curly quotes only where §5
has them, " - " never an em dash. Beat 16 is the new `.salawat` case; beat 17's `close:`
is `The promise is yours to keep.`

## Wave 2b - catalog + What's New

- `Thaqalayn/Services/DeepDiveCatalog.swift`: NEW descriptor between `taqwa` and `rida`,
  all fields per design doc §7 (`coverAssetName: "KisaCover"`).
- `Thaqalayn/Models/WhatsNewItem.swift`: `deepDives-kisa` entry per design doc §7,
  newest-first position; `releaseDate` = 2026-08-12 as an adjustable placeholder, with
  the existing entries' date style.

## Wave 3 - cover art (main agent, not a subagent)

Generate `KisaCover` (4:5, dark top for title text) per the surah-cover recipe; add
`Thaqalayn/Assets.xcassets/KisaCover.imageset/` mirroring an existing cover imageset's
`Contents.json`.

## Build gate (after every wave)

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -n 4
```

## Guardrails (Stage 4)

Per `references/technical-integration.md`: added-line em-dash grep, `strip_diacritics.py
--report`, no `lock.fill`, beat census grep (expect: open 1 · orientation 1 · depths 1 ·
act 3 · verse 3 · narration 4 · response 1 · climax 1 · salawat 1 · dua 1).
