//
//  ContentView.swift
//  Thaqalayn
//
//  Main app interface with dark modern design
//

import SwiftUI

extension Notification.Name {
    static let showAuthentication = Notification.Name("showAuthentication")
    static let navigateToVerse = Notification.Name("NavigateToVerse")
    static let navigateToJourney = Notification.Name("NavigateToJourney")
    static let navigateToSurahExperience = Notification.Name("NavigateToSurahExperience")
    /// Reveal (not auto-open) a surah experience: switch to the Journey hub and
    /// scroll its Inside-the-Surah list to that surah's card, so the user can
    /// choose Watch or Listen. Posted by the Quran-list Journey tab.
    static let revealSurahExperience = Notification.Name("RevealSurahExperience")
    static let navigateToDeepDive = Notification.Name("NavigateToDeepDive")
}

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var ratingManager = RatingManager.shared
    @State private var showingWelcome = false
    /// First-launch onboarding is deferred until the loading splash finishes.
    @State private var pendingWelcome = false
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            if dataManager.isLoading {
                ZStack {
                    AdaptiveModernBackground()
                    LoadingView()
                }
            } else if let errorMessage = dataManager.errorMessage {
                ZStack {
                    AdaptiveModernBackground()
                    ErrorView(message: errorMessage)
                }
            } else {
                MainTabView()
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .tint(themeManager.accentColor)
        .overlay(alignment: .bottom) {
            if audioManager.currentPlayback != nil {
                SurahAudioPlayerView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: audioManager.currentPlayback != nil)
            }
        }
        .onAppear {
            checkFirstLaunch()
            ratingManager.recordAppLaunch()
            // Covers Arafah + journey-start + daily-verse window + badge/inbox.
            Task { await NotificationManager.shared.handleAppBecameActive() }
        }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await NotificationManager.shared.handleAppBecameActive() }
            }
        }
        .onChange(of: dataManager.isLoading) { _, loading in
            // Present onboarding only once the loading splash has finished.
            if !loading { presentWelcomeIfReady() }
        }
        .fullScreenCover(isPresented: $showingWelcome) {
            OnboardingFlowView()
        }
        .overlay {
            if let badge = progressManager.pendingBadge {
                BadgeAwardView(badge: badge) {
                    progressManager.dismissPendingBadge()
                }
                .transition(.opacity)
                .animation(.easeInOut, value: progressManager.pendingBadge != nil)
            }
        }
    }
    
    private func checkFirstLaunch() {
        // Only show welcome screen on first launch, not for authentication
        let hasShownWelcome = UserDefaults.standard.bool(forKey: "hasShownWelcome")

        if !hasShownWelcome {
            // Defer presentation until the loading splash finishes, so the
            // splash gets its full moment before onboarding slides up.
            pendingWelcome = true
            presentWelcomeIfReady()
            // Brand-new install: suppress the What's New backlog but keep the newest
            // announcement live, so day-one users still see the current headline card.
            WhatsNewManager.shared.seedBacklogAsSeenForFreshInstall()
        }

        #if DEBUG
        if ProcessInfo.processInfo.arguments.contains("-wnReset") {
            WhatsNewManager.shared.debugReset()
        }
        #endif
    }

    /// Presents the deferred first-launch onboarding once the loading splash
    /// (`dataManager.isLoading`) has finished.
    private func presentWelcomeIfReady() {
        guard pendingWelcome, !dataManager.isLoading else { return }
        pendingWelcome = false
        showingWelcome = true
    }
}

