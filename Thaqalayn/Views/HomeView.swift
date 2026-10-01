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
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var deepLinkRouter = DeepLinkRouter.shared
    @State private var searchText = ""
    @State private var showingAuthentication = false
    @State private var selectedSurahForDeepLink: SurahWithTafsir?
    @State private var targetVerseNumber: Int?
    /// Set by a passage deep link: the surah opens on that passage's hub.
    @State private var targetPassageIndex: Int?

    var body: some View {
        EmeraldHomeView(
            searchText: $searchText,
            selectedSurahForDeepLink: $selectedSurahForDeepLink,
            targetVerseNumber: $targetVerseNumber,
            targetPassageIndex: $targetPassageIndex
        )
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
        }
        .onChange(of: deepLinkRouter.pendingDeepLink) { _, _ in
            consumePendingDeepLink()
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
            targetPassageIndex = link.passageIndex
            selectedSurahForDeepLink = surahData
            deepLinkRouter.pendingDeepLink = nil
        }
    }
}

#Preview {
    HomeView()
}
