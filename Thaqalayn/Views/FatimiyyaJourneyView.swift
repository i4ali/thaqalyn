//
//  FatimiyyaJourneyView.swift
//  Thaqalayn
//
//  "Ayyam-e-Fatimiyya" (Days of Fatimah) Journey tab view with progress tracking
//  Only visible during Fatimiyya season
//

import SwiftUI

struct FatimiyyaJourneyView: View {
    @StateObject private var journeyManager = FatimiyyaJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedDay: FatimiyyaDay?
    @State private var navigateToDetail = false
    /// A locked day the user tapped - opens the veiled preview instead of the paywall.
    @State private var lockedPreviewDay: FatimiyyaDay?

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    // Header with progress
                    FatimiyyaJourneyHeader()

                    // Day list
                    if journeyManager.isLoading {
                        FatimiyyaLoadingSection(message: JourneyStrings.loadingJourney)
                    } else if let error = journeyManager.errorMessage {
                        FatimiyyaErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(journeyManager.days) { day in
                                    FatimiyyaDayCard(
                                        day: day,
                                        isObserved: journeyManager.isDayObserved(day.dayNumber),
                                        isCurrentDay: false,
                                        isLocked: !premiumManager.canAccessFatimiyyaDay(day.dayNumber)
                                    ) {
                                        if premiumManager.canAccessFatimiyyaDay(day.dayNumber) {
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
                        destination: FatimiyyaDayDetailView(day: day),
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
                dayLabel: "\(JourneyStrings.title("fatimiyya")) \u{00B7} \(JourneyStrings.dayN(day.dayNumber))",
                theme: day.theme,
                themeArabic: day.themeArabic,
                openingLine: day.tafsirFocus,
                verseCount: day.verses.count,
                coverAssetName: JourneyDescriptor.byId("fatimiyya")?.coverAssetName ?? "FatimiyyaCover",
                paywallContext: PaywallContext(
                    coverAssetName: JourneyDescriptor.byId("fatimiyya")?.coverAssetName,
                    eyebrow: JourneyStrings.title("fatimiyya")))
        }
    }
}

struct FatimiyyaJourneyHeader: View {
    @StateObject private var journeyManager = FatimiyyaJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared

    var statusMessage: String {
        let status = calendarManager.fatimiyyaSeasonStatus()
        return status.isEmpty ? JourneyStrings.screenTitle("fatimiyya") : status
    }

    var observedCount: Int {
        journeyManager.observedDaysCount
    }

    // Somber observance: no completion/celebration note, "observed" wording.
    var body: some View {
        EmJourneyHeader(
            eyebrow: JourneyStrings.eyebrow("fatimiyya", "Mourning of az-Zahra (AS)"),
            title: JourneyStrings.title("fatimiyya"),
            sfSymbol: "tulip",
            statusLine: statusMessage,
            countLine: JourneyStrings.daysObserved(observedCount, 5),
            percent: journeyManager.completionPercentage,
            iconIsCustomAsset: true,
            coverAssetName: "FatimiyyaCover"
        )
    }
}

struct FatimiyyaDayCard: View {
    let day: FatimiyyaDay
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

private struct FatimiyyaLoadingSection: View {
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

private struct FatimiyyaErrorSection: View {
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
    FatimiyyaJourneyView()
}
