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
    /// Set by a passage link: open that passage's hub rather than the reader
    /// at `verseNumber`.
    let passageIndex: Int?

    init(surahNumber: Int, verseNumber: Int, passageIndex: Int? = nil) {
        self.surahNumber = surahNumber
        self.verseNumber = verseNumber
        self.passageIndex = passageIndex
    }
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

    /// Surah-experience id (e.g. "surah-yusuf") to auto-open once the Journey
    /// hub becomes the active tab. Set by a What's New card tap; consumed (and
    /// cleared) by JourneyHubView.
    @Published var pendingSurahExperienceId: String? = nil

    /// The surah-experience id the Journey hub's Inside-the-Surah reveal list should
    /// currently be showing (scrolled to + highlighted). Set by the Quran-list Journey
    /// tab; retargeted live if another surah's Journey tab is tapped while the list is
    /// still open; cleared when that list is dismissed. Distinct from the auto-open path.
    @Published var revealSurahExperienceId: String? = nil

    private init() {}
}
