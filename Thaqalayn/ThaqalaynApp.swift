//
//  ThaqalaynApp.swift
//  Thaqalayn
//
//  Created by Imran Ali on 8/1/25.
//

import SwiftUI
import Supabase
import UserNotifications
import WidgetKit

@main
struct ThaqalaynApp: App {
    @StateObject private var supabaseService = SupabaseService.shared
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared

        // Apply native chrome (UITabBar / UINavigationBar) for current theme
        ChromeAppearance.apply(for: ThemeManager.shared.selectedTheme)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Cold-launch entitlement check: a paying user who
                    // reinstalled (or never signed in) must not read as free
                    // until they discover Restore.
                    await PurchaseManager.shared.verifyEntitlementsAtLaunch()
                }
                .task {
                    // Rebuild widget timelines once per launch so an app
                    // update never leaves a widget serving yesterday's code
                    // or data until the midnight reload.
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        // Handle Supabase authentication callback
        if url.scheme == "thaqalayn" && url.host == "auth" {
            Task {
                await handleAuthCallback(url)
            }
        }
        // Handle verse deep link from notifications
        else if url.scheme == "thaqalayn" && url.host == "verse" {
            handleVerseDeepLink(url)
        }
        // Handle journey deep link from journey-start notifications
        else if url.scheme == "thaqalayn" && url.host == "journey" {
            handleJourneyDeepLink(url)
        }
        // Handle surah experience deep link (widget doorway beats)
        else if url.scheme == "thaqalayn" && url.host == "experience" {
            handleIdDeepLink(url, notification: .navigateToSurahExperience)
        }
        // Handle deep dive deep link (widget doorway beats)
        else if url.scheme == "thaqalayn" && url.host == "deepdive" {
            handleIdDeepLink(url, notification: .navigateToDeepDive)
        }
    }

    /// Shared "?id=" parser for experience/deep-dive links.
    private func handleIdDeepLink(_ url: URL, notification: Notification.Name) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        var linkedId: String?
        for item in queryItems where item.name == "id" {
            linkedId = item.value
        }

        guard let id = linkedId else { return }

        NotificationCenter.default.post(name: notification, object: nil, userInfo: ["id": id])
    }

    private func handleJourneyDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        var journeyId: String?
        for item in queryItems where item.name == "id" {
            journeyId = item.value
        }

        guard let id = journeyId else { return }

        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToJourney"),
            object: nil,
            userInfo: ["journey": id]
        )
    }

    private func handleVerseDeepLink(_ url: URL) {
        // Parse query parameters
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            return
        }

        // Extract surah and verse numbers
        var surahNumber: Int?
        var verseNumber: Int?

        for item in queryItems {
            if item.name == "surah", let value = item.value, let number = Int(value) {
                surahNumber = number
            } else if item.name == "verse", let value = item.value, let number = Int(value) {
                verseNumber = number
            }
        }

        guard let surah = surahNumber, let verse = verseNumber else {
            return
        }

        // Post notification to trigger navigation
        NotificationCenter.default.post(
            name: NSNotification.Name("NavigateToVerse"),
            object: nil,
            userInfo: ["surah": surah, "verse": verse]
        )
    }
    
    private func handleAuthCallback(_ url: URL) async {
        do {
            // Extract the URL components for Supabase auth
            let session = try await supabaseService.getClient().auth.session(from: url)

            // The session should now be updated automatically
            print("✅ Successfully handled auth callback - User: \(session.user.id)")

        } catch {
            print("❌ Failed to handle auth callback: \(error)")
        }
    }
}

// MARK: - Notification Delegate

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    private override init() {
        super.init()
    }

    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let received = notification
        Task { @MainActor in
            NotificationInboxStore.record(received)
        }
        // Banner + keep in Notification Center list, sound, badge — even in foreground
        completionHandler([.banner, .list, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let received = response.notification
        Task { @MainActor in
            NotificationInboxStore.record(received)
        }

        let userInfo = response.notification.request.content.userInfo

        // Journey-start notification → open the journey's tab
        if let type = userInfo["type"] as? String, type == "journey_start",
           let journeyId = userInfo["journey"] as? String {
            if let url = URL(string: "thaqalayn://journey?id=\(journeyId)") {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
            completionHandler()
            return
        }

        // Extract verse information
        if let surah = userInfo["surah"] as? Int,
           let verse = userInfo["verse"] as? Int {
            // Create deep link URL
            if let url = URL(string: "thaqalayn://verse?surah=\(surah)&verse=\(verse)") {
                // Post notification to app to handle navigation
                DispatchQueue.main.async {
                    UIApplication.shared.open(url)
                }
            }
        }

        completionHandler()
    }
}
