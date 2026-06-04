//
//  TabBarModifier.swift
//  Thaqalayn
//
//  View modifier for hiding tab bar on specific screens.
//  Hides BOTH the native UITabBar and the custom Midnight Emerald floating
//  tab bar (which lives as an overlay above the TabView and so isn't affected
//  by `.toolbar(.hidden, for: .tabBar)`).
//

import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// Shared signal so the custom emerald floating tab bar can hide on pushed
/// detail screens (e.g. the reader). Driven by `hideTabBar()`.
@MainActor
final class TabBarVisibility: ObservableObject {
    static let shared = TabBarVisibility()
    @Published var isHidden = false
    private init() {}
}

extension View {
    /// Hides the tab bar (native + emerald floating) when applied to a view.
    func hideTabBar() -> some View {
        modifier(HideTabBarModifier())
    }
}

private struct HideTabBarModifier: ViewModifier {
    @ViewBuilder
    private func hideNative(_ content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.toolbar(.hidden, for: .tabBar)
        } else {
            content
                #if canImport(UIKit)
                .onAppear { UITabBar.appearance().isHidden = true }
                .onDisappear { UITabBar.appearance().isHidden = false }
                #endif
        }
    }

    func body(content: Content) -> some View {
        hideNative(content)
            .onAppear { TabBarVisibility.shared.isHidden = true }
            .onDisappear { TabBarVisibility.shared.isHidden = false }
    }
}
