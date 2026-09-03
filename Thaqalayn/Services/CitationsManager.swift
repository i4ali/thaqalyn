//
//  CitationsManager.swift
//  Thaqalayn
//
//  Loads bundled Citations/citations_{surah}.json on demand and caches per surah.
//  Surahs without a citations file simply have no citations (empty arrays), so the
//  reader degrades to today's behaviour while the surah-by-surah pass is running.
//

import Foundation

final class CitationsManager {
    static let shared = CitationsManager()

    private var cache: [Int: SurahCitations?] = [:]
    private let lock = NSLock()

    private init() {}

    /// Citations for one verse and layer, reader-visible ones only, renumbered 1..n
    /// in display order so hidden (not-found / unchecked) entries leave no gaps.
    func readerCitations(surah: Int, verse: Int, layer: TafsirLayer) -> [DisplayCitation] {
        let all = load(surah: surah)?.citations(verse: verse, layer: layer) ?? []
        return all.filter { $0.status.isReaderVisible }
            .enumerated()
            .map { DisplayCitation(number: $0.offset + 1, citation: $0.element) }
    }

    func hasCitations(surah: Int) -> Bool {
        load(surah: surah) != nil
    }

    private func load(surah: Int) -> SurahCitations? {
        lock.lock(); defer { lock.unlock() }
        if let cached = cache[surah] { return cached }
        var result: SurahCitations? = nil
        if let url = Bundle.main.url(forResource: "citations_\(surah)", withExtension: "json"),
           let data = try? Data(contentsOf: url) {
            do {
                result = try JSONDecoder().decode(SurahCitations.self, from: data)
            } catch {
                print("Error decoding citations for surah \(surah): \(error)")
            }
        }
        cache[surah] = result
        return result
    }
}

/// A citation as shown to the reader: its display number plus the record.
struct DisplayCitation: Identifiable, Equatable {
    let number: Int
    let citation: Citation
    var id: Int { citation.id }
}
