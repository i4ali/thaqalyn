# What's New on Today - Design

- Date: 2026-07-06
- Status: Approved (design), ready for planning
- Topic: A "What's New" spotlight on the Today tab that auto-surfaces recently added/enabled features. First entry: Deep Dives.

## Goal

Give the Today tab a lightweight "What's New" area that automatically introduces a
recently added feature, then gets out of the way once the user has noticed it. The
immediate driver is the **Deep Dives** feature, which today has **no entry point on the
Today tab** (it is only reachable by scrolling to the bottom of the Journey tab). This
feature both announces Deep Dives and becomes its first Today-tab doorway.

"Auto" means: we author a one-line blurb per feature in a small in-app registry, and the
Today tab **auto-surfaces** the newest unseen one and **auto-retires** it once seen. No
backend, no remote config.

## Decisions (locked)

| Decision | Choice | Rationale |
|---|---|---|
| Structure | **Single auto-queuing spotlight** (one card at a time; next queued feature surfaces when the current retires; area disappears when nothing is unseen) | Simplest and most "auto"; still handles multiple releases via a queue; no permanent clutter |
| Retire trigger | **On open or dismiss**, plus a quiet **~21-day long-stop** | User-controlled, nothing lingers unexpectedly; long-stop prevents a never-tapped card from going stale |
| Visual treatment | **Prominent spotlight card** (variant A): icon chip, title, gold "New" pill, one-line blurb, CTA, small dismiss `x` | A genuinely new feature like Deep Dives deserves a real introduction; it is temporary so it won't clutter Today long-term |
| Placement | **Position 1** - directly under the greeting, above the gold "Reminder of the Day" | Highest visibility; acceptable because the card is transient (retires on open/dismiss) |

Mockup (rendered in the real Midnight-Emerald palette + Cormorant Garamond serif):
`scratchpad/whatsnew-mockup/` (variant A chosen).

## 1. Data model - `WhatsNewItem` + static catalog

A single value type plus a static registry, mirroring `DeepDiveDescriptor.all` /
`JourneyCatalog`:

```
struct WhatsNewItem: Identifiable {
    let id: String                 // stable, e.g. "deepDives-yaqin"
    let sfSymbol: String           // icon chip glyph, e.g. "eye"
    let releaseDate: Date          // newest-first ordering + recency
    let destination: WhatsNewDestination
    // Localized copy, keyed by CommentaryLanguage (EN / UR / AR):
    func title(_ lang) -> String
    func blurb(_ lang) -> String
    func cta(_ lang) -> String
}

enum WhatsNewDestination {
    case deepDive(String)          // v1: dive id, e.g. "yaqin"
    // Reserved for later: case journey(String), case tab(Int), case url(URL)
}

enum WhatsNewCatalog { static let all: [WhatsNewItem] = [ ... ] }
```

- An item only ever appears in the catalog in the **same release that ships its feature**,
  so "present in the catalog" == "available in this build" (no separate availability gate).
- Authoring a new "what's new" = appending one `WhatsNewItem`. This is the entire content
  source. No backend.

## 2. Manager - `WhatsNewManager`

`@MainActor final class WhatsNewManager: ObservableObject { static let shared }`

Local state, persisted to UserDefaults as JSON (device-local, no cloud sync):

- `seenIds: Set<String>` - an item enters this set when **opened or dismissed**.
- `firstSurfacedAt: [String: Date]` - when each item first became the active spotlight
  (drives the long-stop).

Published output:

- `spotlight: WhatsNewItem?` - the newest-by-`releaseDate` item in `WhatsNewCatalog.all`
  that is **not** in `seenIds` and **not** past its long-stop.

Methods:

- `markOpened(_ id)` and `dismiss(_ id)` -> insert into `seenIds`, persist, recompute
  `spotlight` (which surfaces the next queued item, if any).
- On computing `spotlight`, if the chosen item has no `firstSurfacedAt`, stamp it `= now`.

### Fresh-install seeding

On the first launch that includes this system (guarded by a one-time
`whatsNew.didSeed` flag):

- **Fresh install** (user has not completed onboarding / has no prior app data): seed all
  currently-shipped item ids into `seenIds`. A brand-new user is discovering the whole app;
  they should not be shown "What's New" for features that are simply part of the app. Only
  features added **after** they installed will surface.
- **Existing user updating into this build**: seed nothing, so Deep Dives surfaces
  immediately (correct - it is under-discovered and has no Today entry point today).

Detection uses the existing first-launch / onboarding marker (e.g. `hasShownWelcome`);
exact key to confirm during planning.

## 3. Lifecycle - the "auto" behavior

