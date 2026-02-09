//
//  PropheticParallelsManager.swift
//  Thaqalayn
//
//  Manager for Prophetic Parallels feature - connecting life situations to stories of Prophets
//  "You aren't alone; the best of humans went through this too."
//

import Foundation
import Combine

class PropheticParallelsManager: ObservableObject {
    static let shared = PropheticParallelsManager()

    @Published var parallels: [PropheticParallel] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadParallels()
    }

    func loadParallels() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "prophetic_parallels", withExtension: "json") else {
            errorMessage = "Could not find prophetic_parallels.json"
            isLoading = false
            print("❌ PropheticParallelsManager: prophetic_parallels.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let parallelsData = try decoder.decode(PropheticParallelsData.self, from: data)

            DispatchQueue.main.async {
                self.parallels = parallelsData.parallels
                self.isLoading = false
                print("✅ PropheticParallelsManager: Loaded \(self.parallels.count) prophetic parallels")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load parallels: \(error.localizedDescription)"
                self.isLoading = false
                print("❌ PropheticParallelsManager: Failed to load parallels - \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Filtering Methods

    /// Filter parallels by category
    func parallels(for category: ParallelCategory) -> [PropheticParallel] {
        return parallels.filter { $0.category == category }
    }

    /// Filter parallels by prophet name
    func parallels(byProphet prophet: String) -> [PropheticParallel] {
        return parallels.filter { $0.prophet.localizedCaseInsensitiveContains(prophet) }
    }

    /// Get all unique categories
    var categories: [ParallelCategory] {
        return ParallelCategory.allCases
    }

    /// Get all unique prophets mentioned in parallels
    var prophets: [String] {
        return Array(Set(parallels.map { $0.prophet })).sorted()
    }

    // MARK: - Search Methods

    /// Search parallels by situation, prophet name, or connection
    func search(query: String) -> [PropheticParallel] {
        guard !query.isEmpty else { return parallels }

        return parallels.filter {
            $0.situation.localizedCaseInsensitiveContains(query) ||
            $0.prophet.localizedCaseInsensitiveContains(query) ||
            $0.connection.localizedCaseInsensitiveContains(query) ||
            $0.storySummary.localizedCaseInsensitiveContains(query)
        }
    }

    // MARK: - Lookup Methods

    /// Get a parallel by ID
    func parallel(byId id: String) -> PropheticParallel? {
        return parallels.first { $0.id == id }
    }

    /// Get the related PropheticStory for a parallel (if it exists)
    func relatedStory(for parallel: PropheticParallel) -> PropheticStory? {
        guard let storyId = parallel.relatedStoryId else { return nil }
        return PropheticStoriesManager.shared.story(byId: storyId)
    }

    // MARK: - Statistics

    /// Total number of parallels
    var totalParallels: Int {
        return parallels.count
    }

    /// Total number of verses referenced across all parallels
    var totalVerses: Int {
        return parallels.reduce(0) { $0 + $1.verses.count }
    }

    /// Get count of parallels per category
    func parallelsCount(for category: ParallelCategory) -> Int {
        return parallels(for: category).count
    }
}
