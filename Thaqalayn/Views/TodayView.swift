//
//  TodayView.swift
//  Thaqalayn
//
//  The Today tab — daily reminder, continue reading, du'a of the day.
//

import SwiftUI

// MARK: - Today copy
// Copy for the Today tab (greeting, section labels, buttons). English is stored
// in natural case; call sites that render small-caps apply `.uppercased()`.
private enum TodayStrings {
    static let greeting = "Assalamu alaykum"
    /// Greeting with the user's name appended. Falls back to the bare greeting
    /// when no name is set.
    static func greeting(name: String) -> String {
        guard !name.isEmpty else { return greeting }
        return greeting + ", " + name
    }
    static let today = "Today"
    static let reminderEyebrow = "A reminder for today"
    static let continueReading = "Continue reading"
    static let duaOfTheDay = "Du'a of the day"
    static let startJourney = "Start your journey"
    static let openFatiha = "Open Surah Al-Fatiha"
    static let begin = "Begin"
    static let resume = "Resume"
    static let share = "Share"
    static func verseOf(_ n: Int, _ total: Int) -> String { "Verse \(n) of \(total)" }
    /// Continue-reading position: "<passage title> · passage 3 of 40". The no-break
    /// space keeps the dot with the title when the line wraps.
    static func passagePosition(_ title: String, _ index: Int, _ total: Int) -> String {
        "\(title)\u{00A0}· passage \(index) of \(total)"
    }
    /// Title fallback for a passage without commentary yet: "Verses 30 to 39".
    static func versesRange(_ label: String) -> String { "Verses \(label)" }
    static func percentComplete(_ p: Int) -> String { "\(p)% complete" }
    static func passagesRead(_ read: Int, _ total: Int) -> String { "\(read) of \(total) passages read" }
}

/// "<title> · passage i of n" for the passage holding the reading position.
/// nil until the passage index has loaded, so callers fall back to the verse line.
private func passagePositionLine(for info: LastReadInfo) -> String? {
    guard let index = info.passageIndex, let title = info.passageTitle, info.passagesTotal > 0 else { return nil }
    return TodayStrings.passagePosition(title, index, info.passagesTotal)
}

/// "3 of 24 passages read", or the percentage of verses until the passage
/// index has loaded.
private func progressLine(for info: LastReadInfo) -> String {
    info.passagesTotal > 0
        ? TodayStrings.passagesRead(info.passagesRead, info.passagesTotal)
        : TodayStrings.percentComplete(Int(info.progress * 100))
}

struct TodayView: View {
    @StateObject private var dailyVerse = DailyVerseProvider.shared
    @StateObject private var whatsNew = WhatsNewManager.shared

    @Binding var selectedTab: Int

    @State private var selectedSurahForDeepLink: SurahWithTafsir?
    @State private var targetVerseNumber: Int?
    @State private var hasAppeared = false
    @State private var showingNotifications = false
    @State private var showingSettings = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        ZStack {
            EmeraldTodayView(
                selectedTab: $selectedTab,
                selectedSurahForDeepLink: $selectedSurahForDeepLink,
                targetVerseNumber: $targetVerseNumber,
                showingNotifications: $showingNotifications
            )

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
            dailyVerse.refreshIfDayChanged()
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
        .onAppear { hasAppeared = true; whatsNew.refresh() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                dailyVerse.refreshIfDayChanged()
                DailyChallengeProvider.shared.refreshIfDayChanged()
                DailyCrosswordProvider.shared.refreshIfDayChanged()
                DailyCrosswordManager.shared.refreshForToday()
            }
        }
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
                    .fill(themeManager.glassSurface)
                    .overlay(
                        Capsule()
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
            .accessibilityLabel(accessibilityText)
    }
}

// MARK: - Today layout

