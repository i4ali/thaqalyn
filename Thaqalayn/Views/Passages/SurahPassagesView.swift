//
//  SurahPassagesView.swift
//  Thaqalayn
//
//  A surah as the list of its passages (one per ruku). SurahDetailView wraps
//  this screen for every navigation into a surah. Tapping a row pushes
//  PassageView; swiping a row from the leading edge marks the passage read or
//  unread and, with a second button, saves or unsaves it as a bookmark; a
//  target verse (deep link or go-to-verse) pushes the passage that holds it
//  and scrolls to the verse.
//

import SwiftUI

struct SurahPassagesView: View {
    let surahWithTafsir: SurahWithTafsir
    let targetVerse: Int?
    let targetConceptId: String?

    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var audioManager = AudioManager.shared
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var passageStore = PassageStore.shared
    @ObservedObject private var bookmarkManager = BookmarkManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showingGoToVerse = false
    /// A verse to land on, with an optional gem to open once there. Setting it
    /// activates the hidden NavigationLink below. Go-to-verse and the deep-link
    /// onAppear both go through it.
    @State private var pendingTarget: PassageTarget?
    /// The deep link pushes once. onAppear fires again when the user pops back
    /// from the passage, and must not push it a second time.
    @State private var didOpenTargetVerse = false

    private struct PassageTarget {
        let verse: Int
        let conceptId: String?
    }

    init(surahWithTafsir: SurahWithTafsir, targetVerse: Int? = nil, targetConceptId: String? = nil) {
        self.surahWithTafsir = surahWithTafsir
        self.targetVerse = targetVerse
        self.targetConceptId = targetConceptId
    }

    // MARK: - Derived

    private var surah: Surah { surahWithTafsir.surah }

    private var passages: [PassageRef] {
        dataManager.passageIndex?.passages(forSurah: surah.number) ?? []
    }

    /// The passage holding the most recently read verse, when it is in this surah.
    private var lastReadRef: PassageRef? {
        guard let info = progressManager.lastReadInfo, info.surahNumber == surah.number else { return nil }
        return dataManager.passageIndex?.passage(surah: surah.number, containing: info.verseNumber)
    }

    private func passageTitle(_ ref: PassageRef) -> String {
        passageStore.title(for: ref)
    }

    private var pendingTargetIsActive: Binding<Bool> {
        Binding(
            get: { pendingTarget != nil },
            set: { if !$0 { pendingTarget = nil } }
        )
    }

    // MARK: - Body