1. Newest unseen item becomes `spotlight`; `firstSurfacedAt` is stamped on first surface.
2. Card shows at position 1 on Today until the user **opens** it (tap -> feature) or
   **dismisses** it (`x`) -> id joins `seenIds` -> card retires.
3. If never touched, the card auto-retires once `now - firstSurfacedAt > 21 days`
   (long-stop).
4. On any retire, `spotlight` recomputes and the next queued item (if any) appears; when
   none remain, the What's New area is absent entirely.

## 4. Deep-link (tap -> open the dive across tabs)

Deep Dives lives in the Journey tab (tag 4), presented via `JourneyHubView`'s
`presentedDive` + `.fullScreenCover`. Reuse the established `DeepLinkRouter` pattern:

- Add `@Published var pendingDeepDiveId: String?` to `DeepLinkRouter`.
- Card tap: set `DeepLinkRouter.shared.pendingDeepDiveId = "yaqin"` and `selectedTab = 4`
  (the Today view already holds the `selectedTab` binding), after the existing 0.12s
  press-squish delay.
- `JourneyHubView`: consume `pendingDeepDiveId` in `onAppear` and `onChange` (mirroring
  `consumePendingJourney`), set `presentedDive = PresentedDeepDive(id:)`, then clear the
  pending id.
- Opening the feature also calls `WhatsNewManager.shared.markOpened(item.id)`.

## 5. UI - `WhatsNewCard`

- Theme-adaptive: built on `EmCard` + `ThemeManager` tokens (`accentGradient`, `glassSurfaceElevated`,
  `strokeColor`, `accentChip`, `primaryText`/`secondaryText`, `onAccentText`) so it renders
  correctly in **both** the Midnight-Emerald layout and the legacy Light/Night layout.
- Inserted at **position 1** in **both** `EmeraldTodayView.body` and `legacyContent`,
  rendered only when `WhatsNewManager.shared.spotlight != nil`.
- Layout (variant A): "What's New" gold eyebrow + dismiss `x` on top; icon chip + title +
  gold "New" pill + one-line blurb; a gold CTA row ("Begin the descent ->").
- Whole card is the tap target (opens the feature); the `x` dismisses.
- **Chrome, not reading content** - per CLAUDE.md it does **not** scale with the reading
  text-size control. Fixed sizes are correct here.

### Localization

- Chrome labels ("What's New", "New", default CTA) localize EN / UR / AR via the existing
  `TodayStrings` pattern.
- Per-item `title` / `blurb` / `cta` carry their own three translations on the
  `WhatsNewItem`.

## 6. First entry - Deep Dives (content)

- `id`: `"deepDives-yaqin"`
- `sfSymbol`: `"eye"` (matches the Yaqīn dive icon)
- `destination`: `.deepDive("yaqin")`
- `releaseDate`: the ship date of the release carrying this feature.
- Copy (EN authored now; UR + AR produced via the repo's `urdu-translator` /
  `arabic-translator` agents during implementation, matching how Journey/DeepDive strings
  are localized):
  - Title (EN): **Deep Dives**
  - Blurb (EN): **Yaqīn · Certainty - an immersive descent through three depths, from Qur'an to Karbala.**
  - CTA (EN): **Begin the descent**

## Out of scope (YAGNI)

- **No cloud sync** of seen-state - it is low-stakes and device-ephemeral; the
  BOOKMARK_SYNC architecture is intentionally not used here.
- **No remote-config / feature-flag backend** - the registry ships in the binary.
- **No premium-gating work** - Deep Dives is free. A `requiresPremium` field (show as
  upsell, route a locked tap to the normal paywall) can be added the day a premium feature
  needs announcing.

## Files

- New: `Thaqalayn/Models/WhatsNewItem.swift` (+ `WhatsNewCatalog`),
  `Thaqalayn/Services/WhatsNewManager.swift`,
  `Thaqalayn/Views/WhatsNewCard.swift`.
- Edited: `Thaqalayn/Services/DeepLinkRouter.swift`,
  `Thaqalayn/Views/JourneyHubView.swift`,
  `Thaqalayn/Views/TodayView.swift` (both `EmeraldTodayView` and `legacyContent`),
  `TodayStrings` (in `TodayView.swift`).

## Verification gate

- `xcodebuild` build succeeds (scheme Thaqalayn).
- Behavior, exercised in the simulator:
  - Existing-user path: Deep Dives spotlight appears at position 1 on Today; tapping opens
    the Yaqīn descent; card is gone on return.
  - Dismiss path: `x` removes the card; it does not return.
  - Fresh-install path: no What's New card for a brand-new user.
  - Both themes (Midnight-Emerald + a legacy theme) render the card correctly.
