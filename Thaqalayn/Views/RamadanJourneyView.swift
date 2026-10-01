//
//  RamadanJourneyView.swift
//  Thaqalayn
//
//  30-day Ramadan Journey tab view with progress tracking
//  Only visible during Ramadan season
//

import SwiftUI

struct RamadanJourneyView: View {
    @StateObject private var journeyManager = RamadanJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedDay: RamadanDay?
    @State private var navigateToDetail = false
    /// A locked day the user tapped - opens the veiled preview instead of the paywall.
    @State private var lockedPreviewDay: RamadanDay?

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    // Header with progress
                    RamadanJourneyHeader()

                    // Day list
                    if journeyManager.isLoading {
                        RamadanLoadingSection(message: JourneyStrings.loadingJourney)
                    } else if let error = journeyManager.errorMessage {
                        RamadanErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(journeyManager.days) { day in
                                    RamadanDayCard(
                                        day: day,
                                        isCompleted: journeyManager.isDayCompleted(day.dayNumber),
                                        isCurrentDay: calendarManager.currentRamadanDay() == day.dayNumber,
                                        isLocked: !premiumManager.canAccessRamadanDay(day.dayNumber)
                                    ) {
                                        if premiumManager.canAccessRamadanDay(day.dayNumber) {
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
                        destination: RamadanDayDetailView(day: day),
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
                dayLabel: "\(JourneyStrings.title("ramadan")) \u{00B7} \(JourneyStrings.dayN(day.dayNumber))",
                theme: day.theme,
                themeArabic: day.themeArabic,
                openingLine: day.tafsirFocus,
                verseCount: day.verses.count,
                coverAssetName: JourneyDescriptor.byId("ramadan")?.coverAssetName ?? "RamadanCover",
                paywallContext: PaywallContext(
                    coverAssetName: JourneyDescriptor.byId("ramadan")?.coverAssetName,
                    eyebrow: JourneyStrings.title("ramadan")))
        }
    }
}

struct RamadanJourneyHeader: View {
    @StateObject private var journeyManager = RamadanJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared

    var statusMessage: String {
        let month = calendarManager.currentIslamicMonth()
        let day = calendarManager.currentIslamicDay()

        switch month {
        case 8: // Sha'ban
            if let daysUntil = calendarManager.daysUntilRamadan(), daysUntil > 0 {
                return "\(daysUntil) day\(daysUntil == 1 ? "" : "s") until Ramadan"
            }
            return "Ramadan begins soon"
        case 9: // Ramadan
            return "Day \(day) of Ramadan"
        case 10: // Shawwal
            if day <= 5 {
                return "Eid Mubarak!"
            }
            return "Ramadan has ended"
        default:
            return JourneyStrings.screenTitle("ramadan")
        }
    }

    var body: some View {
        EmJourneyHeader(
            eyebrow: JourneyStrings.eyebrow("ramadan", "30-Day Journey"),
            title: JourneyStrings.title("ramadan"),
            sfSymbol: "moon.stars.fill",
            statusLine: statusMessage,
            countLine: JourneyStrings.daysCompleted(journeyManager.completedDaysCount, 30),
            percent: journeyManager.completionPercentage,
            completionNote: journeyManager.isJourneyCompleted ? "Journey complete · Ramadan Champion earned" : nil,
            coverAssetName: "RamadanCover"
        )
    }
}

struct RamadanDayCard: View {
    let day: RamadanDay
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

private struct RamadanLoadingSection: View {
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

private struct RamadanErrorSection: View {
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
    RamadanJourneyView()
}
