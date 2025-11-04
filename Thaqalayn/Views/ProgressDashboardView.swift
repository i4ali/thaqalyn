//
//  ProgressDashboardView.swift
//  Thaqalayn
//
//  Progress dashboard with stats, streaks, and badges
//

import SwiftUI

struct ProgressDashboardView: View {
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var dataManager = DataManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground,
                        themeManager.tertiaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Hero Section - Total Sawab
                        sawabHeroSection

                        // Hero Section - Current Streak
                        streakHeroSection

                        // Quick Stats Cards
                        quickStatsSection

                        // Weekly Calendar
                        weeklyCalendarSection

                        // Badge Collection
                        badgeCollectionSection

                        // Recent Activity
                        recentActivitySection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Reading Progress")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }

    // MARK: - Sawab Hero Section

    private var sawabHeroSection: some View {
        VStack(spacing: 16) {
            // Star icon with Islamic color scheme
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.green.opacity(0.3), Color(red: 0.75, green: 0.60, blue: 0.35).opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Image(systemName: "star.fill")
                    .font(.system(size: 64, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.green, Color(red: 0.75, green: 0.60, blue: 0.35)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.green.opacity(0.5), radius: 10)
            }

            Text("\(progressManager.stats.totalSawab)")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.green, Color(red: 0.75, green: 0.60, blue: 0.35)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text("Total Sawab Earned")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.secondaryText)

            Text("ثواب")
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.green.opacity(0.5), Color(red: 0.75, green: 0.60, blue: 0.35).opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }

    // MARK: - Streak Hero Section

    private var streakHeroSection: some View {
        VStack(spacing: 16) {
            // Flame icon with animation
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)

                Text("🔥")
                    .font(.system(size: 64))
                    .shadow(color: Color.orange.opacity(0.5), radius: 10)
            }

            Text("\(progressManager.streak.currentStreak)")
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.orange, Color.red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )

            Text(progressManager.streak.currentStreak == 1 ? "Day Streak" : "Day Streak")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(themeManager.secondaryText)

            if progressManager.streak.longestStreak > progressManager.streak.currentStreak {
                Text("Longest: \(progressManager.streak.longestStreak) days")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.5), Color.red.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2
                        )
                )
        )
    }

    // MARK: - Quick Stats Section

    private var quickStatsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Overview")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ProgressStatCard(
                    icon: "book.fill",
                    value: "\(progressManager.stats.versesReadToday)",
                    label: "Today",
                    color: .blue
                )

                ProgressStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(progressManager.stats.totalVersesRead)",
                    label: "Total Verses",
                    color: .green
                )

                ProgressStatCard(
                    icon: "star.fill",
                    value: "\(progressManager.stats.totalSurahsCompleted)",
                    label: "Surahs Done",
                    color: .purple
                )

                ProgressStatCard(
                    icon: "flame.fill",
                    value: "\(progressManager.streak.longestStreak)",
                    label: "Best Streak",
                    color: .orange
                )
            }
        }
    }

    // MARK: - Weekly Calendar Section

    private var weeklyCalendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("This Week")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    weekDayCard(dayOffset: index)
                }
            }
        }
    }

    private func weekDayCard(dayOffset: Int) -> some View {
        let calendar = Calendar.current
        let today = Date()
        guard let date = calendar.date(byAdding: .day, value: -6 + dayOffset, to: today) else {
            return AnyView(EmptyView())
        }

        let dayStart = calendar.startOfDay(for: date)
        let versesOnDay = progressManager.verseProgress.filter { progress in
            calendar.isDate(progress.readDate, inSameDayAs: dayStart)
        }.count

        let hasActivity = versesOnDay > 0
        let isToday = calendar.isDateInToday(date)

        return AnyView(
            VStack(spacing: 8) {
                Text(dayOfWeek(for: date))
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(isToday ? Color(red: 0.39, green: 0.4, blue: 0.95) : themeManager.tertiaryText)

                ZStack {
                    Circle()
                        .fill(hasActivity ? Color.green.opacity(0.3) : themeManager.tertiaryBackground)
                        .frame(width: 40, height: 40)

                    if hasActivity {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                    }

                    if isToday {
                        Circle()
                            .stroke(Color(red: 0.39, green: 0.4, blue: 0.95), lineWidth: 2)
                            .frame(width: 40, height: 40)
                    }
                }
            }
            .frame(maxWidth: .infinity)
        )
    }

    private func dayOfWeek(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date).prefix(1).uppercased()
    }

    // MARK: - Badge Collection Section

    private var badgeCollectionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Badges")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Spacer()

                Text("\(progressManager.badges.count)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.secondaryText)
            }

            if progressManager.badges.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "star.slash")
                        .font(.system(size: 48))
                        .foregroundColor(themeManager.tertiaryText.opacity(0.5))

                    Text("No badges yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)

                    Text("Complete surahs and build streaks to earn badges!")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(themeManager.tertiaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                )
            } else {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    ForEach(progressManager.badges.sorted(by: { $0.awardedDate > $1.awardedDate })) { badge in
                        BadgeCard(badge: badge)
                    }
                }
            }
        }
    }

    // MARK: - Recent Activity Section

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            if progressManager.verseProgress.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "clock")
                        .font(.system(size: 48))
                        .foregroundColor(themeManager.tertiaryText.opacity(0.5))

                    Text("No activity yet")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)

                    Text("Start reading and mark verses as complete!")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(themeManager.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                )
            } else {
                VStack(spacing: 12) {
                    ForEach(progressManager.getRecentActivity(limit: 10)) { progress in
                        RecentActivityRow(progress: progress)
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

struct ProgressStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
}

struct BadgeCard: View {
    let badge: BadgeAward
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(badgeColor.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: badge.badgeType.icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(badgeColor)
            }

            Text(badge.badgeType == .surahCompletion ? badge.surahName : badge.badgeType.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(badgeColor.opacity(0.3), lineWidth: 1.5)
                )
        )
    }

    private var badgeColor: Color {
        switch badge.badgeType.color {
        case "green": return .green
        case "blue": return .blue
        case "purple": return .purple
        case "orange": return .orange
        case "gold": return .yellow
        case "red": return .red
        default: return .gray
        }
    }
}

struct RecentActivityRow: View {
    let progress: VerseProgress
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var dataManager = DataManager.shared

    private var surahName: String {
        dataManager.getSurah(number: progress.surahNumber)?.surah.englishName ?? "Unknown"
    }

    var body: some View {
        HStack(spacing: 16) {
            // Checkmark icon
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 40, height: 40)

                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.green)
            }

            // Verse info
            VStack(alignment: .leading, spacing: 4) {
                Text("\(surahName) • Verse \(progress.verseNumber)")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text(timeAgo(from: progress.readDate))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }

    private func timeAgo(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)m ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)h ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days)d ago"
        }
    }
}

#Preview {
    ProgressDashboardView()
}
