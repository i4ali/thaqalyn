//
//  DailyCrosswordCard.swift
//  Thaqalayn
//
//  Today-screen entry card for the Daily Crossword feature.
//  Styled to match DailyChallengeCard exactly — EmIconChip(46) + serif title +
//  gold uppercased sub-line + right chevron/checkmark.
//
//  Two states driven by DailyCrosswordManager:
//    • Pending  — not done today → taps to DailyCrosswordView
//    • Done     — completed today → non-tappable
//
//  Chrome is fixed-size (no ReadingSettingsManager scaling).
//

import SwiftUI

// MARK: - State enum

private enum DailyCrosswordCardState {
    case pending
    case done
}

// MARK: - Public entry point

/// Drop into TodayView/EmeraldTodayView.
struct DailyCrosswordCard: View {
    @ObservedObject private var manager = DailyCrosswordManager.shared
    @ObservedObject private var provider = DailyCrosswordProvider.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showSheet = false


    private var cardState: DailyCrosswordCardState {
        manager.isCompletedToday ? .done : .pending
    }

    var body: some View {
        emeraldCard
            .sheet(isPresented: $showSheet) {
                DailyCrosswordView(puzzle: provider.today, onCompleted: {})
            }
    }

    // MARK: - Emerald body (mirrors DailyChallengeCard.emeraldCard)

    @ViewBuilder
    private var emeraldCard: some View {
        let state = cardState
        let isDone = state == .done

        Group {
            if isDone {
                // Done state: non-tappable
                EmCard {
                    emeraldInner(state: state)
                }
            } else {
                // Pending: tappable
                Button {
                    Haptics.press()
                    showSheet = true
                } label: {
                    EmCard {
                        emeraldInner(state: state)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(EmPressStyle.gentle)
            }
        }
    }

    private func emeraldInner(state: DailyCrosswordCardState) -> some View {
        let isDone = state == .done

        return HStack(spacing: 14) {
            EmIconChip(sfSymbol: "square.grid.3x3.fill", size: 46)

            VStack(alignment: .leading, spacing: 4) {
                // Title row: serif title
                Text(DailyCrosswordStrings.dailyCrossword)
                    .font(EmType.serif(20, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Gold uppercased sub-line
                Text(emeraldSubLine(state: state))
                    .font(.system(size: 11, weight: .bold)).tracking(1)
                    .foregroundColor(isDone ? .green : themeManager.accentColor)
            }

            Spacer(minLength: 8)

            // Right icon
            emeraldRightIcon(state: state)
        }
        .padding(16)
    }

    private func emeraldSubLine(state: DailyCrosswordCardState) -> String {
        switch state {
        case .pending:
            let teaser = DailyCrosswordStrings.teaser
            if manager.streak.currentStreak > 0 {
                return "🔥 \(manager.streak.currentStreak) · \(teaser.uppercased())"
            }
            return teaser.uppercased()
        case .done:
            let base = DailyCrosswordStrings.doneForToday.uppercased()
            return "\(base) · 🔥 \(manager.streak.currentStreak)"
        }
    }

    @ViewBuilder
    private func emeraldRightIcon(state: DailyCrosswordCardState) -> some View {
        switch state {
        case .pending:
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(themeManager.tertiaryText)
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.green)
        }
    }
}

// MARK: - DEBUG Previews

#if DEBUG

// MARK: Pending (not done) previews

#Preview("Crossword Card — Pending, English, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .midnightEmerald
    return VStack(spacing: 16) {
        DailyCrosswordCard()
    }
    .padding(20)
    .background(ThemeManager.shared.primaryBackground)
    .preferredColorScheme(.dark)
}

#Preview("Crossword Card — Pending, English, Light") {
    let _ = ThemeManager.shared.selectedTheme = .sageDawn
    return VStack(spacing: 16) {
        DailyCrosswordCard()
    }
    .padding(20)
    .background(ThemeManager.shared.primaryBackground)
    .preferredColorScheme(.light)
}

// MARK: Done (premium, completed) previews
//
// DailyCrosswordManager.isCompletedToday is driven by UserDefaults and cannot be directly
// overridden from a preview without running the full completion flow. We render the done
// visual directly here using the same layout helpers, mirroring the pattern used in the
// DailyChallengeCard previews for faithful preview coverage.

private struct _DebugCrosswordDoneCard: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: "square.grid.3x3.fill", size: 46)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(DailyCrosswordStrings.dailyCrossword)
                            .font(EmType.serif(20, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2).multilineTextAlignment(.leading)
                    }
                    let subLine = "\(DailyCrosswordStrings.doneForToday.uppercased()) · 🔥 5"
                    Text(subLine)
                        .font(.system(size: 11, weight: .bold)).tracking(1)
                        .foregroundColor(.green)
                }
                Spacer(minLength: 8)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.green)
            }
            .padding(16)
        }
    }
}

#Preview("Crossword Card — Done, English, Emerald") {
    _DebugCrosswordDoneCard()
        .padding(20)
        .background(ThemeManager.shared.primaryBackground)
        .preferredColorScheme(.dark)
}

#Preview("Crossword Card — Done, English, Light") {
    _DebugCrosswordDoneCard()
        .padding(20)
        .background(ThemeManager.shared.primaryBackground)
        .preferredColorScheme(.light)
}

#endif
