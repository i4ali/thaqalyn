# Journey-Start Notifications Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fire a local notification announcing a seasonal Journey tab (Ramadan, Hajj, Muharram) has become available, when the tab appears, deep-linking into that Journey's tab.

**Architecture:** A data-driven `JourneyAnnouncement` table plus a *pure*, side-effect-free `journeyScheduleDecision(...)` function in a new `JourneyAnnouncements.swift`. An `@MainActor` `scheduleJourneyStartNotifications()` in `NotificationManager` calls the pure function and performs the UNUserNotificationCenter side effects + persistence. Invoked unconditionally from `ContentView.onAppear` and re-armed inside `NotificationManager.scheduleNotifications()`. Tap routing parallels the existing verse deep-link path.

**Tech Stack:** Swift, SwiftUI, UserNotifications, `Calendar(identifier: .islamicUmmAlQura)`. No test target (per project convention) — verification is `xcodebuild build` + a removable `#if DEBUG` date-injection matrix.

**Spec:** `docs/superpowers/specs/2026-05-17-journey-start-notifications-design.md`

**Conventions for this repo:**
- **Commits are the user's to make.** Each "Checkpoint" lists the files + a suggested message; do NOT run `git commit` automatically.
- **Build = source of truth.** SourceKit "cannot find type in scope" on new/edited files is a known false positive — trust `xcodebuild`.
- New `.swift` files in `Thaqalayn/` are auto-included via Xcode 16 synced folders — no `.pbxproj` edits.
- **Build command (used in every task):**
  ```bash
  xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination 'generic/platform=iOS Simulator' build
  ```
  Expected tail: `** BUILD SUCCEEDED **`

---

### Task 1: Journey table, types & pure scheduling decision

**Files:**
- Create: `Thaqalayn/Services/JourneyAnnouncements.swift`

- [ ] **Step 1: Create `Thaqalayn/Services/JourneyAnnouncements.swift`**

