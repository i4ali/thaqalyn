// Thaqalayn/Models/QuizModels.swift
import Foundation

/// One shipped passage quiz, decoded from Data/quiz_<surah>.json, which is an
/// object keyed by passage index as a string. Generated and reviewed by the
/// quiz pipeline (docs/plans/2026-09-11-passage-quiz-design.md); the app never
/// writes it.
struct PassageQuiz: Codable, Identifiable, Hashable {
    let id: String
    let surah: Int
    let index: Int
    let range: [Int]
    let questions: [QuizQuestion]

    var start: Int { range.first ?? 0 }
    var end: Int { range.last ?? 0 }
    var ref: PassageRef { PassageRef(surah: surah, index: index, start: start, end: end) }
}

/// The four framings. whichVerse was removed on 2026-09-12; a file that still
/// carries one fails to decode and the store hides that surah's quizzes.
enum QuizQuestionType: String, Codable, Hashable {
    case multipleChoice, trueFalse, fillGap, whoSaid

    var label: String {
        switch self {
        case .multipleChoice: return "Multiple choice"
        case .trueFalse: return "True or false"
        case .fillGap: return "Fill the gap"
        case .whoSaid: return "Who said it"
        }
    }
}

struct QuizQuestion: Codable, Identifiable, Hashable {
    let id: String
    let type: QuizQuestionType
    let verse: Int
    let prompt: LocalizedText
    let options: [LocalizedText]
    let answer: Int
    let explanation: LocalizedText
    let anchor: QuizAnchor
}

/// Where in the passage the answer is settled. `location` is the JSON key
/// `where`, a Swift keyword.
struct QuizAnchor: Codable, Hashable {
    let location: String
    let quote: String

    enum CodingKeys: String, CodingKey {
        case location = "where"
        case quote
    }
}
