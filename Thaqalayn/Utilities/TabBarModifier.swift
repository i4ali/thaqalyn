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
    @Published private(set) var isHidden = false

    /// The screens currently asking for the bar to be hidden. Pushed screens
    /// overlap: a child's onAppear fires before its parent's onDisappear, so a
    /// single flag flips back to visible one step into a nested push (surah,
    /// passage, understanding). The bar stays hidden while any screen asks.
    private var hiders = Set<UUID>()

    private init() {}

    func hide(_ token: UUID) {
        hiders.insert(token)
        isHidden = true
    }

    func show(_ token: UUID) {
        hiders.remove(token)
        isHidden = !hiders.isEmpty
    }
}

extension View {
    /// Hides the tab bar (native + emerald floating) when applied to a view.
    func hideTabBar() -> some View {
        modifier(HideTabBarModifier())
    }
}

private struct HideTabBarModifier: ViewModifier {
    @State private var token = UUID()

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
            .onAppear { TabBarVisibility.shared.hide(token) }
            .onDisappear { TabBarVisibility.shared.show(token) }
    }
}
