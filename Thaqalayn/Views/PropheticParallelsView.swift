//
//  PropheticParallelsView.swift
//  Thaqalayn
//
//  "You aren't alone; the best of humans went through this too."
//  Connect life situations to stories of Prophets
//

import SwiftUI

struct PropheticParallelsView: View {
    @StateObject private var parallelsManager = PropheticParallelsManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: ParallelCategory? = nil
    @State private var selectedParallel: PropheticParallel?
    @State private var navigateToDetail = false

    var filteredParallels: [PropheticParallel] {
        let searchFiltered = searchText.isEmpty ? parallelsManager.parallels : parallelsManager.search(query: searchText)

        if let category = selectedCategory {
            return searchFiltered.filter { $0.category == category }
        }
        return searchFiltered
    }

    // Group parallels by category
    var groupedParallels: [(ParallelCategory, [PropheticParallel])] {
        var grouped: [ParallelCategory: [PropheticParallel]] = [:]
        for parallel in filteredParallels {
            grouped[parallel.category, default: []].append(parallel)
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
                                Text("Prophetic Parallels")
                                    .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32, weight: .bold, design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
                                    .foregroundColor(themeManager.primaryText)

                                Text("You aren't alone in your struggles")
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

                        TextField("Search situations or prophets...", text: $searchText)
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
                            ParallelCategoryChip(
                                title: "All",
                                icon: "square.grid.2x2.fill",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )

                            ForEach(ParallelCategory.allCases, id: \.self) { category in
                                ParallelCategoryChip(
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

                    // Parallels list
                    if parallelsManager.isLoading {
                        ParallelLoadingSection(message: "Loading parallels...")
                    } else if let error = parallelsManager.errorMessage {
                        ParallelErrorSection(message: error)
                    } else if filteredParallels.isEmpty {
                        ParallelEmptyStateSection()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                                ForEach(groupedParallels, id: \.0) { category, parallels in
                                    Section {
                                        ForEach(parallels) { parallel in
                                            PropheticParallelCard(parallel: parallel)
                                                .onTapGesture {
                                                    selectedParallel = parallel
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

                // Hidden NavigationLink for parallel detail navigation
                if let parallel = selectedParallel {
                    NavigationLink(
                        destination: ParallelDetailView(parallel: parallel),
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

// MARK: - Parallel Card View

struct PropheticParallelCard: View {
    let parallel: PropheticParallel
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Situation icon
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: themeManager.accentColor.opacity(0.3),
                        radius: 8
                    )

                Image(systemName: parallel.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Parallel content
            VStack(alignment: .leading, spacing: 6) {
                // Prophet name badge
                Text(parallel.prophet)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(themeManager.accentColor.opacity(0.15))
                    )

                // Situation text
                Text(parallel.situation)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Connection preview
                Text(parallel.connection)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)

                // Verse count and category
                Text("\(parallel.verses.count) verse\(parallel.verses.count == 1 ? "" : "s") • \(parallel.category.displayName)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
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

// MARK: - Category Chip

struct ParallelCategoryChip: View {
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
                    .lineLimit(1)
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

// MARK: - Empty State

struct ParallelEmptyStateSection: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.wave.2.fill")
                .font(.system(size: 48))
                .foregroundColor(themeManager.secondaryText)

            Text("No parallels found")
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

// MARK: - Loading Section

private struct ParallelLoadingSection: View {
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

// MARK: - Error Section

private struct ParallelErrorSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Error Loading Parallels")
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
    PropheticParallelsView()
}
