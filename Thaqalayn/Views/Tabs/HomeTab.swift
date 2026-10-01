//
//  HomeTab.swift
//  Thaqalayn
//
//  NavigationView wrapper for HomeView
//

import SwiftUI

struct HomeTab: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                // Emerald background (both themes)
                AdaptiveModernBackground()

                HomeView()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    HomeTab()
}