private struct EmeraldTodayView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var dailyVerse = DailyVerseProvider.shared
    @ObservedObject private var duasManager = DuasManager.shared
    @ObservedObject private var calendarManager = IslamicCalendarManager.shared
    @ObservedObject private var profile = UserProfileManager.shared
    @ObservedObject private var whatsNew = WhatsNewManager.shared

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
                if let item = whatsNew.spotlight {
                    WhatsNewCard(item: item, selectedTab: $selectedTab)
                }
                EmDailyReminderHero(
                    selection: dailyVerse.today,
                    headline: reminderHeadline,
                    surahName: surahName(for: dailyVerse.today.surah),
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
                BookmarkSpotlightCard()
                DailyChallengeCard()
                DailyCrosswordCard()
                if let dua = duasManager.duaOfTheDay() {
                    EmDuaOfTheDayCard(dua: dua)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 120)
        }
        .onAppear {
            whatsNew.refresh()
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
                Text(TodayStrings.greeting(name: profile.greetingName))
                    .font(.system(size: 12, weight: .semibold)).tracking(0.5)
                    .foregroundColor(themeManager.tertiaryText)
                    .lineLimit(1)
                    .truncationMode(.tail)
                PhosphorIcon(name: "ph-moon-stars-fill", size: 13).foregroundColor(themeManager.accentColor)
            }
            Text(TodayStrings.today).font(EmType.serif(40, .semiBold)).foregroundColor(themeManager.primaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func surahName(for n: Int) -> String {
        dataManager.availableSurahs.first(where: { $0.surah.number == n })?.surah.englishName ?? "Surah \(n)"
    }
    /// Both translations come from quran_data.json now, so Urdu readers get the
    /// Jawadi translation instead of silently falling back to English.
    private var reminderHeadline: String {
        guard let verse = dataManager.getVerse(surah: dailyVerse.today.surah,
                                               verse: dailyVerse.today.verse) else {
            print("⚠️ EmeraldTodayView: daily verse \(dailyVerse.today.id) did not hydrate")
            return ""
        }
        return verse.translation
    }
    private func openMessageSource() {
        guard let s = dataManager.availableSurahs.first(where: { $0.surah.number == dailyVerse.today.surah }) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            targetVerseNumber = dailyVerse.today.verse
            selectedSurahForDeepLink = s
        }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            targetVerseNumber = info.verseNumber
            selectedSurahForDeepLink = s
        }
    }
    private func openSurah1() {
        guard let s = dataManager.availableSurahs.first(where: { $0.surah.number == 1 }) else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            targetVerseNumber = 1
            selectedSurahForDeepLink = s
        }
    }
}

