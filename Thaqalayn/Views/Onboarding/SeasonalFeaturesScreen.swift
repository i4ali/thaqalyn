//
//  SeasonalFeaturesScreen.swift
//  Thaqalayn
//
//  Onboarding Screen: Special Seasons. Spotlights the current season (the
//  active one, or the soonest to open) and lists the rest as a quiet
//  "year ahead", driven by the shared JourneyCatalog ordering so it always
//  agrees with the Journey hub. Replaces the old four bullet-heavy cards.
//

import SwiftUI

struct SeasonalFeaturesScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var showCards = false
    @State private var starsPulse = false

    private let gold = Color(hex: "ECD49A")

    var body: some View {
        let seasons = JourneyDescriptor.orderedByStatus()

        return VStack(spacing: 0) {
            header

            if let spotlight = seasons.first {
                SeasonSpotlightHero(descriptor: spotlight.descriptor,
                                    status: spotlight.status,
                                    isVisible: showCards)
                    .padding(.horizontal, 20)

                YearAheadSection(items: Array(seasons.dropFirst()),
                                 isVisible: showCards)
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
            }

            Spacer(minLength: 0)

            Text("Every season lives in the Journey tab -\neach opens in its blessed time")
                .onbCaption()
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 84)
                .opacity(showCards ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.6), value: showCards)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .lavender))
        .onAppear {
            isVisible = true
            starsPulse = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation { showCards = true }
            }
        }
    }

    // MARK: Header (animated moon + stars)

    private var header: some View {
        VStack(spacing: 14) {
            ZStack {
                ForEach(0..<5) { index in
                    Image(systemName: "star.fill")
                        .font(.system(size: CGFloat([10, 8, 12, 9, 11][index])))
                        .foregroundColor(.yellow.opacity(0.6))
                        .offset(x: CGFloat([-40, 35, -25, 45, -50][index]),
                                y: CGFloat([-35, -40, 30, 25, -10][index]))
                        .opacity(starsPulse ? 1.0 : 0.3)
                        .animation(.easeInOut(duration: [1.8, 2.2, 1.5, 2.0, 2.4][index])
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2), value: starsPulse)
                }

                ZStack {
                    Circle()
                        .fill(RadialGradient(colors: [gold.opacity(0.22), gold.opacity(0.05)],
                                             center: .center, startRadius: 2, endRadius: 36))
                        .overlay(Circle().stroke(gold.opacity(0.18), lineWidth: 1))
                        .frame(width: 62, height: 62)
                    Image(systemName: "moon.stars.fill")
                        .font(.system(size: 26, weight: .semibold))
                        .foregroundColor(gold)
                }
            }
            .opacity(isVisible ? 1 : 0)
            .scaleEffect(isVisible ? 1 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

            VStack(spacing: 6) {
                Text("Special Seasons")
                    .onbHeroTitle()
                    .foregroundColor(themeManager.primaryText)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                Text("A guided journey for every sacred time")
                    .onbBody()
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .opacity(isVisible ? 1 : 0)
                    .animation(.easeOut(duration: 0.6).delay(0.5), value: isVisible)
            }
        }
        .padding(.top, 34)
        .padding(.bottom, 18)
    }
}

// MARK: - Spotlight hero (the current season)

private struct SeasonSpotlightHero: View {
    @StateObject private var themeManager = ThemeManager.shared
    let descriptor: JourneyDescriptor
    let status: JourneyStatus
    let isVisible: Bool

    private let gold = Color(hex: "ECD49A")
    private var isActive: Bool { status.isActive }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            SeasonGlyph(descriptor: descriptor, pointSize: 32)
                .frame(width: 68, height: 68)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(RadialGradient(colors: [gold.opacity(0.26), gold.opacity(0.05)],
                                             center: .center, startRadius: 2, endRadius: 44))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(gold.opacity(0.3), lineWidth: 1)
                        )
                )
                .shadow(color: isActive ? gold.opacity(0.35) : .clear, radius: 18)
                .padding(.bottom, 16)

            Text(descriptor.eyebrow)
                .onbEyebrow()
                .foregroundColor(gold.opacity(0.6))

            Text(descriptor.title)
                .onbHeroTitle()
                .foregroundColor(themeManager.primaryText)
                .padding(.top, 4)
                .padding(.bottom, 13)

            statusPill

            Text(SeasonCopy.blurb(descriptor.id))
                .onbBody()
                .foregroundColor(themeManager.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(22)
        .background(heroBackground)
        .overlay(alignment: .topTrailing) {
            if !isActive {
                Text("NEXT UP")
                    .onbPill()
                    .foregroundColor(gold)
                    .padding(.horizontal, 9).padding(.vertical, 4)
                    .background(Capsule().stroke(gold.opacity(0.4), lineWidth: 1))
                    .padding(16)
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 24)
        .animation(.easeOut(duration: 0.5).delay(0.1), value: isVisible)
    }

    private var heroBackground: some View {
        RoundedRectangle(cornerRadius: 26, style: .continuous)
            .fill(Color.white.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .stroke(gold.opacity(isActive ? 0.4 : 0.12), lineWidth: 1)
            )
            .shadow(color: isActive ? gold.opacity(0.16) : .black.opacity(0.35),
                    radius: isActive ? 22 : 16, x: 0, y: 8)
    }

    @ViewBuilder private var statusPill: some View {
        switch status {
        case .active:
            HStack(spacing: 7) {
                Circle().fill(Color(hex: "0A1512")).frame(width: 7, height: 7)
                Text("Open now")
            }
            .onbPill()
            .foregroundColor(Color(hex: "0A1512"))
            .padding(.horizontal, 13).padding(.vertical, 6)
            .background(
                Capsule().fill(LinearGradient(colors: [Color(hex: "F3DFA6"), Color(hex: "E3C078")],
                                              startPoint: .top, endPoint: .bottom))
            )
        case .comingSoon:
            softPill("Coming soon · " + SeasonCopy.compactTiming(status))
        case .ended:
            softPill("Returns " + SeasonCopy.compactTiming(status))
        }
    }

    private func softPill(_ text: String) -> some View {
        Text(text)
            .onbPill()
            .foregroundColor(gold)
            .padding(.horizontal, 13).padding(.vertical, 6)
            .background(Capsule().fill(gold.opacity(0.12)))
            .overlay(Capsule().stroke(gold.opacity(0.3), lineWidth: 1))
    }
}

