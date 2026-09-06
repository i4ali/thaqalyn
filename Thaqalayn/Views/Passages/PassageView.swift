//
//  PassageView.swift
//  Thaqalayn
//
//  One passage (a ruku) read in full: its verses in order, then the
//  Understand card for the passage commentary and a link to the next
//  passage. Reaching the end of the verses marks the passage read.
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
    @Environment(\.dismiss) private var dismiss

    /// The verse whose action row (listen, bookmark, gems) is open.
    @State private var selectedVerse: Int?
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

    init(surahWithTafsir: SurahWithTafsir, ref: PassageRef, scrollToVerse: Int? = nil, openConceptId: String? = nil) {
        self.surahWithTafsir = surahWithTafsir
        self.ref = ref
        self.scrollToVerse = scrollToVerse
        self.openConceptId = openConceptId
    }

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
        passage?.title.en ?? "Verses \(ref.rangeLabel)"
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
                                    isSelected: selectedVerse == verse.number,
                                    isPlaying: playingVerse == verse.number,
                                    onTap: { toggleSelection(verse.number) },
                                    onGems: { openGems(for: verse) }
                                )
                                .id("verse_\(verse.number)")
                            }

                            understandCard
                                .padding(.top, 28)
                                .onAppear { endCardVisible = true }
                                .onDisappear { endCardVisible = false }

                            // Reaching this point means the verses were scrolled through.
                            Color.clear
                                .frame(height: 1)
                                .onAppear { progressManager.markPassageRead(ref) }

                            if let next = nextRef {
                                NextPassageCard(surahWithTafsir: surahWithTafsir, next: next)
                                    .padding(.top, 14)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 4)
                        .padding(.bottom, 48)
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

    private func toggleSelection(_ verse: Int) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedVerse = selectedVerse == verse ? nil : verse
        }
    }

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
private struct PassageVerseRow: View {
    let verse: VerseWithTafsir
    let surah: Surah
    let isSelected: Bool
    let isPlaying: Bool
    let onTap: () -> Void
    let onGems: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @State private var showingBookmarkFeedback = false

    private var isBookmarked: Bool {
        bookmarkManager.isBookmarked(surahNumber: surah.number, verseNumber: verse.number)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 14) {
                EmNumeralCircle(n: verse.number, size: 30)

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

                if isSelected {
                    actionRow
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.vertical, 18)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isPlaying ? themeManager.accentColor.opacity(0.08) : Color.clear)
            )
            .contentShape(Rectangle())
            .onTapGesture(perform: onTap)

            Rectangle()
                .fill(themeManager.dividerColor)
                .frame(height: 1)
                .padding(.horizontal, 12)
        }
    }

    private var actionRow: some View {
        HStack(spacing: 10) {
            VerseRecitationButton(surahNumber: surah.number, verseNumber: verse.number, size: 32)

            Button(action: toggleBookmark) {
                Image(systemName: isBookmarked ? "heart.fill" : "heart")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(isBookmarked ? themeManager.onAccentText : themeManager.accentColor)
                    .frame(width: 32, height: 32)
                    .background(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(isBookmarked ? AnyShapeStyle(themeManager.accentGradient) : AnyShapeStyle(themeManager.accentChip))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(isBookmarked ? Color.clear : themeManager.strokeColor, lineWidth: 1)
                    )
                    .scaleEffect(showingBookmarkFeedback ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingBookmarkFeedback)
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel(isBookmarked ? "Remove bookmark" : "Bookmark verse")

            Button(action: onGems) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles").font(.system(size: 13, weight: .semibold))
                    Text("Gems").font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(themeManager.accentColor)
                .padding(.horizontal, 14)
                .frame(height: 32)
                .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(themeManager.accentChip))
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            .opacity(verse.tafsir != nil ? 1 : 0.45)
            .disabled(verse.tafsir == nil)

            Spacer()
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
        passageStore.passage(surah: next.surah, index: next.index)?.title.en ?? "Verses \(next.rangeLabel)"
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
