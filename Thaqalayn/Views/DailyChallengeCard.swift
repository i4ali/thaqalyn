//
//  DailyChallengeCard.swift
//  Thaqalayn
//
//  Today-screen entry card for the Daily Challenge feature.
//  Styled to match MomentCard (LifeMomentsView) exactly — EmIconChip(46) + serif title +
//  gold uppercased sub-line + right chevron/checkmark.
//
//  Two states driven by DailyChallengeManager (the feature is free for everyone):
//    • Pending: not done today, taps to DailyChallengeView
//    • Done: completed today, non-tappable
//
//  Chrome is fixed-size (no ReadingSettingsManager scaling).
//

import SwiftUI

// MARK: - State enum

private enum DailyChallengeCardState {
    case pending
    case done
}

// MARK: - Public entry point

/// Drop into TodayView/EmeraldTodayView.
struct DailyChallengeCard: View {
    @ObservedObject private var manager = DailyChallengeManager.shared
    @ObservedObject private var provider = DailyChallengeProvider.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showSheet = false


    private var cardState: DailyChallengeCardState {
        manager.isCompletedToday ? .done : .pending
    }

    var body: some View {
        emeraldCard
            .sheet(isPresented: $showSheet) {
                DailyChallengeView(challenge: provider.today, onCompleted: {})
            }
    }

    // MARK: - Emerald body (mirrors MomentCard.emeraldBody)

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
                // Pending: tappable, opens the challenge
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

    private func emeraldInner(state: DailyChallengeCardState) -> some View {
        let isDone = state == .done

        return HStack(spacing: 14) {
            EmIconChip(sfSymbol: "brain.head.profile", size: 46)

            VStack(alignment: .leading, spacing: 4) {
                Text(DailyChallengeStrings.dailyChallenge)
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

    private func emeraldSubLine(state: DailyChallengeCardState) -> String {
        switch state {
        case .pending:
            let teaser = DailyChallengeStrings.teaser(for: provider.today.format)
            if manager.streak.currentStreak > 0 {
                return "🔥 \(manager.streak.currentStreak) · \(teaser.uppercased())"
            }
            return teaser.uppercased()
        case .done:
            let base = DailyChallengeStrings.doneForToday.uppercased()
            return "\(base) · 🔥 \(manager.streak.currentStreak)"
        }
    }

    @ViewBuilder
    private func emeraldRightIcon(state: DailyChallengeCardState) -> some View {
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

#Preview("Card — Pending, English, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .midnightEmerald
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(ThemeManager.shared.primaryBackground)
    .preferredColorScheme(.dark)
}

#Preview("Card — Pending, English, Light") {
    let _ = ThemeManager.shared.selectedTheme = .sageDawn
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(ThemeManager.shared.primaryBackground)
    .preferredColorScheme(.light)
}

// MARK: Done (completed) previews
//
// DailyChallengeManager.isCompletedToday is driven by UserDefaults and cannot be directly
// overridden from a preview without running the full completion flow. We render the done
// visual directly here using the same layout helpers, mirroring the pattern used in the
// previous implementation for faithful preview coverage.

private struct _DebugDoneCard: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: "brain.head.profile", size: 46)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(DailyChallengeStrings.dailyChallenge)
                            .font(EmType.serif(20, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2).multilineTextAlignment(.leading)
                    }
                    let subLine = "\(DailyChallengeStrings.doneForToday.uppercased()) · 🔥 5"
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

#Preview("Card — Done, English, Emerald") {
    _DebugDoneCard()
        .padding(20)
        .background(ThemeManager.shared.primaryBackground)
        .preferredColorScheme(.dark)
}

#Preview("Card — Done, English, Light") {
    _DebugDoneCard()
        .padding(20)
        .background(ThemeManager.shared.primaryBackground)
        .preferredColorScheme(.light)
}

#endif
