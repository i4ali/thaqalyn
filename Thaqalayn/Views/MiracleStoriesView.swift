//
//  MiracleStoriesView.swift
//  Thaqalayn
//
//  "Miracle Stories" - the sixteen miracles of 14 Mojzay, retold in English and
//  Urdu. A framing note, then the stories grouped by figure → MiracleStoryDetailView.
//

import SwiftUI

struct MiracleStoriesView: View {
    @StateObject private var manager = MiracleStoriesManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    header

                    if let error = manager.errorMessage {
                        ErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                noteCard

                                ForEach(manager.groups) { group in
                                    EmDivider(label: group.figure)
                                        .padding(.top, 16)
                                        .padding(.bottom, 2)
                                    ForEach(group.stories) { story in
                                        PressableNavLink {
                                            MiracleStoryDetailView(story: story)
                                        } label: {
                                            MiracleStoryCard(story: story)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(themeManager.isMidnightEmerald ? .hidden : .automatic, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura()
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: themeManager.isMidnightEmerald ? 7 : 4) {
                if themeManager.isMidnightEmerald {
                    Text("FROM 14 MOJZAY")
                        .font(.system(size: 11, weight: .bold)).tracking(3)
                        .foregroundColor(themeManager.accentColor)
                }
                Text("Miracle Stories")
                    .font(themeManager.isMidnightEmerald ? EmType.serif(34, .semiBold) : .system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(themeManager.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text("Beloved stories of the Ahl al-Bayt, in English and Urdu")
                    .font(.system(size: themeManager.isMidnightEmerald ? 13.5 : 16, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 18)
        .emCoverHeaderBandIfEmerald("MiracleStoriesCover", height: 280)
    }

    /// The framing note: what these stories are and where they come from.
    private var noteCard: some View {
        cardContainer {
            Text(manager.note)
                .font(themeManager.isMidnightEmerald
                      ? EmType.serifItalic(16 * readingSettings.scale)
                      : .system(size: 15 * readingSettings.scale, weight: .regular))
                .foregroundColor(themeManager.secondaryText)
                .lineSpacing(4 * readingSettings.scale)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // Themed card container - EmCard glass for emerald, rounded glass/white for legacy.
    @ViewBuilder
    private func cardContainer<Content: View>(@ViewBuilder _ content: () -> Content) -> some View {
        if themeManager.isMidnightEmerald {
            EmCard { content().padding(16) }
        } else {
            content()
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(themeManager.strokeColor, lineWidth: 1))
                )
        }
    }
}

struct MiracleStoryCard: View {
    let story: MiracleStory
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    /// The book's own number for the miracle, in a glass chip.
    private var numberChip: some View {
        Text("\(story.number)")
            .font(EmType.serif(20, .semiBold))
            .foregroundColor(themeManager.accentColor)
            .frame(width: 44, height: 44)
            .background(Circle().fill(themeManager.accentChip))
            .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
    }

    private var emeraldBody: some View {
        EmCard {
            HStack(spacing: 14) {
                numberChip
                VStack(alignment: .leading, spacing: 3) {
                    Text(story.title.en)
                        .font(EmType.serif(19, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(story.subtitle.en)
                        .font(.system(size: 12.5))
                        .foregroundColor(themeManager.tertiaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(14)
        }
        .contentShape(Rectangle())
    }

    private var legacyBody: some View {
        HStack(spacing: 16) {
            numberChip
            VStack(alignment: .leading, spacing: 4) {
                Text(story.title.en)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                Text(story.subtitle.en)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(themeManager.strokeColor, lineWidth: 1))
        )
        .contentShape(Rectangle())
    }
}

#Preview {
    MiracleStoriesView()
}
