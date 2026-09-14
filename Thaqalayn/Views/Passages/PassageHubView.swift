//
//  PassageHubView.swift
//  Thaqalayn
//
//  A passage's home: its title and opening verse, then its stages - Read,
//  Understand, Test yourself - laid out as a path, each sealing once it is
//  finished, and a bottom bar that always carries the next step. The passage
//  list pushes this screen for every passage; the reader, the Understanding
//  screen and the quiz are pushed from here and pop back here when their
//  Finish button is tapped. Nothing is marked by hand.
//

import SwiftUI

struct PassageHubView: View {
    let surahWithTafsir: SurahWithTafsir
    let ref: PassageRef

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var passageStore = PassageStore.shared
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @ObservedObject private var quizStore = QuizStore.shared
    @ObservedObject private var quizResults = QuizResultsStore.shared
    @ObservedObject private var stageStore = PassageStageStore.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showingReader = false
    @State private var showingUnderstanding = false
    @State private var showingQuiz = false
    @State private var showingNext = false
    @State private var showingPaywall = false
    /// What the user reached for when the paywall fired - drives its hero art.
    @State private var paywallContext: PaywallContext? = nil
    /// Brief pop of the header heart after the passage is saved.
    @State private var showingSaveFeedback = false

    // MARK: - Derived

    private var surah: Surah { surahWithTafsir.surah }

    private var passage: Passage? { passageStore.passage(surah: surah.number, index: ref.index) }

    private var quiz: PassageQuiz? { quizStore.quiz(for: ref) }

    private var versesInRange: [VerseWithTafsir] {
        surahWithTafsir.verses.filter { ref.start...ref.end ~= $0.number }
    }

    private var firstVerse: VerseWithTafsir? {
        versesInRange.first { $0.number == ref.start }
    }

    private var passageCount: Int {
        dataManager.passageIndex?.passages(forSurah: surah.number).count ?? 0
    }

    private var nextRef: PassageRef? {
        dataManager.passageIndex?.next(after: ref)
    }

    private var title: String { passageStore.title(for: ref) }

    private var eyebrow: String {
        "Passage \(ref.index) of \(passageCount) · verses \(ref.rangeLabel)"
    }

    /// Minutes to read the verses themselves at 200 words a minute, at least 1.
    private var readingMinutes: Int {
        let words = versesInRange.reduce(0) { $0 + $1.translation.split(separator: " ").count }
        return max(1, words / 200 + 1)
    }

    private var readSubline: String {
        let verses = ref.verseCount == 1 ? "1 verse" : "\(ref.verseCount) verses"
        return "\(verses) · \(readingMinutes) min"
    }

    private var understandSubline: String {
        guard let passage else { return PassageHubStrings.comingSoon }
        let narrations = passage.narrationCount == 1 ? "1 narration" : "\(passage.narrationCount) narrations"
        return "Essay · \(narrations) · \(passage.readingMinutes) min"
    }

    private var quizSubline: String {
        if let best = quizResults.best(for: ref) { return PassageHubStrings.best(best.score, of: best.total) }
        let count = quiz?.questions.count ?? 0
        return count == 1 ? "1 question" : "\(count) questions"
    }

    private var stages: PassageStages {
        PassageStages(
            isRead: progressManager.isPassageRead(ref),
            isUnderstood: stageStore.isUnderstood(ref),
            bestScore: quizResults.best(for: ref)?.score,
            quizTotal: quiz?.questions.count ?? 5,
            hasCommentary: passage != nil,
            hasQuiz: quiz != nil
        )
    }

    private var isUnderstandingGated: Bool { !premiumManager.canAccessUnderstanding(surahNumber: surah.number) }
    private var isQuizGated: Bool { !premiumManager.canAccessQuiz(surahNumber: surah.number) }

    private var isPassageSaved: Bool {
        bookmarkManager.isPassageBookmarked(surah: surah.number, index: ref.index)
    }

    // MARK: - Body

