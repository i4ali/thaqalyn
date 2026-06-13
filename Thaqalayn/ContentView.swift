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
}

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @StateObject private var ratingManager = RatingManager.shared
    @State private var showingWelcome = false
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
        .onChange(of: themeManager.selectedTheme) { _, newValue in
            ChromeAppearance.apply(for: newValue)
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
            showingWelcome = true
        }
    }
}

struct AdaptiveModernBackground: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald {
            EmeraldBackground()
        } else {
            ZStack {
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground,
                        themeManager.tertiaryBackground
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                RadialGradient(
                    colors: [themeManager.floatingOrbColors[0], .clear],
                    center: .topLeading,
                    startRadius: 0,
                    endRadius: 300
                )

                RadialGradient(
                    colors: [themeManager.floatingOrbColors[1], .clear],
                    center: .bottomTrailing,
                    startRadius: 0,
                    endRadius: 300
                )

                RadialGradient(
                    colors: [themeManager.floatingOrbColors[2], .clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: 200
                )
            }
            .ignoresSafeArea()
            .darkScreenAura()
        }
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
            
            Text("Experience the Quran like never before\nwith AI-powered Shia commentary")
                .font(.system(size: 18, weight: .light))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(themeManager.semanticBlue)
                
                Text("Initializing AI Commentary...")
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

struct SurahListView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @State private var searchText = ""
    @State private var showingAuthentication = false
    @State private var showingSettings = false
    @State private var showingNotifications = false
    @State private var selectedSurahForDeepLink: SurahWithTafsir?
    @State private var targetVerseNumber: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern header with glassmorphism
            VStack(spacing: 16) {
                // Top navigation row (universal for all themes)
                HStack(spacing: 12) {
                    // Profile Avatar (theme-adaptive)
                    ProfileAvatar()

                    Spacer()

                    // Bookmark Badge (theme-adaptive)
                    BookmarkBadge()

                    Spacer()

                    // Notification Bell (theme-adaptive)
                    NotificationBell(showingNotifications: $showingNotifications)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Text("Assalamu Alaikum")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                            PhosphorIcon(name: "ph-moon-stars-fill", size: 16)
                                .foregroundColor(themeManager.accentColor)
                        }

                        Text("The Holy Quran")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(themeManager.primaryText)
                    }

                    Spacer()
                }
                
                // Search bar with glassmorphism
                HStack {
                    PhosphorIcon(name: "ph-magnifying-glass", size: 18)
                        .foregroundColor(themeManager.tertiaryText)

                    TextField("Search surahs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(themeManager.primaryText)
                }
                .padding(16)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.selectedTheme == .nightSanctuary
                              ? themeManager.glassSurface
                              : Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                        .shadow(
                            color: themeManager.selectedTheme == .nightSanctuary
                                ? Color.black.opacity(0.45)
                                : Color.black.opacity(0.04),
                            radius: 12, x: 0, y: 4
                        )
                }

                // Discovery Carousel (Life Moments + Q&A)
                DiscoveryCarousel()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
            
            // Surah list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(dataManager.availableSurahs.filter { surah in
                        searchText.isEmpty ||
                        surah.surah.englishName.localizedCaseInsensitiveContains(searchText) ||
                        surah.surah.englishNameTranslation.localizedCaseInsensitiveContains(searchText) ||
                        surah.surah.arabicName.contains(searchText)
                    }) { surahWithTafsir in
                        NavigationLink(destination: SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil)) {
                            ModernSurahCard(surah: surahWithTafsir.surah)
                        }
                        .buttonStyle(EmPressStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }

            // Hidden NavigationLink for deep linking
            if let surahForDeepLink = selectedSurahForDeepLink {
                NavigationLink(
                    destination: SurahDetailView(surahWithTafsir: surahForDeepLink, targetVerse: targetVerseNumber),
                    isActive: Binding(
                        get: { selectedSurahForDeepLink != nil },
                        set: { if !$0 {
                            selectedSurahForDeepLink = nil
                            targetVerseNumber = nil
                        } }
                    )
                ) {
                    EmptyView()
                }
                .frame(width: 0, height: 0)
                .hidden()
            }
            
        }
        .overlay(alignment: .bottom) {
            if let syncStatus = bookmarkManager.syncStatus {
                SyncStatusToast(message: syncStatus)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: bookmarkManager.syncStatus)
            }
        }
        .fullScreenCover(isPresented: $showingAuthentication) {
            AuthenticationView()
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .sheet(isPresented: $showingNotifications) {
            NotificationsView()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAuthentication)) { _ in
            showingAuthentication = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .init("showSettings"))) { _ in
            showingSettings = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .navigateToVerse)) { notification in
            guard let userInfo = notification.userInfo,
                  let surah = userInfo["surah"] as? Int,
                  let verse = userInfo["verse"] as? Int else {
                return
            }

            // Dismiss any open sheets first
            showingSettings = false
            showingAuthentication = false

            // Find the surah data and navigate after a brief delay to allow sheets to dismiss
            if let surahData = dataManager.availableSurahs.first(where: { $0.surah.number == surah }) {
                // Wait for sheets to dismiss before navigating
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    targetVerseNumber = verse
                    selectedSurahForDeepLink = surahData
                }
            }
        }
    }
}

