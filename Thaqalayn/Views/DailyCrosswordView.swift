//
//  DailyCrosswordView.swift
//  Thaqalayn
//
//  Full-screen play sheet for the Daily Crossword — the interactive grid + on-screen
//  keyboard + clue bar, plus the solved/reward overlay.
//
//  Visual target: mockups/daily-crossword/board.png (centre phone = play, right phone = solved).
//  Midnight Emerald is the primary look (Em* components + ThemeManager tokens); a basic
//  legacy/light path is provided too. Structure mirrors DailyChallengeView (emerald vs legacy,
//  sheet, dismiss, Haptics).
//
//  Chrome rule (CLAUDE.md): the grid letters, numbers, clue chrome, and keyboard are FIXED-SIZE.
//  Do NOT wire ReadingSettingsManager here — none of this is "reading content".
//
//  Localization / RTL: clue text, header title, and solved copy follow the selected commentary
//  language and flip via .environment(\.layoutDirection,…). The grid + keyboard stay LTR (Latin).
//
//  Completion: DailyCrosswordManager.shared.complete(seconds:usedHint:) is called EXACTLY ONCE on
//  the false→true `solved` transition, guarded by `didComplete`.
//

import SwiftUI
import Combine

// MARK: - Main view

struct DailyCrosswordView: View {
    let puzzle: DailyCrossword
    var onCompleted: () -> Void = {}

    @ObservedObject private var manager = DailyCrosswordManager.shared
    @ObservedObject private var languageManager = CommentaryLanguageManager.shared
    @ObservedObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    // MARK: State machine

    @State private var entered: [CellPos: Character] = [:]   // user input
    @State private var selected: CellPos                      // active cell
    @State private var acrossMode = true                      // direction toggle
    @State private var seconds = 0
    @State private var usedHint = false
    @State private var solved = false

    /// One-call guard: ensures `complete(...)` runs exactly once even if the body re-renders.
    @State private var didComplete = false
    /// Drives the animated reveal of the solved overlay (separate from `solved` so we can spring it).
    @State private var showSolved = false

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    private var lang: CommentaryLanguage { languageManager.selectedLanguage }

    // MARK: Init — seed `selected` to the first cell of the first Across entry (fallback: first entry).

