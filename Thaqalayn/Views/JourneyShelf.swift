//
//  JourneyShelf.swift
//  Thaqalayn
//
//  Horizontal-shelf layout for the Journey hub. Each of the three hub sections
//  (Sacred Seasons, Deep Dives, Inside the Surah) renders as a `JourneyShelf`: a
//  header row (section label + "All N ›") over a horizontally scrolling row of
//  compact `ShelfCard`s. Available/live items sort to the front and wear the gold
//  hairline + gold icon tile; upcoming/soon items are muted. Tapping "All N ›"
//  pushes a `SectionFullList` - the existing full-width cards scoped to one section.
//
//  All colors come from ThemeManager, so the shelves adapt to both Light and
//  Midnight Emerald exactly like the full-width cards they replace on the surface.
//

import SwiftUI

// MARK: - Zoom-transition source

fileprivate extension View {
    /// Marks this view as a zoom-transition source when a namespace is supplied.
    /// A nil namespace leaves the view untouched, so the same card can appear on a
    /// shelf (zoom) and in an "All N" list (no zoom) without conflicting sources.
    @ViewBuilder
    func matchedZoomSource(_ id: String, in namespace: Namespace.ID?) -> some View {
        if let namespace {
            matchedTransitionSource(id: id, in: namespace)
        } else {
            self
        }
    }
}

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
    case ready          // a built deep dive / surah experience the user can open
    case soon           // a not-yet-built deep dive / surah experience
    case premium        // built but premium-gated for a non-subscriber (shown as a chip)
}

// MARK: - Item model

/// One card's worth of data for a shelf. Title/description arrive as display-ready
/// strings (they come from three different sources); `status` is resolved to
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
    /// Cover art (Assets.xcassets). When set, the card renders as a poster - the art
    /// fills it and the title sits in the art's own dark sky. When nil, the card falls
    /// back to the original icon-chip layout.
    var coverAssetName: String? = nil
    /// Present when this shelf card should offer a "Listen" (audio narration) affordance -
    /// set only for narratable journeys (Deep Dives / Surah experiences) in English. nil
    /// (the default) means no headphones - e.g. Sacred Seasons and the onboarding spotlight.
    var onListen: (() -> Void)? = nil
}

// MARK: - Compact card

/// A fixed-width (190pt) card for one shelf item. Cards in a shelf stretch to a
/// uniform height via `.frame(maxHeight: .infinity)` inside the shelf's HStack, so
/// their bottoms line up even when some carry a description and some don't.
struct ShelfCard: View {
    @ObservedObject private var tm = ThemeManager.shared
    let item: ShelfItem
    /// Section label, spoken as the third clause of the card's accessibility label.
    let section: String
    /// Uniform height to pin to (0 = not measured yet; card uses its natural height).
    var pinnedHeight: CGFloat = 0
    /// When set, this card is the source of a zoom transition into the descent it
    /// opens - the tapped poster grows into the full-screen dive. nil = no zoom
    /// (the "All N" lists and deep links present without a matching source).
    var zoomNamespace: Namespace.ID? = nil

    private static let cardWidth: CGFloat = 190
    private static let cornerRadius: CGFloat = 18
    /// 4:5 - the aspect every cover is composed at.
    private static let posterHeight: CGFloat = 238

    var body: some View {
        // The card body and the "Listen" affordance are two independent tap targets in
        // one ZStack: SwiftUI routes a tap to the topmost button under the finger, so the
        // headphones handles its corner and the rest of the card still opens the descent.
        // `onListen` is set only for narratable journeys (Deep Dives / Surah experiences)
        // in English; Sacred Seasons and the onboarding spotlight leave it nil.
        ZStack(alignment: .topTrailing) {
            cardButton
            if item.onListen != nil {
                listenButton
            }
        }
    }

    /// The card itself - a whole-card button opening the descent. Named so the "Listen"
    /// affordance can overlay it in the top-trailing corner without joining its tap.
    private var cardButton: some View {
        Button(action: item.onTap) {
            Group {
                if let cover = item.coverAssetName {
                    posterFace(cover)
                } else {
                    iconFace
                }
            }
            .contentShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        }
        .buttonStyle(EmPressStyle())
        .matchedZoomSource(item.id, in: zoomNamespace)
        .accessibilityElement(children: .ignore)
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(Text("\(item.title), \(statusText), \(section)"))
    }