struct StatCard: View {
    let number: String
    let label: String
    let color: Color?
    @StateObject private var themeManager = ThemeManager.shared

    init(number: String, label: String, color: Color? = nil) {
        self.number = number
        self.label = label
        self.color = color
    }

    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(color ?? themeManager.accentColor)

            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary
                      ? themeManager.glassSurface
                      : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .shadow(
                    color: color?.opacity(0.15) ?? Color.clear,
                    radius: 12,
                    x: 0,
                    y: 4
                )
        }
    }
}

struct ModernSurahCard: View {
    let surah: Surah
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var progressManager = ProgressManager.shared

    private var completion: (read: Int, total: Int) {
        progressManager.getSurahCompletion(surahNumber: surah.number)
    }

    private var readCount: Int {
        completion.read
    }

    private var totalCount: Int {
        completion.total
    }

    private var percentage: Int {
        totalCount > 0 ? Int((Double(readCount) / Double(totalCount)) * 100) : 0
    }

    private var surahNumberGradient: LinearGradient {
        LinearGradient(
            colors: [Color(red: 0.91, green: 0.604, blue: 0.435), Color(red: 0.847, green: 0.541, blue: 0.373)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var surahNumberShadowColor: Color {
        Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.3)
    }

    var body: some View {
        if themeManager.isMidnightEmerald {
            emeraldBody
        } else {
            legacyBody
        }
    }

    private var legacyBody: some View {
        HStack(spacing: 16) {
            // Surah number badge with theme-adaptive styling
            ZStack {
                Circle()
                    .fill(surahNumberGradient)
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: surahNumberShadowColor,
                        radius: 8
                    )

                Text("\(surah.number)")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(surah.englishName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)

                        Text(surah.englishNameTranslation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }

                    Spacer()

                    Text(surah.arabicName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.trailing)
                }

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        PhosphorIcon(name: "ph-book-open", size: 12)
                            .foregroundColor(themeManager.tertiaryText)
                        Text("\(surah.versesCount) verses")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }

                    HStack(spacing: 4) {
                        PhosphorIcon(name: "ph-map-pin-fill", size: 12)
                            .foregroundColor(themeManager.tertiaryText)
                        Text(surah.revelationType)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }

                    if readCount > 0 {
                        HStack(spacing: 4) {
                            PhosphorIcon(name: percentage >= 100 ? "ph-trophy-fill" : "ph-seal-check-fill", size: 12)
                                .foregroundColor(percentage >= 100 ? .orange : .green)
                            Text("\(percentage)%")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(percentage >= 100 ? .orange : .green)
                        }
                    }

                    Spacer()
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary
                      ? themeManager.glassSurface
                      : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary
                        ? Color.black.opacity(0.45)
                        : Color.black.opacity(0.04),
                    radius: 12, x: 0, y: 4
                )
        }
    }

    private var emeraldBody: some View {
        EmCard {
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
                    HStack(spacing: 8) {
                        Text("\(surah.versesCount) verses")
                            .foregroundColor(themeManager.tertiaryText)
                        Text("·").foregroundColor(themeManager.tertiaryText)
                        Text(surah.revelationType)
                            .foregroundColor(themeManager.tertiaryText)
                        if readCount > 0 {
                            Text("·").foregroundColor(themeManager.tertiaryText)
                            Text("\(percentage)%")
                                .foregroundColor(themeManager.accentColor)
                                .fontWeight(.semibold)
                        }
                        Spacer(minLength: 0)
                    }
                    .font(.system(size: 12, weight: .medium))
                }
            }
            .padding(20)
        }
    }
}

