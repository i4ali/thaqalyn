//
//  EmeraldComponents.swift
//  Thaqalayn
//
//  Reusable building blocks + typography for the Midnight Emerald theme.
//  Colors come from ThemeManager; these are used only in emerald (Dark) contexts.
//

import SwiftUI

// MARK: - Typography

enum EmType {
    enum Weight { case medium, semiBold
        var face: String { self == .semiBold ? "CormorantGaramond-SemiBold" : "CormorantGaramond-Medium" }
    }
    /// Cormorant Garamond serif (display).
    static func serif(_ size: CGFloat, _ weight: Weight = .semiBold) -> Font { .custom(weight.face, size: size) }
    static func serifItalic(_ size: CGFloat) -> Font { .custom("CormorantGaramondItalic-MediumItalic", size: size) }
    /// Amiri Arabic.
    static func arabic(_ size: CGFloat, bold: Bool = false) -> Font { .custom(bold ? "Amiri-Bold" : "Amiri-Regular", size: size) }
}

// MARK: - Eyebrow / small-caps label

extension Text {
    /// Styling for the app's small-caps "eyebrow" labels (the little
    /// uppercased section tags like "TODAY'S DUA"), made RTL-aware.
    ///
    /// The baseline `size` and letter-`tracking` are tuned for Latin capitals.
    /// Arabic/Urdu is connected script with no upper-case, so at the same size
    /// it reads noticeably smaller, and the tracking pulls apart joined glyphs.
    /// For RTL we raise the size a touch and drop the tracking; LTR is unchanged.
    func emEyebrow(_ lang: CommentaryLanguage,
                   size: CGFloat,
                   tracking: CGFloat = 0,
                   weight: Font.Weight = .bold,
                   design: Font.Design = .default) -> Text {
        self
            .font(.system(size: lang.isRTL ? size + 2 : size, weight: weight, design: design))
            .tracking(lang.isRTL ? 0 : tracking)
    }
}

// MARK: - Haptics

/// Centralized tap/press haptics. One place to tune the subtle tactile
/// feel that pairs with the visual press squish across the app.
enum Haptics {
    /// A gentle light impact for press-down feedback on buttons & cards.
    static func press() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        generator.impactOccurred(intensity: 0.6)
    }
}

// MARK: - Press style

/// Shared tap-feedback for the app: a deep, smooth, no-bounce press.
/// Default = "Deep & Soft" (scale 0.92 + slight dim). All existing
/// `.buttonStyle(EmPressStyle())` call sites inherit this automatically.
///
/// A quick tap is usually shorter than the press-in animation, so a naïve
/// `.animation(_, value: isPressed)` barely moves before the finger lifts and
/// the squish only "reads" on a long press. `PressableContent` fixes that: it
/// snaps in fast, holds the pressed look for a short floor, then eases back —
/// so every tap plays the full squish — and fires a light haptic on press-down.
struct EmPressStyle: ButtonStyle {
    var depth: CGFloat = 0.92   // pressed scale
    var dim: Double = 0.90      // pressed opacity

    func makeBody(configuration: Configuration) -> some View {
        PressableContent(isPressed: configuration.isPressed, depth: depth, dim: dim) {
            configuration.label
        }
    }

    /// Gentler preset for full-width rows so they sink in place rather than
    /// appearing to "jump" away from neighboring rows.
    static var gentle: EmPressStyle { EmPressStyle(depth: 0.97, dim: 0.94) }
}

/// Renders press feedback for a pressed flag: scale + dim + a light haptic on
/// press-down, with a minimum-visible floor so the full squish shows even on a
/// very quick tap. Shared by `EmPressStyle` (driven by a `Button`'s pressed
/// state) and `.pressFeedback()` (driven by a gesture, for non-`Button`
/// surfaces like the bookmark cards).
struct PressableContent<Label: View>: View {
    private let isPressed: Bool
    private let depth: CGFloat
    private let dim: Double
    private let label: Label

