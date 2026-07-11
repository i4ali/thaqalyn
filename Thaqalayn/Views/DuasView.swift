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
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDua: DailyDua?

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    if themeManager.isMidnightEmerald { emeraldHeaderView } else { headerView }

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
                            .environment(\.layoutDirection,
                                         languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(localizedTitle)
                        .font(.system(size: 34,
                                      weight: .bold,
                                      design: .rounded))
                        .foregroundColor(themeManager.primaryText)

                    Text(localizedSubtitle)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                Spacer()
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 20)
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    private var emeraldHeaderView: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 7) {
                Text(localizedEyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(3)
                    .foregroundColor(themeManager.accentColor)
                Text(localizedTitle)
                    .font(EmType.serif(36, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(localizedSubtitle)
                    .font(.system(size: 13.5))
                    .foregroundColor(themeManager.secondaryText)
            }
            Spacer(minLength: 8)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    private var localizedEyebrow: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "الأدعية"
        case .urdu: return "دعائیں"
        default: return "Supplications"
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أدعية لكل حاجة"
        case .urdu: return "ہر حاجت کی دعا"
        default: return "Duas for Every Need"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "للصحة والحفظ والرزق وغيرها"
        case .urdu: return "صحت، حفاظت، رزق اور مزید کے لیے"
        default: return "For health, protection, sustenance & more"
        }
    }
}

struct DuaCard: View {
    let dua: DailyDua
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: dua.categoryIcon)
                Text(dua.situation(for: languageManager.selectedLanguage))
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

    private var legacyBody: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 50, height: 50)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)

                Image(systemName: dua.categoryIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(dua.situation(for: languageManager.selectedLanguage))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
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
