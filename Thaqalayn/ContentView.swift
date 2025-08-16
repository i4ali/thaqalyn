//
//  ContentView.swift
//  Thaqalayn
//
//  Main app interface with dark modern design
//

import SwiftUI

extension Notification.Name {
    static let showAuthentication = Notification.Name("showAuthentication")
}

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @State private var showingWelcome = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background with floating elements
                AdaptiveModernBackground()
                
                Group {
                    if dataManager.isLoading {
                        LoadingView()
                    } else if let errorMessage = dataManager.errorMessage {
                        ErrorView(message: errorMessage)
                    } else {
                        SurahListView()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for iPhone
        .preferredColorScheme(themeManager.colorScheme)
        .overlay(alignment: .bottom) {
            if audioManager.currentPlayback != nil {
                SurahAudioPlayerView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: audioManager.currentPlayback != nil)
            }
        }
        .onAppear {
            checkFirstLaunch()
        }
        .onReceive(NotificationCenter.default.publisher(for: .showAuthentication)) { _ in
            showingWelcome = true
        }
        .fullScreenCover(isPresented: $showingWelcome) {
            WelcomeView()
        }
    }
    
    private func checkFirstLaunch() {
        // Always show welcome screen if user is not authenticated
        let hasShownWelcome = UserDefaults.standard.bool(forKey: "hasShownWelcome")
        let supabaseService = SupabaseService.shared
        
        if !hasShownWelcome || !supabaseService.isAuthenticated {
            showingWelcome = true
        }
    }
}

struct AdaptiveModernBackground: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.secondaryBackground,
                    themeManager.tertiaryBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating gradient orbs
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[0],
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[1],
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[2],
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
        }
        .ignoresSafeArea()
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
                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.5), radius: 30)
            
            Text("Experience the Quran like never before\nwith AI-powered Shia commentary")
                .font(.system(size: 18, weight: .light))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(Color(red: 0.39, green: 0.4, blue: 0.95))
                
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
                .foregroundColor(Color(red: 0.93, green: 0.28, blue: 0.6))
                .shadow(color: Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.3), radius: 20)
            
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
    @State private var searchText = ""
    @State private var showingBookmarks = false
    @State private var navigateToSurah: SurahWithTafsir?
    @State private var targetVerse: Int?
    @State private var showingAuthentication = false
    @State private var showingSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern header with glassmorphism
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Surahs")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text("AI-powered Shia Commentary")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Bookmarks button
                        Button(action: { showingBookmarks = true }) {
                            ZStack {
                                Image(systemName: "heart")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(themeManager.primaryText)
                                
                                if bookmarkManager.bookmarks.count > 0 {
                                    Circle()
                                        .fill(Color.pink)
                                        .frame(width: 12, height: 12)
                                        .overlay(
                                            Text("\(bookmarkManager.bookmarks.count)")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                        .offset(x: 12, y: -12)
                                }
                            }
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        Circle()
                                            .stroke(themeManager.strokeColor, lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Sync status indicator
                        if bookmarkManager.isSyncing {
                            Button(action: {}) {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.blue)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(themeManager.glassEffect)
                                            .overlay(
                                                Circle()
                                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                                            )
                                    )
                                    .rotationEffect(.degrees(bookmarkManager.isSyncing ? 360 : 0))
                                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: bookmarkManager.isSyncing)
                            }
                            .disabled(true)
                        } else if !bookmarkManager.isAuthenticated {
                            Button(action: {
                                showingAuthentication = true
                            }) {
                                Image(systemName: "cloud.slash")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.orange)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(themeManager.glassEffect)
                                            .overlay(
                                                Circle()
                                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                                            )
                                    )
                            }
                        } else {
                            Button(action: {
                                Task {
                                    await bookmarkManager.forceSyncWithSupabase()
                                }
                            }) {
                                Image(systemName: "cloud.fill")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.green)
                                    .frame(width: 40, height: 40)
                                    .background(
                                        Circle()
                                            .fill(themeManager.glassEffect)
                                            .overlay(
                                                Circle()
                                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                                            )
                                    )
                            }
                        }
                        
                        // Settings button
                        Button(action: {
                            showingSettings = true
                        }) {
                            Image(systemName: "gearshape.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(themeManager.glassEffect)
                                        .overlay(
                                            Circle()
                                                .stroke(themeManager.strokeColor, lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Profile/Authentication button
                        AuthenticationStatusButton()
                    }
                }
                
                // Search bar with glassmorphism
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeManager.tertiaryText)
                    
                    TextField("Search surahs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(themeManager.primaryText)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                )
                
                // Stats cards
                HStack(spacing: 12) {
                    StatCard(number: "\(dataManager.availableSurahs.count)", label: "Available")
                    StatCard(number: "\(dataManager.availableSurahs.reduce(0) { $0 + $1.surah.versesCount })", label: "Verses")
                    StatCard(number: "\(TafsirLayer.allCases.count)", label: "Layers")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
            .background(
                Rectangle()
                    .fill(themeManager.glassEffect)
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
            )
            
            // Surah list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(dataManager.availableSurahs.filter { surah in
                        searchText.isEmpty || 
                        surah.surah.englishName.localizedCaseInsensitiveContains(searchText) ||
                        surah.surah.arabicName.contains(searchText)
                    }) { surahWithTafsir in
                        NavigationLink(destination: SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil)) {
                            ModernSurahCard(surah: surahWithTafsir.surah)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Navigation destination for programmatic navigation from bookmarks
            .navigationDestination(isPresented: Binding(
                get: { navigateToSurah != nil },
                set: { if !$0 { navigateToSurah = nil; targetVerse = nil } }
            )) {
                if let surah = navigateToSurah {
                    SurahDetailView(surahWithTafsir: surah, targetVerse: targetVerse)
                }
            }
        }
        .sheet(isPresented: $showingBookmarks) {
            BookmarksView(selectedSurahForNavigation: $navigateToSurah, targetVerse: $targetVerse)
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
        .onReceive(NotificationCenter.default.publisher(for: .showAuthentication)) { _ in
            showingAuthentication = true
        }
    }
}