    /// Minimum time the pressed look stays on screen, so a tap shorter than
    /// the press-in animation still plays the complete squish.
    private let minHold: TimeInterval = 0.11

    @State private var held = false
    @State private var isDown = false
    @State private var pressStart: Date?

    init(isPressed: Bool,
         depth: CGFloat = 0.92,
         dim: Double = 0.90,
         @ViewBuilder label: () -> Label) {
        self.isPressed = isPressed
        self.depth = depth
        self.dim = dim
        self.label = label()
    }

    var body: some View {
        label
            .scaleEffect(held ? depth : 1)
            .opacity(held ? dim : 1)
            .animation(held ? .easeOut(duration: 0.07)
                            : .spring(response: 0.3, dampingFraction: 0.8),
                       value: held)
            .onChange(of: isPressed) { _, pressed in
                isDown = pressed
                if pressed {
                    pressStart = Date()
                    held = true
                    Haptics.press()
                } else {
                    let elapsed = pressStart.map { Date().timeIntervalSince($0) } ?? minHold
                    let remaining = max(0, minHold - elapsed)
                    if remaining == 0 {
                        held = false
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now() + remaining) {
                            if !isDown { held = false }
                        }
                    }
                }
            }
    }
}

/// Press feedback for a surface that already owns gestures (drag / long-press)
/// and so can't be a plain `Button`. Recognizes a zero-distance drag
/// *simultaneously*, so it adds the press squish + haptic on tap-down without
/// consuming the existing taps, long presses, or swipes.
extension View {
    func pressFeedback(depth: CGFloat = 0.92, dim: Double = 0.90) -> some View {
        modifier(PressFeedbackModifier(depth: depth, dim: dim))
    }
}

private struct PressFeedbackModifier: ViewModifier {
    let depth: CGFloat
    let dim: Double
    @State private var pressed = false

    func body(content: Content) -> some View {
        PressableContent(isPressed: pressed, depth: depth, dim: dim) { content }
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in pressed = true }
                    .onEnded { _ in pressed = false }
            )
    }
}

/// A tappable row/card that pushes a destination, but plays its press squish
/// *before* navigating. A plain `NavigationLink` pushes the instant you lift
/// your finger, so the `EmPressStyle` squish is hidden by the incoming screen.
/// This defers the push by a short beat so the press is acknowledged first —
/// the same "press, then open" feel as the in-place buttons. Drop-in
/// replacement for `NavigationLink(destination:) { label }.buttonStyle(EmPressStyle())`.
struct PressableNavLink<Label: View, Destination: View>: View {
    private let delay: Double
    private let destination: Destination
    private let label: Label
    @State private var isActive = false

    init(delay: Double = 0.12,
         @ViewBuilder destination: () -> Destination,
         @ViewBuilder label: () -> Label) {
        self.delay = delay
        self.destination = destination()
        self.label = label()
    }

    var body: some View {
        Button {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { isActive = true }
        } label: {
            label
        }
        .buttonStyle(EmPressStyle())
        .background(
            NavigationLink(destination: destination, isActive: $isActive) { EmptyView() }
                .hidden()
                .accessibilityHidden(true)
        )
    }
}

/// Press feedback for a tappable card/row that is NOT already a `Button`
/// (i.e. replaces a bare `.onTapGesture { }`). Also gives the element proper
/// button accessibility traits — an upgrade over the VoiceOver-invisible tap gesture.
extension View {
    func pressable(depth: CGFloat = 0.92,
                   dim: Double = 0.90,
                   action: @escaping () -> Void) -> some View {
        Button(action: action) {
            self.contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle(depth: depth, dim: dim))
    }
}

// MARK: - Card

struct EmCard<Content: View>: View {
    @ObservedObject private var tm = ThemeManager.shared
    var elevated = false
    var glow = false
    var cornerRadius: CGFloat = 20
    /// Optional override for the hairline border (defaults to the theme stroke).
    var borderColor: Color? = nil
    @ViewBuilder var content: Content

