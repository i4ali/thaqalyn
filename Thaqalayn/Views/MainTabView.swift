//
//  MainTabView.swift
//  Thaqalayn
//
//  Main TabView container with Today, Quran, Explore, Progress, and conditional Ramadan tabs
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var deepLinkRouter = DeepLinkRouter.shared
    @State private var selectedTab = 0

    // Check if Ramadan season is active
    private var isRamadanSeason: Bool {
        IslamicCalendarManager.shared.isRamadanSeason()
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayTab(selectedTab: $selectedTab)
                .tabItem {
                    Label {
                        Text("Today")
                    } icon: {
                        Image(systemName: "sun.max.fill")
                    }
                }
                .tag(0)

            HomeTab()
                .tabItem {
                    Label {
                        Text("Quran")
                    } icon: {
                        Image(systemName: "book.closed.fill")
                    }
                }
                .tag(1)

            ExploreTab()
                .tabItem {
                    Label {
                        Text("Explore")
                    } icon: {
                        Image(systemName: "sparkles")
                    }
                }
                .tag(2)

            ProgressTab()
                .tabItem {
                    Label {
                        Text("Progress")
                    } icon: {
                        Image(systemName: "circle.circle")
                    }
                }
                .tag(3)

            // Conditional Ramadan tab - only visible during Ramadan season
            if isRamadanSeason {
                RamadanJourneyView()
                    .tabItem {
                        Label {
                            Text("Ramadan")
                        } icon: {
                            Image(systemName: "moon.stars.fill")
                        }
                    }
                    .tag(4)
            }
        }
        .tint(themeManager.accentColor)
        .onReceive(NotificationCenter.default.publisher(for: .navigateToVerse)) { notification in
            guard let userInfo = notification.userInfo,
                  let surah = userInfo["surah"] as? Int,
                  let verse = userInfo["verse"] as? Int else { return }

            // Stash the deep-link first so HomeView consumes it on appear
            deepLinkRouter.pendingDeepLink = PendingDeepLink(
                surahNumber: surah,
                verseNumber: verse
            )
            // Then switch to the Quran tab — HomeView's onAppear/onChange triggers the navigation.
            selectedTab = 1
        }
    }
}

#Preview {
    MainTabView()
}
