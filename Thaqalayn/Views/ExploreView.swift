//
//  ExploreView.swift
//  Thaqalayn
//
//  Table of contents style layout for discovery features
//

import SwiftUI

// MARK: - Data Model

enum ExploreSection: CaseIterable {
    case lifeAndGuidance
    case storiesAndFigures

    var title: String {
        switch self {
        case .lifeAndGuidance:
            return "Life & Guidance"
        case .storiesAndFigures:
            return "Stories & Figures"
        }
    }

    var items: [ExploreItem] {
        switch self {
        case .lifeAndGuidance:
            return [
                ExploreItem(
                    id: "lifeMoments",
                    icon: "heart.fill",
                    title: "Life Moments",
                    subtitle: "Find solace for any situation",
                    destination: .lifeMoments
                ),
                ExploreItem(
                    id: "dailyDuas",
                    icon: "hands.sparkles.fill",
                    title: "Daily Duas",
                    subtitle: "20 supplications for everyday moments",
                    destination: .dailyDuas
                ),
                ExploreItem(
                    id: "propheticParallels",
                    icon: "person.2.wave.2.fill",
                    title: "Prophetic Parallels",
                    subtitle: "You aren't alone in your struggles",
                    destination: .propheticParallels
                ),
                ExploreItem(
                    id: "questions",
                    icon: "questionmark.circle",
                    title: "Questions & Answers",
                    subtitle: "Quranic answers to questions",
                    destination: .questions
                ),
                ExploreItem(
                    id: "fasting",
                    icon: "moon.fill",
                    title: "Fasting in the Quran",
                    subtitle: "Verses about fasting & Ramadan",
                    destination: .fasting
                )
            ]
        case .storiesAndFigures:
            return [
                ExploreItem(
                    id: "propheticStories",
                    icon: "book",
                    title: "Prophetic Stories",
                    subtitle: "Accounts of the messengers",
                    destination: .propheticStories
                ),
                ExploreItem(
                    id: "ahlulbaytQuran",
                    icon: "star.fill",
                    title: "Ahl al-Bayt in Quran",
                    subtitle: "Verses honoring the family",
                    destination: .ahlulbaytQuran
                )
            ]
        }
    }
}

struct ExploreItem: Identifiable {
    let id: String
    let icon: String
    let title: String
    let subtitle: String
    let destination: ExploreDestination
}

enum ExploreDestination {
    case lifeMoments
    case dailyDuas
    case propheticParallels
    case questions
    case fasting
    case propheticStories
    case ahlulbaytQuran
}

// MARK: - View

struct ExploreView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showLifeMoments = false
    @State private var showDailyDuas = false
    @State private var showPropheticParallels = false
    @State private var showQuestions = false
    @State private var showFasting = false
    @State private var showPropheticStories = false
    @State private var showAhlulbaytQuran = false

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                EmeraldExploreView(onTap: handleTap)
            } else {
                legacyBody
            }
        }
        .fullScreenCover(isPresented: $showLifeMoments) {
            LifeMomentsView()
        }
        .fullScreenCover(isPresented: $showDailyDuas) {
            DuasView()
        }
        .fullScreenCover(isPresented: $showPropheticParallels) {
            PropheticParallelsView()
        }
        .fullScreenCover(isPresented: $showQuestions) {
            QuestionsView()
        }
        .fullScreenCover(isPresented: $showFasting) {
            FastingVersesView()
        }
        .fullScreenCover(isPresented: $showPropheticStories) {
            PropheticStoriesView()
        }
        .fullScreenCover(isPresented: $showAhlulbaytQuran) {
            AhlulbaytQuranView()
        }
    }

    private var legacyBody: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explore")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundColor(themeManager.primaryText)

                    Text("Discover Quranic wisdom")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                // Sections
                ForEach(ExploreSection.allCases, id: \.self) { section in
                    sectionView(section)
                }

                Spacer(minLength: 100)
            }
        }
    }

    @ViewBuilder
    private func sectionView(_ section: ExploreSection) -> some View {
        VStack(spacing: 0) {
            // Section header
            ExploreSectionHeader(title: section.title)

            // Section card with rows
            VStack(spacing: 0) {
                ForEach(Array(section.items.enumerated()), id: \.element.id) { index, item in
                    ExploreRow(
                        icon: iconForItem(item),
                        title: item.title,
                        subtitle: item.subtitle
                    ) {
                        handleTap(item.destination)
                    }

                    // Divider between rows (not after last row)
                    if index < section.items.count - 1 {
                        Divider()
                            .padding(.leading, 76) // Align with text, not icon
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(themeManager.strokeColor, lineWidth: 1))
                    .shadow(
                        color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                        radius: 12, x: 0, y: 4
                    )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
        }
    }

    private func iconForItem(_ item: ExploreItem) -> String {
        // Use emoji for warmInviting theme, SF Symbols text for others
        switch item.destination {
        case .lifeMoments:
            return "heart.fill"
        case .dailyDuas:
            return "hands.sparkles.fill"
        case .propheticParallels:
            return "person.2.wave.2.fill"
        case .questions:
            return "questionmark.circle"
        case .fasting:
            return "moon.fill"
        case .propheticStories:
            return "book"
        case .ahlulbaytQuran:
            return "star.fill"
        }
    }

    private func handleTap(_ destination: ExploreDestination) {
        switch destination {
        case .lifeMoments:
            showLifeMoments = true
        case .dailyDuas:
            showDailyDuas = true
        case .propheticParallels:
            showPropheticParallels = true
        case .questions:
            showQuestions = true
        case .fasting:
            showFasting = true
        case .propheticStories:
            showPropheticStories = true
        case .ahlulbaytQuran:
            showAhlulbaytQuran = true
        }
    }
}

// MARK: - Midnight Emerald — Explore

private struct EmeraldExploreView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    let onTap: (ExploreDestination) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 7) {
                    Text("DISCOVER")
                        .font(.system(size: 11, weight: .bold)).tracking(3)
                        .foregroundColor(themeManager.accentColor)
                    Text("Explore")
                        .font(EmType.serif(40, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                    Text("Discover Quranic wisdom")
                        .font(.system(size: 13.5))
                        .foregroundColor(themeManager.secondaryText)
                }
                .padding(.top, 8)

                ForEach(ExploreSection.allCases, id: \.self) { section in
                    VStack(alignment: .leading, spacing: 10) {
                        EmDivider(label: section.title)
                        VStack(spacing: 10) {
                            ForEach(section.items) { item in
                                Button { onTap(item.destination) } label: {
                                    EmCard {
                                        HStack(spacing: 14) {
                                            EmIconChip(sfSymbol: item.icon, size: 44)
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(item.title)
                                                    .font(EmType.serif(19, .semiBold))
                                                    .foregroundColor(themeManager.primaryText)
                                                Text(item.subtitle)
                                                    .font(.system(size: 12.5))
                                                    .foregroundColor(themeManager.tertiaryText)
                                                    .lineLimit(1)
                                            }
                                            Spacer(minLength: 8)
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 13, weight: .semibold))
                                                .foregroundColor(themeManager.tertiaryText)
                                        }
                                        .padding(16)
                                    }
                                }
                                .buttonStyle(EmPressStyle())
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 120)
        }
    }
}

#Preview {
    ExploreView()
}
