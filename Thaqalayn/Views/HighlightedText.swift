//
//  HighlightedText.swift
//  Thaqalayn
//
//  SwiftUI view that displays text with a highlighted word range, and optional
//  citation superscripts inserted at character offsets without altering the
//  underlying text (so TTS ranges computed on the original text stay valid).
//

import SwiftUI

/// A superscript marker to insert into displayed text at a character offset.
struct TextMarker: Equatable {
    /// Character offset in the original text where the marker is inserted (0...count).
    let offset: Int
    let label: String
    let color: Color
}

struct HighlightedText: View {
    let text: String
    let highlightRange: NSRange?
    let font: Font
    let textColor: Color
    let highlightColor: Color?
    let lineSpacing: CGFloat
    let markers: [TextMarker]
    let markerFontSize: CGFloat

    @StateObject private var themeManager = ThemeManager.shared

    init(
        text: String,
        highlightRange: NSRange?,
        font: Font = .system(size: 17, weight: .regular, design: .serif),
        textColor: Color = .primary,
        highlightColor: Color? = nil,
        lineSpacing: CGFloat = 6,
        markers: [TextMarker] = [],
        markerFontSize: CGFloat = 10
    ) {
        self.text = text
        self.highlightRange = highlightRange
        self.font = font
        self.textColor = textColor
        self.highlightColor = highlightColor
        self.lineSpacing = lineSpacing
        self.markers = markers
        self.markerFontSize = markerFontSize
    }

    /// Theme-aware default highlight color (search-result yellow).
    private var resolvedHighlightColor: Color {
        if let highlightColor = highlightColor {
            return highlightColor
        }
        return themeManager.semanticYellow.opacity(themeManager.isDarkMode ? 0.30 : 0.50)
    }

    var body: some View {
        Text(buildAttributedString())
            .font(font)
            .foregroundColor(textColor)
            .lineSpacing(lineSpacing)
    }

    private func buildAttributedString() -> AttributedString {
        var attributedString = AttributedString(text)

        // Apply highlight if range is valid (on the original text, before any insertion)
        if let nsRange = highlightRange,
           let attributedRange = Range(nsRange, in: attributedString) {
            attributedString[attributedRange].backgroundColor = UIColor(resolvedHighlightColor)
        }

        // Insert superscripts from the end backwards so earlier offsets stay valid.
        let count = text.count
        for marker in markers.sorted(by: { $0.offset > $1.offset }) {
            let offset = min(max(marker.offset, 0), count)
            let index = attributedString.index(attributedString.startIndex, offsetByCharacters: offset)
            var sup = AttributedString(marker.label)
            sup.font = .system(size: markerFontSize, weight: .bold)
            sup.baselineOffset = markerFontSize * 0.55
            sup.foregroundColor = UIColor(marker.color)
            sup.backgroundColor = nil
            attributedString.insert(sup, at: index)
        }

        return attributedString
    }
}

#Preview {
    VStack(spacing: 20) {
        HighlightedText(
            text: "This is a sample tafsir commentary text.",
            highlightRange: nil
        )

        HighlightedText(
            text: "This is a sample tafsir commentary text.",
            highlightRange: NSRange(location: 10, length: 6),
            markers: [TextMarker(offset: 40, label: "1", color: .purple)]
        )
    }
    .padding()
}
