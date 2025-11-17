//
//  PropheticStoriesView.swift
//  Thaqalayn
//
//  Learn from the prophets - Quranic stories of Allah's messengers
//

import SwiftUI

struct PropheticStoriesView: View {
    @StateObject private var storiesManager = PropheticStoriesManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: StoryCategory? = nil
    @State private var selectedStory: PropheticStory?
    @State private var navigateToDetail = false

    var filteredStories: [PropheticStory] {
        let searchFiltered = searchText.isEmpty ? storiesManager.stories : storiesManager.search(query: searchText)

        if let category = selectedCategory {
            return searchFiltered.filter { $0.category == category }
        }
        return searchFiltered
    }

    // Group stories by category
    var groupedStories: [(StoryCategory, [PropheticStory])] {
        var grouped: [StoryCategory: [PropheticStory]] = [:]
        for story in filteredStories {
            grouped[story.category, default: []].append(story)
        }
        return grouped.sorted { $0.key.displayName < $1.key.displayName }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background with floating elements
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    // Modern header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Prophetic Stories")
                                    .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32, weight: .bold, design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
                                    .foregroundColor(themeManager.primaryText)

                                Text("Quranic accounts of the messengers")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    .background {
                        if themeManager.selectedTheme != .warmInviting {
                            Rectangle()
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.clear,
                                                    themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
                                                ],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )
                                )
                        }
                    }

                    // Search bar
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(themeManager.secondaryText)
                            .font(.system(size: 16, weight: .medium))

                        TextField("Search stories or prophets...", text: $searchText)
                            .font(.system(size: 16))
                            .foregroundColor(themeManager.primaryText)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background {
                        if themeManager.selectedTheme == .warmInviting {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // Category filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            StoryCategoryChip(
                                title: "All",
                                icon: "square.grid.2x2.fill",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )

                            ForEach(StoryCategory.allCases, id: \.self) { category in
                                StoryCategoryChip(
                                    title: category.displayName,
                                    icon: category.icon,
                                    isSelected: selectedCategory == category,
                                    action: { selectedCategory = category }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 12)

                    // Stories list
                    if storiesManager.isLoading {
                        StoryLoadingSection(message: "Loading stories...")
                    } else if let error = storiesManager.errorMessage {
                        StoryErrorSection(message: error)
                    } else if filteredStories.isEmpty {
                        StoryEmptyStateSection()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                                ForEach(groupedStories, id: \.0) { category, stories in
                                    Section {
                                        ForEach(stories) { story in
                                            PropheticStoryCardView(story: story)
                                                .onTapGesture {
                                                    selectedStory = story
                                                    navigateToDetail = true
                                                }
                                        }
                                    } header: {
                                        HStack {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(themeManager.accentColor)

                                            Text(category.displayName)
                                                .font(.system(size: 18, weight: .bold))
                                                .foregroundColor(themeManager.primaryText)
                                                .textCase(nil)

                                            Spacer()
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .background(themeManager.primaryBackground)
                                    }
                                }
                            }
                            .padding(.vertical, 12)
                        }
                    }
                }

                // Hidden NavigationLink for story detail navigation
                if let story = selectedStory {
                    NavigationLink(
                        destination: StoryDetailView(story: story),
                        isActive: $navigateToDetail
                    ) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    .hidden()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
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
    }
}

struct PropheticStoryCardView: View {
    let story: PropheticStory
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: themeManager.accentColor.opacity(0.3),
                        radius: 8
                    )

                Image(systemName: story.categoryIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Story content
            VStack(alignment: .leading, spacing: 6) {
                // Prophet name badge
                Text(story.prophet)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(themeManager.accentColor.opacity(0.15))
                    )

                Text(story.title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Verse count
                Text("\(story.verseCount) verse\(story.verseCount == 1 ? "" : "s") • \(story.category.displayName)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)

                // Verse references
                let verseRefs = story.verses.prefix(3).map { $0.verseReference }.joined(separator: " • ")
                Text(verseRefs)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
                    .lineLimit(1)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(20)
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 1.0, green: 1.0, blue: 1.0).opacity(1.0))
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        themeManager.floatingOrbColors[0].opacity(0.5),
                                        themeManager.floatingOrbColors[1].opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
    }
}

struct StoryCategoryChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))

                Text(title)
                    .font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : themeManager.primaryText)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule()
                        .fill(themeManager.accentGradient)
                        .shadow(color: themeManager.accentColor.opacity(0.3), radius: 8)
                } else {
                    if themeManager.selectedTheme == .warmInviting {
                        Capsule()
                            .fill(Color(red: 0.95, green: 0.95, blue: 0.95))
                    } else {
                        Capsule()
                            .fill(themeManager.glassEffect)
                            .overlay(
                                Capsule()
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                    }
                }
            }
        }
    }
}

struct StoryEmptyStateSection: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed.fill")
                .font(.system(size: 48))
                .foregroundColor(themeManager.secondaryText)

            Text("No stories found")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            Text("Try adjusting your search or category filter")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

private struct StoryLoadingSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(themeManager.accentColor)

            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

private struct StoryErrorSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Error Loading Stories")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    PropheticStoriesView()
}
