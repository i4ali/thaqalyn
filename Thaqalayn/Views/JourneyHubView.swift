//
//  JourneyHubView.swift
//  Thaqalayn
//
//  Permanent "Journey" tab (5th). Lists every seasonal journey with its status;
//  only active journeys open. Replaces the old conditional
//  Ramadan/Hajj/Muharram tabs.
//

import SwiftUI

/// Identifiable wrapper so `.fullScreenCover(item:)` can key on a journey id.
struct PresentedJourney: Identifiable { let id: String }

/// Content for the alert shown when a locked (non-active) journey is tapped.
struct LockedJourneyAlert: Identifiable {
    let id = UUID()
    let title: String       // e.g. "Ramadan has ended"
    let detail: String      // e.g. "Returns Feb 8, 2027"
    let pointer: String?    // e.g. "Up next: Muharram · in 8 days"
}

struct JourneyHubView: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var cal = IslamicCalendarManager.shared
    @ObservedObject private var router = DeepLinkRouter.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    @State private var presented: PresentedJourney?
    /// Set when a locked journey is tapped — drives the "ended / not open yet" alert.
    @State private var lockedAlert: LockedJourneyAlert?

    /// Descriptors paired with status, sorted Active → Coming soon (soonest) →
    /// Ended (soonest to return).
    private var ordered: [(descriptor: JourneyDescriptor, status: JourneyStatus)] {
        JourneyDescriptor.all
            .map { ($0, $0.status(using: cal)) }
            .sorted { lhs, rhs in sortKey(lhs.1) < sortKey(rhs.1) }
    }

    /// (bucket, tiebreak-days) — lower sorts first.
    private func sortKey(_ s: JourneyStatus) -> (Int, Int) {
        switch s {
        case .active:                      return (0, 0)
        case .comingSoon(let d, _):        return (1, d)
        case .ended(let d, _):             return (2, d)
        }
    }

    /// The journey to flag as "next up": the soonest journey to open next — but
    /// only when nothing is currently active (an active card is the sole
    /// highlight). `ordered` is sorted soonest-first among non-active journeys, so
    /// the first entry is the answer. This includes an "ended" journey whose
    /// return is nearest — e.g. mid-Dhul-Hijjah, when every journey reads "ended"
    /// and Muharram returns within days.
    private var nextUpId: String? {
        let items = ordered
        guard !items.contains(where: { $0.status.isActive }) else { return nil }
        return items.first?.descriptor.id
    }

    var body: some View {
        ZStack {
            AdaptiveModernBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    EmHeading(eyebrow: JourneyStrings.sacredSeasons(lang), title: JourneyStrings.journeys(lang),
                              sub: JourneyStrings.journeysSub(lang))
                        .frame(maxWidth: .infinity, alignment: lang.isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                        .padding(.horizontal, 4)
                        .padding(.top, 12)
                        .padding(.bottom, 22)   // clear gap so the cards sit below the top glow/header zone

                    ForEach(ordered, id: \.descriptor.id) { item in
                        JourneyCard(descriptor: item.descriptor, status: item.status,
                                    isNextUp: item.descriptor.id == nextUpId) {
                            handleTap(item.descriptor, item.status)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 120)   // clear the floating EmeraldTabBar
            }
        }
        .preferredColorScheme(tm.colorScheme)
        .fullScreenCover(item: $presented) { p in
            if let d = JourneyDescriptor.byId(p.id) {
                JourneyCover(descriptor: d) { presented = nil }
            }
        }
        .onAppear { consumePendingJourney() }
        .onChange(of: router.pendingJourneyId) { _, _ in consumePendingJourney() }
        .overlay {
            if let alert = lockedAlert {
                LockedJourneyOverlay(alert: alert) {
                    withAnimation(.easeInOut(duration: 0.2)) { lockedAlert = nil }
                }
                .transition(.opacity)
            }
        }
    }

    private func handleTap(_ d: JourneyDescriptor, _ status: JourneyStatus) {
        if status.isActive {
            // Let the card's press squish play before the cover slides up and hides it.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                presented = PresentedJourney(id: d.id)
            }
        } else {
            // Locked — explain why it won't open and point to the next journey.
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            withAnimation(.easeInOut(duration: 0.2)) {
                lockedAlert = makeLockedAlert(for: d, status: status)
            }
        }
    }

    /// Builds the locked-journey alert: a title + reason for the tapped journey,
    /// plus a pointer to the soonest *other* journey to open.
    private func makeLockedAlert(for d: JourneyDescriptor, status: JourneyStatus) -> LockedJourneyAlert {
        let title: String
        let detail: String
        let jTitle = JourneyStrings.title(d.id, lang)
        switch status {
        case .ended(_, let returns):
            title = JourneyStrings.hasEnded(jTitle, lang)
            detail = returns
        case .comingSoon(_, let starts):
            title = JourneyStrings.notOpenYet(jTitle, lang)
            detail = starts
        case .active:
            title = jTitle          // unreachable: active journeys open directly
            detail = ""
        }
        return LockedJourneyAlert(title: title, detail: detail, pointer: pointerLine(excluding: d))
    }

    /// "Up next: X · in N days" (or "X is open now") for the soonest journey to
    /// open, excluding the tapped one. Returns nil when the tapped journey IS the
    /// soonest — it's already the next one up.
    private func pointerLine(excluding tapped: JourneyDescriptor) -> String? {
        func opensIn(_ s: JourneyStatus) -> Int {
            switch s {
            case .active:               return 0
            case .comingSoon(let d, _): return d
            case .ended(let d, _):      return d
            }
        }
        let rows = JourneyDescriptor.all.map { ($0, $0.status(using: cal)) }
        guard let soonest = rows.min(by: { opensIn($0.1) < opensIn($1.1) }) else { return nil }
        if soonest.0.id == tapped.id { return nil }
        let sTitle = JourneyStrings.title(soonest.0.id, lang)
        if soonest.1.isActive { return JourneyStrings.isOpenNow(sTitle, lang) }
        let days = opensIn(soonest.1)
        if days <= 0 { return JourneyStrings.upNextToday(sTitle, lang) }
        return JourneyStrings.upNextInDays(sTitle, days, lang)
    }

    /// If a deep-link queued a journey and it is currently active, open it.
    /// Always clears the pending id (a locked journey can't be opened).
    private func consumePendingJourney() {
        guard let id = router.pendingJourneyId else { return }
        if let d = JourneyDescriptor.byId(id), d.isActive() {
            presented = PresentedJourney(id: id)
        }
        router.pendingJourneyId = nil
    }
}