struct StatCard: View {
    let number: String
    let label: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(themeManager.accentGradient)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
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

struct ModernSurahCard: View {
    let surah: Surah
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Surah number with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.purpleGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)
                
                Text("\(surah.number)")
                    .font(.system(size: 18, weight: .semibold))
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
                        Image(systemName: "book")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.tertiaryText)
                        Text("\(surah.versesCount) verses")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.tertiaryText)
                        Text(surah.revelationType)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    
                    Spacer()
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
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    themeManager.floatingOrbColors[0].opacity(0.5),
                                    themeManager.floatingOrbColors[1].opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
    }
}

struct AuthenticationStatusButton: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    @State private var showingAuthentication = false
    @State private var showingProfile = false
    
    var body: some View {
        Button(action: {
            if supabaseService.isAuthenticated {
                showingProfile = true
            } else {
                showingAuthentication = true
            }
        }) {
            if supabaseService.isAuthenticated {
                // Show user avatar when authenticated
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text(getUserInitials())
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)
            } else {
                // Show sign in button when not authenticated
                HStack(spacing: 6) {
                    Image(systemName: "person.circle")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Sign In")
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), lineWidth: 1)
                        )
                )
            }
        }
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingAuthentication) {
            AuthenticationView()
        }
        .sheet(isPresented: $showingProfile) {
            ProfileMenuView()
        }
    }
    
    private func getUserInitials() -> String {
        if let user = supabaseService.currentUser,
           let email = user.email {
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
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingSignOutAlert = false
    @State private var showingAudioSettings = false
    
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
                            .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 12)
                        
                        VStack(spacing: 4) {
                            Text(getUserEmail())
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                            
                            Text("All Features Unlocked")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.green)
                        }
                    }
                    
                    // Menu options
                    VStack(spacing: 16) {
                        ProfileMenuItem(
                            icon: "heart.fill",
                            title: "Bookmarks",
                            subtitle: "\(bookmarkManager.bookmarks.count) saved verses",
                            action: { dismiss() }
                        )
                        
                        ProfileMenuItem(
                            icon: "speaker.wave.2.fill",
                            title: "Audio Settings",
                            subtitle: "Reciter: \(audioManager.configuration.selectedReciter.nameEnglish)",
                            action: { showingAudioSettings = true }
                        )
                        
                        
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
                        
                        ProfileMenuItem(
                            icon: "rectangle.portrait.and.arrow.right",
                            title: "Sign Out",
                            subtitle: "Switch to guest mode",
                            isDestructive: true,
                            action: { showingSignOutAlert = true }
                        )
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
                    .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .alert("Sign Out", isPresented: $showingSignOutAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Sign Out", role: .destructive) {
                Task {
                    await bookmarkManager.signOutAndClearRemoteData()
                    await MainActor.run {
                        dismiss()
                        // Trigger authentication screen after sign out
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            NotificationCenter.default.post(name: .showAuthentication, object: nil)
                        }
                    }
                }
            }
        } message: {
            Text("Your bookmarks will remain on this device, but you'll need to sign in again to sync across devices.")
        }
        .sheet(isPresented: $showingAudioSettings) {
            AudioSettingsView()
        }
    }
    
    private func getUserInitials() -> String {
        if let user = supabaseService.currentUser,
           let email = user.email {
            let components = email.components(separatedBy: "@")
            if let username = components.first {
                let initials = String(username.prefix(2)).uppercased()
                return initials
            }
        }
        return "U"
    }
    
    private func getUserEmail() -> String {
        return supabaseService.currentUser?.email ?? "Guest User"
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
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(isDestructive ? .red : Color(red: 0.39, green: 0.4, blue: 0.95))
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
                    .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))
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
                        .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))
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

#Preview {
    ContentView()
}
