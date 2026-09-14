// Thaqalayn/Views/Passages/QuizStrings.swift
import Foundation

/// Chrome copy for the passage quiz. English only, plain spelling, no em dash.
enum QuizStrings {
    static let title = "Test yourself"
    static let entry = "Test yourself"
    static let hint = "Tap an answer to check it"
    static let why = "Why"
    static let readInPassage = "Read this in the passage"
    static let next = "Next question"
    static let seeResults = "See results"
    static let missed = "What you missed"
    static let tryAgain = "Try again"
    static let backToPassage = "Back to passage"
    static let premium = "PREMIUM"

    static func question(_ n: Int, of total: Int) -> String { "Question \(n) of \(total)" }
    static func score(_ score: Int, of total: Int) -> String { "\(score) of \(total)" }
    static func scoreShort(_ score: Int, of total: Int) -> String { "\(score)/\(total)" }
    static func verse(_ n: Int) -> String { "Verse \(n)" }

    /// Where "Read this in the passage" lands, in the reader's words.
    static func anchorLabel(_ location: String) -> String {
        let parts = location.split(separator: ".")
        if parts.first == "essay" { return "Essay" }
        if parts.first == "perspectives" { return "Perspectives" }
        guard parts.count >= 3, let v = Int(parts[1]) else { return "" }
        if parts[2] == "narrations" { return "Narration on verse \(v)" }
        if parts[2] == "note" { return "Note on verse \(v)" }
        return "Verse \(v)"
    }

    static func verdict(_ score: Int, of total: Int) -> String {
        switch score {
        case total: return "You understood this passage."
        case (total - 1)...: return "You understood this passage."
        case (total / 2)...: return "Most of it landed. Read the missed points again."
        default: return "Worth another read before moving on."
        }
    }
}
