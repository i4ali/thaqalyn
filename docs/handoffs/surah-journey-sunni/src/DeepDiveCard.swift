//
//  DeepDiveCard.swift
//  Thaqalayn
//
//  Hub card for one deep dive. Deliberately the SAME EmCard/EmIconChip/serif
//  layout as JourneyCard so Deep Dives read as a peer to Sacred Seasons — not a
//  flashier headliner. Available dives glow + show a chevron (like an active
//  journey); coming-soon dives are dimmed with a "Soon" marker.
//

import SwiftUI

struct DeepDiveCard: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let descriptor: DeepDiveDescriptor
    let onTap: () -> Void

    /// An available dive the user cannot yet open (premium-gated, not subscribed).
    /// Coming-soon dives are not "locked" in this sense - they read as "Soon".
    private var locked: Bool {
        descriptor.available && !premiumManager.canAccessDeepDive(descriptor.id)
    }

    var body: some View {
        Button(action: onTap) {
            EmCard(glow: descriptor.available,
                   borderColor: descriptor.available ? tm.accentColor.opacity(0.4) : nil) {
                HStack(spacing: 14) {
                    if let cover = descriptor.coverAssetName {
                        EmCoverTile(assetName: cover, dimmed: !descriptor.available)
                    } else {
                        EmIconChip(sfSymbol: descriptor.sfSymbol, active: descriptor.available)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        // Every card carries the same "DEEP DIVE" eyebrow; live-vs-soon is
                        // carried by the chevron/SOON trailing glyph. A premium-gated dive the
                        // user can't yet open swaps the eyebrow for the PREMIUM chip.
                        if locked {
                            premiumPill
                        } else {
                            Text(JourneyStrings.deepDiveEyebrow(lang).uppercased())
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

    /// "PREMIUM" chip shown in place of the eyebrow when the dive is subscriber-only
    /// and the user is not premium - the same accent-chip treatment the app's other
    /// premium-gated cards use (Daily Crossword, journey days). No lock glyph.
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
            // Always a chevron for available dives (free or premium-gated) - the
            // PREMIUM chip carries the gated signal; no lock, per the app's style.
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.accentColor)
        } else {
            // A quiet "Soon" marker rather than a lock icon — matches the app's
            // convention of never letting a coming-soon card read as a paywall.
            Text(JourneyStrings.soon(lang))
                .font(.system(size: 9, weight: .heavy)).tracking(1.4)
                .foregroundColor(tm.tertiaryText)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
        }
    }
}
