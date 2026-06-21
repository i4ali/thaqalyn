//
//  DailyChallengeScreen.swift
//  Thaqalayn
//
//  Onboarding Screen: Daily Challenge Feature Highlight
//
//  Loops through three formats (~4–5s each), each self-answering, with a
//  streak +1 bump and a gold "✨ +N sawab" pill float-up flourish.
//  Reduce Motion → static representative state (no loop).
//

import SwiftUI

// MARK: - Main View

struct DailyChallengeScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isVisible = false
    @State private var cardVisible = false
    @State private var demoStep: DemoChallengeStep = .multipleChoice
    @State private var loopRunning = false

    // Multiple-choice state
    @State private var mcAnswered = false          // shows green + ✓
    // True/false state
    @State private var tfAnswered = false          // shows True button green
    // Flashcard state
    @State private var flashFlipped = false        // card flipped to answer face
    // Shared flourish state
    @State private var streakCount: Int = 6
    @State private var showStreakBump = false
    @State private var showSawabPill = false
    @State private var sawabAmount: Int = 25
    // Card cross-fade
    @State private var cardOpacity: Double = 1.0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                HeroChip(palette: ThemeManager.chipGold, pulseDuration: 2.0) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 38, weight: .semibold))
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                Text("Daily Challenge")
                    .onbHeroTitle()
                    .foregroundColor(themeManager.primaryText)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                Text("A bite-sized challenge every day — multiple-choice, true/false, flip-cards and more. Answer it to build your streak and earn sawab.")
                    .onbBody()
                    .foregroundColor(themeManager.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.55), value: isVisible)
            }
            .padding(.top, 60)
            .padding(.bottom, 24)

            // Demo card area
            ZStack {
                demoChallengeCard
                    .opacity(cardOpacity)
            }
            .padding(.horizontal, 20)
            .opacity(cardVisible ? 1 : 0)
            .offset(y: cardVisible ? 0 : 40)
            .animation(Animation.easeOut(duration: 0.5).delay(0.7), value: cardVisible)

            Spacer()

            Text("Build a daily habit of reflection")
                .onbCaption()
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 100)
                .opacity(isVisible ? 1 : 0)
                .animation(Animation.easeOut(duration: 0.6).delay(0.9), value: isVisible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .lavender))
        .onAppear {
            isVisible = true
            cardVisible = true
            if !reduceMotion && !loopRunning {
                loopRunning = true
                startLoop()
            }
        }
        .onDisappear {
            loopRunning = false
        }
    }

    // MARK: - Demo Card Router

    @ViewBuilder
    private var demoChallengeCard: some View {
        switch demoStep {
        case .multipleChoice:
            DemoMCCard(answered: mcAnswered, streakCount: streakCount,
                       showStreakBump: showStreakBump, showSawabPill: showSawabPill,
                       sawabAmount: sawabAmount, reduceMotion: reduceMotion)
        case .trueFalse:
            DemoTFCard(answered: tfAnswered, streakCount: streakCount,
                       showStreakBump: showStreakBump, showSawabPill: showSawabPill,
                       sawabAmount: sawabAmount)
        case .flashcard:
            DemoFlashCard(flipped: flashFlipped, streakCount: streakCount,
                          showStreakBump: showStreakBump, showSawabPill: showSawabPill,
                          sawabAmount: sawabAmount)
        }
    }

    // MARK: - Loop Engine

    /// Runs one full beat for the current format, then advances.
    /// Guards with `loopRunning` so a second `onAppear` doesn't double-start.
    private func startLoop() {
        runBeat(for: demoStep)
    }

    private func runBeat(for step: DemoChallengeStep) {
        guard loopRunning else { return }
        resetForStep(step)

        // 1. Show prompt (already visible). Auto-answer after 1.2s.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            guard loopRunning else { return }
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                autoAnswer(step)
            }

            // 2. Reward flourish at 1.8s
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                guard loopRunning else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                    showStreakBump = true
                }
                withAnimation(Animation.easeOut(duration: 0.35).delay(0.1)) {
                    showSawabPill = true
                }

                // Dismiss pill at 3.0s (relative = 1.8 + 1.2)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    guard loopRunning else { return }
                    withAnimation(.easeIn(duration: 0.25)) {
                        showSawabPill = false
                        showStreakBump = false
                    }

                    // 3. Cross-fade to next format at ~4.2s
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        guard loopRunning else { return }
                        let next = step.next
                        sawabAmount = next == .flashcard ? 15 : 25
                        withAnimation(.easeInOut(duration: 0.35)) {
                            cardOpacity = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            guard loopRunning else { return }
                            demoStep = next
                            // streak bump carries visually; reset to representative value when wrapping
                            if next == .multipleChoice { streakCount = 6 }
                            withAnimation(.easeInOut(duration: 0.35)) {
                                cardOpacity = 1
                            }
                            // Recurse for next beat
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                runBeat(for: next)
                            }
                        }
                    }
                }
            }
        }
    }

    private func resetForStep(_ step: DemoChallengeStep) {
        mcAnswered   = false
        tfAnswered   = false
        flashFlipped = false
        showStreakBump = false
        showSawabPill  = false
    }

    private func autoAnswer(_ step: DemoChallengeStep) {
        switch step {
        case .multipleChoice: mcAnswered   = true; streakCount += 1
        case .trueFalse:      tfAnswered   = true; streakCount += 1
        case .flashcard:      flashFlipped = true; streakCount += 1
        }
    }
}