```swift
//
//  JourneyAnnouncements.swift
//  Thaqalayn
//
//  Data-driven table + a pure, side-effect-free scheduling decision for
//  "Journey is open" notifications. The decision function takes an injected
//  "now" and Hijri date so it is verifiable without a test harness.
//

import Foundation

/// One seasonal Journey that gets a "tab is now available" announcement.
struct JourneyAnnouncement {
    /// Stable id — also the deep-link `id` and the notification identifier suffix.
    let id: String
    /// Notification title.
    let title: String
    /// Notification body.
    let body: String
    /// Hijri month the tab appears (lead-in start). 8=Sha'ban, 11=Dhul-Qa'dah, 12=Dhul-Hijjah.
    let leadInHijriMonth: Int
    /// Hijri day the tab appears.
    let leadInHijriDay: Int
    /// True when the lead-in falls in the Hijri year *before* the content month
    /// (Muharram: lead-in 25 Dhul-Hijjah of year C-1, content Muharram of year C).
    let leadInIsPreviousHijriYear: Bool
    /// `MainTabView` tab tag this journey deep-links to.
    let tabTag: Int
    /// Whether the given Islamic (month, day) is inside this journey's announce
    /// window — narrower than the season window: it excludes the post-content
    /// grace tail so a late catch-up never fires on Eid etc.
    let isWithinAnnounceWindow: (_ islamicMonth: Int, _ islamicDay: Int) -> Bool

    /// The Hijri year of this journey's *content* month for the cycle `now`
    /// belongs to (the dedup key). See spec §3.
    func cycleYear(currentIslamicYear: Int, currentIslamicMonth: Int) -> Int {
        guard leadInIsPreviousHijriYear else {
            return currentIslamicYear // Ramadan / Hajj: lead-in & content share the year.
        }
        // Muharram: content year == current year only when we are already in
        // Muharram (month 1); otherwise the next Muharram is next Hijri year.
        return currentIslamicYear + (currentIslamicMonth == 1 ? 0 : 1)
    }

    /// The Hijri year the lead-in date itself falls in, for a given cycle year.
    func leadInHijriYear(forCycleYear cycleYear: Int) -> Int {
        leadInIsPreviousHijriYear ? cycleYear - 1 : cycleYear
    }
}

/// Outcome of the pure scheduling decision.
struct JourneyScheduleDecision: Equatable {
    /// If non-nil, ensure an idempotent calendar notification exists at this date.
    let calendarFireDate: Date?
    /// If true, fire the ~5s catch-up now.
    let fireCatchUpNow: Bool
    /// If non-nil, persist `handledYears[id] = this value`.
    let markHandledCycleYear: Int?

    static let noop = JourneyScheduleDecision(
        calendarFireDate: nil, fireCatchUpNow: false, markHandledCycleYear: nil
    )
}

extension JourneyAnnouncement {
    /// The canonical journeys. Adding a future journey = append one row here
    /// (+ its conditional tab in `MainTabView`); the scheduler is unchanged.
    static let all: [JourneyAnnouncement] = [
        JourneyAnnouncement(
            id: "ramadan",
            title: "🌙 The Ramadan Journey is open",
            body: "The blessed month draws near. Step into your Ramadan Journey through the Quran. Tap to begin.",
            leadInHijriMonth: 8, leadInHijriDay: 25,
            leadInIsPreviousHijriYear: false,
            tabTag: 4,
            isWithinAnnounceWindow: { month, day in
                (month == 8 && day >= 25) || month == 9 // Sha'ban 25-30 or all Ramadan; NOT Shawwal.
            }
        ),
        JourneyAnnouncement(
            id: "hajj",
            title: "🕋 The Dhul-Hijjah Journey is open",
            body: "The sacred days of Hajj approach. Begin your 10-day Dhul-Hijjah Journey. Tap to enter.",
            leadInHijriMonth: 11, leadInHijriDay: 25,
            leadInIsPreviousHijriYear: false,
            tabTag: 5,
            isWithinAnnounceWindow: { month, day in
                (month == 11 && day >= 25) || (month == 12 && day <= 10) // NOT the 11-13 tail.
            }
        ),
        JourneyAnnouncement(
            id: "muharram",
            title: "The Muharram Journey is open",
            body: "The month of Imam al-Husayn (AS) approaches. Walk the first ten days of Muharram in remembrance. Tap to begin.",
            leadInHijriMonth: 12, leadInHijriDay: 25,
            leadInIsPreviousHijriYear: true,
            tabTag: 6,
            isWithinAnnounceWindow: { month, day in
                (month == 12 && day >= 25) || (month == 1 && day <= 10) // NOT the 11-12 grace.
            }
        )
    ]
}

/// Pure, side-effect-free scheduling decision. The only calendar use is the
/// deterministic Hijri→Gregorian conversion via the injected `islamicCalendar`.
///
/// - Parameters:
///   - now: the current instant.
///   - islamicYear/Month/Day: the Hijri date of `now`.
///   - preferredHour/Minute: the user's notification time.
///   - islamicCalendar: an Umm al-Qura `Calendar` for Hijri→Gregorian.
///   - handledCycleYear: the cycleYear already committed for this journey, or nil.
func journeyScheduleDecision(
    journey: JourneyAnnouncement,
    now: Date,
    islamicYear: Int,
    islamicMonth: Int,
    islamicDay: Int,
    preferredHour: Int,
    preferredMinute: Int,
    islamicCalendar: Calendar,
    handledCycleYear: Int?
) -> JourneyScheduleDecision {
    let cycleYear = journey.cycleYear(
        currentIslamicYear: islamicYear,
        currentIslamicMonth: islamicMonth
    )
    let leadInHYear = journey.leadInHijriYear(forCycleYear: cycleYear)

    var hijri = DateComponents()
    hijri.year = leadInHYear
    hijri.month = journey.leadInHijriMonth
    hijri.day = journey.leadInHijriDay
    guard let leadInDay = islamicCalendar.date(from: hijri) else {
        return .noop
    }

    var gregorian = Calendar.current
    gregorian.timeZone = .current
    var fireComps = gregorian.dateComponents([.year, .month, .day], from: leadInDay)
    fireComps.hour = preferredHour
    fireComps.minute = preferredMinute
    let fireDate = gregorian.date(from: fireComps) ?? leadInDay

    if fireDate > now {
        // (Re)materialize the calendar notification — idempotent, wipe-recoverable.
        // Mark handled only the first time we commit this cycle.
        let mark = (handledCycleYear == cycleYear) ? nil : cycleYear
        return JourneyScheduleDecision(
            calendarFireDate: fireDate,
            fireCatchUpNow: false,
            markHandledCycleYear: mark
        )
    }

    // Lead-in instant has passed.
    if journey.isWithinAnnounceWindow(islamicMonth, islamicDay),
       handledCycleYear != cycleYear {
        return JourneyScheduleDecision(
            calendarFireDate: nil,
            fireCatchUpNow: true,
            markHandledCycleYear: cycleYear
        )
    }
    return .noop
}
```