    var body: some View {
        let stages = self.stages
        let isPlaying = audioManager.currentPlayback != nil

        ZStack {
            if themeManager.isMidnightEmerald {
                EmeraldBackground()
            } else {
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
            }

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        titleBlock(stages: stages)

                        if stages.isComplete {
                            completeBlock(stages: stages)
                        } else {
                            hero
                        }

                        stageList(stages: stages)
                            .padding(.top, 22)

                        if !stages.isComplete, nextRef != nil {
                            nextPassageLink
                                .padding(.top, 8)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 4)
                    // Room for the pinned bar (and the player when it is up).
                    .padding(.bottom, isPlaying ? 220 : 140)
                }
            }
        }
        .background(
            // Screen-level links: every spoke is pushed from here and pops back here.
            ZStack {
                NavigationLink(destination: readerDestination, isActive: $showingReader) { EmptyView() }
                NavigationLink(destination: understandingDestination, isActive: $showingUnderstanding) { EmptyView() }
                NavigationLink(destination: quizDestination, isActive: $showingQuiz) { EmptyView() }
                NavigationLink(destination: nextDestination, isActive: $showingNext) { EmptyView() }
            }
            .hidden()
            .accessibilityHidden(true)
        )
        .navigationBarHidden(true)
        .hideTabBar()
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.22, starCount: 10)
        .overlay(alignment: .bottom) {
            VStack(spacing: 10) {
                if let action = action(for: stages) {
                    HubActionBar(action: action)
                        .padding(.horizontal, 20)
                        .padding(.bottom, isPlaying ? 0 : 12)
                }
                if isPlaying {
                    SurahAudioPlayerView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isPlaying)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(context: paywallContext)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 10) {
            Button(action: { dismiss() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())

            Spacer()

            Button(action: toggleSaved) {
                Image(systemName: isPassageSaved ? "heart.fill" : "heart")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isPassageSaved ? themeManager.accentBright : themeManager.accentColor)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(themeManager.glassSurface))
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                    .scaleEffect(showingSaveFeedback ? 1.25 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingSaveFeedback)
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel(isPassageSaved ? "Remove passage bookmark" : "Save passage")

            Button(action: {
                Task { await audioManager.playVerseSequence(versesInRange, in: surah, startingFrom: 0) }
            }) {
                Image(systemName: "play.fill")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 40, height: 40)
                    .background(Circle().fill(themeManager.glassSurface))
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Play passage")
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 8)
    }

    private func titleBlock(stages: PassageStages) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow.uppercased())
                    .emEyebrow(size: 11, tracking: 2)
                    .foregroundColor(themeManager.accentColor)
                Text(title)
                    .font(EmType.serif(34, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 6) {
                PassageProgressRing(done: stages.doneCount, total: stages.total, size: 44, lineWidth: 3.4)
                Text(PassageHubStrings.ringLabel(stages.doneCount, of: stages.total))
                    .font(.system(size: 11, weight: .bold)).tracking(1)
                    .foregroundColor(themeManager.tertiaryText)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("\(stages.doneCount) of \(stages.total) stages done")
        }
        .padding(.top, 8)
    }

    // MARK: - Hero

    /// The opening verse, so the passage is recognisable before it is opened.
    @ViewBuilder private var hero: some View {
        if let verse = firstVerse {
            VStack(alignment: .leading, spacing: 10 * readingSettings.scale) {
                Text(verse.arabicText)
                    .font(EmType.arabic(24 * readingSettings.scale))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(10 * readingSettings.scale)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.layoutDirection, .rightToLeft)

                Text(verse.translation)
                    .font(EmType.serifItalic(16 * readingSettings.scale))
                    .foregroundColor(themeManager.secondaryText)
                    .lineSpacing(5 * readingSettings.scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                Rectangle()
                    .fill(themeManager.dividerColor)
                    .frame(height: 1)
                    .padding(.top, 12)
            }
            .padding(.top, 18)
        }
    }

    /// Replaces the opening verse once every stage is sealed.
    private func completeBlock(stages: PassageStages) -> some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 52, weight: .semibold))
                .foregroundStyle(themeManager.accentGradient)
                .shadow(color: themeManager.accentColor.opacity(0.35), radius: 18, x: 0, y: 8)
            Text(PassageHubStrings.complete)
                .font(EmType.serif(24, .semiBold))
                .foregroundColor(themeManager.primaryText)
                .padding(.top, 6)
            Text(completeSubline(stages: stages))
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)

            Rectangle()
                .fill(themeManager.dividerColor)
                .frame(height: 1)
                .padding(.top, 16)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 22)
        .accessibilityElement(children: .combine)
    }

    private func completeSubline(stages: PassageStages) -> String {
        var parts = ["Read"]
        if stages.hasCommentary { parts.append("Understood") }
        if let best = quizResults.best(for: ref) { parts.append("\(best.score) of \(best.total) on the quiz") }
        return parts.joined(separator: " · ")
    }

    // MARK: - Stages

    private func stageList(stages: PassageStages) -> some View {
        ZStack(alignment: .topLeading) {
            // The path between the stage markers; each marker paints over it.
            Rectangle()
                .fill(themeManager.strokeColorStrong)
                .frame(width: 1)
                .padding(.leading, 17.5)
                .padding(.vertical, 30)

            VStack(spacing: 0) {
                HubStageRow(
                    number: 1,
                    title: PassageHubStrings.read,
                    subtitle: readSubline,
                    state: stages.isDone(.read) ? .done : (stages.next == .read ? .next : .todo),
                    gated: false,
                    onTap: openReader
                )
                HubStageRow(
                    number: 2,
                    title: PassageHubStrings.understand,
                    subtitle: understandSubline,
                    state: stages.hasCommentary
                        ? (stages.isDone(.understand) ? .done : (stages.next == .understand ? .next : .todo))
                        : .unavailable,
                    gated: stages.hasCommentary && isUnderstandingGated,
                    onTap: openUnderstanding
                )
                if stages.hasQuiz {
                    HubStageRow(
                        number: 3,
                        title: PassageHubStrings.test,
                        subtitle: quizSubline,
                        state: stages.isDone(.test) ? .done : (stages.next == .test ? .next : .todo),
                        gated: isQuizGated,
                        onTap: openQuiz
                    )
                }
            }
        }
    }

    /// A quiet way past this passage for readers who only want the verses.
    private var nextPassageLink: some View {
        Button(action: openNext) {
            HStack(spacing: 6) {
                Text(PassageHubStrings.nextPassage)
                    .font(.system(size: 14, weight: .semibold))
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .bold))
            }
            .foregroundColor(themeManager.tertiaryText)
            .padding(.leading, 50)
            .frame(minHeight: 44)
            .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle.gentle)
    }

    // MARK: - Bottom bar

    private func action(for stages: PassageStages) -> HubAction? {
        if stages.isComplete {
            if let next = nextRef {
                return HubAction(
                    title: PassageHubStrings.nextPassage,
                    subtitle: "\(passageStore.title(for: next)) · verses \(next.rangeLabel)",
                    gated: false,
                    perform: openNext
                )
            }
            return HubAction(
                title: PassageHubStrings.backToSurah(surah.englishName),
                subtitle: PassageHubStrings.surahComplete,
                gated: false,
                quiet: true,
                perform: { dismiss() }
            )
        }
        switch stages.next {
        case .read:
            return HubAction(title: PassageHubStrings.startReading, subtitle: readSubline, gated: false, perform: openReader)
        case .understand:
            return HubAction(title: PassageHubStrings.understandPassage, subtitle: understandSubline, gated: isUnderstandingGated, perform: openUnderstanding)
        case .test:
            return HubAction(title: PassageHubStrings.test, subtitle: quizSubline, gated: isQuizGated, perform: openQuiz)
        case nil:
            return nil
        }
    }

    // MARK: - Destinations

    @ViewBuilder private var readerDestination: some View {
        PassageView(surahWithTafsir: surahWithTafsir, ref: ref)
    }

    @ViewBuilder private var understandingDestination: some View {
        if let passage {
            UnderstandingView(surahWithTafsir: surahWithTafsir, ref: ref, passage: passage)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var quizDestination: some View {
        if let quiz {
            QuizView(surahWithTafsir: surahWithTafsir, ref: ref, quiz: quiz)
        } else {
            EmptyView()
        }
    }

    @ViewBuilder private var nextDestination: some View {
        if let next = nextRef {
            PassageHubView(surahWithTafsir: surahWithTafsir, ref: next)
        } else {
            EmptyView()
        }
    }

    // MARK: - Actions

    /// Every push waits a beat so the press squish is seen before the screen slides in.
    private func push(_ flag: Binding<Bool>) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { flag.wrappedValue = true }
    }

    private func openReader() { push($showingReader) }

    private func openUnderstanding() {
        guard passage != nil else { return }
        if isUnderstandingGated {
            paywallContext = .inSurah(surah, "Understanding")
            showingPaywall = true
        } else {
            push($showingUnderstanding)
        }
    }

    private func openQuiz() {
        guard quiz != nil else { return }
        if isQuizGated {
            paywallContext = .inSurah(surah, "Quiz")
            showingPaywall = true
        } else {
            push($showingQuiz)
        }
    }

    private func openNext() {
        guard nextRef != nil else { return }
        push($showingNext)
    }

    /// Header heart: the same manager call as the list's Save swipe and the
    /// reader's heart, so all three always agree.
    private func toggleSaved() {
        let arabic = firstVerse?.arabicText ?? ""
        let result = bookmarkManager.togglePassageBookmark(
            ref: ref,
            surahName: surah.englishName,
            title: title,
            firstVerseArabic: arabic
        )
        switch result {
        case .saved:
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            showingSaveFeedback = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { showingSaveFeedback = false }
        case .refused:
            UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .removed:
            break
        }
    }
}

