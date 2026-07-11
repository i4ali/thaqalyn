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
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var showSheet = false

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    private var cardState: DailyCrosswordCardState {
        manager.isCompletedToday ? .done : .pending
    }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldCard
            } else {
                legacyCard
            }
        }
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
                Text(DailyCrosswordStrings.dailyCrossword(lang))
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
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }

    private func emeraldSubLine(state: DailyCrosswordCardState) -> String {
        switch state {
        case .pending:
            let teaser = DailyCrosswordStrings.teaser(lang)
            if manager.streak.currentStreak > 0 {
                return "🔥 \(manager.streak.currentStreak) · \(teaser.uppercased())"
            }
            return teaser.uppercased()
        case .done:
            let base = DailyCrosswordStrings.doneForToday(lang).uppercased()
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

    // MARK: - Legacy body (mirrors DailyChallengeCard.legacyCard)

    @ViewBuilder
    private var legacyCard: some View {
        let state = cardState
        let isDone = state == .done

        Group {
            if isDone {
                legacyInner(state: state)
            } else {
                Button {
                    Haptics.press()
                    showSheet = true
                } label: {
                    legacyInner(state: state)
                        .contentShape(Rectangle())
                }
                .buttonStyle(EmPressStyle.gentle)
            }
        }
    }

    private func legacyInner(state: DailyCrosswordCardState) -> some View {
        let isDone = state == .done

        return HStack(alignment: .center, spacing: 16) {
            // Category icon — circle gold gradient (50), white symbol
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 50, height: 50)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Text stack
            VStack(alignment: .leading, spacing: 4) {
                Text(DailyCrosswordStrings.dailyCrossword(lang))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Sub-line
                Text(legacySubLine(state: state))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isDone ? .green : themeManager.secondaryText)
            }

            Spacer()

            // Right icon
            legacyRightIcon(state: state)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary
                      ? themeManager.glassSurface : Color.white)
                .overlay(RoundedRectangle(cornerRadius: 20)
                    .stroke(themeManager.strokeColor, lineWidth: 1))
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary
                        ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                    radius: 12, x: 0, y: 4
                )
        }
        .contentShape(Rectangle())
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }

    private func legacySubLine(state: DailyCrosswordCardState) -> String {
        switch state {
        case .pending:
            let teaser = DailyCrosswordStrings.teaser(lang)
            if manager.streak.currentStreak > 0 {
                return "🔥 \(manager.streak.currentStreak) · \(teaser)"
            }
            return teaser
        case .done:
            let base = DailyCrosswordStrings.doneForToday(lang)
            return "\(base) · 🔥 \(manager.streak.currentStreak)"
        }
    }

    @ViewBuilder
    private func legacyRightIcon(state: DailyCrosswordCardState) -> some View {
        switch state {
        case .pending:
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        case .done:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.green)
        }
    }
}

// MARK: - DEBUG Previews

#if DEBUG

// MARK: Pending (not done) previews

#Preview("Crossword Card — Pending, English, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    return VStack(spacing: 16) {
        DailyCrosswordCard()
    }
    .padding(20)
    .background(Color.black)
}

#Preview("Crossword Card — Pending, English, Light") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    return VStack(spacing: 16) {
        DailyCrosswordCard()
    }
    .padding(20)
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#Preview("Crossword Card — Pending, Urdu, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    return VStack(spacing: 16) {
        DailyCrosswordCard()
    }
    .padding(20)
    .background(Color.black)
}

#Preview("Crossword Card — Pending, Urdu, Light") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    return VStack(spacing: 16) {
        DailyCrosswordCard()
    }
    .padding(20)
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

// MARK: Done (premium, completed) previews
//
// DailyCrosswordManager.isCompletedToday is driven by UserDefaults and cannot be directly
// overridden from a preview without running the full completion flow. We render the done
// visual directly here using the same layout helpers, mirroring the pattern used in the
// DailyChallengeCard previews for faithful preview coverage.

private struct _DebugCrosswordDoneCard: View {
    let theme: ThemeVariant
    let language: CommentaryLanguage

    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    private var lang: CommentaryLanguage { language }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald { emeraldDone } else { legacyDone }
        }
        .onAppear {
            ThemeManager.shared.selectedTheme = theme
            CommentaryLanguageManager.shared.setLanguage(language)
        }
    }

    private var emeraldDone: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: "square.grid.3x3.fill", size: 46)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(DailyCrosswordStrings.dailyCrossword(lang))
                            .font(EmType.serif(20, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2).multilineTextAlignment(.leading)
                    }
                    let subLine = "\(DailyCrosswordStrings.doneForToday(lang).uppercased()) · 🔥 5"
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
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
        }
    }

    private var legacyDone: some View {
        HStack(alignment: .center, spacing: 16) {
            ZStack {
                Circle().fill(themeManager.accentGradient).frame(width: 50, height: 50)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(DailyCrosswordStrings.dailyCrossword(lang))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText).lineLimit(2)
                Text("\(DailyCrosswordStrings.doneForToday(lang)) · 🔥 5")
                    .font(.system(size: 14, weight: .medium)).foregroundColor(.green)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 14, weight: .medium)).foregroundColor(.green)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary
                      ? themeManager.glassSurface : Color.white)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(themeManager.strokeColor, lineWidth: 1))
                .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        }
        .contentShape(Rectangle())
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }
}

#Preview("Crossword Card — Done, English, Emerald") {
    _DebugCrosswordDoneCard(theme: .nightSanctuary, language: .english)
        .padding(20)
        .background(Color.black)
}

#Preview("Crossword Card — Done, English, Light") {
    _DebugCrosswordDoneCard(theme: .warmInviting, language: .english)
        .padding(20)
        .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#Preview("Crossword Card — Done, Urdu, Emerald") {
    _DebugCrosswordDoneCard(theme: .nightSanctuary, language: .urdu)
        .padding(20)
        .background(Color.black)
}

#Preview("Crossword Card — Done, Urdu, Light") {
    _DebugCrosswordDoneCard(theme: .warmInviting, language: .urdu)
        .padding(20)
        .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#endif
