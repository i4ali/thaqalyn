import Foundation

// MARK: - Format

enum DailyChallengeFormat: String, Codable {
    case multipleChoice
    case trueFalse
    case flashcard
    case fillInBlank
}

// MARK: - Localized text
// The struct keeps its ur/ar fields so existing JSON and content files decode
// unchanged, but the app displays English only.

struct LocalizedText: Codable, Hashable {
    let en: String
    let ur: String?
    let ar: String?

    /// The displayed (English) text.
    var text: String { en }
}

// MARK: - The challenge

struct DailyChallenge: Codable, Identifiable {
    let id: String                       // stable, e.g. "dc_001"
    let format: DailyChallengeFormat
    let topic: String                    // "quran" | "dua" | "ahlulbayt" | "event" | "practice"
    let prompt: LocalizedText            // question / statement / flashcard front / sentence-with-blank
    let options: [LocalizedText]?        // multipleChoice + fillInBlank only
    let correctIndex: Int?               // MC/fill-in → option index; trueFalse → 1=true,0=false; flashcard → nil
    let answer: LocalizedText?           // flashcard back
    let explanation: LocalizedText?      // shown after answering
    let arabicText: String?              // optional verse/du'a, shown verbatim, never translated
    let source: String?                  // optional citation, e.g. "Qur'an 2:255"

    /// True/false convenience. Convention: correctIndex 1 = true, 0 = false.
    var trueFalseAnswer: Bool? {
        guard format == .trueFalse, let i = correctIndex else { return nil }
        return i == 1
    }
}

// MARK: - Completion + streak (persisted)

struct DailyChallengeCompletion: Codable {
    let dayKey: String                   // "yyyy-MM-dd" (user's calendar)
    let challengeId: String
    let format: DailyChallengeFormat
    let wasCorrect: Bool                 // flashcards: true (self-graded "got it") or store user's choice
    let completedAt: Date
}

struct DailyChallengeStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletedDayKey: String? = nil
}

