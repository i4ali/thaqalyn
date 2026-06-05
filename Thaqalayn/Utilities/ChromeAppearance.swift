//
//  ChromeAppearance.swift
//  Thaqalayn
//
//  Configures UIKit-bridged native chrome (UITabBar, UINavigationBar)
//  to match the active SwiftUI theme.
//

import SwiftUI
import UIKit

enum ChromeAppearance {
    @MainActor
    static func apply(for variant: ThemeVariant) {
        let isDark = variant == .nightSanctuary
        let accent = UIColor(ThemeManager.shared.accentColor)

        // --- Tab bar ---
        // NB: in Midnight Emerald the native bar is HIDDEN entirely by
        // `HideNativeTabBar` (MainTabView) — the floating EmeraldTabBar replaces
        // it. This only styles the bar for the Light theme, where it's shown.
        let tab = UITabBarAppearance()
        tab.configureWithDefaultBackground()

        let inactive = isDark
            ? UIColor.white.withAlphaComponent(0.48)
            : UIColor.label.withAlphaComponent(0.6)

        // Merge into existing attributes so we don't blow away the system's default font.
        tab.stackedLayoutAppearance.selected.iconColor = accent
        var selectedTabAttrs = tab.stackedLayoutAppearance.selected.titleTextAttributes
        selectedTabAttrs[.foregroundColor] = accent
        tab.stackedLayoutAppearance.selected.titleTextAttributes = selectedTabAttrs

        tab.stackedLayoutAppearance.normal.iconColor = inactive
        var normalTabAttrs = tab.stackedLayoutAppearance.normal.titleTextAttributes
        normalTabAttrs[.foregroundColor] = inactive
        tab.stackedLayoutAppearance.normal.titleTextAttributes = normalTabAttrs

        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab

        // --- Navigation bar ---
        let nav = UINavigationBarAppearance()
        nav.configureWithDefaultBackground()
        let titleColor = isDark ? UIColor(ThemeManager.shared.primaryText) : UIColor.label
        var navTitleAttrs = nav.titleTextAttributes
        navTitleAttrs[.foregroundColor] = titleColor
        nav.titleTextAttributes = navTitleAttrs
        var navLargeTitleAttrs = nav.largeTitleTextAttributes
        navLargeTitleAttrs[.foregroundColor] = titleColor
        nav.largeTitleTextAttributes = navLargeTitleAttrs

        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = accent
    }
}
