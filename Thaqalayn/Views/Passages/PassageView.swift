//
//  PassageView.swift
//  Thaqalayn
//
//  One passage (a ruku) read in full: its verses in order, then a Mark as
//  read toggle, the Understand card for the passage commentary and a link
//  to the next passage. Only the toggle (or reading every verse elsewhere)
//  marks the passage read; scrolling to the end does not. The header heart
//  saves the whole passage as a bookmark; each verse keeps its own heart in
//  the rail.
//

import SwiftUI

struct PassageView: View {
    let surahWithTafsir: SurahWithTafsir
    let ref: PassageRef
    let scrollToVerse: Int?
    let openConceptId: String?

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var passageStore = PassageStore.shared
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var selectedVerseForSummary: VerseWithTafsir?
    @State private var pendingConceptId: String?
    @State private var showTextSizePanel = false
    @State private var showingPaywall = false
    /// What the user reached for when the paywall fired - drives its hero art.
    @State private var paywallContext: PaywallContext? = nil
    @State private var showingUnderstanding = false
    /// The scroll target is handled once; onAppear fires again when the user
    /// pops back from Understanding or a gem.
    @State private var didHandleScrollTarget = false
    /// True while the end-of-verses Understand card is on screen. The pinned
    /// Understand bar shows only while it is not, so the two never stack.
    @State private var endCardVisible = false
    /// The verse at the top of the screen, from the rows' frames. Recorded as
    /// the reading position when the reader leaves, so Continue Reading
    /// returns here.
    @State private var topVerse: Int?
    /// Brief pop of the header heart after the passage is saved.
    @State private var showingSaveFeedback = false

    init(surahWithTafsir: SurahWithTafsir, ref: PassageRef, scrollToVerse: Int? = nil, openConceptId: String? = nil) {
        self.surahWithTafsir = surahWithTafsir
        self.ref = ref
        self.scrollToVerse = scrollToVerse
        self.openConceptId = openConceptId
    }

    private static let scrollSpace = "passageScroll"

    // MARK: - Derived

    private var surah: Surah { surahWithTafsir.surah }

    private var versesInRange: [VerseWithTafsir] {
        surahWithTafsir.verses.filter { ref.start...ref.end ~= $0.number }
    }

    private var passage: Passage? {
        passageStore.passage(surah: surah.number, index: ref.index)
    }

    private var passageCount: Int {
        dataManager.passageIndex?.passages(forSurah: surah.number).count ?? 0
    }

    private var nextRef: PassageRef? {
        dataManager.passageIndex?.next(after: ref)
    }

    private var title: String {
        passageStore.title(for: ref)
    }

    private var eyebrow: String {
        "Passage \(ref.index) of \(passageCount) · verses \(ref.rangeLabel)"
    }

    /// Minutes to read the verses themselves at 200 words a minute, at least 1.
    private var readingMinutes: Int {
        let words = versesInRange.reduce(0) { $0 + $1.translation.split(separator: " ").count }
        return max(1, words / 200 + 1)
    }

    private var subline: String {
        let verses = ref.verseCount == 1 ? "1 verse" : "\(ref.verseCount) verses"
        return "\(verses) · \(readingMinutes) min"
    }

    /// The verse loaded in the player, when it belongs to this surah.
    private var playingVerse: Int? {
        guard let playback = audioManager.currentPlayback, playback.surahNumber == surah.number else { return nil }
        return playback.verseNumber
    }

    /// Every verse in the passage is marked read; the same test the list uses
    /// for its checkmark.
    private var isPassageRead: Bool {
        progressManager.isPassageRead(ref)
    }

    /// The whole passage is bookmarked (not any one of its verses).
    private var isPassageSaved: Bool {
        bookmarkManager.isPassageBookmarked(surah: surah.number, index: ref.index)
    }

    // MARK: - Body

