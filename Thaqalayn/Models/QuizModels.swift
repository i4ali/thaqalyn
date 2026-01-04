//
//  QuizModels.swift
//  Thaqalayn
//
//  Data models for Surah Quiz feature
//

import Foundation

// MARK: - Quiz Data Models

struct SurahQuiz: Codable {
    let surahNumber: Int
    let questions: [QuizQuestion]
}

struct QuizQuestion: Codable, Identifiable {
    let id: String
    let type: QuizQuestionType
    let layer: Int                  // 1-5 (which tafsir layer this tests)
    let verseNumber: Int?           // Optional verse reference
    let question: String
    let options: [String]?          // For multiple choice (nil for true/false)
    let correctAnswer: String       // "A"/"B"/"C"/"D" or "true"/"false"
    let explanation: String         // Shown after answering (from tafsir)
}

enum QuizQuestionType: String, Codable {
    case multipleChoice = "multipleChoice"
    case trueFalse = "trueFalse"
}

// MARK: - Quiz Result Models

struct QuizResult: Codable, Identifiable {
    let id: UUID
    let surahNumber: Int
    let score: Int
    let totalQuestions: Int
    let level: UnderstandingLevel
    let sawabEarned: Int
    let completedAt: Date

    init(
        id: UUID = UUID(),
        surahNumber: Int,
        score: Int,
        totalQuestions: Int,
        completedAt: Date = Date()
    ) {
        self.id = id
        self.surahNumber = surahNumber
        self.score = score
        self.totalQuestions = totalQuestions
        self.level = UnderstandingLevel.fromScore(score: score, total: totalQuestions)
        self.sawabEarned = QuizResult.calculateSawab(score: score, total: totalQuestions)
        self.completedAt = completedAt
    }

    /// Calculate sawab earned based on score
    /// +50 base for completing, +10 per correct, +100 bonus for perfect
    static func calculateSawab(score: Int, total: Int) -> Int {
        var sawab = 50 // Base completion sawab
        sawab += score * 10 // Per correct answer
        if score == total {
            sawab += 100 // Perfect score bonus
        }
        return sawab
    }
}

enum UnderstandingLevel: String, Codable, CaseIterable {
    case hafiz = "hafiz"           // 10/10
    case scholar = "scholar"       // 8-9/10
    case student = "student"       // 6-7/10
    case seeker = "seeker"         // 4-5/10
    case beginner = "beginner"     // 0-3/10

    static func fromScore(score: Int, total: Int) -> UnderstandingLevel {
        guard total > 0 else { return .beginner }
        let percentage = Double(score) / Double(total)

        switch percentage {
        case 1.0:
            return .hafiz
        case 0.8..<1.0:
            return .scholar
        case 0.6..<0.8:
            return .student
        case 0.4..<0.6:
            return .seeker
        default:
            return .beginner
        }
    }

    var title: String {
        switch self {
        case .hafiz: return "Hafiz Level"
        case .scholar: return "Scholar Level"
        case .student: return "Student Level"
        case .seeker: return "Seeker Level"
        case .beginner: return "Beginner Level"
        }
    }

    var arabicTitle: String {
        switch self {
        case .hafiz: return "حافظ"
        case .scholar: return "عالم"
        case .student: return "طالب"
        case .seeker: return "باحث"
        case .beginner: return "مبتدئ"
        }
    }

    var message: String {
        switch self {
        case .hafiz:
            return "MashAllah! You have mastered this surah's wisdom!"
        case .scholar:
            return "Excellent understanding! You've grasped the deep meanings."
        case .student:
            return "Good progress! Review the highlighted areas to deepen understanding."
        case .seeker:
            return "Keep learning! The commentary holds many treasures for you."
        case .beginner:
            return "Every journey begins with a step. Review the tafsir and try again!"
        }
    }

    var icon: String {
        switch self {
        case .hafiz: return "crown.fill"
        case .scholar: return "book.closed.fill"
        case .student: return "graduationcap.fill"
        case .seeker: return "magnifyingglass"
        case .beginner: return "leaf.fill"
        }
    }

    var color: String {
        switch self {
        case .hafiz: return "gold"
        case .scholar: return "purple"
        case .student: return "blue"
        case .seeker: return "green"
        case .beginner: return "gray"
        }
    }
}

// MARK: - Quiz State

struct QuizState {
    var currentQuestionIndex: Int = 0
    var answers: [String: String] = [:]  // questionId -> userAnswer
    var isComplete: Bool = false

    var answeredCount: Int {
        answers.count
    }

    func isAnswered(_ questionId: String) -> Bool {
        answers[questionId] != nil
    }

    func isCorrect(_ question: QuizQuestion) -> Bool? {
        guard let userAnswer = answers[question.id] else { return nil }
        return userAnswer.lowercased() == question.correctAnswer.lowercased()
    }
}

// MARK: - Quiz Answer for Review

struct QuizAnswer: Codable, Identifiable {
    let id: String
    let questionId: String
    let userAnswer: String
    let correctAnswer: String
    let isCorrect: Bool
    let question: String
    let explanation: String

    init(question: QuizQuestion, userAnswer: String) {
        self.id = question.id
        self.questionId = question.id
        self.userAnswer = userAnswer
        self.correctAnswer = question.correctAnswer
        self.isCorrect = userAnswer.lowercased() == question.correctAnswer.lowercased()
        self.question = question.question
        self.explanation = question.explanation
    }
}

// MARK: - Quiz Badges

enum QuizBadgeType: String, Codable {
    case firstQuiz = "first_quiz"
    case perfectScore = "perfect_score"
    case quizMaster10 = "quiz_master_10"
    case quizMaster50 = "quiz_master_50"
    case scholarAverage = "scholar_average"

    var title: String {
        switch self {
        case .firstQuiz: return "First Steps"
        case .perfectScore: return "Perfect Score"
        case .quizMaster10: return "Quiz Explorer"
        case .quizMaster50: return "Quiz Master"
        case .scholarAverage: return "Scholar"
        }
    }

    var subtitle: String {
        switch self {
        case .firstQuiz: return "الخطوة الأولى"
        case .perfectScore: return "النتيجة الكاملة"
        case .quizMaster10: return "مستكشف"
        case .quizMaster50: return "أستاذ"
        case .scholarAverage: return "عالم"
        }
    }

    var icon: String {
        switch self {
        case .firstQuiz: return "checkmark.circle.fill"
        case .perfectScore: return "star.circle.fill"
        case .quizMaster10: return "brain.head.profile"
        case .quizMaster50: return "crown.fill"
        case .scholarAverage: return "book.closed.fill"
        }
    }

    var description: String {
        switch self {
        case .firstQuiz:
            return "Completed your first surah quiz"
        case .perfectScore:
            return "Achieved a perfect score on a surah quiz"
        case .quizMaster10:
            return "Completed quizzes for 10 different surahs"
        case .quizMaster50:
            return "Completed quizzes for 50 different surahs"
        case .scholarAverage:
            return "Maintained an average score above 80% across all quizzes"
        }
    }

    var sawabValue: Int {
        switch self {
        case .firstQuiz: return 100
        case .perfectScore: return 200
        case .quizMaster10: return 500
        case .quizMaster50: return 2500
        case .scholarAverage: return 1000
        }
    }
}