// MARK: - Stage row

/// One stage on the path: a numbered marker (a seal once done, lit when it is
/// the next step), the stage title and its subline, and a chevron or the
/// PREMIUM capsule on the trailing edge. Done stages stay tappable, to read or
/// take the stage again.
struct HubStageRow: View {
    enum State { case done, next, todo, unavailable }

    let number: Int
    let title: String
    let subtitle: String
    let state: State
    let gated: Bool
    let onTap: () -> Void
    @ObservedObject private var tm = ThemeManager.shared

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                marker

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(EmType.serif(18, .semiBold))
                        .foregroundColor(state == .todo || state == .unavailable ? tm.tertiaryText : tm.primaryText)
                    Text(subtitle)
                        .font(.system(size: 13, weight: subtitleIsScore ? .semibold : .medium))
                        .foregroundColor(subtitleIsScore ? tm.semanticGreen : tm.secondaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                if state != .unavailable {
                    if gated {
                        Text(QuizStrings.premium)
                            .emEyebrow(size: 10, tracking: 1.5)
                            .foregroundColor(tm.accentColor)
                            .padding(.horizontal, 9)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(tm.accentChip))
                    } else {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(state == .next ? tm.accentColor : tm.quaternaryText)
                    }
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle.gentle)
        .disabled(state == .unavailable)
        .opacity(state == .unavailable ? 0.55 : 1)
        .accessibilityLabel(accessibility)
    }

    /// "Best 4 of 5" reads as a result, so it takes the done colour.
    private var subtitleIsScore: Bool { state == .done && subtitle.hasPrefix("Best ") }

    @ViewBuilder private var marker: some View {
        ZStack {
            // Paints over the path line behind the row.
            Circle().fill(tm.primaryBackground)
            switch state {
            case .done:
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(tm.semanticGreen)
            case .next:
                Circle().fill(tm.accentChip)
                Circle().stroke(tm.accentColor, lineWidth: 1)
                Circle().stroke(tm.accentColor.opacity(0.18), lineWidth: 8).padding(-4)
                Text("\(number)")
                    .font(EmType.serif(15, .semiBold))
                    .foregroundColor(tm.accentBright)
            case .todo, .unavailable:
                Circle().stroke(tm.strokeColorStrong, lineWidth: 1)
                Text("\(number)")
                    .font(EmType.serif(15, .semiBold))
                    .foregroundColor(tm.tertiaryText)
            }
        }
        .frame(width: 36, height: 36)
    }

    private var accessibility: String {
        switch state {
        case .done: return "\(title), done. \(subtitle). Tap to open again"
        case .next: return "\(title), next. \(subtitle)"
        case .todo: return "\(title). \(subtitle)"
        case .unavailable: return "\(title). \(subtitle)"
        }
    }
}

