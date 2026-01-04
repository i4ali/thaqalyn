//
//  QuizManager.swift
//  Thaqalayn
//
//  Service for managing surah quizzes, scoring, and results
//

import Foundation
import SwiftUI
import Combine

@MainActor
class QuizManager: ObservableObject {
    static let shared = QuizManager()

    // MARK: - Published Properties

    @Published var quizResults: [QuizResult] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    // MARK: - Private Properties

    private var quizCache: [Int: SurahQuiz] = [:]
    private let quizResultsKey = "quizResults"

    // MARK: - Initialization

    private init() {
        loadResults()
    }

    // MARK: - Quiz Loading

    /// Load quiz data for a specific surah
    func loadQuiz(for surahNumber: Int) async -> SurahQuiz? {
        // Check cache first
        if let cached = quizCache[surahNumber] {
            return cached
        }

        // Load from bundle
        let filename = "quiz_\(surahNumber)"
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("⚠️ Quiz file not found: \(filename).json")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let quiz = try decoder.decode(SurahQuiz.self, from: data)
            quizCache[surahNumber] = quiz
            print("✅ Loaded quiz for surah \(surahNumber) with \(quiz.questions.count) questions")
            return quiz
        } catch {
            print("❌ Failed to load quiz for surah \(surahNumber): \(error)")
            errorMessage = "Failed to load quiz: \(error.localizedDescription)"
            return nil
        }
    }

    /// Check if a quiz is available for a surah
    func hasQuiz(for surahNumber: Int) -> Bool {
        // Check cache
        if quizCache[surahNumber] != nil {
            return true
        }

        // Check bundle
        let filename = "quiz_\(surahNumber)"
        return Bundle.main.url(forResource: filename, withExtension: "json") != nil
    }

    // MARK: - Quiz Scoring

    /// Calculate score from quiz answers
    func calculateScore(quiz: SurahQuiz, answers: [String: String]) -> Int {
        var score = 0
        for question in quiz.questions {
            if let userAnswer = answers[question.id],
               userAnswer.lowercased() == question.correctAnswer.lowercased() {
                score += 1
            }
        }
        return score
    }

    /// Generate quiz answers for review
    func generateAnswers(quiz: SurahQuiz, userAnswers: [String: String]) -> [QuizAnswer] {
        return quiz.questions.map { question in
            let userAnswer = userAnswers[question.id] ?? ""
            return QuizAnswer(question: question, userAnswer: userAnswer)
        }
    }

    // MARK: - Result Management

    /// Save a completed quiz result
    func saveResult(_ result: QuizResult) {
        // Add to results
        quizResults.append(result)
        saveResults()

        // Check for badge achievements
        checkForBadges(result: result)

        print("✅ Saved quiz result: \(result.score)/\(result.totalQuestions) for surah \(result.surahNumber)")
    }

    /// Get best result for a surah
    func bestResult(for surahNumber: Int) -> QuizResult? {
        quizResults
            .filter { $0.surahNumber == surahNumber }
            .max { $0.score < $1.score }
    }

    /// Get all results for a surah
    func results(for surahNumber: Int) -> [QuizResult] {
        quizResults
            .filter { $0.surahNumber == surahNumber }
            .sorted { $0.completedAt > $1.completedAt }
    }

    /// Get unique surahs with completed quizzes
    var completedSurahCount: Int {
        Set(quizResults.map { $0.surahNumber }).count
    }

    /// Get average score percentage across all quizzes
    var averageScorePercentage: Double {
        guard !quizResults.isEmpty else { return 0 }
        let totalPercentage = quizResults.reduce(0.0) { sum, result in
            sum + (Double(result.score) / Double(result.totalQuestions))
        }
        return totalPercentage / Double(quizResults.count)
    }

    /// Get total sawab earned from quizzes
    var totalQuizSawab: Int {
        quizResults.reduce(0) { $0 + $1.sawabEarned }
    }

    // MARK: - Badge Checking

    private func checkForBadges(result: QuizResult) {
        // First quiz badge
        if quizResults.count == 1 {
            awardQuizBadge(.firstQuiz)
        }

        // Perfect score badge
        if result.score == result.totalQuestions {
            awardQuizBadge(.perfectScore)
        }

        // Quiz master badges
        let uniqueSurahs = completedSurahCount
        if uniqueSurahs >= 10 {
            awardQuizBadge(.quizMaster10)
        }
        if uniqueSurahs >= 50 {
            awardQuizBadge(.quizMaster50)
        }

        // Scholar badge (average > 80%)
        if averageScorePercentage >= 0.8 && quizResults.count >= 5 {
            awardQuizBadge(.scholarAverage)
        }
    }

    private func awardQuizBadge(_ badgeType: QuizBadgeType) {
        // Check if already awarded
        let awardedBadgesKey = "awardedQuizBadges"
        var awardedBadges = UserDefaults.standard.stringArray(forKey: awardedBadgesKey) ?? []

        guard !awardedBadges.contains(badgeType.rawValue) else { return }

        // Award the badge
        awardedBadges.append(badgeType.rawValue)
        UserDefaults.standard.set(awardedBadges, forKey: awardedBadgesKey)

        print("🏆 Awarded quiz badge: \(badgeType.title)")
    }

    /// Check if a quiz badge has been awarded
    func hasBadge(_ badgeType: QuizBadgeType) -> Bool {
        let awardedBadgesKey = "awardedQuizBadges"
        let awardedBadges = UserDefaults.standard.stringArray(forKey: awardedBadgesKey) ?? []
        return awardedBadges.contains(badgeType.rawValue)
    }

    /// Get all awarded quiz badges
    var awardedBadges: [QuizBadgeType] {
        let awardedBadgesKey = "awardedQuizBadges"
        let awardedBadges = UserDefaults.standard.stringArray(forKey: awardedBadgesKey) ?? []
        return awardedBadges.compactMap { QuizBadgeType(rawValue: $0) }
    }

    // MARK: - Persistence

    private func loadResults() {
        if let data = UserDefaults.standard.data(forKey: quizResultsKey),
           let decoded = try? JSONDecoder().decode([QuizResult].self, from: data) {
            self.quizResults = decoded
            print("✅ Loaded \(decoded.count) quiz results")
        }
    }

    private func saveResults() {
        if let encoded = try? JSONEncoder().encode(quizResults) {
            UserDefaults.standard.set(encoded, forKey: quizResultsKey)
        }
    }

    // MARK: - Clear Data

    /// Clear all quiz results (for testing or user request)
    func clearAllResults() {
        quizResults = []
        quizCache = [:]
        UserDefaults.standard.removeObject(forKey: quizResultsKey)
        UserDefaults.standard.removeObject(forKey: "awardedQuizBadges")
        print("🗑️ Cleared all quiz results and badges")
    }
}
