//
//  DailyCrosswordScreen.swift
//  Thaqalayn
//
//  Onboarding Screen: Daily Crossword Feature Highlight
//
//  A self-solving mini crossword on a repeating loop (~3.5s): SALAH fills in
//  left→right across row 1, then the down extras of ALI (A above, I below the
//  shared L) drop in, then a 🔥 streak bump springs up. Holds, fades back to
//  empty, repeats.
//  Reduce Motion → static completed grid (no loop).
//

import SwiftUI

// MARK: - Main View

struct DailyCrosswordScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isVisible = false
    @State private var cardVisible = false
    @State private var loopRunning = false

    // Fill state: how many of the 5 across letters of SALAH are revealed.
    @State private var acrossRevealed: Int = 0
    // The down extras (A above, I below); the shared L comes from SALAH.
    @State private var downExtrasRevealed = false
    // Reward flourish
    @State private var showStreakBump = false
    private let streakCount = 6

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 20) {
                HeroChip(palette: ThemeManager.chipGold, pulseDuration: 2.0) {
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 36, weight: .semibold))
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                Text("More than a crossword")
                    .onbHeroTitle()
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                Text("Most puzzles just pass the time — this one fills it. Every clue is a verse, an Imam, or a practice worth knowing. Solve the daily mini to build your streak.")
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
                DemoCrosswordCard(
                    acrossRevealed: acrossRevealed,
                    downExtrasRevealed: downExtrasRevealed,
                    streakCount: streakCount,
                    showStreakBump: showStreakBump,
                    reduceMotion: reduceMotion
                )
            }
            .padding(.horizontal, 20)
            .opacity(cardVisible ? 1 : 0)
            .offset(y: cardVisible ? 0 : 40)
            .animation(Animation.easeOut(duration: 0.5).delay(0.7), value: cardVisible)

            Spacer()

            Text("Knowledge, one clue at a time")
                .onbCaption()
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .padding(.bottom, 100)
                .opacity(isVisible ? 1 : 0)
                .animation(Animation.easeOut(duration: 0.6).delay(0.9), value: isVisible)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .sage))
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

    // MARK: - Loop Engine

    /// Runs one full self-solving beat, then recurses.
    /// Guards with `loopRunning` so a second `onAppear` doesn't double-start.
    private func startLoop() {
        runBeat()
    }

    private func runBeat() {
        guard loopRunning else { return }
        resetGrid()

        // 1. Reveal SALAH left→right, one letter every 0.18s (starts at 0.5s).
        let perLetter = 0.18
        for i in 1...5 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 + perLetter * Double(i - 1)) {
                guard loopRunning else { return }
                withAnimation(.spring(response: 0.32, dampingFraction: 0.7)) {
                    acrossRevealed = i
                }
            }
        }

        // 2. After SALAH completes, drop in the down extras (A above, I below).
        let downAt = 0.5 + perLetter * 5 + 0.25
        DispatchQueue.main.asyncAfter(deadline: .now() + downAt) {
            guard loopRunning else { return }
            withAnimation(.spring(response: 0.40, dampingFraction: 0.7)) {
                downExtrasRevealed = true
            }

            // 3. Reward flourish: streak bump.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                guard loopRunning else { return }
                withAnimation(.spring(response: 0.4, dampingFraction: 0.65)) {
                    showStreakBump = true
                }

                // 4. Hold ~0.9s, then fade everything back to empty.
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                    guard loopRunning else { return }
                    withAnimation(.easeIn(duration: 0.35)) {
                        acrossRevealed = 0
                        downExtrasRevealed = false
                        showStreakBump = false
                    }

                    // 5. Brief empty pause, then recurse.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
                        runBeat()
                    }
                }
            }
        }
    }

    private func resetGrid() {
        acrossRevealed = 0
        downExtrasRevealed = false
        showStreakBump = false
    }
}

// MARK: - Crossword Demo Card

private struct DemoCrosswordCard: View {
    let acrossRevealed: Int
    let downExtrasRevealed: Bool
    let streakCount: Int
    let showStreakBump: Bool
    let reduceMotion: Bool