    var body: some View {
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

                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            titleBlock
                                .padding(.bottom, 8)

                            ForEach(versesInRange) { verse in
                                PassageVerseRow(
                                    verse: verse,
                                    surah: surah,
                                    isPlaying: playingVerse == verse.number,
                                    onGems: { openGems(for: verse) }
                                )
                                .id("verse_\(verse.number)")
                                .background(
                                    GeometryReader { geo in
                                        Color.clear.preference(
                                            key: VerseBottomsKey.self,
                                            value: [verse.number: geo.frame(in: .named(Self.scrollSpace)).maxY]
                                        )
                                    }
                                )
                            }

                            markReadButton
                                .padding(.top, 28)

                            understandCard
                                .padding(.top, 14)
                                .onAppear { endCardVisible = true }
                                .onDisappear { endCardVisible = false }

                            if let next = nextRef {
                                NextPassageCard(surahWithTafsir: surahWithTafsir, next: next)
                                    .padding(.top, 14)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 48)
                    }
                    .coordinateSpace(name: Self.scrollSpace)
                    .onPreferenceChange(VerseBottomsKey.self) { bottoms in
                        // The first verse still meaningfully on screen: its
                        // bottom edge sits below the top of the scroll view
                        // by more than a sliver.
                        let top = bottoms.filter { $0.value > 80 }.keys.min()
                        if top != topVerse { topVerse = top }
                    }
                    .onAppear { handleScrollTarget(proxy) }
                    .onChange(of: audioManager.currentPlayback?.verseNumber) { _, newVerse in
                        // Follow playback through this passage.
                        guard let n = newVerse, playingVerse == n, ref.start...ref.end ~= n else { return }
                        withAnimation(.easeInOut(duration: 0.5)) {
                            proxy.scrollTo("verse_\(n)", anchor: .center)
                        }
                    }
                }
            }
        }
        .background(
            // Screen-level so the pinned bar can push Understanding before the
            // lazy list has ever built the end card.
            NavigationLink(destination: understandingDestination, isActive: $showingUnderstanding) { EmptyView() }
                .hidden()
                .accessibilityHidden(true)
        )
        .textSizePanelOverlay(isOpen: $showTextSizePanel, topPadding: 60, trailingPadding: 20)
        .onAppear { progressManager.enterPassage(ref) }
        .navigationBarHidden(true)
        .hideTabBar()
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.22, starCount: 10)
        .overlay(alignment: .bottom) {
            let isPlaying = audioManager.currentPlayback != nil
            VStack(spacing: 10) {
                // One tap to Understanding from anywhere in the verses; it steps
                // aside once the reader reaches the end card.
                if passage != nil && !endCardVisible {
                    pinnedUnderstandBar
                        .padding(.horizontal, 20)
                        .padding(.bottom, isPlaying ? 0 : 12)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                if isPlaying {
                    SurahAudioPlayerView()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.easeInOut(duration: 0.25), value: endCardVisible)
            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isPlaying)
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView(context: paywallContext)
        }
        .fullScreenCover(item: $selectedVerseForSummary, onDismiss: { pendingConceptId = nil }) { verse in
            VerseSummaryView(
                verse: verse,
                surah: surah,
                initialConceptId: pendingConceptId
            )
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

            TextSizeButton(isPanelOpen: $showTextSizePanel)

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

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(eyebrow.uppercased())
                .emEyebrow(size: 11, tracking: 2)
                .foregroundColor(themeManager.accentColor)
            Text(title)
                .font(EmType.serif(30, .semiBold))
                .foregroundColor(themeManager.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            Text(subline)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }

    // MARK: - Save

    /// Header heart: saves or unsaves this passage as a bookmark. The same
    /// manager call as the passage list's Save swipe, so the two stay in step.
    private func toggleSaved() {
        let arabic = versesInRange.first { $0.number == ref.start }?.arabicText ?? ""
        let result = bookmarkManager.togglePassageBookmark(
            ref: ref,
            surahName: surah.englishName,
            title: passageStore.title(for: ref),
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

    // MARK: - Mark as read

    /// The one explicit way to finish a passage: the same done/todo toggle the
    /// journey days use. Tapping it again takes the passage back to unread.
    private var markReadButton: some View {
        EmJourneyToggleButton(
            isDone: isPassageRead,
            doneLabel: "Marked as read",
            todoLabel: "Mark as read",
            doneTint: themeManager.semanticGreen,
            horizontalPadding: 0,
            onToggle: toggleRead
        )
        .accessibilityLabel(isPassageRead ? "Marked as read. Tap to unmark" : "Mark passage as read")
    }

    // MARK: - Understand

    private var isUnderstandingGated: Bool {
        !premiumManager.canAccessUnderstanding(surahNumber: surah.number)
    }

    private var understandSubline: String {
        if let passage {
            let narrations = passage.narrationCount == 1 ? "1 narration" : "\(passage.narrationCount) narrations"
            return "Essay · \(narrations) · \(passage.readingMinutes) min"
        }
        return "Understanding for this passage is coming in an update"
    }

    private var understandCard: some View {
        let hasCommentary = passage != nil

        return Button(action: openUnderstanding) {
            EmCard(cornerRadius: 20, borderColor: themeManager.accentColor) {
                HStack(spacing: 14) {
                    Text("ع")
                        .font(EmType.arabic(22))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Understand this passage")
                            .font(EmType.serif(18, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                        Text(understandSubline)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    if hasCommentary {
                        if isUnderstandingGated {
                            premiumCapsule
                        } else {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(themeManager.accentColor)
                        }
                    }
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(themeManager.accentColor.opacity(0.10))
                )
            }
        }
        .buttonStyle(EmPressStyle())
        .disabled(!hasCommentary)
        .opacity(hasCommentary ? 1 : 0.55)
    }

    /// Compact Understand control pinned above the bottom edge while the verses
    /// scroll: the same action and gating as the end card, on an opaque ground
    /// so the text beneath does not bleed through.
    private var pinnedUnderstandBar: some View {
        Button(action: openUnderstanding) {
            HStack(spacing: 12) {
                Text("ع")
                    .font(EmType.arabic(20))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Understand this passage")
                        .font(EmType.serif(17, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(understandSubline)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                if isUnderstandingGated {
                    premiumCapsule
                } else {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(themeManager.primaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(themeManager.accentColor.opacity(0.12))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(themeManager.accentColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 14, x: 0, y: 6)
        }
        .buttonStyle(EmPressStyle())
        .accessibilityLabel("Understand this passage")
    }

    private var premiumCapsule: some View {
        Text("PREMIUM")
            .emEyebrow(size: 10, tracking: 1.5)
            .foregroundColor(themeManager.accentColor)
            .padding(.horizontal, 9)
            .padding(.vertical, 4)
            .background(Capsule().fill(themeManager.accentColor.opacity(0.14)))
    }

    @ViewBuilder
    private var understandingDestination: some View {
        if let passage {
            UnderstandingView(surahWithTafsir: surahWithTafsir, ref: ref, passage: passage)
        } else {
            EmptyView()
        }
    }

    // MARK: - Actions

    private func openGems(for verse: VerseWithTafsir) {
        if premiumManager.canAccessOverview(surahNumber: surah.number) {
            // Let the chip's press squish play before the cover slides up.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                pendingConceptId = nil
                selectedVerseForSummary = verse
            }
        } else {
            paywallContext = .inSurah(surah, "Gems")
            showingPaywall = true
        }
    }

    private func toggleRead() {
        if isPassageRead {
            progressManager.unmarkPassageRead(ref)
        } else {
            progressManager.markPassageRead(ref)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    private func openUnderstanding() {
        guard passage != nil else { return }
        if isUnderstandingGated {
            paywallContext = .inSurah(surah, "Understanding")
            showingPaywall = true
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showingUnderstanding = true }
        }
    }

    /// Deep links land on a verse; a theme deep link then opens that verse's gem.
    private func handleScrollTarget(_ proxy: ScrollViewProxy) {
        guard let scrollToVerse, !didHandleScrollTarget else { return }
        didHandleScrollTarget = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // The first verse already sits under the title; centring it would
            // only push the eyebrow and title off the top.
            if scrollToVerse != ref.start {
                withAnimation(.easeInOut(duration: 0.8)) {
                    proxy.scrollTo("verse_\(scrollToVerse)", anchor: .center)
                }
            }
            guard let openConceptId,
                  let verse = versesInRange.first(where: { $0.number == scrollToVerse }) else { return }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                pendingConceptId = openConceptId
                selectedVerseForSummary = verse
            }
        }
    }
}

// MARK: - Verse row

/// One verse: numeral, Arabic, translation, and (when selected) the action
/// row with listen, bookmark and gems. The verse loaded in the player gets a
/// faint accent wash.
/// Bottom edge of each built verse row in the passage scroll space, keyed by
/// verse number. Only rows the lazy stack has built report, which is all the
/// top-of-screen search needs.
private struct VerseBottomsKey: PreferenceKey {
    static var defaultValue: [Int: CGFloat] = [:]
    static func reduce(value: inout [Int: CGFloat], nextValue: () -> [Int: CGFloat]) {
        value.merge(nextValue()) { $1 }
    }
}

/// One verse: the numeral row, whose empty right side carries the verse's
/// tools (listen, save, gems) on every verse as quiet glyphs, then the Arabic
/// and the translation. The tools are chrome, so they keep a fixed size while
/// the reading text scales.
private struct PassageVerseRow: View {
    let verse: VerseWithTafsir
    let surah: Surah
    let isPlaying: Bool
    let onGems: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @State private var showingBookmarkFeedback = false

    private var isBookmarked: Bool {
        bookmarkManager.isBookmarked(surahNumber: surah.number, verseNumber: verse.number)
    }

    /// Idle glyphs sit at this strength so the page still reads as a page;
    /// only state (saved, playing) brings a glyph to full strength.
    private let idleOpacity = 0.55

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 0) {
                    EmNumeralCircle(n: verse.number, size: 30)
                    Spacer(minLength: 8)
                    rail
                }

                // Laid out right to left, so leading is the right edge.
                Text(verse.arabicText)
                    .font(EmType.arabic(27 * readingSettings.scale))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(12 * readingSettings.scale)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .environment(\.layoutDirection, .rightToLeft)

                Text(verse.translation)
                    .font(EmType.serif(17 * readingSettings.scale, .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineSpacing(6 * readingSettings.scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isPlaying ? themeManager.accentColor.opacity(0.08) : Color.clear)
            )

            Rectangle()
                .fill(themeManager.dividerColor)
                .frame(height: 1)
                .padding(.horizontal, 12)
        }
    }

    /// Listen, save and gems on the right of the numeral row.
    private var rail: some View {
        HStack(spacing: 2) {
            VerseRecitationButton(surahNumber: surah.number, verseNumber: verse.number, size: 32, quiet: true)

            Button(action: toggleBookmark) {
                Image(systemName: isBookmarked ? "heart.fill" : "heart")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(isBookmarked ? themeManager.accentBright : themeManager.accentColor)
                    .opacity(isBookmarked ? 1 : idleOpacity)
                    .frame(width: 32, height: 32)
                    .contentShape(Rectangle())
                    .scaleEffect(showingBookmarkFeedback ? 1.25 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingBookmarkFeedback)
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Bookmark verse")

            Button(action: onGems) {
                HStack(spacing: 5) {
                    Image(systemName: "sparkles").font(.system(size: 13, weight: .semibold))
                    Text("Gems").font(.system(size: 12.5, weight: .semibold))
                }
                .foregroundColor(themeManager.accentColor)
                .opacity(verse.tafsir != nil ? idleOpacity : 0.28)
                .padding(.horizontal, 6)
                .frame(height: 32)
                .contentShape(Rectangle())
            }
            .buttonStyle(EmPressStyle())
            .disabled(verse.tafsir == nil)
            .accessibilityLabel("Gems for this verse")
        }
    }

    private func toggleBookmark() {
        if isBookmarked {
            if let bookmark = bookmarkManager.getBookmark(surahNumber: surah.number, verseNumber: verse.number) {
                bookmarkManager.removeBookmark(id: bookmark.id)
            }
        } else {
            let success = bookmarkManager.addBookmark(
                surahNumber: surah.number,
                verseNumber: verse.number,
                surahName: surah.englishName,
                verseText: verse.arabicText,
                verseTranslation: verse.translation
            )

            if success {
                showingBookmarkFeedback = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingBookmarkFeedback = false
                }
            }
        }
    }
}

// MARK: - Next passage

/// Plain card linking to the passage after this one. Shared with the
/// Understanding screen, which ends on the same card.
struct NextPassageCard: View {
    let surahWithTafsir: SurahWithTafsir
    let next: PassageRef

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var passageStore = PassageStore.shared

    private var nextTitle: String {
        passageStore.title(for: next)
    }

    var body: some View {
        PressableNavLink {
            PassageView(surahWithTafsir: surahWithTafsir, ref: next)
        } label: {
            EmCard(cornerRadius: 20) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Next passage")
                            .font(EmType.serif(18, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                        Text("\(nextTitle) · \(next.rangeLabel)")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
                .padding(18)
            }
        }
    }
}
