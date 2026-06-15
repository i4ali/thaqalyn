//
//  PropheticStoriesManager.swift
//  Thaqalayn
//
//  Manager for Prophetic Stories feature - Quranic stories of prophets
//  Learn from the lives and trials of Allah's messengers
//

import Foundation
import Combine

class PropheticStoriesManager: ObservableObject {
    static let shared = PropheticStoriesManager()

    @Published var stories: [PropheticStory] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadStories()
    }

    func loadStories() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "prophetic_stories", withExtension: "json") else {
            errorMessage = "Could not find prophetic_stories.json"
            isLoading = false
            print("❌ PropheticStoriesManager: prophetic_stories.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let storiesData = try decoder.decode(PropheticStoriesData.self, from: data)

            DispatchQueue.main.async {
                self.stories = storiesData.stories
                self.isLoading = false
                print("✅ PropheticStoriesManager: Loaded \(self.stories.count) prophetic stories")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load stories: \(error.localizedDescription)"
                self.isLoading = false
                print("❌ PropheticStoriesManager: Failed to load stories - \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Filtering Methods

    /// Filter stories by category
    func stories(for category: StoryCategory) -> [PropheticStory] {
        return stories.filter { $0.category == category }
    }

    /// Filter stories by prophet name (matches any language)
    func stories(byProphet prophet: String) -> [PropheticStory] {
        return stories.filter {
            [$0.prophetEn, $0.prophetAr, $0.prophetUr].contains { name in
                name.localizedCaseInsensitiveContains(prophet)
            }
        }
    }

    /// Get all unique categories
    var categories: [StoryCategory] {
        return StoryCategory.allCases
    }

    /// Get all unique prophets mentioned in stories (English canonical names)
    var prophets: [String] {
        return Array(Set(stories.map { $0.prophetEn })).sorted()
    }

    // MARK: - Search Methods

    /// Search stories by title, prophet or short title (across EN/AR/UR)
    func search(query: String) -> [PropheticStory] {
        guard !query.isEmpty else { return stories }

        return stories.filter { s in
            let haystack: [String] = [
                s.titleEn, s.titleAr, s.titleUr,
                s.prophetEn, s.prophetAr, s.prophetUr,
                s.shortTitleEn ?? "", s.shortTitleAr ?? "", s.shortTitleUr ?? "",
            ]
            return haystack.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    // MARK: - Lookup Methods

    /// Get a story by ID
    func story(byId id: String) -> PropheticStory? {
        return stories.first { $0.id == id }
    }

    /// Get related stories for a given story
    func relatedStories(for story: PropheticStory) -> [PropheticStory] {
        return story.relatedStories.compactMap { relatedId in
            self.story(byId: relatedId)
        }
    }

    // MARK: - Statistics

    /// Total number of stories
    var totalStories: Int {
        return stories.count
    }

    /// Total number of verses referenced across all stories
    var totalVerses: Int {
        return stories.reduce(0) { $0 + $1.verseCount }
    }

    /// Get count of stories per category
    func storiesCount(for category: StoryCategory) -> Int {
        return stories(for: category).count
    }
}
