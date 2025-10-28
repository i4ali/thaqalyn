//
//  SettingsView.swift
//  Thaqalayn
//
//  Centralized settings hub for the app
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingThemeSelection = false
    @State private var showingAuthentication = false
    @State private var showingClearDataAlert = false
    @State private var clearDataMessage = ""
    @State private var showingTimePickerSheet = false
    @State private var showingSyncStatus = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                                .frame(width: 40, height: 40)
                        }
                        
                        Spacer()
                        
                        Text("Settings")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Spacer()
                        
                        // Invisible spacer to balance the close button
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // Settings content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Appearance Section
                            SettingsSection(title: "Appearance") {
                                VStack(spacing: 12) {
                                    // Theme selection
                                    SettingsRow(
                                        icon: "paintbrush.fill",
                                        title: "Theme",
                                        subtitle: themeManager.selectedTheme.displayName,
                                        iconColor: .purple
                                    ) {
                                        showingThemeSelection = true
                                    }
                                    
                                    // Quick dark/light toggle for modern themes
                                    if themeManager.selectedTheme == .modernDark || themeManager.selectedTheme == .modernLight {
                                        SettingsRow(
                                            icon: themeManager.selectedTheme == .modernDark ? "sun.max.fill" : "moon.fill",
                                            title: "Quick Toggle",
                                            subtitle: themeManager.selectedTheme == .modernDark ? "Switch to Light" : "Switch to Dark",
                                            iconColor: .orange
                                        ) {
                                            themeManager.toggleTheme()
                                        }
                                    }
                                }
                            }

                            // Prayer Times Section
                            SettingsSection(title: "Prayer Times") {
                                VStack(spacing: 12) {
                                    NavigationLink(destination: PrayerTimesView()) {
                                        SettingsRowContent(
                                            icon: "moon.stars.fill",
                                            title: "Prayer Times",
                                            subtitle: "Shia prayer times with athan",
                                            iconColor: .indigo
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }

                            // Daily Verse Notifications Section
                            SettingsSection(title: "Daily Verse") {
                                VStack(spacing: 12) {
                                    // Enable/Disable toggle
                                    SettingsToggleRow(
                                        icon: "bell.fill",
                                        title: "Daily Notifications",
                                        subtitle: notificationManager.preferences.enabled ? "Enabled" : "Tap to enable",
                                        iconColor: .blue,
                                        isOn: Binding(
                                            get: { notificationManager.preferences.enabled },
                                            set: { newValue in
                                                if newValue && notificationManager.permissionStatus != .authorized {
                                                    Task {
                                                        let granted = await notificationManager.requestPermission()
                                                        if granted {
                                                            notificationManager.preferences.enabled = true
                                                        }
                                                    }
                                                } else {
                                                    notificationManager.preferences.enabled = newValue
                                                }
                                            }
                                        )
                                    )

                                    // Show additional settings only if enabled
                                    if notificationManager.preferences.enabled {
                                        // Time picker
                                        SettingsRow(
                                            icon: "clock.fill",
                                            title: "Notification Time",
                                            subtitle: formatTime(notificationManager.preferences.time),
                                            iconColor: .orange
                                        ) {
                                            showingTimePickerSheet = true
                                        }

                                        // Language preference
                                        SettingsRow(
                                            icon: "globe",
                                            title: "Language",
                                            subtitle: notificationManager.preferences.language.displayName,
                                            iconColor: .green
                                        ) {
                                            toggleNotificationLanguage()
                                        }

                                        // Include tafsir toggle
                                        SettingsToggleRow(
                                            icon: "book.fill",
                                            title: "Include Commentary",
                                            subtitle: notificationManager.preferences.includeTafsir ? "Brief tafsir shown" : "Verse only",
                                            iconColor: .purple,
                                            isOn: Binding(
                                                get: { notificationManager.preferences.includeTafsir },
                                                set: { notificationManager.preferences.includeTafsir = $0 }
                                            )
                                        )

                                        // Today's verse preview
                                        if let verse = notificationManager.selectTodayVerse(),
                                           let monthData = notificationManager.currentMonthData() {
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Image(systemName: "star.fill")
                                                        .font(.system(size: 12))
                                                        .foregroundColor(.yellow)
                                                    Text("Today's Verse (\(monthData.name))")
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(themeManager.primaryText)
                                                }
                                                .padding(.horizontal, 16)
                                                .padding(.top, 12)

                                                Text("Surah \(verse.surah), Verse \(verse.verse)")
                                                    .font(.system(size: 13, weight: .medium))
                                                    .foregroundColor(themeManager.secondaryText)
                                                    .padding(.horizontal, 16)

                                                Text(verse.theme)
                                                    .font(.system(size: 12))
                                                    .foregroundColor(themeManager.tertiaryText)
                                                    .padding(.horizontal, 16)
                                                    .padding(.bottom, 12)
                                            }
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(themeManager.primaryBackground.opacity(0.5))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(themeManager.strokeColor.opacity(0.5), lineWidth: 1)
                                            )
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                        }
                                    }
                                }
                            }

                            // Account Section
                            SettingsSection(title: "Account") {
                                VStack(spacing: 12) {
                                    if bookmarkManager.isAuthenticated {
                                        SettingsRow(
                                            icon: "person.circle.fill",
                                            title: "Account",
                                            subtitle: "Signed in",
                                            iconColor: .green
                                        ) {
                                            // Could navigate to account details
                                        }

                                        SettingsRow(
                                            icon: "icloud.fill",
                                            title: "Sync Status",
                                            subtitle: bookmarkManager.isSyncing ? "Syncing..." : (bookmarkManager.isAuthenticated ? "Cloud sync enabled" : "Not signed in"),
                                            iconColor: bookmarkManager.isAuthenticated ? .blue : .orange
                                        ) {
                                            showingSyncStatus = true
                                        }

                                        SettingsRow(
                                            icon: "arrow.right.square.fill",
                                            title: "Sign Out",
                                            subtitle: "Clear local data and sign out",
                                            iconColor: .orange
                                        ) {
                                            Task {
                                                await bookmarkManager.signOutAndClearRemoteData()
                                            }
                                        }
                                    } else {
                                        SettingsRow(
                                            icon: "person.badge.plus",
                                            title: "Sign In",
                                            subtitle: "Enable cloud sync for bookmarks",
                                            iconColor: .blue
                                        ) {
                                            showingAuthentication = true
                                        }
                                    }
                                }
                            }
                            
                            // Audio Section
                            SettingsSection(title: "Audio") {
                                VStack(spacing: 12) {
                                    SettingsRow(
                                        icon: "speaker.wave.2.fill",
                                        title: "Audio Quality",
                                        subtitle: "High Quality (128kbps)",
                                        iconColor: .indigo
                                    ) {
                                        // Could implement audio quality settings
                                    }
                                }
                            }
                            
                            // App Info Section
                            SettingsSection(title: "About") {
                                VStack(spacing: 12) {
                                    SettingsRow(
                                        icon: "info.circle.fill",
                                        title: "Version",
                                        subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                                        iconColor: .gray
                                    ) {
                                        // Could show app info
                                    }
                                    
                                    SettingsRow(
                                        icon: "heart.fill",
                                        title: "Support",
                                        subtitle: "Rate or review the app",
                                        iconColor: .red
                                    ) {
                                        // Could open App Store review
                                    }
                                    
                                    SettingsRow(
                                        icon: "trash.fill",
                                        title: "Clear All Local Data",
                                        subtitle: "Remove bookmarks, preferences, cache",
                                        iconColor: .red
                                    ) {
                                        performClearAllLocalData()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingThemeSelection) {
            ThemeSelectionView()
        }
        .sheet(isPresented: $showingAuthentication) {
            // You can replace this with your actual AuthenticationView
            Text("Authentication View")
        }
        .sheet(isPresented: $showingTimePickerSheet) {
            TimePickerSheet(
                selectedTime: Binding(
                    get: { notificationManager.preferences.time },
                    set: { notificationManager.preferences.time = $0 }
                ),
                isPresented: $showingTimePickerSheet
            )
        }
        .sheet(isPresented: $showingSyncStatus) {
            SyncStatusDetailView()
        }
        .alert("Local Data Cleared", isPresented: $showingClearDataAlert) {
            Button("OK") {
                // Force UI refresh
                DispatchQueue.main.async {
                    bookmarkManager.objectWillChange.send()
                }
            }
        } message: {
            Text(clearDataMessage)
        }
    }

    // MARK: - Helper Methods

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func toggleNotificationLanguage() {
        notificationManager.preferences.language = notificationManager.preferences.language == .english ? .urdu : .english
    }
    
    private func performClearAllLocalData() {
        print("🧹 SettingsView: Starting clear all local data")
        
        // Clear BookmarkManager data
        #if DEBUG
        BookmarkManager.shared.clearAllLocalData()
        #endif
        
        // Clear other UserDefaults that might exist
        let domain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        
        clearDataMessage = "All local data cleared successfully!\n\nBookmarks: 0\nPreferences: Reset\nCache: Cleared"
        showingClearDataAlert = true
        
        print("🧹 SettingsView: Completed clearing all local data")
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: () -> Content
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: action) {
            SettingsRowContent(
                icon: icon,
                title: title,
                subtitle: subtitle,
                iconColor: iconColor
            )
        }
    }
}

