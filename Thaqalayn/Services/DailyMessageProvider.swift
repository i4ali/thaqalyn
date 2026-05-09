//
//  DailyMessageProvider.swift
//  Thaqalayn
//
//  Loads daily_messages.json and returns today's verse deterministically.
//

import Foundation
import Combine

@MainActor
final class DailyMessageProvider: ObservableObject {
    static let shared = DailyMessageProvider()

    @Published private(set) var today: DailyMessage

    private let cacheKey = "ThaqalaynDailyMessageCache"
    private let messages: [DailyMessage]

    private init() {
        guard let url = Bundle.main.url(forResource: "daily_messages", withExtension: "json") else {
            fatalError("daily_messages.json missing from bundle")
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DailyMessagesData.self, from: data)
            guard !decoded.messages.isEmpty else {
                fatalError("daily_messages.json must contain at least one entry")
            }
            self.messages = decoded.messages
        } catch {
            fatalError("Failed to parse daily_messages.json: \(error)")
        }

        self.today = DailyMessageProvider.resolve(messages: messages, cacheKey: cacheKey)
    }

    /// Re-evaluate today's message. Called when the app becomes active across a date boundary.
    func refreshIfDayChanged() {
        let resolved = DailyMessageProvider.resolve(messages: messages, cacheKey: cacheKey)
        if resolved.id != today.id {
            today = resolved
        }
    }

    /// Test/debug helper — peek at the next message in the rotation.
    func peekNext() -> DailyMessage {
        let nextIndex = (todayIndex() + 1) % messages.count
        return messages[nextIndex]
    }

    private func todayIndex() -> Int {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return dayOfYear % messages.count
    }

    private static func resolve(messages: [DailyMessage], cacheKey: String) -> DailyMessage {
        let dateString = Self.todayDateString()
        let cache = UserDefaults.standard.dictionary(forKey: cacheKey)

        if let cache = cache,
           let cachedDate = cache["date"] as? String,
           let cachedIndex = cache["index"] as? Int,
           cachedDate == dateString,
           cachedIndex >= 0,
           cachedIndex < messages.count {
            return messages[cachedIndex]
        }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % messages.count

        let payload: [String: Any] = ["date": dateString, "index": index]
        UserDefaults.standard.set(payload, forKey: cacheKey)

        return messages[index]
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

