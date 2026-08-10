# Taqwa Deep Dive - Implementation Plan

- **Date:** 2026-08-07
- **Design (source of truth):** `docs/plans/2026-08-07-taqwa-deep-dive-design.md`
- **Content strings:** transcribe VERBATIM from design doc §4. Do not rewrite.
- **Execution:** three build-gated waves. The engine change (Wave 1) is ONE atomic unit -
  `DeepDive.swift` + `DeepDiveView.swift` do not compile independently.

Build gate (run after every wave + a final independent run):
```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -n 4
```
Ignore SourceKit "cannot find type in scope" on new files (stale index); the green build is truth.

---

## WAVE 1 - Engine: the new `door` beat (atomic: both files together)

### 1a. `Thaqalayn/Models/DeepDive.swift`

**(i)** Add the case to `enum DeepDiveSection`, immediately after the `extinguish` case:
```swift
    /// The interactive close of a dive built on the guarding fear (Taqwa): a warm "forbidden"
    /// opening rests, then drifts across the screen and away. The reader must WITHHOLD - not
    /// touch it - and let it pass; holding still to the end of the drift resolves into the verse,
    /// while reaching for it (a tap) gently resets the drift ("it opens again"). The one
    /// interactive close in the series where acting is the failure - restraint itself is the
    /// gesture, the meaning-inverse of every tap/press/hold beat. Replaces `reflectionPrompt`.
    case door(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
              arabic: String, translation: LocalizedText, reference: String,
              note: LocalizedText, nextLabel: LocalizedText)
```

**(ii)** Add `.door` to the act-4 group in the computed `var act`:
```swift
        case .reflectionPrompt, .release, .count, .sujud, .extinguish, .door, .dua, .closing: return 4
```

### 1b. `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

**(i)** State block - add after the `extinguish` state block (~line 128):
```swift
    /// The `door` beat's state machine (Taqwa). A warm forbidden opening rests, then drifts
    /// across the screen and away; withholding - NOT touching it - is the gesture. Holding still
    /// through the drift resolves into the verse; reaching for it (a tap on the field) gently
    /// resets it. The one interactive close where acting is the failure.
    @State private var doorBegun = false        // beat reached; the pre-roll (reading window) is scheduled
    @State private var doorStarted = false       // the temptation is now drifting past
    @State private var doorOffset: CGFloat = 0    // 0 = resting at center, ~1.15 = drifted off to the right
    @State private var doorReached = false        // transient: the reader reached (tapped) - reset flash
    @State private var doorDone = false
    @State private var doorTimer: Timer? = nil
    private let doorDriftDuration: TimeInterval = 4.0
```

**(ii)** `placeInfo` - add case alongside the other interactive closes (~line 433):
```swift
        case .door(let tag, _, _, _, _, _, _, _): return (tag(lang), dive.acts.count)
```

**(iii)** content switch - add case after `.extinguish` (~line 531):
```swift
        case let .door(_, prompt, subline, arabic, translation, reference, note, nextLabel):
            doorPage(prompt(lang), subline(lang), arabic, translation(lang), reference, note(lang), nextLabel(lang), show)
```