struct JourneyCard: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let descriptor: JourneyDescriptor
    let status: JourneyStatus
    /// When true, this is the soonest upcoming journey — marked with a "NEXT UP"
    /// pill (in place of the eyebrow) and a brighter gold hairline border.
    var isNextUp: Bool = false
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            EmCard(glow: status.isActive,
                   borderColor: isNextUp ? tm.accentColor.opacity(0.4) : nil) {
                HStack(spacing: 14) {
                    EmIconChip(sfSymbol: descriptor.sfSymbol, active: status.isActive, isCustomAsset: descriptor.iconIsCustomAsset)
                    VStack(alignment: .leading, spacing: 4) {
                        if isNextUp {
                            nextUpPill
                        } else {
                            Text(JourneyStrings.eyebrow(descriptor.id, descriptor.eyebrow, lang).uppercased())
                                .emEyebrow(lang, size: 10.5, tracking: 2)
                                .foregroundColor(tm.accentColor)
                        }
                        Text(JourneyStrings.title(descriptor.id, lang))
                            .font(EmType.serif(22, .semiBold))
                            .foregroundColor(tm.primaryText)
                        Text(detailLine)
                            .font(.system(size: 13))
                            .foregroundColor(tm.secondaryText)
                    }
                    Spacer(minLength: 8)
                    trailingGlyph
                }
                .padding(16)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
            }
        }
        .buttonStyle(EmPressStyle())
    }

    /// Gold "NEXT UP" capsule shown in the eyebrow slot of the next-up card.
    private var nextUpPill: some View {
        Text(JourneyStrings.nextUp(lang))
            .font(.system(size: 9, weight: .heavy)).tracking(1.6)
            .foregroundColor(tm.onAccentText)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(tm.accentGradient))
    }

    private var detailLine: String {
        switch status {
        case .active(let line):                 return line
        case .comingSoon(let days, _):          return JourneyStrings.comingSoonInDays(days, lang)
        case .ended(_, let returns):            return isNextUp ? returns : JourneyStrings.endedReturns(returns, lang)
        }
    }

    @ViewBuilder private var trailingGlyph: some View {
        switch status {
        case .active:
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.accentColor)
        case .comingSoon, .ended:
            // Locked cards rely on the status text ("Coming soon · …" / "Ended · …")
            // — no trailing icon, so they never read as a paywall lock.
            EmptyView()
        }
    }
}

