//
//  EmeraldTabBar.swift
//  Thaqalayn
//
//  Custom floating, blurred tab bar: frosted white & gold in Sage Dawn, emerald-black
//  & gold in Midnight Emerald. Replaces the native UITabBar, which MainTabView hides.
//  Driven by the same selectedTab binding; adapts to the items passed in.
//

import SwiftUI

struct EmeraldTabItem: Identifiable {
    let id: Int          // matches MainTabView's selectedTab tag
    let label: String
    let sfSymbol: String // SF Symbol name
}

struct EmeraldTabBar: View {
    @ObservedObject private var tm = ThemeManager.shared
    let items: [EmeraldTabItem]
    @Binding var selection: Int

    // Selected icon/label tint: bright gold in dark, the deep text gold in light.
    private var selectedColor: Color { tm.accentBright }

    // Tint layered over .ultraThinMaterial to form the card: deep emerald-black in
    // dark, frosted white in light.
    private var cardTint: Color { tm.tabBarTint }

    private var inactiveColor: Color { tm.tertiaryText }

    private let labelSize: CGFloat = 10

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items) { item in
                Button {
                    selection = item.id
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: item.sfSymbol)
                            .font(.system(size: 20, weight: .regular))
                        Text(item.label)
                            .font(.system(size: labelSize, weight: .semibold))
                            .tracking(0.4)
                            .lineLimit(1)
                        Circle()
                            .fill(item.id == selection ? tm.accentOrnament : Color.clear)
                            .frame(width: 4, height: 4)
                    }
                    .foregroundColor(item.id == selection ? selectedColor : inactiveColor)
                    .frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                }
                .buttonStyle(EmPressStyle())
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 8)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(cardTint)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(tm.strokeColor, lineWidth: 1)
            )
        )
        .emShadow(.floating)
        .padding(.horizontal, 18)
        .padding(.bottom, 30)
    }
}

#if DEBUG
#Preview {
    let _ = (ThemeManager.shared.selectedTheme = .midnightEmerald)
    return ZStack {
        EmeraldBackground()
        VStack {
            Spacer()
            EmeraldTabBar(items: [
                .init(id: 0, label: "Today",    sfSymbol: "sun.max"),
                .init(id: 1, label: "Quran",    sfSymbol: "book.closed"),
                .init(id: 2, label: "Explore",  sfSymbol: "sparkles"),
                .init(id: 3, label: "Progress", sfSymbol: "chart.bar"),
            ], selection: .constant(1))
        }
    }
}
#endif
