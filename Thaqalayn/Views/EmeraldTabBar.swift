//
//  EmeraldTabBar.swift
//  Thaqalayn
//
//  Custom floating, blurred, gold-accented tab bar for the Midnight Emerald theme.
//  Driven by the same selectedTab binding as MainTabView; adapts to the items passed in.
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
                    .foregroundColor(item.id == selection ? tm.accentBright : tm.tertiaryText)
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
                RoundedRectangle(cornerRadius: 22, style: .continuous).fill(Color(hex: "0A1512").opacity(0.72))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous).stroke(tm.strokeColor, lineWidth: 1)
            )
        )
        .shadow(color: Color.black.opacity(0.5), radius: 36, x: 0, y: 14)
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