- [ ] **Step 2: Build**

Run the build command. Expected tail: `** BUILD SUCCEEDED **`. (Ignore any editor "cannot find type" noise — trust the build.)

- [ ] **Step 3: Checkpoint** (user commits)

Files: `Thaqalayn/Services/JourneyAnnouncements.swift`, `docs/superpowers/specs/2026-05-17-journey-start-notifications-design.md`, `docs/superpowers/plans/2026-05-17-journey-start-notifications.md`
Suggested message: `feat: journey-start announcement table + pure scheduling decision`

---

### Task 2: Debug date-injection verification matrix (temporary scaffold)

**Files:**
- Modify: `Thaqalayn/Services/JourneyAnnouncements.swift` (append a `#if DEBUG` block)
- Modify: `Thaqalayn/ThaqalaynApp.swift:17-23` (call it once under `#if DEBUG`)

- [ ] **Step 1: Append the verification matrix to `JourneyAnnouncements.swift`**

Append at end of file:

```swift
#if DEBUG
extension JourneyAnnouncement {
    /// Temporary manual-verification scaffold (spec §9). Removed in the final
    /// task. Builds `now` from the synthetic Hijri date via the same Umm
    /// al-Qura calendar so future/past comparisons are deterministic.
    static func debugVerifyDecisionMatrix() {
        var islamic = Calendar(identifier: .islamicUmmAlQura)
        islamic.timeZone = .current

        func now(y: Int, m: Int, d: Int) -> Date {
            var c = DateComponents(); c.year = y; c.month = m; c.day = d
            return islamic.date(from: c) ?? Date()
        }
        func decide(_ j: JourneyAnnouncement, y: Int, m: Int, d: Int,
                    handled: Int?) -> JourneyScheduleDecision {
            journeyScheduleDecision(
                journey: j, now: now(y: y, m: m, d: d),
                islamicYear: y, islamicMonth: m, islamicDay: d,
                preferredHour: 9, preferredMinute: 0,
                islamicCalendar: islamic, handledCycleYear: handled
            )
        }

        let ramadan = all.first { $0.id == "ramadan" }!
        let hajj = all.first { $0.id == "hajj" }!
        let muharram = all.first { $0.id == "muharram" }!

        var failures: [String] = []
        func expect(_ name: String, _ cond: Bool) {
            if !cond { failures.append(name) }
            print("JOURNEY-MATRIX \(cond ? "PASS" : "FAIL"): \(name)")
        }

        // cycleYear integer math (the riskiest part — esp. Muharram rollover).
        expect("ramadan cycleYear in Sha'ban 1446 == 1446",
               ramadan.cycleYear(currentIslamicYear: 1446, currentIslamicMonth: 8) == 1446)
        expect("hajj cycleYear in Dhul-Qa'dah 1446 == 1446",
               hajj.cycleYear(currentIslamicYear: 1446, currentIslamicMonth: 11) == 1446)
        expect("muharram cycleYear during Dhul-Hijjah 1446 == 1447",
               muharram.cycleYear(currentIslamicYear: 1446, currentIslamicMonth: 12) == 1447)
        expect("muharram cycleYear during Muharram 1447 == 1447",
               muharram.cycleYear(currentIslamicYear: 1447, currentIslamicMonth: 1) == 1447)
        expect("muharram cycleYear in Rabi'-al-Awwal 1446 == 1447",
               muharram.cycleYear(currentIslamicYear: 1446, currentIslamicMonth: 3) == 1447)

        // Decision A: future lead-in → schedule calendar, no catch-up.
        let a = decide(ramadan, y: 1446, m: 8, d: 20, handled: nil)
        expect("ramadan 20 Sha'ban → calendar, no catch-up",
               a.calendarFireDate != nil && a.fireCatchUpNow == false && a.markHandledCycleYear == 1446)

        // Decision A re-arm: already handled → still re-materialize, don't re-mark.
        let aRe = decide(ramadan, y: 1446, m: 8, d: 20, handled: 1446)
        expect("ramadan 20 Sha'ban already handled → calendar, mark nil",
               aRe.calendarFireDate != nil && aRe.markHandledCycleYear == nil)

        // Decision B: past lead-in, in window, not handled → catch-up once.
        let b = decide(ramadan, y: 1446, m: 9, d: 3, handled: nil)
        expect("ramadan 3 Ramadan not handled → catch-up, mark 1446",
               b.calendarFireDate == nil && b.fireCatchUpNow == true && b.markHandledCycleYear == 1446)

        // Decision C: past lead-in, in window, already handled → noop.
        let cHandled = decide(ramadan, y: 1446, m: 9, d: 3, handled: 1446)
        expect("ramadan 3 Ramadan already handled → noop",
               cHandled == .noop)

        // Decision C: announce-window boundary — Shawwal tail excluded.
        let shawwal = decide(ramadan, y: 1446, m: 10, d: 3, handled: nil)
        expect("ramadan Shawwal 3 → noop (outside announce window)",
               shawwal == .noop)

        // Hajj boundary: Dhul-Hijjah day 11 is OUT of the announce window.
        let hajjTail = decide(hajj, y: 1446, m: 12, d: 11, handled: nil)
        expect("hajj Dhul-Hijjah 11 → noop (11-13 tail excluded)",
               hajjTail == .noop)
        let hajjIn = decide(hajj, y: 1446, m: 12, d: 5, handled: nil)
        expect("hajj Dhul-Hijjah 5 → catch-up",
               hajjIn.fireCatchUpNow == true && hajjIn.markHandledCycleYear == 1446)

        // Muharram catch-up keyed on the rolled-over cycleYear (1447).
        let muh = decide(muharram, y: 1447, m: 1, d: 4, handled: nil)
        expect("muharram 4 Muharram → catch-up, mark 1447",
               muh.fireCatchUpNow == true && muh.markHandledCycleYear == 1447)
        let muhGrace = decide(muharram, y: 1447, m: 1, d: 11, handled: nil)
        expect("muharram 11 Muharram → noop (11-12 grace excluded)",
               muhGrace == .noop)

        print(failures.isEmpty
              ? "JOURNEY DECISION MATRIX: ALL PASS"
              : "JOURNEY DECISION MATRIX: FAILURES \(failures)")
        assert(failures.isEmpty, "Journey decision matrix failures: \(failures)")
    }
}
#endif
```

