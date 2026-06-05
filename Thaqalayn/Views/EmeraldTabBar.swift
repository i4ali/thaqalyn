//
//  EmeraldTabBar.swift
//  Thaqalayn
//
//  Custom floating, blurred tab bar used in BOTH themes — a light "card" in Light,
//  emerald-black & gold in Midnight Emerald. Replaces the native UITabBar (which
//  MainTabView hides in both themes, because iOS 26's Liquid-Glass bar renders nearly
//  invisibly over the light background). Driven by the same selectedTab binding;
//  adapts to the items passed in.
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

    // Selected icon/label tint: bright gold glow in dark, the purple accent in Light.
    private var selectedColor: Color {
        tm.isMidnightEmerald ? tm.accentBright : tm.accentColor
    }

    // Tint layered over .ultraThinMaterial to form the card: deep emerald-black in
    // dark, frosted translucent white in Light (so it reads as a floating glass bar,
    // distinct from the opaque white content cards behind it).
    private var cardTint: Color {
        tm.isMidnightEmerald ? Color(hex: "0A1512").opacity(0.72) : Color.white.opacity(0.6)
    }

    // Inactive icon/label tint: faint cream in dark; a deeper warm grey in Light so the
    // tabs stay legible on the frosted bar (the pale tertiary grey washed out).
    private var inactiveColor: Color {
        tm.isMidnightEmerald ? tm.tertiaryText : tm.secondaryText
    }

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
                            .font(.system(size: 10, weight: .semibold))
                            .tracking(0.4)
                            .lineLimit(1)
                        Circle()
                            .fill(item.id == selection ? tm.accentColor : Color.clear)
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
        .shadow(color: tm.isMidnightEmerald ? Color.black.opacity(0.5) : Color.black.opacity(0.15),
                radius: tm.isMidnightEmerald ? 36 : 24, x: 0, y: tm.isMidnightEmerald ? 14 : 10)
        .padding(.horizontal, 18)
        .padding(.bottom, 30)
    }
}

#if DEBUG
#Preview {
    let _ = (ThemeManager.shared.selectedTheme = .nightSanctuary)
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
