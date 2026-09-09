//
//  PaywallView.swift
//  Thaqalayn
//
//  Paywall screen for premium upgrade.
//  Design: docs/mockups/paywall-redesign-final.png - price-forward hero,
//  Understanding depth ladder, feature rows, rotating App Store reviews, pinned CTA.
//

import SwiftUI

/// What the user was reaching for when the paywall fired.
///
/// The *offer* never changes - it really is "everything, forever", and shrinking the
/// headline to "unlock this one surah" would shrink the thing they're being sold. So a
/// context only swaps the hero art and the eyebrow above the headline: the art honours
/// the specific thing they wanted, and the headline still sells the whole library.
///
/// Entries with no art of their own (a locked Understanding, the profile upgrade
/// row) pass `coverAssetName: nil` and fall back to the shrine dome.
struct PaywallContext: Identifiable {
    /// Stable identity so the paywall can be raised via `.fullScreenCover(item:)` - e.g.
    /// from `JourneyListenPresenter` when a locked "Listen" is tapped. Each reach-for-
    /// premium is its own presentation. Defaulted, so every existing `PaywallContext(...)`
    /// call site (which passes only cover + eyebrow) is unaffected.
    let id = UUID()
    /// Cover art for the hero band. nil = the default shrine dome.
    let coverAssetName: String?
    /// Small gold caps line above the headline, e.g. "Inside the Surah · Yusuf".
    let eyebrow: String

