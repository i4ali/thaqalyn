//
//  DeepLinkRouter.swift
//  Thaqalayn
//
//  Cross-tab routing for deep-links (e.g. tapping a notification card to
//  jump to a specific verse). MainTabView writes the pending deep-link;
//  HomeView consumes it once the Quran tab is active.
//

import Foundation

struct PendingDeepLink: Equatable {
    let surahNumber: Int
    let verseNumber: Int
}

@MainActor
final class DeepLinkRouter: ObservableObject {
    static let shared = DeepLinkRouter()

    @Published var pendingDeepLink: PendingDeepLink? = nil

    /// Journey id ("ramadan" | "hajj" | "muharram") to auto-open once the
    /// Journey hub becomes the active tab. Set by MainTabView on a
    /// `.navigateToJourney` deep-link; consumed (and cleared) by JourneyHubView.
    @Published var pendingJourneyId: String? = nil

    /// Deep-dive id to auto-open once the Journey hub becomes the active tab. Set by a
    /// What's New card tap; consumed (and cleared) by JourneyHubView.
    @Published var pendingDeepDiveId: String? = nil

    /// Sūrah-experience id (e.g. "surah-yusuf") to auto-open once the Journey
    /// hub becomes the active tab. Set by a What's New card tap; consumed (and
    /// cleared) by JourneyHubView.
    @Published var pendingSurahExperienceId: String? = nil

    private init() {}
}