// MARK: - Bottom bar

struct HubAction {
    let title: String
    let subtitle: String
    let gated: Bool
    /// Glass instead of gold: the surah is finished and the bar only leads back.
    var quiet: Bool = false
    let perform: () -> Void
}

/// The pinned bar at the foot of the hub: gold with the next step's title and
/// subline, glass with the PREMIUM capsule when that step is gated.
struct HubActionBar: View {
    let action: HubAction
    @ObservedObject private var tm = ThemeManager.shared

    private var isGold: Bool { !action.gated && !action.quiet }

    var body: some View {
        Button(action: action.perform) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(action.title)
                        .font(EmType.serif(18, .semiBold))
                        .foregroundColor(isGold ? tm.onAccentText : tm.primaryText)
                    Text(action.subtitle)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(isGold ? tm.onAccentText.opacity(0.72) : tm.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                if action.gated {
                    Text(QuizStrings.premium)
                        .emEyebrow(size: 10, tracking: 1.5)
                        .foregroundColor(tm.accentColor)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(tm.accentChip))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isGold ? tm.onAccentText : tm.accentColor)
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isGold ? AnyShapeStyle(tm.accentGradient) : AnyShapeStyle(tm.primaryBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(isGold ? Color.clear : tm.accentColor.opacity(0.12))
                    .allowsHitTesting(false)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isGold ? Color.clear : tm.accentColor, lineWidth: 1)
            )
            .shadow(color: isGold ? tm.accentColor.opacity(0.28) : Color.black.opacity(0.28),
                    radius: isGold ? 24 : 14, x: 0, y: isGold ? 10 : 6)
        }
        .buttonStyle(EmPressStyle())
        .accessibilityLabel(action.gated ? "\(action.title), premium feature" : "\(action.title). \(action.subtitle)")
    }
}

