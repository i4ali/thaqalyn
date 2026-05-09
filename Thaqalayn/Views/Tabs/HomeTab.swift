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
            .darkScreenAura()
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    HomeTab()
}
