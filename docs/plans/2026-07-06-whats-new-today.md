# What's New on Today - Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add a single auto-queuing "What's New" spotlight card to the top of the Today tab that introduces a recently added feature and retires once the user opens or dismisses it; ship Deep Dives as the first entry (also its first Today-tab entry point).

**Architecture:** A static in-app registry (`WhatsNewCatalog.all`) of `WhatsNewItem`s feeds a `@MainActor` `WhatsNewManager` singleton that tracks per-item seen state in UserDefaults and publishes the current `spotlight`. A theme-adaptive `WhatsNewCard` renders it at position 1 in both Today layouts. Tapping routes cross-tab into the Deep Dive via the existing `DeepLinkRouter` pattern. Seen-state is device-local (no cloud sync). No backend, no remote config.

**Tech Stack:** Swift / SwiftUI, UserDefaults persistence, existing `ThemeManager` / `EmCard` / `EmIconChip` / `EmPressStyle` design system, `DeepLinkRouter` cross-tab routing, `CommentaryLanguage` localization.

---

## Conventions for this plan (read first)

This repo does **not** use XCTest and ships iOS work without an automated test target. So each task's verification is:

1. **Build gate** - the change compiles:
   ```bash
   xcodebuild -scheme Thaqalayn \
     -destination 'platform=iOS Simulator,id=5E7A1BA3-A540-4DF7-9BF4-4ED58E13821C' \
     build
   ```
   Expected: `** BUILD SUCCEEDED **`.
