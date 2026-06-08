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

struct JourneyHubView: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var cal = IslamicCalendarManager.shared
    @ObservedObject private var router = DeepLinkRouter.shared
    @State private var presented: PresentedJourney?

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
        case .ended:                       return (2, 0)
        }
    }

    var body: some View {
        ZStack {
            AdaptiveModernBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    EmHeading(eyebrow: "Sacred Seasons", title: "Journeys",
                              sub: "Live each sacred season deeply, and let it transform you.")
                        .padding(.horizontal, 4)
                        .padding(.top, 12)
                        .padding(.bottom, 22)   // clear gap so the cards sit below the top glow/header zone

                    ForEach(ordered, id: \.descriptor.id) { item in
                        JourneyCard(descriptor: item.descriptor, status: item.status) {
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
    }

    private func handleTap(_ d: JourneyDescriptor, _ status: JourneyStatus) {
        if status.isActive {
            presented = PresentedJourney(id: d.id)
        } else {
            // Locked — status is already on the card; just a soft nudge.
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        }
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
    let descriptor: JourneyDescriptor
    let status: JourneyStatus
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            EmCard(glow: status.isActive) {
                HStack(spacing: 14) {
                    EmIconChip(sfSymbol: descriptor.sfSymbol, active: status.isActive, isCustomAsset: descriptor.iconIsCustomAsset)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(descriptor.eyebrow.uppercased())
                            .font(.system(size: 10.5, weight: .bold)).tracking(2)
                            .foregroundColor(tm.accentColor)
                        Text(descriptor.title)
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
            }
        }
        .buttonStyle(EmPressStyle())
    }

    private var detailLine: String {
        switch status {
        case .active(let line):                 return line
        case .comingSoon(let days, _):          return "Coming soon · in \(days) day\(days == 1 ? "" : "s")"
        case .ended(let returns):               return "Ended · \(returns)"
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
#endif