// Daily-reminder hero - the day's verse set like a manuscript page: a paper fill,
// a thin double gold frame inside the card, and the verse centered between small
// gold diamonds. The verse follows the Reading text-size control, and steps down a
// size for long verses so the card doesn't tower over the rest of the Today tab.
private struct EmDailyReminderHero: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var readingSettings = ReadingSettingsManager.shared
    let selection: DailyVerseSelection
    let headline: String
    let surahName: String
    let onTap: () -> Void

    /// Warm paper by day; the card's own elevated surface by night.
    private static let paper = Color(light: Color(hex: "FBF8EF"), dark: Color.white.opacity(0.07))

    private var headlineText: String {
        "\u{201C}\(headline)\u{201D}"
    }

    private var sourceLabel: String {
        "\(surahName) \u{00B7} \(selection.surah):\(selection.verse)"
    }

    /// Base verse size before the reading scale: long verses step down so the
    /// page keeps its proportions.
    private var verseSize: CGFloat {
        switch headline.count {
        case ..<140: return 22
        case ..<260: return 20
        default:     return 18
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 14) {
                HStack(spacing: 10) {
                    diamond
                    Text(TodayStrings.reminderEyebrow.uppercased()).emEyebrow(size: 10.5, tracking: 2)
                    diamond
                }
                .foregroundColor(themeManager.accentColor)

                Text(headlineText)
                    .font(EmType.serif(verseSize * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(4 * readingSettings.scale)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity)

                ornament

                Text(sourceLabel.uppercased())
                    .font(.system(size: 11, weight: .semibold)).tracking(1.6)
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 30)
            .frame(maxWidth: .infinity)
            .background(pageFrame)
            .background(
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Self.paper)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(themeManager.strokeColor, lineWidth: 1)
            )
            .emShadow(.raised)
        }
        .buttonStyle(EmPressStyle())
        .contextMenu {
            ShareLink(item: "\(headlineText) \u{2014} \(sourceLabel)") {
                Label(TodayStrings.share, systemImage: "square.and.arrow.up")
            }
        }
    }

    private var diamond: some View {
        Rectangle()
            .fill(themeManager.accentOrnament)
            .frame(width: 5, height: 5)
            .rotationEffect(.degrees(45))
    }

    /// Hairline - diamond - hairline, between the verse and its reference.
    private var ornament: some View {
        HStack(spacing: 8) {
            Rectangle().fill(themeManager.accentOrnament.opacity(0.6)).frame(width: 28, height: 1)
            diamond
            Rectangle().fill(themeManager.accentOrnament.opacity(0.6)).frame(width: 28, height: 1)
        }
    }

    /// The manuscript frame: two gold hairlines inset from the card edge.
    private var pageFrame: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(themeManager.accentOrnament.opacity(0.55), lineWidth: 1)
                .padding(10)
            RoundedRectangle(cornerRadius: 11, style: .continuous)
                .stroke(themeManager.accentOrnament.opacity(0.3), lineWidth: 0.75)
                .padding(14)
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
            Text(TodayStrings.continueReading.uppercased()).emEyebrow(size: 11, tracking: 2).foregroundColor(themeManager.accentColor)
                .frame(maxWidth: .infinity, alignment: .leading)
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
                    // The passage the reader is in; the verse line until the passage index loads.
                    Text(passagePositionLine(for: info) ?? TodayStrings.verseOf(info.verseNumber, surah.surah.versesCount))
                        .font(.system(size: 12)).foregroundColor(themeManager.tertiaryText).lineLimit(2)
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
                    .multilineTextAlignment(.leading)
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
                    Text(progressLine(for: info)).font(.system(size: 11, weight: .semibold)).foregroundColor(themeManager.tertiaryText)
                }
                Button(action: onResume) {
                    HStack(spacing: 6) {
                        Image(systemName: "play.fill").font(.system(size: 12, weight: .semibold))
                        Text(TodayStrings.resume).font(.system(size: 13, weight: .bold))
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
            Text(TodayStrings.startJourney).font(EmType.serif(22, .semiBold)).foregroundColor(themeManager.primaryText)
            Text(TodayStrings.openFatiha).font(.system(size: 13)).foregroundColor(themeManager.secondaryText)
            EmGoldCTA(title: TodayStrings.begin, sfSymbol: "play.fill") { onBegin() }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct EmDuaOfTheDayCard: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let dua: DailyDua

    var body: some View {
        PressableNavLink {
            DuaDetailView(dua: dua)
        } label: {
            EmCard {
                HStack(spacing: 12) {
                    EmIconChip(sfSymbol: "quote.bubble.fill", size: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(TodayStrings.duaOfTheDay.uppercased()).emEyebrow(size: 11, tracking: 1.5).foregroundColor(themeManager.accentColor)
                        Text(dua.situationEn).font(EmType.serif(18, .semiBold)).foregroundColor(themeManager.primaryText).lineLimit(2)
                        Text(dua.category.capitalized).font(.system(size: 11)).foregroundColor(themeManager.tertiaryText)
                    }
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(themeManager.tertiaryText)
                }
                .padding(16)
            }
        }
    }
}

#Preview("TodayView - Sage Dawn") {
    TodayView(selectedTab: .constant(1))
        .preferredColorScheme(.light)
}
