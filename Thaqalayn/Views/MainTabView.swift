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

    // Check if Hajj season is active (mutually exclusive with Ramadan season)
    private var isHajjSeason: Bool {
        IslamicCalendarManager.shared.isHajjSeason()
    }

    // Check if Muharram season is active (mutually exclusive with Ramadan and Hajj seasons)
    private var isMuharramSeason: Bool {
        IslamicCalendarManager.shared.isMuharramSeason()
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

            // Conditional Hajj tab - only visible during Hajj season
            if isHajjSeason {
                HajjJourneyView()
                    .tabItem {
                        Label {
                            Text("Hajj")
                        } icon: {
                            Image(systemName: "building.columns.fill")
                        }
                    }
                    .tag(5)
            }

            // Conditional Muharram tab - only visible during Muharram season
            if isMuharramSeason {
                MuharramJourneyView()
                    .tabItem {
                        Label {
                            Text("Muharram")
                        } icon: {
                            Image(systemName: "flame.fill")
                        }
                    }
                    .tag(6)
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
        .onReceive(NotificationCenter.default.publisher(for: .navigateToJourney)) { notification in
            guard let userInfo = notification.userInfo,
                  let journeyId = userInfo["journey"] as? String else { return }

            // Only switch if that journey's tab is currently present (season
            // active). It will be: the notification fires at/after the lead-in.
            switch journeyId {
            case "ramadan":  if isRamadanSeason { selectedTab = 4 }
            case "hajj":     if isHajjSeason { selectedTab = 5 }
            case "muharram": if isMuharramSeason { selectedTab = 6 }
            default: break
            }
        }
    }
}

#Preview {
    MainTabView()
}
