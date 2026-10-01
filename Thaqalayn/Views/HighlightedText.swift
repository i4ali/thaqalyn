//
//  HighlightedText.swift
//  Thaqalayn
//
//  SwiftUI view that displays text with highlighted ranges
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let highlightRanges: [NSRange]
    let font: Font
    let textColor: Color
    let highlightColor: Color?
    let lineSpacing: CGFloat

    @StateObject private var themeManager = ThemeManager.shared

    init(
        text: String,
        highlightRange: NSRange?,
        font: Font = .system(size: 17, weight: .regular, design: .serif),
        textColor: Color = .primary,
        highlightColor: Color? = nil,
        lineSpacing: CGFloat = 6
    ) {
        self.init(text: text, highlightRanges: highlightRange.map { [$0] } ?? [], font: font,
                  textColor: textColor, highlightColor: highlightColor, lineSpacing: lineSpacing)
    }

    init(
        text: String,
        highlightRanges: [NSRange],
        font: Font = .system(size: 17, weight: .regular, design: .serif),
        textColor: Color = .primary,
        highlightColor: Color? = nil,
        lineSpacing: CGFloat = 6
    ) {
        self.text = text
        self.highlightRanges = highlightRanges
        self.font = font
        self.textColor = textColor
        self.highlightColor = highlightColor
        self.lineSpacing = lineSpacing
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

        // Apply each valid highlight range
        for nsRange in highlightRanges {
            if let attributedRange = Range(nsRange, in: attributedString) {
                attributedString[attributedRange].backgroundColor = UIColor(resolvedHighlightColor)
            }
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
            highlightRange: NSRange(location: 10, length: 6)
        )
    }
    .padding()
}