    var body: some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(elevated || glow ? tm.glassSurfaceElevated : tm.glassSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(borderColor ?? tm.strokeColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(glow ? 0.45 : 0.28),
                    radius: glow ? 40 : 24, x: 0, y: glow ? 16 : 8)
    }
}

// MARK: - Eyebrow + serif heading

struct EmHeading: View {
    @ObservedObject private var tm = ThemeManager.shared
    var eyebrow: String? = nil
    var title: String
    var sub: String? = nil
    var center = false

    var body: some View {
        VStack(alignment: center ? .center : .leading, spacing: 7) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(3)
                    .foregroundColor(tm.accentColor)
            }
            Text(title)
                .font(EmType.serif(40, .semiBold)).tracking(0.2)
                .foregroundColor(tm.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            if let sub {
                Text(sub).font(.system(size: 13.5)).foregroundColor(tm.secondaryText)
            }
        }
        .frame(maxWidth: .infinity, alignment: center ? .center : .leading)
    }
}

// MARK: - Numeral circle

struct EmNumeralCircle: View {
    @ObservedObject private var tm = ThemeManager.shared
    var n: Int
    var size: CGFloat = 46

    var body: some View {
        Text("\(n)")
            .font(EmType.serif(size * 0.42, .semiBold))
            .foregroundColor(tm.accentBright)
            .frame(width: size, height: size)
            .background(Circle().fill(tm.accentChip))
            .overlay(Circle().stroke(tm.accentColor, lineWidth: 1))
    }
}

// MARK: - Icon chip (SF Symbol)

struct EmIconChip: View {
    @ObservedObject private var tm = ThemeManager.shared
    var sfSymbol: String
    var size: CGFloat = 46
    var active = false
    var isCustomAsset = false   // when true, sfSymbol is an asset name rendered as a template

    var body: some View {
        Group {
            if isCustomAsset {
                Image(sfSymbol).renderingMode(.template).resizable().scaledToFit()
                    .frame(width: size * 0.46, height: size * 0.46)
            } else {
                Image(systemName: sfSymbol)
                    .font(.system(size: size * 0.40, weight: .regular))
            }
        }
        .foregroundColor(active ? tm.onAccentText : tm.accentColor)
        .frame(width: size, height: size)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(active ? AnyShapeStyle(tm.accentGradient) : AnyShapeStyle(tm.accentChip))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(active ? Color.clear : tm.strokeColor, lineWidth: 1)
        )
    }
}

// MARK: - Gold CTA

struct EmGoldCTA: View {
    @ObservedObject private var tm = ThemeManager.shared
    var title: String
    var sfSymbol: String? = nil
    var small = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                if let sfSymbol { Image(systemName: sfSymbol).font(.system(size: small ? 13 : 15, weight: .semibold)) }
                Text(title).font(.system(size: small ? 14 : 15.5, weight: .bold)).tracking(0.3)
            }
            .foregroundColor(tm.onAccentText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, small ? 12 : 16)
            .background(RoundedRectangle(cornerRadius: 15, style: .continuous).fill(tm.accentGradient))
            .shadow(color: tm.accentColor.opacity(0.28), radius: 28, x: 0, y: 10)
        }
        .buttonStyle(EmPressStyle())
    }
}

// MARK: - Ornamental divider

struct EmDivider: View {
    @ObservedObject private var tm = ThemeManager.shared
    var label: String? = nil

    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(LinearGradient(colors: [.clear, tm.strokeColor], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
            if let label {
                Text(label.uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(2.5)
                    .foregroundColor(tm.tertiaryText).fixedSize()
            } else {
                Rectangle().fill(tm.accentColor).frame(width: 6, height: 6).rotationEffect(.degrees(45))
            }
            Rectangle()
                .fill(LinearGradient(colors: [tm.strokeColor, .clear], startPoint: .leading, endPoint: .trailing))
                .frame(height: 1)
        }
    }
}

// MARK: - Emerald background (radial emerald gradient + gold top glow)

struct EmeraldBackground: View {
    @ObservedObject private var tm = ThemeManager.shared