struct AuthenticationStatusButton: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    @State private var showingProfile = false

    var body: some View {
        Button(action: {
            showingProfile = true
        }) {
            // Always show avatar (user initials or guest "U")
            Circle()
                .fill(themeManager.accentGradient)
                .frame(width: 40, height: 40)
                .overlay(
                    Text(getUserInitials())
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                )
                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)
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
        Group {
            if themeManager.isMidnightEmerald {
                emeraldBody
            } else {
                legacyBody
            }
        }
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

    private var legacyBody: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    // User info section
                    VStack(spacing: 16) {
                        Circle()
                            .fill(themeManager.accentGradient)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Text(getUserInitials())
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: themeManager.semanticBlue.opacity(0.4), radius: 12)
                        
                        VStack(spacing: 4) {
                            Text(getUserEmail())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)

                            Text(premiumManager.isPremium ? "Premium Member" : "Free Tier")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(premiumManager.isPremium ? .green : .orange)
                        }
                    }
                    
                    // Menu options
                    VStack(spacing: 16) {
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
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.semanticBlue)
                }
            }
        }
    }

    private var emeraldBody: some View {
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
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        Button(action: action) {
            EmCard(cornerRadius: 16) {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(isDestructive ? Color(red: 0.82, green: 0.36, blue: 0.33).opacity(0.14) : themeManager.accentChip)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(isDestructive ? Color(red: 0.82, green: 0.36, blue: 0.33).opacity(0.32) : themeManager.strokeColor, lineWidth: 1)
                            )
                        Image(systemName: icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(isDestructive ? Color(red: 0.86, green: 0.49, blue: 0.45) : themeManager.accentColor)
                    }
                    .frame(width: 44, height: 44)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(EmType.serif(19, .semiBold))
                            .foregroundColor(isDestructive ? Color(red: 0.86, green: 0.49, blue: 0.45) : themeManager.primaryText)
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

    private var legacyBody: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDestructive ? .red : themeManager.semanticBlue)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isDestructive ? .red : themeManager.primaryText)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SyncStatusToast: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 12) {
            if message.contains("Syncing") {
                ProgressView()
                    .scaleEffect(0.8)
                    .tint(.white)
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
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.black.opacity(0.3))
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 100) // Above tab bar
    }
}

struct AudioSettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingReciterSelection = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Reciter selection
                        AudioSettingCard(
                            icon: "person.wave.2.fill",
                            title: "Reciter",
                            subtitle: audioManager.configuration.selectedReciter.nameEnglish,
                            action: { showingReciterSelection = true }
                        )
                        
                        // Playback speed
                        AudioSettingCard(
                            icon: "speedometer",
                            title: "Playback Speed",
                            subtitle: String(format: "%.2fx", audioManager.configuration.playbackSpeed)
                        ) {
                            // Speed picker inline
                        } content: {
                            HStack {
                                Text("Speed")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                                
                                Spacer()
                                
                                Menu {
                                    ForEach([0.5, 0.75, 1.0, 1.25, 1.5, 2.0], id: \.self) { speed in
                                        Button(String(format: "%.2fx", speed)) {
                                            audioManager.updatePlaybackSpeed(speed)
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(String(format: "%.2fx", audioManager.configuration.playbackSpeed))
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(themeManager.primaryText)
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(themeManager.tertiaryText)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        
                        // Repeat mode
                        AudioSettingCard(
                            icon: audioManager.configuration.repeatMode.icon,
                            title: "Repeat Mode",
                            subtitle: audioManager.configuration.repeatMode.title
                        ) {
                            // Repeat mode picker inline
                        } content: {
                            HStack {
                                Text("Repeat")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                                
                                Spacer()
                                
                                Menu {
                                    ForEach(RepeatMode.allCases, id: \.self) { mode in
                                        Button(action: {
                                            audioManager.updateRepeatMode(mode)
                                        }) {
                                            HStack {
                                                Image(systemName: mode.icon)
                                                Text(mode.title)
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Image(systemName: audioManager.configuration.repeatMode.icon)
                                            .font(.system(size: 14, weight: .medium))
                                        
                                        Text(audioManager.configuration.repeatMode.title)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(themeManager.primaryText)
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 12, weight: .medium))
                                            .foregroundColor(themeManager.tertiaryText)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Audio Settings")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.semanticBlue)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .sheet(isPresented: $showingReciterSelection) {
            ReciterSelectionView()
        }
    }
}

struct AudioSettingCard<Content: View>: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: (() -> Void)?
    let content: (() -> Content)?
    @StateObject private var themeManager = ThemeManager.shared
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        action: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.content = content
    }
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        action: @escaping () -> Void
    ) where Content == EmptyView {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.content = nil
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: action ?? {}) {
                HStack(spacing: 16) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(themeManager.semanticBlue)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text(subtitle)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    if action != nil && content == nil {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
                .frame(minHeight: 60)
                .contentShape(Rectangle())
            }
            .disabled(action == nil)
            
            if let content = content {
                content()
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
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

struct BookmarkBadge: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared

    var body: some View {
        NavigationLink(destination: BookmarksView()) {
            HStack(spacing: 6) {
                PhosphorIcon(name: "ph-heart-fill", size: 18)
                    .foregroundColor(themeManager.accentColor)
                Text("\(bookmarkManager.bookmarks.count)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.accentColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 24)
                    .fill(themeManager.selectedTheme == .nightSanctuary
                          ? themeManager.glassSurface
                          : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 24)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(themeManager.selectedTheme == .nightSanctuary ? 0.4 : 0.06),
                            radius: 8, x: 0, y: 2)
            }
        }
        .buttonStyle(EmPressStyle())
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
