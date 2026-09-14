//
//  PassageStageStore.swift
//  Thaqalayn
//
//  Which passages the reader has finished Understanding. Local only, like
//  the quiz scores in QuizResultsStore: the Understand stage is a self-check
//  on the commentary, not reading progress, so it does not join the synced
//  stores. Reading progress itself stays in ProgressManager.
//

import Foundation

@MainActor
final class PassageStageStore: ObservableObject {
    static let shared = PassageStageStore()

    private static let storageKey = "passageUnderstood"
    private let defaults: UserDefaults
    /// Passage ids ("surah:index") whose Understanding has been finished.
    @Published private(set) var understood: Set<String> = []

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let saved = defaults.array(forKey: Self.storageKey) as? [String] {
            understood = Set(saved)
        }
    }

    func isUnderstood(_ ref: PassageRef) -> Bool {
        understood.contains(ref.id)
    }

    /// Passage indices understood in a surah, for the list rings.
    func understoodIndices(surah: Int) -> Set<Int> {
        let prefix = "\(surah):"
        return Set(understood.compactMap { id -> Int? in
            guard id.hasPrefix(prefix) else { return nil }
            return Int(id.dropFirst(prefix.count))
        })
    }

    var understoodCount: Int { understood.count }

    func markUnderstood(_ ref: PassageRef) {
        guard !understood.contains(ref.id) else { return }
        understood.insert(ref.id)
        save()
    }

    func unmarkUnderstood(_ ref: PassageRef) {
        guard understood.contains(ref.id) else { return }
        understood.remove(ref.id)
        save()
    }

    private func save() {
        defaults.set(Array(understood).sorted(), forKey: Self.storageKey)
    }
}