    // Reduce Motion → show the completed grid statically.
    private var effectiveAcross: Int { reduceMotion ? 5 : acrossRevealed }
    private var effectiveDownExtras: Bool { reduceMotion ? true : downExtrasRevealed }
    private var effectiveShowBump: Bool { reduceMotion ? false : showStreakBump }
    private var effectiveStreak: Int { reduceMotion ? 7 : streakCount }

    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 14) {
                // Eyebrow + streak
                HStack {
                    Text("TODAY'S MINI")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(1.6)
                        .foregroundColor(ThemeManager.chipGold.fg)

                    Spacer()

                    ZStack(alignment: .topTrailing) {
                        HStack(spacing: 5) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(ThemeManager.chipGold.fg)
                            Text("\(effectiveStreak)")
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(ThemeManager.chipGold.fg)
                                .contentTransition(.numericText())
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Capsule().fill(ThemeManager.chipGold.bg))

                        if effectiveShowBump {
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

                // The mini grid
                CrosswordGrid(acrossRevealed: effectiveAcross,
                              downExtrasRevealed: effectiveDownExtras)
                    .padding(.vertical, 4)

                // Static clue line
                HStack(spacing: 6) {
                    Text("1 Across")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(ThemeManager.chipGold.fg)
                    Text("·")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white.opacity(0.35))
                    Text("Ritual prayer, five times a day")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.78))
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .fixedSize(horizontal: false, vertical: true)
            }
            .onboardingCard()
        }
    }
}

// MARK: - Crossword Grid

private struct CrosswordGrid: View {
    let acrossRevealed: Int        // 0...5 letters of SALAH revealed
    let downExtrasRevealed: Bool   // A (above) + I (below) the shared L

    private let across = Array("SALAH")   // row 1, cols 0–4
    private let cell: CGFloat = 38
    private let spacing: CGFloat = 6

    // Across row tints gold once any letter is in (active-word highlight).
    private var acrossActive: Bool { acrossRevealed > 0 }

    var body: some View {
        VStack(spacing: spacing) {
            // Row 0: only col 2 = "A" (down extra)
            HStack(spacing: spacing) {
                blank()
                blank()
                LetterCell(letter: downExtrasRevealed ? "A" : nil,
                           filled: downExtrasRevealed,
                           active: downExtrasRevealed,
                           size: cell)
                blank()
                blank()
            }

            // Row 1: SALAH across (col 2 is the shared "L")
            HStack(spacing: spacing) {
                ForEach(0..<5, id: \.self) { col in
                    let revealed = col < acrossRevealed
                    LetterCell(letter: revealed ? String(across[col]) : nil,
                               filled: revealed,
                               active: acrossActive,
                               size: cell)
                }
            }

            // Row 2: only col 2 = "I" (down extra)
            HStack(spacing: spacing) {
                blank()
                blank()
                LetterCell(letter: downExtrasRevealed ? "I" : nil,
                           filled: downExtrasRevealed,
                           active: downExtrasRevealed,
                           size: cell)
                blank()
                blank()
            }
        }
    }

    private func blank() -> some View {
        Color.clear.frame(width: cell, height: cell)
    }
}

// MARK: - Letter Cell

private struct LetterCell: View {
    let letter: String?       // nil = empty (awaiting fill)
    let filled: Bool
    let active: Bool          // word is being solved → gold tint
    let size: CGFloat

    private var bgColor: Color {
        if filled { return ThemeManager.chipGold.bg }
        if active { return ThemeManager.chipGold.fg.opacity(0.06) }
        return Color.white.opacity(0.04)
    }
    private var borderColor: Color {
        if filled { return ThemeManager.chipGold.fg.opacity(0.55) }
        if active { return ThemeManager.chipGold.fg.opacity(0.22) }
        return Color.white.opacity(0.12)
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 8, style: .continuous)
            .fill(bgColor)
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(borderColor, lineWidth: 1)
            )
            .frame(width: size, height: size)
            .overlay {
                if let letter {
                    Text(letter)
                        .font(.system(size: 17, weight: .bold, design: .rounded))
                        .foregroundColor(ThemeManager.chipGold.fg)
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: filled)
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Daily Crossword Screen") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    return DailyCrosswordScreen()
}
#endif
