//
//  DailyChallengeCard.swift
//  Thaqalayn
//
//  Today-screen entry card for the Daily Challenge feature.
//  Styled to match MomentCard (LifeMomentsView) exactly — EmIconChip(46) + serif title +
//  inline PREMIUM capsule when locked + gold uppercased sub-line + right lock/chevron/checkmark.
//
//  Three states driven by PremiumManager + DailyChallengeManager:
//    • Locked   — free user → taps to PaywallView
//    • Pending  — premium, not done today → taps to DailyChallengeView
//    • Done     — premium, completed today → non-tappable
//
//  Chrome is fixed-size (no ReadingSettingsManager scaling).
//

import SwiftUI

// MARK: - State enum

private enum DailyChallengeCardState {
    case locked
    case pending
    case done
}

// MARK: - Public entry point

/// Drop into TodayView/EmeraldTodayView.
struct DailyChallengeCard: View {
    @ObservedObject private var manager = DailyChallengeManager.shared
    @ObservedObject private var provider = DailyChallengeProvider.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var showSheet = false
    @State private var showPaywall = false

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    private var cardState: DailyChallengeCardState {
        if !premiumManager.canAccessDailyChallenge() { return .locked }
        return manager.isCompletedToday ? .done : .pending
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
            DailyChallengeView(challenge: provider.today, onCompleted: {})
        }
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Emerald body (mirrors MomentCard.emeraldBody)