    var body: some View {
        ZStack {
            tm.primaryBackground.ignoresSafeArea()
            GeometryReader { geo in
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: tm.emeraldBgTop, location: 0.0),
                        .init(color: tm.primaryBackground, location: 0.55),
                        .init(color: tm.emeraldBgBottom, location: 1.0),
                    ]),
                    center: UnitPoint(x: 0.5, y: -0.10),
                    startRadius: 0,
                    endRadius: max(geo.size.width, geo.size.height) * 1.1
                )
                .ignoresSafeArea()
            }
            RadialGradient(
                gradient: Gradient(colors: [tm.accentColor.opacity(0.14), .clear]),
                center: .top, startRadius: 0, endRadius: 230
            )
            .frame(height: 320)
            .frame(maxWidth: .infinity, alignment: .top)
            .offset(y: -90)
            .allowsHitTesting(false)
            .ignoresSafeArea()
        }
    }
}

// MARK: - Seasonal journey (Screen 04)

/// How a completed/observed day's marker reads. `.gold` is the festive gold-gradient check
/// (Ramadan/Hajj); `.subdued` is a quieter gold-chip check for the somber Muharram observance.
enum EmDayDoneStyle { case gold, subdued }

/// The header + glow progress card for a seasonal journey (Screen 04):
/// eyebrow + serif season title, a 56pt icon chip on the right, then a glow `EmCard` with the
/// status line + "N of M days …" on the left, a big `accentBright` percentage on the right, and a
/// gold progress track beneath. `completionNote`, when non-nil, adds a subdued "verified" badge.
struct EmJourneyHeader: View {
    @ObservedObject private var tm = ThemeManager.shared
    var eyebrow: String
    var title: String
    var sfSymbol: String
    var statusLine: String
    var countLine: String
    var percent: Double
    var completionNote: String? = nil
    var iconIsCustomAsset = false

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 12) {
                EmHeading(eyebrow: eyebrow, title: title)
                EmIconChip(sfSymbol: sfSymbol, size: 56, isCustomAsset: iconIsCustomAsset)
                    .padding(.top, 6)
            }
            EmCard(glow: true) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .bottom) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text(statusLine)
                                .font(.system(size: 12))
                                .foregroundColor(tm.secondaryText)
                            Text(countLine)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(tm.primaryText)
                        }
                        Spacer(minLength: 8)
                        Text("\(Int((percent * 100).rounded()))%")
                            .font(EmType.serif(30, .semiBold))
                            .foregroundColor(tm.accentBright)
                    }
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.white.opacity(0.08))
                            Capsule().fill(tm.accentGradient)
                                .frame(width: max(0, geo.size.width * percent))
                        }
                    }
                    .frame(height: 5)
                    if let completionNote {
                        HStack(spacing: 7) {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 13))
                                .foregroundColor(tm.semanticGreen)
                            Text(completionNote)
                                .font(.system(size: 12.5, weight: .semibold))
                                .foregroundColor(tm.semanticGreen)
                        }
                        .padding(.top, 2)
                    }
                }
                .padding(18)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }
}

/// One day row in a seasonal journey list (Screen 04). Marker: done → gold-gradient circle + check
/// (or, `.subdued`, a gold-chip circle + gold check); else a numeral circle. The current day's card
/// gains a gold border + gold-chip fill. Locked days show a lock chip + "PREMIUM" tag.
struct EmJourneyDayRow: View {
    @ObservedObject private var tm = ThemeManager.shared
    var dayNumber: Int
    var theme: String
    var themeArabic: String
    var isDone: Bool
    var isCurrent: Bool
    var isLocked: Bool
    var doneStyle: EmDayDoneStyle = .gold
    var onTap: () -> Void

