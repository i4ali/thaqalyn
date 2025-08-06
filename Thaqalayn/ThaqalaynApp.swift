//
//  ThaqalaynApp.swift
//  Thaqalayn
//
//  Created by Imran Ali on 8/1/25.
//

import SwiftUI
import Supabase

@main
struct ThaqalaynApp: App {
    @StateObject private var supabaseService = SupabaseService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        print("🔗 Received deep link: \(url)")
        print("🔗 Scheme: \(url.scheme ?? "none"), Host: \(url.host ?? "none")")
        print("🔗 Full URL: \(url.absoluteString)")
        
        // Handle Supabase authentication callback
        if url.scheme == "thaqalayn" && url.host == "auth" {
            print("✅ Processing Supabase auth callback")
            Task {
                await handleAuthCallback(url)
            }
        } else {
            print("❌ URL doesn't match expected pattern: thaqalayn://auth/...")
        }
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
