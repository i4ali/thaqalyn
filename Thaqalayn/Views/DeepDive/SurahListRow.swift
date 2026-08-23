//
//  SurahListRow.swift
//  Thaqalayn
//
//  One surah row in the Quran-tab list (browse + search): the navigation card
//  plus the attached Read & Tafsir | Journey mode toggle. The card and the Read
//  tab open the reading view; the Journey tab hands off to the Journey hub, which
//  reveals this surah's Inside-the-Surah card (scroll + highlight) so the reader
//  can choose Watch or Listen (PREMIUM chip on the toggle - never a lock). Surahs
//  without a built experience show the same toggle with the Journey tab greyed
//  out and marked SOON. Theme-adaptive (emerald + standard).
//

import SwiftUI

/// The navigation card plus, for surahs with an experience, the attached mode
/// toggle. Drop-in replacement for the bare PressableNavLink + ModernSurahCard
/// pattern in both themes and in search results.
struct SurahListRow: View {
    let surahWithTafsir: SurahWithTafsir
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared

    /// The "Inside the Surah" experience for this surah, when one is built.
    private var experience: SurahExperienceDescriptor? {
        guard let d = SurahExperienceDescriptor.bySurahNumber(surahWithTafsir.surah.number),
              d.available else { return nil }
        return d
    }

    var body: some View {
        VStack(spacing: 0) {
            PressableNavLink {
                SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil)
            } label: {
                // The toggle is always attached, so the card drops its own border -
                // the row draws one combined border below so the two read as one card.
                ModernSurahCard(surah: surahWithTafsir.surah,
                                squaredBottom: true,
                                showsBorder: false)
            }
            if let d = experience {
                JourneyModeToggle(
                    descriptor: d,
                    locked: !premiumManager.canAccessSurahExperience(d.id),
                    readDestination: {
                        SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil)
                    },
                    onJourney: { revealJourney(d) },
                    showsOuterBorder: false
                )
            } else {
                // No experience built yet: same toggle, Journey greyed out + SOON.
                JourneyModeToggle(
                    descriptor: nil,
                    locked: false,
                    readDestination: {
                        SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil)
                    },
                    onJourney: {},
                    comingSoon: true,
                    showsOuterBorder: false
                )
            }
        }
        .overlay {
            // Single continuous outline around card + toggle - no seam between them.
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(tm.strokeColor, lineWidth: 1)
                .allowsHitTesting(false)
        }
    }

    /// The Journey tab no longer dives straight in - it hands off to the Journey hub,
    /// which reveals this surah's Inside-the-Surah card (scroll + highlight) so the
    /// reader chooses Watch or Listen. The small delay lets the tab's press-squish play
    /// before the tab switch; gating is applied where each mode is presented.
    private func revealJourney(_ d: SurahExperienceDescriptor) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            NotificationCenter.default.post(
                name: .revealSurahExperience, object: nil,
                userInfo: ["id": d.id])
        }
    }
}
