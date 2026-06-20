//
//  FastingVersesView.swift
//  Thaqalayn
//
//  Fasting in the Quran - curated verses about fasting
//  organized by category with premium gating
//

import SwiftUI

struct FastingVersesView: View {
    @StateObject private var fastingManager = FastingVersesManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: FastingCategory?
    @State private var navigateToDetail = false
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    // Header
                    if themeManager.isMidnightEmerald {
                        emeraldHeaderView
                    } else {
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizedTitle)
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
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
                    .padding(.bottom, 16)
                    .environment(\.layoutDirection,
                                 languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                    }

                    // Category list
                    if fastingManager.isLoading {
                        FastingLoadingSection(message: "Loading verses...")
                    } else if let error = fastingManager.errorMessage {
                        FastingErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(fastingManager.categories) { category in
                                    FastingCategoryCard(
                                        category: category,
                                        isLocked: !premiumManager.canAccessFastingCategory(category.id)
                                    ) {
                                        if premiumManager.canAccessFastingCategory(category.id) {
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                                selectedCategory = category
                                                navigateToDetail = true
                                            }
                                        } else {
                                            showPaywall = true
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 16)
                            .environment(\.layoutDirection,
                                         languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                        }
                    }
                }

                // Hidden NavigationLink for category detail navigation
                if let category = selectedCategory {
                    NavigationLink(
                        destination: FastingCategoryDetailView(category: category),
                        isActive: $navigateToDetail
                    ) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    .hidden()
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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var emeraldHeaderView: some View {
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 18)
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    // MARK: - Localized header strings (follow the global app language)

    private var localizedEyebrow: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "رمضان في القرآن"
        case .urdu:   return "قرآن میں رمضان"
        default:      return "Ramadan in the Qur'an"
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "الصيام في القرآن"
        case .urdu:   return "قرآن میں روزہ"
        default:      return "Fasting in the Quran"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "آياتٌ عن الصيام ورمضان"
        case .urdu:   return "روزے اور رمضان سے متعلق آیات"
        default:      return "Verses about fasting and Ramadan"
        }
    }
}

struct FastingCategoryCard: View {
    let category: FastingCategory
    let isLocked: Bool
    let onTap: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    private var grayGradient: LinearGradient {
        LinearGradient(
            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        Button(action: onTap) {
            EmCard {
                HStack(spacing: 14) {
                    EmIconChip(sfSymbol: category.icon)
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(category.title(for: languageManager.selectedLanguage))
                                .font(EmType.serif(20, .semiBold))
                                .foregroundColor(themeManager.primaryText)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                            if isLocked {
                                Text("PREMIUM")
                                    .font(.system(size: 8.5, weight: .bold)).tracking(1)
                                    .foregroundColor(themeManager.accentColor)
                                    .padding(.horizontal, 6).padding(.vertical, 2)
                                    .background(Capsule().fill(themeManager.accentChip))
                                    .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                            }
                        }
                        Text(category.description(for: languageManager.selectedLanguage))
                            .font(.system(size: 13))
                            .foregroundColor(themeManager.secondaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        Text("\(category.verseCount) verse\(category.verseCount == 1 ? "" : "s")")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(themeManager.tertiaryText)
                }
                .padding(14)
            }
        }
        .buttonStyle(EmPressStyle())
        .padding(.horizontal, 20)
    }

    private var legacyBody: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 16) {
                // Category icon
                ZStack {
                    Circle()
                        .fill(isLocked ? grayGradient : themeManager.accentGradient)
                        .frame(width: 50, height: 50)
                        .shadow(
                            color: isLocked ? Color.clear : themeManager.accentColor.opacity(0.3),
                            radius: 8
                        )

                    Image(systemName: category.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(isLocked ? themeManager.secondaryText : .white)
                }

                // Category content
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(category.title(for: languageManager.selectedLanguage))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)

                        if isLocked {
                            Text("Premium")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(Color.orange.gradient)
                                )
                        }
                    }

                    Text(category.description(for: languageManager.selectedLanguage))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    // Verse count
                    Text("\(category.verseCount) verse\(category.verseCount == 1 ? "" : "s")")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }

                Spacer()

                // Chevron or lock icon
                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isLocked ? themeManager.secondaryText : themeManager.tertiaryText)
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
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 20)
    }
}

private struct FastingLoadingSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(themeManager.accentColor)

            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

private struct FastingErrorSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Error Loading Verses")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    FastingVersesView()
}
