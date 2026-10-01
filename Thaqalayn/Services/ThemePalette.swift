//
//  ThemePalette.swift
//  Thaqalayn
//
//  The app's color tokens. Every token is a dynamic color with a Sage Dawn
//  (light) value and a Midnight Emerald (dark) value, resolved from the SwiftUI
//  color scheme. The root view sets `.preferredColorScheme(themeManager.colorScheme)`,
//  so tokens follow the theme picked in Settings; a subtree forced dark (the
//  immersive Deep Dive / Journey Listen screens, onboarding, text laid over
//  dark cover art via `.environment(\.colorScheme, .dark)`) resolves the
//  Midnight values on its own.
//
//  ThemeManager forwards its color properties here; views keep reading
//  `themeManager.primaryText` etc.
//

import SwiftUI
import UIKit

// MARK: - Dynamic color

extension UIColor {
    /// A color that resolves to `dark` under a dark trait collection and to
    /// `light` otherwise.
    convenience init(light: UIColor, dark: UIColor) {
        self.init { $0.userInterfaceStyle == .dark ? dark : light }
    }
}

extension Color {
    /// A color that resolves to `dark` under a dark color scheme and to
    /// `light` otherwise.
    init(light: Color, dark: Color) {
        self.init(uiColor: UIColor(light: UIColor(light), dark: UIColor(dark)))
    }

    /// Hex string initializer: "RGB", "RRGGBB" or "AARRGGBB", with or without "#".
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    /// A data-driven concept color (`colorHex` in the Quick Overview data).
    /// The data holds five mid-tone pastels picked for the dark ground; on the
    /// light ground each resolves to a deeper shade that keeps ~4.5:1 contrast.
    /// Unknown hexes pass through unchanged in both schemes.
    static func concept(hex: String) -> Color {
        let key = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted).uppercased()
        guard let deep = conceptLightShades[key] else { return Color(hex: hex) }
        return Color(light: Color(hex: deep), dark: Color(hex: hex))
    }

    private static let conceptLightShades: [String: String] = [
        "E8B86D": "8F6E2A", // gold
        "9B8FBF": "6B5E9A", // lilac
        "E57373": "B3473F", // red
        "64B5F6": "2F6DB5", // blue
        "7BC47F": "2E7D4F", // green
    ]
}

// MARK: - Tokens

/// Every color token, as a Sage Dawn / Midnight Emerald pair. The dark values
/// are the original Midnight Emerald literals, unchanged.
enum ThemePalette {
    // Base inks
    private static let ink = Color(hex: "14261E")              // Sage Dawn text
    private static let cream = Color(hex: "F1E8D6")            // Midnight text
    private static let greenInk = Color(.sRGB, red: 20 / 255, green: 60 / 255, blue: 45 / 255)  // Sage Dawn hairlines/wells
    private static let gold = Color(hex: "D6B25E")
    private static let goldDeep = Color(hex: "B8923F")
    private static let goldBright = Color(hex: "ECD49A")

    // MARK: UIKit (native navigation bar)

    static let uiPrimaryText = UIColor(light: UIColor(ink), dark: UIColor(cream))
    static let uiAccent      = UIColor(light: UIColor(Color(hex: "8F6E2A")), dark: UIColor(gold))

    // MARK: Grounds

    static let primaryBackground   = Color(light: Color(hex: "EAF2EB"), dark: Color(hex: "0A1512"))
    static let secondaryBackground = Color(light: Color(hex: "DFEBE1"), dark: Color(hex: "081310"))
    static let tertiaryBackground  = Color(light: Color(hex: "F7FBF6"), dark: Color(hex: "0C1D16"))
    /// Radial background stops (top of the screen / far edge).
    static let bgTop    = Color(light: Color(hex: "F7FBF6"), dark: Color(hex: "0C1D16"))
    static let bgBottom = Color(light: Color(hex: "DFEBE1"), dark: Color(hex: "081310"))
    /// The soft gold glow at the top of every screen.
    static let topGlow  = Color(light: gold.opacity(0.20), dark: gold.opacity(0.14))

    // MARK: Text

    static let primaryText    = Color(uiColor: uiPrimaryText)
    static let secondaryText  = Color(light: ink.opacity(0.72), dark: cream.opacity(0.74))
    /// Captions and metadata: ~4.5:1 in both themes (light on cards; dark lifted from 0.38).
    static let tertiaryText   = Color(light: ink.opacity(0.62), dark: cream.opacity(0.52))
    static let quaternaryText = Color(light: ink.opacity(0.30), dark: cream.opacity(0.24))

    // MARK: Gold

    /// Gold for text, icons and control tint. #D6B25E fails contrast on the light
    /// ground, so Sage Dawn uses the deeper #8F6E2A.
    static let accent       = Color(uiColor: uiAccent)
    /// Emphasis gold text (big numerals, the selected tab).
    static let accentBright = Color(light: Color(hex: "7A5B1E"), dark: goldBright)
    static let accentDeep   = Color(light: Color(hex: "7A5B1E"), dark: goldDeep)
    /// Decorative gold: rule diamonds, dots, hairline rules.
    static let accentOrnament = Color(light: goldDeep, dark: gold)
    static let accentChip       = Color(light: gold.opacity(0.18), dark: gold.opacity(0.14))
    static let accentChipStroke = Color(light: goldDeep.opacity(0.30), dark: gold.opacity(0.16))
    /// The gold CTA gradient is the same in both themes.
    static let accentGradient = LinearGradient(colors: [goldBright, goldDeep], startPoint: .topLeading, endPoint: .bottomTrailing)
    /// Text and glyphs on the gold gradient.
    static let onAccentText = Color(hex: "1A1408")

    // MARK: Surfaces

