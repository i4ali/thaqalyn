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
    @StateObject private var languageManager = CommentaryLanguageManager.shared
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
            Group {
                if themeManager.isMidnightEmerald {
                    EmeraldTodayView(
                        selectedTab: $selectedTab,
                        selectedSurahForDeepLink: $selectedSurahForDeepLink,
                        targetVerseNumber: $targetVerseNumber,
                        showingNotifications: $showingNotifications
                    )
                } else {
                    legacyContent
                }
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

    // MARK: - Legacy (Light / Night Sanctuary) content

    private var legacyContent: some View {
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
                    headline: reminderHeadline.text,
                    isUrdu: reminderHeadline.isUrdu,
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

                #if DEBUG
                if ProcessInfo.processInfo.arguments.contains("-tallToday") {
                    Color.clear.frame(height: 800)
                }
                #endif
            }
            .padding(.bottom, 40)
        }
    }

    /// Daily-reminder headline in the commentary language: Urdu shows the
    /// Jawadi verse translation (the curated quote only exists in English);
    /// any other language falls back to the English line.
    private var reminderHeadline: (text: String, isUrdu: Bool) {
        if languageManager.selectedLanguage == .urdu,
           let verse = dataManager.getVerse(surah: dailyMessage.today.surah, verse: dailyMessage.today.verse),
           verse.usesUrduTranslation(for: .urdu) {
            return (verse.displayTranslation(for: .urdu), true)
        }
        return (dailyMessage.today.english, false)
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
            HStack(spacing: 6) {
                Text("Assalāmu ʿalaykum")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                PhosphorIcon(name: "ph-moon-stars-fill", size: 14)
                    .foregroundColor(themeManager.accentColor)
            }

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

private struct DailyReminderBanner: View {
    let message: DailyMessage
    let headline: String
    let isUrdu: Bool
    let surahName: String
    let themeManager: ThemeManager
    let onTap: () -> Void

    private var bannerGradient: LinearGradient {
        themeManager.accentGradient
    }

    /// Latin curly quotes misbehave around RTL text — Urdu renders unquoted.
    private var headlineText: String {
        isUrdu ? headline : "\u{201C}\(headline)\u{201D}"
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
                        .font(isUrdu ? EmType.arabic(20) : .system(size: 19, weight: .bold))
                        .kerning(isUrdu ? 0 : -0.2)
                        .lineSpacing(isUrdu ? 7 : 3)
                        .foregroundColor(.white)
                        .frame(maxWidth: 270, alignment: isUrdu ? .trailing : .leading)
                        .multilineTextAlignment(isUrdu ? .trailing : .leading)
                        .environment(\.layoutDirection, isUrdu ? .rightToLeft : .leftToRight)
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
        .accessibilityLabel("\(headline). \(sourceLabel). Double tap to open verse.")
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
        .buttonStyle(EmPressStyle())
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

// MARK: - Midnight Emerald — Today

private struct EmeraldTodayView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var dailyMessage = DailyMessageProvider.shared
    @ObservedObject private var duasManager = DuasManager.shared
    @ObservedObject private var calendarManager = IslamicCalendarManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared

    @Binding var selectedTab: Int
    @Binding var selectedSurahForDeepLink: SurahWithTafsir?
    @Binding var targetVerseNumber: Int?
    @Binding var showingNotifications: Bool

    @State private var animateProgress = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                headerRow
                greeting
                EmDailyReminderHero(
                    message: dailyMessage.today,
                    headline: reminderHeadline.text,
                    isUrdu: reminderHeadline.isUrdu,
                    surahName: surahName(for: dailyMessage.today.surah),
                    onTap: openMessageSource
                )
                EmContinueReadingCard(
                    info: progressManager.lastReadInfo,
                    surah: lastReadSurah,
                    verse: lastReadVerse,
                    animateProgress: animateProgress,
                    onResume: openLastRead,
                    onBegin: openSurah1
                )
                if let dua = duasManager.duaOfTheDay() {
                    EmDuaOfTheDayCard(dua: dua)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 120)
        }
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.6)) { animateProgress = true }
        }
    }

    private var headerRow: some View {
        VStack(spacing: 14) {
            HStack(spacing: 10) {
                ProfileAvatar()
                Spacer()
                NotificationBell(showingNotifications: $showingNotifications)
            }
            HStack { HijriDatePill(themeManager: themeManager, calendarManager: calendarManager); Spacer() }
        }
    }

    private var greeting: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text("Assalāmu ʿalaykum")
                    .font(.system(size: 12, weight: .semibold)).tracking(0.5)
                    .foregroundColor(themeManager.tertiaryText)
                PhosphorIcon(name: "ph-moon-stars-fill", size: 13).foregroundColor(themeManager.accentColor)
            }
            Text("Today").font(EmType.serif(40, .semiBold)).foregroundColor(themeManager.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func surahName(for n: Int) -> String {
        dataManager.availableSurahs.first(where: { $0.surah.number == n })?.surah.englishName ?? "Surah \(n)"
    }
    /// Urdu shows the Jawadi verse translation (curated quote is English-only).
    private var reminderHeadline: (text: String, isUrdu: Bool) {
        if languageManager.selectedLanguage == .urdu,
           let verse = dataManager.getVerse(surah: dailyMessage.today.surah, verse: dailyMessage.today.verse),
           verse.usesUrduTranslation(for: .urdu) {
            return (verse.displayTranslation(for: .urdu), true)
        }
        return (dailyMessage.today.english, false)
    }
    private func openMessageSource() {
        guard let s = dataManager.availableSurahs.first(where: { $0.surah.number == dailyMessage.today.surah }) else { return }
        targetVerseNumber = dailyMessage.today.verse
        selectedSurahForDeepLink = s
    }
    private var lastReadSurah: SurahWithTafsir? {
        guard let info = progressManager.lastReadInfo else { return nil }
        return dataManager.availableSurahs.first(where: { $0.surah.number == info.surahNumber })
    }
    private var lastReadVerse: VerseWithTafsir? {
        guard let info = progressManager.lastReadInfo, let s = lastReadSurah,
              info.verseNumber >= 1, info.verseNumber <= s.verses.count else { return nil }
        return s.verses[info.verseNumber - 1]
    }
    private func openLastRead() {
        guard let info = progressManager.lastReadInfo, let s = lastReadSurah else { return }
        targetVerseNumber = info.verseNumber
        selectedSurahForDeepLink = s
    }
    private func openSurah1() {
        guard let s = dataManager.availableSurahs.first(where: { $0.surah.number == 1 }) else { return }
        targetVerseNumber = 1
        selectedSurahForDeepLink = s
    }
}

