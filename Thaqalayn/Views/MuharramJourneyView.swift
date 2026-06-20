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
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @State private var selectedDay: MuharramDay?
    @State private var navigateToDetail = false
    @State private var showPaywall = false

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
                        MuharramLoadingSection(message: JourneyStrings.loadingJourney(languageManager.selectedLanguage))
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
                                            showPaywall = true
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
        .darkScreenAura()
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct MuharramJourneyHeader: View {
    @StateObject private var journeyManager = MuharramJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var statusMessage: String {
        let status = calendarManager.muharramSeasonStatus()
        return status.isEmpty ? JourneyStrings.screenTitle("muharram", lang) : status
    }

    var observedCount: Int {
        journeyManager.observedDaysCount
    }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    // Somber observance: no completion/celebration note, "observed" wording.
    private var emeraldBody: some View {
        EmJourneyHeader(
            eyebrow: JourneyStrings.eyebrow("muharram", "10-Day Journey", lang),
            title: JourneyStrings.title("muharram", lang),
            sfSymbol: "flame.fill",
            statusLine: statusMessage,
            countLine: JourneyStrings.daysObserved(observedCount, 10, lang),
            percent: journeyManager.completionPercentage
        )
    }

    private var legacyBody: some View {
        VStack(spacing: 16) {
            // Title and status
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(JourneyStrings.screenTitle("muharram", lang))
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.primaryText)

                        Text(statusMessage)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.accentColor)
                    }

                    Spacer()

                    // Muharram icon
                    Image(systemName: "flame.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(themeManager.accentGradient)
                }
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(JourneyStrings.daysObserved(observedCount, 10, lang))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)

                    Spacer()

                    Text("\(Int(journeyManager.completionPercentage * 100))%")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(themeManager.strokeColor)
                            .frame(height: 12)

                        RoundedRectangle(cornerRadius: 6)
                            .fill(themeManager.accentGradient)
                            .frame(width: geometry.size.width * journeyManager.completionPercentage, height: 12)
                    }
                }
                .frame(height: 12)
            }

            // NOTE: No completion/celebration block here — Muharram is a somber observance,
            // not a festive achievement. The Hajj "Journey Complete! Hajj Champion badge earned."
            // banner is intentionally omitted.
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
}

struct MuharramDayCard: View {
    let day: MuharramDay
    let isObserved: Bool
    let isCurrentDay: Bool
    let isLocked: Bool
    let onTap: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    private var grayGradient: LinearGradient {
        LinearGradient(
            colors: [Color.gray.opacity(0.2), Color.gray.opacity(0.15)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var circleBackground: LinearGradient {
        if isLocked {
            return grayGradient
        } else if isObserved {
            // Subdued observed state — use accent gradient rather than celebratory green
            return themeManager.accentGradient
        } else if isCurrentDay {
            return themeManager.accentGradient
        } else {
            return grayGradient
        }
    }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmJourneyDayRow(
            dayNumber: day.dayNumber,
            theme: day.localizedTheme(lang),
            themeArabic: day.themeArabic,
            isDone: isObserved,
            isCurrent: isCurrentDay,
            isLocked: isLocked,
            doneStyle: .subdued,
            onTap: onTap
        )
        .padding(.horizontal, 20)
    }

    private var legacyBody: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Day number with observation status
                ZStack {
                    Circle()
                        .fill(circleBackground)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isCurrentDay && !isObserved && !isLocked ? themeManager.accentColor : Color.clear, lineWidth: 2)
                        )

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.secondaryText)
                    } else if isObserved {
                        // Simple checkmark — subdued, not festive
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(day.dayNumber)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(isCurrentDay ? .white : themeManager.primaryText)
                    }
                }

                // Day content
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(JourneyStrings.dayN(day.dayNumber, lang))
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(themeManager.secondaryText)

                        if isLocked {
                            Text("Premium")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.gradient)
                                )
                        } else if isCurrentDay {
                            Text(JourneyStrings.today(lang))
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule()
                                        .fill(themeManager.accentGradient)
                                )
                        }
                    }

                    HStack(spacing: 8) {
                        Image(systemName: day.icon)
                            .font(.system(size: 14))
                            .foregroundColor(isLocked ? themeManager.secondaryText : themeManager.accentColor)

                        Text(day.localizedTheme(lang))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(isLocked ? themeManager.secondaryText : themeManager.primaryText)
                    }

                    Text(day.themeArabic)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }

                Spacer()

                // Chevron or lock icon
                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isLocked ? themeManager.secondaryText : themeManager.tertiaryText)
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
                    .shadow(
                        color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                        radius: 8, x: 0, y: 2
                    )
            }
        }
        .buttonStyle(PlainButtonStyle())
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
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text(JourneyStrings.errorLoadingJourney(languageManager.selectedLanguage))
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
