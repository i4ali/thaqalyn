// Thaqalayn/Utilities/PassageMarkup.swift
import SwiftUI
import UIKit

/// Citation markers "[n]" inside passage prose. Rendered as superscript links so
/// a tap opens the source sheet for source s<n>.
enum PassageMarkup {
    enum Segment: Equatable {
        case text(String)
        case marker(Int)
    }

    static let scheme = "thaqalayn-source"
    private static let markerRegex = try! NSRegularExpression(pattern: #"\[(\d+)\]"#)

    static func segments(_ text: String) -> [Segment] {
        guard !text.isEmpty else { return [] }
        var out: [Segment] = []
        var cursor = text.startIndex
        let ns = text as NSString
        for m in markerRegex.matches(in: text, range: NSRange(location: 0, length: ns.length)) {
            guard let whole = Range(m.range, in: text), let numRange = Range(m.range(at: 1), in: text) else { continue }
            if cursor < whole.lowerBound { out.append(.text(String(text[cursor..<whole.lowerBound]))) }
            out.append(.marker(Int(text[numRange]) ?? 0))
            cursor = whole.upperBound
        }
        if cursor < text.endIndex { out.append(.text(String(text[cursor...]))) }
        return out
    }

    /// Distinct marker numbers in order of first appearance.
    static func markerNumbers(_ text: String) -> [Int] {
        var seen: [Int] = []
        for case .marker(let n) in segments(text) where !seen.contains(n) { seen.append(n) }
        return seen
    }

    static func url(forSource n: Int) -> URL { URL(string: "\(scheme)://\(n)")! }

    static func sourceNumber(from url: URL) -> Int? {
        guard url.scheme == scheme else { return nil }
        return Int(url.host ?? "")
    }

    /// Prose with markers turned into small raised accent-coloured numbers that link
    /// to `thaqalayn-source://n`. `baseFont` is the already scaled body font.
    static func attributed(_ text: String, baseFont: UIFont, color: UIColor, accent: UIColor) -> AttributedString {
        var result = AttributedString()
        let markerFont = baseFont.withSize(baseFont.pointSize * 0.62)
        for seg in segments(text) {
            switch seg {
            case .text(let s):
                var a = AttributedString(s)
                a.font = baseFont
                a.foregroundColor = color
                result.append(a)
            case .marker(let n):
                var a = AttributedString("\(n)")
                a.font = markerFont
                a.foregroundColor = accent
                a.baselineOffset = baseFont.pointSize * 0.35
                a.link = url(forSource: n)
                result.append(a)
            }
        }
        return result
    }
}
