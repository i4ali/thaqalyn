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

    @Environment(\.colorScheme) private var colorScheme

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

    /// Default highlight color (search-result yellow). Midnight Emerald keeps its
    /// #F2C969 at 30%; on the light ground a bright highlighter yellow at 50% sits
    /// behind the dark ink. Picked per scheme as plain colors, since it is handed
    /// to the attributed string as a UIColor.
    private var resolvedHighlightColor: Color {
        if let highlightColor = highlightColor {
            return highlightColor
        }
        return colorScheme == .dark
            ? Color(hex: "F2C969").opacity(0.30)
            : Color(red: 0.95, green: 0.78, blue: 0.30).opacity(0.50)
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
