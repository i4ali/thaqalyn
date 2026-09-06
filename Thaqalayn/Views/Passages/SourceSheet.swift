//
//  SourceSheet.swift
//  Thaqalayn
//
//  One source behind a passage commentary, opened from a citation marker, a
//  narration's source line or the bibliography: the work, its author and
//  locus, the quoted excerpt with its gloss, the narrations it supplies in
//  verbatim Arabic with their chains, any grading, and a link to the page it
//  was read from. Tier C (copyrighted translations) shows only the work,
//  author, locus and link.
//

import SwiftUI

struct SourceSheet: View {
    let source: PassageSource
    let passage: Passage
    let surahName: String

    @ObservedObject private var themeManager = ThemeManager.shared
    @StateObject private var readingSettings = ReadingSettingsManager.shared
    @Environment(\.dismiss) private var dismiss

    init(source: PassageSource, passage: Passage, surahName: String) {
        self.source = source
        self.passage = passage
        self.surahName = surahName
    }

    // MARK: - Derived

    private var scale: CGFloat { readingSettings.scale }

    private var isTierC: Bool { source.tier.uppercased() == "C" }

    private var eyebrow: String {
        let tradition = source.tradition.lowercased() == "sunni" ? "Sunni" : "Shia"
        let kind = source.kind.lowercased() == "hadith" ? "narration" : "commentary"
        return "Source \(source.number) · \(tradition) · \(kind)"
    }

    private var contextLine: String {
        "Cited in \(surahName) · \(passage.title.en)"
    }

    /// Narrations in this passage that quote this source.
    private var citingNarrations: [Narration] {
        passage.verses.flatMap(\.narrations).filter { $0.source == source.id }
    }

    /// The source page, only when the stored string is a real web URL.
    private var linkURL: URL? {
        let trimmed = source.url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let url = URL(string: trimmed),
              let scheme = url.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              url.host != nil else { return nil }
        return url
    }

    private var linkHost: String {
        guard let host = linkURL?.host else { return "the web" }
        return host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
    }

    private var grades: [String] {
        (source.grades ?? []).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            if themeManager.isMidnightEmerald {
                EmeraldBackground()
            } else {
                LinearGradient(
                    colors: [themeManager.primaryBackground, themeManager.secondaryBackground],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    titleBlock

                    if !isTierC, let excerpt = source.excerpt {
                        excerptSection(excerpt)
                    }

                    if !isTierC, !citingNarrations.isEmpty {
                        narrationsSection
                    }

                    if !grades.isEmpty {
                        Text("Grading: \(grades.joined(separator: ", "))")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.tertiaryText)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    if let url = linkURL {
                        Link(destination: url) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 12, weight: .semibold))
                                Text("Open on \(linkHost)")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(themeManager.accentColor)
                            .padding(.horizontal, 16)
                            .frame(height: 38)
                            .background(Capsule().fill(themeManager.accentChip))
                            .overlay(Capsule().stroke(themeManager.strokeColor, lineWidth: 1))
                        }
                        .buttonStyle(EmPressStyle())
                        .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 24)
                .padding(.top, 22)
                .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }

    // MARK: - Sections

    private var titleBlock: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(eyebrow.uppercased())
                    .emEyebrow(size: 11, tracking: 2)
                    .foregroundColor(themeManager.accentColor)
                Text(source.work)
                    .font(EmType.serif(24, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(source.author)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(source.locus)
                    .font(.system(size: 13))
                    .foregroundColor(themeManager.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
                Text(contextLine)
                    .font(.system(size: 12))
                    .foregroundColor(themeManager.tertiaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)
            }

            Spacer(minLength: 8)

            Button(action: { dismiss() }) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                    .frame(width: 36, height: 36)
                    .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Close")
        }
    }

    private func excerptSection(_ excerpt: SourceExcerpt) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            EmDivider(label: "Excerpt")

            if excerpt.lang.lowercased() == "en" {
                Text(excerpt.text)
                    .font(EmType.serif(17 * scale, .medium))
                    .foregroundColor(themeManager.primaryText)
                    .lineSpacing(6 * scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            } else {
                arabicText(excerpt.text, size: 22, lineSpacing: 11)
            }

            if let gloss = source.gloss, !gloss.isEmpty {
                Text(gloss)
                    .font(EmType.serifItalic(16 * scale))
                    .foregroundColor(themeManager.secondaryText)
                    .lineSpacing(5 * scale)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var narrationsSection: some View {
        VStack(alignment: .leading, spacing: 18) {
            EmDivider(label: citingNarrations.count == 1 ? "Narration" : "Narrations")

            ForEach(citingNarrations) { narration in
                VStack(alignment: .leading, spacing: 8) {
                    speakerLine(narration)

                    if let chain = narration.chain, !chain.isEmpty {
                        Text(chain)
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.secondaryText)
                            .lineSpacing(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    arabicText(narration.arabic, size: 20, lineSpacing: 9)
                        .padding(.top, 2)
                }
            }
        }
    }

    private func speakerLine(_ narration: Narration) -> some View {
        var line = Text(narration.speaker)
            .font(EmType.serif(15, .semiBold))
            .foregroundColor(themeManager.primaryText)
        if let addressee = narration.addressee, !addressee.isEmpty {
            line = line + Text(" to \(addressee)")
                .font(EmType.serif(15, .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        return line
            .fixedSize(horizontal: false, vertical: true)
    }

    /// Reading Arabic: scaled, laid out right to left, so leading is the right edge.
    private func arabicText(_ text: String, size: CGFloat, lineSpacing: CGFloat) -> some View {
        Text(text)
            .font(EmType.arabic(size * scale))
            .foregroundColor(themeManager.primaryText)
            .lineSpacing(lineSpacing * scale)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .fixedSize(horizontal: false, vertical: true)
            .environment(\.layoutDirection, .rightToLeft)
    }
}
