//
//  MuharramJourneyView.swift
//  Thaqalayn
//
//  10-day "First Ten Days of Muharram" Journey tab view with progress tracking
//  Only visible during Muharram season
//

import SwiftUI

struct MuharramJourneyView: View {
    @StateObject private var journeyManager = MuharramJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedDay: MuharramDay?
    @State private var navigateToDetail = false
    /// A locked day the user tapped - opens the veiled preview instead of the paywall.
    @State private var lockedPreviewDay: MuharramDay?

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    // Header with progress
                    MuharramJourneyHeader()

                    // Day list
                    if journeyManager.isLoading {
                        MuharramLoadingSection(message: JourneyStrings.loadingJourney)
                    } else if let error = journeyManager.errorMessage {
                        MuharramErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(journeyManager.days) { day in
                                    MuharramDayCard(
                                        day: day,
                                        isObserved: journeyManager.isDayObserved(day.dayNumber),
                                        isCurrentDay: calendarManager.currentMuharramDay() == day.dayNumber,
                                        isLocked: !premiumManager.canAccessMuharramDay(day.dayNumber)
                                    ) {
                                        if premiumManager.canAccessMuharramDay(day.dayNumber) {
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

                // Hidden NavigationLink for day detail navigation
                if let day = selectedDay {
                    NavigationLink(
                        destination: MuharramDayDetailView(day: day),
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
            // A locked day opens into the veil - the day's theme and opening line, then
            // what waits beneath - rather than jumping straight to the paywall. The
            // paywall it carries still wears this journey's art and name.
            VeiledDayPreview(
                dayLabel: "\(JourneyStrings.title("muharram")) \u{00B7} \(JourneyStrings.dayN(day.dayNumber))",
                theme: day.theme,
                themeArabic: day.themeArabic,
                openingLine: day.tafsirFocus,
                verseCount: day.verses.count,
                coverAssetName: JourneyDescriptor.byId("muharram")?.coverAssetName ?? "MuharramCover",
                paywallContext: PaywallContext(
                    coverAssetName: JourneyDescriptor.byId("muharram")?.coverAssetName,
                    eyebrow: JourneyStrings.title("muharram")))
        }
    }
}

struct MuharramJourneyHeader: View {
    @StateObject private var journeyManager = MuharramJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared

    var statusMessage: String {
        let status = calendarManager.muharramSeasonStatus()
        return status.isEmpty ? JourneyStrings.screenTitle("muharram") : status
    }

    var observedCount: Int {
        journeyManager.observedDaysCount
    }

    // Somber observance: no completion/celebration note, "observed" wording.
    var body: some View {
        EmJourneyHeader(
            eyebrow: JourneyStrings.eyebrow("muharram", "10-Day Journey"),
            title: JourneyStrings.title("muharram"),
            sfSymbol: "flame.fill",
            statusLine: statusMessage,
            countLine: JourneyStrings.daysObserved(observedCount, 10),
            percent: journeyManager.completionPercentage,
            coverAssetName: "MuharramCover"
        )
    }
}

struct MuharramDayCard: View {
    let day: MuharramDay
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
            onTap: onTap
        )
        .padding(.horizontal, 20)
    }
}

private struct MuharramLoadingSection: View {
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

private struct MuharramErrorSection: View {
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
    MuharramJourneyView()
}
