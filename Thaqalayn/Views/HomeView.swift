//
//  HomeView.swift
//  Thaqalayn
//
//  Home tab view - Surah list without discovery carousel
//

import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var progressManager = ProgressManager.shared
    @State private var searchText = ""
    @State private var showingAuthentication = false
    @State private var showingSettings = false
    @State private var showingProgressDashboard = false
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

                    // Streak Badge (theme-adaptive)
                    StreakBadge()

                    // Bookmark Badge (theme-adaptive)
                    BookmarkBadge()

                    Spacer()

                    // Notification Bell (theme-adaptive)
                    NotificationBell(showingNotifications: $showingNotifications)
                }

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Assalamu Alaikum \u{1F319}")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)

                        Text("The Holy Quran")
                            .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32, weight: .bold, design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
                            .foregroundColor(themeManager.primaryText)
                    }

                    Spacer()
                }

                // Search bar with glassmorphism
                HStack {
                    if themeManager.selectedTheme == .warmInviting {
                        Text("\u{1F50D}")
                            .font(.system(size: 20))
                    } else {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.tertiaryText)
                    }

                    TextField("Search surahs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(themeManager.primaryText)
                }
                .padding(themeManager.selectedTheme == .warmInviting ? 16 : 12)
                .background {
                    if themeManager.selectedTheme == .warmInviting {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(red: 1.0, green: 1.0, blue: 1.0).opacity(1.0))
                            .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.glassEffect)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
            .background {
                if themeManager.selectedTheme != .warmInviting {
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
                }
            }

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
        .fullScreenCover(isPresented: $showingProgressDashboard) {
            ProgressDashboardView()
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

#Preview {
    HomeView()
}
