//
//  AhlulbaytQuranView.swift
//  Thaqalayn
//
//  Ahl al-Bayt in the Quran - Verses honoring the Prophet's purified family
//

import SwiftUI

struct AhlulbaytQuranView: View {
    @StateObject private var ahlulbaytManager = AhlulbaytQuranManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: AhlulbaytCategory? = nil
    @State private var selectedEntry: AhlulbaytEntry?
    @State private var navigateToDetail = false
    @State private var showPaywall = false

    // The single free entry: first entry of the first rendered group
    private var freeEntryID: String? { groupedEntries.first?.1.first?.id }

    var filteredEntries: [AhlulbaytEntry] {
        let searchFiltered = searchText.isEmpty ? ahlulbaytManager.entries : ahlulbaytManager.search(query: searchText)

        if let category = selectedCategory {
            return searchFiltered.filter { $0.category == category }
        }
        return searchFiltered
    }

    // Group entries by category
    var groupedEntries: [(AhlulbaytCategory, [AhlulbaytEntry])] {
        var grouped: [AhlulbaytCategory: [AhlulbaytEntry]] = [:]
        for entry in filteredEntries {
            grouped[entry.category, default: []].append(entry)
        }
        return grouped.sorted { $0.key.displayName < $1.key.displayName }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background with floating elements
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    if themeManager.isMidnightEmerald {
                        emeraldHeader
                        emeraldSearchBar
                        emeraldCategoryFilter
                    } else {
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

                        TextField("Search verses or members...", text: $searchText)
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
                            AhlulbaytCategoryChip(
                                title: "All",
                                icon: "square.grid.2x2.fill",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )

                            ForEach(AhlulbaytCategory.allCases, id: \.self) { category in
                                AhlulbaytCategoryChip(
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
                    }

                    // Entries list
                    if ahlulbaytManager.isLoading {
                        AhlulbaytLoadingSection(message: "Loading entries...")
                    } else if let error = ahlulbaytManager.errorMessage {
                        AhlulbaytErrorSection(message: error)
                    } else if filteredEntries.isEmpty {
                        AhlulbaytEmptyStateSection()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                                ForEach(groupedEntries, id: \.0) { category, entries in
                                    Section {
                                        ForEach(entries) { entry in
                                            let isLocked = !premiumManager.canAccessExploreItem(isFirst: entry.id == freeEntryID)
                                            AhlulbaytEntryCardView(entry: entry, isLocked: isLocked)
                                                .pressable {
                                                    if isLocked {
                                                        showPaywall = true
                                                    } else {
                                                        selectedEntry = entry
                                                        navigateToDetail = true
                                                    }
                                                }
                                        }
                                    } header: {
                                        if themeManager.isMidnightEmerald {
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
                                        } else {
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
                            }
                            .padding(.vertical, 12)
                            .environment(\.layoutDirection,
                                         languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
                        }
                    }
                }

                // Hidden NavigationLink for entry detail navigation
                if let entry = selectedEntry {
                    NavigationLink(
                        destination: AhlulbaytEntryDetailView(entry: entry),
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

    private var emeraldHeader: some View {
        VStack(alignment: .leading, spacing: 7) {
            Text(localizedEyebrow.uppercased())
                .font(.system(size: 11, weight: .bold)).tracking(3)
                .foregroundColor(themeManager.accentColor)
            Text(localizedTitle)
                .font(EmType.serif(36, .semiBold))
                .foregroundColor(themeManager.primaryText)
                .fixedSize(horizontal: false, vertical: true)
            Text(localizedSubtitle)
                .font(.system(size: 13.5))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .padding(.bottom, 14)
        .environment(\.layoutDirection,
                     languageManager.selectedLanguage.isRTL ? .rightToLeft : .leftToRight)
    }

    // MARK: - Localized header strings (follow the global app language)

    private var localizedEyebrow: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "العترة الطاهرة"
        case .urdu:   return "اہلِ بیت اطہار"
        default:      return "The Purified Family"
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أهل البيت في القرآن"
        case .urdu:   return "قرآن میں اہلِ بیت"
        default:      return "Ahl al-Bayt in the Quran"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "آياتٌ في فضل آل النبي (ص)"
        case .urdu:   return "آلِ رسول کی شان میں آیات"
        default:      return "Verses honoring the Prophet's family"
        }
    }

    private var emeraldSearchBar: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(themeManager.accentColor)
                .font(.system(size: 15, weight: .medium))

            TextField("Search verses or members...", text: $searchText)
                .font(.system(size: 16))
                .foregroundColor(themeManager.primaryText)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.accentChip)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 14)
    }

    private var emeraldCategoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                AhlulbaytCategoryChip(
                    title: "All",
                    icon: "square.grid.2x2.fill",
                    isSelected: selectedCategory == nil,
                    action: { selectedCategory = nil }
                )

                ForEach(AhlulbaytCategory.allCases, id: \.self) { category in
                    AhlulbaytCategoryChip(
                        title: category.displayName,
                        icon: category.icon,
                        isSelected: selectedCategory == category,
                        action: { selectedCategory = category }
                    )
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 14)
    }
}

struct AhlulbaytEntryCardView: View {
    let entry: AhlulbaytEntry
    let isLocked: Bool
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: entry.categoryIcon)

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(entry.title(for: languageManager.selectedLanguage))
                            .font(EmType.serif(20, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                        if isLocked {
                            Text("PREMIUM")
                                .font(.system(size: 8.5, weight: .bold)).tracking(1)
                                .foregroundColor(themeManager.accentColor)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(themeManager.accentChip))
                                .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                        }
                    }

