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
            HomeTab()
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        Image(systemName: "house.fill")
                    }
                }
                .tag(0)

            ExploreTab()
                .tabItem {
                    Label {
                        Text("Explore")
                    } icon: {
                        Image(systemName: "sparkles")
                    }
                }
                .tag(1)

            ProgressTab()
                .tabItem {
                    Label {
                        Text("Progress")
                    } icon: {
                        Image(systemName: "circle.circle")
                    }
                }
                .tag(2)

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
                    .tag(3)
            }
        }
        .tint(themeManager.accentColor)
    }
}

#Preview {
    MainTabView()
}
