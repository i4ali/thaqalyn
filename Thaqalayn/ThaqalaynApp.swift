//
//  ThaqalaynApp.swift
//  Thaqalayn
//
//  Created by Imran Ali on 8/1/25.
//

import SwiftUI
import Supabase
import UserNotifications

@main
struct ThaqalaynApp: App {
    @StateObject private var supabaseService = SupabaseService.shared
    @StateObject private var notificationManager = NotificationManager.shared

    init() {
        // Set up notification delegate
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
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
        // Show banner, sound, and badge even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

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
