//
//  DailyCrosswordModels.swift
//  Thaqalayn
//
//  Data models for the Daily Crossword feature.
//  Mirrors DailyChallengeModels.swift; reuses LocalizedText from that file.
//

import Foundation

// MARK: - Entry

/// One interlocking entry (across or down).
struct CrosswordEntry: Codable, Identifiable, Hashable {
    let num: Int
    let dir: String            // "A" or "D"
    let answer: String         // A–Z solution, uppercased
    let clue: LocalizedText    // {en, ur, ar}
    let cells: [[Int]]         // [[row,col], …], length == answer.count
    var id: String { "\(num)\(dir)" }
    var isAcross: Bool { dir == "A" }
    func cell(at i: Int) -> CellPos { CellPos(r: cells[i][0], c: cells[i][1]) }
}

struct CellPos: Hashable, Codable { let r: Int; let c: Int }

// MARK: - Puzzle

/// A full daily puzzle.
struct DailyCrossword: Codable, Identifiable {
    let id: String
    let rows: Int
    let cols: Int
    let entries: [CrosswordEntry]
    let cellNumbers: [String: Int]   // "r,c" -> number

    /// Solution letter for every filled cell, rebuilt from entries.
    var solution: [CellPos: Character] {
        var m: [CellPos: Character] = [:]
        for e in entries {
            let a = Array(e.answer)
            for (i, rc) in e.cells.enumerated() { m[CellPos(r: rc[0], c: rc[1])] = a[i] }
        }
        return m
    }
    func number(at p: CellPos) -> Int? { cellNumbers["\(p.r),\(p.c)"] }
}

// MARK: - Completion + Streak (persisted)

/// Completion record for one day.
struct DailyCrosswordCompletion: Codable {
    let dayKey: String          // "yyyy-MM-dd"
    let puzzleId: String
    let seconds: Int
    let usedHint: Bool
    let completedAt: Date
}

/// Persisted streak stats (separate from the Daily Challenge streak).
struct DailyCrosswordStreak: Codable {
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastCompletedDayKey: String? = nil

    static func next(_ s: DailyCrosswordStreak, todayKey: String, yesterdayKey: String) -> DailyCrosswordStreak {
        var n = s
        if s.lastCompletedDayKey == todayKey { return n }            // already counted
        n.currentStreak = (s.lastCompletedDayKey == yesterdayKey) ? s.currentStreak + 1 : 1
        n.longestStreak = max(n.longestStreak, n.currentStreak)
        n.lastCompletedDayKey = todayKey
        return n
    }
}