// Refined gold hero — gold-gradient block with near-black serif text
private struct EmDailyReminderHero: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let message: DailyMessage
    let headline: String
    let isUrdu: Bool
    let surahName: String
    let onTap: () -> Void

    /// Latin curly quotes misbehave around RTL text — Urdu renders unquoted.
    private var headlineText: String {
        isUrdu ? headline : "\u{201C}\(headline)\u{201D}"
    }

    private var sourceLabel: String {
        "\(surahName) \u{00B7} \(message.surah):\(message.verse)"
    }

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                ZStack {
                    Circle().fill(themeManager.onAccentText.opacity(0.08)).frame(width: 110, height: 110).offset(x: 30, y: -30)
                    Circle().fill(themeManager.onAccentText.opacity(0.08)).frame(width: 100, height: 100).offset(x: 50, y: -10)
                }.allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles").font(.system(size: 13, weight: .semibold))
                        Text("A REMINDER FOR TODAY").font(.system(size: 11, weight: .bold)).tracking(1.3)
                    }
                    .foregroundColor(themeManager.onAccentText.opacity(0.75))

                    Text(headlineText)
                        .font(isUrdu ? EmType.arabic(22) : EmType.serif(24, .semiBold))
                        .foregroundColor(themeManager.onAccentText)
                        .lineSpacing(isUrdu ? 8 : 3)
                        .multilineTextAlignment(isUrdu ? .trailing : .leading)
                        .environment(\.layoutDirection, isUrdu ? .rightToLeft : .leftToRight)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: isUrdu ? .trailing : .leading)

                    Text(sourceLabel)
                        .font(.system(size: 12.5, weight: .medium))
                        .foregroundColor(themeManager.onAccentText.opacity(0.7))
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(RoundedRectangle(cornerRadius: 22, style: .continuous).fill(themeManager.accentGradient))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .shadow(color: themeManager.accentColor.opacity(0.30), radius: 24, x: 0, y: 12)
        }
        .buttonStyle(EmPressStyle())
        .contextMenu {
            ShareLink(item: "\(headlineText) \u{2014} \(sourceLabel)") {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
    }
}

