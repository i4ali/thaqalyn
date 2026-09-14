// Thaqalayn/Services/QuizStore.swift
import Foundation

/// Lazily loads Data/quiz_<surah>.json once per surah, like PassageStore does
/// for passages. A surah with no file, or a file that fails to decode, simply
/// has no quizzes; the UI hides the entry points for it.
@MainActor
final class QuizStore: ObservableObject {
    static let shared = QuizStore()

    private var cache: [Int: [String: PassageQuiz]] = [:]
    private var missing: Set<Int> = []

    init() {}

    private func load(surah: Int) -> [String: PassageQuiz] {
        if let hit = cache[surah] { return hit }
        if missing.contains(surah) { return [:] }
        guard let url = Bundle.main.url(forResource: "quiz_\(surah)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            missing.insert(surah)
            return [:]
        }
        do {
            let decoded = try JSONDecoder().decode([String: PassageQuiz].self, from: data)
            cache[surah] = decoded
            return decoded
        } catch {
            // A shipped file that fails to decode is a data bug, not "no quiz yet".
            assertionFailure("QuizStore: quiz_\(surah).json failed to decode: \(error)")
            missing.insert(surah)
            return [:]
        }
    }

    func quiz(for ref: PassageRef) -> PassageQuiz? {
        load(surah: ref.surah)[String(ref.index)]
    }

    func hasQuiz(for ref: PassageRef) -> Bool {
        quiz(for: ref) != nil
    }

    /// Passage indices of this surah that have a quiz; the list view reads it once per render.
    func quizIndices(surah: Int) -> Set<Int> {
        Set(load(surah: surah).keys.compactMap { Int($0) })
    }

    /// Quizzes shipped across the whole Quran, the denominator on the Progress
    /// tab. Every surah's file is looked up once; misses are remembered, so the
    /// scan costs 114 bundle lookups the first time and nothing after.
    func shippedQuizCount() -> Int {
        (1...114).reduce(0) { $0 + load(surah: $1).count }
    }
}
