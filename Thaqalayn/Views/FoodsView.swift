//
//  FoodsView.swift
//  Thaqalayn
//
//  "Foods of the Quran" — foods the Qur'an names as nourishment, paired with
//  Ahlul Bayt narrations. List of foods → FoodDetailView.
//

import SwiftUI

struct FoodsView: View {
    @StateObject private var foodsManager = FoodsManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showPaywall = false

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    header

                    if foodsManager.isLoading {
                        loadingSection
                    } else if let error = foodsManager.errorMessage {
                        ErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(foodsManager.foods.enumerated()), id: \.element.id) { index, food in
                                    let isLocked = !premiumManager.canAccessExploreItem(isFirst: index == 0)
                                    if isLocked {
                                        Button { showPaywall = true } label: {
                                            FoodCard(food: food, isLocked: true)
                                        }
                                        .buttonStyle(EmPressStyle())
                                    } else {
                                        PressableNavLink {
                                            FoodDetailView(food: food)
                                        } label: {
                                            FoodCard(food: food, isLocked: false)
                                        }
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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: themeManager.isMidnightEmerald ? 7 : 4) {
                if themeManager.isMidnightEmerald {
                    Text(localizedEyebrow.uppercased())
                        .font(.system(size: 11, weight: .bold)).tracking(3)
                        .foregroundColor(themeManager.accentColor)
                }
                Text(localizedTitle)
                    .font(themeManager.isMidnightEmerald ? EmType.serif(34, .semiBold) : .system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(localizedSubtitle)
                    .font(.system(size: themeManager.isMidnightEmerald ? 13.5 : 16, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 18)
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    // MARK: - Localized header strings (follow the global app language)

    private var localizedEyebrow: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "غذاء"
        case .urdu:   return "غذائیت"
        default:      return "Nourishment"
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أطعمة القرآن"
        case .urdu:   return "قرآن کی غذائیں"
        default:      return "Foods of the Quran"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "غذاءٌ من القرآن وأهل البيت (ع)"
        case .urdu:   return "قرآن اور اہلِ بیت سے غذا"
        default:      return "Nourishment from Qur'an & Ahlul Bayt"
        }
    }

    private var loadingSection: some View {
        VStack(spacing: 16) {
            ProgressView().scaleEffect(1.2).tint(themeManager.accentColor)
            Text("Loading foods…")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

struct FoodCard: View {
    let food: Food
    let isLocked: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    // Emoji-in-glass-chip placeholder (Phase 2 swaps to Image(food.illustrationAsset)).
    private var chip: some View {
        ZStack {
            Circle()
                .fill(themeManager.accentChip)
                .frame(width: 52, height: 52)
                .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            Text(food.emoji).font(.system(size: 26))
        }
    }

    private var emeraldBody: some View {
        EmCard {
            HStack(spacing: 14) {
                chip
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(food.name(for: languageManager.selectedLanguage))
                            .font(EmType.serif(20, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(1)
                        if isLocked {
                            Text("PREMIUM")
                                .font(.system(size: 8.5, weight: .bold)).tracking(1)
                                .foregroundColor(themeManager.accentColor)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(themeManager.accentChip))
                                .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                        }
                    }
                    Text("QUR'AN \(food.surahNumber):\(food.verseNumber)")
                        .font(.system(size: 11, weight: .bold)).tracking(1)
                        .foregroundColor(themeManager.accentColor)
                }
                Spacer(minLength: 8)
                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(14)
        }
        .contentShape(Rectangle())
    }

    private var legacyBody: some View {
        HStack(spacing: 16) {
            chip
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(food.name(for: languageManager.selectedLanguage))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    if isLocked {
                        Text("Premium")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.orange.gradient))
                    }
                }
                Text("Quran \(food.surahNumber):\(food.verseNumber)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
            Spacer()
            Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(themeManager.strokeColor, lineWidth: 1))
        )
        .contentShape(Rectangle())
    }
}

#Preview {
    FoodsView()
}
