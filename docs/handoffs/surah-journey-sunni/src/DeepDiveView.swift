//
//  DeepDiveView.swift
//  Thaqalayn
//
//  The immersive "descent": a full-screen, vertical scroll-snap experience that
//  renders one DeepDive's sections one screen at a time. Keeps its own fixed
//  cinematic dark palette (DeepDivePalette) regardless of the app theme — it is
//  an immersive mode, like a film. Reuses the app's real audio
//  (VerseRecitationButton / DuaListenButton) and reading-size control.
//
//  A quiet guidance layer runs through it: a place-label + depth meter on every
//  beat, an orientation screen up front, and movement connectors that name the
//  KNOW → SEE → LIVE arc — so a first-timer can feel the shape.
//
//  Native SwiftUI rebuild of MajlisYaqeen.jsx.
//

import SwiftUI

// MARK: - Scroll offset plumbing

private struct DeepDiveOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) { value = nextValue() }
}

private extension Array {
    subscript(safe i: Int) -> Element? { indices.contains(i) ? self[i] : nil }
}

private extension View {
    /// Fade + rise reveal, matching the JSX `reveal()`. Disabled under reduce-motion.
    func reveal(_ shown: Bool, _ delay: Double = 0, reduce: Bool) -> some View {
        self.opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : 24)
            .animation(reduce ? nil : .easeOut(duration: 0.85).delay(delay), value: shown)
    }
}

private let romans = ["", "I", "II", "III", "IV", "V", "VI", "VII", "VIII"]
/// Safe roman numeral for a movement number. Falls back to the raw number so a
/// dive declaring more movements than the table covers can never crash.
private func roman(_ n: Int) -> String { (n >= 0 && n < romans.count) ? romans[n] : "\(n)" }

// MARK: - View

struct DeepDiveView: View {
    let dive: DeepDive
    var onClose: () -> Void
    /// Present on surah experiences: invoked by the closing beat's
    /// "Read the full surah" button. nil hides the button (theme dives).
    var onReadSurah: (() -> Void)? = nil
    /// The experience's cover art. Renders behind the opening beat as the threshold you
    /// step through, then dissolves into `DeepDiveBackground` over the first scroll.
    /// nil = no art, and the descent looks exactly as it did before.
    var coverAssetName: String? = nil
    /// When set, the descent is gated and renders as a *veiled preview*: the reader gets
    /// the threshold and the orientation - everything before Movement I - and then the
    /// veil, which names what lies beneath it. The context drives the paywall the veil's
    /// button opens. nil = full access, and the dive behaves exactly as it always has.
    var lockedPaywallContext: PaywallContext? = nil

    @StateObject private var reading = ReadingSettingsManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentID: Int? = 0
    @State private var progress: CGFloat = 0
    @State private var showingPaywall = false
    /// First depth starts open so the "tap to open" gesture is obvious.
    @State private var openDepths: Set<Int> = [0]
    @State private var saidAmin = false

    /// The `release` beat's state machine. The grip is a press-and-hold: the ring fills
    /// while the finger is down, and once full the lifting of the finger IS the release.
    @State private var releaseHolding = false
    @State private var releasePrimed = false     // ring filled while still holding
    @State private var releaseDone = false
    @State private var releaseHoldStart: Date? = nil
    /// How long the grip must be held before it can be released.
    private let releaseHoldDuration: TimeInterval = 2.2

    /// The `refrain` beats' state: which occurrences (by section index) the reader
    /// has answered. Four independent askings in al-Rahman; each remembers its own.
    @State private var answeredRefrains: Set<Int> = []

    /// The `count` beat's state machine. Each tap logs one blessing and births a
    /// light; after `countOverflowAt` taps the lights start multiplying on their
    /// own - outrunning the finger - and the verse takes over.
    @State private var countTaps = 0
    @State private var countTally = 0
    @State private var countOverflow = false
    @State private var countDone = false
    @State private var countLights: [CountLight] = []
    @State private var countTimer: Timer? = nil
    private let countOverflowAt = 7

    /// One blessing-light in the count field, positioned in unit space.
    private struct CountLight: Identifiable {
        let id = UUID()
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let opacity: Double
    }

    private var s: CGFloat { reading.scale }
    private var currentIndex: Int { currentID ?? 0 }

    /// True when this reader has not paid for this descent.
    private var isLocked: Bool { lockedPaywallContext != nil }

    /// What a gated reader may actually read: everything before Movement I. `.open` and
    /// `.orientation` both report act 0, so the cut is drawn by the content itself - the
    /// threshold, and the dive's own statement of what it will leave you with - rather
    /// than by an arbitrary page count. Every dive has exactly one of each.
    private var visibleSections: [DeepDiveSection] {
        isLocked ? Array(dive.sections.prefix { $0.act == 0 }) : dive.sections
    }

    /// Beats in the scroll, counting the veil as one.
    private var pageCount: Int { visibleSections.count + (isLocked ? 1 : 0) }
    /// Active commentary language - resolves every `LocalizedText` field below and
    /// drives RTL layout for Urdu/Arabic.
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                DeepDiveBackground(progress: progress).ignoresSafeArea()

