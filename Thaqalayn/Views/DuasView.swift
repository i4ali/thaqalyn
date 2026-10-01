//
//  DuasView.swift
//  Thaqalayn
//
//  Daily duas list — short hadith-based supplications for everyday occasions.
//

import SwiftUI

struct DuasView: View {
    @StateObject private var duasManager = DuasManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDua: DailyDua?

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    headerView

                    if duasManager.isLoading {
                        DuasLoadingSection()
                    } else if let error = duasManager.errorMessage {
                        ErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(duasManager.duas, id: \.id) { dua in
                                    PressableNavLink {
                                        DuaDetailView(dua: dua)
                                    } label: {
                                        DuaCard(dua: dua)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
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
    }

    private var headerView: some View {
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
        .emCoverHeaderBand("DailyDuasCover", height: 280)
    }

    private let headerEyebrow = "Supplications"
    private let headerTitle = "Duas for Every Need"
    private let headerSubtitle = "For health, protection, sustenance & more"
}

struct DuaCard: View {
    let dua: DailyDua
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: dua.categoryIcon)
                Text(dua.situationEn)
                    .font(EmType.serif(20, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(14)
        }
        .contentShape(Rectangle())
    }
}

private struct DuasLoadingSection: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(themeManager.accentColor)

            Text("Loading duas...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    DuasView()
}
