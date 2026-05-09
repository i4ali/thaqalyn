//
//  TodayView.swift
//  Thaqalayn
//
//  The Today tab — daily reminder, continue reading, du'a of the day.
//

import SwiftUI

struct TodayView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var dailyMessage = DailyMessageProvider.shared
    @StateObject private var duasManager = DuasManager.shared
    @StateObject private var calendarManager = IslamicCalendarManager.shared

    @Binding var selectedTab: Int

    @State private var selectedSurahForDeepLink: SurahWithTafsir?
    @State private var targetVerseNumber: Int?
    @State private var hasAppeared = false
    @State private var showingNotifications = false
    @State private var showingSettings = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            ScrollView {
                LazyVStack(spacing: 14) {
                    headerRow
                        .padding(.horizontal, 22)
                        .padding(.top, 60)

                    greeting
                        .padding(.horizontal, 18)
                        .padding(.top, 18)

                    DailyReminderBanner(
                        message: dailyMessage.today,
                        surahName: surahName(for: dailyMessage.today.surah),
                        themeManager: themeManager,
                        onTap: { openMessageSource() }
                    )
                    .padding(.horizontal, 18)
                    .padding(.top, 6)

                    ContinueReadingHero(
                        info: progressManager.lastReadInfo,
                        surah: lastReadSurah,
                        verse: lastReadVerse,
                        themeManager: themeManager,
                        onResume: { openLastRead() },
                        onBegin: { openSurah1() }
                    )
                    .padding(.horizontal, 18)

                    if let dua = duasManager.duaOfTheDay() {
                        DuaOfTheDayCard(
                            dua: dua,
                            themeManager: themeManager
                        )
                        .padding(.horizontal, 18)
                        .padding(.top, -2)
                    }
                }
                .padding(.bottom, 40)
            }

            // Hidden deep-link
            if let surahForDeepLink = selectedSurahForDeepLink {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: surahForDeepLink, targetVerse: targetVerseNumber),
                    isActive: Binding(
                        get: { selectedSurahForDeepLink != nil },
                        set: { if !$0 {
                            selectedSurahForDeepLink = nil
                            targetVerseNumber = nil
                        } }
                    )
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }
        }
        .refreshable {
            dailyMessage.refreshIfDayChanged()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("showSettings"))) { _ in
            showingSettings = true
        }
        .onAppear { hasAppeared = true }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                dailyMessage.refreshIfDayChanged()
            }
        }
    }

    private func surahName(for surahNumber: Int) -> String {
        dataManager.availableSurahs
            .first(where: { $0.surah.number == surahNumber })?
            .surah.englishName
            ?? "Surah \(surahNumber)"
    }

    private func openMessageSource() {
        guard let surah = dataManager.availableSurahs.first(where: { $0.surah.number == dailyMessage.today.surah }) else {
            print("⚠️ TodayView: daily-message surah \(dailyMessage.today.surah) not in availableSurahs")
            return
        }
        targetVerseNumber = dailyMessage.today.verse
        selectedSurahForDeepLink = surah
    }

    private var lastReadSurah: SurahWithTafsir? {
        guard let info = progressManager.lastReadInfo else { return nil }
        return dataManager.availableSurahs.first(where: { $0.surah.number == info.surahNumber })
    }

    private var lastReadVerse: VerseWithTafsir? {
        guard let info = progressManager.lastReadInfo,
              let surah = lastReadSurah,
              info.verseNumber >= 1,
              info.verseNumber <= surah.verses.count else { return nil }
        return surah.verses[info.verseNumber - 1]
    }

    private func openLastRead() {
        guard let info = progressManager.lastReadInfo,
              let surah = lastReadSurah else { return }
        targetVerseNumber = info.verseNumber
        selectedSurahForDeepLink = surah
    }

    private func openSurah1() {
        guard let surah = dataManager.availableSurahs.first(where: { $0.surah.number == 1 }) else { return }
        targetVerseNumber = 1
        selectedSurahForDeepLink = surah
    }

    // MARK: - Header row

    @ViewBuilder
    private var headerRow: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ProfileAvatar()
                Spacer()
                StreakBadge(
                    streak: progressManager.streak.currentStreak,
                    themeManager: themeManager,
                    onTap: { selectedTab = 3 }
                )
                NotificationBell(showingNotifications: $showingNotifications)
            }

            HStack {
                HijriDatePill(themeManager: themeManager, calendarManager: calendarManager)
                Spacer()
            }
        }
    }

    // MARK: - Greeting

    @ViewBuilder
    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Assalāmu ʿalaykum 🌙")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)

            Text("Today")
                .font(.system(size: 32, weight: .heavy))
                .kerning(-0.6)
                .foregroundColor(themeManager.primaryText)

            Spacer().frame(height: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Subviews

private struct HijriDatePill: View {
    let themeManager: ThemeManager
    let calendarManager: IslamicCalendarManager

    private var labelText: String {
        let day = calendarManager.currentIslamicDay()
        let month = calendarManager.monthName(for: calendarManager.currentIslamicMonth())
        let weekdayShort = String(calendarManager.islamicDayOfWeek().prefix(3)).uppercased()
        return "\(day) \(month.uppercased()) · \(weekdayShort)"
    }

    private var accessibilityText: String {
        let day = calendarManager.currentIslamicDay()
        let month = calendarManager.monthName(for: calendarManager.currentIslamicMonth())
        return "\(day) \(month)"
    }

    var body: some View {
        Text(labelText)
            .font(.system(size: 12, weight: .semibold))
            .kerning(0.2)
            .foregroundColor(themeManager.secondaryText)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(pillBackground)
                    .overlay(
                        Capsule()
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
            .accessibilityLabel(accessibilityText)
    }

    private var pillBackground: Color {
        themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white
    }
}

private struct StreakBadge: View {
    let streak: Int
    let themeManager: ThemeManager
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 6) {
                Text("🔥")
                    .font(.system(size: 14))
                Text("\(streak)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(streakColor)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(badgeBackground)
                    .overlay(
                        Capsule()
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Reading streak: \(streak) days. Tap to view progress.")
    }

    private var badgeBackground: Color {
        themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white
    }

    private var streakColor: Color {
        themeManager.accentColor
    }
}

private struct DailyReminderBanner: View {
    let message: DailyMessage
    let surahName: String
    let themeManager: ThemeManager
    let onTap: () -> Void

    private var bannerGradient: LinearGradient {
        themeManager.accentGradient
    }

    private var headlineText: String {
        "\u{201C}\(message.english)\u{201D}"
    }

    private var sourceLabel: String {
        "\(surahName) · \(message.surah):\(message.verse)"
    }

    private var shareText: String {
        "\(headlineText) — \(sourceLabel)"
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                // Decorative crescent
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 110, height: 110)
                        .offset(x: 30, y: -30)
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 100, height: 100)
                        .offset(x: 50, y: -10)
                }
                .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.92))
                        Text("A REMINDER FOR TODAY")
                            .font(.system(size: 11, weight: .bold))
                            .kerning(1.3)
                            .foregroundColor(.white.opacity(0.92))
                    }

                    Text(headlineText)
                        .font(.system(size: 19, weight: .bold))
                        .kerning(-0.2)
                        .lineSpacing(3)
                        .foregroundColor(.white)
                        .frame(maxWidth: 270, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    Text(sourceLabel)
                        .font(.system(size: 12.5))
                        .foregroundColor(.white.opacity(0.85))
                }
                .padding(18)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(
                RoundedRectangle(cornerRadius: 22)
                    .fill(bannerGradient)
            )
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .shadow(
                color: themeManager.accentColor.opacity(0.28),
                radius: 14, x: 0, y: 12
            )
        }
        .buttonStyle(PlainButtonStyle())
        .contextMenu {
            ShareLink(item: shareText) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .accessibilityLabel("\(message.english). \(sourceLabel). Double tap to open verse.")
    }
}