**(iv)** Renderer + helpers - add after the `extinguish` section (after `resolveExtinguish`, ~line 1372):
```swift
    // MARK: The door (Taqwa) - restraint; withholding is the gesture

    /// Idle: the prompt, the subline, and a warm doorway of light resting at center - "Do not
    /// touch it - let it pass." After a short reading pre-roll the opening begins to drift away;
    /// the label turns to "Hold still - it is passing." Reaching for it (a tap on the field)
    /// flashes "It opens again," returns the glow to center, and restarts the drift. Holding
    /// still until it has passed resolves into 79:40-41.
    private func doorPage(_ prompt: String, _ subline: String, _ arabic: String, _ translation: String, _ reference: String, _ note: String, _ nextLabel: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            if doorDone {
                Text(arabic).font(EmType.arabic(27 * s, bold: true)).foregroundColor(DeepDivePalette.goldBright)
                    .multilineTextAlignment(.center).lineSpacing(10 * s)
                    .environment(\.layoutDirection, .rightToLeft)
                    .shadow(color: DeepDivePalette.goldBright.opacity(0.4), radius: 22)
                Text(translation).font(EmType.serifItalic(21 * s)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).lineSpacing(4 * s).padding(.top, 16).frame(maxWidth: 330)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                Text(reference).font(.system(size: 11, weight: .semibold)).tracking(2)
                    .foregroundColor(DeepDivePalette.gold.opacity(0.85)).padding(.top, 14)
                hairline.padding(.vertical, 22)
                Text(note).font(.system(size: 14 * s)).foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center).lineSpacing(5 * s).frame(maxWidth: 310)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                bob(nextLabel, true, 0.4).padding(.top, 30)
            } else {
                Text("✦").font(.system(size: 20)).foregroundColor(DeepDivePalette.gold)
                    .opacity(doorStarted ? 0.5 : 1)
                    .reveal(show, reduce: reduceMotion)
                Text(prompt).font(EmType.serif(33)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).padding(.top, 20)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .opacity(doorStarted || doorReached ? 0.4 : 1)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: doorStarted)
                    .reveal(show, 0.15, reduce: reduceMotion)
                if !doorStarted && !doorReached {
                    Text(subline).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.72))
                        .multilineTextAlignment(.center).lineSpacing(3 * s).padding(.top, 14).frame(maxWidth: 320)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                        .reveal(show, 0.3, reduce: reduceMotion)
                }
                doorField
                    .padding(.top, (doorStarted || doorReached) ? 18 : 30)
                    .reveal(show, 0.5, reduce: reduceMotion)
                Text((doorReached ? "It opens again" : (doorStarted ? "Hold still - it is passing" : "Do not touch it - let it pass")).uppercased())
                    .font(.system(size: doorStarted && !doorReached ? 12 : 10.5, weight: .semibold))
                    .tracking(doorStarted && !doorReached ? 4 : 3)
                    .foregroundColor(doorStarted && !doorReached ? DeepDivePalette.goldBright : DeepDivePalette.gold)
                    .shadow(color: doorStarted && !doorReached ? DeepDivePalette.goldBright.opacity(0.4) : .clear, radius: 12)
                    .padding(.top, 18)
                    .reveal(show, 0.6, reduce: reduceMotion)
            }
        }
        .background {
            if doorDone {
                RadialGradient(colors: [DeepDivePalette.goldBright.opacity(0.10), .clear],
                               center: .center, startRadius: 10, endRadius: 280)
                    .allowsHitTesting(false)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: doorReached)
        .onChange(of: show) { _, newValue in if newValue { beginDoor() } }
        .onAppear { if show { beginDoor() } }
        .onDisappear { doorTimer?.invalidate(); doorTimer = nil }
    }

    /// The warm forbidden opening, positioned by `doorOffset` (0 center → ~1.15 off the right edge).
    /// The whole field is the "reach zone": a tap anywhere on it counts as reaching for the door.
    private var doorField: some View {
        GeometryReader { geo in
            let x = (geo.size.width / 2) + doorOffset * (geo.size.width * 0.62)
            doorGlow
                .opacity(doorReached ? 0.4 : 1)
                .position(x: x, y: geo.size.height / 2)
        }
        .frame(maxWidth: 300)
        .frame(height: 190)
        .contentShape(Rectangle())
        .onTapGesture { reachDoor() }
    }

    /// A doorway of warm light - deliberately the one warm (amber) element in an emerald/gold
    /// dive, so the temptation reads as foreign to everything the descent has valued.
    private var doorGlow: some View {
        RoundedRectangle(cornerRadius: 44, style: .continuous)
            .fill(LinearGradient(colors: [Color(red: 0.91, green: 0.77, blue: 0.55).opacity(0.55),
                                          Color(red: 0.78, green: 0.47, blue: 0.23).opacity(0.24)],
                                 startPoint: .top, endPoint: .bottom))
            .frame(width: 78, height: 120)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(LinearGradient(colors: [Color(red: 1.0, green: 0.91, blue: 0.73).opacity(0.5), .clear],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 40, height: 86).offset(y: -6)
            )
            .shadow(color: Color(red: 0.89, green: 0.59, blue: 0.33).opacity(0.42), radius: 26)
    }

    /// Beat reached: schedule a short reading pre-roll (the idle instruction is visible), then drift.
    private func beginDoor() {
        guard !doorBegun, !doorDone else { return }
        doorBegun = true
        doorTimer?.invalidate()
        doorTimer = Timer.scheduledTimer(withTimeInterval: reduceMotion ? 1.2 : 1.6, repeats: false) { _ in
            startDoorDrift()
        }
    }

    private func startDoorDrift() {
        guard !doorDone else { return }
        doorStarted = true
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        withAnimation(reduceMotion ? nil : .easeIn(duration: doorDriftDuration)) { doorOffset = 1.15 }
        doorTimer?.invalidate()
        doorTimer = Timer.scheduledTimer(withTimeInterval: reduceMotion ? 3.0 : doorDriftDuration, repeats: false) { _ in
            resolveDoor()
        }
    }

    /// The reader reached for it (tapped the field): restraint broke. Gentle - no penalty. The
    /// opening returns to center and begins again.
    private func reachDoor() {
        guard doorBegun, !doorDone, !doorReached else { return }
        doorTimer?.invalidate()
        doorReached = true
        doorStarted = false
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.4)) { doorOffset = 0 }
        doorTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { _ in
            doorReached = false
            startDoorDrift()
        }
    }

    private func resolveDoor() {
        guard !doorDone else { return }
        doorTimer?.invalidate(); doorTimer = nil
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.6)) { doorDone = true }
    }
```

