# Journey-Start Notifications — Design Spec

**Date:** 2026-05-17
**Status:** Approved (design), pending implementation plan
**Deliverable:** A local notification announcing that a seasonal Journey tab
(Ramadan, Hajj/Dhul-Hijjah, Muharram) has become available, fired when the tab
appears. Generalized so future journeys are one table entry.

---

## 1. Goal

When a seasonal Journey tab appears in `MainTabView`, the user receives a local
notification telling them the Journey is open, deep-linking into that Journey's
tab. Applies uniformly to all journeys (Ramadan, Hajj, Muharram, and any future
journey).

## 2. Locked Decisions

| Decision | Choice |
|----------|--------|
| Fire timing | **When the tab appears** — at the start of the lead-in window (25 Sha'ban / 25 Dhul-Qa'dah / 25 Dhul-Hijjah), not day 1 of the sacred month |
| Missed window | If the user's first app open in the cycle is *after* the tab appeared (scheduled date passed), fire a **catch-up** notification shortly after that open — **exactly once per journey per year** |
| Opt-in gating | **Match the Arafah precedent**: fire only if iOS notification permission is already `.authorized`; never request permission here; ignore the in-app daily-verse toggle; no new Settings UI |
| Structure | Data-driven table + one scheduler method inside `NotificationManager` (where `scheduleArafahReminder()` already lives) |

## 3. Journey Table

A private `[JourneyAnnouncement]` table in `NotificationManager`. Each entry:
`id`, `title`, `body`, lead-in Hijri month/day, content-year mapping, an
`isSeasonActive` closure (existing season check), an `isWithinAnnounceWindow`
closure, and the `MainTabView` tab tag.

| Journey | `id` | Tab appears (Hijri lead-in) | Content month | `cycleYear` C = Hijri year of content | Lead-in Hijri year for cycle C | Tab tag |
|---------|------|------------------------------|---------------|----------------------------------------|---------------------------------|---------|
| Ramadan | `ramadan` | 25 Sha'ban (8 / 25) | Ramadan (9) | year of Ramadan | **C** | 4 |
| Hajj | `hajj` | 25 Dhul-Qa'dah (11 / 25) | Dhul-Hijjah (12) | year of Dhul-Hijjah | **C** | 5 |
| Muharram | `muharram` | 25 Dhul-Hijjah (12 / 25) | Muharram (1) | year of Muharram | **C − 1** | 6 |

**Muharram rollover (call out for TDD):** Muharram's lead-in (25 Dhul-Hijjah) is
in Hijri year `C − 1`, but its content month (Muharram) is Hijri year `C`.
General rule, valid at **any** app-open time (including unrelated months when
Path A schedules far ahead):

> `cycleYear = currentIslamicYear() + (currentIslamicMonth() == 1 ? 0 : 1)`

Instances of that rule:
- Opened during Muharram itself (month 1) → `currentIslamicYear()` = `C` → `cycleYear` = `currentIslamicYear()`.
- Opened during the Dhul-Hijjah lead-in (month 12) → `currentIslamicYear()` = `C − 1` → `cycleYear` = `currentIslamicYear() + 1`.
- Opened in any other month (e.g. Rabi' al-Awwal) → next Muharram is `currentIslamicYear() + 1` → `cycleYear` = `currentIslamicYear() + 1`.

Ramadan and Hajj have lead-in and content in the same Hijri year (the Hijri new
year falls at Muharram, away from both windows), so `cycleYear` =
`currentIslamicYear()` for them in every relevant month.

## 4. Scheduler — `scheduleJourneyStartNotifications()`

`@MainActor async`, on `NotificationManager`. Mirrors `scheduleArafahReminder()`'s
guards (permission, `preferences.time`, idempotent identifier, "skip if passed").

A persisted `handledYears[id] = cycleYear` records that the announcement for a
journey's cycle has been **committed** (either the calendar notification was
first scheduled, or the catch-up fired). `handledYears` gates the catch-up so it
fires at most once per cycle, **and** prevents the lead-in-day double-fire
(calendar fires at the preferred time, then a later same-day reopen must not
also fire a catch-up).

Per journey, after guarding iOS permission is `.authorized` (return otherwise,
**never request**), resolve the lead-in fire `Date` (`preferences.time` on the
lead-in calendar day) and `cycleYear`, then:

