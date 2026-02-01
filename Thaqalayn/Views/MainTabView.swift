//
//  MainTabView.swift
//  Thaqalayn
//
//  Main TabView container with Home and Explore tabs
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeTab()
                .tabItem {
                    Label {
                        Text("Home")
                    } icon: {
                        if themeManager.selectedTheme == .warmInviting {
                            Image(systemName: "house.fill")
                        } else {
                            Image(systemName: "house.fill")
                        }
                    }
                }
                .tag(0)

            ExploreTab()
                .tabItem {
                    Label {
                        Text("Explore")
                    } icon: {
                        if themeManager.selectedTheme == .warmInviting {
                            Image(systemName: "sparkles")
                        } else {
                            Image(systemName: "sparkles")
                        }
                    }
                }
                .tag(1)
        }
        .tint(themeManager.accentColor)
    }
}

#Preview {
    MainTabView()
}
