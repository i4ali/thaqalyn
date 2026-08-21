//
//  WidgetShowcaseScreen.swift
//  Thaqalayn
//
//  Onboarding: the Daily Reflection home-screen widget. Single focus - showing
//  how to add it. A large looping iPhone acts out the three steps (long-press,
//  tap + and search Thaqalayn, the widget drops in) as the hero; the header
//  frames what it is. English by design like the rest of onboarding; the
//  localized explainer with the prayer-times location capture stays in
//  WidgetExplainerView (Settings).
//

import SwiftUI

struct WidgetShowcaseScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false

    // The onboarding accent gold.
    private let accent = Color(hex: "ECD49A")

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 44)

                VStack(spacing: 28) {
                    header

                    AddWidgetDemo(accent: accent,
                                  primaryText: themeManager.primaryText,
                                  secondaryText: themeManager.secondaryText)
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 28)
                        .animation(.spring(response: 0.7, dampingFraction: 0.74).delay(0.5), value: isVisible)
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 44)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .sage))
        .onAppear { isVisible = true }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 12) {
            Text("Home Screen Widget")
                .onbEyebrow()
                .foregroundColor(accent)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -16)
                .animation(.easeOut(duration: 0.6).delay(0.15), value: isVisible)

            Text("Add it to your Home Screen")
                .onbHeroTitle()
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: isVisible)

            Text("One verse that unfolds through your day")
                .onbBody()
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.42), value: isVisible)
        }
    }
}

// MARK: - Add-widget demonstration

// A large looping iPhone that acts out the three steps of adding the widget:
// long-press the Home Screen (icons jiggle, + appears), tap + and search
// Thaqalayn, then the Daily Reflection widget drops into place. Self-contained
// (its own timer/state) and fixed-look like the real widget, so it does not
// depend on the app theme; the caption/step dots take the theme's text colors.
//
// Every phone dimension is `base * s`, so the whole mock scales as one unit -
// bump `s` to resize without disturbing the proportions.
private struct AddWidgetDemo: View {
    let accent: Color
    let primaryText: Color
    let secondaryText: Color

    @State private var step = 0        // 0 long-press, 1 gallery, 2 added
    @State private var pulse = false   // ripple + plus attention pulse
    @State private var wobble = false  // edit-mode icon jiggle

    private let stepTimer = Timer.publish(every: 2.6, on: .main, in: .common).autoconnect()

    // One scale factor drives the whole phone.
    private let s: CGFloat = 1.42
    private var screenW: CGFloat { 168 * s }
    private var screenH: CGFloat { 264 * s }

    private let captions = [
        "Touch and hold the Home Screen",
        "Tap +, then search Thaqalayn",
        "Pick a size and add it",
    ]

    // Fixed phone palette (a stylized iOS home screen).
    private enum P {
        static let bezel = Color(hex: "0B0B0D")
        static let wallTop = Color(hex: "123227")
        static let wallBottom = Color(hex: "0A1A14")
        static let sheet = Color(hex: "1B1B1E")
        static let gold = Color(hex: "CFA96A")
        static let widgetTop = Color(hex: "14332A")
        static let widgetBottom = Color(hex: "0A1D18")
    }
    private let iconColors = [
        Color(hex: "3A5A78"), Color(hex: "6C5A86"), Color(hex: "7A6A4A"), Color(hex: "4A6B58"),
        Color(hex: "8A5A5A"), Color(hex: "5A7A6A"), Color(hex: "6A6A8A"), Color(hex: "7A7A5A"),
    ]