- [ ] **Step 2: Call it once from `ThaqalaynApp.init()`**

In `Thaqalayn/ThaqalaynApp.swift`, the `init()` currently is:

```swift
    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        // Apply native chrome (UITabBar / UINavigationBar) for current theme
        ChromeAppearance.apply(for: ThemeManager.shared.selectedTheme)
    }
```

Replace it with:

```swift
    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        // Apply native chrome (UITabBar / UINavigationBar) for current theme
        ChromeAppearance.apply(for: ThemeManager.shared.selectedTheme)

        #if DEBUG
        JourneyAnnouncement.debugVerifyDecisionMatrix()
        #endif
    }
```

- [ ] **Step 3: Build**

Run the build command. Expected tail: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Run once and read the console**

Launch the app on an iOS Simulator (Xcode Run, or your usual flow). In the Xcode console expect a line:

```
JOURNEY DECISION MATRIX: ALL PASS
```

If any `JOURNEY-MATRIX FAIL: …` line appears (or the `assert` traps), fix the pure logic in `JourneyAnnouncements.swift` and repeat Steps 3–4. Do not proceed until ALL PASS.

- [ ] **Step 5: Checkpoint** (user commits)

Files: `Thaqalayn/Services/JourneyAnnouncements.swift`, `Thaqalayn/ThaqalaynApp.swift`
Suggested message: `test: temporary date-injection matrix for journey scheduling`

