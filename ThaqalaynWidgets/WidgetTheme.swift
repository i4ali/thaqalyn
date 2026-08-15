//
//  WidgetTheme.swift
//  ThaqalaynWidgets
//
//  The Midnight Emerald palette, hardcoded. The widget process cannot (and
//  must not) observe app state, so it does not import ThemeManager; the widget
//  always renders in the house look regardless of the in-app theme choice.
//

import SwiftUI

enum WidgetTheme {
    // #14332A -> #0A1D18 at ~155 degrees
    static let background = LinearGradient(
        colors: [Color(red: 0.078, green: 0.200, blue: 0.165),
                 Color(red: 0.039, green: 0.114, blue: 0.094)],
        startPoint: UnitPoint(x: 0.29, y: 0.05),
        endPoint: UnitPoint(x: 0.71, y: 0.95))

    static let text = Color(red: 0.925, green: 0.898, blue: 0.827)     // #ECE5D3
    static let dim = Color(red: 0.604, green: 0.659, blue: 0.588)      // #9AA896
    static let gold = Color(red: 0.812, green: 0.663, blue: 0.416)     // #CFA96A
    static let goldDim = gold.opacity(0.16)
}

/// Mono-caps capsule chip: the gem title, "Go deeper", "Prayer time".
struct WidgetChip: View {
    let text: String

    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 9, weight: .semibold, design: .monospaced))
            .tracking(1.4)
            .lineLimit(1)
            .foregroundColor(WidgetTheme.gold)
            .padding(.horizontal, 7)
            .padding(.vertical, 3)
            .background(Capsule().fill(WidgetTheme.goldDim))
            .overlay(Capsule().stroke(WidgetTheme.gold.opacity(0.3), lineWidth: 1))
    }
}
