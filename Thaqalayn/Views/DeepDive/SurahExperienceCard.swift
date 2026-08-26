//
//  SurahExperienceCard.swift
//  Thaqalayn
//
//  Hub card for one "Inside the Surah" experience. Deliberately the SAME
//  EmCard/EmIconChip/serif layout as JourneyCard and DeepDiveCard so the three
//  hub sections read as peers. All surah experiences are premium-gated: available
//  cards show a PREMIUM chip to non-subscribers (never a lock), a plain eyebrow to
//  subscribers; coming-soon cards are dimmed with a "Soon" marker.
//

import SwiftUI

struct SurahExperienceCard: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    let descriptor: SurahExperienceDescriptor
    let onTap: () -> Void

    /// An available experience the user cannot yet open (premium-gated, not
    /// subscribed). Coming-soon cards are not "locked" - they read as "Soon".
    private var locked: Bool {
        descriptor.available && !premiumManager.canAccessSurahExperience(descriptor.id)
    }

    var body: some View {
        // The card body and the "Listen" affordance are two independent tap targets in
        // one ZStack: SwiftUI routes a tap to the topmost button under the finger, so the
        // headphones handles its corner and the rest of the cell still opens the visual
        // journey. Listen shows only where the narration is actually rendered - matching
        // the shelf card, so an audio-less surah (e.g. one still awaiting its render)
        // never shows a headphones that can't play.
        ZStack(alignment: .topTrailing) {
            cardButton
            if descriptor.available && descriptor.dive != nil
                && JourneyAudioAvailability.isAudioReady(descriptor.id) {
                listenButton
            }
        }
    }

    /// The card itself - a whole-cell button opening the visual journey. Named so the
    /// "Listen" affordance can overlay it without becoming part of its tap.
    private var cardButton: some View {
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
                        if locked {
                            premiumPill
                        } else {
                            Text(JourneyStrings.surahJourneyEyebrow.uppercased())
                                .emEyebrow(size: 10.5, tracking: 2)
                                .foregroundColor(tm.accentColor)
                        }
                        Text(descriptor.title())
                            .font(EmType.serif(22, .semiBold))
                            .foregroundColor(tm.primaryText)
                        Text(descriptor.subtitle())
                            .font(.system(size: 13))
                            .foregroundColor(tm.secondaryText)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    Spacer(minLength: 8)
                    trailingGlyph
                }
                .padding(16)
            }
            .opacity(descriptor.available ? 1 : 0.72)
        }
        .buttonStyle(EmPressStyle())
    }

    /// "PREMIUM" chip in the app's accent-chip treatment - no lock glyph, matching
    /// DeepDiveCard / DailyCrosswordCard.
    private var premiumPill: some View {
        Text(JourneyStrings.premium.uppercased())
            .font(.system(size: 9, weight: .bold)).tracking(1.4)
            .foregroundColor(tm.accentColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(tm.accentChip))
            .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
    }

    /// Headphones "Listen" affordance overlaid in the card's top-trailing corner - a
    /// separate tap target from the card body. Free users open the audio player; premium-
    /// locked users are routed to the paywall. No lock glyph - the PREMIUM chip already
    /// carries the gating signal.
    private var listenButton: some View {
        Button {
            guard let dive = descriptor.dive else { return }
            JourneyListenPresenter.shared.requestListen(
                dive,
                isFree: premiumManager.canAccessSurahExperience(descriptor.id),
                paywall: PaywallContext(
                    coverAssetName: descriptor.coverAssetName,
                    eyebrow: "\(JourneyStrings.surahJourneyEyebrow) \u{00B7} \(descriptor.title())"))
        } label: {
            Image(systemName: "headphones")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.accentColor)
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle())
        .padding(.top, 4)
        .padding(.trailing, 6)
        .accessibilityLabel("Listen")
    }

    @ViewBuilder private var trailingGlyph: some View {
        if descriptor.available {
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.accentColor)
        } else {
            Text(JourneyStrings.soon)
                .font(.system(size: 9, weight: .heavy)).tracking(1.4)
                .foregroundColor(tm.tertiaryText)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
        }
    }
}
