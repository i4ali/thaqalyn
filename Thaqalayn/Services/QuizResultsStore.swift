// Thaqalayn/Services/QuizResultsStore.swift
import Foundation

struct PassageQuizResult: Codable, Equatable {
    let surah: Int
    let index: Int
    let score: Int
    let total: Int
    let completedAt: Date

    var key: String { "\(surah):\(index)" }
}

/// Best quiz score per passage. Local only, on purpose: the quiz is a
/// self-check, not reading progress, so it does not join the synced stores
/// (see docs/plans/2026-09-12-passage-quiz-app.md, decision 4).
@MainActor
final class QuizResultsStore: ObservableObject {
    static let shared = QuizResultsStore()

    private static let storageKey = "passageQuizBest"
    private let defaults: UserDefaults
    @Published private(set) var best: [String: PassageQuizResult] = [:]

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode([String: PassageQuizResult].self, from: data) {
            best = decoded
        }
    }

    func best(for ref: PassageRef) -> PassageQuizResult? {
        best[ref.id]
    }

    /// Passage index to best score, for the list rows.
    func bestScores(surah: Int) -> [Int: Int] {
        var out: [Int: Int] = [:]
        for r in best.values where r.surah == surah { out[r.index] = r.score }
        return out
    }

    // MARK: - Summary (Progress tab)

    /// Passages with at least one completed attempt.
    var takenCount: Int { best.count }

    /// Passages whose best attempt answered every question.
    var fullMarksCount: Int { best.values.filter { $0.score == $0.total }.count }

    /// Mean best score per passage, nil until a quiz has been taken. Best
    /// scores, not every attempt: the store only keeps the best.
    var averageBestScore: Double? {
        guard !best.isEmpty else { return nil }
        return Double(best.values.reduce(0) { $0 + $1.score }) / Double(best.count)
    }

    /// Keeps the higher score; an equal score keeps the newer attempt.
    func record(_ result: PassageQuizResult) {
        if let old = best[result.key], old.score > result.score { return }
        best[result.key] = result
        if let data = try? JSONEncoder().encode(best) {
            defaults.set(data, forKey: Self.storageKey)
        }
    }
}
