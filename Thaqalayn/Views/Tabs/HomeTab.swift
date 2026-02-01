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
                // Adaptive background with floating elements
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
