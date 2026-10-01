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
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var voiceManager = TTSVoiceManager.shared
    @StateObject private var dailyVerse = DailyVerseProvider.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @State private var showingPaywall = false
    @Environment(\.presentationMode) var presentationMode
    @State private var showingAuthentication = false
    @State private var showingClearDataAlert = false
    @State private var clearDataMessage = ""
    @State private var showingTimePickerSheet = false
    @State private var showingSyncStatus = false
    @State private var showingResetProgressAlert = false
    @State private var showingReciterSelection = false
    @State private var showingTTSVoiceSelection = false
    @State private var selectedTTSLanguage: CommentaryLanguage = .english
    @State private var showingMailCopiedAlert = false
    @State private var showingWidgetExplainer = false
    
    var body: some View {
        emeraldBody
            .preferredColorScheme(themeManager.colorScheme)
            .navigationBarHidden(true)
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
            .sheet(isPresented: $showingReciterSelection) {
                ReciterSelectionView()
            }
            .sheet(isPresented: $showingTTSVoiceSelection) {
                TTSVoicePickerView(language: selectedTTSLanguage)
            }
            .sheet(isPresented: $showingWidgetExplainer) {
                WidgetExplainerView()
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
            .alert("Reset Progress?", isPresented: $showingResetProgressAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    Task {
                        await progressManager.resetProgress()
                    }
                }
            } message: {
                Text("This will clear all your reading progress, streaks, and badges. This action cannot be undone.")
            }
            .alert("Email Address Copied", isPresented: $showingMailCopiedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("We couldn't open a mail app, so \(SupportContact.recipient) was copied to your clipboard.")
            }
    }

    // MARK: - Emerald body

    private var emeraldBody: some View {
        ZStack {
            EmeraldBackground()

            VStack(spacing: 0) {
                // Header
                HStack(alignment: .center) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 40, height: 40)
                            .background(Circle().fill(themeManager.accentChip))
                            .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                    }
                    .buttonStyle(EmPressStyle())

                    Spacer()

                    VStack(spacing: 3) {
                        Text("PREFERENCES")
                            .font(.system(size: 11, weight: .bold)).tracking(3)
                            .foregroundColor(themeManager.accentColor)
                        Text("Settings")
                            .font(EmType.serif(30, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                    }

                    Spacer()

                    // Invisible spacer to balance the close button
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 18)

                ScrollView {
                    VStack(spacing: 26) {
                        emeraldPremiumSection
                        emeraldYourNameSection
                        emeraldAppearanceSection
                        emeraldReadingSection
                        emeraldDailyVerseSection
                        emeraldReadingProgressSection
                        emeraldAccountSection
                        emeraldAudioSection
                        emeraldTTSSection
                        emeraldAboutSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 60)
                }
            }
        }
    }

    // MARK: - Emerald sections

    // The one road to the paywall from Settings. Premium chip, never a lock
    // (house rule); for premium users it settles into a quiet "active" state.
    private var emeraldPremiumSection: some View {
        Button {
            if !premiumManager.isPremium { showingPaywall = true }
        } label: {
            HStack(spacing: 13) {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Thaqalayn Premium")
                        .font(EmType.serif(17, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(premiumManager.isPremium
                         ? "Every dive, journey and passage is yours."
                         : "Everything. Forever. Every dive, journey and passage.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                if premiumManager.isPremium {
                    Text("ACTIVE")
                        .font(.system(size: 10, weight: .heavy)).tracking(1.6)
                        .foregroundColor(themeManager.accentColor)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().stroke(themeManager.accentColor.opacity(0.4), lineWidth: 1))
                } else {
                    Text("PREMIUM")
                        .font(.system(size: 10, weight: .heavy)).tracking(1.6)
                        .foregroundColor(themeManager.onAccentText)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(themeManager.accentGradient))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(LinearGradient(colors: [themeManager.accentColor.opacity(0.10),
                                                  themeManager.accentColor.opacity(0.03)],
                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(themeManager.accentColor.opacity(0.34), lineWidth: 1)
                    )
                    .shadow(color: themeManager.accentColor.opacity(0.09), radius: 20)
            )
        }
        .buttonStyle(EmPressStyle())
        .disabled(premiumManager.isPremium)
        .fullScreenCover(isPresented: $showingPaywall) { PaywallView() }
    }

    private var emeraldYourNameSection: some View {
        SettingsSection(title: "Your Name") {
            NameSettingRow()
        }
    }

    private var emeraldAppearanceSection: some View {
        SettingsSection(title: "Appearance") {
            EmCard(cornerRadius: 18) {
                HStack(spacing: 14) {
                    EmIconChip(sfSymbol: "moon.stars.fill", size: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Theme")
                            .font(EmType.serif(19, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                        Text("Light or Dark")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }

                    Spacer(minLength: 8)

                    Picker("Theme", selection: Binding(
                        get: { themeManager.selectedTheme },
                        set: { newValue in
                            withAnimation(.easeInOut(duration: 0.25)) {
                                themeManager.selectedTheme = newValue
                            }
                        }
                    )) {
                        ForEach(ThemeVariant.allCases, id: \.self) { variant in
                            Text(variant.displayName).tag(variant)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 140)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
            }
        }
    }

    private var emeraldReadingSection: some View {
        SettingsSection(title: "Reading") {
            ReadingSizeSettingRow()
        }
    }

    private var emeraldDailyVerseSection: some View {
        SettingsSection(title: "Daily Verse") {
            VStack(spacing: 12) {
                // Enable/Disable toggle
                SettingsToggleRow(
                    icon: "bell.fill",
                    title: "Daily Notifications",
                    subtitle: notificationManager.preferences.enabled ? "Enabled" : "Tap to enable",
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

                // Daily Reflection home-screen widget
                SettingsRow(
                    icon: "square.grid.2x2.fill",
                    title: "Daily Reflection Widget",
                    subtitle: "Verse, gems & prayer times on your Home Screen"
                ) {
                    showingWidgetExplainer = true
                }

                // Show additional settings only if enabled
                if notificationManager.preferences.enabled {
                    // Time picker
                    SettingsRow(
                        icon: "clock.fill",
                        title: "Notification Time",
                        subtitle: formatTime(notificationManager.preferences.time)
                    ) {
                        showingTimePickerSheet = true
                    }

                    // Include tafsir toggle
                    SettingsToggleRow(
                        icon: "book.fill",
                        title: "Include Commentary",
                        subtitle: notificationManager.preferences.includeTafsir ? "Brief tafsir shown" : "Verse only",
                        isOn: Binding(
                            get: { notificationManager.preferences.includeTafsir },
                            set: { notificationManager.preferences.includeTafsir = $0 }
                        )
                    )

                    // Today's verse preview. On a sacred day the occasion replaces
                    // the generic header.
                    EmCard(cornerRadius: 16) {
                        VStack(alignment: .leading, spacing: 6) {
                            EmSectionLabel(
                                icon: "star.fill",
                                text: dailyVerse.today.occasionEn ?? "Today's Verse"
                            )
                            Text("Surah \(dailyVerse.today.surah), Verse \(dailyVerse.today.verse)")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                            Text(dailyVerse.today.themeEn)
                                .font(EmType.serif(18, .medium))
                                .foregroundColor(themeManager.primaryText)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(16)
                    }
                }
            }
        }
    }

    private var emeraldReadingProgressSection: some View {
        SettingsSection(title: "Reading Progress") {
            VStack(spacing: 12) {
                // Current Streak
                SettingsRow(
                    icon: "flame.fill",
                    title: "Current Streak",
                    subtitle: "\(progressManager.streak.currentStreak) days"
                ) {
                    // Just displays info, no action
                }

                // Progress Notifications Toggle
                SettingsToggleRow(
                    icon: "bell.badge.fill",
                    title: "Progress Notifications",
                    subtitle: progressManager.preferences.notificationsEnabled ? "Motivational reminders" : "Tap to enable",
                    isOn: Binding(
                        get: { progressManager.preferences.notificationsEnabled },
                        set: { newValue in
                            var newPrefs = progressManager.preferences
                            newPrefs.notificationsEnabled = newValue
                            progressManager.updatePreferences(newPrefs)
                        }
                    )
                )

                // Badge Celebrations Toggle
                SettingsToggleRow(
                    icon: "star.fill",
                    title: "Badge Celebrations",
                    subtitle: progressManager.preferences.celebrationsEnabled ? "Show celebrations" : "Quiet mode",
                    isOn: Binding(
                        get: { progressManager.preferences.celebrationsEnabled },
                        set: { newValue in
                            var newPrefs = progressManager.preferences
                            newPrefs.celebrationsEnabled = newValue
                            progressManager.updatePreferences(newPrefs)
                        }
                    )
                )

                // Reset Progress
                SettingsRow(
                    icon: "arrow.counterclockwise",
                    title: "Reset Progress",
                    subtitle: "Clear all reading progress",
                    isDestructive: true
                ) {
                    showingResetProgressAlert = true
                }
            }
        }
    }

    private var emeraldAccountSection: some View {
        SettingsSection(title: "Account") {
            VStack(spacing: 12) {
                if bookmarkManager.isAuthenticated {
                    SettingsRow(
                        icon: "person.circle.fill",
                        title: "Account",
                        subtitle: "Signed in"
                    ) {
                        // Could navigate to account details
                    }

                    SettingsRow(
                        icon: "icloud.fill",
                        title: "Sync Status",
                        subtitle: bookmarkManager.isSyncing ? "Syncing..." : (bookmarkManager.isAuthenticated ? "Cloud sync enabled" : "Not signed in")
                    ) {
                        showingSyncStatus = true
                    }
                } else {
                    SettingsRow(
                        icon: "person.badge.plus",
                        title: "Sign In",
                        subtitle: "Enable cloud sync for bookmarks"
                    ) {
                        showingAuthentication = true
                    }
                }
            }
        }
    }

    private var emeraldAudioSection: some View {
        SettingsSection(title: "Audio") {
            VStack(spacing: 12) {
                // Reciter selection
                SettingsRow(
                    icon: "person.wave.2.fill",
                    title: "Reciter",
                    subtitle: audioManager.configuration.selectedReciter.nameEnglish
                ) {
                    showingReciterSelection = true
                }

                // Repeat mode
                SettingsRow(
                    icon: audioManager.configuration.repeatMode.icon,
                    title: "Repeat Mode",
                    subtitle: audioManager.configuration.repeatMode.title
                ) {
                    cycleRepeatMode()
                }
            }
        }
    }

    private var emeraldTTSSection: some View {
        SettingsSection(title: "Text-to-Speech") {
            VStack(spacing: 12) {
                ForEach(TTSVoiceManager.supportedTTSLanguages, id: \.self) { language in
                    SettingsRow(
                        icon: "speaker.wave.2.fill",
                        title: "\(language.displayName) Voice",
                        subtitle: voiceManager.selectedVoice(for: language)?.name ?? "No voices"
                    ) {
                        selectedTTSLanguage = language
                        showingTTSVoiceSelection = true
                    }
                }
            }
        }
    }

    private var emeraldAboutSection: some View {
        SettingsSection(title: "About") {
            VStack(spacing: 12) {
                SettingsRow(
                    icon: "envelope.fill",
                    title: "Contact Us",
                    subtitle: "Email the developer"
                ) {
                    SupportContact.composeFeedbackEmail {
                        showingMailCopiedAlert = true
                    }
                }

                SettingsRow(
                    icon: "info.circle.fill",
                    title: "Version",
                    subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
                ) {
                    // Could show app info
                }

                SettingsRow(
                    icon: "trash.fill",
                    title: "Clear All Local Data",
                    subtitle: "Remove bookmarks, preferences, cache",
                    isDestructive: true
                ) {
                    performClearAllLocalData()
                }
            }
        }
    }

    // MARK: - Language picker (writes the global app language)

    // MARK: - Helper Methods

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func cycleRepeatMode() {
        let modes: [RepeatMode] = [.off, .verse, .surah, .continuous]
        if let currentIndex = modes.firstIndex(of: audioManager.configuration.repeatMode) {
            let nextIndex = (currentIndex + 1) % modes.count
            audioManager.updateRepeatMode(modes[nextIndex])
        }
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
        VStack(alignment: .leading, spacing: 14) {
            Text(title.uppercased())
                .font(.system(size: 11, weight: .bold)).tracking(2.5)
                .foregroundColor(themeManager.accentColor)
                .padding(.horizontal, 2)

            VStack(spacing: 12) {
                content()
            }
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isDestructive: Bool
    let action: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    init(icon: String, title: String, subtitle: String, isDestructive: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.isDestructive = isDestructive
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            EmCard(cornerRadius: 16) {
                HStack(spacing: 14) {
                    if isDestructive {
                        ZStack {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(themeManager.destructiveTint.opacity(0.14))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(themeManager.destructiveTint.opacity(0.32), lineWidth: 1)
                                )
                            Image(systemName: icon)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(themeManager.destructive)
                        }
                        .frame(width: 44, height: 44)
                    } else {
                        EmIconChip(sfSymbol: icon, size: 44)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(EmType.serif(19, .semiBold))
                            .foregroundColor(isDestructive ? themeManager.destructive : themeManager.primaryText)
                        Text(subtitle)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }

                    Spacer(minLength: 8)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
            }
        }
        .buttonStyle(EmPressStyle())
    }
}

// MARK: - Settings Toggle Row

struct SettingsToggleRow: View {
    let icon: String
    let title: String
    let subtitle: String
    @Binding var isOn: Bool
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        EmCard(cornerRadius: 16) {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: icon, size: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(EmType.serif(19, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }

                Spacer(minLength: 8)

                Toggle("", isOn: $isOn)
                    .labelsHidden()
                    .tint(themeManager.accentColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 14)
        }
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
                                .buttonStyle(EmPressStyle())
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
                                .buttonStyle(EmPressStyle())
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

// MARK: - Your Name setting

struct NameSettingRow: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var profile = UserProfileManager.shared

    private let maxNameLength = 30

    var body: some View {
        HStack(spacing: 14) {
            EmIconChip(sfSymbol: "person.fill", size: 44)

            TextField("Your name", text: $profile.displayName)
                .font(EmType.serif(18, .medium))
                .foregroundColor(tm.primaryText)
                .submitLabel(.done)
                .onChange(of: profile.displayName) { _, newValue in
                    if newValue.count > maxNameLength {
                        profile.displayName = String(newValue.prefix(maxNameLength))
                    }
                }

            if !profile.displayName.isEmpty {
                Button {
                    profile.displayName = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(tm.tertiaryText)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tm.glassSurface)
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(tm.strokeColor, lineWidth: 1))
        )
    }
}

// MARK: - Reading text-size setting

/// "Reading Text Size" control for Settings: label + A−/dots/A+ stepper + a live
/// preview line that resizes with the global ReadingSettingsManager scale.
struct ReadingSizeSettingRow: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var settings = ReadingSettingsManager.shared

    private func stepButton(_ label: String, size: CGFloat, enabled: Bool, a11y: String, action: @escaping () -> Void) -> some View {
        Button(action: { withAnimation(.easeInOut(duration: 0.18)) { action() } }) {
            Text(label)
                .font(.system(size: size, weight: .semibold))
                .foregroundColor(enabled ? tm.accentColor : tm.tertiaryText)
                .frame(width: 34, height: 34)
                .background(Circle().fill(tm.accentChip))
                .overlay(Circle().stroke(tm.strokeColor, lineWidth: 1))
        }
        .disabled(!enabled)
        .accessibilityLabel(a11y)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: "textformat.size", size: 44)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Reading Text Size")
                        .font(EmType.serif(19, .semiBold))
                        .foregroundColor(tm.primaryText)
                    Text("Verses, translation & commentary")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(tm.secondaryText)
                }
                Spacer(minLength: 8)
            }

            HStack(spacing: 18) {
                stepButton("A", size: 15, enabled: settings.canDecrease, a11y: "Decrease text size") { settings.decrease() }
                HStack(spacing: 8) {
                    ForEach(0..<settings.stepCount, id: \.self) { i in
                        Circle()
                            .fill(i <= settings.stepIndex ? tm.accentColor : tm.strokeColorStrong)
                            .frame(width: 7, height: 7)
                    }
                }
                .frame(maxWidth: .infinity)
                stepButton("A", size: 23, enabled: settings.canIncrease, a11y: "Increase text size") { settings.increase() }
            }

            Text("In the name of Allah, the Most Gracious, the Most Merciful.")
                .font(EmType.serif(17 * settings.scale, .medium))
                .foregroundColor(tm.secondaryText)
                .lineSpacing(4 * settings.scale)
                .fixedSize(horizontal: false, vertical: true)
                .animation(.easeInOut(duration: 0.2), value: settings.stepIndex)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(tm.glassSurface)
                .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(tm.strokeColor, lineWidth: 1))
        )
    }
}

#Preview {
    SettingsView()
}