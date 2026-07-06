//
//  WhatsNewStrings.swift
//  Thaqalayn
//
//  Chrome labels for the Today-tab What's New spotlight, keyed off the global
//  Settings -> Language picker. Per-item copy lives on WhatsNewItem, not here.
//

import Foundation

enum WhatsNewStrings {
    static func eyebrow(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "ما الجديد"; case .urdu: return "نیا کیا ہے"; default: return "What's New" }
    }
    static func newPill(_ l: CommentaryLanguage) -> String {
        switch l { case .arabic: return "جديد"; case .urdu: return "نیا"; default: return "New" }
    }
}
