//
//  PaywallView.swift
//  Thaqalayn
//
//  Paywall screen for premium upgrade
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldBody
            } else {
                legacyBody
            }
        }
        .darkScreenAura(glowOpacity: 0.40, starCount: 18)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private var legacyBody: some View {
        ZStack {
            // Background
            themeManager.primaryBackground
                .ignoresSafeArea()

            // Animated background orbs (matching app theme)
            ForEach(0..<3) { i in
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(
                        x: i == 0 ? -100 : (i == 1 ? 150 : 0),
                        y: i == 0 ? -150 : (i == 1 ? 300 : 500)
                    )
            }

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(themeManager.secondaryText.opacity(0.6))
                    }
                    .padding()
                }

                ScrollView {
                    VStack(spacing: 24) {
                        // Featured: Quick Gems
                        PaywallQuickGemsFeature()

                        // Hero: 5 Layers of Wisdom
                        PaywallLayersHero()

                        // Progress/Streak Teaser
                        PaywallProgressTeaser()

                        // Condensed Benefits list
                        VStack(spacing: 12) {
                            PremiumBenefitRow(
                                icon: "book.fill",
                                title: "All 114 Surahs",
                                description: "Comprehensive tafsir for the entire Quran",
                                color: .green
                            )

                            PremiumBenefitRow(
                                icon: "globe",
                                title: "Multilingual Support",
                                description: "Full commentary in English, Urdu & Arabic",
                                color: .purple
                            )

                            PremiumBenefitRow(
                                icon: "infinity.circle.fill",
                                title: "Lifetime Access",
                                description: "One-time purchase, no subscriptions",
                                color: .pink
                            )

                            PremiumBenefitRow(
                                icon: "speaker.wave.2.fill",
                                title: "Listen to Commentary",
                                description: "Text-to-speech with word highlighting",
                                color: .blue
                            )

                            PremiumBenefitRow(
                                icon: "brain.head.profile",
                                title: "Surah Quizzes",
                                description: "Interactive quizzes for every surah",
                                color: .orange
                            )
                        }
                        .padding(.horizontal)

                        // Price and purchase button
                        VStack(spacing: 16) {
                            // Price display
                            VStack(spacing: 4) {
                                Text("Only")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)

                                if let price = purchaseManager.getProductPrice() {
                                    Text(price)
                                        .font(.system(size: 48, weight: .bold))
                                        .foregroundColor(themeManager.primaryText)
                                } else {
                                    ProgressView()
                                        .frame(height: 58)
                                }

                                Text("One-time payment")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }
                            .padding(.vertical, 20)
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(themeManager.secondaryBackground.opacity(0.5))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(themeManager.accentColor.opacity(0.3), lineWidth: 1)
                                    )
                            )

                            // Purchase button
                            Button(action: {
                                Task {
                                    do {
                                        try await purchaseManager.purchase()

                                        if purchaseManager.purchaseSuccess {
                                            alertTitle = "Success!"
                                            alertMessage = "Premium unlocked! All tafsir commentary is now available."
                                            showingAlert = true

                                            // Dismiss after showing success
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                dismiss()
                                            }
                                        }
                                    } catch {
                                        alertTitle = "Purchase Failed"
                                        alertMessage = error.localizedDescription
                                        showingAlert = true
                                    }
                                }
                            }) {
                                HStack(spacing: 12) {
                                    if purchaseManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "star.fill")
                                        Text("Unlock Premium")
                                            .font(.system(size: 18, weight: .bold))
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .background(themeManager.accentGradient)
                                .cornerRadius(16)
                                .shadow(color: themeManager.accentColor.opacity(0.5), radius: 15, x: 0, y: 8)
                            }
                            .disabled(purchaseManager.isLoading || !purchaseManager.isProductLoaded)

                            // Restore purchases button
                            Button(action: {
                                Task {
                                    do {
                                        try await purchaseManager.restorePurchases()

                                        if purchaseManager.purchaseSuccess {
                                            alertTitle = "Restored!"
                                            alertMessage = "Your premium access has been restored."
                                            showingAlert = true

                                            // Dismiss after showing success
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                dismiss()
                                            }
                                        }
                                    } catch {
                                        alertTitle = "Restore Failed"
                                        alertMessage = purchaseManager.purchaseError ?? "No purchases found"
                                        showingAlert = true
                                    }
                                }
                            }) {
                                Text("Restore Purchases")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(themeManager.secondaryText)
                                    .underline()
                            }
                            .disabled(purchaseManager.isLoading)
                        }
                        .padding(.horizontal)

                        // Footer text
                        Text("Secure payment processed by Apple")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.secondaryText.opacity(0.6))
                            .padding(.bottom, 40)
                    }
                }
            }
        }
    }

    // MARK: - Emerald body

    private var emeraldBody: some View {
        ZStack {
            EmeraldBackground()

            VStack(spacing: 0) {
                // Close button (gold chip)
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 38, height: 38)
                            .background(
                                Circle().fill(themeManager.accentChip)
                            )
                            .overlay(
                                Circle().stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                    }
                    .buttonStyle(EmPressStyle())
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                }

                ScrollView {
                    VStack(spacing: 26) {
                        // Hero header
                        VStack(spacing: 10) {
                            Text("THAQALAYN PREMIUM")
                                .font(.system(size: 11, weight: .bold)).tracking(3)
                                .foregroundColor(themeManager.accentColor)
                            Text("Unlock the Full Depth")
                                .font(EmType.serif(38, .semiBold)).tracking(0.2)
                                .foregroundColor(themeManager.primaryText)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                            Text("Five layers of wisdom, Gems for every verse, and your entire spiritual journey — for life.")
                                .font(EmType.serif(18, .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 8)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 4)

                        // Featured: Gems
                        PaywallQuickGemsFeature()

                        // Hero: 5 Layers of Wisdom
                        PaywallLayersHero()

                        // Progress/Streak Teaser
                        PaywallProgressTeaser()

                        EmDivider(label: "Everything Included")

                        // Condensed Benefits list
                        VStack(spacing: 12) {
                            PremiumBenefitRow(
                                icon: "book.fill",
                                title: "All 114 Surahs",
                                description: "Comprehensive tafsir for the entire Quran",
                                color: .green
                            )

                            PremiumBenefitRow(
                                icon: "globe",
                                title: "Multilingual Support",
                                description: "Full commentary in English, Urdu & Arabic",
                                color: .purple
                            )

                            PremiumBenefitRow(
                                icon: "infinity.circle.fill",
                                title: "Lifetime Access",
                                description: "One-time purchase, no subscriptions",
                                color: .pink
                            )

                            PremiumBenefitRow(
                                icon: "speaker.wave.2.fill",
                                title: "Listen to Commentary",
                                description: "Text-to-speech with word highlighting",
                                color: .blue
                            )

                            PremiumBenefitRow(
                                icon: "brain.head.profile",
                                title: "Surah Quizzes",
                                description: "Interactive quizzes for every surah",
                                color: .orange
                            )
                        }
                        .padding(.horizontal, 20)

                        // Price and purchase
                        VStack(spacing: 16) {
                            // Price display — headline plan card
                            EmCard(glow: true) {
                                VStack(spacing: 4) {
                                    Text("ONE-TIME")
                                        .font(.system(size: 11, weight: .bold)).tracking(2.5)
                                        .foregroundColor(themeManager.accentColor)

                                    if let price = purchaseManager.getProductPrice() {
                                        Text(price)
                                            .font(EmType.serif(52, .semiBold))
                                            .foregroundColor(themeManager.accentBright)
                                    } else {
                                        ProgressView()
                                            .tint(themeManager.accentColor)
                                            .frame(height: 58)
                                    }

                                    Text("Lifetime access · no subscriptions")
                                        .font(EmType.serif(16, .medium))
                                        .foregroundColor(themeManager.secondaryText)
                                }
                                .padding(.vertical, 22)
                                .frame(maxWidth: .infinity)
                            }

                            // Purchase button
                            Button(action: {
                                Task {
                                    do {
                                        try await purchaseManager.purchase()

                                        if purchaseManager.purchaseSuccess {
                                            alertTitle = "Success!"
                                            alertMessage = "Premium unlocked! All tafsir commentary is now available."
                                            showingAlert = true

                                            // Dismiss after showing success
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                dismiss()
                                            }
                                        }
                                    } catch {
                                        alertTitle = "Purchase Failed"
                                        alertMessage = error.localizedDescription
                                        showingAlert = true
                                    }
                                }
                            }) {
                                HStack(spacing: 10) {
                                    if purchaseManager.isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: themeManager.onAccentText))
                                    } else {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("Unlock Premium")
                                            .font(.system(size: 15.5, weight: .bold)).tracking(0.3)
                                    }
                                }
                                .foregroundColor(themeManager.onAccentText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(themeManager.accentGradient))
                                .shadow(color: themeManager.accentColor.opacity(0.28), radius: 28, x: 0, y: 10)
                            }
                            .buttonStyle(EmPressStyle())
                            .disabled(purchaseManager.isLoading || !purchaseManager.isProductLoaded)

                            // Restore purchases button (subtle gold text)
                            Button(action: {
                                Task {
                                    do {
                                        try await purchaseManager.restorePurchases()

                                        if purchaseManager.purchaseSuccess {
                                            alertTitle = "Restored!"
                                            alertMessage = "Your premium access has been restored."
                                            showingAlert = true

                                            // Dismiss after showing success
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                dismiss()
                                            }
                                        }
                                    } catch {
                                        alertTitle = "Restore Failed"
                                        alertMessage = purchaseManager.purchaseError ?? "No purchases found"
                                        showingAlert = true
                                    }
                                }
                            }) {
                                Text("Restore Purchases")
                                    .font(.system(size: 14, weight: .semibold)).tracking(0.3)
                                    .foregroundColor(themeManager.accentColor)
                            }
                            .buttonStyle(EmPressStyle())
                            .disabled(purchaseManager.isLoading)
                        }
                        .padding(.horizontal, 20)

                        // Footer text
                        Text("Secure payment processed by Apple")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.tertiaryText)
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - Benefit Row Component

