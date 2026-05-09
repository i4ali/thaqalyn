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

    private init() {}
}
