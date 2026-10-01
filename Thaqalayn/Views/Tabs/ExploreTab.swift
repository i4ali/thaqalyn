//
//  ExploreTab.swift
//  Thaqalayn
//
//  NavigationView wrapper for ExploreView
//

import SwiftUI

struct ExploreTab: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                // Emerald background (both themes)
                AdaptiveModernBackground()

                ExploreView()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ExploreTab()
}
