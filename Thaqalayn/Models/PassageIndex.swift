// Thaqalayn/Models/PassageIndex.swift
import Foundation

/// One ruku of one surah, the unit of the passage reader. Exists for every
/// surah whether or not commentary has been generated for it.
struct PassageRef: Hashable, Identifiable {
    let surah: Int
    let index: Int
    let start: Int
    let end: Int

    var id: String { "\(surah):\(index)" }
    var verses: [Int] { Array(start...end) }
    var verseCount: Int { end - start + 1 }
    var rangeLabel: String { start == end ? "\(start)" : "\(start) to \(end)" }
}

/// Passage boundaries for all 114 surahs, derived once from quran_data.json.
struct PassageIndex {
    private let bySurah: [Int: [PassageRef]]

    init(quran: QuranData) {
        var out: [Int: [PassageRef]] = [:]
        for surah in quran.surahs {
            guard let verses = quran.verses[String(surah.number)] else { continue }
            var groups: [Int: [Int]] = [:]
            for (key, rec) in verses {
                guard let n = Int(key) else { continue }
                groups[rec.ruku, default: []].append(n)
            }
            let refs = groups.keys.sorted().enumerated().map { i, ruku -> PassageRef in
                let vs = groups[ruku]!
                return PassageRef(surah: surah.number, index: i + 1, start: vs.min()!, end: vs.max()!)
            }
            out[surah.number] = refs
        }
        bySurah = out
    }

    func passages(forSurah surah: Int) -> [PassageRef] { bySurah[surah] ?? [] }

    func passage(surah: Int, index: Int) -> PassageRef? {
        let refs = passages(forSurah: surah)
        guard index >= 1, index <= refs.count else { return nil }
        return refs[index - 1]
    }

    func passage(surah: Int, containing verse: Int) -> PassageRef? {
        passages(forSurah: surah).first { $0.start <= verse && verse <= $0.end }
    }

    func next(after ref: PassageRef) -> PassageRef? { passage(surah: ref.surah, index: ref.index + 1) }
    func previous(before ref: PassageRef) -> PassageRef? { passage(surah: ref.surah, index: ref.index - 1) }
}
