//
//  SurahListRow.swift
//  Thaqalayn
//
//  One sūrah row in the Quran-tab list (browse + search): the navigation card,
//  plus - for sūrahs with a built "Inside the Sūrah" experience - the attached
//  Read & Tafsir | Journey mode toggle. The card and the Read tab open the
//  reading view; the Journey tab opens the immersive experience (premium-gated,
//  PREMIUM chip - never a lock). Theme-adaptive (emerald + standard).
//

import SwiftUI

/// The navigation card plus, for sūrahs with an experience, the attached mode
/// toggle. Drop-in replacement for the bare PressableNavLink + ModernSurahCard
/// pattern in both themes and in search results.
struct SurahListRow: View {
    let surahWithTafsir: SurahWithTafsir
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var premiumManager = PremiumManager.shared
    @State private var presentedExperience: PresentedSurahExperience?
    @State private var showingPaywall = false

    /// The "Inside the Sūrah" experience for this sūrah, when one is built.
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
                // When a toggle is attached, the card drops its own border - the
                // row draws one combined border below so the two read as one card.
                ModernSurahCard(surah: surahWithTafsir.surah,
                                squaredBottom: experience != nil,
                                showsBorder: experience == nil)
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
            }
        }
        .overlay {
            // Single continuous outline around card + toggle - no seam between them.
            if experience != nil {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(tm.strokeColor, lineWidth: 1)
                    .allowsHitTesting(false)
            }
        }
        .fullScreenCover(item: $presentedExperience) { p in
            if let d = SurahExperienceDescriptor.byId(p.id), let dive = d.dive {
                DeepDiveView(dive: dive,
                             onClose: { presentedExperience = nil },
                             onReadSurah: {
                                 // Dismiss the descent, then hand off to the sūrah -
                                 // MainTabView's .navigateToVerse listener stashes the
                                 // deep link and HomeView pushes SurahDetailView.
                                 presentedExperience = nil
                                 DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                     NotificationCenter.default.post(
                                         name: .navigateToVerse, object: nil,
                                         userInfo: ["surah": d.surahNumber, "verse": 1])
                                 }
                             })
            }
        }
        .sheet(isPresented: $showingPaywall) { PaywallView() }
    }

    private func handleTap(_ d: SurahExperienceDescriptor) {
        if premiumManager.canAccessSurahExperience(d.id) {
            // Let the press squish play before the cover slides up.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                presentedExperience = PresentedSurahExperience(id: d.id)
            }
        } else {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) { showingPaywall = true }
        }
    }
}
