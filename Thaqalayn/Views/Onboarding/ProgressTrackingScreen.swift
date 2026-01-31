//
//  ProgressTrackingScreen.swift
//  Thaqalayn
//
//  Onboarding Screen: Progress Tracking Feature Highlight
//

import SwiftUI

struct ProgressTrackingScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var isVisible = false
    @State private var isCheckboxChecked = false
    @State private var showProgressCard = false
    @State private var animatedPercentage = 0
    @State private var iconPulse = false

    var body: some View {
        VStack(spacing: 0) {
            // Header with animated icon
            VStack(spacing: 20) {
                // Animated checkmark icon
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 100, height: 100)
                        .blur(radius: 20)
                        .scaleEffect(iconPulse ? 1.2 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 2.0).repeatForever(autoreverses: true),
                            value: iconPulse
                        )

                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.green.opacity(0.3), Color.green.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)

                    // Checkmark icon
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 38, weight: .semibold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, Color(red: 0.2, green: 0.7, blue: 0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                // Title
                Text("Track Your Progress")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                // Subtitle
                Text("Master the Quran, verse by verse")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
            }
            .padding(.top, 60)
            .padding(.bottom, 24)

            // Demo content
            VStack(spacing: 16) {
                // Demo verse card
                DemoVerseCard(isCheckboxChecked: $isCheckboxChecked, isVisible: isVisible)

                // Progress indicator card
                DemoProgressCard(
                    showCard: showProgressCard,
                    percentage: animatedPercentage,
                    isVisible: isVisible
                )
            }
            .padding(.horizontal, 20)

            Spacer()

            // Bottom message
            Text("Your progress syncs across all your devices")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 100)
                .opacity(showProgressCard ? 1 : 0)
                .animation(Animation.easeOut(duration: 0.6).delay(0.3), value: showProgressCard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
        .onAppear {
            isVisible = true
            iconPulse = true
            startAnimationSequence()
        }
    }

    private func startAnimationSequence() {
        // After 2 seconds, animate the checkbox being checked
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isCheckboxChecked = true
            }

            // After checkbox animation, show progress card and animate percentage
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeOut(duration: 0.4)) {
                    showProgressCard = true
                }

                // Animate percentage from 0 to 14
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    animatePercentage()
                }
            }
        }
    }

    private func animatePercentage() {
        Timer.scheduledTimer(withTimeInterval: 0.04, repeats: true) { timer in
            if animatedPercentage < 14 {
                animatedPercentage += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Demo Verse Card

struct DemoVerseCard: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Binding var isCheckboxChecked: Bool
    let isVisible: Bool
    @State private var checkboxScale: CGFloat = 1.0

    var body: some View {
        VStack(spacing: 16) {
            // Top row with verse number, actions, and checkbox
            HStack {
                // Verse number circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text("1")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )

                Spacer()

                // Action buttons (decorative)
                HStack(spacing: 16) {
                    Image(systemName: "play.fill")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.secondaryText)

                    Image(systemName: "heart")
                        .font(.system(size: 14))
                        .foregroundColor(themeManager.secondaryText)
                }

                Spacer()

                // Animated checkbox
                DemoCheckbox(isChecked: isCheckboxChecked)
                    .scaleEffect(checkboxScale)
            }

            // Arabic verse
            Text("بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ")
                .font(.system(size: 26, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.center)
                .padding(.vertical, 8)

            // English translation
            Text("In the name of Allah, the Most Gracious, the Most Merciful")
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.secondaryBackground.opacity(0.6))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 40)
        .animation(Animation.easeOut(duration: 0.7).delay(0.6), value: isVisible)
        .onChange(of: isCheckboxChecked) { oldValue, newValue in
            if newValue && !oldValue {
                // Scale pulse animation when checkbox gets checked
                withAnimation(.spring(response: 0.2, dampingFraction: 0.5)) {
                    checkboxScale = 1.2
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        checkboxScale = 1.0
                    }
                }
            }
        }
    }
}

// MARK: - Demo Checkbox

struct DemoCheckbox: View {
    @StateObject private var themeManager = ThemeManager.shared
    let isChecked: Bool

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    isChecked ? Color.green : themeManager.strokeColor,
                    lineWidth: 2
                )
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isChecked ? AnyShapeStyle(Color.green.opacity(0.3)) : AnyShapeStyle(themeManager.glassEffect))
                )

            if isChecked {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 36, height: 36)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isChecked)
    }
}

// MARK: - Demo Progress Card

struct DemoProgressCard: View {
    @StateObject private var themeManager = ThemeManager.shared
    let showCard: Bool
    let percentage: Int
    let isVisible: Bool

    var body: some View {
        HStack(spacing: 16) {
            // Surah number badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(red: 0.35, green: 0.40, blue: 0.75), Color(red: 0.25, green: 0.30, blue: 0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Text("1")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Al-Faatiha")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text("7 verses")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }

            Spacer()

            // Progress indicator
            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.green)

                Text("\(percentage)%")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.green)
                    .contentTransition(.numericText())
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.primaryBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 12, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.green.opacity(0.3), lineWidth: 1)
        )
        .opacity(showCard ? 1 : 0)
        .offset(y: showCard ? 0 : 20)
        .animation(Animation.easeOut(duration: 0.5), value: showCard)
    }
}

#Preview {
    ProgressTrackingScreen()
}
