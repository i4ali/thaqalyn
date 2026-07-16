//
//  DailyCrosswordProvider.swift
//  Thaqalayn
//
//  Loads daily_crosswords.json and returns today's puzzle deterministically.
//  Mirrors DailyChallengeProvider.swift exactly.
//

import Foundation
import Combine

@MainActor
final class DailyCrosswordProvider: ObservableObject {
    static let shared = DailyCrosswordProvider()

    @Published private(set) var today: DailyCrossword

    private let cacheKey = "ThaqalaynDailyCrosswordCache"
    private let all: [DailyCrossword]

    private init() {
        guard let url = Bundle.main.url(forResource: "daily_crosswords", withExtension: "json") else {
            fatalError("daily_crosswords.json missing from bundle")
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode([DailyCrossword].self, from: data)
            guard !decoded.isEmpty else {
                fatalError("daily_crosswords.json must contain at least one entry")
            }
            self.all = decoded
        } catch {
            fatalError("Failed to parse daily_crosswords.json: \(error)")
        }

        self.today = DailyCrosswordProvider.resolve(all: all, cacheKey: cacheKey)
    }

    /// Re-evaluate today's puzzle. Called when the app becomes active across a date boundary.
    func refreshIfDayChanged() {
        let resolved = DailyCrosswordProvider.resolve(all: all, cacheKey: cacheKey)
        if resolved.id != today.id {
            today = resolved
        }
    }

    // MARK: - Deterministic daily pick

    private static func resolve(all: [DailyCrossword], cacheKey: String) -> DailyCrossword {
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
