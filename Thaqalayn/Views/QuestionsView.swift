//
//  QuestionsView.swift
//  Thaqalayn
//
//  Quranic answers to life's biggest questions with modern glassmorphism design
//

import SwiftUI

struct QuestionsView: View {
    @StateObject private var questionsManager = QuestionsManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: QuestionCategory? = nil
    @State private var selectedQuestion: Question?
    @State private var navigateToDetail = false
    @State private var showPaywall = false

    var filteredQuestions: [Question] {
        let searchFiltered = searchText.isEmpty ? questionsManager.questions : questionsManager.search(query: searchText)

        if let category = selectedCategory {
            return searchFiltered.filter { $0.category == category }
        }
        return searchFiltered
    }

    // Group questions by category
    var groupedQuestions: [(QuestionCategory, [Question])] {
        var grouped: [QuestionCategory: [Question]] = [:]
        for question in filteredQuestions {
            grouped[question.category, default: []].append(question)
        }
        return grouped.sorted { $0.key.displayName < $1.key.displayName }
    }

    // The single free question (first question of the first group in the
    // unfiltered grouping) — stable regardless of search/category filtering
    private var freeQuestionID: String? {
        var grouped: [QuestionCategory: [Question]] = [:]
        for question in questionsManager.questions {
            grouped[question.category, default: []].append(question)
        }
        return grouped.sorted { $0.key.displayName < $1.key.displayName }.first?.value.first?.id
    }

    // MARK: - Localized header strings (follow the global app language)

    private var localizedEyebrow: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "مكتبة الحكمة"
        case .urdu:   return "حکمت کا خزانہ"
        default:      return "Wisdom Library"
        }
    }

    private var localizedTitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "أسئلة وأجوبة"
        case .urdu:   return "سوالات و جوابات"
        default:      return "Questions & Answers"
        }
    }

    private var localizedSubtitle: String {
        switch languageManager.selectedLanguage {
        case .arabic: return "اعثر على هداية القرآن لأسئلة الحياة"
        case .urdu:   return "زندگی کے سوالوں کے لیے قرآنی رہنمائی"
        default:      return "Find Quranic guidance for life's questions"
        }
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
                            if themeManager.isMidnightEmerald {
                                VStack(alignment: .leading, spacing: 7) {
                                    Text(localizedEyebrow.uppercased()).font(.system(size: 11, weight: .bold)).tracking(3).foregroundColor(themeManager.accentColor)
                                    Text(localizedTitle).font(EmType.serif(34, .semiBold)).foregroundColor(themeManager.primaryText).fixedSize(horizontal: false, vertical: true)
                                    Text(localizedSubtitle).font(.system(size: 13.5)).foregroundColor(themeManager.secondaryText)
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(localizedTitle)
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(themeManager.primaryText)

                                    Text(localizedSubtitle)
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(themeManager.secondaryText)
                                }
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
                            .foregroundColor(themeManager.isMidnightEmerald ? themeManager.accentColor : themeManager.secondaryText)
                            .font(.system(size: 16, weight: .medium))

                        TextField("Search questions...", text: $searchText)
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
                            CategoryChip(
                                title: "All",
                                icon: "square.grid.2x2.fill",
                                isSelected: selectedCategory == nil,
                                action: { selectedCategory = nil }
                            )

                            ForEach(QuestionCategory.allCases, id: \.self) { category in
                                CategoryChip(
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

                    // Questions list
                    if questionsManager.isLoading {
                        LoadingSection(message: "Loading questions...")
                    } else if let error = questionsManager.errorMessage {
                        ErrorSection(message: error)
                    } else if filteredQuestions.isEmpty {
                        EmptyStateSection()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16, pinnedViews: [.sectionHeaders]) {
                                ForEach(groupedQuestions, id: \.0) { category, questions in
                                    Section {
                                        ForEach(questions) { question in
                                            let isLocked = !premiumManager.canAccessExploreItem(isFirst: question.id == freeQuestionID)
                                            QuestionCardView(question: question, isLocked: isLocked)
                                                .pressable {
                                                    if isLocked {
                                                        showPaywall = true
                                                    } else {
                                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                                                            selectedQuestion = question
                                                            navigateToDetail = true
                                                        }
                                                    }
                                                }
                                        }
                                    } header: {
                                        HStack {
                                            Image(systemName: category.icon)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundColor(themeManager.accentColor)

                                            Text(category.displayName)
                                                .font(themeManager.isMidnightEmerald ? EmType.serif(18, .semiBold) : .system(size: 18, weight: .bold))
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

                // Hidden NavigationLink for question detail navigation
                if let question = selectedQuestion {
                    NavigationLink(
                        destination: QuestionDetailView(question: question),
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
}

struct QuestionCardView: View {
    let question: Question
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
            HStack(alignment: .top, spacing: 14) {
                EmIconChip(sfSymbol: question.categoryIcon, size: 46)
                VStack(alignment: .leading, spacing: 6) {
                    HStack(alignment: .top, spacing: 8) {
                        Text(question.question(for: languageManager.selectedLanguage))
                            .font(EmType.serif(19, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(3).multilineTextAlignment(.leading)
                        if isLocked {
                            Text("PREMIUM")
                                .font(.system(size: 8.5, weight: .bold)).tracking(1)
                                .foregroundColor(themeManager.accentColor)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(Capsule().fill(themeManager.accentChip))
                                .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                        }
                    }
                    HStack(spacing: 8) {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.seal.fill").font(.system(size: 11, weight: .semibold))
                            Text("\(question.verseCount) verse\(question.verseCount == 1 ? "" : "s")").font(.system(size: 11, weight: .semibold))
                        }
                        .foregroundColor(themeManager.semanticGreen)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Capsule().fill(themeManager.semanticGreenChip))
                        Text(question.verses.prefix(2).map { $0.verseReference }.joined(separator: " · "))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText).lineLimit(1)
                    }
                }
                Spacer(minLength: 8)
                Image(systemName: isLocked ? "lock.fill" : "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(themeManager.tertiaryText)
            }
            .padding(16)
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

                Image(systemName: question.categoryIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Question content
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text(question.question(for: languageManager.selectedLanguage))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(3)
                        .multilineTextAlignment(.leading)

                    if isLocked {
                        Text("Premium")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 8).padding(.vertical, 4)
                            .background(Capsule().fill(Color.orange.gradient))
                    }
                }

                // Verse count
                Text("Answered in \(question.verseCount) verse\(question.verseCount == 1 ? "" : "s")")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)

                // Verse references
                let verseRefs = question.verses.prefix(3).map { $0.verseReference }.joined(separator: " • ")
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
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                    radius: 12, x: 0, y: 4
                )
        }
        .contentShape(Rectangle())
        .padding(.horizontal, 20)
    }
}

struct CategoryChip: View {
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
                Image(systemName: icon).font(.system(size: 13, weight: .semibold))
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .foregroundColor(isSelected ? themeManager.onAccentText : themeManager.primaryText)
            .padding(.horizontal, 16).padding(.vertical, 10)
            .background {
                if isSelected {
                    Capsule().fill(themeManager.accentGradient)
                } else {
                    Capsule().fill(themeManager.glassSurface).overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
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

struct EmptyStateSection: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "questionmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(themeManager.secondaryText)

            Text("No questions found")
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

private struct LoadingSection: View {
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

#Preview {
    QuestionsView()
}
