//
//  HomeView.swift
//  Thaqalayn
//
//  Quran tab view — surah list. Consumes pending verse deep-links from
//  DeepLinkRouter (set by MainTabView) when this tab becomes active.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var deepLinkRouter = DeepLinkRouter.shared
    @State private var searchText = ""
    @State private var showingAuthentication = false
    @State private var selectedSurahForDeepLink: SurahWithTafsir?
    @State private var targetVerseNumber: Int?
    /// A search result being read (legacy layout); pushes the passage reader directly.
    @State private var searchTarget: SearchPassageTarget?
    @FocusState private var searchFocused: Bool
    /// Set by a passage deep link: the surah opens on that passage's hub.
    @State private var targetPassageIndex: Int?

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                EmeraldHomeView(
                    searchText: $searchText,
                    selectedSurahForDeepLink: $selectedSurahForDeepLink,
                    targetVerseNumber: $targetVerseNumber,
                    targetPassageIndex: $targetPassageIndex
                )
            } else {
                legacyBody
            }
        }
        .overlay(alignment: .bottom) {
            if let syncStatus = bookmarkManager.syncStatus {
                SyncStatusToast(message: syncStatus)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: bookmarkManager.syncStatus)
            }
        }
        .fullScreenCover(isPresented: $showingAuthentication) {
            AuthenticationView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAuthentication)) { _ in
            showingAuthentication = true
        }
        .onAppear {
            consumePendingDeepLink()
            consumeSearchFocus()
        }
        .onChange(of: deepLinkRouter.pendingDeepLink) { _, _ in
            consumePendingDeepLink()
        }
        .onChange(of: deepLinkRouter.pendingSearchFocus) { _, _ in consumeSearchFocus() }
    }

    /// Focus mode: while the field is focused or holds a query, the title steps
    /// aside and results fill the screen.
    private var isSearching: Bool {
        searchFocused || !searchText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var legacyBody: some View {
        VStack(spacing: 0) {
            // Modern header with glassmorphism
            VStack(spacing: 16) {
                if !isSearching {
                    // Top navigation row (universal for all themes)
                    HStack(spacing: 12) {
                        // Bookmark Badge (theme-adaptive)
                        BookmarkBadge()

                        Spacer()
                    }

                    HStack {
                        Text(QuranTabStrings.holyQuran)
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.primaryText)

                        Spacer()
                    }
                    .transition(.opacity)
                }

                QuranSearchBar(text: $searchText, isFocused: $searchFocused, isSearching: isSearching)
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)

            // Surah list / search results
            ScrollView {
                // One Set over all progress records per render, shared by every surah row.
                let readVerseKeys = progressManager.readVerseKeys
                if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                    LazyVStack(spacing: 12) {
                        ForEach(dataManager.availableSurahs) { surahWithTafsir in
                            SurahListRow(surahWithTafsir: surahWithTafsir, readVerseKeys: readVerseKeys)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    SearchResultsView(
                        query: searchText,
                        readVerseKeys: readVerseKeys,
                        onOpen: { searchTarget = $0 }
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 120)
                }
            }
            .scrollDismissesKeyboard(.immediately)

            // Hidden NavigationLink for search results
            if let target = searchTarget, let destination = SearchPassageDestination(target: target) {
                NavigationLink(
                    destination: destination,
                    isActive: Binding(
                        get: { searchTarget != nil },
                        set: { if !$0 { searchTarget = nil } }
                    )
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }

            // Hidden NavigationLink for deep linking
            if let surahForDeepLink = selectedSurahForDeepLink {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: surahForDeepLink, targetVerse: targetVerseNumber, targetPassageIndex: targetPassageIndex),
                    isActive: Binding(
                        get: { selectedSurahForDeepLink != nil },
                        set: { if !$0 {
                            selectedSurahForDeepLink = nil
                            targetVerseNumber = nil
                            targetPassageIndex = nil
                        } }
                    )
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }

        }
        .animation(.easeInOut(duration: 0.25), value: isSearching)
    }

    /// The What's New search card asks for the field to be focused on arrival.
    /// The emerald layout handles its own field; this covers the legacy one.
    private func consumeSearchFocus() {
        guard !themeManager.isMidnightEmerald, deepLinkRouter.pendingSearchFocus else { return }
        deepLinkRouter.pendingSearchFocus = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { searchFocused = true }
    }

    private func consumePendingDeepLink() {
        guard let link = deepLinkRouter.pendingDeepLink else { return }
        guard let surahData = dataManager.availableSurahs.first(where: { $0.surah.number == link.surahNumber }) else {
            print("⚠️ HomeView: deep-link surah \(link.surahNumber) not in availableSurahs")
            deepLinkRouter.pendingDeepLink = nil
            return
        }

        // Dismiss any open sheets first
        showingAuthentication = false

        // Brief delay so any in-flight tab transition / sheet dismissal settles before pushing.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            targetVerseNumber = link.verseNumber
            targetPassageIndex = link.passageIndex
            selectedSurahForDeepLink = surahData
            deepLinkRouter.pendingDeepLink = nil
        }
    }
}

#Preview {
    HomeView()
}
