//
//  LifeMomentsManager.swift
//  Thaqalayn
//
//  Manager for Life Moments feature - Quranic guidance for life situations
//

import Foundation
import Combine

class LifeMomentsManager: ObservableObject {
    static let shared = LifeMomentsManager()

    @Published var moments: [LifeMoment] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadLifeMoments()
    }

    func loadLifeMoments() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "life_moments", withExtension: "json") else {
            errorMessage = "Could not find life_moments.json"
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let lifeMomentsData = try decoder.decode(LifeMomentsData.self, from: data)

            DispatchQueue.main.async {
                self.moments = lifeMomentsData.moments
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load life moments: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }

    // Filter moments by category
    func moments(for category: String) -> [LifeMoment] {
        return moments.filter { $0.category.lowercased() == category.lowercased() }
    }

    // Get all unique categories
    var categories: [String] {
        return Array(Set(moments.map { $0.category })).sorted()
    }

    // Search moments by situation text
    func search(query: String) -> [LifeMoment] {
        guard !query.isEmpty else { return moments }
        return moments.filter { $0.situation.localizedCaseInsensitiveContains(query) }
    }
}
