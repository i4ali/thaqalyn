//
//  FoodsManager.swift
//  Thaqalayn
//
//  Loads the "Foods of the Quran" data (offline, bundled JSON).
//

import Foundation
import Combine

class FoodsManager: ObservableObject {
    static let shared = FoodsManager()

    @Published var foods: [Food] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        load()
    }

    func load() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "foods", withExtension: "json") else {
            errorMessage = "Could not find foods.json"
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(FoodsData.self, from: data)
            DispatchQueue.main.async {
                self.foods = decoded.foods
                self.isLoading = false
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load foods: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
}
