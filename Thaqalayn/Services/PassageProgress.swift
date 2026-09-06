// Thaqalayn/Services/PassageProgress.swift
import Foundation

/// Passage read state derived from the per-verse progress that ProgressManager
/// already stores and syncs. A passage is read when every verse in it is read.
enum PassageProgress {
    static func isRead(_ ref: PassageRef, readVerseKeys: Set<String>) -> Bool {
        ref.verses.allSatisfy { readVerseKeys.contains("\(ref.surah):\($0)") }
    }

    static func readCount(_ refs: [PassageRef], readVerseKeys: Set<String>) -> Int {
        refs.filter { isRead($0, readVerseKeys: readVerseKeys) }.count
    }
}
