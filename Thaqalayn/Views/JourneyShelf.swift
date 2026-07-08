//
//  JourneyShelf.swift
//  Thaqalayn
//
//  Horizontal-shelf layout for the Journey hub. Each of the three hub sections
//  (Sacred Seasons, Deep Dives, Inside the Sūrah) renders as a `JourneyShelf`: a
//  header row (section label + "All N ›") over a horizontally scrolling row of
//  compact `ShelfCard`s. Available/live items sort to the front and wear the gold
//  hairline + gold icon tile; upcoming/soon items are muted. Tapping "All N ›"
//  pushes a `SectionFullList` - the existing full-width cards scoped to one section.
//
//  All colors come from ThemeManager, so the shelves adapt to both Light and
//  Midnight Emerald exactly like the full-width cards they replace on the surface.
//

import SwiftUI

// MARK: - Uniform height

/// Collects the tallest natural card height across every shelf so all shelf cards
/// can pin to one uniform height (max-reduce up the view tree).
struct ShelfCardHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Status

/// The eyebrow status a compact shelf card shows above its title.
enum ShelfStatus {
    case live           // a seasonal journey in season
    case inDays(Int)    // a seasonal journey still ahead this year
    case ended          // a seasonal journey already passed this year
    case ready          // a built deep dive / sūrah experience the user can open
    case soon           // a not-yet-built deep dive / sūrah experience
    case premium        // built but premium-gated for a non-subscriber (shown as a chip)
}

// MARK: - Item model

/// One card's worth of data for a shelf. Title/description arrive already
/// localized (they come from three different sources); `status` is resolved to
/// copy inside `ShelfCard` so the status vocabulary stays in one place.
struct ShelfItem: Identifiable {
    let id: String
    let sfSymbol: String
    let isCustomAsset: Bool
    let isAvailable: Bool
    let status: ShelfStatus
    let title: String
    let description: String?
    let onTap: () -> Void
}

// MARK: - Compact card

/// A fixed-width (190pt) card for one shelf item. Cards in a shelf stretch to a
/// uniform height via `.frame(maxHeight: .infinity)` inside the shelf's HStack, so
/// their bottoms line up even when some carry a description and some don't.
struct ShelfCard: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let item: ShelfItem
    /// Section label, spoken as the third clause of the card's accessibility label.
    let section: String
    /// Uniform height to pin to (0 = not measured yet; card uses its natural height).
    var pinnedHeight: CGFloat = 0

    private static let cardWidth: CGFloat = 190
    private static let cornerRadius: CGFloat = 18

    var body: some View {
        Button(action: item.onTap) {
            VStack(alignment: .leading, spacing: 0) {
                EmIconChip(sfSymbol: item.sfSymbol, size: 40,
                           active: item.isAvailable, isCustomAsset: item.isCustomAsset)

                eyebrow
                    .padding(.top, 10)

                Text(item.title)
                    .font(EmType.serif(19, .semiBold))
                    .foregroundColor(tm.primaryText)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 2)

                if let description = item.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: 12))
                        .foregroundColor(item.isAvailable ? tm.secondaryText : tm.tertiaryText)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 3)
                }
            }
            .padding(14)
            .frame(width: Self.cardWidth, alignment: .topLeading)
            .background(
                // Measure this card's natural height (before pinning) so the hub can
                // find the tallest across all shelves. Stays natural under the pin,
                // so the reported max is stable (no layout feedback loop).
                GeometryReader { geo in
                    Color.clear.preference(key: ShelfCardHeightKey.self, value: geo.size.height)
                }
            )
            .frame(height: pinnedHeight > 0 ? pinnedHeight : nil, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                    .fill(item.isAvailable ? tm.glassSurfaceElevated : tm.glassSurface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                    .stroke(item.isAvailable ? tm.accentColor.opacity(0.4) : tm.strokeColor, lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.28), radius: 20, x: 0, y: 8)
            .contentShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
        }
        .buttonStyle(EmPressStyle())
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("\(item.title), \(statusText), \(section)"))
    }

    /// Status eyebrow - a small-caps tinted label, or the PREMIUM chip.
    @ViewBuilder private var eyebrow: some View {
        if case .premium = item.status {
            Text(JourneyStrings.premium(lang).uppercased())
                .font(.system(size: 9, weight: .bold)).tracking(1.4)
                .foregroundColor(tm.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(tm.accentChip))
                .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
        } else {
            Text(statusText)
                .emEyebrow(lang, size: 10, tracking: 1.6, weight: .bold)
                .foregroundColor(eyebrowTint)
        }
    }

    private var statusText: String {
        switch item.status {
        case .live:            return JourneyStrings.live(lang)
        case .inDays(let d):   return JourneyStrings.inDaysShort(d, lang)
        case .ended:           return JourneyStrings.endedShort(lang)
        case .ready:           return JourneyStrings.ready(lang)
        case .soon:            return JourneyStrings.soon(lang)
        case .premium:         return JourneyStrings.premium(lang)
        }
    }

    private var eyebrowTint: Color {
        switch item.status {
        case .live, .ready, .premium:  return tm.accentColor
        case .inDays, .ended, .soon:   return tm.tertiaryText
        }
    }
}

// MARK: - Shelf

/// One section: a header row (label + "All N ›") over a horizontal scroller of
/// compact cards. The header's trailing link pushes `destination` (the full-width
/// list for this section).
struct JourneyShelf: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let label: String
    let count: Int
    let items: [ShelfItem]
    let destination: AnyView
    /// Uniform card height, supplied by the hub after measuring every shelf.
    var pinnedHeight: CGFloat = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(label.uppercased())
                    .emEyebrow(lang, size: 12, tracking: 2, weight: .bold)
                    .foregroundColor(tm.accentColor)
                Spacer(minLength: 8)
                NavigationLink { destination } label: {
                    HStack(spacing: 3) {
                        Text(JourneyStrings.allCount(count, lang))
                            .font(.system(size: 12.5))
                        Image(systemName: "chevron.forward")
                            .font(.system(size: 10, weight: .semibold))
                    }
                    .foregroundColor(tm.secondaryText)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(items) { item in
                        ShelfCard(item: item, section: label, pinnedHeight: pinnedHeight)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }
}

// MARK: - "All N" full-list

/// The destination pushed by a shelf's "All N ›" link: the existing full-width
/// cards for one section, in a vertical scroll, under a serif title + back button.
/// Content (the section's cards) is supplied by the caller so the hub's tap
/// handlers and presentation state stay in one place.
struct SectionFullList<Content: View>: View {
    @ObservedObject private var tm = ThemeManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        ZStack {
            AdaptiveModernBackground()
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(tm.primaryText)
                            .frame(width: 38, height: 38)
                            .background(.ultraThinMaterial, in: Circle())
                            .overlay(Circle().stroke(tm.strokeColor, lineWidth: 1))
                    }
                    .buttonStyle(EmPressStyle())
                    Text(title)
                        .font(EmType.serif(28, .semiBold))
                        .foregroundColor(tm.primaryText)
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 6)
                .padding(.bottom, 8)

                ScrollView {
                    VStack(spacing: 12) {
                        content
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 120)   // clear the floating EmeraldTabBar
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
    }
}