// MARK: - Step Enum

private enum DemoChallengeStep {
    case multipleChoice, trueFalse, flashcard

    var next: DemoChallengeStep {
        switch self {
        case .multipleChoice: return .trueFalse
        case .trueFalse:      return .flashcard
        case .flashcard:      return .multipleChoice
        }
    }
}

// MARK: - Shared Header Row

private struct DemoChallengeHeader: View {
    let streakCount: Int
    let showStreakBump: Bool

    var body: some View {
        HStack {
            // Eyebrow
            Text("TODAY'S CHALLENGE")
                .font(.system(size: 10, weight: .bold))
                .tracking(1.6)
                .foregroundColor(ThemeManager.chipGold.fg)

            Spacer()

            // Streak chip with +1 bump
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(ThemeManager.chipGold.fg)
                    Text("\(streakCount)")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(ThemeManager.chipGold.fg)
                        .contentTransition(.numericText())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Capsule().fill(ThemeManager.chipGold.bg))

                if showStreakBump {
                    Text("+1")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Capsule().fill(Color.orange))
                        .offset(x: 6, y: -8)
                        .transition(.scale(scale: 0.3).combined(with: .opacity))
                }
            }
        }
    }
}

// MARK: - Shared Sawab Pill

private struct SawabPill: View {
    let amount: Int

    var body: some View {
        Text("✨ +\(amount) sawab")
            .font(.system(size: 12, weight: .bold))
            .foregroundColor(ThemeManager.chipGold.fg)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule().fill(ThemeManager.chipGold.bg)
                    .overlay(Capsule().stroke(ThemeManager.chipGold.fg.opacity(0.25), lineWidth: 1))
            )
    }
}

// MARK: - Multiple-Choice Demo Card

private struct DemoMCCard: View {
    let answered: Bool
    let streakCount: Int
    let showStreakBump: Bool
    let showSawabPill: Bool
    let sawabAmount: Int
    let reduceMotion: Bool

    // For reduce-motion static state: show as answered
    private var effectiveAnswered: Bool { reduceMotion ? true : answered }
    private var effectiveShowPill: Bool { reduceMotion ? true : showSawabPill }
    private var effectiveShowBump: Bool { reduceMotion ? false : showStreakBump }
    private var effectiveStreak:  Int   { reduceMotion ? 7    : streakCount }

    private let options: [(String, String, Bool)] = [
        ("A", "Al-Fātiḥa", false),
        ("B", "Yā-Sīn", true),
        ("C", "al-Mulk", false),
    ]

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 14) {
                DemoChallengeHeader(streakCount: effectiveStreak,
                                    showStreakBump: effectiveShowBump)

                // Question
                Text("Which surah is known as 'the Heart of the Qur'an'?")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                // Options
                VStack(spacing: 8) {
                    ForEach(options, id: \.0) { letter, text, isCorrect in
                        MCOptionRow(letter: letter, text: text,
                                    isCorrect: isCorrect, answered: effectiveAnswered)
                    }
                }
            }
            .onboardingCard()

            // Sawab pill floats above center-right
            if effectiveShowPill {
                SawabPill(amount: sawabAmount)
                    .offset(y: -18)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

// MARK: - MC Option Row

private struct MCOptionRow: View {
    let letter: String
    let text: String
    let isCorrect: Bool
    let answered: Bool

    private var bgColor: Color {
        guard answered else { return .white.opacity(0.04) }
        return isCorrect ? .green.opacity(0.16) : .white.opacity(0.02)
    }
    private var borderColor: Color {
        guard answered else { return .white.opacity(0.12) }
        return isCorrect ? .green.opacity(0.65) : .white.opacity(0.06)
    }
    private var textOpacity: Double {
        if !answered { return 0.80 }
        return isCorrect ? 1.0 : 0.35
    }

    var body: some View {
        HStack(spacing: 10) {
            Text(letter)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(answered && isCorrect ? .green : .white.opacity(0.55))
                .frame(width: 24, height: 24)
                .background(Circle().fill((answered && isCorrect ? Color.green : Color.white).opacity(0.12)))

            Text(text)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white.opacity(textOpacity))

            Spacer()

            if answered && isCorrect {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 9)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(bgColor)
                .overlay(RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(borderColor, lineWidth: 1))
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: answered)
    }
}