/// Hosts an existing journey view (which brings its own NavigationView) inside a
/// full-screen cover, overlaying a chevron-down to return to the hub.
struct JourneyCover: View {
    @ObservedObject private var tm = ThemeManager.shared
    let descriptor: JourneyDescriptor
    let onClose: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            descriptor.destination()
            Button(action: onClose) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(tm.primaryText)
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(tm.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            .padding(.leading, 14)
            .padding(.top, 6)
        }
    }
}

/// Centered modal shown when a locked journey is tapped: a dimmed backdrop
/// (tap to dismiss) over a card that explains the lock and names the next journey.
struct LockedJourneyOverlay: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    let alert: LockedJourneyAlert
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.55)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            VStack(spacing: 14) {
                EmIconChip(sfSymbol: "hourglass", size: 52)

                VStack(spacing: 6) {
                    Text(alert.title)
                        .font(EmType.serif(20, .semiBold))
                        .foregroundColor(tm.primaryText)
                        .multilineTextAlignment(.center)
                    if !alert.detail.isEmpty {
                        Text(alert.detail)
                            .font(.system(size: 13))
                            .foregroundColor(tm.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    if let pointer = alert.pointer {
                        Text(pointer)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(tm.accentColor)
                            .multilineTextAlignment(.center)
                            .padding(.top, 2)
                    }
                }

                EmGoldCTA(title: JourneyStrings.gotIt(languageManager.selectedLanguage), small: true) { onDismiss() }
                    .padding(.top, 4)
            }
            .padding(22)
            .frame(maxWidth: 290)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(tm.tertiaryBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(tm.strokeColor, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.5), radius: 40, x: 0, y: 20)
            .padding(40)
        }
    }
}

#if DEBUG
private func hijriDate(_ y: Int, _ m: Int, _ d: Int) -> Date {
    IslamicCalendarManager.shared.islamicCalendar
        .date(from: DateComponents(year: y, month: m, day: d))!
}

#Preview("Hub · Ramadan active (9/3)") {
    IslamicCalendarManager.debugNowOverride = hijriDate(1449, 9, 3)
    return JourneyHubView()
}
#Preview("Hub · Hajj coming soon (7/1)") {
    IslamicCalendarManager.debugNowOverride = hijriDate(1449, 7, 1)
    return JourneyHubView()
}
#Preview("Hub · late Dhul-Hijjah — Muharram active (12/27)") {
    IslamicCalendarManager.debugNowOverride = hijriDate(1449, 12, 27)
    return JourneyHubView()
}
#Preview("Hub · Rabi — Muharram ended, Ramadan+Hajj soon (3/10)") {
    IslamicCalendarManager.debugNowOverride = hijriDate(1449, 3, 10)
    return JourneyHubView()
}
#Preview("Hub · First Fatimiyya active (5/13)") {
    IslamicCalendarManager.debugNowOverride = hijriDate(1449, 5, 13)
    return JourneyHubView()
}
#Preview("Hub · Second Fatimiyya active (6/3)") {
    IslamicCalendarManager.debugNowOverride = hijriDate(1449, 6, 3)
    return JourneyHubView()
}
#Preview("Hub · between Fatimiyyas — coming soon (5/20)") {
    IslamicCalendarManager.debugNowOverride = hijriDate(1449, 5, 20)
    return JourneyHubView()
}
#Preview("Locked alert — ended + up-next") {
    ZStack {
        AdaptiveModernBackground()
        LockedJourneyOverlay(
            alert: LockedJourneyAlert(title: "Ramadan has ended",
                                      detail: "Returns Feb 8, 2027",
                                      pointer: "Up next: Muharram · in 8 days"),
            onDismiss: {}
        )
    }
}
#endif
