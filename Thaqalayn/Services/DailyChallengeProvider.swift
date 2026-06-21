//
//  DailyChallengeProvider.swift
//  Thaqalayn
//
//  Loads daily_challenges.json and returns today's challenge deterministically.
//

import Foundation
import Combine

@MainActor
final class DailyChallengeProvider: ObservableObject {
    static let shared = DailyChallengeProvider()

    @Published private(set) var today: DailyChallenge

    private let cacheKey = "ThaqalaynDailyChallengeCache"
    private let all: [DailyChallenge]

    private init() {
        guard let url = Bundle.main.url(forResource: "daily_challenges", withExtension: "json") else {
            fatalError("daily_challenges.json missing from bundle")
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([DailyChallenge].self, from: data)
            guard !decoded.isEmpty else {
                fatalError("daily_challenges.json must contain at least one entry")
            }
            self.all = decoded
        } catch {
            fatalError("Failed to parse daily_challenges.json: \(error)")
        }

        self.today = DailyChallengeProvider.resolve(all: all, cacheKey: cacheKey)
    }

    /// Re-evaluate today's challenge. Called when the app becomes active across a date boundary.
    func refreshIfDayChanged() {
        let resolved = DailyChallengeProvider.resolve(all: all, cacheKey: cacheKey)
        if resolved.id != today.id {
            today = resolved
        }
    }

    // MARK: - Deterministic daily pick

    private static func resolve(all: [DailyChallenge], cacheKey: String) -> DailyChallenge {
        let dateString = todayDateString()
        let cache = UserDefaults.standard.dictionary(forKey: cacheKey)

        if let cache = cache,
           let cachedDate = cache["date"] as? String,
           let cachedIndex = cache["index"] as? Int,
           cachedDate == dateString,
           cachedIndex >= 0,
           cachedIndex < all.count {
            return all[cachedIndex]
        }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % all.count

        let payload: [String: Any] = ["date": dateString, "index": index]
        UserDefaults.standard.set(payload, forKey: cacheKey)

        return all[index]
    }

    private static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}