---

### Task 3: Scheduler + persistence in `NotificationManager`

**Files:**
- Modify: `Thaqalayn/Services/NotificationManager.swift` (insert after `scheduleArafahReminder()`, which ends at line ~585, before `cancelProgressNotifications()`)

- [ ] **Step 1: Add the scheduler, content builder, and persistence helpers**

In `Thaqalayn/Services/NotificationManager.swift`, find the end of `scheduleArafahReminder()` (the closing `}` of that method, just before `/// Cancel progress-related notifications`). Insert this block immediately after `scheduleArafahReminder()`'s closing brace:

```swift
    // MARK: - Journey-Start Notifications

    private let journeyHandledYearsKey = "journeyStartHandledYears"

    private func loadJourneyHandledYears() -> [String: Int] {
        guard let data = UserDefaults.standard.data(forKey: journeyHandledYearsKey),
              let decoded = try? JSONDecoder().decode([String: Int].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private func saveJourneyHandledYears(_ map: [String: Int]) {
        if let encoded = try? JSONEncoder().encode(map) {
            UserDefaults.standard.set(encoded, forKey: journeyHandledYearsKey)
        }
    }

    private func makeJourneyContent(_ journey: JourneyAnnouncement) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = journey.title
        content.body = journey.body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "JOURNEY_START"
        content.userInfo = ["type": "journey_start", "journey": journey.id]
        return content
    }

    /// Schedule "the Journey is open" notifications for all journeys.
    /// Mirrors `scheduleArafahReminder()`'s guards: only if already authorized;
    /// never requests permission. Safe to call on every app open and after
    /// `cancelAllNotifications()` (idempotent calendar identifier).
    @MainActor
    func scheduleJourneyStartNotifications() async {
        let settings = await notificationCenter.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let nowDate = Date()
        let comps = islamicCalendar.currentIslamicDate()
        guard let iYear = comps.year,
              let iMonth = comps.month,
              let iDay = comps.day else { return }

        let timeComps = Calendar.current.dateComponents([.hour, .minute], from: preferences.time)
        let prefHour = timeComps.hour ?? 9
        let prefMinute = timeComps.minute ?? 0

        var handled = loadJourneyHandledYears()

        for journey in JourneyAnnouncement.all {
            let decision = journeyScheduleDecision(
                journey: journey,
                now: nowDate,
                islamicYear: iYear,
                islamicMonth: iMonth,
                islamicDay: iDay,
                preferredHour: prefHour,
                preferredMinute: prefMinute,
                islamicCalendar: islamicCalendar.islamicCalendar,
                handledCycleYear: handled[journey.id]
            )

            let identifier = "journey_start_\(journey.id)"

            if let fireDate = decision.calendarFireDate {
                let dateComponents = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute], from: fireDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: makeJourneyContent(journey),
                    trigger: trigger
                )
                do {
                    try await notificationCenter.add(request)
                    print("✅ NotificationManager: journey-start scheduled (\(journey.id))")
                } catch {
                    print("❌ NotificationManager: journey-start calendar add (\(journey.id)) - \(error)")
                }
            }

            if decision.fireCatchUpNow {
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
                notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
                let request = UNNotificationRequest(
                    identifier: identifier,
                    content: makeJourneyContent(journey),
                    trigger: trigger
                )
                do {
                    try await notificationCenter.add(request)
                    print("✅ NotificationManager: journey-start catch-up (\(journey.id))")
                } catch {
                    print("❌ NotificationManager: journey-start catch-up add (\(journey.id)) - \(error)")
                }
            }

            if let markYear = decision.markHandledCycleYear {
                handled[journey.id] = markYear
            }
        }

        saveJourneyHandledYears(handled)
    }
```