    /// Headphones "Listen" affordance overlaid in the card's top-trailing corner - a
    /// separate tap target from the card body, matching DeepDiveCard / SurahExperienceCard.
    /// It sits over the poster's own dark top scrim (or the icon face's empty corner), so
    /// the accent glyph reads without a lock: the `.premium` status pill already carries
    /// any gating signal, and a locked tap is routed to the paywall by the `onListen` closure.
    private var listenButton: some View {
        Button {
            item.onListen?()
        } label: {
            Image(systemName: "headphones")
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(tm.accentColor)
                .padding(10)
                .contentShape(Rectangle())
        }
        .buttonStyle(EmPressStyle())
        .padding(.top, 4)
        .padding(.trailing, 6)
        .accessibilityLabel("Listen")
    }

    /// The art is the whole card, and the title sits in its sky. Every cover is composed
    /// 4:5 with an uncluttered dark top third precisely so the title can live there -
    /// a bottom scrim would land on the subject instead (the well, the tree, the road).
    private func posterFace(_ cover: String) -> some View {
        ZStack(alignment: .topLeading) {
            Image(cover)
                .resizable()
                .scaledToFill()
                .frame(width: Self.cardWidth, height: Self.posterHeight)
                .clipped()

            // The art's own top is already dark; this only guarantees the floor across
            // every cover, and never reaches the subject.
            LinearGradient(colors: [Color.black.opacity(0.60),
                                    Color.black.opacity(0.26),
                                    .clear],
                           startPoint: .top, endPoint: .center)

            VStack(alignment: .leading, spacing: 6) {
                eyebrow
                Text(item.title)
                    .font(EmType.serif(19, .semiBold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.55), radius: 8, x: 0, y: 2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(14)
        }
        .frame(width: Self.cardWidth, height: Self.posterHeight)
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: Self.cornerRadius, style: .continuous)
                .stroke(item.isAvailable ? tm.accentColor.opacity(0.4) : tm.strokeColor, lineWidth: 1)
        )
        // Deliberately lighter than the 0.72 the text-row cards use: a poster at 0.72
        // reads washed out, and a coming-soon cover still has to be worth wanting.
        .opacity(item.isAvailable ? 1 : 0.82)
        .shadow(color: Color.black.opacity(0.34), radius: 22, x: 0, y: 10)
        .background(
            // Keep the hub's uniform-height machinery fed even on the poster path.
            GeometryReader { geo in
                Color.clear.preference(key: ShelfCardHeightKey.self, value: geo.size.height)
            }
        )
    }

    /// Original layout, kept for any shelf item that has no cover art yet.
    private var iconFace: some View {
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
    }

    /// Status eyebrow - a small-caps tinted label, or the PREMIUM chip.
    @ViewBuilder private var eyebrow: some View {
        if case .premium = item.status {
            Text(JourneyStrings.premium.uppercased())
                .font(.system(size: 9, weight: .bold)).tracking(1.4)
                .foregroundColor(tm.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(tm.accentChip))
                .overlay(Capsule().stroke(tm.strokeColor, lineWidth: 1))
        } else {
            Text(statusText)
                .emEyebrow(size: 10, tracking: 1.6, weight: .bold)
                .foregroundColor(eyebrowTint)
        }
    }

    private var statusText: String {
        switch item.status {
        case .live:            return JourneyStrings.live
        case .inDays(let d):   return JourneyStrings.inDaysShort(d)
        case .ended:           return JourneyStrings.endedShort
        case .ready:           return JourneyStrings.ready
        case .soon:            return JourneyStrings.soon
        case .premium:         return JourneyStrings.premium
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
    let label: String
    let count: Int
    let items: [ShelfItem]
    let destination: AnyView
    /// Uniform card height, supplied by the hub after measuring every shelf.
    var pinnedHeight: CGFloat = 0
    /// Shared namespace for the poster -> descent zoom transition (nil = no zoom).
    var zoomNamespace: Namespace.ID? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(label.uppercased())
                    .emEyebrow(size: 12, tracking: 2, weight: .bold)
                    .foregroundColor(tm.accentColor)
                Spacer(minLength: 8)
                NavigationLink { destination } label: {
                    HStack(spacing: 3) {
                        Text(JourneyStrings.allCount(count))
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
                        ShelfCard(item: item, section: label, pinnedHeight: pinnedHeight,
                                  zoomNamespace: zoomNamespace)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - "All N" full-list

/// The destination pushed by a shelf's "All N ›" link: the existing full-width
/// cards for one section, in a vertical scroll, under a serif title + back button.
/// Content (the section's cards) is supplied by the caller so the hub's tap
/// handlers and presentation state stay in one place.
struct SectionFullList<Content: View>: View {
    @ObservedObject private var tm = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
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
    }
}