    private var highlighted: Bool { isCurrent && !isLocked }

    @ViewBuilder private var marker: some View {
        if isLocked {
            Image(systemName: "lock.fill")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.tertiaryText)
                .frame(width: 42, height: 42)
                .background(Circle().fill(tm.accentChip))
                .overlay(Circle().stroke(tm.strokeColor, lineWidth: 1))
        } else if isDone {
            switch doneStyle {
            case .gold:
                Image(systemName: "checkmark")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(tm.onAccentText)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(tm.accentGradient))
            case .subdued:
                Image(systemName: "checkmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(tm.accentColor)
                    .frame(width: 42, height: 42)
                    .background(Circle().fill(tm.accentChip))
                    .overlay(Circle().stroke(tm.accentColor, lineWidth: 1))
            }
        } else {
            EmNumeralCircle(n: dayNumber, size: 42)
        }
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                marker
                VStack(alignment: .leading, spacing: 1) {
                    HStack(spacing: 7) {
                        Text("Day \(dayNumber)")
                            .font(.system(size: 10.5)).tracking(0.5)
                            .foregroundColor(tm.tertiaryText)
                        if isLocked {
                            Text("PREMIUM")
                                .font(.system(size: 8.5, weight: .bold)).tracking(1)
                                .foregroundColor(tm.accentColor)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(tm.accentChip))
                                .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
                        }
                    }
                    Text(theme)
                        .font(EmType.serif(21, .semiBold))
                        .foregroundColor(isLocked ? tm.secondaryText : tm.primaryText)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Text(themeArabic)
                    .font(EmType.arabic(19))
                    .foregroundColor(isLocked ? tm.secondaryText : tm.accentColor)
            }
            .padding(.vertical, 13)
            .padding(.horizontal, 15)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(highlighted ? tm.accentChip : tm.glassSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(highlighted ? tm.accentColor : tm.strokeColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 24, x: 0, y: 8)
        }
        .buttonStyle(EmPressStyle())
    }
}

// MARK: - Seasonal journey day-detail (pushed within a tab)

/// Gold eyebrow row: a line icon + an uppercase tracked label. Used as the section
/// header inside emerald detail cards.
struct EmSectionLabel: View {
    @ObservedObject private var tm = ThemeManager.shared
    var icon: String
    var text: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(tm.accentColor)
            Text(text.uppercased())
                .font(.system(size: 11, weight: .bold)).tracking(2)
                .foregroundColor(tm.accentColor)
            Spacer(minLength: 0)
        }
    }
}

/// A labelled glass card: gold eyebrow (icon + label) above arbitrary content.
struct EmDetailCard<Content: View>: View {
    var icon: String
    var label: String
    var glow = false
    @ViewBuilder var content: Content

    var body: some View {
        EmCard(glow: glow) {
            VStack(alignment: .leading, spacing: 12) {
                EmSectionLabel(icon: icon, text: label)
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(20)
        }
        .padding(.horizontal, 20)
    }
}

/// Header card for a journey day-detail screen: a "Day n" chip (+ optional badge and
/// status), then the serif theme title and gold Amiri theme word. `emphasized` (Ashura)
/// scales the title up and adds a restrained gold edge — gravity through scale, not ornament.
struct EmJourneyDetailHeader: View {
    @ObservedObject private var tm = ThemeManager.shared
    var dayNumber: Int
    var icon: String
    var theme: String
    var themeArabic: String
    var statusLabel: String? = nil
    var statusTint: Color? = nil
    var emphasized = false
    var badgeSymbol: String? = nil
    var badgeText: String? = nil