// MARK: - True/False Demo Card

private struct DemoTFCard: View {
    let answered: Bool
    let streakCount: Int
    let showStreakBump: Bool
    let showSawabPill: Bool
    let sawabAmount: Int

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 14) {
                DemoChallengeHeader(streakCount: streakCount,
                                    showStreakBump: showStreakBump)

                Text("Imam ʿAlī (ʿa) was born inside the Kaʿba.")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.92))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 10) {
                    // True button
                    TFButton(label: "True",
                             sfSymbol: "checkmark.circle.fill",
                             isCorrect: true,
                             answered: answered)
                    // False button
                    TFButton(label: "False",
                             sfSymbol: "xmark.circle.fill",
                             isCorrect: false,
                             answered: answered)
                }
            }
            .onboardingCard()

            if showSawabPill {
                SawabPill(amount: sawabAmount)
                    .offset(y: -18)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

private struct TFButton: View {
    let label: String
    let sfSymbol: String
    let isCorrect: Bool
    let answered: Bool

    private var bgColor: Color {
        guard answered else { return .white.opacity(0.04) }
        return isCorrect ? .green.opacity(0.16) : .white.opacity(0.02)
    }
    private var borderColor: Color {
        guard answered else { return .white.opacity(0.12) }
        return isCorrect ? .green.opacity(0.65) : .white.opacity(0.06)
    }
    private var fgColor: Color {
        if !answered { return isCorrect ? .green.opacity(0.7) : .red.opacity(0.7) }
        return isCorrect ? .green : .white.opacity(0.30)
    }

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: sfSymbol)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(fgColor)
            Text(label)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(fgColor)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(bgColor)
                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(borderColor, lineWidth: 1.5))
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: answered)
    }
}

// MARK: - Flashcard Demo Card

private struct DemoFlashCard: View {
    let flipped: Bool
    let streakCount: Int
    let showStreakBump: Bool
    let showSawabPill: Bool
    let sawabAmount: Int

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 14) {
                DemoChallengeHeader(streakCount: streakCount,
                                    showStreakBump: showStreakBump)

                ZStack {
                    // Back face
                    FlashFace(
                        isFront: false,
                        content: AnyView(
                            Text("In the name of God, the All-Merciful, the Ever-Merciful.")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(ThemeManager.chipGold.fg)
                                .multilineTextAlignment(.center)
                                .padding(.vertical, 8)
                        )
                    )
                    .opacity(flipped ? 1 : 0)
                    .rotation3DEffect(.degrees(flipped ? 0 : 180), axis: (x: 0, y: 1, z: 0))

                    // Front face
                    FlashFace(
                        isFront: true,
                        content: AnyView(
                            VStack(spacing: 8) {
                                Text("What does 'Bismillāhir-Raḥmānir-Raḥīm' mean?")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.88))
                                    .multilineTextAlignment(.center)
                                Text("TAP TO FLIP")
                                    .font(.system(size: 9, weight: .bold))
                                    .tracking(1.3)
                                    .foregroundColor(ThemeManager.chipGold.fg.opacity(0.65))
                            }
                        )
                    )
                    .opacity(flipped ? 0 : 1)
                    .rotation3DEffect(.degrees(flipped ? -180 : 0), axis: (x: 0, y: 1, z: 0))
                }
                .frame(minHeight: 90)
                .animation(.spring(response: 0.45, dampingFraction: 0.82), value: flipped)
            }
            .onboardingCard()

            if showSawabPill {
                SawabPill(amount: sawabAmount)
                    .offset(y: -18)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 24)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
    }
}

private struct FlashFace: View {
    let isFront: Bool
    let content: AnyView

    var body: some View {
        content
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isFront
                          ? Color.white.opacity(0.03)
                          : ThemeManager.chipGold.bg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(isFront
                                    ? Color.white.opacity(0.10)
                                    : ThemeManager.chipGold.fg.opacity(0.30),
                                    lineWidth: 1)
                    )
            )
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Daily Challenge Screen") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    return DailyChallengeScreen()
}
#endif
