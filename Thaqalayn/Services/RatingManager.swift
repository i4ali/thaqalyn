//
//  RatingManager.swift
//  Thaqalayn
//
//  Manages app rating prompts using Apple's SKStoreReviewController
//

import Foundation
import StoreKit

@MainActor
class RatingManager: ObservableObject {
    static let shared = RatingManager()

    // MARK: - UserDefaults Keys
    private let launchCountKey = "thaqalayn_launch_count"
    private let lastPromptDateKey = "thaqalayn_last_rating_prompt_date"
    private let firstLaunchDateKey = "thaqalayn_first_launch_date"

    // MARK: - Configuration
    private let minimumLaunchesBeforePrompt = 5
    private let minimumDaysSinceFirstLaunch = 3
    private let minimumDaysBetweenPrompts = 60

    // MARK: - Published State
    @Published private(set) var launchCount: Int = 0

    private init() {
        loadState()
    }

    // MARK: - Public Methods

    /// Call this when the app launches to track usage and potentially show rating prompt
    func recordAppLaunch() {
        // Record first launch date if not set
        if UserDefaults.standard.object(forKey: firstLaunchDateKey) == nil {
            UserDefaults.standard.set(Date(), forKey: firstLaunchDateKey)
        }

        // Increment launch count
        launchCount += 1
        UserDefaults.standard.set(launchCount, forKey: launchCountKey)

        // Check if we should show rating prompt
        if shouldPromptForRating() {
            requestReview()
        }
    }

    /// Manually request a review (e.g., from settings or after a positive action)
    func requestReviewIfAppropriate() {
        if shouldPromptForRating() {
            requestReview()
        }
    }

    // MARK: - Private Methods

    private func loadState() {
        launchCount = UserDefaults.standard.integer(forKey: launchCountKey)
    }

    private func shouldPromptForRating() -> Bool {
        // Check minimum launch count
        guard launchCount >= minimumLaunchesBeforePrompt else {
            return false
        }

        // Check minimum days since first launch
        if let firstLaunchDate = UserDefaults.standard.object(forKey: firstLaunchDateKey) as? Date {
            let daysSinceFirstLaunch = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day ?? 0
            guard daysSinceFirstLaunch >= minimumDaysSinceFirstLaunch else {
                return false
            }
        }

        // Check minimum days since last prompt
        if let lastPromptDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date {
            let daysSinceLastPrompt = Calendar.current.dateComponents([.day], from: lastPromptDate, to: Date()).day ?? 0
            guard daysSinceLastPrompt >= minimumDaysBetweenPrompts else {
                return false
            }
        }

        return true
    }

    private func requestReview() {
        // Record that we prompted
        UserDefaults.standard.set(Date(), forKey: lastPromptDateKey)

        // Request review using the modern API
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}