    @ViewBuilder
    private var emeraldCard: some View {
        let state = cardState
        let isLocked = state == .locked
        let isDone = state == .done

        Group {
            if isDone {
                // Done state: non-tappable
                EmCard {
                    emeraldInner(state: state)
                }
            } else {
                // Locked or pending: tappable
                Button {
                    Haptics.press()
                    if isLocked { showPaywall = true } else { showSheet = true }
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
        let isLocked = state == .locked
        let isDone = state == .done

        return HStack(spacing: 14) {
            EmIconChip(sfSymbol: "brain.head.profile", size: 46)

            VStack(alignment: .leading, spacing: 4) {
                // Title row: serif title + optional inline PREMIUM capsule
                HStack(spacing: 8) {
                    Text(DailyChallengeStrings.dailyChallenge(lang))
                        .font(EmType.serif(20, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if isLocked {
                        Text(DailyChallengeStrings.premiumLabel(lang).uppercased())
                            .font(.system(size: 8.5, weight: .bold)).tracking(1)
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Capsule().fill(themeManager.accentChip))
                            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                    }
                }

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

    private func emeraldSubLine(state: DailyChallengeCardState) -> String {
        switch state {
        case .locked:
            return DailyChallengeStrings.lockedTagline(lang).uppercased()
        case .pending:
            let teaser = DailyChallengeStrings.teaser(for: provider.today.format, lang)
            if manager.streak.currentStreak > 0 {
                return "🔥 \(manager.streak.currentStreak) · \(teaser.uppercased())"
            }
            return teaser.uppercased()
        case .done:
            let base = DailyChallengeStrings.doneForToday(lang).uppercased()
            var parts = [base, "🔥 \(manager.streak.currentStreak)"]
            if let sawab = manager.lastCompletion?.sawabEarned {
                parts.append(DailyChallengeStrings.sawabEarned(sawab, lang))
            }
            return parts.joined(separator: " · ")
        }
    }

    @ViewBuilder
    private func emeraldRightIcon(state: DailyChallengeCardState) -> some View {
        switch state {
        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(themeManager.tertiaryText)
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

    // MARK: - Legacy body (mirrors MomentCard.legacyBody)

    @ViewBuilder
    private var legacyCard: some View {
        let state = cardState
        let isLocked = state == .locked
        let isDone = state == .done

        Group {
            if isDone {
                legacyInner(state: state)
            } else {
                Button {
                    Haptics.press()
                    if isLocked { showPaywall = true } else { showSheet = true }
                } label: {
                    legacyInner(state: state)
                        .contentShape(Rectangle())
                }
                .buttonStyle(EmPressStyle.gentle)
            }
        }
    }

    private func legacyInner(state: DailyChallengeCardState) -> some View {
        let isLocked = state == .locked
        let isDone = state == .done

        return HStack(alignment: .center, spacing: 16) {
            // Category icon — circle gold gradient (50), white symbol
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 50, height: 50)
                    .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Text stack
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(DailyChallengeStrings.dailyChallenge(lang))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if isLocked {
                        Text(DailyChallengeStrings.premiumLabel(lang))
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.orange.gradient))
                    }
                }

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

    private func legacySubLine(state: DailyChallengeCardState) -> String {
        switch state {
        case .locked:
            return DailyChallengeStrings.lockedTagline(lang)
        case .pending:
            let teaser = DailyChallengeStrings.teaser(for: provider.today.format, lang)
            if manager.streak.currentStreak > 0 {
                return "🔥 \(manager.streak.currentStreak) · \(teaser)"
            }
            return teaser
        case .done:
            let base = DailyChallengeStrings.doneForToday(lang)
            var parts = [base, "🔥 \(manager.streak.currentStreak)"]
            if let sawab = manager.lastCompletion?.sawabEarned {
                parts.append(DailyChallengeStrings.sawabEarned(sawab, lang))
            }
            return parts.joined(separator: " · ")
        }
    }

    @ViewBuilder
    private func legacyRightIcon(state: DailyChallengeCardState) -> some View {
        switch state {
        case .locked:
            Image(systemName: "lock.fill")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
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

// MARK: Locked (free) previews

#Preview("Card — LOCKED, English, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    let _ = PremiumManager.shared.isPremium = false
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(Color.black)
}

#Preview("Card — LOCKED, English, Light") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    let _ = PremiumManager.shared.isPremium = false
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#Preview("Card — LOCKED, Urdu, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    let _ = PremiumManager.shared.isPremium = false
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(Color.black)
}

#Preview("Card — LOCKED, Urdu, Light") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    let _ = PremiumManager.shared.isPremium = false
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

// MARK: Pending (premium, not done) previews

#Preview("Card — Pending, English, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    let _ = PremiumManager.shared.isPremium = true
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(Color.black)
}

#Preview("Card — Pending, English, Light") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    let _ = PremiumManager.shared.isPremium = true
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#Preview("Card — Pending, Urdu, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    let _ = PremiumManager.shared.isPremium = true
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(Color.black)
}

#Preview("Card — Pending, Urdu, Light") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    let _ = PremiumManager.shared.isPremium = true
    return VStack(spacing: 16) {
        DailyChallengeCard()
    }
    .padding(20)
    .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

// MARK: Done (premium, completed) previews
//
// DailyChallengeManager.isCompletedToday is driven by UserDefaults and cannot be directly
// overridden from a preview without running the full completion flow. We render the done
// visual directly here using the same layout helpers, mirroring the pattern used in the
// previous implementation for faithful preview coverage.

private struct _DebugDoneCard: View {
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
                EmIconChip(sfSymbol: "brain.head.profile", size: 46)
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(DailyChallengeStrings.dailyChallenge(lang))
                            .font(EmType.serif(20, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2).multilineTextAlignment(.leading)
                    }
                    let subLine = "\(DailyChallengeStrings.doneForToday(lang).uppercased()) · 🔥 5 · +25 sawab"
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
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 20, weight: .semibold)).foregroundColor(.white)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(DailyChallengeStrings.dailyChallenge(lang))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText).lineLimit(2)
                Text("\(DailyChallengeStrings.doneForToday(lang)) · 🔥 5 · +25 sawab")
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

#Preview("Card — Done, English, Emerald") {
    _DebugDoneCard(theme: .nightSanctuary, language: .english)
        .padding(20)
        .background(Color.black)
}

#Preview("Card — Done, English, Light") {
    _DebugDoneCard(theme: .warmInviting, language: .english)
        .padding(20)
        .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#Preview("Card — Done, Urdu, Emerald") {
    _DebugDoneCard(theme: .nightSanctuary, language: .urdu)
        .padding(20)
        .background(Color.black)
}

#Preview("Card — Done, Urdu, Light") {
    _DebugDoneCard(theme: .warmInviting, language: .urdu)
        .padding(20)
        .background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#endif
