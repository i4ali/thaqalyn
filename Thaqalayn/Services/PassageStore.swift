// Thaqalayn/Services/PassageStore.swift
import Foundation

/// Lazily loads Data/passages_<surah>.json (one file per surah, keyed by the
/// passage index as a string) and caches it. A missing file means no
/// commentary has been generated for that surah yet.
@MainActor
final class PassageStore: ObservableObject {
    static let shared = PassageStore()

    private var cache: [Int: [String: Passage]] = [:]
    private var missing: Set<Int> = []

    init() {}

    private func load(surah: Int) -> [String: Passage] {
        if let cached = cache[surah] { return cached }
        if missing.contains(surah) { return [:] }
        guard let url = Bundle.main.url(forResource: "passages_\(surah)", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            missing.insert(surah)
            return [:]
        }
        do {
            let decoded = try JSONDecoder().decode([String: Passage].self, from: data)
            cache[surah] = decoded
            return decoded
        } catch {
            // A shipped file that fails to decode is a data bug, not "no commentary yet".
            // Surface it in debug builds instead of silently hiding the surah.
            assertionFailure("PassageStore: passages_\(surah).json failed to decode: \(error)")
            missing.insert(surah)
            return [:]
        }
    }

    func passage(surah: Int, index: Int) -> Passage? { load(surah: surah)[String(index)] }
    func hasCommentary(surah: Int, index: Int) -> Bool { passage(surah: surah, index: index) != nil }
    func passageCount(withCommentary surah: Int) -> Int { load(surah: surah).count }

    /// Display title for a passage: the commentary title when it has shipped,
    /// else "Verses X to Y". Every list, card and Continue Reading line uses this.
    func title(for ref: PassageRef) -> String {
        passage(surah: ref.surah, index: ref.index)?.title.en ?? "Verses \(ref.rangeLabel)"
    }
}
