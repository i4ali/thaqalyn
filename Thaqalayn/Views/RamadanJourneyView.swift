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
    @State private var showPaywall = false

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
                        RamadanLoadingSection(message: "Loading journey...")
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
                                            selectedDay = day
                                            navigateToDetail = true
                                        } else {
                                            showPaywall = true
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 16)
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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct RamadanJourneyHeader: View {
    @StateObject private var journeyManager = RamadanJourneyManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared
    @StateObject private var themeManager = ThemeManager.shared

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
            return "Ramadan Journey"
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            // Title and status
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Ramadan Journey")
                            .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32, weight: .bold, design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
                            .foregroundColor(themeManager.primaryText)

                        Text(statusMessage)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.accentColor)
                    }

                    Spacer()

                    // Moon icon
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(themeManager.accentGradient)
                }
            }

            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("\(journeyManager.completedDaysCount) of 30 days completed")
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

            // Completion message if done
            if journeyManager.isJourneyCompleted {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                    Text("Journey Complete! Ramadan Champion badge earned.")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.green)
                }
                .padding(.top, 4)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background {
            if themeManager.selectedTheme != .warmInviting {
                Rectangle()
                    .fill(themeManager.glassEffect)
            }
        }
    }
}

struct RamadanDayCard: View {
    let day: RamadanDay
    let isCompleted: Bool
    let isCurrentDay: Bool
    let isLocked: Bool
    let onTap: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    private var greenGradient: LinearGradient {
        LinearGradient(
            colors: [Color.green, Color.green.opacity(0.8)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

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
        } else if isCompleted {
            return greenGradient
        } else if isCurrentDay {
            return themeManager.accentGradient
        } else {
            return grayGradient
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Day number with completion status
                ZStack {
                    Circle()
                        .fill(circleBackground)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(isCurrentDay && !isCompleted && !isLocked ? themeManager.accentColor : Color.clear, lineWidth: 2)
                        )

                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.secondaryText)
                    } else if isCompleted {
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
                        Text("Day \(day.dayNumber)")
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
                            Text("TODAY")
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

                        Text(day.theme)
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
                if themeManager.selectedTheme == .warmInviting {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 2)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isCurrentDay && !isLocked ? themeManager.accentColor.opacity(0.5) : themeManager.strokeColor, lineWidth: 1)
                        )
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
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

            Text("Error Loading Journey")
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
