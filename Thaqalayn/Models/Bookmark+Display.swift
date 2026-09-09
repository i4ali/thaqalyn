//
//  Bookmark+Display.swift
//  Thaqalayn
//
//  Display helpers for bookmark rows and cards. A bookmark stores a snapshot of
//  its text; these prefer the live bundled data (the verse's translation, the
//  passage's title) and fall back to the snapshot, which stays on the synced
//  record untouched.
//

import Foundation

@MainActor
extension Bookmark {
    /// The saved passage, once the passage index has loaded. Nil for a verse bookmark.
    var passageRef: PassageRef? {
        guard let passageIndex else { return nil }
        return DataManager.shared.passageIndex?.passage(surah: surahNumber, index: passageIndex)
    }

    /// The passage's current title from the shipped commentary, else the title
    /// snapshotted when it was saved. For a verse bookmark, the stored translation.
    var passageTitle: String {
        guard let passageIndex else { return verseTranslation }
        return PassageStore.shared.passage(surah: surahNumber, index: passageIndex)?.title.en ?? verseTranslation
    }

    /// "Verse 30" for a verse; "Passage 4 · Verses 30 to 39" for a passage.
    var positionLabel: String {
        guard let passageIndex else { return "Verse \(verseNumber)" }
        guard let ref = passageRef else { return "Passage \(passageIndex)" }
        return "Passage \(passageIndex) · Verses \(ref.rangeLabel)"
    }

    /// "Passage 4 · 10 verses" for a passage; nil for a verse.
    var passageMetaLabel: String? {
        guard let passageIndex else { return nil }
        guard let ref = passageRef else { return "Passage \(passageIndex)" }
        let verses = ref.verseCount == 1 ? "1 verse" : "\(ref.verseCount) verses"
        return "Passage \(passageIndex) · \(verses)"
    }

    /// "2:30 to 39" for a passage, "2:30" for a verse.
    var referenceLabel: String {
        if let ref = passageRef { return "\(surahNumber):\(ref.rangeLabel)" }
        return verseReference
    }

    /// The text a card shows under the reference. Verse: the verse's current
    /// English translation from the bundled Quran data, falling back to the
    /// snapshot (it only goes stale for display when the shipped translation
    /// edition changes, as it did with the 2026-09 move from Sahih International
    /// to Ali Quli Qarai). Passage: its title.
    var displayTranslation: String {
        if isPassage { return passageTitle }
        return DataManager.shared.quranData?
            .verses[String(surahNumber)]?[String(verseNumber)]?
            .translation ?? verseTranslation
    }
}
