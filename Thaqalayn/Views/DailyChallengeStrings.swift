//
//  DailyChallengeStrings.swift
//  Thaqalayn
//
//  UI strings for the Daily Challenge feature.
//

import Foundation

enum DailyChallengeStrings {

    // MARK: - Eyebrow

    static let dailyChallenge = "Daily Challenge"

    // MARK: - Buttons / actions

    static let start = "Start"
    static let doneForToday = "Done for today"
    static let comeBackTomorrow = "Come back tomorrow"

    // MARK: - Answer feedback

    static let correct = "Correct"
    static let notQuite = "Not quite"

    // MARK: - Flashcard

    static let flipCard = "Tap to flip"
    static let gotIt = "Got it"
    static let reviewAgain = "Review again"

    // MARK: - True / False labels

    static let trueLabel = "True"
    static let falseLabel = "False"

    // MARK: - Streak

    /// "N day(s)" with proper singular/plural.
    static func dayUnit(_ count: Int) -> String {
        count == 1 ? "1 day" : "\(count) days"
    }

    /// Full streak label, e.g. "5-day streak"
    static func streakLabel(_ count: Int) -> String {
        "\(dayUnit(count)) streak"
    }

    // MARK: - Format teasers (shown on the entry card before the sheet opens)

    static func teaser(for format: DailyChallengeFormat) -> String {
        switch format {
        case .multipleChoice: return "Pick the right answer"
        case .trueFalse:      return "True or false?"
        case .flashcard:      return "Flashcard - flip to test yourself"
        case .fillInBlank:    return "Fill in the blank"
        }
    }

    // MARK: - Completion screen

    static let completionTitle = "Well done"
    static let doneButton = "Done"
}