struct PremiumBenefitRow: View {
    @StateObject private var themeManager = ThemeManager.shared

    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard(cornerRadius: 16) {
            HStack(spacing: 14) {
                // Gold check seal
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 26))
                    .foregroundColor(themeManager.accentColor)

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(EmType.serif(20, .semiBold))
                        .foregroundColor(themeManager.primaryText)

                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 16)
        }
    }

    private var legacyBody: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(color)
            }

            // Text
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.secondaryBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Hero 5-Layers Section

struct PaywallLayersHero: View {
    @StateObject private var themeManager = ThemeManager.shared

    private let layers: [(emoji: String, title: String, tagline: String, color: Color)] = [
        ("ph-bank-fill", "Foundation", "Historical context & basics", .blue),
        ("ph-books-fill", "Classical Shia", "Tabatabai & Tabrisi", .purple),
        ("ph-globe-hemisphere-west-fill", "Contemporary", "Modern perspectives", .green),
        ("ph-star-fill", "Ahlul Bayt", "Wisdom of the Infallibles", .orange),
        ("ph-scales-fill", "Comparative", "Shia & Sunni analysis", .indigo)
    ]

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 6) {
                Text("5 Layers of Wisdom")
                    .font(EmType.serif(30, .semiBold))
                    .foregroundColor(themeManager.primaryText)

                Text("Unlock the depth of Quranic understanding")
                    .font(EmType.serif(17, .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
            }

            // Layer cards grid
            layerGrid
        }
        .padding(.horizontal, 20)
        .padding(.top, 4)
    }

    private var legacyBody: some View {
        VStack(spacing: 16) {
            // Header
            VStack(spacing: 8) {
                Text("5 Layers of Wisdom")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(themeManager.primaryText)

                Text("Unlock the depth of Quranic understanding")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
            }

            // Layer cards grid
            layerGrid
        }
        .padding(.horizontal)
        .padding(.top, 12)
    }

    private var layerGrid: some View {
        VStack(spacing: 10) {
                // First row: 2 cards
                HStack(spacing: 10) {
                    PaywallLayerCard(
                        emoji: layers[0].emoji,
                        title: layers[0].title,
                        tagline: layers[0].tagline,
                        color: layers[0].color
                    )
                    PaywallLayerCard(
                        emoji: layers[1].emoji,
                        title: layers[1].title,
                        tagline: layers[1].tagline,
                        color: layers[1].color
                    )
                }

                // Second row: 3 cards
                HStack(spacing: 10) {
                    PaywallLayerCard(
                        emoji: layers[2].emoji,
                        title: layers[2].title,
                        tagline: layers[2].tagline,
                        color: layers[2].color
                    )
                    PaywallLayerCard(
                        emoji: layers[3].emoji,
                        title: layers[3].title,
                        tagline: layers[3].tagline,
                        color: layers[3].color
                    )
                    PaywallLayerCard(
                        emoji: layers[4].emoji,
                        title: layers[4].title,
                        tagline: layers[4].tagline,
                        color: layers[4].color
                    )
                }
            }
    }
}

