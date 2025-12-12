//
//  HighlightedText.swift
//  Thaqalayn
//
//  SwiftUI view that displays text with a highlighted word range
//

import SwiftUI

struct HighlightedText: View {
    let text: String
    let highlightRange: NSRange?
    let font: Font
    let textColor: Color
    let highlightColor: Color
    let lineSpacing: CGFloat

    init(
        text: String,
        highlightRange: NSRange?,
        font: Font = .system(size: 17, weight: .regular, design: .serif),
        textColor: Color = .primary,
        highlightColor: Color = .yellow.opacity(0.4),
        lineSpacing: CGFloat = 6
    ) {
        self.text = text
        self.highlightRange = highlightRange
        self.font = font
        self.textColor = textColor
        self.highlightColor = highlightColor
        self.lineSpacing = lineSpacing
    }

    var body: some View {
        Text(buildAttributedString())
            .font(font)
            .foregroundColor(textColor)
            .lineSpacing(lineSpacing)
    }

    private func buildAttributedString() -> AttributedString {
        var attributedString = AttributedString(text)

        // Apply highlight if range is valid
        if let nsRange = highlightRange,
           let swiftRange = Range(nsRange, in: text),
           let attributedRange = Range(nsRange, in: attributedString) {
            attributedString[attributedRange].backgroundColor = UIColor(highlightColor)
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