**(v)** Reset in `aminBlock`'s "Begin again" closure (add alongside the other beat resets, ~line 1574):
```swift
                        doorTimer?.invalidate(); doorTimer = nil
                        doorBegun = false; doorStarted = false; doorOffset = 0
                        doorReached = false; doorDone = false
```

**Wave 1 build gate → must be green before Wave 2.**

---

## WAVE 2 - Content: `Thaqalayn/Content/TaqwaDeepDive.swift`

CREATE the file. `extension DeepDive { static let taqwa: DeepDive = ... }`, mirroring
`IkhlasDeepDive.swift` structure (English-first bare literals). Transcribe every string
VERBATIM from design doc §4 (metadata, acts, 15 beats in order). Header comment names the
spine ("The Three Walls") and points at the design doc. New beat used: `.door`.

**Wave 2 build gate → must be green before Wave 3.**

---

## WAVE 3 - Catalog flip + What's New

### 3a. `Thaqalayn/Services/DeepDiveCatalog.swift`
Flip the existing `taqwa` descriptor: `available: true, dive: .taqwa`, and replace `subtitle`
with the trilingual pattern in design doc §6. Leave `title`/`titleAr`/`sfSymbol`/`coverAssetName`.

### 3b. `Thaqalayn/Models/WhatsNewItem.swift`
Add the `deepDives-taqwa` entry (design doc §6) at the newest-first position. If the
`.deepDive` destination + Deep-Dive handling already exists (it does for shipped dives), no
new `WhatsNewDestination` case is needed. `releaseDate` = ship-date placeholder (2026-08-07),
flagged adjustable at ship.

**Wave 3 build gate → green.**

---

## Stage 4 - Final build + guardrail greps (run myself)
```bash
# final independent build (truth)
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -n 4
# em dashes in ADDED lines only:
git diff -U0 -- Thaqalayn/Content/TaqwaDeepDive.swift Thaqalayn/Models/DeepDive.swift \
  Thaqalayn/Views/DeepDive/DeepDiveView.swift Thaqalayn/Services/DeepDiveCatalog.swift \
  Thaqalayn/Models/WhatsNewItem.swift | grep "^+" | grep "—"        # expect empty
grep -c "—" Thaqalayn/Content/TaqwaDeepDive.swift                   # expect 0
python3 scripts/strip_diacritics.py --report Thaqalayn/Content/TaqwaDeepDive.swift  # expect 0
grep -n "lock.fill" Thaqalayn/Content/TaqwaDeepDive.swift Thaqalayn/Views/DeepDive/DeepDiveView.swift  # expect empty
# beat census:
grep -o "\.\(open\|orientation\|depths\|act\|verse\|narration\|response\|climax\|door\|dua\)(" \
  Thaqalayn/Content/TaqwaDeepDive.swift | sort | uniq -c
```
Expected census: open 1, orientation 1, depths 1, act 3, verse 3, narration 2, response 1,
climax 1, door 1, dua 1. (Note `.act(` also matches BridgeVerse-free act cards; the bridge is a
field, not a case.)

No simulator launch (user does the device pass). No commit (user commits).