    init(puzzle: DailyCrossword, onCompleted: @escaping () -> Void = {}) {
        self.puzzle = puzzle
        self.onCompleted = onCompleted

        let firstAcross = puzzle.entries.first(where: { $0.isAcross }) ?? puzzle.entries.first
        if let e = firstAcross {
            _selected = State(initialValue: e.cell(at: 0))
            _acrossMode = State(initialValue: e.isAcross)
        } else {
            // No entries at all (shouldn't happen for a real puzzle) — park at origin.
            _selected = State(initialValue: CellPos(r: 0, c: 0))
        }
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            background

            if showSolved {
                solvedOverlay
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                playContent
            }
        }
        .animation(.spring(response: 0.40, dampingFraction: 0.82), value: showSolved)
        .onReceive(timer) { _ in
            guard !solved else { return }   // paused once solved
            seconds += 1
        }
    }

    @ViewBuilder
    private var background: some View {
        if themeManager.isMidnightEmerald {
            EmeraldBackground()
        } else {
            themeManager.primaryBackground.ignoresSafeArea()
        }
    }

    // MARK: - Play content

    private var playContent: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 8)

            Spacer(minLength: 8)

            grid
                .padding(.horizontal, 20)

            Spacer(minLength: 14)

            clueBar
                .padding(.horizontal, 20)
                .padding(.bottom, 12)

            keyboard
                .padding(.horizontal, 6)
                .padding(.bottom, 8)
        }
    }

    // MARK: - Header (✕ close · centered title + 🔥streak + mm:ss · hint)

    private var header: some View {
        HStack(alignment: .center, spacing: 10) {
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Close")

            Spacer(minLength: 0)

            VStack(spacing: 3) {
                Text(DailyCrosswordStrings.dailyCrossword(lang))
                    .font(themeManager.isMidnightEmerald
                          ? EmType.serif(20, .semiBold)
                          : .system(size: 18, weight: .bold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

                HStack(spacing: 10) {
                    Text("🔥 \(manager.streak.currentStreak)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(themeManager.accentColor)
                    Text(timeString(seconds))
                        .font(.system(size: 12, weight: .semibold).monospacedDigit())
                        .foregroundColor(themeManager.secondaryText)
                }
            }

            Spacer(minLength: 0)

            Button {
                Haptics.press()
                revealHint()
            } label: {
                VStack(spacing: 3) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text(DailyCrosswordStrings.hint(lang))
                        .font(.system(size: 9, weight: .bold)).tracking(0.5)
                }
                .foregroundColor(themeManager.accentColor)
                .frame(width: 44, height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(themeManager.accentChip)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
            }
            .buttonStyle(EmPressStyle.gentle)
            .accessibilityLabel(DailyCrosswordStrings.hint(lang))
        }
    }

    // MARK: - Grid

    private var grid: some View {
        GeometryReader { geo in
            let spacing: CGFloat = 6
            let totalSpacing = spacing * CGFloat(puzzle.cols - 1)
            let cell = max(0, (geo.size.width - totalSpacing) / CGFloat(puzzle.cols))
            let gridWidth = cell * CGFloat(puzzle.cols) + totalSpacing

            VStack(spacing: spacing) {
                ForEach(0..<puzzle.rows, id: \.self) { r in
                    HStack(spacing: spacing) {
                        ForEach(0..<puzzle.cols, id: \.self) { c in
                            cellView(at: CellPos(r: r, c: c), size: cell)
                        }
                    }
                }
            }
            .frame(width: gridWidth, height: cellGridHeight(cell: cell, spacing: spacing))
            // Center horizontally + vertically within the available box.
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(CGFloat(puzzle.cols) / CGFloat(puzzle.rows), contentMode: .fit)
        // Keep the grid always LTR regardless of language.
        .environment(\.layoutDirection, .leftToRight)
    }

    private func cellGridHeight(cell: CGFloat, spacing: CGFloat) -> CGFloat {
        cell * CGFloat(puzzle.rows) + spacing * CGFloat(puzzle.rows - 1)
    }

    @ViewBuilder
    private func cellView(at p: CellPos, size: CGFloat) -> some View {
        if letterCells.contains(p) {
            let isSelected = (p == selected)
            let isActive = activeCells.contains(p)
            let radius = max(6, size * 0.16)

            ZStack {
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .fill(cellFill(isActive: isActive, isSelected: isSelected))
                    .overlay(
                        RoundedRectangle(cornerRadius: radius, style: .continuous)
                            .stroke(cellBorder(isActive: isActive, isSelected: isSelected),
                                    lineWidth: isSelected ? 2 : 1)
                    )

                // Entry number (top-left, fixed-size chrome)
                if let n = puzzle.number(at: p) {
                    Text("\(n)")
                        .font(.system(size: max(7, size * 0.20), weight: .semibold))
                        .foregroundColor(themeManager.secondaryText)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .padding(.leading, size * 0.10)
                        .padding(.top, size * 0.06)
                        .allowsHitTesting(false)
                }

                // Entered letter (centered serif, fixed-size chrome)
                if let ch = entered[p] {
                    Text(String(ch))
                        .font(EmType.serif(size * 0.52, .semiBold))
                        .foregroundColor(letterColor(isSelected: isSelected, isActive: isActive))
                        .allowsHitTesting(false)
                }
            }
            .frame(width: size, height: size)
            .contentShape(Rectangle())
            .onTapGesture { tapCell(p) }
            .accessibilityElement()
            .accessibilityLabel(cellAccessibilityLabel(p))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        } else {
            // Blank / blocked cell — transparent placeholder that holds the slot.
            Color.clear.frame(width: size, height: size)
        }
    }

    // MARK: - Clue bar (‹ prev · "num Across/Down" + clue + (len) · next ›)

    private var clueBar: some View {
        HStack(spacing: 12) {
            clueNavButton(systemName: "chevron.left",
                          label: DailyCrosswordStrings.prevClue(lang)) {
                step(by: -1)
            }

            VStack(spacing: 4) {
                if let e = activeEntry {
                    Text(clueHeadline(for: e))
                        .font(.system(size: 11, weight: .bold)).tracking(0.8)
                        .foregroundColor(themeManager.accentColor)
                        .frame(maxWidth: .infinity, alignment: .center)

                    Text(e.clue.text(for: lang))
                        .font(themeManager.isMidnightEmerald
                              ? EmType.serif(17, .medium)
                              : .system(size: 15, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                }
            }
            .frame(maxWidth: .infinity)

            clueNavButton(systemName: "chevron.right",
                          label: DailyCrosswordStrings.nextClue(lang)) {
                step(by: 1)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(themeManager.isMidnightEmerald ? themeManager.glassSurface : Color.white.opacity(0.7))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(themeManager.strokeColor, lineWidth: 1)
        )
    }

    private func clueNavButton(systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button {
            Haptics.press()
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 34, height: 34)
                .background(Circle().fill(themeManager.accentChip))
                .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
        }
        .buttonStyle(EmPressStyle.gentle)
        .accessibilityLabel(label)
    }

    /// "<num> <Across|Down> (<len>)" — chrome, always LTR (Latin numerals + direction word).
    private func clueHeadline(for e: CrosswordEntry) -> String {
        let dir = e.isAcross ? DailyCrosswordStrings.across(lang) : DailyCrosswordStrings.down(lang)
        return "\(e.num) \(dir.uppercased()) · (\(e.answer.count))"
    }

    // MARK: - Keyboard (QWERTY + ⌫, dark keys / light letters)

    private static let kbRows = ["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"]

    private var keyboard: some View {
        GeometryReader { geo in
            let hPad: CGFloat = 4
            let keySpacing: CGFloat = 5
            // Size keys off the widest row (10 keys) so all rows align.
            let maxKeys = 10
            let available = geo.size.width - hPad * 2
            let keyW = max(0, (available - keySpacing * CGFloat(maxKeys - 1)) / CGFloat(maxKeys))
            let keyH = min(46, keyW * 1.35)

            VStack(spacing: keySpacing + 1) {
                ForEach(Array(Self.kbRows.enumerated()), id: \.offset) { idx, row in
                    HStack(spacing: keySpacing) {
                        // Last row gets a leading flexible spacer + a trailing ⌫ key.
                        if idx == Self.kbRows.count - 1 { Spacer(minLength: 0) }

                        ForEach(Array(row), id: \.self) { ch in
                            letterKey(ch, width: keyW, height: keyH)
                        }

                        if idx == Self.kbRows.count - 1 {
                            backspaceKey(width: keyW * 1.6, height: keyH)
                            Spacer(minLength: 0)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, hPad)
        }
        .frame(height: 168)
        .environment(\.layoutDirection, .leftToRight)   // keyboard stays LTR
    }

    private func letterKey(_ ch: Character, width: CGFloat, height: CGFloat) -> some View {
        Button {
            typeLetter(ch)
        } label: {
            Text(String(ch))
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(keyTextColor)
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(keyFill)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(themeManager.strokeColor, lineWidth: 0.75)
                )
        }
        .buttonStyle(EmPressStyle.gentle)
    }

    private func backspaceKey(width: CGFloat, height: CGFloat) -> some View {
        Button {
            backspace()
        } label: {
            Image(systemName: "delete.left.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(keyTextColor)
                .frame(width: width, height: height)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(keyFillStrong)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .stroke(themeManager.strokeColor, lineWidth: 0.75)
                )
        }
        .buttonStyle(EmPressStyle.gentle)
        .accessibilityLabel("Delete")
    }

    // MARK: - Solved overlay (mockup right phone)

    private var solvedOverlay: some View {
        VStack(spacing: 26) {
            Spacer()

            // Gold seal + checkmark
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 116, height: 116)
                    .shadow(color: themeManager.accentColor.opacity(0.35), radius: 26, x: 0, y: 10)
                Image(systemName: "checkmark")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(themeManager.onAccentText)
            }

            VStack(spacing: 6) {
                Text(DailyCrosswordStrings.solved(lang))
                    .font(themeManager.isMidnightEmerald
                          ? EmType.serif(40, .semiBold)
                          : .system(size: 34, weight: .bold))
                    .foregroundColor(themeManager.accentBright)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

                Text(puzzleSubtitle)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            // Stat pills: time · 🔥 streak
            HStack(spacing: 10) {
                statPill(systemName: "clock", text: timeString(manager.lastCompletion?.seconds ?? seconds))
                statPill(text: "🔥 \(streakLabel(manager.streak.currentStreak))")
            }
            .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)

            Spacer()

            EmGoldCTA(title: doneLabel, sfSymbol: "checkmark") {
                onCompleted()
                dismiss()
            }
            .padding(.horizontal, 24)

            Text(DailyCrosswordStrings.comeBackTomorrow(lang))
                .font(.system(size: 12.5, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
                .multilineTextAlignment(.center)
                .padding(.bottom, 28)
                .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 20)
    }

    private func statPill(systemName: String? = nil, text: String, filled: Bool = false) -> some View {
        HStack(spacing: 6) {
            if let systemName {
                Image(systemName: systemName)
                    .font(.system(size: 12, weight: .semibold))
            }
            Text(text)
                .font(.system(size: 13, weight: .semibold))
        }
        .foregroundColor(filled ? themeManager.onAccentText : themeManager.secondaryText)
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(
            Capsule().fill(filled ? AnyShapeStyle(themeManager.accentGradient)
                                  : AnyShapeStyle(themeManager.accentChip))
        )
        .overlay(
            Capsule().stroke(filled ? Color.clear : themeManager.strokeColor, lineWidth: 1)
        )
    }

    // MARK: - Derived geometry / entry helpers

    /// Union of every entry's cells — only these render as tiles.
    private var letterCells: Set<CellPos> {
        var s: Set<CellPos> = []
        for e in puzzle.entries {
            for i in 0..<e.answer.count { s.insert(e.cell(at: i)) }
        }
        return s
    }

    private var solution: [CellPos: Character] { puzzle.solution }

    /// All entries ordered: all Across by num, then all Down by num.
    private var orderedEntries: [CrosswordEntry] {
        let across = puzzle.entries.filter { $0.isAcross }.sorted { $0.num < $1.num }
        let down   = puzzle.entries.filter { !$0.isAcross }.sorted { $0.num < $1.num }
        return across + down
    }

    /// Entries (either direction) that contain `selected`.
    private func entries(containing p: CellPos) -> [CrosswordEntry] {
        puzzle.entries.filter { e in (0..<e.answer.count).contains { e.cell(at: $0) == p } }
    }

    /// The active entry: the one matching the current direction that contains `selected`;
    /// if none in that direction, the one in the other direction that contains it.
    private var activeEntry: CrosswordEntry? {
        let wantAcross = acrossMode
        let here = entries(containing: selected)
        if let match = here.first(where: { $0.isAcross == wantAcross }) { return match }
        return here.first
    }

    /// Cells of the active entry (highlighted gold).
    private var activeCells: Set<CellPos> {
        guard let e = activeEntry else { return [] }
        return Set((0..<e.answer.count).map { e.cell(at: $0) })
    }

    // MARK: - Interactions

    private func tapCell(_ p: CellPos) {
        let here = entries(containing: p)
        guard !here.isEmpty else { return }

        if p == selected, here.count > 1 {
            // Cell belongs to entries in BOTH directions → toggle direction.
            acrossMode.toggle()
        } else {
            selected = p
            // Keep current direction if an entry exists there, else switch to the available one.
            if !here.contains(where: { $0.isAcross == acrossMode }), let only = here.first {
                acrossMode = only.isAcross
            }
        }
    }

    private func typeLetter(_ ch: Character) {
        guard let e = activeEntry else { return }
        Haptics.press()
        entered[selected] = ch

        // Advance to the next cell of the active entry (stop at its end).
        let cells = (0..<e.answer.count).map { e.cell(at: $0) }
        if let idx = cells.firstIndex(of: selected), idx + 1 < cells.count {
            selected = cells[idx + 1]
        }

        checkSolved()
    }

    private func backspace() {
        Haptics.press()
        guard let e = activeEntry else {
            entered[selected] = nil
            return
        }
        let cells = (0..<e.answer.count).map { e.cell(at: $0) }

        if entered[selected] == nil {
            // Current cell empty → step back to the previous cell and clear it.
            if let idx = cells.firstIndex(of: selected), idx > 0 {
                let prev = cells[idx - 1]
                selected = prev
                entered[prev] = nil
            }
        } else {
            // Clear the current cell (stay put).
            entered[selected] = nil
        }
    }

    private func revealHint() {
        guard let sol = solution[selected] else { return }
        entered[selected] = sol
        usedHint = true
        checkSolved()
    }

    /// Move to the prev/next entry in `orderedEntries`, select its first empty cell (or first cell).
    private func step(by delta: Int) {
        let order = orderedEntries
        guard !order.isEmpty else { return }

        // Find the index of the current active entry; fall back to 0.
        let currentIndex = activeEntry.flatMap { e in order.firstIndex(where: { $0.id == e.id }) } ?? 0
        let nextIndex = ((currentIndex + delta) % order.count + order.count) % order.count
        let next = order[nextIndex]

        acrossMode = next.isAcross
        let cells = (0..<next.answer.count).map { next.cell(at: $0) }
        selected = cells.first(where: { entered[$0] == nil }) ?? cells.first ?? selected
    }

    /// After every input: recompute `solved`. On the false→true transition, complete exactly once.
    private func checkSolved() {
        let nowSolved = letterCells.allSatisfy { entered[$0] == solution[$0] }
        guard nowSolved, !solved else {
            solved = nowSolved
            return
        }

        // false → true transition.
        solved = true
        if !didComplete {
            didComplete = true
            manager.complete(seconds: seconds, usedHint: usedHint)
        }
        // Reveal the overlay (animated by the .animation modifier on `showSolved`).
        withAnimation(.spring(response: 0.40, dampingFraction: 0.82)) {
            showSolved = true
        }
    }

    // MARK: - Color helpers

    private func cellFill(isActive: Bool, isSelected: Bool) -> Color {
        if isSelected { return themeManager.accentColor.opacity(0.30) }
        if isActive   { return themeManager.accentColor.opacity(0.16) }
        return themeManager.isMidnightEmerald ? Color.white.opacity(0.05) : Color.white.opacity(0.85)
    }

    private func cellBorder(isActive: Bool, isSelected: Bool) -> Color {
        if isSelected { return themeManager.accentBright }
        if isActive   { return themeManager.accentColor.opacity(0.55) }
        return themeManager.strokeColor
    }

    private func letterColor(isSelected: Bool, isActive: Bool) -> Color {
        (isSelected || isActive) ? themeManager.accentBright : themeManager.primaryText
    }

    private var keyTextColor: Color {
        themeManager.isMidnightEmerald ? Color.white.opacity(0.92) : themeManager.primaryText
    }

    private var keyFill: Color {
        themeManager.isMidnightEmerald ? Color.white.opacity(0.08) : Color.white.opacity(0.9)
    }

    private var keyFillStrong: Color {
        themeManager.isMidnightEmerald ? Color.white.opacity(0.13) : Color.white.opacity(0.7)
    }

    // MARK: - Misc helpers

    private func timeString(_ s: Int) -> String {
        String(format: "%02d:%02d", s / 60, s % 60)
    }

    /// e.g. "5×5 · 6 words" — a quiet subtitle under "Solved!".
    private var puzzleSubtitle: String {
        "\(puzzle.cols)×\(puzzle.rows) · \(puzzle.entries.count) \(wordsLabel)"
    }

    // MARK: - Local overlay strings
    //
    // Kept inline (this is the single new file). The shared DailyCrosswordStrings covers the
    // play-screen vocabulary the brief lists; these few overlay-only labels live here so we
    // don't have to touch a second file.

    private var doneLabel: String {
        switch lang {
        case .arabic: return "تم"
        case .urdu:   return "مکمل"
        default:      return "Done"
        }
    }

    private var wordsLabel: String {
        switch lang {
        case .arabic: return "كلمات"
        case .urdu:   return "الفاظ"
        default:      return "words"
        }
    }

    /// "<n>-day streak" — chrome label for the streak pill.
    private func streakLabel(_ n: Int) -> String {
        switch lang {
        case .arabic: return "\(n) أيام متتالية"
        case .urdu:   return "\(n) دن کا سلسلہ"
        default:      return "\(n)-day streak"
        }
    }

    private func cellAccessibilityLabel(_ p: CellPos) -> String {
        var parts: [String] = []
        if let n = puzzle.number(at: p) { parts.append("\(n)") }
        if let ch = entered[p] { parts.append(String(ch)) } else { parts.append("empty") }
        return parts.joined(separator: ", ")
    }
}

// MARK: - Preview

#if DEBUG
#Preview("Crossword — Emerald, English") {
    let _ = (ThemeManager.shared.selectedTheme = .nightSanctuary)
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    DailyCrosswordView(puzzle: DailyCrosswordProvider.shared.today)
}

#Preview("Crossword — Emerald, Urdu RTL") {
    let _ = (ThemeManager.shared.selectedTheme = .nightSanctuary)
    let _ = CommentaryLanguageManager.shared.setLanguage(.urdu)
    DailyCrosswordView(puzzle: DailyCrosswordProvider.shared.today)
}

#Preview("Crossword — Light, English") {
    let _ = (ThemeManager.shared.selectedTheme = .warmInviting)
    let _ = CommentaryLanguageManager.shared.setLanguage(.english)
    DailyCrosswordView(puzzle: DailyCrosswordProvider.shared.today)
}
#endif
