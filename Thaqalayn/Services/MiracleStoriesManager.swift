//
//  MiracleStoriesManager.swift
//  Thaqalayn
//
//  Loads "Miracle Stories" (offline, bundled JSON).
//

import Foundation
import Combine

final class MiracleStoriesManager: ObservableObject {
    static let shared = MiracleStoriesManager()

    @Published private(set) var note = ""
    @Published private(set) var stories: [MiracleStory] = []
    @Published private(set) var errorMessage: String?

    private init() {
        load()
    }

    /// Stories grouped by figure; groups follow each figure's first story in the book.
    var groups: [MiracleStoryGroup] {
        var order: [String] = []
        var byFigure: [String: [MiracleStory]] = [:]
        for story in stories {
            let figure = story.figure.en
            if byFigure[figure] == nil { order.append(figure) }
            byFigure[figure, default: []].append(story)
        }
        return order.map { MiracleStoryGroup(figure: $0, stories: byFigure[$0] ?? []) }
    }

    private func load() {
        guard let url = Bundle.main.url(forResource: "miracle_stories", withExtension: "json") else {
            errorMessage = "Could not find miracle_stories.json"
            return
        }
        do {
            let decoded = try JSONDecoder().decode(MiracleStoriesData.self, from: Data(contentsOf: url))
            note = decoded.note
            stories = decoded.stories.sorted { $0.number < $1.number }
        } catch {
            errorMessage = "Failed to load the stories: \(error.localizedDescription)"
        }
    }
}
