//
//  ProgressTab.swift
//  Thaqalayn
//
//  NavigationView wrapper for ProgressRingsView
//

import SwiftUI

struct ProgressTab: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()
                ProgressRingsView()
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    ProgressTab()
}
