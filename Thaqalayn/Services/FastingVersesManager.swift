//
//  FastingVersesManager.swift
//  Thaqalayn
//
//  Manager for Fasting in the Quran feature - verses about fasting
//  organized by category with premium gating
//

import Foundation
import Combine

class FastingVersesManager: ObservableObject {
    static let shared = FastingVersesManager()

    @Published var categories: [FastingCategory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadCategories()
    }

    func loadCategories() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "fasting_verses", withExtension: "json") else {
            errorMessage = "Could not find fasting_verses.json"
            isLoading = false
            print("FastingVersesManager: fasting_verses.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let fastingData = try decoder.decode(FastingVersesData.self, from: data)

            DispatchQueue.main.async {
                self.categories = fastingData.categories
                self.isLoading = false
                print("FastingVersesManager: Loaded \(self.categories.count) categories with \(self.totalVerses) verses")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load fasting verses: \(error.localizedDescription)"
                self.isLoading = false
                print("FastingVersesManager: Failed to load - \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Lookup Methods

    /// Get a category by ID
    func category(byId id: String) -> FastingCategory? {
        return categories.first { $0.id == id }
    }

    /// Get all verses for a specific category
    func verses(for categoryId: String) -> [FastingVerse] {
        return category(byId: categoryId)?.verses ?? []
    }

    /// Get key verses for a category
    func keyVerses(for categoryId: String) -> [FastingVerse] {
        return verses(for: categoryId).filter { $0.isKeyVerse }
    }

    // MARK: - Statistics

    /// Total number of categories
    var totalCategories: Int {
        return categories.count
    }

    /// Total number of verses across all categories
    var totalVerses: Int {
        return categories.reduce(0) { $0 + $1.verseCount }
    }

    /// Get verse count for a specific category
    func verseCount(for categoryId: String) -> Int {
        return category(byId: categoryId)?.verseCount ?? 0
    }

    // MARK: - Premium Access

    /// Check if a category is free (only "obligation" is free)
    func isCategoryFree(_ categoryId: String) -> Bool {
        return categoryId == "obligation"
    }
}
