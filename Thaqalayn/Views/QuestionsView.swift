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
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    @State private var selectedCategory: QuestionCategory? = nil
    @State private var selectedQuestion: Question?
    @State private var navigateToDetail = false

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
                                Text("Questions & Answers")
                                    .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32, weight: .bold, design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
                                    .foregroundColor(themeManager.primaryText)

                                Text("Find Quranic guidance for life's questions")
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

                        TextField("Search questions...", text: $searchText)
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
                                            QuestionCardView(question: question)
                                                .onTapGesture {
                                                    selectedQuestion = question
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
    }
}

struct QuestionCardView: View {
    let question: Question
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

                Image(systemName: question.categoryIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Question content
            VStack(alignment: .leading, spacing: 6) {
                Text(question.question)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)

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

struct CategoryChip: View {
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
