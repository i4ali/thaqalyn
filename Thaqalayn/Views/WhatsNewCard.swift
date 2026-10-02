//
//  WhatsNewCard.swift
//  Thaqalayn
//
//  Today-tab "What's New" spotlight. Announces one recently added feature; the whole
//  card taps to open it, the x dismisses it (both retire it via WhatsNewManager). Drop
//  into EmeraldTodayView, gated on WhatsNewManager.shared.spotlight != nil.
//
//  Chrome - fixed size (no ReadingSettingsManager scaling), matching DailyChallengeCard /
//  DailyCrosswordCard.
//

import SwiftUI

struct WhatsNewCard: View {
    let item: WhatsNewItem
    @Binding var selectedTab: Int

    @ObservedObject private var manager = WhatsNewManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @ObservedObject private var router = DeepLinkRouter.shared
    @State private var showingWidgetExplainer = false
    @State private var showingDuasZiyarat = false
    @State private var showingMiracleStories = false


    var body: some View {
        card
            .sheet(isPresented: $showingWidgetExplainer) {
                WidgetExplainerView()
            }
            .fullScreenCover(isPresented: $showingDuasZiyarat) {
                DuasZiyaratView()
            }
            .fullScreenCover(isPresented: $showingMiracleStories) {
                MiracleStoriesView()
            }
    }

    // MARK: Actions

    private func open() {
        Haptics.press()
        manager.markOpened(item.id)
        switch item.destination {
        case .deepDive(let diveId):
            // Let the press squish play, then switch tabs; the hub opens the dive.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                router.pendingDeepDiveId = diveId
                selectedTab = 4
            }
        case .surahExperience(let experienceId):
            // Same hand-off: stash the id, switch to the Journey hub; it opens the experience.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                router.pendingSurahExperienceId = experienceId
                selectedTab = 4
            }
        case .widgetExplainer:
            // No tab switch; the explainer presents as a sheet over Today.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                showingWidgetExplainer = true
            }
        case .duasZiyarat:
            // No tab switch; the library presents as a full-screen cover over Today.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                showingDuasZiyarat = true
            }
        case .miracleStories:
            // No tab switch; the stories present as a full-screen cover over Today.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                showingMiracleStories = true
            }
        case .quranSearch:
            // Switch to the Quran tab; it focuses its search field on arrival.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                router.pendingSearchFocus = true
                selectedTab = 1
            }
        case .journeyListen(let diveId), .journeyListenUrdu(let diveId):
            // Open the narrated Listen player app-wide (MainTabView hosts it) - no tab switch.
            // The showcased journey is free, so it plays at once (Urdu after a one-time download).
            let language: CommentaryLanguage? = item.destination == .journeyListenUrdu(diveId) ? .urdu : nil
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                if let dive = DeepDiveDescriptor.all.first(where: { $0.dive?.id == diveId })?.dive
                    ?? SurahExperienceDescriptor.all.first(where: { $0.dive?.id == diveId })?.dive {
                    JourneyListenPresenter.shared.open(dive, language: language)
                }
            }
        case .lightTheme:
            // Switch to Sage Dawn in place; Settings > Appearance switches back.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.easeInOut(duration: 0.25)) {
                    ThemeManager.shared.selectedTheme = .sageDawn
                }
            }
        case .passage(let surah, let index):
            // Take the passage deep link: the app resolves the passage's first verse,
            // switches to the Quran tab and pushes the surah at that passage.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                if let url = URL(string: "thaqalayn://passage?surah=\(surah)&index=\(index)") {
                    UIApplication.shared.open(url)
                }
            }
        }
    }

    private func dismissCard() {
        Haptics.press()
        withAnimation(.easeInOut(duration: 0.2)) { manager.dismiss(item.id) }
    }

    // MARK: Shared bits

    private var newPill: some View {
        Text(WhatsNewStrings.newPill.uppercased())
            .font(.system(size: 9, weight: .heavy)).tracking(1)
            .foregroundColor(themeManager.onAccentText)
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(Capsule().fill(themeManager.accentGradient))
    }

    private func dismissButton() -> some View {
        Button(action: dismissCard) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(themeManager.tertiaryText)
                .frame(width: 24, height: 24)
                .background(Circle().fill(themeManager.glassSurface))
        }
        .buttonStyle(.plain)
        .padding(12)
    }

    // MARK: Card

    private var card: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: open) {
                EmCard(glow: true) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(WhatsNewStrings.eyebrow.uppercased())
                            .font(.system(size: 11, weight: .bold)).tracking(2)
                            .foregroundColor(themeManager.accentColor)

                        HStack(alignment: .top, spacing: 13) {
                            EmIconChip(sfSymbol: item.sfSymbol, size: 46)
                            VStack(alignment: .leading, spacing: 5) {
                                // A long title wraps to a second line rather than truncating;
                                // the pill stays on the first line's baseline.
                                HStack(alignment: .firstTextBaseline, spacing: 8) {
                                    Text(item.title)
                                        .font(EmType.serif(21, .semiBold))
                                        .foregroundColor(themeManager.primaryText)
                                        .lineLimit(2)
                                        .fixedSize(horizontal: false, vertical: true)
                                    newPill
                                }
                                Text(item.blurb)
                                    .font(.system(size: 13))
                                    .foregroundColor(themeManager.secondaryText)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        Rectangle().fill(themeManager.strokeColor).frame(height: 1)

                        HStack(spacing: 6) {
                            Text(item.cta)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(themeManager.accentBright)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(themeManager.accentBright)
                            Spacer()
                        }
                    }
                    .padding(16)
                    .contentShape(Rectangle())
                }
            }
            .buttonStyle(EmPressStyle.gentle)

            dismissButton()
        }
    }
}

#if DEBUG
private func _wnPreviewItem() -> WhatsNewItem { WhatsNewCatalog.all[0] }

#Preview("What's New - English, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .midnightEmerald
    return WhatsNewCard(item: _wnPreviewItem(), selectedTab: .constant(0))
        .padding(20).background(Color.black)
        .preferredColorScheme(.dark)
}

#Preview("What's New - English, Light") {
    let _ = ThemeManager.shared.selectedTheme = .sageDawn
    return WhatsNewCard(item: _wnPreviewItem(), selectedTab: .constant(0))
        .padding(20).background(ThemeManager.shared.primaryBackground)
        .preferredColorScheme(.light)
}

#endif
