//
//  TodayTab.swift
//  Thaqalayn
//
//  NavigationView wrapper for TodayView
//

import SwiftUI

struct TodayTab: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var selectedTab: Int

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()
                TodayView(selectedTab: $selectedTab)
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    TodayTab(selectedTab: .constant(1))
}