// MARK: - Settings Row Content (for use with NavigationLink)

struct SettingsRowContent: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(16)
        .background(
            Rectangle()
                .fill(Color.clear)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    @Binding var isOn: Bool
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.2))
                    .frame(width: 32, height: 32)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            // Text content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text(subtitle)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            // Toggle
            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(16)
        .background(
            Rectangle()
                .fill(Color.clear)
        )
        .contentShape(Rectangle())
    }
}

// MARK: - Time Picker Sheet

struct TimePickerSheet: View {
    @Binding var selectedTime: Date
    @Binding var isPresented: Bool
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    Text("Choose your preferred notification time")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                        .padding(.top, 20)

                    DatePicker(
                        "Time",
                        selection: $selectedTime,
                        displayedComponents: .hourAndMinute
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal, 20)

                    Spacer()
                }
            }
            .navigationTitle("Notification Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        isPresented = false
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

// MARK: - Sync Status Detail View

struct SyncStatusDetailView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isSyncing = false
    @State private var syncMessage = ""
    @State private var showingSyncMessage = false

    var body: some View {
        NavigationView {
            ZStack {
                themeManager.primaryBackground
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Connection Status Card
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: bookmarkManager.isAuthenticated ? "checkmark.circle.fill" : "xmark.circle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(bookmarkManager.isAuthenticated ? .green : .orange)

                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Connection Status")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(themeManager.primaryText)

                                    Text(bookmarkManager.isAuthenticated ? "Connected to Cloud" : "Not Signed In")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(themeManager.secondaryText)
                                }

                                Spacer()
                            }

                            if bookmarkManager.isAuthenticated {
                                Divider()
                                    .background(themeManager.strokeColor)

                                // Bookmark Count
                                HStack {
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.pink)
                                    Text("Bookmarks Synced")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(themeManager.secondaryText)
                                    Spacer()
                                    Text("\(bookmarkManager.bookmarks.count)")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(themeManager.primaryText)
                                }

                                // Last Sync Time
                                HStack {
                                    Image(systemName: "clock.fill")
                                        .foregroundColor(.blue)
                                    Text("Last Sync")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(themeManager.secondaryText)
                                    Spacer()
                                    Text(formatLastSyncTime())
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(themeManager.primaryText)
                                }
                            }
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )

                        // Actions
                        if bookmarkManager.isAuthenticated {
                            VStack(spacing: 12) {
                                // Manual Sync Button
                                Button(action: {
                                    performManualSync()
                                }) {
                                    HStack {
                                        if isSyncing {
                                            ProgressView()
                                                .scaleEffect(0.9)
                                                .tint(.white)
                                        } else {
                                            Image(systemName: "arrow.triangle.2.circlepath")
                                                .font(.system(size: 16, weight: .semibold))
                                        }

                                        Text(isSyncing ? "Syncing..." : "Sync Now")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                    )
                                }
                                .disabled(isSyncing || bookmarkManager.isSyncing)

                                // Info Text
                                Text("Bookmarks are automatically synced when you add, edit, or delete them. Use manual sync if you want to force an update.")
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(themeManager.tertiaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 16)
                            }
                            .padding(.horizontal, 20)
                        } else {
                            VStack(spacing: 16) {
                                Text("Sign in to enable cloud sync and access your bookmarks across all your devices.")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)

                                Button(action: {
                                    dismiss()
                                    // Trigger authentication screen
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        NotificationCenter.default.post(name: .showAuthentication, object: nil)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                            .font(.system(size: 16, weight: .semibold))
                                        Text("Sign In")
                                            .font(.system(size: 16, weight: .semibold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue)
                                    )
                                }
                                .padding(.horizontal, 20)
                            }
                        }

                        // Sync Message
                        if showingSyncMessage {
                            HStack {
                                Image(systemName: syncMessage.contains("success") ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                                    .foregroundColor(syncMessage.contains("success") ? .green : .red)
                                Text(syncMessage)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.primaryText)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(themeManager.strokeColor, lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }

                        Spacer()
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Sync Status")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }

    private func formatLastSyncTime() -> String {
        // Get the most recent bookmark's updatedAt time as a proxy for last sync
        guard let mostRecent = bookmarkManager.bookmarks.max(by: { $0.updatedAt < $1.updatedAt }) else {
            return "Never"
        }

        let now = Date()
        let interval = now.timeIntervalSince(mostRecent.updatedAt)

        if interval < 60 {
            return "Just now"
        } else if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes) minute\(minutes == 1 ? "" : "s") ago"
        } else if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours) hour\(hours == 1 ? "" : "s") ago"
        } else {
            let days = Int(interval / 86400)
            return "\(days) day\(days == 1 ? "" : "s") ago"
        }
    }

    private func performManualSync() {
        isSyncing = true
        syncMessage = ""
        showingSyncMessage = false

        Task {
            do {
                await bookmarkManager.forceSyncWithSupabase()

                await MainActor.run {
                    isSyncing = false
                    syncMessage = "Sync completed successfully"
                    showingSyncMessage = true

                    // Hide message after 3 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            showingSyncMessage = false
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    isSyncing = false
                    syncMessage = "Sync failed: \(error.localizedDescription)"
                    showingSyncMessage = true
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}