    static let glassSurface         = Color(light: Color.white.opacity(0.75), dark: Color.white.opacity(0.045))
    static let glassSurfaceElevated = Color(light: Color.white.opacity(0.92), dark: Color.white.opacity(0.07))
    static let glassSurfaceRecessed = Color(light: greenInk.opacity(0.045), dark: Color.white.opacity(0.03))
    /// The strongest fill a control sits on (e.g. pressed keyboard keys).
    static let glassSurfaceStrong   = Color(light: greenInk.opacity(0.08), dark: Color.white.opacity(0.13))
    /// Tint laid over `.ultraThinMaterial` for floating bars (tab bar, mini players).
    static let tabBarTint = Color(light: Color.white.opacity(0.85), dark: Color(hex: "0A1512").opacity(0.72))
    /// Dimming layer behind a modal card.
    static let modalScrim = Color(light: ink.opacity(0.35), dark: Color.black.opacity(0.55))

    // MARK: Strokes

    static let stroke       = Color(light: greenInk.opacity(0.10), dark: gold.opacity(0.16))
    static let strokeStrong = Color(light: greenInk.opacity(0.18), dark: gold.opacity(0.24))
    static let divider      = Color(light: greenInk.opacity(0.07), dark: gold.opacity(0.09))
    /// The empty part of a progress bar.
    static let progressTrack = Color(light: greenInk.opacity(0.10), dark: Color.white.opacity(0.08))

    // MARK: Semantic

    static let semanticGreen     = Color(light: Color(hex: "2C7A5B"), dark: Color(hex: "3E9B79"))
    static let semanticGreenChip = Color(light: Color(hex: "2C7A5B").opacity(0.14), dark: Color(hex: "3E9B79").opacity(0.16))
    static let semanticRed       = Color(light: Color(hex: "B3473F"), dark: Color(hex: "F47875"))
    static let semanticBlue      = Color(light: Color(hex: "2F6DB5"), dark: Color(hex: "6FA5E8"))
    static let semanticYellow    = Color(light: Color(hex: "8A6A10"), dark: Color(hex: "F2C969"))
    /// Destructive actions (sign out, delete account, errors).
    static let destructive       = Color(light: Color(hex: "B3473F"), dark: Color(red: 0.86, green: 0.49, blue: 0.45))
    /// Base for destructive chip fills and strokes (used with opacity).
    static let destructiveTint   = Color(light: Color(hex: "B3473F"), dark: Color(red: 0.82, green: 0.36, blue: 0.33))

    // MARK: Celebration

    /// Confetti pieces: soft peach / lilac / green glints on the dark ground; on the
    /// light ground the faint glints vanish, so Sage Dawn uses deeper gold and emerald.
    static let confettiColors: [Color] = [
        Color(light: goldDeep.opacity(0.85), dark: Color(red: 0.910, green: 0.580, blue: 0.392).opacity(0.18)),
        Color(light: Color(hex: "2C7A5B").opacity(0.75), dark: Color(red: 0.722, green: 0.651, blue: 0.851).opacity(0.12)),
        Color(light: gold.opacity(0.9), dark: Color(red: 0.357, green: 0.773, blue: 0.541).opacity(0.06)),
    ]
}

// MARK: - Shadows

/// Elevation levels. Midnight Emerald keeps its original black shadows; Sage Dawn
/// uses soft green-ink shadows from the design spec. Radius and offset differ by
/// theme too, so this resolves from the environment rather than a dynamic color.
enum EmShadow {
    /// Content cards.
    case card
    /// Hero / glowing cards.
    case raised
    /// Floating chrome: the tab bar, mini players, modal cards.
    case floating
    /// Under the gold CTA gradient.
    case goldCTA
    /// A one-off dark shadow; the light shadow is derived from it.
    case custom(opacity: Double, radius: CGFloat, y: CGFloat)

    fileprivate struct Spec { let color: Color; let radius: CGFloat; let y: CGFloat }

    private static let lightShadowInk = Color(.sRGB, red: 20 / 255, green: 50 / 255, blue: 38 / 255)

    fileprivate func spec(dark: Bool) -> Spec {
        switch self {
        case .card:
            return dark ? Spec(color: .black.opacity(0.28), radius: 24, y: 8)
                        : Spec(color: Self.lightShadowInk.opacity(0.10), radius: 17, y: 14)
        case .raised:
            return dark ? Spec(color: .black.opacity(0.45), radius: 40, y: 16)
                        : Spec(color: Self.lightShadowInk.opacity(0.14), radius: 22, y: 16)
        case .floating:
            return dark ? Spec(color: .black.opacity(0.5), radius: 36, y: 14)
                        : Spec(color: Self.lightShadowInk.opacity(0.18), radius: 20, y: 16)
        case .goldCTA:
            return dark ? Spec(color: Color(hex: "D6B25E").opacity(0.28), radius: 28, y: 10)
                        : Spec(color: Color(hex: "B8923F").opacity(0.35), radius: 12, y: 10)
        case let .custom(opacity, radius, y):
            return dark ? Spec(color: .black.opacity(opacity), radius: radius, y: y)
                        : Spec(color: Self.lightShadowInk.opacity(min(0.18, opacity * 0.36)), radius: radius * 0.7, y: y)
        }
    }
}

private struct EmShadowModifier: ViewModifier {
    @Environment(\.colorScheme) private var colorScheme
    let level: EmShadow

    func body(content: Content) -> some View {
        let spec = level.spec(dark: colorScheme == .dark)
        content.shadow(color: spec.color, radius: spec.radius, x: 0, y: spec.y)
    }
}

extension View {
    /// Applies the theme's shadow for an elevation level.
    func emShadow(_ level: EmShadow) -> some View {
        modifier(EmShadowModifier(level: level))
    }
}
