//
//  HajjJourneyView.swift
//  Thaqalayn
//
//  10-day "First Ten Days of Dhul-Hijjah" Journey tab view with progress tracking
//  Only visible during Hajj season
//

import SwiftUI

struct HajjJourneyView: View {
    @StateObject private var journeyManager = HajjJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedDay: HajjDay?
    @State private var navigateToDetail = false
    /// A locked day the user tapped - opens the veiled preview instead of the paywall.
    @State private var lockedPreviewDay: HajjDay?

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    // Header with progress
                    HajjJourneyHeader()

                    // Day list
                    if journeyManager.isLoading {
                        HajjLoadingSection(message: JourneyStrings.loadingJourney)
                    } else if let error = journeyManager.errorMessage {
                        HajjErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(journeyManager.days) { day in
                                    HajjDayCard(
                                        day: day,
                                        isCompleted: journeyManager.isDayCompleted(day.dayNumber),
                                        isCurrentDay: calendarManager.currentHajjDay() == day.dayNumber,
                                        isLocked: !premiumManager.canAccessHajjDay(day.dayNumber)
                                    ) {
                                        if premiumManager.canAccessHajjDay(day.dayNumber) {
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
                        destination: HajjDayDetailView(day: day),
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
                dayLabel: "\(JourneyStrings.title("hajj")) \u{00B7} \(JourneyStrings.dayN(day.dayNumber))",
                theme: day.theme,
                themeArabic: day.themeArabic,
                openingLine: day.tafsirFocus,
                verseCount: day.verses.count,
                coverAssetName: JourneyDescriptor.byId("hajj")?.coverAssetName ?? "HajjCover",
                paywallContext: PaywallContext(
                    coverAssetName: JourneyDescriptor.byId("hajj")?.coverAssetName,
                    eyebrow: JourneyStrings.title("hajj")))
        }
    }
}

struct HajjJourneyHeader: View {
    @StateObject private var journeyManager = HajjJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared

    var statusMessage: String {
        let status = calendarManager.hajjSeasonStatus()
        return status.isEmpty ? JourneyStrings.screenTitle("hajj") : status
    }

    var body: some View {
        EmJourneyHeader(
            eyebrow: JourneyStrings.eyebrow("hajj", "10-Day Journey"),
            title: JourneyStrings.title("hajj"),
            sfSymbol: "building.columns.fill",
            statusLine: statusMessage,
            countLine: JourneyStrings.daysCompleted(journeyManager.completedDaysCount, 10),
            percent: journeyManager.completionPercentage,
            completionNote: journeyManager.isJourneyCompleted ? "Journey complete · Hajj Champion earned" : nil,
            coverAssetName: "HajjCover"
        )
    }
}

struct HajjDayCard: View {
    let day: HajjDay
    let isCompleted: Bool
    let isCurrentDay: Bool
    let isLocked: Bool
    let onTap: () -> Void

    var body: some View {
        EmJourneyDayRow(
            dayNumber: day.dayNumber,
            theme: day.theme,
            themeArabic: day.themeArabic,
            isDone: isCompleted,
            isCurrent: isCurrentDay,
            isLocked: isLocked,
            doneStyle: .gold,
            onTap: onTap
        )
        .padding(.horizontal, 20)
    }
}

private struct HajjLoadingSection: View {
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

private struct HajjErrorSection: View {
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
    HajjJourneyView()
}