- **Path A — lead-in fire date is in the future:** schedule/refresh an
  idempotent `UNCalendarNotificationTrigger` with identifier
  `journey_start_<id>` at that date (remove any existing pending request with
  that id first, then add — the Arafah pattern). The calendar request is
  re-materialized on **every** call while the fire date is still in the future,
  *regardless* of `handledYears` — this is what survives the daily-verse
  `removeAllPendingNotificationRequests()` wipe (mirrors Arafah). If this is the
  first time it is scheduled for this `cycleYear` (`handledYears[id] !=
  cycleYear`), also set `handledYears[id] = cycleYear`.
- **Path B — lead-in fire date already passed, currently within the announce
  window, and `handledYears[id] != cycleYear`:** schedule a ~5 s
  `UNTimeIntervalNotificationTrigger` (id `journey_start_<id>`) as a catch-up,
  then set `handledYears[id] = cycleYear`.
- **Path C — lead-in passed and outside the announce window, OR
  `handledYears[id] == cycleYear` (already committed this cycle):** do nothing.

`handledYears` gates only the catch-up and the one-time mark; the calendar
notification is always (re)materialized while its fire date is in the future, so
a wipe is recoverable on the next app open before the lead-in. `handledYears`
re-arms naturally each new cycle because `cycleYear` differs.

### Invocation points

1. **`ContentView.onAppear`** — add an **unconditional** call to
   `scheduleJourneyStartNotifications()` next to the existing
   `if isHajjSeason() { scheduleArafahReminder() }`. It must be unconditional
   (not season-gated) because Path A schedules *before* any season is active.
   The method self-guards per journey.
2. **`NotificationManager.scheduleNotifications()`** — after the existing
   `cancelAllNotifications()` (which currently re-arms Arafah), also call
   `scheduleJourneyStartNotifications()`. Rationale: the daily-verse 7-day
   reschedule calls `removeAllPendingNotificationRequests()`, which would wipe a
   pending `journey_start_*`. Path A re-materializes the calendar request
   (idempotent, while still future); `handledYears` prevents a re-fired catch-up.

## 5. Announce Window (catch-up only)

The full **season window** (tab visible) includes a post-content grace tail. A
catch-up "the Journey is open" must NOT fire in that tail (e.g. on Eid /
Shawwal). The on-time scheduled notification (Path A) is unaffected — it always
fires at the very start.

| Journey | Season window (tab visible) | Announce window (catch-up allowed) |
|---------|------------------------------|-------------------------------------|
| Ramadan | Sha'ban 25–30, Ramadan 1–30, Shawwal 1–5 | Sha'ban 25–30, Ramadan 1–30 (**not** Shawwal tail) |
| Hajj | Dhul-Qa'dah 25–30, Dhul-Hijjah 1–13 | Dhul-Qa'dah 25–30, Dhul-Hijjah 1–10 (**not** 11–13 Tashriq tail) |
| Muharram | Dhul-Hijjah 25–30, Muharram 1–12 | Dhul-Hijjah 25–30, Muharram 1–10 (**not** 11–12 grace) |

## 6. Notification Copy

Tone is per-journey. Muharram is solemn, matching the existing
`muharramSeasonStatus()` register ("Ya Husayn (AS)"); no celebratory emoji.

- **Ramadan** — Title: `🌙 The Ramadan Journey is open` · Body: `The blessed month draws near. Step into your Ramadan Journey through the Quran. Tap to begin.`
- **Hajj** — Title: `🕋 The Dhul-Hijjah Journey is open` · Body: `The sacred days of Hajj approach. Begin your 10-day Dhul-Hijjah Journey. Tap to enter.`
- **Muharram** — Title: `The Muharram Journey is open` · Body: `The month of Imam al-Husayn (AS) approaches. Walk the first ten days of Muharram in remembrance. Tap to begin.`

All notifications: `sound = .default`, `badge = 1`, `categoryIdentifier =
"JOURNEY_START"`, `userInfo = ["type": "journey_start", "journey": "<id>"]`.

## 7. Tap → Open the Journey Tab

Parallels the existing verse deep-link path exactly:

1. **`NotificationDelegate.didReceive`** — add a branch: if
   `userInfo["type"] == "journey_start"`, open
   `thaqalayn://journey?id=<journey>`. (Existing surah/verse branch unchanged;
   journey notifications carry no `surah` key so they never enter it.)
2. **`ThaqalaynApp.handleDeepLink`** — add `else if scheme == "thaqalayn" &&
   host == "journey"` → new `handleJourneyDeepLink(url)` that parses `id` and
   posts `.navigateToJourney` with `userInfo = ["journey": id]`.
