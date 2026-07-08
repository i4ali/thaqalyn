//
//  WhatsNewCard.swift
//  Thaqalayn
//
//  Today-tab "What's New" spotlight. Announces one recently added feature; the whole
//  card taps to open it, the x dismisses it (both retire it via WhatsNewManager). Drop
//  into TodayView / EmeraldTodayView, gated on WhatsNewManager.shared.spotlight != nil.
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
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var router = DeepLinkRouter.shared

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald { emeraldCard } else { legacyCard }
        }
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
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
        }
    }

    private func dismissCard() {
        Haptics.press()
        withAnimation(.easeInOut(duration: 0.2)) { manager.dismiss(item.id) }
    }

    // MARK: Shared bits

    private var newPill: some View {
        Text(WhatsNewStrings.newPill(lang).uppercased())
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
                .background(Circle().fill(Color.white.opacity(0.06)))
        }
        .buttonStyle(.plain)
        .padding(12)
    }

    // MARK: Emerald

    private var emeraldCard: some View {
        ZStack(alignment: lang.isRTL ? .topLeading : .topTrailing) {
            Button(action: open) {
                EmCard(glow: true) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(WhatsNewStrings.eyebrow(lang).uppercased())
                            .font(.system(size: 11, weight: .bold)).tracking(2)
                            .foregroundColor(themeManager.accentColor)

                        HStack(alignment: .top, spacing: 13) {
                            EmIconChip(sfSymbol: item.sfSymbol, size: 46)
                            VStack(alignment: .leading, spacing: 5) {
                                HStack(spacing: 8) {
                                    Text(item.title(lang))
                                        .font(EmType.serif(21, .semiBold))
                                        .foregroundColor(themeManager.primaryText)
                                        .lineLimit(1)
                                    newPill
                                }
                                Text(item.blurb(lang))
                                    .font(.system(size: 13))
                                    .foregroundColor(themeManager.secondaryText)
                                    .lineSpacing(2)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }

                        Rectangle().fill(themeManager.strokeColor).frame(height: 1)

                        HStack(spacing: 6) {
                            Text(item.cta(lang))
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

    // MARK: Legacy (Light / Night Sanctuary)

    private var legacyCard: some View {
        ZStack(alignment: lang.isRTL ? .topLeading : .topTrailing) {
            Button(action: open) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(WhatsNewStrings.eyebrow(lang).uppercased())
                        .font(.system(size: 11, weight: .bold)).tracking(2)
                        .foregroundColor(themeManager.accentColor)

                    HStack(alignment: .top, spacing: 14) {
                        ZStack {
                            Circle().fill(themeManager.accentGradient).frame(width: 50, height: 50)
                                .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                            Image(systemName: item.sfSymbol)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 5) {
                            HStack(spacing: 8) {
                                Text(item.title(lang))
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(themeManager.primaryText)
                                    .lineLimit(1)
                                newPill
                            }
                            Text(item.blurb(lang))
                                .font(.system(size: 13))
                                .foregroundColor(themeManager.secondaryText)
                                .lineSpacing(2)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    Rectangle().fill(themeManager.strokeColor).frame(height: 1)

                    HStack(spacing: 6) {
                        Text(item.cta(lang))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                        Spacer()
                    }
                }
                .padding(20)
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.selectedTheme == .nightSanctuary
                              ? themeManager.glassSurface : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 20)
                            .stroke(themeManager.strokeColor, lineWidth: 1))
                        .shadow(color: themeManager.selectedTheme == .nightSanctuary
                                ? Color.black.opacity(0.45) : Color.black.opacity(0.05),
                                radius: 12, x: 0, y: 4)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(EmPressStyle.gentle)

            dismissButton()
        }
    }
}

#if DEBUG
private func _wnPreviewItem() -> WhatsNewItem { WhatsNewCatalog.all[0] }

#Preview("What's New - English, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    return WhatsNewCard(item: _wnPreviewItem(), selectedTab: .constant(0))
        .padding(20).background(Color.black)
}

#Preview("What's New - English, Light") {
    let _ = ThemeManager.shared.selectedTheme = .warmInviting
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    return WhatsNewCard(item: _wnPreviewItem(), selectedTab: .constant(0))
        .padding(20).background(Color(red: 0.97, green: 0.95, blue: 0.92))
}

#Preview("What's New - Urdu, Emerald") {
    let _ = ThemeManager.shared.selectedTheme = .nightSanctuary
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    return WhatsNewCard(item: _wnPreviewItem(), selectedTab: .constant(0))
        .padding(20).background(Color.black)
}
#endif