// MARK: - Layer Card Component


struct PaywallLayerCard: View {
    @StateObject private var themeManager = ThemeManager.shared

    let emoji: String
    let title: String
    let tagline: String
    let color: Color

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard(cornerRadius: 14) {
            VStack(spacing: 6) {
                PhosphorIcon(name: emoji, size: 24)
                    .foregroundColor(themeManager.accentColor)

                Text(title)
                    .font(EmType.serif(15, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text(tagline)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
        }
    }

    private var legacyBody: some View {
        VStack(spacing: 6) {
            PhosphorIcon(name: emoji, size: 24)
                .foregroundColor(color)

            Text(title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(themeManager.primaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(tagline)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.secondaryBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Progress/Streak Teaser Section

struct PaywallProgressTeaser: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        VStack(spacing: 12) {
            Text("Track Your Spiritual Journey")
                .font(EmType.serif(22, .semiBold))
                .foregroundColor(themeManager.primaryText)

            HStack(spacing: 12) {
                ProgressTeaserItem(icon: "flame.fill", label: "Build Streaks", color: .orange)
                ProgressTeaserItem(icon: "star.fill", label: "Earn Sawab", color: .yellow)
                ProgressTeaserItem(icon: "trophy.fill", label: "Unlock Badges", color: .purple)
            }
        }
        .padding(.horizontal, 20)
    }

    private var legacyBody: some View {
        VStack(spacing: 12) {
            Text("Track Your Spiritual Journey")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(themeManager.primaryText)

            HStack(spacing: 12) {
                ProgressTeaserItem(icon: "flame.fill", label: "Build Streaks", color: .orange)
                ProgressTeaserItem(icon: "star.fill", label: "Earn Sawab", color: .yellow)
                ProgressTeaserItem(icon: "trophy.fill", label: "Unlock Badges", color: .purple)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Progress Teaser Item

struct ProgressTeaserItem: View {
    @StateObject private var themeManager = ThemeManager.shared

    let icon: String
    let label: String
    let color: Color

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard(cornerRadius: 14) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(themeManager.accentColor)

                Text(label)
                    .font(EmType.serif(15, .semiBold))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    private var legacyBody: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 22))
                .foregroundColor(color)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.secondaryBackground.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Quick Gems Feature Card

struct PaywallQuickGemsFeature: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard(glow: true) {
            VStack(spacing: 0) {
                // Popular badge
                HStack {
                    Spacer()
                    Text("POPULAR")
                        .font(.system(size: 10, weight: .bold)).tracking(1.5)
                        .foregroundColor(themeManager.onAccentText)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(themeManager.accentGradient))
                        .offset(y: -12)
                }
                .padding(.trailing, 16)

                // Icon and content
                HStack(spacing: 16) {
                    EmIconChip(sfSymbol: "sparkles", size: 60, active: true)

                    VStack(alignment: .leading, spacing: 3) {
                        Text("Gems")
                            .font(EmType.serif(24, .semiBold))
                            .foregroundColor(themeManager.primaryText)

                        Text("Bite-size insights for every verse")
                            .font(EmType.serif(16, .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer(minLength: 8)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    private var legacyBody: some View {
        VStack(spacing: 0) {
            // Popular badge
            HStack {
                Spacer()
                Text("POPULAR")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Capsule().fill(themeManager.semanticYellow))
                    .offset(y: -12)
            }
            .padding(.trailing, 16)

            // Icon and content
            HStack(spacing: 16) {
                // Sparkles icon with glow
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 64, height: 64)

                    Image(systemName: "sparkles")
                        .font(.system(size: 28))
                        .foregroundColor(.orange)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("Gems")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(themeManager.primaryText)

                    Text("Bite-size insights for every verse")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.secondaryBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.orange.opacity(0.4), lineWidth: 2)
                )
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}