private struct EmContinueReadingCard: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let info: LastReadInfo?
    let surah: SurahWithTafsir?
    let verse: VerseWithTafsir?
    let animateProgress: Bool
    let onResume: () -> Void
    let onBegin: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("CONTINUE READING").font(.system(size: 11, weight: .bold)).tracking(2).foregroundColor(themeManager.accentColor)
            EmCard(glow: true) {
                Group {
                    if let info, let surah, let verse {
                        populated(info: info, surah: surah, verse: verse)
                    } else {
                        empty
                    }
                }
                .padding(18)
            }
        }
    }

    private func populated(info: LastReadInfo, surah: SurahWithTafsir, verse: VerseWithTafsir) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                EmNumeralCircle(n: surah.surah.number, size: 48)
                VStack(alignment: .leading, spacing: 2) {
                    Text(surah.surah.englishName).font(EmType.serif(20, .semiBold)).foregroundColor(themeManager.primaryText)
                    Text("Verse \(info.verseNumber) of \(surah.surah.versesCount)").font(.system(size: 12)).foregroundColor(themeManager.tertiaryText).lineLimit(1)
                }
                Spacer(minLength: 8)
                Text(surah.surah.arabicName).font(EmType.arabic(22)).foregroundColor(themeManager.accentBright).lineLimit(1)
            }

            VStack(alignment: .trailing, spacing: 8) {
                Text(verse.arabicText)
                    .font(EmType.arabic(20)).lineSpacing(6).multilineTextAlignment(.trailing)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .environment(\.layoutDirection, .rightToLeft)
                    .foregroundColor(themeManager.primaryText)
                Text("\u{201C}\(verse.translation)\u{201D}")
                    .font(.system(size: 12.5)).lineSpacing(2)
                    .foregroundColor(themeManager.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(14)
            .background(RoundedRectangle(cornerRadius: 14, style: .continuous).fill(themeManager.glassSurfaceElevated))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))

            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 4) {
                    ZStack(alignment: .leading) {
                        Capsule().fill(themeManager.accentChip).frame(height: 6)
                        GeometryReader { geo in
                            Capsule().fill(themeManager.accentGradient)
                                .frame(width: max(0, geo.size.width * CGFloat(animateProgress ? info.progress : 0)), height: 6)
                        }.frame(height: 6)
                    }.frame(height: 6)
                    Text("\(Int(info.progress * 100))% complete").font(.system(size: 11, weight: .semibold)).foregroundColor(themeManager.tertiaryText)
                }
                Button(action: onResume) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill").font(.system(size: 12, weight: .semibold))
                        Text("Resume").font(.system(size: 13, weight: .bold))
                    }
                    .foregroundColor(themeManager.onAccentText)
                    .padding(.horizontal, 16).padding(.vertical, 10)
                    .background(Capsule().fill(themeManager.accentGradient))
                }
                .buttonStyle(EmPressStyle())
            }
        }
    }

    private var empty: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start your journey").font(EmType.serif(22, .semiBold)).foregroundColor(themeManager.primaryText)
            Text("Open Surah Al-Fātiḥa").font(.system(size: 13)).foregroundColor(themeManager.secondaryText)
            EmGoldCTA(title: "Begin", sfSymbol: "play.fill") { onBegin() }
        }
    }
}

private struct EmDuaOfTheDayCard: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let dua: DailyDua

    var body: some View {
        NavigationLink(destination: DuaDetailView(dua: dua)) {
            EmCard {
                HStack(spacing: 12) {
                    EmIconChip(sfSymbol: "quote.bubble.fill", size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("DU'A OF THE DAY").font(.system(size: 11, weight: .bold)).tracking(1.5).foregroundColor(themeManager.accentColor)
                        Text(dua.situationEn).font(EmType.serif(18, .semiBold)).foregroundColor(themeManager.primaryText).lineLimit(2)
                        Text(dua.category.capitalized).font(.system(size: 11)).foregroundColor(themeManager.tertiaryText)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(themeManager.tertiaryText)
                }
                .padding(16)
            }
        }
        .buttonStyle(EmPressStyle())
    }
}

#Preview("TodayView — Warm") {
    TodayView(selectedTab: .constant(1))
        .preferredColorScheme(.light)
}
