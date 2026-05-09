//
//  DuasManager.swift
//  Thaqalayn
//
//  Loads the 20-entry daily_duas.json bundle and exposes it for SwiftUI views.
//

import Foundation
import Combine

@MainActor
class DuasManager: ObservableObject {
    static let shared = DuasManager()

    @Published var duas: [DailyDua] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadDuas()
    }

    func loadDuas() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "daily_duas", withExtension: "json") else {
            errorMessage = "Could not find daily_duas.json"
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(DailyDuasData.self, from: data)
            self.duas = decoded.duas
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to load daily duas: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    /// Returns the rotation-of-the-day du'a deterministic by `dayOfYear % count`.
    /// Returns nil only if duas haven't loaded yet.
    func duaOfTheDay() -> DailyDua? {
        guard !duas.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let index = dayOfYear % duas.count
        return duas[index]
    }
}
