//
//  ArbaeenJourneyView.swift
//  Thaqalayn
//
//  "Arbaeen" (The Return) Journey tab view — the 8-station road from Ashura to
//  Arbaeen. Only surfaced during the Arbaeen season (11 Muharram – 25 Safar).
//  Somber azadari (mourning) observance — "observed" wording, no badges.
//

import SwiftUI

struct ArbaeenJourneyView: View {
    @StateObject private var journeyManager = ArbaeenJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedDay: ArbaeenDay?
    @State private var navigateToDetail = false
    /// A locked station the user tapped - opens the veiled preview instead of the paywall.
    @State private var lockedPreviewDay: ArbaeenDay?

    private var currentStation: Int? { calendarManager.currentArbaeenStation() }

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    // Header with progress
                    ArbaeenJourneyHeader()

                    // Station list
                    if journeyManager.isLoading {
                        ArbaeenLoadingSection(message: JourneyStrings.loadingJourney)
                    } else if let error = journeyManager.errorMessage {
                        ArbaeenErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(journeyManager.days) { day in
                                    ArbaeenStationCard(
                                        day: day,
                                        isObserved: journeyManager.isDayObserved(day.dayNumber),
                                        isCurrentDay: currentStation == day.dayNumber,
                                        isLocked: !premiumManager.canAccessArbaeenStation(day.dayNumber)
                                    ) {
                                        if premiumManager.canAccessArbaeenStation(day.dayNumber) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                                selectedDay = day
                                                navigateToDetail = true
                                            }
                                        } else {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                                lockedPreviewDay = day
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 16)
                            .padding(.bottom, 120)
                        }
                    }
                }

                // Hidden NavigationLink for station detail navigation
                if let day = selectedDay {
                    NavigationLink(
                        destination: ArbaeenDayDetailView(day: day),
                        isActive: $navigateToDetail
                    ) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    .hidden()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(themeManager.colorScheme)
        .fullScreenCover(item: $lockedPreviewDay) { day in
            // A locked station opens into the veil - its theme and opening line, then
            // what waits beneath - rather than jumping straight to the paywall. The
            // paywall it carries still wears this journey's art and name.
            VeiledDayPreview(
                dayLabel: "\(JourneyStrings.title("arbaeen")) \u{00B7} \(JourneyStrings.stationN(day.dayNumber))",
                theme: day.theme,
                themeArabic: day.themeArabic,
                openingLine: day.tafsirFocus,
                verseCount: day.verses.count,
                unitIsStation: true,
                coverAssetName: JourneyDescriptor.byId("arbaeen")?.coverAssetName ?? "ArbaeenCover",
                paywallContext: PaywallContext(
                    coverAssetName: JourneyDescriptor.byId("arbaeen")?.coverAssetName,
                    eyebrow: JourneyStrings.title("arbaeen")))
        }
    }
}

struct ArbaeenJourneyHeader: View {
    @StateObject private var journeyManager = ArbaeenJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared

    var statusMessage: String {
        let status = calendarManager.arbaeenSeasonStatus()
        return status.isEmpty ? JourneyStrings.screenTitle("arbaeen") : status
    }

    var observedCount: Int {
        journeyManager.observedDaysCount
    }

    // Somber observance: no completion/celebration note, "observed" wording.
    var body: some View {
        EmJourneyHeader(
            eyebrow: JourneyStrings.eyebrow("arbaeen", "40-Day Journey"),
            title: JourneyStrings.title("arbaeen"),
            sfSymbol: "figure.walk",
            statusLine: statusMessage,
            countLine: JourneyStrings.stationsObserved(observedCount, 8),
            percent: journeyManager.completionPercentage,
            iconIsCustomAsset: false,
            coverAssetName: "ArbaeenCover"
        )
    }
}

struct ArbaeenStationCard: View {
    let day: ArbaeenDay
    let isObserved: Bool
    let isCurrentDay: Bool
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        EmJourneyDayRow(
            dayNumber: day.dayNumber,
            theme: day.theme,
            themeArabic: day.themeArabic,
            isDone: isObserved,
            isCurrent: isCurrentDay,
            isLocked: isLocked,
            doneStyle: .subdued,
            numberLabel: JourneyStrings.stationN(day.dayNumber),
            onTap: onTap
        )
        .padding(.horizontal, 20)
    }
}

private struct ArbaeenLoadingSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(themeManager.accentColor)

            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

private struct ArbaeenErrorSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(JourneyStrings.errorLoadingJourney)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    ArbaeenJourneyView()
}