3. **`ContentView` `Notification.Name` extension** — add
   `static let navigateToJourney = Notification.Name("NavigateToJourney")`.
4. **`MainTabView`** — add
   `.onReceive(NotificationCenter.default.publisher(for: .navigateToJourney))`:
   map `id` → tab tag (`ramadan`→4, `hajj`→5, `muharram`→6) and set
   `selectedTab`. Guard: only switch if that journey's season is active (tab
   present). It will be, since the notification fires at/after the lead-in.

## 8. Persistence

- UserDefaults key `journeyStartHandledYears`, a JSON-encoded `[String: Int]`
  (`journeyId` → `cycleYear` that has been committed). Encoded/decoded with
  `JSONEncoder`/`JSONDecoder`, matching the pattern used by other managers.
- Written when an announcement is first committed for a cycle — on Path A's
  first calendar schedule for that `cycleYear`, or on Path B's catch-up. Read on
  Paths A/B/C to gate the catch-up and the one-time mark. Naturally re-arms each
  new cycle because `cycleYear` differs (same idea as
  `MuharramJourneyManager.checkYearReset`).
- The calendar trigger itself is re-materialized whenever its fire date is still
  in the future, independent of this map (wipe-recoverable, Arafah-style).

## 9. Testing

This repo has **no Swift test target** and zero existing Swift tests; per
project convention this feature ships **without automated tests**. Instead:

- **Design for testability anyway:** the scheduling decision is a *pure*
  function that takes an injected "now" (`DateComponents` for the Islamic date
  + a `Date`) and a "catch-up already delivered?" input, and returns a decision
  enum (`.scheduleCalendar(fireDate:)` / `.catchUpNow` / `.noop`). It must not
  read `Date()` / `currentIslamicDate()` internally — callers pass them in. This
  keeps the logic verifiable and side-effect-free even without a harness.
- **Verification gate per task:** `xcodebuild -project Thaqalayn.xcodeproj
  -scheme Thaqalayn -destination 'generic/platform=iOS Simulator' build`
  succeeds (the repo's trusted check; SourceKit "cannot find type" on new files
  is a known false positive — trust xcodebuild).
- **Manual date-injection matrix** (exercised via a `#if DEBUG` temporary call
  site that feeds synthetic Islamic dates and asserts the returned decision; the
  scaffold is removed before completion). Cover at minimum:
  - `cycleYear` for all three journeys, **especially Muharram across the
    Dhul-Hijjah → Muharram boundary** (opened during lead-in vs. during Muharram
    yields the same `cycleYear`).
  - Decision A/B/C: future lead-in → A; past lead-in inside announce window, not
    yet delivered → B; past + outside window → C; catch-up already delivered
    this cycle → C.
  - Announce-window boundaries (Shawwal day 5 → C; Ramadan day 30 → B; Hajj
    Dhul-Hijjah day 11 → C).
  - Catch-up idempotency: same cycle, two opens in-window → exactly one catch-up.
  - Permission not `.authorized` → nothing scheduled, no state written.

## 10. Non-Goals (YAGNI)

- No countdown / "N days until" notifications, no day-1 "has begun" second
  notification (timing is *tab appearance only*).
- No permission request from this feature (Arafah precedent owns gating).
- No new Settings toggle or UI.
- No server push / remote notifications — local only; if the user never opens
  the app during the entire season, no notification (accepted).
- No changes to existing daily-verse, Arafah, or progress notifications beyond
  the one additive re-arm call in `scheduleNotifications()`.
- No fallback/alternative delivery paths (per repo `CLAUDE.md`): if permission
  is absent, fail closed (schedule nothing).

## 11. Success Criteria

- Opening the app before a lead-in date schedules a calendar notification that
  fires at `preferences.time` on the lead-in date, deep-linking to that
  Journey's tab.
- Opening the app for the first time after the lead-in (but within the announce
  window) delivers a catch-up within seconds — exactly once per journey/year.
- No notification fires in a post-content grace tail.
- Tapping any journey-start notification opens the correct Journey tab.
- A 4th future journey is added by appending one `JourneyAnnouncement` row plus
  its tab in `MainTabView` — no scheduler changes.
- Permission denied → nothing scheduled, no state written.
- `xcodebuild … build` succeeds and the Section 9 manual date-injection matrix
  produces the expected decision in every listed case.