    var body: some View {
        EmCard(glow: emphasized) {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    HStack(spacing: 7) {
                        Image(systemName: icon).font(.system(size: 13, weight: .semibold))
                        Text("Day \(dayNumber)").font(.system(size: 13, weight: .semibold))
                    }
                    .foregroundColor(tm.accentColor)
                    .padding(.horizontal, 13).padding(.vertical, 7)
                    .background(Capsule().fill(tm.accentChip))
                    .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))

                    if let badgeSymbol, let badgeText {
                        HStack(spacing: 5) {
                            Image(systemName: badgeSymbol).font(.system(size: 11, weight: .semibold))
                            Text(badgeText).font(.system(size: 11.5, weight: .bold))
                        }
                        .foregroundColor(tm.secondaryText)
                        .padding(.horizontal, 10).padding(.vertical, 5)
                        .background(Capsule().fill(tm.secondaryText.opacity(0.12)))
                    }

                    if let statusLabel {
                        HStack(spacing: 5) {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 11))
                            Text(statusLabel).font(.system(size: 11.5, weight: .bold))
                        }
                        .foregroundColor(statusTint ?? tm.semanticGreen)
                    }
                    Spacer(minLength: 0)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text(theme)
                        .font(EmType.serif(emphasized ? 34 : 30, .semiBold))
                        .foregroundColor(tm.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(themeArabic)
                        .font(EmType.arabic(emphasized ? 24 : 22))
                        .foregroundColor(tm.accentColor)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(22)
        }
        .overlay {
            if emphasized {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(tm.accentColor.opacity(0.5), lineWidth: 1.5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
    }
}

/// The mark-complete / mark-observed toggle. Resting (not-done) is a gold CTA; done is a
/// quiet tinted confirmation chip (`doneTint` = semanticGreen for festive journeys,
/// secondaryText for the somber Muharram observance).
struct EmJourneyToggleButton: View {
    @ObservedObject private var tm = ThemeManager.shared
    var isDone: Bool
    var doneLabel: String
    var todoLabel: String
    var doneTint: Color
    var onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                Image(systemName: isDone ? "checkmark.seal.fill" : "circle")
                    .font(.system(size: 18, weight: .semibold))
                Text(isDone ? doneLabel : todoLabel)
                    .font(.system(size: 16, weight: .bold)).tracking(0.3)
            }
            .foregroundColor(isDone ? doneTint : tm.onAccentText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 17)
            .background(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(isDone ? AnyShapeStyle(doneTint.opacity(0.14)) : AnyShapeStyle(tm.accentGradient))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .stroke(isDone ? doneTint.opacity(0.5) : Color.clear, lineWidth: 1)
            )
            .shadow(color: isDone ? .clear : tm.accentColor.opacity(0.28), radius: 24, x: 0, y: 10)
        }
        .buttonStyle(EmPressStyle())
        .padding(.horizontal, 20)
    }
}

extension View {
    /// Applies `hideTabBar()` only in Midnight Emerald (so the floating bar doesn't overlap a
    /// pushed detail screen), leaving the Light path — which keeps the native tab bar — untouched.
    @ViewBuilder func hideTabBarInEmerald() -> some View {
        if ThemeManager.shared.isMidnightEmerald { self.hideTabBar() } else { self }
    }
}

// MARK: - Reading text-size control (shared across reading screens)

/// The "Aa" toggle chip. Theme-adaptive (reads ThemeManager tokens, works in both
/// Midnight Emerald and Light). Binds to a panel-visibility flag the host owns.
struct TextSizeButton: View {
    @ObservedObject private var tm = ThemeManager.shared
    @Binding var isPanelOpen: Bool

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.32, dampingFraction: 0.85)) {
                isPanelOpen.toggle()
            }
        }) {
            Text("Aa")
                .font(EmType.serif(18, .semiBold))
                .foregroundColor(tm.accentColor)
                .frame(width: 40, height: 40)
                .background(Circle().fill(isPanelOpen ? tm.accentChip : Color.clear))
                .overlay(Circle().stroke(tm.strokeColor, lineWidth: 1))
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("Text size")
    }
}