/// The app's screen background: the emerald radial ground with its gold top
/// glow, in both themes.
struct AdaptiveModernBackground: View {
    var body: some View {
        EmeraldBackground()
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Floating circles animation
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(themeManager.accentGradient.opacity(0.3))
                        .frame(width: 60 - CGFloat(index * 10), height: 60 - CGFloat(index * 10))
                        .blur(radius: 5)
                        .offset(y: isAnimating ? -20 : 20)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                            value: isAnimating
                        )
                }
            }
            .frame(height: 80)
            
            Text("ثقلين")
                .font(.system(size: 56, weight: .light, design: .default))
                .foregroundColor(themeManager.primaryText)
                .shadow(color: themeManager.semanticBlue.opacity(0.5), radius: 30)
            
            Text("Experience the Quran like never before\n")
                .font(.system(size: 18, weight: .light))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(themeManager.semanticBlue)
                
                Text("Preparing your journey...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .padding(60)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ErrorView: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(themeManager.semanticRed)
                .shadow(color: themeManager.semanticRed.opacity(0.3), radius: 20)
            
            Text("Error")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.primaryText)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct ModernSurahCard: View {
    let surah: Surah
    /// Keys "surah:verse" of every verse marked read. The list that renders these
    /// rows computes `ProgressManager.shared.readVerseKeys` once per render and
    /// passes it down: it builds a Set over every progress record, so it must not
    /// be rebuilt per row.
    let readVerseKeys: Set<String>
    /// True when an experience toggle is attached below - squares the bottom
    /// corners so card + toggle read as one card.
    var squaredBottom = false
    /// False when the row draws a single combined border around card + toggle,
    /// so the card must not stroke its own (seam-creating) outline.
    var showsBorder = true
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var dataManager = DataManager.shared

    /// The surah's passages (rukus); empty until the passage index has loaded.
    private var passages: [PassageRef] {
        dataManager.passageIndex?.passages(forSurah: surah.number) ?? []
    }

    private var totalCount: Int { passages.count }

    private var readCount: Int {
        PassageProgress.readCount(passages, readVerseKeys: readVerseKeys)
    }

    /// "40 passages" until the first passage is read, then "3 of 40 passages".
    private var passagesLabel: String {
        readCount > 0
            ? QuranTabStrings.passagesRead(readCount, of: totalCount)
            : QuranTabStrings.passagesCount(totalCount)
    }

    /// Card container shape - all four corners round at 20, or the bottom two
    /// squared off when an experience strip is attached directly below.
    private var cardShape: UnevenRoundedRectangle {
        UnevenRoundedRectangle(topLeadingRadius: 20,
                               bottomLeadingRadius: squaredBottom ? 0 : 20,
                               bottomTrailingRadius: squaredBottom ? 0 : 20,
                               topTrailingRadius: 20,
                               style: .continuous)
    }

    var body: some View {
        HStack(spacing: 16) {
            EmNumeralCircle(n: surah.number, size: 46)
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(surah.englishName)
                            .font(EmType.serif(20, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                        Text(surah.englishNameTranslation)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    Spacer(minLength: 8)
                    Text(surah.arabicName)
                        .font(EmType.arabic(24))
                        .foregroundColor(themeManager.accentBright)
                        .lineLimit(1)
                }
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(QuranTabStrings.versesCount(surah.versesCount))
                            .foregroundColor(themeManager.tertiaryText)
                        Text("·").foregroundColor(themeManager.tertiaryText)
                        Text(QuranTabStrings.revelation(surah.revelationType))
                            .foregroundColor(themeManager.tertiaryText)
                        Spacer(minLength: 0)
                    }
                    // Passage count and progress on its own line: "3 of 40 passages"
                    // does not fit beside the verse count and revelation type on
                    // narrow phones. Accent once reading has started, as the verse
                    // percentage was.
                    if totalCount > 0 {
                        Text(passagesLabel)
                            .foregroundColor(readCount > 0 ? themeManager.accentColor : themeManager.tertiaryText)
                            .fontWeight(readCount > 0 ? .semibold : .medium)
                    }
                }
                .font(.system(size: 12, weight: .medium))
            }
        }
        .padding(.horizontal, 20).padding(.top, 20)
        // Tighter bottom inset when a toggle is attached, so the buttons sit
        // closer to the metadata rather than floating far below it.
        .padding(.bottom, squaredBottom ? 10 : 20)
        .background(cardShape.fill(themeManager.glassSurface))
        .overlay {
            if showsBorder {
                cardShape.stroke(themeManager.strokeColor, lineWidth: 1)
            }
        }
        .emShadow(.card)
    }
}

