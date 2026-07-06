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
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let descriptor: DeepDiveDescriptor
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            EmCard(glow: descriptor.available,
                   borderColor: descriptor.available ? tm.accentColor.opacity(0.4) : nil) {
                HStack(spacing: 14) {
                    EmIconChip(sfSymbol: descriptor.sfSymbol, active: descriptor.available)
                    VStack(alignment: .leading, spacing: 4) {
                        if descriptor.available {
                            featuredPill
                        } else {
                            Text(descriptor.eyebrow.uppercased())
                                .emEyebrow(lang, size: 10.5, tracking: 2)
                                .foregroundColor(tm.accentColor)
                        }
                        Text(descriptor.titleEn)
                            .font(EmType.serif(22, .semiBold))
                            .foregroundColor(tm.primaryText)
                        Text(descriptor.subtitle)
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

    /// Gold "FEATURED" capsule — mirrors JourneyCard's "NEXT UP" pill so the two
    /// sections' highlighted cards match.
    private var featuredPill: some View {
        Text("FEATURED")
            .font(.system(size: 9, weight: .heavy)).tracking(1.6)
            .foregroundColor(tm.onAccentText)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(tm.accentGradient))
    }

    @ViewBuilder private var trailingGlyph: some View {
        if descriptor.available {
            Image(systemName: "chevron.right")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.accentColor)
        } else {
            // A quiet "Soon" marker rather than a lock icon — matches the app's
            // convention of never letting a coming-soon card read as a paywall.
            Text("SOON")
                .font(.system(size: 9, weight: .heavy)).tracking(1.4)
                .foregroundColor(tm.tertiaryText)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
        }
    }
}
