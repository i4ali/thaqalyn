//
//  MainTabView.swift
//  Thaqalayn
//
//  Main TabView container with Home, Explore, Progress, and conditional Ramadan tabs
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var themeManager = ThemeManager.shared
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
    }
}

#Preview {
    MainTabView()
}