struct ProfileMenuView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingSignOutAlert = false
    @State private var showingAccountDeletion = false
    @State private var showingPaywall = false
    
    var body: some View {
        content
            .preferredColorScheme(themeManager.colorScheme)
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Sign Out", role: .destructive) {
                    Task {
                        await bookmarkManager.signOutAndClearRemoteData()
                        await progressManager.signOutAndClearRemoteData()
                        await MainActor.run {
                            dismiss()
                            // Trigger authentication screen after sign out
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                                NotificationCenter.default.post(name: .showAuthentication, object: nil)
                            }
                        }
                    }
                }
            } message: {
                Text("Your bookmarks will remain on this device, but you'll need to sign in again to sync across devices.")
            }
            .sheet(isPresented: $showingAccountDeletion) {
                AccountDeletionView()
            }
            .fullScreenCover(isPresented: $showingPaywall) {
                PaywallView()
            }
    }

    private var content: some View {
        NavigationView {
            ZStack {
                EmeraldBackground()

                ScrollView {
                    VStack(spacing: 26) {
                        VStack(spacing: 14) {
                            Text("ACCOUNT")
                                .font(.system(size: 11, weight: .bold)).tracking(3)
                                .foregroundColor(themeManager.accentColor)

                            ZStack {
                                Circle()
                                    .fill(themeManager.accentGradient)
                                    .frame(width: 84, height: 84)
                                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                                    .shadow(color: themeManager.accentColor.opacity(0.35), radius: 16, x: 0, y: 6)
                                Text(getUserInitials())
                                    .font(EmType.serif(34, .semiBold))
                                    .foregroundColor(themeManager.onAccentText)
                            }

                            VStack(spacing: 5) {
                                Text(getUserEmail())
                                    .font(EmType.serif(22, .semiBold))
                                    .foregroundColor(themeManager.primaryText)
                                    .multilineTextAlignment(.center)
                                Text(premiumManager.isPremium ? "PREMIUM MEMBER" : "FREE TIER")
                                    .font(.system(size: 11, weight: .bold)).tracking(2.5)
                                    .foregroundColor(premiumManager.isPremium ? themeManager.semanticGreen : themeManager.accentColor)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 8)

                        EmDivider()

                        VStack(spacing: 12) {
                            menuOptions
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(EmType.serif(18, .semiBold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    @ViewBuilder
    private var menuOptions: some View {
        // Sign In (for guest users)
        if !supabaseService.isAuthenticated {
            ProfileMenuItem(
                icon: "person.circle",
                title: "Sign In",
                subtitle: "Sync bookmarks across devices",
                action: {
                    dismiss()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        NotificationCenter.default.post(name: .showAuthentication, object: nil)
                    }
                }
            )
        }

        // Upgrade to Premium (for non-premium users)
        if !premiumManager.isPremium {
            ProfileMenuItem(
                icon: "star.fill",
                title: "Upgrade to Premium",
                subtitle: "Unlock all tafsir commentary",
                action: { showingPaywall = true }
            )
        }

        // Restore Purchases (for non-premium users)
        if !premiumManager.isPremium {
            ProfileMenuItem(
                icon: "arrow.clockwise",
                title: "Restore Purchases",
                subtitle: "Already purchased? Restore here",
                action: {
                    Task {
                        try? await purchaseManager.restorePurchases()
                    }
                }
            )
        }

        ProfileMenuItem(
            icon: "gearshape.fill",
            title: "Settings",
            subtitle: "App preferences and theme",
            action: {
                dismiss()
                // Post notification to open settings
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    NotificationCenter.default.post(name: .init("showSettings"), object: nil)
                }
            }
        )

        // Leave a Review
        ProfileMenuItem(
            icon: "star.bubble.fill",
            title: "Leave a Review",
            subtitle: "Rate Al-Thaqalayn on the App Store",
            action: {
                RatingManager.shared.openAppStoreReviewPage()
            }
        )

        // Sync Status (only for authenticated users)
        if supabaseService.isAuthenticated {
            ProfileMenuItem(
                icon: "arrow.triangle.2.circlepath",
                title: "Sync Status",
                subtitle: bookmarkManager.isAuthenticated ? "Connected" : "Offline",
                action: {
                    Task {
                        await bookmarkManager.forceSyncWithSupabase()
                    }
                }
            )
        }

        // Sign Out (only for authenticated users)
        if supabaseService.isAuthenticated {
            ProfileMenuItem(
                icon: "rectangle.portrait.and.arrow.right",
                title: "Sign Out",
                subtitle: "Switch to guest mode",
                isDestructive: true,
                action: { showingSignOutAlert = true }
            )

            ProfileMenuItem(
                icon: "trash.fill",
                title: "Delete Account",
                subtitle: "Permanently remove account and data",
                isDestructive: true,
                action: { showingAccountDeletion = true }
            )
        }
    }

    private func getUserInitials() -> String {
        // Use current user email if online, otherwise fall back to cached email
        let email = supabaseService.currentUser?.email ?? supabaseService.cachedUserEmail
        if let email = email {
            let components = email.components(separatedBy: "@")
            if let username = components.first {
                let initials = String(username.prefix(2)).uppercased()
                return initials
            }
        }
        return "U"
    }
    
    private func getUserEmail() -> String {
        // Use current user email if online, otherwise fall back to cached email
        return supabaseService.currentUser?.email ?? supabaseService.cachedUserEmail ?? "Guest User"
    }
}

struct ProfileMenuItem: View {
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
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isDestructive ? themeManager.destructiveTint.opacity(0.14) : themeManager.accentChip)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(isDestructive ? themeManager.destructiveTint.opacity(0.32) : themeManager.strokeColor, lineWidth: 1)
                            )
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isDestructive ? themeManager.destructive : themeManager.accentColor)
                    }
                    .frame(width: 44, height: 44)

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

struct SyncStatusToast: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    /// Text and spinner: Sage Dawn ink in light, white in dark.
    private static let ink = Color(light: Color(hex: "14261E"), dark: .white)
    /// Veil over the material: a light frost in light, the original dark veil in dark.
    private static let veil = Color(light: Color.white.opacity(0.55), dark: Color.black.opacity(0.3))

    var body: some View {
        HStack(spacing: 12) {
            if message.contains("Syncing") {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(Self.ink)
            } else if message.contains("completed") {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if message.contains("failed") {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.red)
            } else {
                Image(systemName: "cloud.fill")
                    .foregroundColor(.blue)
            }
            
            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Self.ink)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Self.veil)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 100) // Above tab bar
    }
}

// MARK: - Theme-Adaptive Components

struct ProfileAvatar: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    @State private var showingProfile = false

    var body: some View {
        Button(action: {
            showingProfile = true
        }) {
            Circle()
                .fill(themeManager.accentGradient)
                .frame(width: 44, height: 44)
                .overlay(
                    Text(getUserInitials())
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(
                    color: themeManager.accentColor.opacity(0.3),
                    radius: 12
                )
        }
        .buttonStyle(PlainButtonStyle())
        .sheet(isPresented: $showingProfile) {
            ProfileMenuView()
        }
    }

    private func getUserInitials() -> String {
        // Use current user email if online, otherwise fall back to cached email
        let email = supabaseService.currentUser?.email ?? supabaseService.cachedUserEmail
        if let email = email {
            let components = email.components(separatedBy: "@")
            if let username = components.first {
                let initials = String(username.prefix(2)).uppercased()
                return initials
            }
        }
        return "U"
    }
}

struct NotificationBell: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var showingNotifications: Bool

    var body: some View {
        Button(action: {
            showingNotifications = true
        }) {
            PhosphorIcon(name: "ph-bell", size: 20)
                .foregroundColor(themeManager.primaryText)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