private struct ContinueReadingHero: View {
    let info: LastReadInfo?
    let surah: SurahWithTafsir?
    let verse: VerseWithTafsir?
    let themeManager: ThemeManager
    let onResume: () -> Void
    let onBegin: () -> Void

    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("CONTINUE READING")
                    .font(.system(size: 13, weight: .bold))
                    .kerning(0.4)
                    .foregroundColor(themeManager.secondaryText)
                Spacer()
                if let info = info {
                    Text(Self.relativeFormatter.localizedString(for: info.updatedAt, relativeTo: Date()))
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.tertiaryText)
                }
            }

            cardBody
        }
    }

    @ViewBuilder
    private var cardBody: some View {
        Group {
            if let info = info, let surah = surah, let verse = verse {
                populatedCard(info: info, surah: surah, verse: verse)
            } else {
                emptyCard
            }
        }
        .padding(16)
        .background(cardBackground)
    }

    @ViewBuilder
    private func populatedCard(info: LastReadInfo, surah: SurahWithTafsir, verse: VerseWithTafsir) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            identityRow(info: info, surah: surah)
            versePreview(verse: verse)
            progressAndResume(info: info)
        }
    }

    @ViewBuilder
    private func identityRow(info: LastReadInfo, surah: SurahWithTafsir) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(avatarBackground)
                Text("\(surah.surah.number)")
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundColor(themeManager.accentColor)
            }
            .frame(width: 48, height: 48)

            VStack(alignment: .leading, spacing: 2) {
                Text(surah.surah.englishName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                Text("Verse \(info.verseNumber) of \(surah.surah.versesCount) · \(surah.surah.englishNameTranslation)")
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.tertiaryText)
                    .lineLimit(1)
            }

            Spacer()

            Text(surah.surah.arabicName)
                .font(.custom("Amiri", size: 22))
                .foregroundColor(themeManager.primaryText)
        }
    }

    @ViewBuilder
    private func versePreview(verse: VerseWithTafsir) -> some View {
        VStack(alignment: .trailing, spacing: 8) {
            Text(verse.arabicText)
                .font(.custom("Amiri", size: 19))
                .lineSpacing(5)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .environment(\.layoutDirection, .rightToLeft)
                .foregroundColor(themeManager.primaryText)

            Text("\u{201C}\(verse.translation)\u{201D}")
                .font(.system(size: 12.5))
                .lineSpacing(2)
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(versePreviewBackground)
        )
    }

    @ViewBuilder
    private func progressAndResume(info: LastReadInfo) -> some View {
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(progressTrackColor)
                            .frame(height: 6)
                        Capsule()
                            .fill(themeManager.accentColor)
                            .frame(width: max(0, geo.size.width * info.progress), height: 6)
                    }
                }
                .frame(height: 6)

                Text("\(Int(info.progress * 100))% complete")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }

            Button(action: onResume) {
                HStack(spacing: 6) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 12))
                    Text("Resume")
                        .font(.system(size: 13, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Capsule().fill(resumeBackground))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    @ViewBuilder
    private var emptyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start your journey")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(themeManager.primaryText)
            Text("Open Surah Al-Fātiḥa")
                .font(.system(size: 13))
                .foregroundColor(themeManager.secondaryText)

            Button(action: onBegin) {
                Text("Begin")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Capsule().fill(resumeBackground))
            }
            .buttonStyle(PlainButtonStyle())
        }
    }

    // MARK: - Theme tokens

    private var cardBackground: some View {
        Group {
            RoundedRectangle(cornerRadius: 22)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(RoundedRectangle(cornerRadius: 22).stroke(themeManager.strokeColor, lineWidth: 1))
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.06),
                    radius: 9, x: 0, y: 6
                )
        }
    }

    private var avatarBackground: Color {
        themeManager.accentColorSoft
    }

    private var versePreviewBackground: Color {
        themeManager.secondaryBackground
    }

    private var progressTrackColor: Color {
        themeManager.tertiaryBackground
    }

    private var resumeBackground: Color {
        themeManager.selectedTheme == .nightSanctuary ? themeManager.accentColor : themeManager.primaryText
    }
}

private struct DuaOfTheDayCard: View {
    let dua: DailyDua
    let themeManager: ThemeManager

    var body: some View {
        NavigationLink(destination: DuaDetailView(dua: dua)) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconBackground)
                    Image(systemName: "quote.bubble.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.accentColor)
                }
                .frame(width: 28, height: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Du'a of the day")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(themeManager.secondaryText)
                    Text(dua.situationEn)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(2)
                    Text(dua.category.capitalized)
                        .font(.system(size: 11))
                        .foregroundColor(themeManager.tertiaryText)
                }

                Spacer()

                Image(systemName: "arrow.right")
                    .font(.system(size: 14))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(14)
            .background(cardBackground)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var iconBackground: Color {
        themeManager.accentColorSoft
    }

    private var cardBackground: some View {
        Group {
            RoundedRectangle(cornerRadius: 18)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(RoundedRectangle(cornerRadius: 18).stroke(themeManager.strokeColor, lineWidth: 1))
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.05),
                    radius: 7, x: 0, y: 4
                )
        }
    }
}

#Preview("TodayView — Warm") {
    TodayView(selectedTab: .constant(1))
        .preferredColorScheme(.light)
}
