//
//  DuasZiyaratView.swift
//  Thaqalayn
//
//  The "Duas & Ziyarat" library — the major, most-recited Shia supplications
//  (Kumayl, Ziyarat Ashura, Tawassul, Nudba, al-Ahd), each a full segmented text
//  with a streamed recitation. Sits parallel to the short everyday Daily Duas.
//  Flat list ordered by popularity (JSON order).
//

import SwiftUI

struct DuasZiyaratView: View {
    @StateObject private var manager = SpecialDuasManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var stream = DuaStreamPlayer.shared
    @Environment(\.dismiss) private var dismiss

    /// The dua re-opened from the docked mini-player (programmatic push).
    @State private var reopenedDua: SpecialDua?

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    if themeManager.isMidnightEmerald { emeraldHeaderView } else { headerView }

                    if manager.isLoading {
                        Spacer()
                        ProgressView().tint(themeManager.accentColor)
                        Spacer()
                    } else if let error = manager.errorMessage {
                        ErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(manager.duas) { dua in
                                    PressableNavLink {
                                        SpecialDuaDetailView(dua: dua)
                                    } label: {
                                        SpecialDuaCard(dua: dua)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            // Keep the last card reachable above the docked mini-player.
                            .padding(.bottom, stream.currentDua != nil ? 96 : 20)
                        }
                    }
                }

                // Docked mini-player for the recitation still playing after the reader
                // navigated back to this list. Tapping it re-pushes the dua's reader.
                if stream.currentDua != nil {
                    VStack {
                        Spacer()
                        DuaMiniPlayer { reopenedDua = stream.currentDua }
                            .padding(.bottom, 10)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.38, dampingFraction: 0.86), value: stream.currentDua?.id)
            .background(
                NavigationLink(
                    isActive: Binding(
                        get: { reopenedDua != nil },
                        set: { if !$0 { reopenedDua = nil } }
                    )
                ) {
                    if let dua = reopenedDua { SpecialDuaDetailView(dua: dua) }
                } label: { EmptyView() }
                .hidden()
                .accessibilityHidden(true)
            )
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.isMidnightEmerald ? .hidden : .automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura()
    }

    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(headerTitle)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)
                Text(headerSubtitle)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
    }

    private var emeraldHeaderView: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text(headerEyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(3)
                    .foregroundColor(themeManager.accentColor)
                Text(headerTitle)
                    .font(EmType.serif(36, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(headerSubtitle)
                    .font(.system(size: 13.5))
                    .foregroundColor(themeManager.secondaryText)
            }
            Spacer(minLength: 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .emCoverHeaderBand("DuasZiyaratCover", height: 280)
    }

    private let headerEyebrow = "Supplications"
    private let headerTitle = "Duas & Ziyarat"
    private let headerSubtitle = "The great supplications, with recitation"
}

/// Symbol for each dua in the library.
enum SpecialDuaIcon {
    static func symbol(for id: String) -> String {
        switch id {
        case "kumayl":   return "moon.stars.fill"
        case "ashura":   return "drop.fill"
        case "tawassul": return "hands.sparkles.fill"
        case "nudba":    return "sunrise.fill"
        case "ahad":     return "hand.raised.fill"
        case "faraj":    return "sparkles"
        default:          return "text.book.closed.fill"
        }
    }
}

struct SpecialDuaCard: View {
    let dua: SpecialDua
    @StateObject private var themeManager = ThemeManager.shared

    private var icon: String { SpecialDuaIcon.symbol(for: dua.id) }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: icon)
                VStack(alignment: .leading, spacing: 3) {
                    Text(dua.titleEn)
                        .font(EmType.serif(20, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(1)
                    Text(dua.whenEn)
                        .font(.system(size: 12.5))
                        .foregroundColor(themeManager.tertiaryText)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(14)
        }
        .contentShape(Rectangle())
    }

    private var legacyBody: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 50, height: 50)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dua.titleEn)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
                Text(dua.whenEn)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(1)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                    radius: 12, x: 0, y: 4
                )
        }
        .contentShape(Rectangle())
    }
}

#Preview {
    DuasZiyaratView()
}
