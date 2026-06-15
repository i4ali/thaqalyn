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
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @State private var searchText = ""
    @State private var showingAuthentication = false
    @State private var selectedSurahForDeepLink: SurahWithTafsir?
    @State private var targetVerseNumber: Int?
    @State private var targetConceptId: String?

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                EmeraldHomeView(
                    searchText: $searchText,
                    selectedSurahForDeepLink: $selectedSurahForDeepLink,
                    targetVerseNumber: $targetVerseNumber
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
        .onAppear { consumePendingDeepLink() }
        .onChange(of: deepLinkRouter.pendingDeepLink) { _, _ in
            consumePendingDeepLink()
        }
    }

    private var legacyBody: some View {
        VStack(spacing: 0) {
            // Modern header with glassmorphism
            VStack(spacing: 16) {
                // Top navigation row (universal for all themes)
                HStack(spacing: 12) {
                    // Bookmark Badge (theme-adaptive)
                    BookmarkBadge()

                    Spacer()
                }

                HStack {
                    Text(QuranTabStrings.holyQuran(languageManager.selectedLanguage))
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.primaryText)

                    Spacer()
                }
                .environment(\.layoutDirection, languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)

                // Search bar with glassmorphism
                HStack {
                    Text("\u{1F50D}")
                        .font(.system(size: 20))

                    TextField(QuranTabStrings.searchPlaceholder(languageManager.selectedLanguage), text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(themeManager.primaryText)
                }
                .environment(\.layoutDirection, languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeManager.strokeColor, lineWidth: 1))
                        .shadow(
                            color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                            radius: 12, x: 0, y: 4
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)

            // Surah list / search results
            ScrollView {
                if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
                    LazyVStack(spacing: 12) {
                        ForEach(dataManager.availableSurahs.filter { surah in
                            surah.surah.englishName.localizedCaseInsensitiveContains(searchText) ||
                            surah.surah.englishNameTranslation.localizedCaseInsensitiveContains(searchText) ||
                            surah.surah.arabicName.contains(searchText) ||
                            searchText.isEmpty
                        }) { surahWithTafsir in
                            NavigationLink(destination: SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil)) {
                                ModernSurahCard(surah: surahWithTafsir.surah)
                            }
                            .buttonStyle(EmPressStyle())
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                } else {
                    SearchResultsView(
                        query: searchText,
                        onOpenSurah: { swt in
                            targetConceptId = nil
                            targetVerseNumber = nil
                            selectedSurahForDeepLink = swt
                        },
                        onOpenVerse: { s, v in
                            targetConceptId = nil
                            targetVerseNumber = v
                            selectedSurahForDeepLink = dataManager.getSurah(number: s)
                        },
                        onOpenTheme: { s, v, cid in
                            targetConceptId = cid
                            targetVerseNumber = v
                            selectedSurahForDeepLink = dataManager.getSurah(number: s)
                        }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }

            // Hidden NavigationLink for deep linking
            if let surahForDeepLink = selectedSurahForDeepLink {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: surahForDeepLink, targetVerse: targetVerseNumber, targetConceptId: targetConceptId),
                    isActive: Binding(
                        get: { selectedSurahForDeepLink != nil },
                        set: { if !$0 {
                            selectedSurahForDeepLink = nil
                            targetVerseNumber = nil
                            targetConceptId = nil
                        } }
                    )
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }

        }
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
            selectedSurahForDeepLink = surahData
            deepLinkRouter.pendingDeepLink = nil
        }
    }
}

#Preview {
    HomeView()
}
