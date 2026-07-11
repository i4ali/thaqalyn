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

    @StateObject private var reading = ReadingSettingsManager.shared
    @StateObject private var languageManager = CommentaryLanguageManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var currentID: Int? = 0
    @State private var progress: CGFloat = 0
    /// First depth starts open so the "tap to open" gesture is obvious.
    @State private var openDepths: Set<Int> = [0]
    @State private var saidAmin = false

    private var s: CGFloat { reading.scale }
    private var currentIndex: Int { currentID ?? 0 }
    /// Active commentary language - resolves every `LocalizedText` field below and
    /// drives RTL layout for Urdu/Arabic.
    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .top) {
                DeepDiveBackground(progress: progress).ignoresSafeArea()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(dive.sections.enumerated()), id: \.offset) { idx, section in
                            page(section, index: idx)
                                .frame(width: geo.size.width, height: geo.size.height)
                                .id(idx)
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
                    let total = max(geo.size.height * CGFloat(dive.sections.count - 1), 1)
                    progress = min(max(-minY / total, 0), 1)
                }

                progressHairline
                closeButton
            }
        }
        .preferredColorScheme(.dark)
        .statusBarHidden(true)
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
                    content(section, show)
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
    private func content(_ section: DeepDiveSection, _ show: Bool) -> some View {
        switch section {
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
            Text("\(dive.actInfo(act)?.name(lang) ?? "") · Depth \(act) of \(dive.acts.count)".uppercased())
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

    private func climaxPage(_ tag: String, _ source: String, _ arabic: String, _ translation: String, _ body: String, _ reflection: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            tagLabel(tag, show).padding(.bottom, 26)
            Text(body).font(.system(size: 15 * s)).foregroundColor(Color(white: 0.66))
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
                .font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.66))
                .multilineTextAlignment(.center).lineSpacing(3 * s).padding(.top, 16).frame(maxWidth: 340)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, 0.35, reduce: reduceMotion)
            bob(nextLabel, show).padding(.top, 34)
        }
    }

    private func duaPage(_ tag: String, _ intro: String, _ arabic: String, _ translation: String, _ source: String, _ note: String, _ close: String, _ show: Bool) -> some View {
        VStack(spacing: 0) {
            Text(tag.uppercased()).font(.system(size: 11, weight: .semibold)).tracking(3.4)
                .foregroundColor(DeepDivePalette.gold).padding(.bottom, 22)
                .multilineTextAlignment(lang.isRTL ? .trailing : .leading)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                .reveal(show, reduce: reduceMotion)
            Text(intro).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.66))
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
                    withAnimation { saidAmin = false; openDepths = [0] }
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
