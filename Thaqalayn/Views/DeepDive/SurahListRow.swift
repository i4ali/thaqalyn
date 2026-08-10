//
//  SurahListRow.swift
//  Thaqalayn
//
//  One surah row in the Quran-tab list (browse + search): the navigation card
//  plus the attached Read & Tafsir | Journey mode toggle. The card and the Read
//  tab open the reading view; the Journey tab opens the immersive experience
//  (premium-gated, PREMIUM chip - never a lock). Surahs without a built
//  experience show the same toggle with the Journey tab greyed out and marked
//  SOON. Theme-adaptive (emerald + standard).
//

import SwiftUI

/// The navigation card plus, for surahs with an experience, the attached mode
/// toggle. Drop-in replacement for the bare PressableNavLink + ModernSurahCard
/// pattern in both themes and in search results.
struct SurahListRow: View {
    let surahWithTafsir: SurahWithTafsir
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @State private var presentedExperience: PresentedSurahExperience?

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
                    onJourney: { handleTap(d) },
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
        .fullScreenCover(item: $presentedExperience) { p in
            if let d = SurahExperienceDescriptor.byId(p.id), let dive = d.dive {
                DeepDiveView(dive: dive,
                             onClose: { presentedExperience = nil },
                             onReadSurah: {
                                 // Dismiss the descent, then hand off to the surah -
                                 // MainTabView's .navigateToVerse listener stashes the
                                 // deep link and HomeView pushes SurahDetailView.
                                 presentedExperience = nil
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                     NotificationCenter.default.post(
                                         name: .navigateToVerse, object: nil,
                                         userInfo: ["surah": d.surahNumber, "verse": 1])
                                 }
                             },
                             coverAssetName: d.coverAssetName,
                             lockedPaywallContext: premiumManager.canAccessSurahExperience(d.id) ? nil
                                : PaywallContext(coverAssetName: d.coverAssetName,
                                                 eyebrow: "\(JourneyStrings.surahJourneyEyebrow(languageManager.selectedLanguage)) \u{00B7} \(d.title(languageManager.selectedLanguage))"))
            }
        }
    }

    /// The Journey toggle spends real effort making this tap wanted - it breathes, sweeps
    /// light and rises embers. So the tap always opens the descent; a gated reader simply
    /// gets the veiled preview rather than being bounced to a page that sells them
    /// something else. The gate is applied where the experience is presented.
    private func handleTap(_ d: SurahExperienceDescriptor) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            presentedExperience = PresentedSurahExperience(id: d.id)
        }
    }
}