/// The floating A− / step-dots / A+ panel. Reads + mutates ReadingSettingsManager directly.
struct TextSizePanel: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var settings = ReadingSettingsManager.shared

    var body: some View {
        HStack(spacing: 16) {
            Button(action: { withAnimation(.easeInOut(duration: 0.18)) { settings.decrease() } }) {
                Text("A")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(settings.canDecrease ? tm.accentColor : tm.tertiaryText)
                    .frame(width: 28, height: 28)
            }
            .disabled(!settings.canDecrease)
            .accessibilityLabel("Decrease text size")

            HStack(spacing: 7) {
                ForEach(0..<settings.stepCount, id: \.self) { i in
                    Circle()
                        .fill(i <= settings.stepIndex ? tm.accentColor : tm.strokeColorStrong)
                        .frame(width: 6, height: 6)
                }
            }

            Button(action: { withAnimation(.easeInOut(duration: 0.18)) { settings.increase() } }) {
                Text("A")
                    .font(.system(size: 23, weight: .semibold))
                    .foregroundColor(settings.canIncrease ? tm.accentColor : tm.tertiaryText)
                    .frame(width: 28, height: 28)
            }
            .disabled(!settings.canIncrease)
            .accessibilityLabel("Increase text size")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(tm.strokeColor, lineWidth: 1))
                .shadow(color: .black.opacity(0.35), radius: 16, x: 0, y: 8)
        )
    }
}

extension View {
    /// Overlays the floating `TextSizePanel` at top-trailing with a transparent
    /// outside-tap catcher that closes it. Host owns the `isOpen` flag.
    func textSizePanelOverlay(isOpen: Binding<Bool>,
                              topPadding: CGFloat,
                              trailingPadding: CGFloat) -> some View {
        ZStack(alignment: .topTrailing) {
            self
            if isOpen.wrappedValue {
                Color.black.opacity(0.001)
                    .ignoresSafeArea()
                    .onTapGesture { withAnimation(.easeInOut(duration: 0.2)) { isOpen.wrappedValue = false } }
                TextSizePanel()
                    .padding(.top, topPadding)
                    .padding(.trailing, trailingPadding)
                    .transition(.scale(scale: 0.92, anchor: .topTrailing).combined(with: .opacity))
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    // Components read the shared singleton; force emerald so the canvas renders correctly.
    let _ = (ThemeManager.shared.selectedTheme = .nightSanctuary)
    return ZStack {
        EmeraldBackground()
        ScrollView {
            VStack(spacing: 16) {
                EmHeading(eyebrow: "The Noble Qur'an", title: "Read & Reflect", sub: "Premium serif heading")
                EmCard(glow: true) { Text("Glow card").foregroundColor(.white).frame(maxWidth: .infinity).padding(24) }
                HStack(spacing: 12) {
                    EmNumeralCircle(n: 2, size: 46)
                    EmIconChip(sfSymbol: "sparkles")
                    EmIconChip(sfSymbol: "sparkles", active: true)
                }
                EmDivider(label: "114 Surahs")
                EmDivider()
                EmGoldCTA(title: "Begin Quiz", sfSymbol: "play.fill") {}
            }
            .padding(20)
        }
    }
}

#Preview("EmPressStyle feel") {
    ZStack {
        EmeraldBackground()
        VStack(spacing: 20) {
            Button("Deep & Soft (0.92)") {}
                .buttonStyle(EmPressStyle())
            Button("Row gentle (0.97)") {}
                .buttonStyle(EmPressStyle.gentle)
        }
        .font(.system(size: 16, weight: .bold))
        .foregroundColor(ThemeManager.shared.onAccentText)
        .padding(.horizontal, 28).padding(.vertical, 16)
        .background(RoundedRectangle(cornerRadius: 15).fill(ThemeManager.shared.accentBright))
    }
    .environment(\.colorScheme, .dark)
}
#endif
