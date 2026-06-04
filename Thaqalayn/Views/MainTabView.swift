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
    @ObservedObject private var tabBarVisibility = TabBarVisibility.shared
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

    // Adaptive items for the Midnight Emerald floating tab bar — mirrors whichever
    // tabs are present in the TabView below (always 0-3, plus at most one seasonal tab).
    private var emeraldItems: [EmeraldTabItem] {
        var items: [EmeraldTabItem] = [
            EmeraldTabItem(id: 0, label: "Today",    sfSymbol: "sun.max"),
            EmeraldTabItem(id: 1, label: "Quran",    sfSymbol: "book.closed"),
            EmeraldTabItem(id: 2, label: "Explore",  sfSymbol: "sparkles"),
            EmeraldTabItem(id: 3, label: "Progress", sfSymbol: "chart.bar"),
        ]
        if isRamadanSeason  { items.append(EmeraldTabItem(id: 4, label: "Ramadan",  sfSymbol: "moon.stars")) }
        if isHajjSeason     { items.append(EmeraldTabItem(id: 5, label: "Hajj",     sfSymbol: "building.columns")) }
        if isMuharramSeason { items.append(EmeraldTabItem(id: 6, label: "Muharram", sfSymbol: "flame")) }
        return items
    }

    var body: some View {
        ZStack(alignment: .bottom) {
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
                .toolbar(themeManager.isMidnightEmerald ? .hidden : .visible, for: .tabBar)

            HomeTab()
                .tabItem {
                    Label {
                        Text("Quran")
                    } icon: {
                        Image(systemName: "book.closed.fill")
                    }
                }
                .tag(1)
                .toolbar(themeManager.isMidnightEmerald ? .hidden : .visible, for: .tabBar)

            ExploreTab()
                .tabItem {
                    Label {
                        Text("Explore")
                    } icon: {
                        Image(systemName: "sparkles")
                    }
                }
                .tag(2)
                .toolbar(themeManager.isMidnightEmerald ? .hidden : .visible, for: .tabBar)

            ProgressTab()
                .tabItem {
                    Label {
                        Text("Progress")
                    } icon: {
                        Image(systemName: "circle.circle")
                    }
                }
                .tag(3)
                .toolbar(themeManager.isMidnightEmerald ? .hidden : .visible, for: .tabBar)

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
                    .toolbar(themeManager.isMidnightEmerald ? .hidden : .visible, for: .tabBar)
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
                    .toolbar(themeManager.isMidnightEmerald ? .hidden : .visible, for: .tabBar)
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
                    .toolbar(themeManager.isMidnightEmerald ? .hidden : .visible, for: .tabBar)
            }
        }
        .tint(themeManager.accentColor)

        if themeManager.isMidnightEmerald && !tabBarVisibility.isHidden {
            EmeraldTabBar(items: emeraldItems, selection: $selectedTab)
        }
        }
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