                if let cover = coverAssetName {
                    thresholdCover(cover, size: geo.size)
                }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(visibleSections.enumerated()), id: \.offset) { idx, section in
                            page(section, index: idx)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .id(idx)
                        }
                        if isLocked {
                            veilPage(index: visibleSections.count, size: geo.size)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .id(visibleSections.count)
                        }
                    }
                    .scrollTargetLayout()
                    .background(
                        GeometryReader { g in
                            Color.clear.preference(key: DeepDiveOffsetKey.self,
                                                   value: g.frame(in: .named("dive")).minY)
                        }
                    )
                }
                .scrollTargetBehavior(.paging)
                .scrollPosition(id: $currentID)
                .scrollIndicators(.hidden)
                .coordinateSpace(name: "dive")
                .onPreferenceChange(DeepDiveOffsetKey.self) { minY in
                    let total = max(geo.size.height * CGFloat(pageCount - 1), 1)
                    progress = min(max(-minY / total, 0), 1)
                }

                progressHairline
                closeButton
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView(context: lockedPaywallContext)
        }
        #if DEBUG
        .onAppear {
            if let arg = ProcessInfo.processInfo.arguments.first(where: { $0.hasPrefix("-ddPage=") }),
               let n = Int(arg.dropFirst(8)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.easeInOut(duration: 0.3)) { currentID = n }
                }
            }
        }
        #endif
    }

    private func shown(_ index: Int) -> Bool { currentIndex >= index }

    // MARK: Threshold cover

    /// 1 on the opening beat, 0 once the first beat is behind you. Measured in *pages
    /// scrolled* rather than raw `progress`, so the handoff lands at the same place
    /// whether a dive has twelve beats or thirty.
    private var coverOpacity: Double {
        let pagesScrolled = progress * CGFloat(max(pageCount - 1, 1))
        return Double(1 - min(max(pagesScrolled / 0.85, 0), 1))
    }

    /// The cover art as the doorway you step through, dissolving into the procedural
    /// background as you sink. The scrim is deliberately heavy: the opening beat lays a
    /// 72pt gold Arabic title across the middle of the frame and every cover has a bright
    /// gold light source somewhere in it, so the art has to read as a lit room rather than
    /// a photograph. Ghosting the art instead of scrimming it was tried and is worse on
    /// both counts - the bright areas punch straight through the text, and the art washes out.
    private func thresholdCover(_ asset: String, size: CGSize) -> some View {
        let scrim = Color(.sRGB, red: 4.0 / 255.0, green: 10.0 / 255.0, blue: 7.0 / 255.0, opacity: 1)
        return Image(asset)
            .resizable()
            .scaledToFill()
            .frame(width: size.width, height: size.height)
            .clipped()
            .overlay(
                LinearGradient(stops: [
                    .init(color: scrim.opacity(0.50), location: 0.00),
                    .init(color: scrim.opacity(0.66), location: 0.34),
                    .init(color: scrim.opacity(0.74), location: 0.62),
                    .init(color: scrim.opacity(0.60), location: 1.00),
                ], startPoint: .top, endPoint: .bottom)
            )
            .overlay(
                RadialGradient(stops: [
                    .init(color: .clear, location: 0.32),
                    .init(color: scrim.opacity(0.55), location: 1.00),
                ], center: .center, startRadius: 0,
                   endRadius: max(size.width, size.height) * 0.62)
            )
            .opacity(coverOpacity)
            .allowsHitTesting(false)
            .ignoresSafeArea()
    }

    // MARK: The veil

    /// The beat a gated reader lands on when the descent runs out. Deliberately NOT a
    /// wall: the dive's own cover sits behind it, blurred past legibility, and every
    /// movement beneath is named in the content's own words. A wall tells you something
    /// exists; a veil tells you what it is. House rule - no lock glyph anywhere.
    private func veilPage(index: Int, size: CGSize) -> some View {
        let show = shown(index)
        return ZStack {
            veiledArt(size: size)
            GeometryReader { pgeo in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: 1)   // the slot placeBar occupies on a real beat
                        Spacer(minLength: 20)
                        veilContent(show)
                        Spacer(minLength: 20)
                    }
                    .frame(maxWidth: 480)
                    .padding(.horizontal, 30)
                    .padding(.top, 52)
                    .padding(.bottom, 40)
                    .frame(maxWidth: .infinity, minHeight: pgeo.size.height)
                }
                .scrollIndicators(.hidden)
                .scrollBounceBehavior(.basedOnSize)
            }
        }
    }

    /// The cover, blurred until only its shape survives. You can see that there is
    /// something through there; you cannot see what.
    @ViewBuilder
    private func veiledArt(size: CGSize) -> some View {
        if let cover = coverAssetName {
            Image(cover)
                .resizable()
                .scaledToFill()
                .frame(width: size.width, height: size.height)
                // Overscan before blurring: a blur samples past its own bounds, so without
                // the extra material the frame picks up a dark vignette at every edge.
                .scaleEffect(1.22)
                .blur(radius: 44, opaque: true)
                .frame(width: size.width, height: size.height)
                .clipped()
                .overlay(Color.black.opacity(0.46))
                .allowsHitTesting(false)
                .accessibilityHidden(true)
        }
    }

    private func veilContent(_ show: Bool) -> some View {
        VStack(spacing: 0) {
            Text(JourneyStrings.veilEyebrow(lang).uppercased())
                .font(.system(size: 10, weight: .semibold)).tracking(4)
                .foregroundColor(DeepDivePalette.gold)
                .multilineTextAlignment(.center)
                .reveal(show, reduce: reduceMotion)

            hairline.padding(.vertical, 26).reveal(show, 0.2, reduce: reduceMotion)

            // What lies beneath, named. This is the entire mechanic - the reader leaves
            // knowing exactly what they did not get, in the dive's own language.
            VStack(alignment: .leading, spacing: 16) {
                ForEach(dive.acts) { act in
                    HStack(alignment: .firstTextBaseline, spacing: 14) {
                        Text(roman(act.number))
                            .font(.system(size: 11, weight: .semibold)).tracking(1.6)
                            .foregroundColor(DeepDivePalette.gold.opacity(0.8))
                            .frame(width: 24, alignment: .leading)
                        Text(act.name(lang))
                            .font(EmType.serif(22 * s, .semiBold))
                            .foregroundColor(DeepDivePalette.cream.opacity(0.62))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
            .reveal(show, 0.35, reduce: reduceMotion)

            hairline.padding(.vertical, 26).reveal(show, 0.5, reduce: reduceMotion)

            unlockButton.reveal(show, 0.62, reduce: reduceMotion)

            Text("\(JourneyStrings.premium(lang)) \u{00B7} \(JourneyStrings.veilNote(lang))")
                .font(.system(size: 11))
                .foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center)
                .padding(.top, 14)
                .reveal(show, 0.62, reduce: reduceMotion)
        }
    }

    private var unlockButton: some View {
        Button {
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
            showingPaywall = true
        } label: {
            Text(JourneyStrings.veilCta(lang))
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color(.sRGB, red: 11.0 / 255.0, green: 20.0 / 255.0,
                                       blue: 15.0 / 255.0, opacity: 1))
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    Capsule().fill(
                        LinearGradient(colors: [DeepDivePalette.goldBright, DeepDivePalette.gold],
                                       startPoint: .top, endPoint: .bottom))
                )
                .shadow(color: DeepDivePalette.gold.opacity(0.35), radius: 16, x: 0, y: 6)
        }
        .buttonStyle(EmPressStyle())
    }

    // MARK: Chrome

    private var progressHairline: some View {
        GeometryReader { g in
            ZStack(alignment: .leading) {
                Rectangle().fill(Color.white.opacity(0.04))
                Rectangle()
                    .fill(LinearGradient(colors: [DeepDivePalette.gold, DeepDivePalette.goldBright],
                                         startPoint: .leading, endPoint: .trailing))
                    .frame(width: g.size.width * progress)
            }
        }
        .frame(height: 2)
        .ignoresSafeArea(edges: .top)
    }

    private var closeButton: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(DeepDivePalette.cream)
                    .frame(width: 38, height: 38)
                    .background(.ultraThinMaterial, in: Circle())
                    .overlay(Circle().stroke(DeepDivePalette.gold.opacity(0.25), lineWidth: 1))
            }
            Spacer()
        }
        .padding(.leading, 16)
        .padding(.top, 8)
    }

    // MARK: Place-label + depth meter (orientation)

    /// The "where am I" label + how many depth dots to fill, per section.
    /// nil = no bar (cover, orientation, and the movement dividers that announce
    /// themselves).
    private func placeInfo(_ section: DeepDiveSection) -> (label: String, filled: Int)? {
        switch section {
        case .open, .orientation, .act: return nil
        case .reflectionPrompt:         return ("The Return", dive.acts.count)
        case .release(let tag, _, _, _, _, _, _, _): return (tag(lang), dive.acts.count)
        case .count(let tag, _, _, _, _, _, _, _): return (tag(lang), dive.acts.count)
        case .dua:                      return ("The Close", dive.acts.count)
        case .closing:                  return ("The Close", dive.acts.count)
        default:
            let a = section.act
            guard let info = dive.actInfo(a) else { return nil }
            return ("Movement \(roman(a)) · \(info.name(lang))", a)
        }
    }

    @ViewBuilder
    private func placeBar(for section: DeepDiveSection, _ show: Bool) -> some View {
        if let info = placeInfo(section) {
            HStack(spacing: 8) {
                Text(info.label.uppercased())
                    .font(.system(size: 9.5, weight: .semibold)).tracking(1.8)
                    .foregroundColor(DeepDivePalette.gold)
                Spacer(minLength: 8)
                HStack(spacing: 5) {
                    ForEach(0..<dive.acts.count, id: \.self) { i in
                        Circle()
                            .fill(i < info.filled ? DeepDivePalette.gold : Color.clear)
                            .frame(width: 5, height: 5)
                            .overlay(Circle().stroke(DeepDivePalette.gold.opacity(0.5), lineWidth: i < info.filled ? 0 : 1))
                            .shadow(color: i < info.filled ? DeepDivePalette.gold.opacity(0.5) : .clear, radius: 3)
                    }
                }
            }
            .reveal(show, reduce: reduceMotion)
        } else {
            Color.clear.frame(height: 1)
        }
    }

    // MARK: Page dispatch

    /// One beat. Content is centered when it fits the screen (the default look) and
    /// becomes scrollable when it overflows - e.g. at the largest reading text size -
    /// so nothing is ever clipped. The outer paging still snaps one beat per screen
    /// because this whole view is clipped to the viewport-height page frame.
    @ViewBuilder
    private func page(_ section: DeepDiveSection, index: Int) -> some View {
        let show = shown(index)
        GeometryReader { pgeo in
            ScrollView(.vertical) {
                VStack(spacing: 0) {
                    placeBar(for: section, show)
                    Spacer(minLength: 20)
                    content(section, show, index)
                    Spacer(minLength: 20)
                }
                .frame(maxWidth: 480)
                .padding(.horizontal, 30)
                .padding(.top, 52)
                .padding(.bottom, 40)
                // Center the beat when it fits; grow past the screen and scroll when
                // it does not (e.g. at the largest reading size). minHeight is fed a
                // concrete height from the GeometryReader so the Spacers actually
                // expand - the beat is never height-constrained, so text never truncates.
                .frame(maxWidth: .infinity, minHeight: pgeo.size.height)
            }
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
        }
    }

    @ViewBuilder
    private func content(_ section: DeepDiveSection, _ show: Bool, _ index: Int = 0) -> some View {
        switch section {
        case let .refrain(_, tag, _, _, arabic, translation, reference, intro, teachSource, replyArabic, replyTransliteration, replyTranslation, reflection):
            refrainPage(index, tag(lang), arabic, translation(lang), reference, intro(lang),
                        teachSource.map { $0(lang) }, replyArabic, replyTransliteration,
                        replyTranslation(lang), reflection(lang), show)
        case let .open(kicker, titleAr, titleEn, subtitle, line):
            openPage(kicker(lang), titleAr, titleEn, subtitle(lang), line(lang), show)
        case let .orientation(eyebrow, promise, leaveWith):
            orientationPage(eyebrow(lang), promise(lang), leaveWith(lang), show)
        case let .verse(_, tag, surah, ayah, arabic, translation, reference, reflection):
            versePage(tag(lang), surah, ayah, arabic, translation(lang), reference, reflection(lang), show)
        case let .depths(_, tag, _, items):
            depthsPage(tag(lang), items, show)
        case let .act(act, connector, line, bridge):
            actPage(act, connector.map { $0(lang) }, line(lang), bridge, show)
        case let .narration(_, tag, source, body, reflection):
            narrationPage(tag(lang), source(lang), body(lang), reflection(lang), show)
        case let .response(_, replyingTo, arabic, words, source, reflection):
            responsePage(replyingTo(lang), arabic, words(lang), source(lang), reflection(lang), show)
        case let .climax(_, tag, source, arabic, translation, body, reflection):
            climaxPage(tag(lang), source(lang), arabic, translation(lang), body(lang), reflection(lang), show)
        case let .reflectionPrompt(_, prompt, _, subline, nextLabel):
            reflectionPage(prompt(lang), subline(lang), nextLabel(lang), show)
        case let .release(_, prompt, subline, arabic, translation, reference, note, nextLabel):
            releasePage(prompt(lang), subline(lang), arabic, translation(lang), reference, note(lang), nextLabel(lang), show)
        case let .count(_, prompt, subline, arabic, translation, reference, note, nextLabel):
            countPage(prompt(lang), subline(lang), arabic, translation(lang), reference, note(lang), nextLabel(lang), show)
        case let .dua(tag, intro, arabic, translation, source, note, close):
            duaPage(tag(lang), intro(lang), arabic, translation(lang), source(lang), note(lang), close(lang), show)
        case let .closing(tag, titleAr, essence, line):
            closingPage(tag(lang), titleAr, essence(lang), line(lang), show)
        }
    }

    // MARK: Shared bits

    private func tagLabel(_ text: String, _ show: Bool, _ delay: Double = 0.06) -> some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .semibold)).tracking(3)
            .foregroundColor(DeepDivePalette.cream)
            .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
            .reveal(show, delay, reduce: reduceMotion)
    }

    private var hairline: some View {
        Rectangle().fill(DeepDivePalette.gold.opacity(0.3)).frame(width: 26, height: 1)
    }

    private func bob(_ label: String, _ show: Bool, _ delay: Double = 1.0) -> some View {
        VStack(spacing: 8) {
            Text(label.uppercased())
                .font(.system(size: 10.5, weight: .regular)).tracking(3)
                .foregroundColor(DeepDivePalette.mute)
            Image(systemName: "chevron.compact.down").foregroundColor(DeepDivePalette.gold)
        }
        .reveal(show, delay, reduce: reduceMotion)
    }

    // MARK: Renderers

    private func openPage(_ kicker: String, _ titleAr: String, _ titleEn: String, _ subtitle: String, _ line: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            Text(kicker.uppercased()).font(.system(size: 11, weight: .medium)).tracking(6)
                .foregroundColor(DeepDivePalette.gold).padding(.bottom, 30)
                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, reduce: reduceMotion)
            Text(titleAr).font(EmType.arabic(72)).foregroundColor(DeepDivePalette.goldBright)
                .padding(.bottom, 14).reveal(show, 0.25, reduce: reduceMotion)
            Text(titleEn).font(EmType.serif(44)).foregroundColor(DeepDivePalette.cream)
                .reveal(show, 0.5, reduce: reduceMotion)
            Text(subtitle.uppercased()).font(.system(size: 12)).tracking(5)
                .foregroundColor(DeepDivePalette.mute).padding(.top, 8)
                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.5, reduce: reduceMotion)
            hairline.padding(.vertical, 30).reveal(show, 0.78, reduce: reduceMotion)
            Text(line).font(EmType.serifItalic(18 * s)).foregroundColor(Color(white: 0.72))
                .multilineTextAlignment(.center).lineSpacing(5 * s).frame(maxWidth: 320)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.78, reduce: reduceMotion)
            bob("Descend", show).padding(.top, 44)
        }
    }

    private func orientationPage(_ eyebrow: String, _ promise: String, _ leaveWith: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            Text(eyebrow.uppercased()).font(.system(size: 10, weight: .semibold)).tracking(4)
                .foregroundColor(DeepDivePalette.gold)
                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, reduce: reduceMotion)
            Text(promise).font(EmType.serifItalic(22 * s)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center).lineSpacing(5 * s).padding(.top, 20).frame(maxWidth: 320)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.2, reduce: reduceMotion)
            hairline.padding(.vertical, 24).reveal(show, 0.35, reduce: reduceMotion)
            VStack(alignment: .leading, spacing: 14) {
                hintRow("arrow.down", "Scroll to sink deeper")
                hintRow("hand.tap", "Tap what draws you")
                hintRow("square.and.pencil", "Reflect at the end")
            }
            .reveal(show, 0.5, reduce: reduceMotion)
            Text(leaveWith).font(.system(size: 13 * s)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).lineSpacing(4 * s).padding(.top, 26).frame(maxWidth: 250)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.7, reduce: reduceMotion)
            bob("Begin the descent", show, 0.9).padding(.top, 30)
        }
    }

    private func hintRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 13) {
            Image(systemName: icon).font(.system(size: 13)).foregroundColor(DeepDivePalette.gold)
                .frame(width: 20, alignment: .center)
            Text(text).font(.system(size: 13)).foregroundColor(DeepDivePalette.mute)
        }
    }

    private func versePage(_ tag: String, _ surah: Int, _ ayah: Int, _ arabic: String, _ translation: String, _ reference: String, _ reflection: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            tagLabel(tag, show).padding(.bottom, 30)
            Text(arabic).font(EmType.arabic(26 * s)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center).lineSpacing(14 * s)
                .environment(\.layoutDirection, .rightToLeft)
                .reveal(show, 0.24, reduce: reduceMotion)
            if !translation.isEmpty {
                Text(translation).font(EmType.serifItalic(20 * s)).foregroundColor(Color(white: 0.8))
                    .multilineTextAlignment(.center).lineSpacing(4 * s).padding(.top, 26).frame(maxWidth: 400)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .reveal(show, 0.55, reduce: reduceMotion)
            }
            Text(reference).font(.system(size: 11, weight: .semibold)).tracking(2)
                .foregroundColor(DeepDivePalette.gold.opacity(0.85)).padding(.top, 16)
                .reveal(show, 0.55, reduce: reduceMotion)
            hairline.padding(.top, 28).padding(.bottom, 22).reveal(show, 0.9, reduce: reduceMotion)
            Text(reflection).font(.system(size: 15 * s)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.9, reduce: reduceMotion)
            VStack(spacing: 8) {
                VerseRecitationButton(surahNumber: surah, verseNumber: ayah)
                Text("Hear it recited").font(.system(size: 9.5, weight: .semibold)).tracking(1.5)
                    .foregroundColor(DeepDivePalette.gold.opacity(0.7))
            }
            .padding(.top, 20).reveal(show, 0.95, reduce: reduceMotion)
        }
    }

    private func depthsPage(_ tag: String, _ items: [Depth], _ show: Bool) -> some View {
        VStack(spacing: 0) {
            Text(tag).font(EmType.serif(28)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.06, reduce: reduceMotion)
            Text("The map for everything below.")
                .font(EmType.serifItalic(15)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).padding(.top, 4)
                .reveal(show, 0.12, reduce: reduceMotion)
            HStack(spacing: 8) {
                Rectangle().fill(DeepDivePalette.goldBright.opacity(0.4)).frame(width: 16, height: 1)
                Text("Tap each to open").font(.system(size: 10, weight: .semibold)).tracking(1.6)
                    .foregroundColor(DeepDivePalette.goldBright)
                Image(systemName: "chevron.compact.down").font(.system(size: 12)).foregroundColor(DeepDivePalette.goldBright)
                Rectangle().fill(DeepDivePalette.goldBright.opacity(0.4)).frame(width: 16, height: 1)
            }
            .padding(.top, 14).padding(.bottom, 18).reveal(show, 0.2, reduce: reduceMotion)
            VStack(spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.element.id) { di, d in
                    depthCard(di, d, show)
                }
            }
        }
    }

    private func depthCard(_ di: Int, _ d: Depth, _ show: Bool) -> some View {
        let open = openDepths.contains(di)
        return Button {
            withAnimation(.easeInOut(duration: 0.45)) {
                if open { openDepths.remove(di) } else { openDepths.insert(di) }
            }
        } label: {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(roman(di + 1)) · \(d.tr)").font(EmType.serif(17)).foregroundColor(DeepDivePalette.cream)
                        Text(d.label(lang)).font(.system(size: 11)).foregroundColor(DeepDivePalette.mute)
                            .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    }
                    Spacer()
                    Text(d.ar).font(EmType.arabic(24, bold: true))
                        .foregroundColor(open ? DeepDivePalette.goldBright : DeepDivePalette.gold)
                }
                if open {
                    Rectangle().fill(DeepDivePalette.gold.opacity(0.22)).frame(height: 1).padding(.vertical, 12)
                    Text(d.desc(lang)).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.8))
                        .lineSpacing(3 * s).fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    Text("→ \(d.embodies(lang))".uppercased()).font(.system(size: 10.5, weight: .semibold)).tracking(1.2)
                        .foregroundColor(DeepDivePalette.gold).padding(.top, 10)
                        .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(RoundedRectangle(cornerRadius: 16).fill(open ? DeepDivePalette.goldBright.opacity(0.06) : Color.white.opacity(0.022)))
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(open ? DeepDivePalette.goldBright.opacity(0.34) : DeepDivePalette.gold.opacity(0.16), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .reveal(show, 0.3 + Double(di) * 0.16, reduce: reduceMotion)
    }

    private func actPage(_ act: Int, _ connector: String?, _ line: String, _ bridge: BridgeVerse?, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            if let connector {
                Text(connector).font(.system(size: 13)).foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .padding(.bottom, 24).reveal(show, reduce: reduceMotion)
            }
            Text("Movement").font(.system(size: 11, weight: .semibold)).tracking(6)
                .foregroundColor(DeepDivePalette.gold).padding(.bottom, 14).reveal(show, 0.1, reduce: reduceMotion)
            Text(roman(act)).font(EmType.serif(80)).foregroundColor(DeepDivePalette.goldBright.opacity(0.28))
                .reveal(show, 0.2, reduce: reduceMotion)
            Text(dive.actInfo(act)?.ar ?? "").font(EmType.arabic(40, bold: true)).foregroundColor(DeepDivePalette.goldBright)
                .padding(.top, 8).reveal(show, 0.36, reduce: reduceMotion)
            Text(dive.actInfo(act)?.tr ?? "").font(EmType.serif(26)).foregroundColor(DeepDivePalette.cream)
                .padding(.top, 6).reveal(show, 0.36, reduce: reduceMotion)
            Text("\(dive.actInfo(act)?.name(lang) ?? "") · \(dive.stageNoun) \(act) of \(dive.acts.count)".uppercased())
                .font(.system(size: 10, weight: .semibold)).tracking(2.4)
                .foregroundColor(DeepDivePalette.mute).padding(.top, 8)
                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.36, reduce: reduceMotion)
            if let b = bridge {
                VStack(spacing: 10) {
                    Text(b.arabic).font(EmType.arabic(22 * s)).foregroundColor(DeepDivePalette.cream)
                        .multilineTextAlignment(.center).lineSpacing(9 * s).environment(\.layoutDirection, .rightToLeft)
                    if !b.translation(lang).isEmpty {
                        Text(b.translation(lang)).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.8))
                            .multilineTextAlignment(.center)
                            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    }
                    Text(b.reference).font(.system(size: 11, weight: .semibold)).tracking(2).foregroundColor(DeepDivePalette.gold.opacity(0.8))
                }
                .padding(18).frame(maxWidth: 380)
                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.02)))
                .overlay(RoundedRectangle(cornerRadius: 14).stroke(DeepDivePalette.gold.opacity(0.16), lineWidth: 1))
                .padding(.top, 26).reveal(show, 0.6, reduce: reduceMotion)
            }
            hairline.padding(.top, 24).padding(.bottom, 20).reveal(show, bridge == nil ? 0.6 : 0.85, reduce: reduceMotion)
            Text(line).font(EmType.serifItalic(18 * s)).foregroundColor(Color(white: 0.72))
                .multilineTextAlignment(.center).lineSpacing(5 * s).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, bridge == nil ? 0.6 : 0.85, reduce: reduceMotion)
            bob("Continue", show, 1.1).padding(.top, 30)
        }
    }

    private func narrationPage(_ tag: String, _ source: String, _ body: String, _ reflection: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            tagLabel(tag, show).padding(.bottom, 28)
            Text(body).font(EmType.serif(21 * s)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center).lineSpacing(8 * s)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.25, reduce: reduceMotion)
            Text(source).font(.system(size: 11, weight: .semibold)).tracking(2)
                .foregroundColor(DeepDivePalette.gold.opacity(0.75)).padding(.top, 24)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.8, reduce: reduceMotion)
            hairline.padding(.top, 26).padding(.bottom, 20).reveal(show, 1.05, reduce: reduceMotion)
            Text(reflection).font(EmType.serifItalic(16 * s)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).lineSpacing(4 * s).frame(maxWidth: 330)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 1.05, reduce: reduceMotion)
        }
    }

    /// The hadith-qudsi reply. God's answer to the line just recited, staged as a
    /// call-and-response: a thread of light descends from above, a fixed "He answers"
    /// eyebrow gives the three replies one recurring identity, then His words glow.
    private func responsePage(_ replyingTo: String, _ arabic: String, _ words: String, _ source: String, _ reflection: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(LinearGradient(colors: [DeepDivePalette.goldBright.opacity(0.7), DeepDivePalette.goldBright.opacity(0)],
                                     startPoint: .top, endPoint: .bottom))
                .frame(width: 1, height: 22)
                .reveal(show, 0.06, reduce: reduceMotion)
            Text("He Answers".uppercased())
                .font(.system(size: 11, weight: .semibold)).tracking(4)
                .foregroundColor(DeepDivePalette.goldBright)
                .padding(.top, 10).reveal(show, 0.12, reduce: reduceMotion)
            Text(replyingTo.uppercased())
                .font(.system(size: 10, weight: .semibold)).tracking(2)
                .foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).padding(.top, 12)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.18, reduce: reduceMotion)
            if !arabic.isEmpty {
                Text(arabic).font(EmType.arabic(23 * s, bold: true))
                    .foregroundColor(DeepDivePalette.goldBright)
                    .environment(\.layoutDirection, .rightToLeft)
                    .shadow(color: DeepDivePalette.goldBright.opacity(0.3), radius: 16)
                    .padding(.top, 24).reveal(show, 0.32, reduce: reduceMotion)
            }
            Text(words).font(EmType.serifItalic(25 * s)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 320)
                .shadow(color: DeepDivePalette.goldBright.opacity(0.22), radius: 22)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .padding(.top, 20).reveal(show, 0.52, reduce: reduceMotion)
            Text(source).font(.system(size: 11, weight: .semibold)).tracking(2)
                .foregroundColor(DeepDivePalette.gold.opacity(0.8))
                .multilineTextAlignment(.center).padding(.top, 22)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.82, reduce: reduceMotion)
            hairline.padding(.top, 26).padding(.bottom, 20).reveal(show, 1.0, reduce: reduceMotion)
            Text(reflection).font(.system(size: 15 * s)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 330)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 1.0, reduce: reduceMotion)
        }
    }

    /// The recurring question of al-Rahman. The refrain verse glows; the reader presses
    /// "Answer Him" and the taught reply RISES on an ascending thread of light - the
    /// deliberate inverse of `responsePage`'s descending one (there He answers you; here
    /// He asks and you answer). First occurrence carries the teaching source; later
    /// occurrences just ask again. The reflection is written to be read after answering,
    /// so it only appears once the answer is given.
    private func refrainPage(_ index: Int, _ tag: String, _ arabic: String, _ translation: String, _ reference: String, _ intro: String, _ teachSource: String?, _ replyArabic: String, _ replyTransliteration: String, _ replyTranslation: String, _ reflection: String, _ show: Bool) -> some View {
        let answered = answeredRefrains.contains(index)
        return VStack(spacing: 0) {
            tagLabel(tag, show).padding(.bottom, 26)
            Text(arabic).font(EmType.arabic(26 * s, bold: true)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center).lineSpacing(12 * s)
                .environment(\.layoutDirection, .rightToLeft)
                .shadow(color: DeepDivePalette.goldBright.opacity(0.2), radius: 18)
                .reveal(show, 0.2, reduce: reduceMotion)
            Text(translation).font(EmType.serifItalic(19 * s)).foregroundColor(Color(white: 0.8))
                .multilineTextAlignment(.center).lineSpacing(4 * s).padding(.top, 20).frame(maxWidth: 380)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.45, reduce: reduceMotion)
            Text(reference).font(.system(size: 11, weight: .semibold)).tracking(2)
                .foregroundColor(DeepDivePalette.gold.opacity(0.85)).padding(.top, 14)
                .reveal(show, 0.45, reduce: reduceMotion)
            hairline.padding(.top, 24).padding(.bottom, 18).reveal(show, 0.7, reduce: reduceMotion)
            Text(intro).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.72))
                .multilineTextAlignment(.center).lineSpacing(3 * s).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.7, reduce: reduceMotion)
            if answered {
                // The answer, risen: a thread of light that intensifies downward into
                // the reader's own words - light on its way up.
                Rectangle()
                    .fill(LinearGradient(colors: [DeepDivePalette.goldBright.opacity(0), DeepDivePalette.goldBright.opacity(0.7)],
                                         startPoint: .top, endPoint: .bottom))
                    .frame(width: 1, height: 22)
                    .padding(.top, 24)
                Text("You Answer".uppercased())
                    .font(.system(size: 11, weight: .semibold)).tracking(4)
                    .foregroundColor(DeepDivePalette.goldBright)
                    .padding(.top, 10)
                Text(replyArabic).font(EmType.arabic(26 * s, bold: true))
                    .foregroundColor(DeepDivePalette.goldBright)
                    .multilineTextAlignment(.center).lineSpacing(10 * s)
                    .environment(\.layoutDirection, .rightToLeft)
                    .shadow(color: DeepDivePalette.goldBright.opacity(0.35), radius: 20)
                    .padding(.top, 18)
                Text(replyTransliteration)
                    .font(.system(size: 12, weight: .medium)).tracking(0.6)
                    .foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center).padding(.top, 10)
                Text(replyTranslation).font(EmType.serifItalic(21 * s)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).lineSpacing(5 * s).frame(maxWidth: 330)
                    .shadow(color: DeepDivePalette.goldBright.opacity(0.2), radius: 22)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .padding(.top, 14)
                DuaListenButton(arabic: replyArabic).padding(.top, 16)
                if let teachSource {
                    Text(teachSource).font(.system(size: 11, weight: .semibold)).tracking(2)
                        .foregroundColor(DeepDivePalette.gold.opacity(0.8))
                        .multilineTextAlignment(.center).padding(.top, 18)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                }
                hairline.padding(.top, 24).padding(.bottom, 18)
                Text(reflection).font(.system(size: 15 * s)).foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 340)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
            } else {
                Button {
                    UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                    withAnimation(reduceMotion ? nil : .easeOut(duration: 0.7)) {
                        _ = answeredRefrains.insert(index)
                    }
                } label: {
                    VStack(spacing: 8) {
                        Image(systemName: "chevron.compact.up")
                            .font(.system(size: 14)).foregroundColor(DeepDivePalette.goldBright)
                        Text("Answer Him".uppercased())
                            .font(.system(size: 12, weight: .semibold)).tracking(3.5)
                            .foregroundColor(DeepDivePalette.goldBright)
                            .padding(.horizontal, 26).padding(.vertical, 13)
                            .overlay(Capsule().stroke(DeepDivePalette.goldBright.opacity(0.35), lineWidth: 1))
                            .shadow(color: DeepDivePalette.goldBright.opacity(0.25), radius: 14)
                    }
                }
                .buttonStyle(EmPressStyle())
                .padding(.top, 30)
                .reveal(show, 0.95, reduce: reduceMotion)
            }
        }
        .animation(reduceMotion ? nil : .easeOut(duration: 0.7), value: answered)
    }

    private func climaxPage(_ tag: String, _ source: String, _ arabic: String, _ translation: String, _ body: String, _ reflection: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            tagLabel(tag, show).padding(.bottom, 26)
            Text(body).font(.system(size: 15 * s)).foregroundColor(Color(white: 0.72))
                .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 360).padding(.bottom, 30)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.2, reduce: reduceMotion)
            Text(arabic).font(EmType.arabic(30 * s, bold: true)).foregroundColor(DeepDivePalette.goldBright)
                .environment(\.layoutDirection, .rightToLeft)
                .shadow(color: DeepDivePalette.goldBright.opacity(0.25), radius: 18)
                .reveal(show, 0.65, reduce: reduceMotion)
            if !translation.isEmpty {
                Text(translation).font(EmType.serifItalic(22 * s)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .padding(.top, 22).reveal(show, 1.0, reduce: reduceMotion)
            }
            Text(source).font(.system(size: 11, weight: .semibold)).tracking(2)
                .foregroundColor(DeepDivePalette.gold.opacity(0.8)).padding(.top, 16)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 1.0, reduce: reduceMotion)
            hairline.padding(.top, 28).padding(.bottom, 22).reveal(show, 1.35, reduce: reduceMotion)
            Text(reflection).font(.system(size: 15 * s)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 1.35, reduce: reduceMotion)
        }
    }

    private func reflectionPage(_ prompt: String, _ subline: String, _ nextLabel: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            Text("✦").font(.system(size: 20)).foregroundColor(DeepDivePalette.gold).padding(.bottom, 22)
                .reveal(show, reduce: reduceMotion)
            Text(prompt).font(EmType.serif(34)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.15, reduce: reduceMotion)
            Text(subline)
                .font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.72))
                .multilineTextAlignment(.center).lineSpacing(3 * s).padding(.top, 16).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.35, reduce: reduceMotion)
            bob(nextLabel, show).padding(.top, 34)
        }
    }

    // MARK: The release (Tawakkul)

    /// The interactive entrusting. Idle: the prompt and a thin gold ring - the grip.
    /// Holding: the ring fills over `releaseHoldDuration`; once full, while still
    /// holding, the label turns to "Now - let go". Lifting the finger after the fill
    /// IS the release - the gesture maps to the meaning, so nothing happens until the
    /// reader actually lets go. Lifting early resets the ring gently.
    private func releasePage(_ prompt: String, _ subline: String, _ arabic: String, _ translation: String, _ reference: String, _ note: String, _ nextLabel: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            if releaseDone {
                Text(arabic).font(EmType.arabic(30 * s, bold: true)).foregroundColor(DeepDivePalette.goldBright)
                    .multilineTextAlignment(.center).lineSpacing(10 * s)
                    .environment(\.layoutDirection, .rightToLeft)
                    .shadow(color: DeepDivePalette.goldBright.opacity(0.35), radius: 22)
                Text(translation).font(EmType.serifItalic(21 * s)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).lineSpacing(4 * s).padding(.top, 16).frame(maxWidth: 340)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                Text(reference).font(.system(size: 11, weight: .semibold)).tracking(2)
                    .foregroundColor(DeepDivePalette.gold.opacity(0.85)).padding(.top, 14)
                hairline.padding(.vertical, 22)
                Text(note).font(.system(size: 14 * s)).foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center).lineSpacing(5 * s).frame(maxWidth: 320)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                bob(nextLabel, true, 0.4).padding(.top, 30)
            } else {
                Text("✦").font(.system(size: 20)).foregroundColor(DeepDivePalette.gold)
                    .opacity(releaseHolding ? 0.35 : 1)
                    .reveal(show, reduce: reduceMotion)
                Text(prompt).font(EmType.serif(34)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).padding(.top, 20)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .opacity(releaseHolding ? 0.45 : 1)
                    .reveal(show, 0.15, reduce: reduceMotion)
                Text(releaseHolding ? "Hold it. All of it." : subline)
                    .font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.72))
                    .multilineTextAlignment(.center).lineSpacing(3 * s).padding(.top, 14).frame(maxWidth: 320)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .opacity(releaseHolding ? 0.5 : 1)
                    .reveal(show, 0.3, reduce: reduceMotion)
                releaseRing.padding(.top, 34).reveal(show, 0.5, reduce: reduceMotion)
                Text((releasePrimed ? "Now - let go" : "Press and hold - that is the grip").uppercased())
                    .font(.system(size: releasePrimed ? 12 : 10.5, weight: .semibold))
                    .tracking(releasePrimed ? 4 : 3)
                    .foregroundColor(releasePrimed ? DeepDivePalette.goldBright : DeepDivePalette.gold)
                    .shadow(color: releasePrimed ? DeepDivePalette.goldBright.opacity(0.4) : .clear, radius: 12)
                    .padding(.top, 18)
                    .reveal(show, 0.6, reduce: reduceMotion)
            }
        }
        .background {
            if releaseDone {
                RadialGradient(colors: [DeepDivePalette.goldBright.opacity(0.10), .clear],
                               center: .center, startRadius: 10, endRadius: 280)
                    .allowsHitTesting(false)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: releaseHolding)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.5), value: releasePrimed)
    }

    /// The grip itself: an outer ring that fills while held, and a core that swells
    /// once the release is primed.
    private var releaseRing: some View {
        ZStack {
            Circle().stroke(DeepDivePalette.gold.opacity(0.5), lineWidth: 1.5)
            Circle()
                .trim(from: 0, to: releaseHolding || releasePrimed ? 1 : 0)
                .stroke(DeepDivePalette.goldBright, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(reduceMotion ? nil :
                            (releaseHolding ? .linear(duration: releaseHoldDuration) : .easeOut(duration: 0.3)),
                           value: releaseHolding)
            Circle().fill(DeepDivePalette.goldBright)
                .frame(width: releasePrimed ? 36 : 14, height: releasePrimed ? 36 : 14)
                .shadow(color: DeepDivePalette.goldBright.opacity(0.8), radius: releasePrimed ? 26 : 12)
        }
        .frame(width: 120, height: 120)
        .contentShape(Circle())
        .gesture(releaseGesture)
    }

    private var releaseGesture: some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { _ in
                guard !releaseDone, !releaseHolding else { return }
                releaseHolding = true
                let started = Date()
                releaseHoldStart = started
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                DispatchQueue.main.asyncAfter(deadline: .now() + releaseHoldDuration) {
                    // Only prime if this same uninterrupted hold is still down.
                    if releaseHolding, releaseHoldStart == started {
                        releasePrimed = true
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }
            }
            .onEnded { _ in
                if releasePrimed {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.6)) { releaseDone = true }
                } else {
                    releaseHoldStart = nil
                    releaseHolding = false
                }
            }
    }

    // MARK: The count (Shukr)

    /// The interactive counting. Idle: the prompt and a single seed-light. Counting:
    /// each tap births a light and ticks the tally. At `countOverflowAt` taps the
    /// cascade begins - the tally accelerates past any finger and lights pour in -
    /// then the verse takes over: the count cannot be finished. The failure IS the
    /// meaning, so the reader never reaches an end.
    private func countPage(_ prompt: String, _ subline: String, _ arabic: String, _ translation: String, _ reference: String, _ note: String, _ nextLabel: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            if countDone {
                Text(arabic).font(EmType.arabic(30 * s, bold: true)).foregroundColor(DeepDivePalette.goldBright)
                    .multilineTextAlignment(.center).lineSpacing(10 * s)
                    .environment(\.layoutDirection, .rightToLeft)
                    .shadow(color: DeepDivePalette.goldBright.opacity(0.35), radius: 22)
                Text(translation).font(EmType.serifItalic(21 * s)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).lineSpacing(4 * s).padding(.top, 16).frame(maxWidth: 340)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                Text(reference).font(.system(size: 11, weight: .semibold)).tracking(2)
                    .foregroundColor(DeepDivePalette.gold.opacity(0.85)).padding(.top, 14)
                hairline.padding(.vertical, 22)
                Text(note).font(.system(size: 14 * s)).foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center).lineSpacing(5 * s).frame(maxWidth: 320)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                bob(nextLabel, true, 0.4).padding(.top, 30)
            } else {
                Text("✦").font(.system(size: 20)).foregroundColor(DeepDivePalette.gold)
                    .opacity(countOverflow ? 0.35 : 1)
                    .reveal(show, reduce: reduceMotion)
                Text(prompt).font(EmType.serif(34)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).padding(.top, 20)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .opacity(countOverflow ? 0.4 : 1)
                    .reveal(show, 0.15, reduce: reduceMotion)
                if countTaps == 0 {
                    Text(subline).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.72))
                        .multilineTextAlignment(.center).lineSpacing(3 * s).padding(.top, 14).frame(maxWidth: 320)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                        .reveal(show, 0.3, reduce: reduceMotion)
                }
                if countTaps > 0 {
                    VStack(spacing: 10) {
                        Text("\(countTally)")
                            .font(EmType.serif(54)).foregroundColor(DeepDivePalette.goldBright)
                            .shadow(color: DeepDivePalette.goldBright.opacity(0.4), radius: 22)
                            .contentTransition(.numericText())
                        if countOverflow {
                            Text("And counting itself".uppercased())
                                .font(.system(size: 9.5, weight: .semibold)).tracking(2.6)
                                .foregroundColor(DeepDivePalette.mute)
                        }
                    }
                    .padding(.top, 22)
                    .animation(reduceMotion ? nil : .easeOut(duration: 0.2), value: countTally)
                }
                countField
                    .padding(.top, countTaps == 0 ? 34 : 14)
                    .reveal(show, 0.5, reduce: reduceMotion)
                Text((countOverflow ? "They outrun the count" : "Tap - each tap, one blessing").uppercased())
                    .font(.system(size: countOverflow ? 12 : 10.5, weight: .semibold))
                    .tracking(countOverflow ? 4 : 3)
                    .foregroundColor(countOverflow ? DeepDivePalette.goldBright : DeepDivePalette.gold)
                    .shadow(color: countOverflow ? DeepDivePalette.goldBright.opacity(0.4) : .clear, radius: 12)
                    .padding(.top, 18)
                    .reveal(show, 0.6, reduce: reduceMotion)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { if !countDone { countTap() } }
        .background {
            if countDone {
                RadialGradient(colors: [DeepDivePalette.goldBright.opacity(0.10), .clear],
                               center: .center, startRadius: 10, endRadius: 280)
                    .allowsHitTesting(false)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: countOverflow)
        .onDisappear { countTimer?.invalidate(); countTimer = nil }
    }

    /// The field of blessing-lights. A single seed-light invites the first tap;
    /// each light after that is one counted blessing (then many uncounted ones).
    private var countField: some View {
        GeometryReader { geo in
            ZStack {
                if countLights.isEmpty {
                    Circle().fill(DeepDivePalette.goldBright)
                        .frame(width: 14, height: 14)
                        .shadow(color: DeepDivePalette.goldBright.opacity(0.8), radius: 12)
                        .position(x: geo.size.width / 2, y: geo.size.height / 2)
                }
                ForEach(countLights) { light in
                    Circle().fill(DeepDivePalette.goldBright)
                        .frame(width: light.size, height: light.size)
                        .opacity(light.opacity)
                        .shadow(color: DeepDivePalette.goldBright.opacity(0.7), radius: light.size)
                        .position(x: light.x * geo.size.width, y: light.y * geo.size.height)
                        .transition(reduceMotion ? .opacity :
                            .scale(scale: 0.2).combined(with: .opacity))
                }
            }
        }
        .frame(maxWidth: 300)
        .frame(height: 190)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.5), value: countLights.count)
    }

    private func addCountLight() {
        countLights.append(CountLight(
            x: .random(in: 0.03...0.97), y: .random(in: 0.05...0.95),
            size: .random(in: 2.5...4.5), opacity: .random(in: 0.5...0.95)))
    }

    private func countTap() {
        guard !countOverflow, !countDone else { return }
        countTaps += 1
        countTally = countTaps
        addCountLight()
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        if countTaps >= countOverflowAt { beginCountOverflow() }
    }

    /// The cascade: the tally accelerates past any finger and lights pour in for
    /// ~2.2s, then the verse takes over. With reduceMotion the field appears as a
    /// single state swap and resolves after a beat - no cascade.
    private func beginCountOverflow() {
        countOverflow = true
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        if reduceMotion {
            (0..<40).forEach { _ in addCountLight() }
            countTally = 999
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                guard countOverflow, !countDone else { return }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                countDone = true
            }
            return
        }
        var tick = 0
        countTimer?.invalidate()
        countTimer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { timer in
            tick += 1
            countTally += tick * Int.random(in: 2...5)
            if countLights.count < 110 { (0..<4).forEach { _ in addCountLight() } }
            if tick >= 18 {
                timer.invalidate()
                countTimer = nil
                UINotificationFeedbackGenerator().notificationOccurred(.success)
                withAnimation(.easeInOut(duration: 0.6)) { countDone = true }
            }
        }
    }

    private func duaPage(_ tag: String, _ intro: String, _ arabic: String, _ translation: String, _ source: String, _ note: String, _ close: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            Text(tag.uppercased()).font(.system(size: 11, weight: .semibold)).tracking(3.4)
                .foregroundColor(DeepDivePalette.gold).padding(.bottom, 22)
                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, reduce: reduceMotion)
            Text(intro).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.72))
                .multilineTextAlignment(.center).lineSpacing(3 * s).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.15, reduce: reduceMotion)
            Text(arabic).font(EmType.arabic(24 * s)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center).lineSpacing(14 * s).environment(\.layoutDirection, .rightToLeft)
                .padding(.top, 26).shadow(color: DeepDivePalette.goldBright.opacity(0.14), radius: 20)
                .reveal(show, 0.38, reduce: reduceMotion)
            DuaListenButton(arabic: arabic).padding(.top, 18).reveal(show, 0.5, reduce: reduceMotion)
            if !translation.isEmpty {
                Text(translation).font(EmType.serifItalic(19 * s)).foregroundColor(Color(white: 0.8))
                    .multilineTextAlignment(.center).lineSpacing(4 * s).padding(.top, 22).frame(maxWidth: 400)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .reveal(show, 0.72, reduce: reduceMotion)
            }
            Text(source).font(.system(size: 11, weight: .semibold)).tracking(1)
                .foregroundColor(DeepDivePalette.gold.opacity(0.85)).padding(.top, 16).multilineTextAlignment(.center)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.72, reduce: reduceMotion)
            hairline.padding(.top, 24).padding(.bottom, 18).reveal(show, 0.98, reduce: reduceMotion)
            Text(note).font(.system(size: 14 * s)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 350)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.98, reduce: reduceMotion)
            aminBlock(close, show).padding(.top, 30)
        }
    }

    @ViewBuilder
    private func aminBlock(_ close: String, _ show: Bool) -> some View {
        if !saidAmin {
            Button {
                UIImpactFeedbackGenerator(style: .soft).impactOccurred()
                withAnimation { saidAmin = true }
            } label: {
                VStack(spacing: 8) {
                    Text("آمِين").font(EmType.arabic(34)).foregroundColor(DeepDivePalette.goldBright)
                        .shadow(color: DeepDivePalette.goldBright.opacity(0.2), radius: 20)
                    Text("Tap to say Amin").font(.system(size: 10.5, weight: .medium)).tracking(3)
                        .foregroundColor(DeepDivePalette.gold).opacity(0.7)
                }
            }
            .buttonStyle(.plain)
            .reveal(show, 1.25, reduce: reduceMotion)
        } else {
            VStack(spacing: 14) {
                Text("Amin.").font(EmType.serifItalic(26)).foregroundColor(DeepDivePalette.goldBright)
                Text("The descent ends. \(close)")
                    .font(.system(size: 14 * s)).foregroundColor(DeepDivePalette.mute).multilineTextAlignment(.center)
                Button {
                    withAnimation {
                        saidAmin = false; openDepths = [0]
                        releaseHolding = false; releasePrimed = false
                        releaseDone = false; releaseHoldStart = nil
                        countTimer?.invalidate(); countTimer = nil
                        countTaps = 0; countTally = 0
                        countOverflow = false; countDone = false; countLights = []
                        answeredRefrains = []
                    }
                    withAnimation(.easeInOut(duration: 0.6)) { currentID = 0 }
                } label: {
                    Text("Begin again").font(.system(size: 11, weight: .regular)).tracking(2)
                        .foregroundColor(DeepDivePalette.gold).padding(.horizontal, 22).padding(.vertical, 11)
                        .overlay(Capsule().stroke(DeepDivePalette.gold.opacity(0.24), lineWidth: 1))
                }
                .buttonStyle(.plain).padding(.top, 14)
            }
        }
    }

    private func closingPage(_ tag: String, _ titleAr: String, _ essence: String, _ line: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            tagLabel(tag, show).padding(.bottom, 26)
            Text(titleAr).font(EmType.arabic(56)).foregroundColor(DeepDivePalette.goldBright)
                .shadow(color: DeepDivePalette.goldBright.opacity(0.2), radius: 20)
                .reveal(show, 0.2, reduce: reduceMotion)
            Text(essence).font(EmType.serifItalic(20 * s)).foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center).lineSpacing(5 * s).padding(.top, 20).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.45, reduce: reduceMotion)
            hairline.padding(.vertical, 26).reveal(show, 0.7, reduce: reduceMotion)
            Text(line).font(.system(size: 14 * s)).foregroundColor(DeepDivePalette.mute)
                .multilineTextAlignment(.center).lineSpacing(6 * s).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.7, reduce: reduceMotion)
            VStack(spacing: 12) {
                if let onReadSurah {
                    Button(action: onReadSurah) {
                        Text(JourneyStrings.readTheFullSurah(lang))
                            .font(.system(size: 13, weight: .semibold)).tracking(1)
                            .foregroundColor(Color(red: 0.12, green: 0.09, blue: 0.03))
                            .padding(.horizontal, 26).padding(.vertical, 13)
                            .background(Capsule().fill(
                                LinearGradient(colors: [DeepDivePalette.gold, DeepDivePalette.goldBright],
                                               startPoint: .leading, endPoint: .trailing)))
                    }
                    .buttonStyle(.plain)
                }
                Button(action: onClose) {
                    Text(JourneyStrings.done(lang)).font(.system(size: 11, weight: .regular)).tracking(2)
                        .foregroundColor(DeepDivePalette.gold).padding(.horizontal, 22).padding(.vertical, 11)
                        .overlay(Capsule().stroke(DeepDivePalette.gold.opacity(0.24), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
            .padding(.top, 30).reveal(show, 1.0, reduce: reduceMotion)
        }
    }
}

#if DEBUG
#Preview("Yaqin Deep Dive") {
    DeepDiveView(dive: .yaqin, onClose: {})
}
#endif