// MARK: - The Year Ahead (the other seasons)

private struct YearAheadSection: View {
    let items: [(descriptor: JourneyDescriptor, status: JourneyStatus)]
    let isVisible: Bool

    private let gold = Color(hex: "ECD49A")

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 12) {
                Text("The Year Ahead")
                    .onbEyebrow()
                    .foregroundColor(gold.opacity(0.55))
                Rectangle().fill(gold.opacity(0.14)).frame(height: 1)
            }
            .padding(.bottom, 4)

            ForEach(Array(items.enumerated()), id: \.element.descriptor.id) { index, item in
                YearAheadRow(descriptor: item.descriptor, status: item.status)
                if index < items.count - 1 {
                    Rectangle().fill(Color.white.opacity(0.05)).frame(height: 1)
                }
            }
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 24)
        .animation(.easeOut(duration: 0.5).delay(0.25), value: isVisible)
    }
}

private struct YearAheadRow: View {
    @StateObject private var themeManager = ThemeManager.shared
    let descriptor: JourneyDescriptor
    let status: JourneyStatus

    private let gold = Color(hex: "ECD49A")

    var body: some View {
        HStack(spacing: 13) {
            SeasonGlyph(descriptor: descriptor, pointSize: 17)
                .frame(width: 36, height: 36)
                .background(
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(gold.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 11, style: .continuous)
                                .stroke(gold.opacity(0.14), lineWidth: 1)
                        )
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(descriptor.title)
                    .onbRowTitle()
                    .foregroundColor(themeManager.primaryText)
                Text(descriptor.eyebrow)
                    .onbCaption()
                    .foregroundColor(themeManager.tertiaryText)
            }

            Spacer(minLength: 8)

            Text(SeasonCopy.compactTiming(status))
                .onbCaption()
                .fontWeight(.semibold)
                .foregroundColor(gold.opacity(0.6))
        }
        .padding(.vertical, 9)
    }
}

// MARK: - Shared glyph + copy

/// Renders a journey's icon (SF Symbol or custom template asset) tinted gold.
private struct SeasonGlyph: View {
    let descriptor: JourneyDescriptor
    let pointSize: CGFloat

    private let gold = Color(hex: "ECD49A")

    var body: some View {
        Group {
            if descriptor.iconIsCustomAsset {
                Image(descriptor.sfSymbol)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: pointSize, height: pointSize)
            } else {
                Image(systemName: descriptor.sfSymbol)
                    .font(.system(size: pointSize, weight: .semibold))
            }
        }
        .foregroundColor(gold)
    }
}

/// Onboarding copy for the seasonal spotlight. English only, matching the rest
/// of the onboarding flow; season names and status come from JourneyCatalog.
private enum SeasonCopy {
    /// One evocative line per season, keyed by JourneyDescriptor.id.
    static func blurb(_ id: String) -> String {
        switch id {
        case "ramadan":   return "Thirty days of duas, curated verses and nightly reflection."
        case "hajj":      return "The ten blessed days - amaal, Arafah and the Du'a of Imam Husayn (AS)."
        case "muharram":  return "Imam Husayn (AS) on the road to Ashura - duas, ziyarat and reflection."
        case "fatimiyya": return "Mourning az-Zahra (AS) - duas, ziyarat and remembrance."
        case "arbaeen":   return "The forty-day road to Karbala - ziyarat, duas and reflection."
        default:          return ""
        }
    }

    /// A short, friendly countdown: "Open now", "soon", "tomorrow",
    /// "in 12 days", "in 5 months", or "next year".
    static func compactTiming(_ status: JourneyStatus) -> String {
        let days: Int
        switch status {
        case .active:               return "Open now"
        case .comingSoon(let d, _): days = d
        case .ended(let d, _):      days = d
        }
        if days <= 0 { return "soon" }
        if days == 1 { return "tomorrow" }
        if days <= 45 { return "in \(days) days" }
        let months = Int((Double(days) / 30.4).rounded())
        return months >= 12 ? "next year" : "in \(months) months"
    }
}

#if DEBUG
#Preview("Live season") {
    IslamicCalendarManager.debugNowOverride = Calendar(identifier: .islamicUmmAlQura)
        .date(from: DateComponents(year: 1448, month: 1, day: 15))!
    return SeasonalFeaturesScreen()
}

#Preview("Nothing active") {
    IslamicCalendarManager.debugNowOverride = Calendar(identifier: .islamicUmmAlQura)
        .date(from: DateComponents(year: 1448, month: 7, day: 10))!
    return SeasonalFeaturesScreen()
}
#endif
