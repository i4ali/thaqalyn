//
//  EmeraldHomeView.swift
//  Thaqalayn
//
//  The Quran (Home/Read) tab layout, shown by HomeView in both themes.
//

import SwiftUI

struct EmeraldHomeView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var progressManager = ProgressManager.shared
    @ObservedObject private var deepLinkRouter = DeepLinkRouter.shared

    @Binding var searchText: String
    @Binding var selectedSurahForDeepLink: SurahWithTafsir?
    @Binding var targetVerseNumber: Int?
    /// Set by a passage deep link: the surah opens on that passage's hub.
    @Binding var targetPassageIndex: Int?

    @State private var showNotifications = false
    @State private var animateProgress = false
    /// A search result being read; pushes the passage reader directly so one
    /// Back returns to the results.
    @State private var searchTarget: SearchPassageTarget?
    @FocusState private var searchFocused: Bool
    /// True once the search bar has stuck to the top of the scroll view; its
    /// backing band only shows then, so it never tints the unpinned bar.
    @State private var searchBarPinned = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Fill of the heart and bell circle buttons: a white disc on the light
    /// ground, the original dark well in Midnight Emerald.
    private static let circleButtonFill = Color(light: Color.white.opacity(0.75),
                                                dark: Color(hex: "050E0B").opacity(0.28))

    /// Focus mode: while the field is focused or holds a query, the heading and
    /// Continue Reading card step aside and results fill the screen.
    private var isSearching: Bool {
        searchFocused || !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }


    private var filteredSurahs: [SurahWithTafsir] {
        dataManager.availableSurahs.filter { s in
            searchText.isEmpty ||
            s.surah.englishName.localizedCaseInsensitiveContains(searchText) ||
            s.surah.englishNameTranslation.localizedCaseInsensitiveContains(searchText) ||
            s.surah.arabicName.contains(searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            greetingRow
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 10)

            ScrollViewReader { proxy in
                ScrollView {
                    // The search bar is a pinned section header: it keeps one
                    // identity (so focus survives the layout change), rides up with
                    // the heading, then sticks to the top while the list scrolls.
                    LazyVStack(alignment: .leading, spacing: 18, pinnedViews: [.sectionHeaders]) {
                        Color.clear.frame(height: 0).id(Self.topAnchor)

                        if !isSearching {
                            EmHeading(eyebrow: QuranTabStrings.nobleQuranEyebrow, title: QuranTabStrings.readAndReflect)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .transition(.opacity)

                            if let info = progressManager.lastReadInfo,
                               let s = dataManager.availableSurahs.first(where: { $0.surah.number == info.surahNumber }) {
                                continueReadingCard(info: info, surah: s)
                                    .padding(.horizontal, 20)
                                    .transition(.opacity)
                            }
                        }

                        Section {
                            // One Set over all progress records per render, shared by every surah row.
                            let readVerseKeys = progressManager.readVerseKeys
                            Group {
                                if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                                    EmDivider(label: QuranTabStrings.surahsCount(dataManager.availableSurahs.count))
                                    surahList(readVerseKeys: readVerseKeys)
                                } else {
                                    SearchResultsView(
                                        query: searchText,
                                        readVerseKeys: readVerseKeys,
                                        onOpen: { searchTarget = $0 }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        } header: {
                            QuranSearchBar(text: $searchText, isFocused: $searchFocused, isSearching: isSearching)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(pinnedHeaderBackground.opacity(searchBarPinned ? 1 : 0))
                                .background(GeometryReader { geo in
                                    Color.clear.preference(key: SearchBarOffsetKey.self,
                                                           value: geo.frame(in: .named(Self.scrollSpace)).minY)
                                })
                        }
                    }
                    .padding(.top, 12)
                    .padding(.bottom, 120)
                }
                .coordinateSpace(name: Self.scrollSpace)
                .onPreferenceChange(SearchBarOffsetKey.self) { y in
                    let pinned = y <= 0.5
                    if pinned != searchBarPinned { searchBarPinned = pinned }
                }
                .scrollDismissesKeyboard(.immediately)
                .onChange(of: isSearching) { _, searching in
                    if searching { proxy.scrollTo(Self.topAnchor, anchor: .top) }
                }
                .onChange(of: searchText) { _, _ in
                    proxy.scrollTo(Self.topAnchor, anchor: .top)
                }
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.25), value: isSearching)
        .background(deepLinkLink)
        .background(searchLink)
        .sheet(isPresented: $showNotifications) { NotificationsView() }
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.6)) { animateProgress = true }
            consumeSearchFocus()
        }
        .onChange(of: deepLinkRouter.pendingSearchFocus) { _, _ in consumeSearchFocus() }
    }

    private var greetingRow: some View {
        HStack(alignment: .center, spacing: 10) {
            Spacer()

            PressableNavLink {
                BookmarksView()
            } label: {
                PhosphorIcon(name: "ph-heart-fill", size: 15)
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Self.circleButtonFill))
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }

            Button { showNotifications = true } label: {
                PhosphorIcon(name: "ph-bell", size: 16)
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 36, height: 36)
                    .background(Circle().fill(Self.circleButtonFill))
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
        }
    }

    private func continueReadingCard(info: LastReadInfo, surah s: SurahWithTafsir) -> some View {
        EmCard(glow: true) {
            ZStack(alignment: .topTrailing) {
                Text("\(info.surahNumber)")
                    .font(EmType.serif(120))
                    .foregroundColor(themeManager.accentColor.opacity(0.07))
                    .offset(x: 8, y: -18)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: 10) {
                    Text(QuranTabStrings.continueReading.uppercased())
                        .emEyebrow(size: 11, tracking: 2)
                        .foregroundColor(themeManager.accentColor)
                    Text(s.surah.englishName)
                        .font(EmType.serif(27, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(positionLine(info: info, surah: s))
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)

                    ZStack(alignment: .leading) {
                        Capsule().fill(themeManager.accentChip).frame(height: 4)
                        GeometryReader { geo in
                            Capsule().fill(themeManager.accentGradient)
                                .frame(width: geo.size.width * CGFloat(animateProgress ? info.progress : 0), height: 4)
                        }
                        .frame(height: 4)
                    }
                    .frame(height: 4)

                    Button {
                        targetPassageIndex = nil
                        targetVerseNumber = info.verseNumber
                        selectedSurahForDeepLink = s
                    } label: {
                        HStack(spacing: 7) {
                            Image(systemName: "play.fill").font(.system(size: 12, weight: .semibold))
                            Text(QuranTabStrings.resume).font(.system(size: 14, weight: .bold)).tracking(0.3)
                        }
                        .foregroundColor(themeManager.onAccentText)
                        .padding(.horizontal, 18).padding(.vertical, 10)
                        .background(Capsule().fill(themeManager.accentGradient))
                        .shadow(color: themeManager.accentColor.opacity(0.28), radius: 16, x: 0, y: 6)
                    }
                    .buttonStyle(EmPressStyle())
                    .padding(.top, 2)
                }
                .padding(20)
            }
        }
    }

    /// "<passage title> · 3 of 24 passages read"; the verse line stands in
    /// until the passage index has loaded.
    private func positionLine(info: LastReadInfo, surah s: SurahWithTafsir) -> String {
        if let title = info.passageTitle, info.passagesTotal > 0 {
            return "\(title) · \(QuranTabStrings.passagesRead(info.passagesRead, info.passagesTotal))"
        }
        return "\(QuranTabStrings.verseOf(info.verseNumber, s.surah.versesCount)) · \(QuranTabStrings.percentComplete(Int(info.progress * 100)))"
    }

    private static let topAnchor = "quranTabTop"
    private static let scrollSpace = "quranTabScroll"

    /// The What's New search card asks for the field to be focused on arrival.
    private func consumeSearchFocus() {
        guard deepLinkRouter.pendingSearchFocus else { return }
        deepLinkRouter.pendingSearchFocus = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { searchFocused = true }
    }

    /// Opaque band behind the pinned search bar so list rows don't show through
    /// it once it sticks.
    private var pinnedHeaderBackground: some View {
        themeManager.emeraldBgTop
    }

    private func surahList(readVerseKeys: Set<String>) -> some View {
        LazyVStack(spacing: 12) {
            ForEach(filteredSurahs) { swt in
                SurahListRow(surahWithTafsir: swt, readVerseKeys: readVerseKeys)
            }
        }
    }

    @ViewBuilder private var deepLinkLink: some View {
        if let surah = selectedSurahForDeepLink {
            NavigationLink(
                destination: SurahDetailView(surahWithTafsir: surah, targetVerse: targetVerseNumber, targetPassageIndex: targetPassageIndex),
                isActive: Binding(
                    get: { selectedSurahForDeepLink != nil },
                    set: { if !$0 { selectedSurahForDeepLink = nil; targetVerseNumber = nil; targetPassageIndex = nil } }
                )
            ) { EmptyView() }
            .hidden()
        }
    }

    @ViewBuilder private var searchLink: some View {
        if let target = searchTarget, let destination = SearchPassageDestination(target: target) {
            NavigationLink(
                destination: destination,
                isActive: Binding(
                    get: { searchTarget != nil },
                    set: { if !$0 { searchTarget = nil } }
                )
            ) { EmptyView() }
            .hidden()
        }
    }
}

/// The search bar's top edge in the Quran tab's scroll viewport (0 when pinned).
private struct SearchBarOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = .infinity
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = min(value, nextValue()) }
}
