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
                // Adaptive background with floating elements
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
