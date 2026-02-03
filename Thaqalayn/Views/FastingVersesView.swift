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
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Fasting in the Quran")
                                    .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32, weight: .bold, design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
                                    .foregroundColor(themeManager.primaryText)

                                Text("Verses about fasting and Ramadan")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 16)
                    .background {
                        if themeManager.selectedTheme != .warmInviting {
                            Rectangle()
                                .fill(themeManager.glassEffect)
                        }
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
                                            selectedCategory = category
                                            navigateToDetail = true
                                        } else {
                                            showPaywall = true
                                        }
                                    }
                                }
                            }
                            .padding(.vertical, 16)
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
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }
}

struct FastingCategoryCard: View {
    let category: FastingCategory
    let isLocked: Bool
    let onTap: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    private var grayGradient: LinearGradient {
        LinearGradient(
            colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
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
                        Text(category.title)
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

                    Text(category.description)
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
                if themeManager.selectedTheme == .warmInviting {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                }
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