// MARK: - Ring

/// A ring of one arc per stage, gold for the stages done. The list rows use
/// it small; the hub header uses it large.
struct PassageProgressRing: View {
    let done: Int
    let total: Int
    var size: CGFloat = 20
    var lineWidth: CGFloat = 2.2
    @ObservedObject private var tm = ThemeManager.shared

    var body: some View {
        let count = max(total, 1)
        // A gap on each side of every arc, as a fraction of the circle.
        let gap = count == 1 ? 0.0 : 0.035
        ZStack {
            ForEach(0..<count, id: \.self) { i in
                Circle()
                    .trim(from: Double(i) / Double(count) + gap, to: Double(i + 1) / Double(count) - gap)
                    .stroke(
                        i < done ? tm.accentColor : tm.accentColor.opacity(0.22),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
            }
        }
        .frame(width: size, height: size)
        .padding(lineWidth / 2)
        .accessibilityHidden(true)
    }
}

// MARK: - Strings

/// Chrome copy for the passage hub. English only, plain spelling, no em dash.
enum PassageHubStrings {
    static let read = "Read the verses"
    static let understand = "Understand"
    static let test = "Test yourself"
    static let startReading = "Start reading"
    static let understandPassage = "Understand this passage"
    static let nextPassage = "Next passage"
    static let complete = "Passage complete"
    static let surahComplete = "Every passage finished"
    static let comingSoon = "Coming in an update"

    static func best(_ score: Int, of total: Int) -> String { "Best \(score) of \(total)" }
    static func ringLabel(_ done: Int, of total: Int) -> String { "\(done) of \(total)" }
    static func backToSurah(_ name: String) -> String { "Back to \(name)" }
}