    var body: some View {
        VStack(spacing: 22) {
            phone
            stepDots
            caption
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) { pulse = true }
            withAnimation(.easeInOut(duration: 0.16).repeatForever(autoreverses: true)) { wobble = true }
        }
        .onReceive(stepTimer) { _ in
            withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) {
                step = (step + 1) % 3
            }
        }
    }

    // MARK: Phone

    private var phone: some View {
        screen
            .frame(width: screenW, height: screenH)
            .clipShape(RoundedRectangle(cornerRadius: 30 * s, style: .continuous))
            .padding(8 * s)
            .background(
                RoundedRectangle(cornerRadius: 38 * s, style: .continuous)
                    .fill(P.bezel)
                    .overlay(
                        RoundedRectangle(cornerRadius: 38 * s, style: .continuous)
                            .stroke(Color.white.opacity(0.10), lineWidth: 1)
                    )
            )
            .shadow(color: .black.opacity(0.5), radius: 24, x: 0, y: 15)
    }

    private var screen: some View {
        ZStack {
            LinearGradient(colors: [P.wallTop, P.wallBottom], startPoint: .top, endPoint: .bottom)

            VStack(spacing: 13 * s) {
                statusBar
                topRegion
                iconRow(offset: 2)
                Spacer(minLength: 0)
                dock
            }
            .padding(.horizontal, 14 * s)
            .padding(.top, 9 * s)
            .padding(.bottom, 11 * s)

            if step == 0 { ripple }

            if step <= 1 {
                plusButton
                    .padding(.leading, 14 * s)
                    .padding(.top, 30 * s)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .transition(.opacity)
            }

            if step == 1 {
                gallerySheet
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }

    private var statusBar: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 10 * s, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            Spacer()
            HStack(spacing: 4 * s) {
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
            }
            .font(.system(size: 8 * s, weight: .semibold))
            .foregroundColor(.white.opacity(0.85))
        }
    }

    // Two icon rows normally; the placed widget once added.
    private var topRegion: some View {
        ZStack {
            if step == 2 {
                placedWidget
                    .transition(.scale(scale: 0.7).combined(with: .opacity))
            } else {
                VStack(spacing: 13 * s) {
                    iconRow(offset: 0)
                    iconRow(offset: 4)
                }
                .transition(.opacity)
            }
        }
        .frame(height: 62 * s)
    }

    private func iconRow(offset: Int) -> some View {
        HStack(spacing: 12 * s) {
            ForEach(0..<4, id: \.self) { i in
                let editing = step <= 1
                RoundedRectangle(cornerRadius: 7 * s, style: .continuous)
                    .fill(iconColors[(offset + i) % iconColors.count])
                    .frame(width: 25 * s, height: 25 * s)
                    .rotationEffect(.degrees(editing ? (wobble ? 1.5 : -1.5) * ((i % 2 == 0) ? 1 : -1) : 0))
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var dock: some View {
        HStack(spacing: 12 * s) {
            ForEach(0..<4, id: \.self) { i in
                RoundedRectangle(cornerRadius: 7 * s, style: .continuous)
                    .fill(iconColors[(i + 3) % iconColors.count])
                    .frame(width: 25 * s, height: 25 * s)
            }
        }
        .padding(.vertical, 8 * s)
        .padding(.horizontal, 12 * s)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 18 * s, style: .continuous).fill(Color.white.opacity(0.08)))
    }

    // The Daily Reflection widget, dropped onto the home screen (step 2).
    private var placedWidget: some View {
        miniWidget
            .overlay(
                RoundedRectangle(cornerRadius: 11 * s, style: .continuous)
                    .stroke(P.gold.opacity(0.5), lineWidth: 1)
            )
            .shadow(color: P.gold.opacity(0.22), radius: 9)
    }

    // A tiny, abstract stand-in for the widget: gold chip + two text bars + the
    // four gold beat dots on the emerald ground - the same visual cues as the
    // real widget.
    private var miniWidget: some View {
        VStack(alignment: .leading, spacing: 4 * s) {
            HStack(spacing: 3 * s) {
                Capsule().fill(P.gold.opacity(0.6)).frame(width: 38 * s, height: 7 * s)
                Spacer()
                Capsule().fill(Color.white.opacity(0.25)).frame(width: 24 * s, height: 4 * s)
            }
            Spacer(minLength: 2)
            RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.62)).frame(height: 4.5 * s)
            RoundedRectangle(cornerRadius: 2).fill(Color.white.opacity(0.42)).frame(width: 74 * s, height: 4.5 * s)
            Spacer(minLength: 2)
            HStack(spacing: 3 * s) {
                ForEach(0..<4, id: \.self) { i in
                    Circle().fill(P.gold.opacity(i == 0 ? 0.85 : 0.3)).frame(width: 3.5 * s, height: 3.5 * s)
                }
            }
        }
        .padding(9 * s)
        .frame(height: 58 * s)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 11 * s, style: .continuous)
                .fill(LinearGradient(colors: [P.widgetTop, P.widgetBottom],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
        )
    }

    private var plusButton: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.92)).frame(width: 22 * s, height: 22 * s)
            Image(systemName: "plus")
                .font(.system(size: 12 * s, weight: .black))
                .foregroundColor(.black.opacity(0.75))
        }
        .overlay(
            Circle()
                .stroke(accent, lineWidth: 1.5)
                .scaleEffect(pulse ? 1.6 : 1.0)
                .opacity(pulse ? 0 : 0.9)
        )
    }

    private var ripple: some View {
        ZStack {
            Circle().fill(Color.white.opacity(0.14))
                .frame(width: 50 * s, height: 50 * s)
                .scaleEffect(pulse ? 1.12 : 0.82)
            Circle().stroke(Color.white.opacity(0.55), lineWidth: 1.5)
                .frame(width: 50 * s, height: 50 * s)
                .scaleEffect(pulse ? 1.35 : 0.85)
                .opacity(pulse ? 0 : 0.8)
        }
        .offset(y: -20 * s)
        .transition(.opacity)
    }

    private var gallerySheet: some View {
        VStack(spacing: 9 * s) {
            Capsule().fill(Color.white.opacity(0.3)).frame(width: 34 * s, height: 4 * s).padding(.top, 8 * s)

            HStack(spacing: 6 * s) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 10 * s, weight: .bold))
                    .foregroundColor(.white.opacity(0.5))
                Text("Thaqalayn")
                    .font(.system(size: 11 * s, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 10 * s)
            .padding(.vertical, 8 * s)
            .background(Capsule().fill(Color.white.opacity(0.14)))

            HStack(spacing: 9 * s) {
                miniWidget.frame(width: 86 * s)
                VStack(alignment: .leading, spacing: 3 * s) {
                    Text("Daily Reflection")
                        .font(.system(size: 11 * s, weight: .semibold))
                        .foregroundColor(.white)
                    Text("Thaqalayn")
                        .font(.system(size: 9 * s))
                        .foregroundColor(.white.opacity(0.55))
                }
                Spacer()
            }
            Spacer(minLength: 0)
        }
        .padding(11 * s)
        .frame(maxWidth: .infinity)
        .frame(height: 156 * s, alignment: .top)
        .background(
            UnevenRoundedRectangle(topLeadingRadius: 20 * s, topTrailingRadius: 20 * s, style: .continuous)
                .fill(P.sheet)
        )
    }

    // MARK: Step dots + caption

    private var stepDots: some View {
        HStack(spacing: 7) {
            ForEach(0..<3, id: \.self) { i in
                Capsule()
                    .fill(i == step ? accent : secondaryText.opacity(0.3))
                    .frame(width: i == step ? 18 : 6, height: 6)
            }
        }
    }

    private var caption: some View {
        Text(captions[step])
            .font(.system(size: 15.5, weight: .semibold))
            .foregroundColor(primaryText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .id(step)
            .transition(.opacity)
    }
}

#Preview {
    WidgetShowcaseScreen()
}
