//
//  SpecialDuasManager.swift
//  Thaqalayn
//
//  Loads special_duas.json (the Duas & Ziyarat library) from the bundle. Mirrors
//  DuasManager. Pure content; no backend.
//

import Foundation
import Combine

@MainActor
final class SpecialDuasManager: ObservableObject {
    static let shared = SpecialDuasManager()

    @Published var duas: [SpecialDua] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private init() { load() }

    func load() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "special_duas", withExtension: "json") else {
            errorMessage = "Could not find special_duas.json"
            isLoading = false
            return
        }

        do {
            let data = try Data(contentsOf: url)
            self.duas = try JSONDecoder().decode(SpecialDuasData.self, from: data).duas
            self.isLoading = false
        } catch {
            self.errorMessage = "Failed to load duas & ziyarat: \(error.localizedDescription)"
            self.isLoading = false
        }
    }
}
