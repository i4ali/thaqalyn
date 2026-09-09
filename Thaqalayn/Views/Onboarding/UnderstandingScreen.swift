//
//  UnderstandingScreen.swift
//  Thaqalayn
//
//  Onboarding screen (tag 2): a teaser for Understanding, the passage
//  commentary. A reader card styled like the real Understanding screen plays
//  al-Fatihah's first passage through its four parts - essay, verse by verse,
//  narrations, perspectives - while a rail beside it lights each part in turn.
//  Content is hardcoded from passages_1.json (al-Fatihah is free, so the user
//  meets exactly this after onboarding). English-only, matching the rest of
//  onboarding. Design: docs/plans/2026-09-09-understanding-onboarding-design.md
//

import SwiftUI

struct UnderstandingScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var isVisible = false   // staggered entrance
    @State private var tick = 0            // one per 0.35 s; the whole loop derives from it
    @State private var haloPulse = false   // the active rail stop breathes

    private let gold = Color(hex: "ECD49A")
    private let cream = Color(hex: "F1E8D6")

    /// The four parts of Understanding, in reading order - the rail's stops.
    private enum Part: Int, CaseIterable {
        case essay, verse, narrations, perspectives

        var label: String {
            switch self {
            case .essay: return "Essay"
            case .verse: return "Verse by verse"
            case .narrations: return "Narrations"
            case .perspectives: return "Perspectives"
            }
        }
    }

    /// Ticks each beat holds the card, in `Part` order (0.35 s per tick, about 14 s a loop).
    private static let beatTicks = [13, 9, 10, 9]
    private static let cardHeight: CGFloat = 304
    private static let stopPitch: CGFloat = cardHeight / 4

    private let clock = Timer.publish(every: 0.35, on: .main, in: .common).autoconnect()

    /// Where the loop is: the part on the card and how many ticks it has been there.
    private var position: (part: Part, offset: Int) {
        var t = tick % Self.beatTicks.reduce(0, +)
        for (i, length) in Self.beatTicks.enumerated() {
            if t < length { return (Part(rawValue: i) ?? .essay, t) }
            t -= length
        }
        return (.essay, 0)
    }

    /// The lit part. Under Reduce Motion the card is a static composite of all four,
    /// so every stop reads as reached.
    private var part: Part { reduceMotion ? .perspectives : position.part }

    /// Lines of a beat write in one every two ticks (0.7 s).
    private func shown(_ line: Int) -> Bool {
        reduceMotion || position.offset >= line * 2
    }

    var body: some View {
        ZStack {
            OnboardingBackground(tilt: .mauve)
            DeepDiveMotes(count: 12)
            content
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            isVisible = true
            if !reduceMotion { haloPulse = true }
        }
        .onReceive(clock) { _ in
            guard !reduceMotion else { return }
            withAnimation(.easeInOut(duration: 0.55)) { tick += 1 }
        }
    }

    // MARK: - Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Spacer(minLength: 18)
            hero
            Spacer(minLength: 18)
            footer
        }
        .padding(.horizontal, 34)
        .padding(.top, 62)
        .padding(.bottom, 68)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Understanding")
                .onbEyebrow()
                .foregroundColor(gold)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -16)
                .animation(.easeOut(duration: 0.6).delay(0.15), value: isVisible)

            Text("Understand\nevery passage")
                .onbHeroTitle()
                .foregroundColor(themeManager.primaryText)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 14)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 26)
                .animation(.easeOut(duration: 0.6).delay(0.28), value: isVisible)

            Text("Each surah is read in passages, a few verses that belong together. Read one, tap Understand, and the passage is explained in one plain essay, then verse by verse, with what the Imams said and where Shia and Sunni scholars differ. Every source is one tap away.")
                .onbBody()
                .foregroundColor(themeManager.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
                .lineSpacing(3)
                .padding(.top, 14)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.42), value: isVisible)
        }
    }

    // MARK: - Hero: the rail and the living reader card

    private var hero: some View {
        HStack(alignment: .top, spacing: 10) {
            labels
            rail
            readerCard
        }
        .frame(maxWidth: .infinity)
        .scaleEffect(isVisible ? 1 : 0.86)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(response: 0.7, dampingFraction: 0.72).delay(0.55), value: isVisible)
    }

    private var labels: some View {
        VStack(spacing: 0) {
            ForEach(Part.allCases, id: \.rawValue) { p in
                Text(p.label.uppercased())
                    .font(.system(size: 10, weight: .bold))
                    .tracking(1)
                    .foregroundColor(p == part ? gold : cream.opacity(p.rawValue < part.rawValue ? 0.6 : 0.32))
                    .multilineTextAlignment(.trailing)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .frame(height: Self.stopPitch)
                    .animation(.easeInOut(duration: 0.45), value: part)
            }
        }
        .frame(width: 96)
    }

    private var rail: some View {
        ZStack(alignment: .top) {
            // Track between the first and last stops.
            Rectangle()
                .fill(gold.opacity(0.16))
                .frame(width: 1, height: Self.cardHeight - Self.stopPitch)
                .padding(.top, Self.stopPitch / 2)

            // Gold fill from the first stop down to the lit one.
            Rectangle()
                .fill(gold)
                .frame(width: 1, height: CGFloat(part.rawValue) * Self.stopPitch)
                .padding(.top, Self.stopPitch / 2)
                .animation(.easeInOut(duration: 0.6), value: part)

            VStack(spacing: 0) {
                ForEach(Part.allCases, id: \.rawValue) { p in
                    stop(p)
                        .frame(height: Self.stopPitch)
                }
            }
        }
        .frame(width: 22, height: Self.cardHeight)
    }

    private func stop(_ p: Part) -> some View {
        let active = p == part
        let reached = p.rawValue <= part.rawValue
        return ZStack {
            Circle()
                .fill(gold.opacity(0.18))
                .frame(width: 22, height: 22)
                .scaleEffect(haloPulse ? 1.25 : 0.9)
                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: haloPulse)
                .opacity(active ? 1 : 0)

            Circle()
                .fill(reached ? gold : Color.clear)
                .frame(width: 8, height: 8)
                .overlay(Circle().stroke(gold.opacity(reached ? 0 : 0.35), lineWidth: 1))
                .scaleEffect(active ? 1.15 : 1)
        }
        .animation(.easeInOut(duration: 0.45), value: part)
    }

    private var readerCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            miniChrome

            ZStack(alignment: .topLeading) {
                if reduceMotion {
                    staticComposite
                } else {
                    beatContent
                        .id(position.part)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .offset(y: 18)),
                            removal: .opacity.combined(with: .offset(y: -18))))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .mask(
                // Content that runs past the card fades out like a page that continues.
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.86),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top, endPoint: .bottom)
            )
            .overlay(alignment: .bottomLeading) { sourceChip }
        }
        .frame(maxWidth: .infinity)
        .frame(height: Self.cardHeight)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(gold.opacity(0.22), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.45), radius: 22, x: 0, y: 12)
    }

    /// A miniature of the real reader's header: back circle and the Listen capsule.
    private var miniChrome: some View {
        HStack {
            Image(systemName: "chevron.left")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(gold)
                .frame(width: 22, height: 22)
                .overlay(Circle().stroke(gold.opacity(0.35), lineWidth: 1))

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "play.fill")
                    .font(.system(size: 7, weight: .semibold))
                Text("Listen")
                    .font(.system(size: 9, weight: .semibold))
            }
            .foregroundColor(gold)
            .padding(.horizontal, 9)
            .frame(height: 22)
            .background(Capsule().fill(gold.opacity(0.12)))
            .overlay(Capsule().stroke(gold.opacity(0.3), lineWidth: 1))
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
    }

    // MARK: - The four beats

    @ViewBuilder
    private var beatContent: some View {
        switch position.part {
        case .essay: essayBeat
        case .verse: verseBeat
        case .narrations: narrationBeat
        case .perspectives: perspectivesBeat
        }
    }

    private var essayBeat: some View {
        VStack(alignment: .leading, spacing: 10) {
            reveal(0, titleBlock)
            reveal(1, prose("Seven verses, and all of them are words God gives the worshipper to say. It opens with His Name."))
            reveal(2, prose("Tabatabai reads that opening as the way a deed is marked with God's Name and bound to it, so that it is not left void and cut off", marker: 1))
        }
    }

    private var verseBeat: some View {
        VStack(alignment: .leading, spacing: 10) {
            reveal(0, dividerLabel("Verse by verse"))
            reveal(1, verseRow(4, "Master of the Day"))
            reveal(2, prose("The verse is read two ways, owner of the Day and king of the Day; Tusi glosses the second as: that day the kingship is His alone, given to no one as it was given in this world", marker: 12, italic: true))
            reveal(3, verseRow(5, "Turning to speak to God", dimmed: true))
                .padding(.top, 4)
        }
    }

    private var narrationBeat: some View {
        VStack(alignment: .leading, spacing: 10) {
            reveal(0, verseRow(4, "Master of the Day", dimmed: true))
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 1, style: .continuous)
                    .fill(gold)
                    .frame(width: 2)
                VStack(alignment: .leading, spacing: 6) {
                    reveal(1, speaker("Imam Ali ibn al-Husayn"))
                    reveal(2, prose("Were all between east and west to die, I would feel no desolation so long as the Quran was with me. And when he recited 'Master of the Day of Retribution' he would repeat it until he was near to death."))
                    reveal(4, sourceLine("Sourced · Al-Kafi · vol. 2, hadith 13"))
                }
            }
        }
    }

    private var perspectivesBeat: some View {
        VStack(alignment: .leading, spacing: 10) {
            reveal(0, dividerLabel("Perspectives"))
            reveal(1, prose("The two traditions divide over the first verse."))
            reveal(2, prose("Tabrisi reports that our companions agree the Name-verse is a verse of this surah and of every surah, and that a prayer in which it is dropped is void", marker: 3))
            reveal(3, prose("Tabari argues the opposite: he takes the return of the two mercy names in the third verse as proof that the opening formula is no verse of the Fatiha", marker: 27))
        }
    }

    /// Reduce Motion: the four parts at once, compact, no timer.
    private var staticComposite: some View {
        VStack(alignment: .leading, spacing: 9) {
            titleBlock
            prose("Seven verses, and all of them are words God gives the worshipper to say", marker: 1)
            dividerLabel("Verse by verse")
            verseRow(4, "Master of the Day")
            HStack(alignment: .top, spacing: 10) {
                RoundedRectangle(cornerRadius: 1, style: .continuous).fill(gold).frame(width: 2)
                VStack(alignment: .leading, spacing: 5) {
                    speaker("Imam Ali ibn al-Husayn")
                    prose("Were all between east and west to die, I would feel no desolation so long as the Quran was with me.")
                    sourceLine("Sourced · Al-Kafi · vol. 2, hadith 13")
                }
            }
            dividerLabel("Perspectives")
            prose("The two traditions divide over the first verse", marker: 3)
        }
    }

    /// The tap-to-source moment: two seconds into the essay a source chip surfaces
    /// under the marker, the way the real reader's source sheet answers a tap.
    @ViewBuilder
    private var sourceChip: some View {
        if !reduceMotion && position.part == .essay && shown(4) {
            HStack(spacing: 5) {
                Image(systemName: "book.closed.fill")
                    .font(.system(size: 8, weight: .semibold))
                Text("al-Mizan · Tabatabai · on 1 to 5")
                    .font(.system(size: 9.5, weight: .semibold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .foregroundColor(Color(hex: "0A1512"))
            .padding(.horizontal, 10)
            .frame(height: 24)
            .background(Capsule().fill(gold))
            .shadow(color: gold.opacity(0.35), radius: 10, x: 0, y: 4)
            .padding(.leading, 16)
            .padding(.bottom, 16)
            .transition(.asymmetric(
                insertion: .scale(scale: 0.8, anchor: .bottomLeading).combined(with: .opacity),
                removal: .opacity))
        }
    }

    // MARK: - Reader card pieces

    /// Fades and lifts a line in once the beat has reached it.
    private func reveal<V: View>(_ line: Int, _ view: V) -> some View {
        view
            .opacity(shown(line) ? 1 : 0)
            .offset(y: shown(line) ? 0 : 10)
            .animation(.easeOut(duration: 0.5), value: shown(line))
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("AL-FATIHAH · 1 TO 7")
                .emEyebrow(size: 9, tracking: 1.6)
                .foregroundColor(gold)
            Text("Praise and the straight path")
                .font(EmType.serif(18, .semiBold))
                .foregroundColor(cream)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func prose(_ text: String, marker: Int? = nil, italic: Bool = false) -> some View {
        var line = Text(text)
            .font(italic ? EmType.serifItalic(12.5) : EmType.serif(12.5, .medium))
            .foregroundColor(italic ? cream.opacity(0.7) : cream.opacity(0.88))
        if let marker {
            line = line + Text(" [\(marker)]")
                .font(.system(size: 8, weight: .bold))
                .foregroundColor(gold)
                .baselineOffset(4)
        }
        return line
            .lineSpacing(3)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func dividerLabel(_ label: String) -> some View {
        HStack(spacing: 8) {
            Rectangle().fill(gold.opacity(0.25)).frame(height: 1)
            Text(label.uppercased())
                .emEyebrow(size: 8.5, tracking: 1.4)
                .foregroundColor(gold)
                .fixedSize()
            Rectangle().fill(gold.opacity(0.25)).frame(height: 1)
        }
    }

    private func verseRow(_ n: Int, _ heading: String, dimmed: Bool = false) -> some View {
        HStack(spacing: 8) {
            Text("\(n)")
                .font(EmType.serif(10, .semiBold))
                .foregroundColor(gold)
                .frame(width: 20, height: 20)
                .background(Circle().fill(gold.opacity(0.14)))
            Text(heading)
                .font(EmType.serif(14.5, .semiBold))
                .foregroundColor(cream)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .opacity(dimmed ? 0.5 : 1)
    }

    private func speaker(_ name: String) -> some View {
        Text(name)
            .font(EmType.serif(13.5, .semiBold))
            .foregroundColor(cream)
    }

    private func sourceLine(_ text: String) -> some View {
        Text(text.uppercased())
            .emEyebrow(size: 8.5, tracking: 1)
            .foregroundColor(gold)
            .fixedSize(horizontal: false, vertical: true)
    }

    // MARK: - Footer

    private var footer: some View {
        Text("Open any surah, read a passage, tap Understand")
            .onbCaption()
            .foregroundColor(themeManager.secondaryText)
            .frame(maxWidth: .infinity, alignment: .center)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeOut(duration: 0.6).delay(0.9), value: isVisible)
    }
}

#if DEBUG
#Preview {
    UnderstandingScreen()
}
#endif
