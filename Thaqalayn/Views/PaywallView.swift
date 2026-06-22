//
//  PaywallView.swift
//  Thaqalayn
//
//  Paywall screen for premium upgrade.
//  Design: docs/mockups/paywall-redesign-final.png — price-forward hero,
//  5-layer depth ladder, feature rows, real App Store review, pinned CTA.
//

import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    /// The one curated App Store review shown on the paywall. Swap when a
    /// stronger review lands — body stays verbatim (spacing tidied only).
    private enum CuratedReview {
        static let title = "What I needed"
        static let body = "That’s the App I was searching for. Quran (reading, listening, traduction), quiz, daily reminder, Tafsir."
        static let author = "BiBiGeRm"
    }

    private struct LayerInfo {
        let number: Int
        let name: String
        let tagline: String
        var isGold: Bool = false
    }

    private let layers: [LayerInfo] = [
        LayerInfo(number: 1, name: "Foundation", tagline: "Historical context & basics"),
        LayerInfo(number: 2, name: "Classical Shia", tagline: "Tabatabai & Tabrisi"),
        LayerInfo(number: 3, name: "Contemporary", tagline: "Modern perspectives"),
        LayerInfo(number: 4, name: "Ahlul Bayt", tagline: "Wisdom of the Infallibles"),
        LayerInfo(number: 5, name: "Comparative", tagline: "Shia & Sunni, side by side", isGold: true),
    ]

    var body: some View {
        ZStack {
            background

            VStack(spacing: 0) {
                closeRow

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        heroSection
                        layersSection
                        featureRows
                        reviewCard
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 2)
                    .padding(.bottom, 10)
                }
                .safeAreaInset(edge: .bottom) { ctaBar }
            }
        }
        .darkScreenAura(glowOpacity: 0.40, starCount: 18)
        .alert(alertTitle, isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    // MARK: - Background

    @ViewBuilder
    private var background: some View {
        if themeManager.isMidnightEmerald {
            EmeraldBackground()
        } else {
            themeManager.primaryBackground.ignoresSafeArea()
        }
    }

    // MARK: - Close

    private var closeRow: some View {
        HStack {
            Spacer()
            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 34, height: 34)
                    .background(Circle().fill(themeManager.accentChip))
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                    .opacity(0.75)
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Close")
            .padding(.horizontal, 20)
            .padding(.top, 8)
        }
    }

    // MARK: - Hero

    private var heroSection: some View {
        VStack(spacing: 9) {
            Text("THAQALAYN PREMIUM")
                .font(.system(size: 11, weight: .bold)).tracking(3)
                .foregroundColor(themeManager.accentColor)

            VStack(spacing: -4) {
                Text("Everything.")
                    .font(EmType.serif(40, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                Text("Forever.")
                    .font(EmType.serif(40, .semiBold))
                    .foregroundColor(themeManager.accentBright)
            }

            priceChip

            Text("One payment. No renewals. Your daily companion, for life.")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    private var priceChip: some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            if let price = purchaseManager.getProductPrice() {
                Text(price)
                    .font(EmType.serif(30, .semiBold))
                    .foregroundColor(themeManager.accentBright)
            } else {
                ProgressView()
                    .tint(themeManager.accentColor)
            }
            Text("ONE-TIME")
                .font(.system(size: 11, weight: .bold)).tracking(2)
                .foregroundColor(themeManager.accentColor)
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
        .background(Capsule().fill(themeManager.accentChip))
        .overlay(Capsule().stroke(themeManager.strokeColorStrong, lineWidth: 1))
        .padding(.top, 2)
    }

    // MARK: - 5 Layers depth ladder

    private var layersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                featureIconChip("square.stack.3d.up.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("5 Layers of Tafsir")
                        .font(EmType.serif(21, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text("All 114 surahs · English, Urdu & Arabic")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
            }

            EmCard(cornerRadius: 16) {
                VStack(spacing: 0) {
                    ForEach(layers, id: \.number) { layer in
                        ladderRow(layer)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
            }
        }
    }

    private func ladderRow(_ layer: LayerInfo) -> some View {
        HStack(alignment: layer.isGold ? .top : .center, spacing: 10) {
            Text("\(layer.number)")
                .font(.system(size: 10, weight: .heavy))
                .foregroundColor(layer.isGold ? themeManager.onAccentText : themeManager.accentColor)
                .frame(width: 20, height: 20)
                .background(
                    Circle().fill(layer.isGold
                                  ? AnyShapeStyle(themeManager.accentGradient)
                                  : AnyShapeStyle(themeManager.accentChip))
                )
                .overlay(
                    Circle().stroke(layer.isGold ? Color.clear : themeManager.strokeColorStrong, lineWidth: 1)
                )

            if layer.isGold {
                // Two lines so the tagline keeps full size next to the pill.
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 7) {
                        Text(layer.name)
                            .font(.system(size: 13.5, weight: .bold))
                            .foregroundColor(themeManager.accentBright)
                            .lineLimit(1)
                        Spacer(minLength: 4)
                        goldPill("EXCLUSIVE")
                    }
                    Text(layer.tagline)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                Text(layer.name)
                    .font(.system(size: 13.5, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
                    .layoutPriority(1)

                Text(layer.tagline)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 4)
            }
        }
        .padding(.vertical, 6)
    }

    // MARK: - Feature rows

    private var featureRows: some View {
        VStack(spacing: 10) {
            featureRow(
                icon: "sparkles",
                title: "Gems",
                pill: "MOST LOVED",
                description: "Bite-size insights for every verse",
                featured: true
            )
            featureRow(
                icon: "moon.stars.fill",
                title: "Seasonal Journeys",
                pill: journeysPill,
                description: "Muharram · Ramadan · Hajj · Fatimiyya"
            )
            featureRow(
                icon: "brain.head.profile",
                title: "Surah Quizzes",
                pill: nil,
                description: "Test your understanding, earn badges"
            )
            featureRow(
                icon: "calendar.badge.checkmark",
                title: "Daily Challenge",
                pill: nil,
                description: "A new quiz, flashcard or puzzle daily — build a streak"
            )
            featureRow(
                icon: "square.grid.3x3.fill",
                title: "Daily Crossword",
                pill: nil,
                description: "Every clue teaches you something real — learn your deen, not just pass time"
            )
            featureRow(
                icon: "speaker.wave.2.fill",
                title: "Listen Mode",
                pill: nil,
                description: "Commentary read aloud, word by word"
            )
        }
    }

    private func featureRow(icon: String, title: String, pill: String?,
                            description: String, featured: Bool = false) -> some View {
        HStack(spacing: 12) {
            featureIconChip(icon)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 7) {
                    Text(title)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(1)
                        .layoutPriority(1)
                    if let pill {
                        goldPill(pill)
                    }
                }
                Text(description)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                    .minimumScaleFactor(0.85)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 11)
        .background(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(featured ? AnyShapeStyle(themeManager.accentChip) : AnyShapeStyle(themeManager.glassSurface))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .stroke(featured ? themeManager.strokeColorStrong : themeManager.strokeColor, lineWidth: 1)
        )
    }

    private func featureIconChip(_ sfSymbol: String) -> some View {
        Image(systemName: sfSymbol)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(themeManager.accentColor)
            .frame(width: 30, height: 30)
            .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(themeManager.accentChip))
            .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
    }

    private func goldPill(_ label: String) -> some View {
        Text(label)
            .font(.system(size: 8.5, weight: .heavy)).tracking(1)
            .foregroundColor(themeManager.onAccentText)
            .padding(.horizontal, 7)
            .padding(.vertical, 2.5)
            .background(Capsule().fill(themeManager.accentGradient))
            .lineLimit(1)
            .fixedSize()
    }

    /// Dynamic Journeys pill — same source of truth as the Journey hub
    /// (`JourneyDescriptor.status`), so it always names the active or
    /// soonest-upcoming journey and updates with the Islamic calendar.
    private var journeysPill: String? {
        let cal = IslamicCalendarManager.shared
        let items = JourneyDescriptor.all.map { ($0, $0.status(using: cal)) }

        if let (descriptor, _) = items.first(where: { $0.1.isActive }) {
            let title = descriptor.title.uppercased()
            switch descriptor.id {
            case "ramadan":
                if let day = cal.currentRamadanDay() { return "\(title) DAY \(day)" }
                if cal.daysUntilRamadan() != nil { return "\(title) SOON" }
                return "\(title) NOW"
            case "hajj":
                if let day = cal.currentHajjDay() { return "\(title) DAY \(day)" }
                if cal.daysUntilHajj() != nil { return "\(title) SOON" }
                return "\(title) NOW"
            case "muharram":
                if let day = cal.currentMuharramDay() { return "\(title) DAY \(day)" }
                if cal.daysUntilMuharram() != nil { return "\(title) SOON" }
                return "\(title) NOW"
            default:
                return "\(title) NOW"
            }
        }

        let upcoming: [(JourneyDescriptor, Int)] = items.compactMap { descriptor, status in
            switch status {
            case .comingSoon(let days, _), .ended(let days, _):
                return (descriptor, days)
            case .active:
                return nil
            }
        }
        guard let (descriptor, days) = upcoming.min(by: { $0.1 < $1.1 }) else { return nil }
        let title = descriptor.title.uppercased()
        return days <= 45 ? "\(title) SOON" : "NEXT: \(title)"
    }

    // MARK: - Review card

    private var reviewCard: some View {
        EmCard(cornerRadius: 16) {
            VStack(spacing: 5) {
                HStack(spacing: 3) {
                    ForEach(0..<5, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 11))
                            .foregroundColor(themeManager.semanticYellow)
                    }
                }

                Text("“\(CuratedReview.title)”")
                    .font(EmType.serif(19, .semiBold))
                    .foregroundColor(themeManager.primaryText)

                Text("“\(CuratedReview.body)”")
                    .font(EmType.serifItalic(15))
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)

                Text("\(CuratedReview.author) · App Store review")
                    .font(.system(size: 10.5, weight: .medium)).tracking(0.3)
                    .foregroundColor(themeManager.tertiaryText)
                    .padding(.top, 3)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Pinned CTA bar

    private var ctaBar: some View {
        VStack(spacing: 10) {
            HStack(spacing: 14) {
                trustItem("Family Sharing")
                trustItem("Works offline")
                trustItem("No ads, ever")
            }

            purchaseButton

            HStack(spacing: 6) {
                Text("One-time · yours for life")
                    .font(.system(size: 11.5, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
                Text("·")
                    .foregroundColor(themeManager.tertiaryText)
                Button(action: restore) {
                    Text("Restore")
                        .font(.system(size: 11.5, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                }
                .disabled(purchaseManager.isLoading)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 6)
        .background(
            LinearGradient(
                stops: [
                    .init(color: themeManager.primaryBackground.opacity(0), location: 0),
                    .init(color: themeManager.primaryBackground.opacity(0.96), location: 0.22),
                    .init(color: themeManager.primaryBackground, location: 0.5)
                ],
                startPoint: .top, endPoint: .bottom
            )
            .padding(.top, -14)
            .ignoresSafeArea(edges: .bottom)
        )
    }

    private func trustItem(_ label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark")
                .font(.system(size: 8.5, weight: .bold))
                .foregroundColor(themeManager.semanticGreen)
            Text(label)
                .font(.system(size: 10.5, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
    }

    private var purchaseButton: some View {
        Button(action: purchase) {
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
    }

    // MARK: - Actions

    private func purchase() {
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
    }

    private func restore() {
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
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}
