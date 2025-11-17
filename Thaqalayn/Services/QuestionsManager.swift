//
//  QuestionsManager.swift
//  Thaqalayn
//
//  Manager for Questions & Answers feature - Quranic answers to life's questions
//

import Foundation
import Combine

class QuestionsManager: ObservableObject {
    static let shared = QuestionsManager()

    @Published var questions: [Question] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadQuestions()
    }

    func loadQuestions() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "questions", withExtension: "json") else {
            errorMessage = "Could not find questions.json"
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questionsData = try decoder.decode(QuestionsData.self, from: data)

            DispatchQueue.main.async {
                self.questions = questionsData.questions
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load questions: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // Filter questions by category
    func questions(for category: QuestionCategory) -> [Question] {
        return questions.filter { $0.category == category }
    }

    // Get all unique categories
    var categories: [QuestionCategory] {
        return QuestionCategory.allCases
    }

    // Search questions by question text
    func search(query: String) -> [Question] {
        guard !query.isEmpty else { return questions }
        return questions.filter { $0.question.localizedCaseInsensitiveContains(query) }
    }

    // Get a question by ID
    func question(byId id: String) -> Question? {
        return questions.first { $0.id == id }
    }
}
