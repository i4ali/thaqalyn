//
//  CitationSourcesList.swift
//  Thaqalayn
//
//  The "Sources" list under a commentary layer: one row per reader-visible
//  citation, numbered to match the superscripts in the text. Tapping a row with a
//  URL opens the source in an in-app Safari sheet. Chrome, not reading content, so
//  sizes are fixed (the reading text-size control does not apply here).
//

import SwiftUI

struct CitationSourcesList: View {
    let citations: [DisplayCitation]

    @StateObject private var themeManager = ThemeManager.shared
    @State private var openURL: URL? = nil

    var body: some View {
        if !citations.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("SOURCES")
                    .font(.system(size: 10.5, weight: .bold))
                    .tracking(1.2)
                    .foregroundColor(themeManager.tertiaryText)
                    .padding(.horizontal, 4)

                VStack(spacing: 0) {
                    ForEach(citations) { item in
                        row(item)
                        if item.id != citations.last?.id {
                            Divider().overlay(themeManager.strokeColor)
                        }
                    }
                }
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(themeManager.glassSurface)
                        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(themeManager.strokeColor, lineWidth: 1))
                }
            }
            .environment(\.layoutDirection, .leftToRight)
            .sheet(item: $openURL) { url in
                SafariView(url: url).ignoresSafeArea()
            }
        }
    }

    @ViewBuilder
    private func row(_ item: DisplayCitation) -> some View {
        let c = item.citation
        Button {
            if let url = c.linkURL { openURL = url }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Text("\(item.number)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(numberColor(for: c.status))
                    .frame(width: 20, height: 20)
                    .background(Circle().fill(numberColor(for: c.status).opacity(0.14)))

                VStack(alignment: .leading, spacing: 2) {
                    Text(c.displayTitle)
                        .font(.system(size: 13.5, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .fixedSize(horizontal: false, vertical: true)
                    if let locator = c.locator, !locator.isEmpty {
                        Text(locator)
                            .font(.system(size: 12, weight: .regular))
                            .foregroundColor(themeManager.secondaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .multilineTextAlignment(.leading)

                Spacer(minLength: 6)

                if c.linkURL != nil {
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                        .padding(.top, 3)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(c.linkURL == nil)
    }

    private func numberColor(for status: CitationStatus) -> Color {
        switch status {
        case .partial: return themeManager.semanticYellow
        default: return themeManager.accentColor
        }
    }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
