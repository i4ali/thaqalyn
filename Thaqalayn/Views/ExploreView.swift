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
    @State private var showPropheticParallels = false
    @State private var showQuestions = false
    @State private var showFasting = false
    @State private var showPropheticStories = false
    @State private var showAhlulbaytQuran = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Explore")
                        .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32, weight: .bold, design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
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
        .fullScreenCover(isPresented: $showLifeMoments) {
            LifeMomentsView()
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
                if themeManager.selectedTheme == .warmInviting {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 20)
        }
    }

    private func iconForItem(_ item: ExploreItem) -> String {
        // Use emoji for warmInviting theme, SF Symbols text for others
        switch item.destination {
        case .lifeMoments:
            return themeManager.selectedTheme == .warmInviting ? "heart.fill" : "heart.fill"
        case .propheticParallels:
            return themeManager.selectedTheme == .warmInviting ? "person.2.wave.2.fill" : "person.2.wave.2.fill"
        case .questions:
            return themeManager.selectedTheme == .warmInviting ? "questionmark.circle" : "questionmark.circle"
        case .fasting:
            return themeManager.selectedTheme == .warmInviting ? "moon.fill" : "moon.fill"
        case .propheticStories:
            return themeManager.selectedTheme == .warmInviting ? "book" : "book"
        case .ahlulbaytQuran:
            return themeManager.selectedTheme == .warmInviting ? "star.fill" : "star.fill"
        }
    }

    private func handleTap(_ destination: ExploreDestination) {
        switch destination {
        case .lifeMoments:
            showLifeMoments = true
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

#Preview {
    ExploreView()
}