                    if !entry.ahlulbaytMembers(for: languageManager.selectedLanguage).isEmpty {
                        Text(entry.ahlulbaytMembers(for: languageManager.selectedLanguage).prefix(2).joined(separator: ", "))
                            .font(.system(size: 12.5, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                            .lineLimit(1)
                    }

                    let verseRefs = entry.verses.prefix(2).map { $0.verseReference }.joined(separator: " · ")
                    Text(verseRefs)
                        .font(.system(size: 12))
                        .foregroundColor(themeManager.tertiaryText)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Text("\(entry.verseCount)")
                    .font(EmType.serif(17, .semiBold))
                    .foregroundColor(themeManager.accentBright)
                    .frame(width: 30, height: 30)
                    .background(Circle().fill(themeManager.accentChip))
                    .overlay(Circle().stroke(themeManager.accentColor, lineWidth: 1))

                Image(systemName: isLocked ? "lock.fill" : "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(14)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
    }

    private var legacyBody: some View {
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

                Image(systemName: entry.categoryIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Entry content
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(entry.title(for: languageManager.selectedLanguage))
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

                // Members involved
                if !entry.ahlulbaytMembers(for: languageManager.selectedLanguage).isEmpty {
                    Text(entry.ahlulbaytMembers(for: languageManager.selectedLanguage).prefix(2).joined(separator: ", "))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .lineLimit(1)
                }

                // Verse count
                Text("\(entry.verseCount) verse\(entry.verseCount == 1 ? "" : "s") • \(entry.category.displayName)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)

                // Verse references
                let verseRefs = entry.verses.prefix(2).map { $0.verseReference }.joined(separator: " • ")
                Text(verseRefs)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
                    .lineLimit(1)
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
                .shadow(color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
    }
}

struct AhlulbaytCategoryChip: View {
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
            }
            .foregroundColor(isSelected ? themeManager.onAccentText : themeManager.accentColor)
            .padding(.horizontal, 15)
            .padding(.vertical, 9)
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

struct AhlulbaytEmptyStateSection: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(themeManager.secondaryText)

            Text("No entries found")
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

private struct AhlulbaytLoadingSection: View {
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

private struct AhlulbaytErrorSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.orange)

            Text("Error Loading Entries")
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
    AhlulbaytQuranView()
}
