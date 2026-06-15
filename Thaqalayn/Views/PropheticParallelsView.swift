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
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: ParallelCategory? = nil
    @State private var selectedParallel: PropheticParallel?
    @State private var navigateToDetail = false
    @State private var showPaywall = false

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

    // The single free parallel: first parallel of the first group (matches body render order)
    private var freeParallelID: String? { groupedParallels.first?.1.first?.id }

    // MARK: - Localized header strings (follow the global app language)

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أمثلة الأنبياء"
        case .urdu:   return "انبیائی مثالیں"
        default:      return "Prophetic Parallels"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "لستَ وحدك في محنتك"
        case .urdu:   return "اپنی آزمائشوں میں آپ اکیلے نہیں"
        default:      return "You aren't alone in your struggles"
        }
    }

    private var localizedEyebrow: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أمثلة الأنبياء"
        case .urdu:   return "انبیائی مثالیں"
        default:      return "Prophetic Parallels"
        }
    }

    private var localizedEmeraldTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "لستَ وحدك"
        case .urdu:   return "آپ اکیلے نہیں ہیں"
        default:      return "You Aren't Alone"
        }
    }

    private var localizedEmeraldSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "قصصُ أنبياءَ ساروا الطريق نفسه"
        case .urdu:   return "انہی راہوں پر چلنے والے انبیاء کی داستانیں"
        default:      return "Stories of Prophets who walked the same road"
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background with floating elements
                AdaptiveModernBackground()

                if themeManager.isMidnightEmerald {
                    emeraldContent
                } else {
                VStack(spacing: 0) {
                    // Modern header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(localizedTitle)
                                    .font(.system(size: 34, weight: .bold, design: .rounded))
                                    .foregroundColor(themeManager.primaryText)

                                Text(localizedSubtitle)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 12)
                    .environment(\.layoutDirection,
                                 languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)

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
                        RoundedRectangle(cornerRadius: 12)
                            .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.95, green: 0.95, blue: 0.95))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
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
                                            let isLocked = !premiumManager.canAccessExploreItem(isFirst: parallel.id == freeParallelID)
                                            PropheticParallelCard(parallel: parallel, isLocked: isLocked)
                                                .pressable {
                                                    if isLocked {
                                                        showPaywall = true
                                                    } else {
                                                        selectedParallel = parallel
                                                        navigateToDetail = true
                                                    }
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
        .darkScreenAura()
        .sheet(isPresented: $showPaywall) {
            PaywallView()
        }
    }

    // MARK: - Emerald

    @ViewBuilder private var emeraldContent: some View {
        VStack(spacing: 0) {
            // Header — gold eyebrow + serif title
            VStack(alignment: .leading, spacing: 7) {
                Text(localizedEyebrow.uppercased())
                    .font(.system(size: 11, weight: .bold)).tracking(3)
                    .foregroundColor(themeManager.accentColor)
                Text(localizedEmeraldTitle)
                    .font(EmType.serif(36, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(localizedEmeraldSubtitle)
                    .font(.system(size: 13.5))
                    .foregroundColor(themeManager.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 14)
            .environment(\.layoutDirection,
                         languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)

            // Search bar
            HStack(spacing: 12) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(themeManager.accentColor)
                    .font(.system(size: 15, weight: .semibold))

                TextField("Search situations or prophets...", text: $searchText)
                    .font(.system(size: 15))
                    .foregroundColor(themeManager.primaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(themeManager.glassSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
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
                    LazyVStack(spacing: 12, pinnedViews: [.sectionHeaders]) {
                        ForEach(groupedParallels, id: \.0) { category, parallels in
                            Section {
                                ForEach(parallels) { parallel in
                                    let isLocked = !premiumManager.canAccessExploreItem(isFirst: parallel.id == freeParallelID)
                                    PropheticParallelCard(parallel: parallel, isLocked: isLocked)
                                        .padding(.horizontal, 20)
                                        .pressable {
                                            if isLocked {
                                                showPaywall = true
                                            } else {
                                                selectedParallel = parallel
                                                navigateToDetail = true
                                            }
                                        }
                                }
                            } header: {
                                HStack(spacing: 8) {
                                    Image(systemName: category.icon)
                                        .font(.system(size: 13))
                                        .foregroundColor(themeManager.accentColor)

                                    Text(category.displayName.uppercased())
                                        .font(.system(size: 11, weight: .bold)).tracking(2)
                                        .foregroundColor(themeManager.accentColor)
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
    }
}

// MARK: - Parallel Card View

struct PropheticParallelCard: View {
    let parallel: PropheticParallel
    let isLocked: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
        }
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    private var emeraldBody: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: parallel.icon)
                VStack(alignment: .leading, spacing: 6) {
                    // Prophet figure pairing
                    Text(parallel.prophet(for: languageManager.selectedLanguage))
                        .font(.system(size: 11, weight: .bold)).tracking(0.5)
                        .foregroundColor(themeManager.accentColor)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 3)
                        .background(Capsule().fill(themeManager.accentChip))
                        .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))

                    HStack(spacing: 8) {
                        Text(parallel.situation(for: languageManager.selectedLanguage))
                            .font(EmType.serif(20, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)
                        if isLocked {
                            Text("PREMIUM")
                                .font(.system(size: 8.5, weight: .bold)).tracking(1)
                                .foregroundColor(themeManager.accentColor)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(themeManager.accentChip))
                                .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                        }
                    }

                    Text(parallel.connection(for: languageManager.selectedLanguage))
                        .font(.system(size: 13))
                        .foregroundColor(themeManager.secondaryText)
                        .lineLimit(2)

                    Text("\(parallel.verses.count) verse\(parallel.verses.count == 1 ? "" : "s") · \(parallel.category.displayName)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(14)
        }
        .contentShape(Rectangle())
    }

    private var legacyBody: some View {
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
                Text(parallel.prophet(for: languageManager.selectedLanguage))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(themeManager.accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(themeManager.accentColor.opacity(0.15))
                    )

                // Situation text
                HStack(spacing: 8) {
                    Text(parallel.situation(for: languageManager.selectedLanguage))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)

                    if isLocked {
                        Text("Premium")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.orange.gradient))
                    }
                }

                // Connection preview
                Text(parallel.connection(for: languageManager.selectedLanguage))
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .lineLimit(2)

                // Verse count and category
                Text("\(parallel.verses.count) verse\(parallel.verses.count == 1 ? "" : "s") • \(parallel.category.displayName)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }

            Spacer()

            // Chevron or lock icon
            Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                    radius: 12, x: 0, y: 4
                )
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
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))

                Text(title)
                    .font(.system(size: 13.5, weight: .semibold))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? themeManager.onAccentText : themeManager.accentColor)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule().fill(themeManager.accentGradient)
                } else {
                    Capsule()
                        .fill(themeManager.accentChip)
                        .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                }
            }
        }
        .buttonStyle(EmPressStyle())
    }

    private var legacyBody: some View {
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
                    Capsule()
                        .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color(red: 0.95, green: 0.95, blue: 0.95))
                        .overlay(
                            Capsule()
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
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