2. **`#if DEBUG` `#Preview`s** for visual verification of new views (the codebase's substitute for a test matrix - see the previews in `DailyCrosswordCard.swift`).
3. **Simulator behavior checks** for the end-to-end flow (Task 8).

Notes:
- **Do not trust SourceKit "cannot find type in scope" errors** on newly added files - the index is stale. Trust `xcodebuild`.
- **Never use an em dash** in code, comments, or copy - use a plain `-`.
- **Commits are the user's** - do not run `git commit`. Each "Checkpoint" marks a good place for the user to commit; leave it to them.
- The booted simulator is **iPhone 17 Pro Max, id `5E7A1BA3-A540-4DF7-9BF4-4ED58E13821C`**. App bundle id is **`MAHR.Partner.Thaqalayn`**.
- New `.swift` files under `Thaqalayn/` are picked up automatically (Xcode 16 synced folder groups) - no `.pbxproj` edits.

Design reference: `docs/plans/2026-07-06-whats-new-today-design.md`.

---

## Task 1: Data model - `WhatsNewItem` + catalog

**Files:**
- Create: `Thaqalayn/Models/WhatsNewItem.swift`

**Step 1: Create the file with the model, destination enum, and catalog (Deep Dives entry).**

English copy is authored here now; Urdu/Arabic are placeholders finalized in Task 7.

```swift
//
//  WhatsNewItem.swift
//  Thaqalayn
//
//  One "What's New" feature announcement plus the static registry that feeds the
//  Today-tab spotlight. Mirrors DeepDiveDescriptor.all / JourneyCatalog: adding an
//  announcement is a pure content addition here. No backend.
//

import Foundation

/// Where tapping a What's New card takes the user.
enum WhatsNewDestination: Equatable {
    /// Open an immersive deep dive by id (lives in the Journey hub, tab 4).
    case deepDive(String)
    // Reserved for later: case journey(String), case tab(Int)
}

/// One feature announcement. Copy is per-language (EN / UR / AR), matching the Today tab.
struct WhatsNewItem: Identifiable, Equatable {
    let id: String
    let sfSymbol: String
    let releaseDate: Date
    let destination: WhatsNewDestination

    private let titleEN: String, titleUR: String, titleAR: String
    private let blurbEN: String, blurbUR: String, blurbAR: String
    private let ctaEN: String, ctaUR: String, ctaAR: String

    init(id: String, sfSymbol: String, releaseDate: Date, destination: WhatsNewDestination,
         titleEN: String, titleUR: String, titleAR: String,
         blurbEN: String, blurbUR: String, blurbAR: String,
         ctaEN: String, ctaUR: String, ctaAR: String) {
        self.id = id; self.sfSymbol = sfSymbol; self.releaseDate = releaseDate
        self.destination = destination
        self.titleEN = titleEN; self.titleUR = titleUR; self.titleAR = titleAR
        self.blurbEN = blurbEN; self.blurbUR = blurbUR; self.blurbAR = blurbAR
        self.ctaEN = ctaEN; self.ctaUR = ctaUR; self.ctaAR = ctaAR
    }

    func title(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return titleAR; case .urdu: return titleUR; default: return titleEN }
    }
    func blurb(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return blurbAR; case .urdu: return blurbUR; default: return blurbEN }
    }
    func cta(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return ctaAR; case .urdu: return ctaUR; default: return ctaEN }
    }
}

enum WhatsNewCatalog {
    /// Author in any order; the manager sorts newest-first by releaseDate.
    static let all: [WhatsNewItem] = [
        WhatsNewItem(
            id: "deepDives-yaqin",
            sfSymbol: "eye",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 7, day: 6).date ?? .distantPast,
            destination: .deepDive("yaqin"),
            titleEN: "Deep Dives",
            titleUR: "ڈیپ ڈائیوز",          // TODO(Task 7): finalize
            titleAR: "الغوص العميق",         // TODO(Task 7): finalize
            blurbEN: "Yaqīn - Certainty. An immersive descent through three depths, from Qur'an to Karbala.",
            blurbUR: "…",                    // TODO(Task 7): finalize
            blurbAR: "…",                    // TODO(Task 7): finalize
            ctaEN: "Begin the descent",
            ctaUR: "…",                      // TODO(Task 7): finalize
            ctaAR: "…"                       // TODO(Task 7): finalize
        )
    ]

    static func byId(_ id: String) -> WhatsNewItem? { all.first { $0.id == id } }
}
```

**Step 2: Build.** Run the build gate command above. Expected: `** BUILD SUCCEEDED **`.

**Checkpoint** (user may commit): "Add WhatsNewItem model + catalog".

---

## Task 2: Chrome strings - `WhatsNewStrings`

**Files:**
- Create: `Thaqalayn/Views/WhatsNewStrings.swift`

The card's non-item labels ("What's New" eyebrow, "New" pill) localize like `TodayStrings`. Per-item title/blurb/cta already live on `WhatsNewItem`.

**Step 1: Create the file.**

```swift
//
//  WhatsNewStrings.swift
//  Thaqalayn
//
//  Chrome labels for the Today-tab What's New spotlight, keyed off the global
//  Settings -> Language picker. Per-item copy lives on WhatsNewItem, not here.
//

import Foundation

enum WhatsNewStrings {
    static func eyebrow(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "ما الجديد"; case .urdu: return "نیا کیا ہے"; default: return "What's New" }
    }
    static func newPill(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "جديد"; case .urdu: return "نیا"; default: return "New" }
    }
}
```

**Step 2: Build.** Expected: `** BUILD SUCCEEDED **`.

**Checkpoint** (user may commit): "Add WhatsNewStrings chrome localization".

---

## Task 3: State manager - `WhatsNewManager`

**Files:**
- Create: `Thaqalayn/Services/WhatsNewManager.swift`

**Step 1: Create the manager.**

```swift
//
//  WhatsNewManager.swift
//  Thaqalayn
//
//  Drives the Today-tab What's New spotlight. Tracks per-item seen state (opened OR
//  dismissed) in UserDefaults and publishes the current `spotlight`: the newest unseen
//  announcement, retired on open/dismiss or after a quiet long-stop. Device-local only -
//  seen-state is low-stakes and ephemeral, so it deliberately does not use the cloud
//  sync architecture.
//

import SwiftUI

@MainActor
final class WhatsNewManager: ObservableObject {
    static let shared = WhatsNewManager()

    /// The feature to spotlight right now, or nil when nothing is unseen.
    @Published private(set) var spotlight: WhatsNewItem?

    private let seenKey = "whatsNew.seenIds"
    private let surfacedKey = "whatsNew.firstSurfacedAt"
    private let seededKey = "whatsNew.didSeedFreshInstall"

    /// A never-touched card auto-retires after this long (the quiet long-stop).
    private let longStop: TimeInterval = 21 * 24 * 60 * 60

    private var seenIds: Set<String>
    private var firstSurfacedAt: [String: Date]

    private init() {
        let d = UserDefaults.standard
        seenIds = Set(d.stringArray(forKey: seenKey) ?? [])
        firstSurfacedAt = (d.dictionary(forKey: surfacedKey) as? [String: Date]) ?? [:]
        refresh()
    }

    /// Recompute the spotlight and stamp its first-surfaced time. Call on Today appear.
    func refresh() {
        let now = Date()
        let candidate = WhatsNewCatalog.all
            .sorted { $0.releaseDate > $1.releaseDate }
            .first { item in
                if seenIds.contains(item.id) { return false }
                if let t = firstSurfacedAt[item.id], now.timeIntervalSince(t) > longStop { return false }
                return true
            }
        if let item = candidate, firstSurfacedAt[item.id] == nil {
            firstSurfacedAt[item.id] = now
            persist()
        }
        spotlight = candidate
    }

    /// User opened the feature - retire it and advance the queue.
    func markOpened(_ id: String) { retire(id) }
    /// User dismissed the card - retire it and advance the queue.
    func dismiss(_ id: String) { retire(id) }

    private func retire(_ id: String) {
        seenIds.insert(id)
        persist()
        refresh()
    }

    /// Fresh-install suppression: a brand-new user is discovering the whole app, so mark
    /// every currently-shipped announcement as already seen. Only features added in LATER
    /// updates will surface for them. Idempotent. Call from the app's first-launch path.
    func seedAllAsSeenForFreshInstall() {
        let d = UserDefaults.standard
        guard !d.bool(forKey: seededKey) else { return }
        seenIds.formUnion(WhatsNewCatalog.all.map { $0.id })
        d.set(true, forKey: seededKey)
        persist()
        refresh()
    }

    private func persist() {
        let d = UserDefaults.standard
        d.set(Array(seenIds), forKey: seenKey)
        d.set(firstSurfacedAt, forKey: surfacedKey)
    }

    #if DEBUG
    /// Wipe all What's New state so the spotlight reappears. Driven by -wnReset (Task 8).
    func debugReset() {
        let d = UserDefaults.standard
        [seenKey, surfacedKey, seededKey].forEach { d.removeObject(forKey: $0) }
        seenIds = []; firstSurfacedAt = [:]
        refresh()
    }
    #endif
}
```

**Step 2: Build.** Expected: `** BUILD SUCCEEDED **`.

Note: `[String: Date]` persists cleanly in UserDefaults (Date is a property-list type). If a future value type is added to the dictionary, switch to explicit `Codable` JSON encoding.

**Checkpoint** (user may commit): "Add WhatsNewManager (local seen-state + spotlight)".

---

## Task 4: Cross-tab deep-link into a Deep Dive

Reuses the established `DeepLinkRouter` + `JourneyHubView.consumePendingJourney` pattern.

**Files:**
- Modify: `Thaqalayn/Services/DeepLinkRouter.swift`
- Modify: `Thaqalayn/Views/JourneyHubView.swift`

**Step 1: Add the pending id to the router.**

In `DeepLinkRouter.swift`, after the `pendingJourneyId` property (line 26), add:

```swift
    /// Deep-dive id to auto-open once the Journey hub becomes the active tab. Set by a
    /// What's New card tap; consumed (and cleared) by JourneyHubView.
    @Published var pendingDeepDiveId: String? = nil
```

**Step 2: Consume it in the Journey hub.**

In `JourneyHubView.swift`, update the `.onAppear` (currently lines 112-119) and add an `.onChange` next to the existing one (line 120):

```swift
        .onAppear {
            consumePendingJourney()
            consumePendingDeepDive()
            #if DEBUG
            if ProcessInfo.processInfo.arguments.contains("-ddYaqin") {
                presentedDive = PresentedDeepDive(id: "yaqin")
            }
            #endif
        }
        .onChange(of: router.pendingJourneyId) { _, _ in consumePendingJourney() }
        .onChange(of: router.pendingDeepDiveId) { _, _ in consumePendingDeepDive() }
```

Then add this method next to `consumePendingJourney` (search for `private func consumePendingJourney` and place the new method directly after it):

```swift
    /// Opens a deep dive requested from another tab (e.g. a What's New card). The small
    /// delay lets the tab switch settle before the full-screen cover slides up.
    private func consumePendingDeepDive() {
        guard let id = router.pendingDeepDiveId else { return }
        router.pendingDeepDiveId = nil
        guard DeepDiveDescriptor.byId(id)?.dive != nil else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            presentedDive = PresentedDeepDive(id: id)
        }
    }
```

> If `consumePendingJourney` is defined below line 170 (not shown in the excerpt), just place `consumePendingDeepDive` immediately after it wherever it is.

**Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

**Checkpoint** (user may commit): "Add pendingDeepDiveId cross-tab route for Deep Dives".

---

## Task 5: The card - `WhatsNewCard`

Mirrors the theme-adaptive structure of `DailyCrosswordCard` (emerald body + legacy body, `EmPressStyle.gentle`, `Haptics.press()`). Adds a dismiss `x` as a sibling button (not nested) so the whole card taps to open. Fixed sizes - this is chrome, so it does **not** scale with the reading text-size control.

**Files:**
- Create: `Thaqalayn/Views/WhatsNewCard.swift`

**Step 1: Create the view.**

```swift
//
//  WhatsNewCard.swift
//  Thaqalayn
//
//  Today-tab "What's New" spotlight. Announces one recently added feature; the whole
//  card taps to open it, the x dismisses it (both retire it via WhatsNewManager). Drop
//  into TodayView / EmeraldTodayView, gated on WhatsNewManager.shared.spotlight != nil.
//
//  Chrome - fixed size (no ReadingSettingsManager scaling), matching DailyChallengeCard /
//  DailyCrosswordCard.
//

import SwiftUI

struct WhatsNewCard: View {
    let item: WhatsNewItem
    @Binding var selectedTab: Int

    @ObservedObject private var manager = WhatsNewManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var router = DeepLinkRouter.shared

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald { emeraldCard } else { legacyCard }
        }
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }

    // MARK: Actions

    private func open() {
        Haptics.press()
        manager.markOpened(item.id)
        switch item.destination {
        case .deepDive(let diveId):
            // Let the press squish play, then switch tabs; the hub opens the dive.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                router.pendingDeepDiveId = diveId
                selectedTab = 4
            }
        }
    }

    private func dismissCard() {
        Haptics.press()
        withAnimation(.easeInOut(duration: 0.2)) { manager.dismiss(item.id) }
    }

    // MARK: Shared bits

    private var newPill: some View {
        Text(WhatsNewStrings.newPill(lang).uppercased())
            .font(.system(size: 9, weight: .heavy)).tracking(1)
            .foregroundColor(themeManager.onAccentText)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Capsule().fill(themeManager.accentGradient))
    }

    private func dismissButton() -> some View {
        Button(action: dismissCard) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(themeManager.tertiaryText)
                .frame(width: 24, height: 24)
                .background(Circle().fill(Color.white.opacity(0.06)))
        }
        .buttonStyle(.plain)
        .padding(12)
    }

    // MARK: Emerald

    private var emeraldCard: some View {
        ZStack(alignment: lang.isRTL ? .topLeading : .topTrailing) {
            Button(action: open) {
                EmCard(glow: true) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(WhatsNewStrings.eyebrow(lang).uppercased())
                            .font(.system(size: 11, weight: .bold)).tracking(2)
                            .foregroundColor(themeManager.accentColor)

                        HStack(alignment: .top, spacing: 13) {
                            EmIconChip(sfSymbol: item.sfSymbol, size: 46)
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 8) {
                                    Text(item.title(lang))
                                        .font(EmType.serif(21, .semiBold))
                                        .foregroundColor(themeManager.primaryText)
                                        .lineLimit(1)
                                    newPill
                                }
                                Text(item.blurb(lang))
                                    .font(.system(size: 13))
                                    .foregroundColor(themeManager.secondaryText)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        Rectangle().fill(themeManager.strokeColor).frame(height: 1)

                        HStack(spacing: 6) {
                            Text(item.cta(lang))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeManager.accentBright)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(themeManager.accentBright)
                            Spacer()
                        }
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
            }
            .buttonStyle(EmPressStyle.gentle)

            dismissButton()
        }
    }

    // MARK: Legacy (Light / Night Sanctuary)

    private var legacyCard: some View {
        ZStack(alignment: lang.isRTL ? .topLeading : .topTrailing) {
            Button(action: open) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(WhatsNewStrings.eyebrow(lang).uppercased())
                        .font(.system(size: 11, weight: .bold)).tracking(2)
                        .foregroundColor(themeManager.accentColor)

                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle().fill(themeManager.accentGradient).frame(width: 50, height: 50)
                                .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                            Image(systemName: item.sfSymbol)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 8) {
                                Text(item.title(lang))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(themeManager.primaryText)
                                    .lineLimit(1)
                                newPill
                            }
                            Text(item.blurb(lang))
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.secondaryText)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Rectangle().fill(themeManager.strokeColor).frame(height: 1)

                    HStack(spacing: 6) {
                        Text(item.cta(lang))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                        Spacer()
                    }
                }
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.selectedTheme == .nightSanctuary
                              ? themeManager.glassSurface : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.strokeColor, lineWidth: 1))
                        .shadow(color: themeManager.selectedTheme == .nightSanctuary
                                ? Color.black.opacity(0.45) : Color.black.opacity(0.05),
                                radius: 12, x: 0, y: 4)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(EmPressStyle.gentle)

            dismissButton()
        }
    }
}

#if DEBUG
private func _wnPreviewItem() -> WhatsNewItem { WhatsNewCatalog.all[0] }

#Preview("What's New - English, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    return WhatsNewCard(item: _wnPreviewItem(), selectedTab: .constant(0))
        .padding(20).background(Color.black)
}

#Preview("What's New - English, Light") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    return WhatsNewCard(item: _wnPreviewItem(), selectedTab: .constant(0))
        .padding(20).background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#Preview("What's New - Urdu, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    return WhatsNewCard(item: _wnPreviewItem(), selectedTab: .constant(0))
        .padding(20).background(Color.black)
}
#endif
```

**Step 2: Build.** Expected: `** BUILD SUCCEEDED **`.

**Step 3: Visual check (previews).** Open `WhatsNewCard.swift` in Xcode, resume the canvas, and confirm all three previews render: gold "WHAT'S NEW" eyebrow, eye chip, "Deep Dives" + gold "NEW" pill, the blurb, a "Begin the descent ->" row, and the `x` in the correct corner (top-right for EN, top-left for Urdu). If SourceKit shows "cannot find type" errors, ignore them if the build in Step 2 succeeded.

**Checkpoint** (user may commit): "Add WhatsNewCard (theme-adaptive spotlight)".

---

## Task 6: Wire the card into Today + seeding

**Files:**
- Modify: `Thaqalayn/Views/TodayView.swift` (both `EmeraldTodayView` and `legacyContent`, plus `refresh()` on appear)
- Modify: `Thaqalayn/ContentView.swift` (fresh-install seed + DEBUG reset)

**Step 1: Emerald layout - observe the manager and insert the card at position 1.**

In `EmeraldTodayView` (the `@ObservedObject` block starting line 715), add:

```swift
    @ObservedObject private var whatsNew = WhatsNewManager.shared
```

In `EmeraldTodayView.body`, between `greeting` and `EmDailyReminderHero(...)` (currently lines 736-737), insert:

```swift
                if let item = whatsNew.spotlight {
                    WhatsNewCard(item: item, selectedTab: $selectedTab)
                }
```

In `EmeraldTodayView`'s existing `.onAppear` (lines 762-764), add `whatsNew.refresh()`:

```swift
        .onAppear {
            whatsNew.refresh()
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.6)) { animateProgress = true }
        }
```

**Step 2: Legacy layout - observe the manager and insert the card at position 1.**

In `TodayView` (the `@StateObject` block starting line 62), add:

```swift
    @StateObject private var whatsNew = WhatsNewManager.shared
```

In `legacyContent`, between the `greeting` block (ends line 147) and `DailyReminderBanner(...)` (starts line 149), insert:

```swift
                if let item = whatsNew.spotlight {
                    WhatsNewCard(item: item, selectedTab: $selectedTab)
                        .padding(.horizontal, 18)
                        .padding(.top, 6)
                }
```

In `TodayView.body`'s existing `.onAppear` (line 125), add the refresh:

```swift
        .onAppear { hasAppeared = true; whatsNew.refresh() }
```

**Step 3: Fresh-install seeding + DEBUG reset in ContentView.**

In `ContentView.swift`, update `checkFirstLaunch()` (lines 78-85):

```swift
    private func checkFirstLaunch() {
        // Only show welcome screen on first launch, not for authentication
        let hasShownWelcome = UserDefaults.standard.bool(forKey: "hasShownWelcome")

        if !hasShownWelcome {
            showingWelcome = true
            // Brand-new install: suppress the What's New backlog (whole app is new to them).
            WhatsNewManager.shared.seedAllAsSeenForFreshInstall()
        }

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-wnReset") {
            WhatsNewManager.shared.debugReset()
        }
        #endif
    }
```

> Confirm `checkFirstLaunch()` is actually invoked (it is called from ContentView's `.onAppear` / `.task`). If it is not wired, call it from ContentView's existing `.onAppear`.

**Step 4: Build.** Expected: `** BUILD SUCCEEDED **`.

**Checkpoint** (user may commit): "Surface What's New card on Today + fresh-install seeding".

---

## Task 7: Finalize Urdu + Arabic copy

The card is functional in English. Now fill the real Urdu and Arabic for the Deep Dives item and verify the chrome strings.

**Files:**
- Modify: `Thaqalayn/Models/WhatsNewItem.swift` (the `deepDives-yaqin` `titleUR/AR`, `blurbUR/AR`, `ctaUR/AR`)
- Modify (if needed): `Thaqalayn/Views/WhatsNewStrings.swift`

**Step 1: Produce translations.** Use the repo's translation agents for quality (per house style):
- `urdu-translator` for `titleUR`, `blurbUR`, `ctaUR`.
- `arabic-translator` for `titleAR`, `blurbAR`, `ctaAR`.

Source English:
- Title: `Deep Dives`
- Blurb: `Yaqīn - Certainty. An immersive descent through three depths, from Qur'an to Karbala.`
- CTA: `Begin the descent`

Keep "Yaqīn" transliterated in all languages (it is the dive's proper name). Dispatch the two agents in a single wave of two (per the two-agents-max rule); wait for both, then paste the results in, replacing the `…` / TODO placeholders. Do not use an em dash in any string.

**Step 2: Sanity-check the chrome strings** in `WhatsNewStrings.swift` (`ما الجديد` / `جديد` for Arabic; `نیا کیا ہے` / `نیا` for Urdu) against the translator output; adjust if the agent suggests better.

**Step 3: Build.** Expected: `** BUILD SUCCEEDED **`.

**Step 4: Preview check.** Resume the "What's New - Urdu, Emerald" preview; confirm the Urdu title/blurb/CTA read correctly and are right-aligned with the `x` in the top-left.

**Checkpoint** (user may commit): "Localize Deep Dives What's New copy (UR/AR)".

---

## Task 8: End-to-end behavior verification (the gate)

Verify the real flows in the booted simulator. Build + install once, then relaunch with args.

**Step 1: Build and install.**

```bash
xcodebuild -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,id=5E7A1BA3-A540-4DF7-9BF4-4ED58E13821C' \
  -derivedDataPath /tmp/thaqalayn-dd build

xcrun simctl install booted \
  "$(find /tmp/thaqalayn-dd/Build/Products -name 'Thaqalayn.app' -maxdepth 3 | head -1)"
```

**Step 2: Existing-user / appear path.** Reset What's New state and launch:

```bash
xcrun simctl launch --terminate-running-process booted MAHR.Partner.Thaqalayn -wnReset
```

Wait ~2s, then screenshot and inspect:

```bash
xcrun simctl io booted screenshot /tmp/wn-appear.png
```

Read `/tmp/wn-appear.png`. Expect the prominent "What's New / Deep Dives" card at position 1 on Today (above the gold "Reminder of the Day").

**Step 3: Open path.** Tap the card (drive via the simulator UI, or reason from the screenshot that the tap target is the card). Confirm it switches to the Journey tab and presents the Yaqīn deep dive full-screen. Screenshot `/tmp/wn-open.png` to confirm. Return to Today (relaunch without `-wnReset`): the card is gone (retired via `markOpened`).

```bash
xcrun simctl launch --terminate-running-process booted MAHR.Partner.Thaqalayn
xcrun simctl io booted screenshot /tmp/wn-after-open.png
```

Read `/tmp/wn-after-open.png`: no What's New card (Deep Dives is now seen); Today shows the reminder hero first.

**Step 4: Dismiss path.** Reset, relaunch with `-wnReset`, tap the `x`, confirm the card disappears in place; relaunch without the arg and confirm it does not return.

**Step 5: Theme check.** In the app, Settings -> switch to a Light theme, reset + relaunch with `-wnReset`, screenshot, and confirm the legacy card renders correctly (white card, gold gradient circle icon, "New" pill, CTA).

**Step 6: Fresh-install check.** Simulate a brand-new install so no What's New card should appear (per memory: `simctl uninstall` alone leaves UserDefaults cached, so flush cfprefsd):

```bash
xcrun simctl terminate booted MAHR.Partner.Thaqalayn 2>/dev/null || true
xcrun simctl uninstall booted MAHR.Partner.Thaqalayn
xcrun simctl spawn booted defaults delete MAHR.Partner.Thaqalayn 2>/dev/null || true
# reinstall from Step 1, then:
xcrun simctl launch booted MAHR.Partner.Thaqalayn
```

Go through onboarding to reach Today. Expect **no** What's New card (fresh-install seeding marked Deep Dives as already seen).

**Step 7: Record results.** Note pass/fail for each path (appear, open, dismiss, both themes, fresh-install) with the screenshot paths. If any fails, debug with superpowers:systematic-debugging before proceeding.

**Checkpoint** (user may commit): nothing to commit if all green (verification only).

---

## Task 9: Final full build + wrap-up

**Step 1: Clean release-config build** to catch anything `#if DEBUG` hid:

```bash
xcodebuild -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,id=5E7A1BA3-A540-4DF7-9BF4-4ED58E13821C' \
  -configuration Release build
```

Expected: `** BUILD SUCCEEDED **`. (Release strips the `#if DEBUG` previews, reset arg, and `debugReset()` - confirm nothing outside `#if DEBUG` references them.)

**Step 2: Confirm the file inventory.**
- New: `Thaqalayn/Models/WhatsNewItem.swift`, `Thaqalayn/Views/WhatsNewStrings.swift`, `Thaqalayn/Services/WhatsNewManager.swift`, `Thaqalayn/Views/WhatsNewCard.swift`.
- Modified: `Thaqalayn/Services/DeepLinkRouter.swift`, `Thaqalayn/Views/JourneyHubView.swift`, `Thaqalayn/Views/TodayView.swift`, `Thaqalayn/ContentView.swift`.

**Step 3: Summary** of what shipped, the verification results from Task 8, and the reminder that a version bump (`/bump-version`) and the commit are the user's to do at release time.

---

## Out of scope (do not build)

- Cloud sync of seen-state (device-local by design).
- Remote config / feature-flag backend (registry ships in the binary).
- Premium gating (Deep Dives is free; add a `requiresPremium` field on `WhatsNewItem` only when a premium feature needs announcing).
- Multiple simultaneous cards / a permanent changelog hub (the design is a single auto-queuing spotlight).
