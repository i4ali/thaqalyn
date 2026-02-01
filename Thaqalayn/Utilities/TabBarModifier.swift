//
//  TabBarModifier.swift
//  Thaqalayn
//
//  View modifier for hiding tab bar on specific screens
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

extension View {
    /// Hides the tab bar when applied to a view
    @ViewBuilder
    func hideTabBar() -> some View {
        if #available(iOS 16.0, *) {
            self.toolbar(.hidden, for: .tabBar)
        } else {
            self.modifier(HideTabBarModifier())
        }
    }
}

/// Fallback modifier for iOS 15
private struct HideTabBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            #if canImport(UIKit)
            .onAppear {
                UITabBar.appearance().isHidden = true
            }
            .onDisappear {
                UITabBar.appearance().isHidden = false
            }
            #endif
    }
}
