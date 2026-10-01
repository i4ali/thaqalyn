//
//  ThemeManager.swift
//  Thaqalayn
//
//  Theme management. Two themes share one design: Sage Dawn (Light) and
//  Midnight Emerald (Dark). Midnight Emerald is the default for fresh installs;
//  users can switch in Settings (selectedTheme is persisted).
//
//  The theme only picks the color scheme. Colors are dynamic light/dark pairs in
//  ThemePalette, resolved from the SwiftUI color scheme the root view sets from
//  `colorScheme`; the properties below forward to them so views keep reading
//  `themeManager.primaryText` etc.
//

import SwiftUI

enum ThemeVariant: String, CaseIterable {
    case sageDawn
    case midnightEmerald

    var displayName: String {
        switch self {
        case .sageDawn:        return "Light"
        case .midnightEmerald: return "Dark"
        }
    }

    /// Reads a persisted value, including the names stored before Sage Dawn
    /// replaced the old Light theme ("warmInviting") and Midnight Emerald was
    /// renamed ("nightSanctuary").
    init?(storedValue: String) {
        switch storedValue {
        case Self.sageDawn.rawValue, "warmInviting":               self = .sageDawn
        case Self.midnightEmerald.rawValue, "nightSanctuary":      self = .midnightEmerald
        default:                                                    return nil
        }
    }
}

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    private static let storageKey = "selectedTheme"

    @Published var selectedTheme: ThemeVariant {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: Self.storageKey)
        }
    }

    private init() {
        // Drop legacy keys from pre-removal era (defensive, no behavior change).
        UserDefaults.standard.removeObject(forKey: "isDarkMode")

        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = ThemeVariant(storedValue: raw) {
            self.selectedTheme = saved
            // Rewrite a pre-rename value under its current name.
            if raw != saved.rawValue {
                UserDefaults.standard.set(saved.rawValue, forKey: Self.storageKey)
            }
        } else {
            // Fresh install (no stored preference) → default to Midnight Emerald.
            self.selectedTheme = .midnightEmerald
        }
    }

    /// The color scheme the app runs in; the root view applies it.
    var colorScheme: ColorScheme { selectedTheme == .midnightEmerald ? .dark : .light }

    // MARK: - Grounds

    var primaryBackground: Color   { ThemePalette.primaryBackground }
    var secondaryBackground: Color { ThemePalette.secondaryBackground }
    var tertiaryBackground: Color  { ThemePalette.tertiaryBackground }
    var emeraldBgTop: Color        { ThemePalette.bgTop }
    var emeraldBgBottom: Color     { ThemePalette.bgBottom }
    var topGlow: Color             { ThemePalette.topGlow }

    // MARK: - Text

    var primaryText: Color    { ThemePalette.primaryText }
    var secondaryText: Color  { ThemePalette.secondaryText }
    var tertiaryText: Color   { ThemePalette.tertiaryText }
    var quaternaryText: Color { ThemePalette.quaternaryText }

    // MARK: - Gold

    var accentColor: Color             { ThemePalette.accent }
    var accentBright: Color            { ThemePalette.accentBright }
    var accentColorDeep: Color         { ThemePalette.accentDeep }
    var accentOrnament: Color          { ThemePalette.accentOrnament }
    var accentChip: Color              { ThemePalette.accentChip }
    var accentChipStroke: Color        { ThemePalette.accentChipStroke }
    var accentGradient: LinearGradient { ThemePalette.accentGradient }
    var onAccentText: Color            { ThemePalette.onAccentText }

    // MARK: - Surfaces

    var glassEffect: Material          { .ultraThin }
    var glassSurface: Color            { ThemePalette.glassSurface }
    var glassSurfaceElevated: Color    { ThemePalette.glassSurfaceElevated }
    var glassSurfaceRecessed: Color    { ThemePalette.glassSurfaceRecessed }
    var glassSurfaceStrong: Color      { ThemePalette.glassSurfaceStrong }
    var tabBarTint: Color              { ThemePalette.tabBarTint }
    var modalScrim: Color              { ThemePalette.modalScrim }

    // MARK: - Strokes & dividers

    var strokeColor: Color       { ThemePalette.stroke }
    var strokeColorStrong: Color { ThemePalette.strokeStrong }
    var dividerColor: Color      { ThemePalette.divider }
    var progressTrack: Color     { ThemePalette.progressTrack }

    // MARK: - Semantic

    var semanticGreen: Color     { ThemePalette.semanticGreen }
    var semanticGreenChip: Color { ThemePalette.semanticGreenChip }
    var semanticRed: Color       { ThemePalette.semanticRed }
    var semanticBlue: Color      { ThemePalette.semanticBlue }
    var semanticYellow: Color    { ThemePalette.semanticYellow }
    var destructive: Color       { ThemePalette.destructive }
    var destructiveTint: Color   { ThemePalette.destructiveTint }

    // MARK: - Celebration

    var confettiColors: [Color] { ThemePalette.confettiColors }

    // MARK: - Onboarding (static; onboarding is a fixed dark design)

    struct ChipColor { let bg: Color; let fg: Color }

    static let chipGold = ChipColor(bg: Color(hex: "ECD49A").opacity(0.15), fg: Color(hex: "ECD49A"))

    enum OnboardingTilt { case peach, lavender, mauve, sage }

    // MARK: - Preview helpers (DEBUG only)

    #if DEBUG
    /// Returns a freshly-instantiated ThemeManager forced to Sage Dawn, for SwiftUI Previews only.
    /// Do NOT use at runtime - this bypasses the singleton.
    static var lightPreview: ThemeManager {
        let m = ThemeManager()
        m.selectedTheme = .sageDawn
        return m
    }

    /// Returns a freshly-instantiated ThemeManager forced to Midnight Emerald, for SwiftUI Previews only.
    static var darkPreview: ThemeManager {
        let m = ThemeManager()
        m.selectedTheme = .midnightEmerald
        return m
    }
    #endif
}
