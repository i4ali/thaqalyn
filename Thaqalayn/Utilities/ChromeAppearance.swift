//
//  ChromeAppearance.swift
//  Thaqalayn
//
//  Styles the UIKit-bridged navigation bar to match the theme. The colors are
//  dynamic, so the bar follows the active color scheme on its own; apply once at
//  launch. (The native tab bar is hidden; EmeraldTabBar replaces it.)
//

import SwiftUI
import UIKit

enum ChromeAppearance {
    @MainActor
    static func apply() {
        let nav = UINavigationBarAppearance()
        nav.configureWithDefaultBackground()
        var navTitleAttrs = nav.titleTextAttributes
        navTitleAttrs[.foregroundColor] = ThemePalette.uiPrimaryText
        nav.titleTextAttributes = navTitleAttrs
        var navLargeTitleAttrs = nav.largeTitleTextAttributes
        navLargeTitleAttrs[.foregroundColor] = ThemePalette.uiPrimaryText
        nav.largeTitleTextAttributes = navLargeTitleAttrs

        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = ThemePalette.uiAccent
    }
}