    /// Fired from inside a surah: a locked Understanding, Gems. These
    /// are the highest-volume gates in the app and have no art of their own - but a surah
    /// that happens to have an "Inside the Surah" experience lends its cover, and the rest
    /// fall back to the shrine dome. Either way the eyebrow names the exact thing the user
    /// just reached for.
    static func inSurah(_ surah: Surah, _ what: String) -> PaywallContext {
        PaywallContext(
            coverAssetName: SurahExperienceDescriptor.bySurahNumber(surah.number)?.coverAssetName,
            eyebrow: "\(surah.englishName) \u{00B7} \(what)")
    }
}

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var purchaseManager = PurchaseManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    /// The moment that sent the user here. nil = they came browsing (profile upgrade row).
    var context: PaywallContext? = nil

    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var alertTitle = ""

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    /// Drives the slow Ken Burns push on the hero art (loops for the life of the screen).
    @State private var heroDrift = false
    /// Flips true on appear to fade + rise the ladder and feature rows in a cascade.
    @State private var contentIn = false
    /// The amount the price count-up has reached; animates 0 -> real price on appear.
    @State private var shownPrice: Double = 0

    /// Which curated review is showing in the rotating review card.
    @State private var reviewIndex = 0
    /// The auto-advance loop for the review card; cancelled on disappear and
    /// restarted when a dot is tapped, so a tap doesn't fight the timer.
    @State private var reviewRotation: Task<Void, Never>?

    /// A curated App Store review shown on the paywall.
    private struct CuratedReview {
        let title: String
        let body: String
        let author: String
    }

    /// The reviews shown on the paywall, auto-rotated one at a time (see
    /// `reviewCard` / `startReviewRotation`). Bodies are from the App Store,
    /// lightly tidied - spacing, sentence casing, one trimmed aside. Swap or
    /// extend as stronger reviews land.
    private let reviews: [CuratedReview] = [
        CuratedReview(
            title: "Very well thought out and put together",
            body: "It’s a great companion app that I use daily for reading and reflection. Some of the features are quite unique like journeys, verse insights and deep dives. Amazing work, mashallah!",
            author: "SyedaRzvi"),
        CuratedReview(
            title: "Mashallah",
            body: "I love this so much! It truly is amazing. Well done, may Allah bless you and your team!",
            author: "Anonymous_rules4ever"),
    ]

    private struct LayerInfo {
        let number: Int
        let name: String
        let tagline: String
        var isGold: Bool = false
    }

    /// The four parts of a passage's Understanding, in reading order.
    private let layers: [LayerInfo] = [
        LayerInfo(number: 1, name: "Essay", tagline: "The passage told once, in order"),
        LayerInfo(number: 2, name: "Verse by verse", tagline: "Notes on the verses that need them"),
        LayerInfo(number: 3, name: "Narrations", tagline: "From the Imams, with their sources"),
        LayerInfo(number: 4, name: "Perspectives", tagline: "Where Shia and Sunni readings differ", isGold: true),
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
        .onAppear { startEntrance() }
        .onDisappear { stopReviewRotation() }
        // The product usually loads before the paywall appears, but if it lands
        // after, start (or restart) the count-up the moment the price arrives.
        .onChange(of: purchaseManager.isProductLoaded) { _, loaded in
            if loaded { startPriceCountUp() }
        }
    }

    // MARK: - Entrance motion

    private func startEntrance() {
        // A different curated review greets each open; the timer then cycles the
        // rest (a no-op under reduce motion, which leaves this one static).
        reviewIndex = Int.random(in: 0..<reviews.count)
        startReviewRotation()

        guard !reduceMotion else {
            contentIn = true
            startPriceCountUp()
            return
        }
        withAnimation(.easeOut(duration: 0.6)) { contentIn = true }
        withAnimation(.easeInOut(duration: 22).repeatForever(autoreverses: true)) { heroDrift = true }
        startPriceCountUp()
    }

    /// Counts the price up from zero on appear. Uses the store's real numeric
    /// value; the format style (currency + locale) is applied by `CountUpPrice`.
    private func startPriceCountUp() {
        guard let target = purchaseManager.getPriceComponents()?.value else { return }
        let targetValue = NSDecimalNumber(decimal: target).doubleValue
        if reduceMotion {
            shownPrice = targetValue
        } else {
            shownPrice = 0
            withAnimation(.easeOut(duration: 0.7)) { shownPrice = targetValue }
        }
    }

    // MARK: - Review rotation

    /// Auto-advances the review card on a slow cross-fade. A no-op when there's a
    /// single review or under reduce motion (which keeps the shown review static).
    /// Re-callable: it cancels any running loop first, so a dot tap can restart the
    /// countdown cleanly instead of advancing again a moment later.
    private func startReviewRotation() {
        reviewRotation?.cancel()
        guard reviews.count > 1, !reduceMotion else { return }
        reviewRotation = Task { @MainActor in
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))
                if Task.isCancelled { return }
                withAnimation(.easeInOut(duration: 0.6)) {
                    reviewIndex = (reviewIndex + 1) % reviews.count
                }
            }
        }
    }

    private func stopReviewRotation() {
        reviewRotation?.cancel()
        reviewRotation = nil
    }

    /// Jump to a tapped review and restart the countdown from full.
    private func showReview(_ index: Int) {
        withAnimation(.easeInOut(duration: 0.4)) { reviewIndex = index }
        startReviewRotation()
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

    /// Band-local text colors: the hero sits on the night-shrine art, which is
    /// dark in BOTH themes, so these are fixed to the emerald-dark palette
    /// instead of following the (possibly light) active theme.
    private enum HeroBand {
        static let ivory = Color(hex: "F1E8D6")
        static let gold = Color(hex: "ECD49A")
        static let ivorySoft = Color(hex: "F1E8D6").opacity(0.78)
        static let ivoryFaint = Color(hex: "F1E8D6").opacity(0.56)
        static let height: CGFloat = 348
    }

    private var heroSection: some View {
        ZStack(alignment: .top) {
            heroArt

            VStack(spacing: 9) {
                Text((context?.eyebrow ?? "Thaqalayn Premium").uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(3)
                    .foregroundColor(HeroBand.gold)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.horizontal, 24)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 1)

                VStack(spacing: -4) {
                    Text("Everything.")
                        .font(EmType.serif(40, .semiBold))
                        .foregroundColor(HeroBand.ivory)
                    Text("Forever.")
                        .font(EmType.serif(40, .semiBold))
                        .foregroundColor(HeroBand.gold)
                }
                .shadow(color: .black.opacity(0.45), radius: 14, x: 0, y: 2)

                anchorLine

                Spacer(minLength: 0)

                priceRow

                Text("One payment. No renewals. Yours for life.")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(HeroBand.ivorySoft)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 1)
            }
            .padding(.top, 8)
            .frame(height: HeroBand.height)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 2)
    }

    /// Behind the hero: by default the shrine of Imam Husayn at night, doves above,
    /// "Ya Husayn" flag on the dome. When the paywall was fired by a specific locked
    /// thing, it is that thing's own cover instead - the well, the olive tree, the
    /// lantern road. Bleeds past the content padding to full width and edge-fades into
    /// the background so it reads as part of the emerald night, not a pasted photo.
    private var heroArt: some View {
        Image(context?.coverAssetName ?? "PaywallHeroDome")
            .resizable()
            .scaledToFill()
            // Slow Ken Burns push - the one moment on this otherwise still screen. The
            // anchor matches the crop alignment below so the zoom grows away from the
            // headline's dark sky, never up into it. Disabled under reduce-motion.
            .scaleEffect(reduceMotion ? 1 : (heroDrift ? 1.09 : 1.0),
                         anchor: context?.coverAssetName == nil ? .center : .top)
            // The experience covers are 4:5 and overflow this wide band a long way, so
            // a centred crop would ride the bright subject (a lit arch, a lantern) up
            // under the 40pt headline. Top-aligning keeps the headline on the cover's
            // dark sky, which is precisely what the covers are composed for. The dome
            // art nearly fills the band as-is, so it keeps its original centred crop.
            .frame(height: HeroBand.height,
                   alignment: context?.coverAssetName == nil ? .center : .top)
            .frame(maxWidth: .infinity)
            .clipped()
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.72), location: 0),
                        .init(color: .black, location: 0.12),
                        .init(color: .black, location: 0.55),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .padding(.horizontal, -20)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    /// Value anchor: comparable "deep" libraries are yearly subscriptions,
    /// which frames our one-time purchase as the better deal. Carries no
    /// currency figure by design - the real, localized price sits just below
    /// via `getPriceComponents()`, and any hardcoded comparison amount read
    /// wrong on non-USD stores (a fixed "$39.99" against a localized price).
    private var anchorLine: some View {
        (
            Text("Libraries this deep charge every year. ")
                .foregroundColor(HeroBand.ivorySoft)
            + Text("Yours is a single payment.")
                .fontWeight(.semibold)
                .foregroundColor(HeroBand.ivory)
        )
        .font(.system(size: 13.5, weight: .medium))
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
        .shadow(color: .black.opacity(0.5), radius: 8, x: 0, y: 1)
    }

    private var priceRow: some View {
        HStack(alignment: .firstTextBaseline, spacing: 9) {
            if let comps = purchaseManager.getPriceComponents() {
                CountUpPrice(amount: shownPrice, format: comps.format,
                             font: EmType.serif(38, .semiBold), color: HeroBand.gold)
            } else {
                ProgressView()
                    .tint(HeroBand.gold)
            }
            Text("ONE-TIME")
                .font(.system(size: 12, weight: .bold)).tracking(2)
                .foregroundColor(HeroBand.gold)
        }
        .padding(.top, 2)
        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 2)
    }

    // MARK: - Understanding depth ladder

    private var layersSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                featureIconChip("square.stack.3d.up.fill")
                VStack(alignment: .leading, spacing: 2) {
                    Text("Understanding")
                        .font(EmType.serif(21, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text("Every passage, written from its sources")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
            }

            EmCard(cornerRadius: 16) {
                VStack(spacing: 0) {
                    ForEach(Array(layers.enumerated()), id: \.element.number) { i, layer in
                        staggeredRow(i, ladderRow(layer))
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
        // Indices continue past the ladder rows so the whole page reads as one
        // cascade from the top rather than two sections starting at once.
        VStack(spacing: 10) {
            staggeredRow(layers.count + 0, featureRow(
                icon: "sparkles",
                title: "Gems",
                pill: "MOST LOVED",
                description: "Bite-size insights for every verse",
                featured: true,
                animatedIcon: true
            ))
            staggeredRow(layers.count + 1, featureRow(
                icon: "book.closed.fill",
                title: "Inside the Surah",
                pill: "IMMERSIVE",
                description: "A whole surah, walked through beat by beat"
            ))
            staggeredRow(layers.count + 2, featureRow(
                icon: "water.waves",
                title: "Deep Dives",
                pill: nil,
                description: "A single-sitting descent through one sacred theme"
            ))
            staggeredRow(layers.count + 3, featureRow(
                icon: "moon.stars.fill",
                title: "Seasonal Journeys",
                pill: journeysPill,
                description: "Muharram · Arbaeen · Ramadan · Hajj · Fatimiyya"
            ))
        }
    }

    private func featureRow(icon: String, title: String, pill: String?,
                            description: String, featured: Bool = false,
                            animatedIcon: Bool = false) -> some View {
        HStack(spacing: 12) {
            featureIconChip(icon, animated: animatedIcon)

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

    private func featureIconChip(_ sfSymbol: String, animated: Bool = false) -> some View {
        Image(systemName: sfSymbol)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(themeManager.accentColor)
            // A living shimmer on the most-loved feature's glyph - the app's first use
            // of symbolEffect. Only the flagged chip animates; the rest pass it inert.
            .symbolEffect(.variableColor.iterative, options: .repeating, isActive: animated && !reduceMotion)
            .frame(width: 30, height: 30)
            .background(RoundedRectangle(cornerRadius: 9, style: .continuous).fill(themeManager.accentChip))
            .overlay(RoundedRectangle(cornerRadius: 9, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
    }

    /// Fade + rise entrance for a row, staggered by its position in the page.
    /// No-op under reduce motion (rows appear in place, fully visible).
    private func staggeredRow<V: View>(_ index: Int, _ view: V) -> some View {
        view
            .opacity(contentIn || reduceMotion ? 1 : 0)
            .offset(y: contentIn || reduceMotion ? 0 : 14)
            .animation(reduceMotion ? nil : .easeOut(duration: 0.5).delay(Double(index) * 0.05), value: contentIn)
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
        VStack(spacing: 10) {
            EmCard(cornerRadius: 16) {
                VStack(spacing: 8) {
                    reviewStars

                    // Every review is stacked and cross-faded in place; the ZStack
                    // sizes to the tallest, so rotating never reflows the page.
                    ZStack(alignment: .top) {
                        ForEach(reviews.indices, id: \.self) { i in
                            reviewText(reviews[i])
                                .opacity(i == reviewIndex ? 1 : 0)
                                .accessibilityHidden(i != reviewIndex)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 13)
                .frame(maxWidth: .infinity)
            }

            if reviews.count > 1 {
                reviewDots
            }
        }
    }

    private var reviewStars: some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.system(size: 11))
                    .foregroundColor(themeManager.semanticYellow)
            }
        }
    }

    private func reviewText(_ review: CuratedReview) -> some View {
        VStack(spacing: 5) {
            Text("“\(review.title)”")
                .font(EmType.serif(19, .semiBold))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("“\(review.body)”")
                .font(EmType.serifItalic(16))
                .foregroundColor(themeManager.primaryText) // hero testimonial - thin italic serif needs full contrast, not secondary
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            Text("\(review.author) · App Store review")
                .font(.system(size: 10.5, weight: .medium)).tracking(0.3)
                .foregroundColor(themeManager.secondaryText)
                .padding(.top, 3)
        }
        .frame(maxWidth: .infinity)
    }

    /// Tappable progress dots under the review card. The active dot wears the
    /// accent; tapping one jumps to that review and restarts the rotation.
    private var reviewDots: some View {
        HStack(spacing: 2) {
            ForEach(reviews.indices, id: \.self) { i in
                Button {
                    showReview(i)
                } label: {
                    Circle()
                        .fill(i == reviewIndex
                              ? AnyShapeStyle(themeManager.accentColor)
                              : AnyShapeStyle(themeManager.tertiaryText.opacity(0.35)))
                        .frame(width: 6.5, height: 6.5)
                        .frame(width: 18, height: 18)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Review \(i + 1) of \(reviews.count)")
                .accessibilityAddTraits(i == reviewIndex ? [.isSelected] : [])
            }
        }
        .animation(.easeInOut(duration: 0.3), value: reviewIndex)
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
                    alertMessage = "Premium unlocked! Understanding is open for every passage."
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

// MARK: - Count-up price

/// A currency amount that animates its value. Conforms to `Animatable` so SwiftUI
/// interpolates `amount` across a `withAnimation` transaction, re-rendering the
/// formatted price at each step - a count-up from zero to the real price. Formatted
/// with the store's own currency style, so it is correct in every locale (no
/// hardcoded symbol).
private struct CountUpPrice: View, Animatable {
    var amount: Double
    let format: Decimal.FormatStyle.Currency
    let font: Font
    let color: Color

    var animatableData: Double {
        get { amount }
        set { amount = newValue }
    }

    var body: some View {
        Text(Decimal(amount).formatted(format))
            .font(font)
            .foregroundColor(color)
            .monospacedDigit()
    }
}

// MARK: - Preview

#Preview {
    PaywallView()
}