    var body: some View {
        // Computed once per render; every row and the header count read from it.
        let readVerseKeys = progressManager.readVerseKeys
        let readCount = PassageProgress.readCount(passages, readVerseKeys: readVerseKeys)
        let readingRef = lastReadRef
        let savedIndices = bookmarkManager.bookmarkedPassageIndices(surah: surah.number)

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
                header(readCount: readCount)

                // A List rather than a ScrollView so rows get native swipe
                // actions; drawn transparent so it sits on the same ground.
                List {
                    ForEach(passages) { ref in
                        let isRead = PassageProgress.isRead(ref, readVerseKeys: readVerseKeys)
                        let isSaved = savedIndices.contains(ref.index)

                        VStack(spacing: 0) {
                            if ref.index > 1 {
                                Rectangle()
                                    .fill(themeManager.dividerColor)
                                    .frame(height: 1)
                                    .padding(.leading, 54)
                            }

                            PressableNavLink {
                                PassageView(surahWithTafsir: surahWithTafsir, ref: ref)
                            } label: {
                                PassageRow(
                                    ref: ref,
                                    title: passageTitle(ref),
                                    hasCommentary: passageStore.hasCommentary(surah: surah.number, index: ref.index),
                                    isRead: isRead,
                                    isSaved: isSaved,
                                    isReading: ref == readingRef
                                )
                            }
                        }
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                        .swipeActions(edge: .leading, allowsFullSwipe: true) {
                            // First button is the full-swipe action, so Read stays first.
                            Button {
                                toggleRead(ref, isRead: isRead)
                            } label: {
                                Label(isRead ? "Unread" : "Read", systemImage: isRead ? "arrow.uturn.backward" : "checkmark")
                            }
                            .tint(isRead ? themeManager.tertiaryText : themeManager.accentColor)

                            Button {
                                toggleSaved(ref)
                            } label: {
                                Label(isSaved ? "Unsave" : "Save", systemImage: isSaved ? "heart.slash" : "heart")
                            }
                            .tint(isSaved ? themeManager.secondaryText : themeManager.accentColorDeep)
                        }
                    }

                    Color.clear
                        .frame(height: 40)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets())
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .padding(.top, 8)
            }
        }
        .background(
            // Driven by pendingTarget: go-to-verse and deep links land on the
            // passage that holds the verse, scrolled to it.
            NavigationLink(destination: targetDestination, isActive: pendingTargetIsActive) { EmptyView() }
                .hidden()
                .accessibilityHidden(true)
        )
        .navigationBarHidden(true)
        .hideTabBar()
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(glowOpacity: 0.22, starCount: 10)
        .overlay(alignment: .bottom) {
            if audioManager.currentPlayback != nil {
                SurahAudioPlayerView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: audioManager.currentPlayback != nil)
            }
        }
        .sheet(isPresented: $showingGoToVerse) {
            GoToVerseSheet(
                versesCount: surah.versesCount,
                onGoToVerse: { verseNumber in
                    showingGoToVerse = false
                    // Let the sheet finish dismissing before the push starts.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        pendingTarget = PassageTarget(verse: verseNumber, conceptId: nil)
                    }
                }
            )
        }
        // Deep link (Continue Reading, bookmarks, search, notifications,
        // widgets): push the passage holding the target verse automatically,
        // once this screen's own push has landed. Pushing from onAppear, while
        // the list is still sliding in, made NavigationView cancel the nested
        // link a beat later, so the passage popped straight back to the list.
        .onDidAppear { openTargetVerseIfNeeded() }
        .onAppear {
            // Fallback should the appearance callback never arrive (previews,
            // hosts that do not forward appearance to child controllers).
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { openTargetVerseIfNeeded() }
        }
    }

    /// Pushes the passage holding `targetVerse`, once per screen instance. The
    /// second caller (transition callback or its timer fallback) is a no-op.
    private func openTargetVerseIfNeeded() {
        guard let targetVerse, !didOpenTargetVerse else { return }
        didOpenTargetVerse = true
        pendingTarget = PassageTarget(verse: targetVerse, conceptId: targetConceptId)
    }

    /// Leading swipe on a row: the same mark and unmark the passage screen's
    /// button performs, so the checkmark and the header count follow at once.
    private func toggleRead(_ ref: PassageRef, isRead: Bool) {
        if isRead {
            progressManager.unmarkPassageRead(ref)
        } else {
            progressManager.markPassageRead(ref)
            UINotificationFeedbackGenerator().notificationOccurred(.success)
        }
    }

    /// Leading swipe, second button: save or unsave the passage as a bookmark.
    /// The same manager call as the passage screen's header heart, so the row
    /// heart and the header heart always agree.
    private func toggleSaved(_ ref: PassageRef) {
        let arabic = surahWithTafsir.verses.first { $0.number == ref.start }?.arabicText ?? ""
        let result = bookmarkManager.togglePassageBookmark(
            ref: ref,
            surahName: surah.englishName,
            title: passageTitle(ref),
            firstVerseArabic: arabic
        )
        switch result {
        case .saved: UINotificationFeedbackGenerator().notificationOccurred(.success)
        case .refused: UINotificationFeedbackGenerator().notificationOccurred(.error)
        case .removed: break
        }
    }

    @ViewBuilder
    private var targetDestination: some View {
        if let target = pendingTarget,
           let ref = dataManager.passageIndex?.passage(surah: surah.number, containing: target.verse) {
            PassageView(
                surahWithTafsir: surahWithTafsir,
                ref: ref,
                scrollToVerse: target.verse,
                openConceptId: target.conceptId
            )
        } else {
            EmptyView()
        }
    }

    // MARK: - Header

    private func header(readCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 16) {
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

                headerChip(system: "magnifyingglass") {
                    // Let the press squish play before the sheet slides up.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showingGoToVerse = true }
                }
                headerChip(system: "play.fill") {
                    Task { await audioManager.playVerseSequence(surahWithTafsir.verses, in: surah, startingFrom: 0) }
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(surah.englishName)
                    .font(EmType.serif(30, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(subline(readCount: readCount))
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 12)
    }

    private func subline(readCount: Int) -> String {
        let count = passages.count
        let passagesLabel = count == 1 ? "1 passage" : "\(count) passages"
        return "\(surah.englishNameTranslation) · \(surah.revelationType) · \(passagesLabel) · \(readCount) read"
    }

    private func headerChip(system: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: system)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 40, height: 40)
                .background(Circle().fill(themeManager.glassSurface))
                .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
        }
        .buttonStyle(EmPressStyle())
    }
}

// MARK: - Row

/// One passage in the list: glyph, title, verse range, and on the trailing
/// edge a heart when the passage is bookmarked and the read state (checkmark
/// when read, "reading" when it holds the last read verse, nothing otherwise).
private struct PassageRow: View {
    let ref: PassageRef
    let title: String
    let hasCommentary: Bool
    let isRead: Bool
    let isSaved: Bool
    let isReading: Bool
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Text("ع")
                .font(EmType.arabic(20))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(EmType.serif(17, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 0) {
                    Text(ref.rangeLabel)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                    if !hasCommentary {
                        Text(" · coming soon")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                }
            }

            Spacer(minLength: 8)

            HStack(spacing: 10) {
                if isSaved {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.accentBright)
                        .accessibilityLabel("Saved")
                }
                if isRead {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                } else if isReading {
                    Text("reading")
                        .font(.system(size: 12.5, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isReading ? themeManager.accentColor.opacity(0.08) : Color.clear)
        )
        .contentShape(Rectangle())
    }
}
