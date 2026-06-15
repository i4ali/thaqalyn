//
//  AhlulbaytQuranManager.swift
//  Thaqalayn
//
//  Manager for Ahl al-Bayt in the Quran feature
//  Quranic verses about the Prophet's purified family
//

import Foundation
import Combine

class AhlulbaytQuranManager: ObservableObject {
    static let shared = AhlulbaytQuranManager()

    @Published var entries: [AhlulbaytEntry] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private init() {
        loadEntries()
    }

    func loadEntries() {
        isLoading = true
        errorMessage = nil

        guard let url = Bundle.main.url(forResource: "ahlulbayt_quran", withExtension: "json") else {
            errorMessage = "Could not find ahlulbayt_quran.json"
            isLoading = false
            print("❌ AhlulbaytQuranManager: ahlulbayt_quran.json not found in bundle")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let ahlulbaytData = try decoder.decode(AhlulbaytQuranData.self, from: data)

            DispatchQueue.main.async {
                self.entries = ahlulbaytData.entries
                self.isLoading = false
                print("✅ AhlulbaytQuranManager: Loaded \(self.entries.count) Ahl al-Bayt entries")
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Failed to load entries: \(error.localizedDescription)"
                self.isLoading = false
                print("❌ AhlulbaytQuranManager: Failed to load entries - \(error.localizedDescription)")
            }
        }
    }

    // MARK: - Filtering Methods

    /// Filter entries by category
    func entries(for category: AhlulbaytCategory) -> [AhlulbaytEntry] {
        return entries.filter { $0.category == category }
    }

    /// Filter entries by Ahl al-Bayt member mentioned (matches any language).
    func entries(byMember member: String) -> [AhlulbaytEntry] {
        return entries.filter { entry in
            (entry.ahlulbaytMembersEn + entry.ahlulbaytMembersAr + entry.ahlulbaytMembersUr)
                .contains { $0.localizedCaseInsensitiveContains(member) }
        }
    }

    /// Get all unique categories
    var categories: [AhlulbaytCategory] {
        return AhlulbaytCategory.allCases
    }

    /// Get all unique Ahl al-Bayt members mentioned (English canonical names).
    var allMembers: [String] {
        let allMemberNames = entries.flatMap { $0.ahlulbaytMembersEn }
        return Array(Set(allMemberNames)).sorted()
    }

    // MARK: - Search Methods

    /// Search entries by title or member name, across all languages (EN/AR/UR).
    func search(query: String) -> [AhlulbaytEntry] {
        guard !query.isEmpty else { return entries }

        return entries.filter { entry in
            let titles: [String] = [entry.titleEn, entry.titleAr, entry.titleUr]
            let shorts: [String] = [entry.shortTitleEn, entry.shortTitleAr, entry.shortTitleUr].compactMap { $0 }
            let members: [String] = entry.ahlulbaytMembersEn + entry.ahlulbaytMembersAr + entry.ahlulbaytMembersUr
            let haystack: [String] = titles + shorts + members
            return haystack.contains { $0.localizedCaseInsensitiveContains(query) }
        }
    }

    // MARK: - Lookup Methods

    /// Get an entry by ID
    func entry(byId id: String) -> AhlulbaytEntry? {
        return entries.first { $0.id == id }
    }

    /// Get related entries for a given entry
    func relatedEntries(for entry: AhlulbaytEntry) -> [AhlulbaytEntry] {
        return entry.relatedEntries.compactMap { relatedId in
            self.entry(byId: relatedId)
        }
    }

    // MARK: - Statistics

    /// Total number of entries
    var totalEntries: Int {
        return entries.count
    }

    /// Total number of verses referenced across all entries
    var totalVerses: Int {
        return entries.reduce(0) { $0 + $1.verseCount }
    }

    /// Get count of entries per category
    func entriesCount(for category: AhlulbaytCategory) -> Int {
        return entries(for: category).count
    }
}