- [ ] **Step 2: Build**

Run the build command. Expected tail: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Checkpoint** (user commits)

Files: `Thaqalayn/Services/NotificationManager.swift`
Suggested message: `feat: scheduleJourneyStartNotifications + handledYears persistence`

---

### Task 4: Wire invocation points

**Files:**
- Modify: `Thaqalayn/ContentView.swift:48-54` (`.onAppear`)
- Modify: `Thaqalayn/Services/NotificationManager.swift:227-230` (`scheduleNotifications()` re-arm)

- [ ] **Step 1: Unconditional call in `ContentView.onAppear`**

In `Thaqalayn/ContentView.swift`, the `.onAppear` is:

```swift
        .onAppear {
            checkFirstLaunch()
            ratingManager.recordAppLaunch()
            if IslamicCalendarManager.shared.isHajjSeason() {
                Task { await NotificationManager.shared.scheduleArafahReminder() }
            }
        }
```

Replace with:

```swift
        .onAppear {
            checkFirstLaunch()
            ratingManager.recordAppLaunch()
            if IslamicCalendarManager.shared.isHajjSeason() {
                Task { await NotificationManager.shared.scheduleArafahReminder() }
            }
            // Unconditional: Path A schedules before any season is active;
            // the scheduler self-guards per journey + on authorization.
            Task { await NotificationManager.shared.scheduleJourneyStartNotifications() }
        }
```

- [ ] **Step 2: Re-arm inside `scheduleNotifications()`**

In `Thaqalayn/Services/NotificationManager.swift`, `scheduleNotifications()` currently ends:

```swift
        // cancelAllNotifications() above also clears any pending Arafah reminder;
        // re-arm it during Hajj season so it survives daily-verse rescheduling.
        if islamicCalendar.isHajjSeason() {
            await scheduleArafahReminder()
        }
    }
```

Replace with:

```swift
        // cancelAllNotifications() above also clears any pending Arafah reminder;
        // re-arm it during Hajj season so it survives daily-verse rescheduling.
        if islamicCalendar.isHajjSeason() {
            await scheduleArafahReminder()
        }

        // cancelAllNotifications() also wipes pending journey-start requests;
        // re-materialize them (idempotent; handledYears prevents a re-fired catch-up).
        await scheduleJourneyStartNotifications()
    }
```

- [ ] **Step 3: Build**

Run the build command. Expected tail: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Checkpoint** (user commits)

Files: `Thaqalayn/ContentView.swift`, `Thaqalayn/Services/NotificationManager.swift`
Suggested message: `feat: invoke journey-start scheduler on appear + after cancelAll`

---

### Task 5: Deep-link plumbing (Notification.Name + app handlers + delegate)

**Files:**
- Modify: `Thaqalayn/ContentView.swift:10-13` (`Notification.Name` extension)
- Modify: `Thaqalayn/ThaqalaynApp.swift:34-76` (`handleDeepLink` + new `handleJourneyDeepLink`)
- Modify: `Thaqalayn/ThaqalaynApp.swift:112-132` (`NotificationDelegate.didReceive`)

- [ ] **Step 1: Add the `.navigateToJourney` name**

In `Thaqalayn/ContentView.swift`, the extension is:

```swift
extension Notification.Name {
    static let showAuthentication = Notification.Name("showAuthentication")
    static let navigateToVerse = Notification.Name("NavigateToVerse")
}
```

Replace with:

```swift
extension Notification.Name {
    static let showAuthentication = Notification.Name("showAuthentication")
    static let navigateToVerse = Notification.Name("NavigateToVerse")
    static let navigateToJourney = Notification.Name("NavigateToJourney")
}
```

- [ ] **Step 2: Add the `journey` host branch + handler in `ThaqalaynApp`**

In `Thaqalayn/ThaqalaynApp.swift`, `handleDeepLink(_:)` is:

```swift
    private func handleDeepLink(_ url: URL) {
        // Handle Supabase authentication callback
        if url.scheme == "thaqalayn" && url.host == "auth" {
            Task {
                await handleAuthCallback(url)
            }
        }
        // Handle verse deep link from notifications
        else if url.scheme == "thaqalayn" && url.host == "verse" {
            handleVerseDeepLink(url)
        }
    }
```

Replace with:

```swift
    private func handleDeepLink(_ url: URL) {
        // Handle Supabase authentication callback
        if url.scheme == "thaqalayn" && url.host == "auth" {
            Task {
                await handleAuthCallback(url)
            }
        }
        // Handle verse deep link from notifications
        else if url.scheme == "thaqalayn" && url.host == "verse" {
            handleVerseDeepLink(url)
        }
        // Handle journey deep link from journey-start notifications
        else if url.scheme == "thaqalayn" && url.host == "journey" {
            handleJourneyDeepLink(url)
        }
    }

    private func handleJourneyDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        var journeyId: String?
        for item in queryItems where item.name == "id" {
            journeyId = item.value
        }

        guard let id = journeyId else { return }

        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToJourney"),
            object: nil,
            userInfo: ["journey": id]
        )
    }
```

- [ ] **Step 3: Add the journey branch in `NotificationDelegate.didReceive`**

In `Thaqalayn/ThaqalaynApp.swift`, the tap handler is:

```swift
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Extract verse information
        if let surah = userInfo["surah"] as? Int,
           let verse = userInfo["verse"] as? Int {
            // Create deep link URL
            if let url = URL(string: "thaqalayn://verse?surah=\(surah)&verse=\(verse)") {
                // Post notification to app to handle navigation
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        }

        completionHandler()
    }
```

Replace with:

```swift
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Journey-start notification → open the journey's tab
        if let type = userInfo["type"] as? String, type == "journey_start",
           let journeyId = userInfo["journey"] as? String {
            if let url = URL(string: "thaqalayn://journey?id=\(journeyId)") {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
            completionHandler()
            return
        }

        // Extract verse information
        if let surah = userInfo["surah"] as? Int,
           let verse = userInfo["verse"] as? Int {
            // Create deep link URL
            if let url = URL(string: "thaqalayn://verse?surah=\(surah)&verse=\(verse)") {
                // Post notification to app to handle navigation
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        }

        completionHandler()
    }
```

- [ ] **Step 4: Build**

Run the build command. Expected tail: `** BUILD SUCCEEDED **`.

- [ ] **Step 5: Checkpoint** (user commits)

Files: `Thaqalayn/ContentView.swift`, `Thaqalayn/ThaqalaynApp.swift`
Suggested message: `feat: thaqalayn://journey deep-link routing for journey-start taps`

---

### Task 6: `MainTabView` journey-navigation receiver

**Files:**
- Modify: `Thaqalayn/Views/MainTabView.swift:112-124` (after the existing `.onReceive(.navigateToVerse)`)

- [ ] **Step 1: Add the `.navigateToJourney` receiver**

In `Thaqalayn/Views/MainTabView.swift`, the body currently ends:

```swift
        .tint(themeManager.accentColor)
        .onReceive(NotificationCenter.default.publisher(for: .navigateToVerse)) { notification in
            guard let userInfo = notification.userInfo,
                  let surah = userInfo["surah"] as? Int,
                  let verse = userInfo["verse"] as? Int else { return }

            // Stash the deep-link first so HomeView consumes it on appear
            deepLinkRouter.pendingDeepLink = PendingDeepLink(
                surahNumber: surah,
                verseNumber: verse
            )
            // Then switch to the Quran tab — HomeView's onAppear/onChange triggers the navigation.
            selectedTab = 1
        }
    }
}
```

Replace with:

```swift
        .tint(themeManager.accentColor)
        .onReceive(NotificationCenter.default.publisher(for: .navigateToVerse)) { notification in
            guard let userInfo = notification.userInfo,
                  let surah = userInfo["surah"] as? Int,
                  let verse = userInfo["verse"] as? Int else { return }

            // Stash the deep-link first so HomeView consumes it on appear
            deepLinkRouter.pendingDeepLink = PendingDeepLink(
                surahNumber: surah,
                verseNumber: verse
            )
            // Then switch to the Quran tab — HomeView's onAppear/onChange triggers the navigation.
            selectedTab = 1
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToJourney)) { notification in
            guard let userInfo = notification.userInfo,
                  let journeyId = userInfo["journey"] as? String else { return }

            // Only switch if that journey's tab is currently present (season
            // active). It will be: the notification fires at/after the lead-in.
            switch journeyId {
            case "ramadan":  if isRamadanSeason { selectedTab = 4 }
            case "hajj":     if isHajjSeason { selectedTab = 5 }
            case "muharram": if isMuharramSeason { selectedTab = 6 }
            default: break
            }
        }
    }
}
```

- [ ] **Step 2: Build**

Run the build command. Expected tail: `** BUILD SUCCEEDED **`.

- [ ] **Step 3: Checkpoint** (user commits)

Files: `Thaqalayn/Views/MainTabView.swift`
Suggested message: `feat: MainTabView switches to the journey tab on journey-start tap`

---

### Task 7: Remove the debug verification scaffold

**Files:**
- Modify: `Thaqalayn/Services/JourneyAnnouncements.swift` (delete the `#if DEBUG` extension)
- Modify: `Thaqalayn/ThaqalaynApp.swift` (delete the `#if DEBUG` call in `init()`)

- [ ] **Step 1: Delete the `#if DEBUG ... #endif` block at the end of `JourneyAnnouncements.swift`**

Remove the entire block added in Task 2 Step 1 — from `#if DEBUG` through its matching `#endif` (the `extension JourneyAnnouncement { static func debugVerifyDecisionMatrix() ... }`). The file should end with the `journeyScheduleDecision(...)` function's closing brace.

- [ ] **Step 2: Remove the call in `ThaqalaynApp.init()`**

In `Thaqalayn/ThaqalaynApp.swift`, `init()` is now:

```swift
    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        // Apply native chrome (UITabBar / UINavigationBar) for current theme
        ChromeAppearance.apply(for: ThemeManager.shared.selectedTheme)

        #if DEBUG
        JourneyAnnouncement.debugVerifyDecisionMatrix()
        #endif
    }
```

Replace with:

```swift
    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        // Apply native chrome (UITabBar / UINavigationBar) for current theme
        ChromeAppearance.apply(for: ThemeManager.shared.selectedTheme)
    }
```

- [ ] **Step 3: Build**

Run the build command. Expected tail: `** BUILD SUCCEEDED **`.

- [ ] **Step 4: Final checkpoint** (user commits)

Files: `Thaqalayn/Services/JourneyAnnouncements.swift`, `Thaqalayn/ThaqalaynApp.swift`
Suggested message: `chore: remove temporary journey decision verification scaffold`

---

## Acceptance (maps to spec §11)

- **Future open → on-time notification:** `scheduleJourneyStartNotifications()` schedules a calendar notification at `preferences.time` on the lead-in date (Task 3 + 4).
- **Late first open → catch-up, once per journey/year:** Path B fires a ~5 s catch-up; `handledYears` makes it exactly-once and blocks the lead-in-day double-fire (Task 1 + 3).
- **No fire in grace tail:** `isWithinAnnounceWindow` excludes Shawwal / Tashriq / Muharram-grace (Task 1; matrix-verified Task 2).
- **Tap opens the right tab:** `journey_start` userInfo → `thaqalayn://journey` → `.navigateToJourney` → tab tag (Task 5 + 6).
- **4th journey = one row:** append to `JourneyAnnouncement.all` + a `MainTabView` conditional tab; scheduler unchanged (Task 1 design).
- **Permission denied → nothing:** authorization guard returns before any side effect/state write (Task 3).
- **Verification:** `xcodebuild … build` succeeds each task; the Task 2 matrix prints `ALL PASS`.
