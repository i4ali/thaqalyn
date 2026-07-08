//
//  SurahExperienceCard.swift
//  Thaqalayn
//
//  Hub card for one "Inside the Sūrah" experience. Deliberately the SAME
//  EmCard/EmIconChip/serif layout as JourneyCard and DeepDiveCard so the three
//  hub sections read as peers. All sūrah experiences are premium-gated: available
//  cards show a PREMIUM chip to non-subscribers (never a lock), a plain eyebrow to
//  subscribers; coming-soon cards are dimmed with a "Soon" marker.
//

import SwiftUI

struct SurahExperienceCard: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let descriptor: SurahExperienceDescriptor
    let onTap: () -> Void

    /// An available experience the user cannot yet open (premium-gated, not
    /// subscribed). Coming-soon cards are not "locked" - they read as "Soon".
    private var locked: Bool {
        descriptor.available && !premiumManager.canAccessSurahExperience(descriptor.id)
    }

    var body: some View {
        Button(action: onTap) {
            EmCard(glow: descriptor.available,
                   borderColor: descriptor.available ? tm.accentColor.opacity(0.4) : nil) {
                HStack(spacing: 14) {
                    EmIconChip(sfSymbol: descriptor.sfSymbol, active: descriptor.available)
                    VStack(alignment: .leading, spacing: 4) {
                        if locked {
                            premiumPill
                        } else {
                            Text(JourneyStrings.surahJourneyEyebrow(lang).uppercased())
                                .emEyebrow(lang, size: 10.5, tracking: 2)
                                .foregroundColor(tm.accentColor)
                        }
                        Text(descriptor.title(lang))
                            .font(EmType.serif(22, .semiBold))
                            .foregroundColor(tm.primaryText)
                        Text(descriptor.subtitle(lang))
                            .font(.system(size: 13))
                            .foregroundColor(tm.secondaryText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    trailingGlyph
                }
                .padding(16)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
            }
            .opacity(descriptor.available ? 1 : 0.72)
        }
        .buttonStyle(EmPressStyle())
    }

    /// "PREMIUM" chip in the app's accent-chip treatment - no lock glyph, matching
    /// DeepDiveCard / DailyCrosswordCard.
    private var premiumPill: some View {
        Text(JourneyStrings.premium(lang).uppercased())
            .font(.system(size: 9, weight: .bold)).tracking(1.4)
            .foregroundColor(tm.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(tm.accentChip))
            .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
    }

    @ViewBuilder private var trailingGlyph: some View {
        if descriptor.available {
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.accentColor)
        } else {
            Text(JourneyStrings.soon(lang))
                .font(.system(size: 9, weight: .heavy)).tracking(1.4)
                .foregroundColor(tm.tertiaryText)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
        }
    }
}
