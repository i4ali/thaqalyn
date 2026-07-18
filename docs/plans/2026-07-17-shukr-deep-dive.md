# Shukr Deep Dive Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans (or subagent-driven execution in-session) to implement this plan task-by-task.
>
> **House rules for this repo (override the generic skill defaults):**
> - **No XCTest.** This project ships iOS work without automated tests. The gate for every task is a green `xcodebuild` build (command in Task 6), not a test suite. Do not create a test target.
> - **No commits.** The user commits themselves. Skip every "commit" step.
> - **Max two subagents at a time** if executing with subagents; **skip the code-quality reviewer stage** (keep build + behavior-guardrail checks).
> - SourceKit "cannot find type in scope" on new/edited files is a stale-index false positive - trust `xcodebuild` only.

**Goal:** Ship the fourth Deep Dive - "Shukr - The Thanks That Returns" - per the approved design in `docs/plans/2026-07-17-shukr-deep-dive-design.md` (visual mock: `docs/mockups/shukr_mock.png`).

**Architecture:** One new engine beat (`count`) added to the data model + renderer, one new pure-content file (`ShukrDeepDive.swift`), a catalog flip, and a What's New entry. Mirrors exactly how the Tawakkul dive added its `release` beat (see `docs/plans/2026-07-16-tawakkul-deep-dive-design.md`).

**Tech Stack:** SwiftUI, Xcode 16 synced folder groups (new files need NO pbxproj edit - just create the file in the folder).

**The design doc (`2026-07-17-shukr-deep-dive-design.md`) is the content source of truth.** All 16 beats' copy lives there in section 4; transcribe it verbatim - do not rewrite prose. Plain-dash " - " everywhere, never an em dash. Curly quotes in quoted speech.

---

### Task 1: Add the `count` case to the section model

**Files:**
- Modify: `Thaqalayn/Models/DeepDive.swift`

**Step 1: Add the case.** In `enum DeepDiveSection`, directly after the existing `case release(...)` (around line 86), add:

```swift
    /// The interactive close of a dive built on gratitude (Shukr): the reader taps to
    /// count blessings - each tap births a point of light - until the lights begin
    /// multiplying on their own, outrunning the finger, and the screen resolves into
    /// the verse: the count cannot be finished. Replaces `reflectionPrompt` for such dives.
    case count(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText, arabic: String, translation: LocalizedText, reference: String, note: LocalizedText, nextLabel: LocalizedText)
```

**Step 2: Extend the act mapping.** In the same enum's `var act: Int`, change the final grouped case from:

```swift
        case .reflectionPrompt, .release, .dua, .closing:  return 4
```

to:

```swift
        case .reflectionPrompt, .release, .count, .dua, .closing:  return 4
```

**Step 3: Build gate.** Not yet - `DeepDiveView`'s `content(_:_:)` switch is exhaustive over `DeepDiveSection`, so the project will NOT compile until Task 2 adds the renderer case. Proceed straight to Task 2 and build after it.

---

### Task 2: Render the `count` beat in DeepDiveView

**Files:**
- Modify: `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

Model everything on the existing `release` implementation (state block ~line 74-81, `placeInfo` ~line 359, dispatch ~line 450, `releasePage` ~line 807, reset in `aminBlock` ~line 966). Reuse the same building blocks: `DeepDivePalette.gold/.goldBright/.cream/.mute`, `EmType.serif/.serifItalic/.arabic`, `reveal(show, delay, reduce:)`, `bob(...)`, `hairline`, the reading-scale factor `s`, and `reduceMotion`.

**Step 1: State.** Below the release state block (after `releaseHoldDuration`, ~line 81), add:

```swift
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
```

**Step 2: placeInfo.** In `placeInfo(_:)`, after the `.release` line, add:

```swift
        case .count(let tag, _, _, _, _, _, _, _): return (tag(lang), dive.acts.count)
```

**Step 3: Dispatch.** In `content(_:_:)`, after the `.release` case, add:

```swift
        case let .count(_, prompt, subline, arabic, translation, reference, note, nextLabel):
            countPage(prompt(lang), subline(lang), arabic, translation(lang), reference, note(lang), nextLabel(lang), show)
```

**Step 4: The renderer.** Add a new `// MARK: The count (Shukr)` section directly after the release section (after `releaseGesture`, ~line 906):

```swift
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
```

**Step 5: Reset in "Begin again".** In `aminBlock`'s reset closure (~line 966, where the release state is cleared), extend the first `withAnimation` block:

```swift
                    withAnimation {
                        saidAmin = false; openDepths = [0]
                        releaseHolding = false; releasePrimed = false
                        releaseDone = false; releaseHoldStart = nil
                        countTimer?.invalidate(); countTimer = nil
                        countTaps = 0; countTally = 0
                        countOverflow = false; countDone = false; countLights = []
                    }
```

**Step 6: Build gate.** Run the build (Task 6 command). Expected: BUILD SUCCEEDED. Tasks 1+2 must build green before Task 3 starts.

---

### Task 3: Create the content file `ShukrDeepDive.swift`

**Files:**
- Create: `Thaqalayn/Content/ShukrDeepDive.swift` (synced folder - just create the file, no pbxproj edit)

Transcribe ALL 16 beats verbatim from design-doc section 4. EN-first string literals (the `ExpressibleByStringLiteral` conformance makes plain strings work), exactly like `TawakkulDeepDive.swift`. Complete file:

```swift
//
//  ShukrDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Shukr" deep dive - a descent through the three tongues
//  of thanks (al-Qalb / al-Lisan / al-Jawarih). Rendered by DeepDiveView; see
//  docs/plans/2026-07-17-shukr-deep-dive-design.md.
//

import SwiftUI

extension DeepDive {
    static let shukr: DeepDive = DeepDive(
        id: "shukr",
        titleEn: "Shukr",
        titleAr: "شُكْر",
        subtitle: "Gratitude - a descent through three tongues",
        sfSymbol: "hands.clap",
        estMinutes: 5,
        acts: [
            ActInfo(number: 1, ar: "القَلْب", tr: "al-Qalb", name: "The Recognizing"),
            ActInfo(number: 2, ar: "اللِّسَان", tr: "al-Lisan", name: "The Saying"),
            ActInfo(number: 3, ar: "الجَوَارِح", tr: "al-Jawarih", name: "The Doing"),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: "A DEEP DIVE",
                titleAr: "شُكْر",
                titleEn: "Shukr",
                subtitle: "Gratitude",
                line: "A descent through the Qur'an and the Ahl al-Bayt - what the heart must see, what the tongue must say, what the body must answer."
            ),

            // 02. Before you descend
            .orientation(
                eyebrow: "Before you descend",
                promise: "Three tongues of thanks lie below - the heart that recognizes, the tongue that praises, and the limbs that answer.",
                leaveWith: "You'll leave with a map of gratitude - and a prayer for the thanks that can never be finished."
            ),

            // 03. Threshold - The Three Tongues
            .depths(
                act: 0,
                tag: "The Three Tongues",
                reference: "al-Kafi · Saba 34:13",
                items: [
                    Depth(
                        ar: "القَلْب",
                        tr: "al-Qalb",
                        label: "The Recognizing",
                        desc: "To see the gift as gift - and the Giver behind it. Thanks begins before a word is said.",
                        reference: nil,
                        embodies: "the heart that sees the Giver"
                    ),
                    Depth(
                        ar: "اللِّسَان",
                        tr: "al-Lisan",
                        label: "The Saying",
                        desc: "To speak the praise aloud - and tell of the blessing.",
                        reference: "93:11",
                        embodies: "the tongue that praises"
                    ),
                    Depth(
                        ar: "الجَوَارِح",
                        tr: "al-Jawarih",
                        label: "The Doing",
                        desc: "To answer the gift with the body - to stand, to serve, to give.",
                        reference: "34:13",
                        embodies: "the family who answered with everything"
                    ),
                ]
            ),

            // 04. Movement I - The Recognizing
            .act(
                act: 1,
                connector: nil,
                line: "It begins behind the ribs. Before gratitude has words, it is a kind of seeing - the gift caught in the act of arriving, and the Giver's hand still on it.",
                bridge: nil
            ),

            // 05. Movement I - The First Gifts (al-Nahl 16:78)
            .verse(
                act: 1,
                tag: "The First Gifts",
                surah: 16,
                ayah: 78,
                arabic: "وَاللَّهُ أَخْرَجَكُم مِّن بُطُونِ أُمَّهَاتِكُمْ لَا تَعْلَمُونَ شَيْئًا وَجَعَلَ لَكُمُ السَّمْعَ وَالْأَبْصَارَ وَالْأَفْئِدَةَ لَعَلَّكُمْ تَشْكُرُونَ",
                translation: "And God brought you out of your mothers' wombs knowing nothing - and He made for you hearing, and sight, and hearts, that you might give thanks.",
                reference: "al-Nahl · 16 : 78",
                reflection: "You arrived owning nothing - not even the knowing. Hearing, sight, a heart: the verse lists the first gifts, then names what they were for. Gratitude is not an ornament on the equipment. It is what the equipment was issued for."
            ),

            // 06. Movement I - The Thanks of the Heart (al-Kafi)
            .narration(
                act: 1,
                tag: "The Thanks of the Heart",
                source: "Imam Ja'far al-Sadiq · al-Kafi, the book of thanks",
                body: "Whomever God grants a blessing, said the Imam, and he recognizes it with his heart - he has already rendered its thanks.",
                reflection: "Before a word is spoken, the thanks has either happened or it hasn't - in the heart, where the gift is seen and the Giver named. Everything the tongue says afterward is overflow."
            ),

            // 07. Movement II - The Saying
            .act(
                act: 2,
                connector: "You have seen the Giver.",
                line: "Now - say it. What the heart knows in silence, the tongue brings into the open: the blessing told, the Giver named aloud.",
                bridge: nil
            ),

            // 08. Movement II - The Covenant of Increase (Ibrahim 14:7)
            .verse(
                act: 2,
                tag: "The Covenant of Increase",
                surah: 14,
                ayah: 7,
                arabic: "وَإِذْ تَأَذَّنَ رَبُّكُمْ لَئِن شَكَرْتُمْ لَأَزِيدَنَّكُمْ",
                translation: "And when your Lord proclaimed: If you give thanks, I will surely increase you.",
                reference: "Ibrahim · 14 : 7",
                reflection: "Proclaimed - not whispered. Thanks is the one debt that grows by being paid: thank Him, and He gives you more to thank for. And the increase is not always more of the gift. Sometimes it is more of the seeing."
            ),

            // 09. Movement II - Tell of It (al-Duha 93:11)
            .verse(
                act: 2,
                tag: "Tell of It",
                surah: 93,
                ayah: 11,
                arabic: "وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ",
                translation: "And as for the blessing of your Lord - tell of it.",
                reference: "al-Duha · 93 : 11",
                reflection: "Five words, spoken first to an orphan who had just been given everything. Gratitude has a voice - not the boast that forgets the Giver, but the telling that names Him: this came from my Lord."
            ),

            // 10. Movement II - He Answers (Musa, al-Kafi)
            .response(
                act: 2,
                replyingTo: "To Musa, who asked: how shall I thank You, when every thanks I thank You with is itself Your gift?",
                arabic: "الْآنَ شَكَرْتَنِي حِينَ عَلِمْتَ أَنَّ ذَلِكَ مِنِّي",
                words: "Now you have thanked Me - now that you know that even the thanks is from Me.",
                source: "His words to Musa · al-Kafi",
                reflection: "The ladder of thanks has no top rung - every thanks is another gift, owing another thanks. He does not ask you to reach the top. He asks you to know where the ladder stands."
            ),

            // 11. Movement III - The Doing + bridge 34:13
            .act(
                act: 3,
                connector: "You have said it.",
                line: "Now - past the saying. The command to the most gifted house on earth was not say thanks but work it. In the end, thanks is something the body does.",
                bridge: BridgeVerse(
                    surah: 34,
                    ayah: 13,
                    arabic: "اعْمَلُوا آلَ دَاوُودَ شُكْرًا وَقَلِيلٌ مِّنْ عِبَادِيَ الشَّكُورُ",
                    translation: "Work, O family of Dawud, in thanks - and few of My servants are deeply grateful.",
                    reference: "Saba · 34 : 13"
                )
            ),

            // 12. Movement III - The Grateful Servant (al-Kafi)
            .narration(
                act: 3,
                tag: "The Grateful Servant",
                source: "The Messenger of God ﷺ · narrated of Imam al-Baqir, al-Kafi",
                body: "He stood in the night until his feet swelled. But you are already forgiven, he was asked - everything before, everything after. Why this? He said: “Shall I not be a grateful servant?”",
                reflection: "Forgiveness did not retire his worship - it changed what the worship was. No longer a plea; a thank-you. The most truthful tongue on earth was not enough for him. He thanked with his feet."
            ),

            // 13. Movement III - The Thanks That Returns (al-Insan 76:22)
            .verse(
                act: 3,
                tag: "The Thanks That Returns",
                surah: 76,
                ayah: 22,
                arabic: "إِنَّ هَٰذَا كَانَ لَكُمْ جَزَاءً وَكَانَ سَعْيُكُم مَّشْكُورًا",
                translation: "Indeed this is a reward for you - and your striving has been thanked.",
                reference: "al-Insan · 76 : 22",
                reflection: "Spoken in the surah this house was given - to the family who fed the hungry three nights and asked nothing back. Read it slowly: God, who needs nothing, thanks. The thanks you send up does not vanish. It returns."
            ),

            // 14. Movement III - The Praise in the Dark (eve of Ashura)
            .climax(
                act: 3,
                tag: "The Praise in the Dark",
                source: "Imam al-Husayn, the eve of Ashura - al-Irshad of al-Mufid",
                arabic: "أُثْنِي عَلَى اللَّهِ أَحْسَنَ الثَّنَاءِ، وَأَحْمَدُهُ عَلَى السَّرَّاءِ وَالضَّرَّاءِ",
                translation: "“I praise God with the best of praise, and I thank Him in ease and in hardship.”",
                body: "The army is across the plain and the morning is known. He gathers his family and companions at nightfall - and opens with praise: for prophethood, for the Qur'an. For hearing, and sight, and hearts.",
                reflection: "Hearing, sight, hearts - the first gifts, the ones this descent began with - named in thanks on the last night they would be his. Anyone can thank for the gift. He thanked the Giver while the gifts were being taken."
            ),

            // 15. The Count (new interactive beat)
            .count(
                tag: "The Count",
                prompt: "Count what He has given you.",
                subline: "Begin anywhere - this breath, your sight, a person who loves you. Tap: one blessing at a time.",
                arabic: "وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا",
                translation: "And if you count the blessings of God, you cannot number them.",
                reference: "al-Nahl · 16 : 18",
                note: "The count was never going to finish. It was only ever going to point - at the One whose giving outruns it.",
                nextLabel: "And one prayer"
            ),

            // 16. The Close - a prayer of the unfinished thanks (Sahifa 37)
            .dua(
                tag: "A Prayer of the Unfinished Thanks",
                intro: "After the heart, the tongue, the limbs - after Karbala - one prayer, in the voice of the fourth Imam: the confession that no thanks arrives at the end.",
                arabic: "اللَّهُمَّ إِنَّ أَحَدًا لَا يَبْلُغُ مِنْ شُكْرِكَ غَايَةً إِلَّا حَصَلَ عَلَيْهِ مِنْ إِحْسَانِكَ مَا يُلْزِمُهُ شُكْرًا",
                translation: "“O God, no one ever reaches an end in thanking You without there settling upon him, from Your goodness, that which binds him to a further thanks.”",
                source: "Imam Ali ibn al-Husayn · al-Sahifa al-Sajjadiyya, Dua 37",
                note: "The full count is not asked of you tonight. Only this: one blessing seen, one alhamdulillah said aloud - and the rest left to the One who accepts the little and gives the much.",
                close: "The thanks is yours to keep."
            ),
        ]
    )
}
```

**Notes for the implementer:**
- The Arabic in `arabic:` fields is plain (non-Uthmani) orthography ON PURPOSE - it will not byte-match `quran_data.json` and there is no byte-check for theme dives (that check is only for Inside-the-Surah files). Do not "fix" it to Uthmani.
- `surah:`/`ayah:` anchor the recitation player to the real full verse - 14:7 and 34:13 display excerpts but recite in full. This matches the Sabr 12:86 precedent.
- Curly quotes appear ONLY inside quoted speech (beats 12, 14, 16) - exactly as typed above.

**Step 2: Build gate.** Run the build. Expected: BUILD SUCCEEDED.

---

### Task 4: Flip the catalog entry

**Files:**
- Modify: `Thaqalayn/Services/DeepDiveCatalog.swift` (~lines 68-78, the `shukr` descriptor)

Replace the `shukr` entry's `subtitle`, `available`, and `dive` values so the entry reads:

```swift
        DeepDiveDescriptor(
            id: "shukr",
            title: LocalizedText(en: "Shukr · Gratitude", ur: "شکر", ar: "الشكر"),
            titleAr: "شُكْر",
            sfSymbol: "hands.clap",
            subtitle: LocalizedText(en: "A descent through three tongues - Qur'an to Karbala",
                                    ur: "تین زبانوں میں اترتا ایک سفر - قرآن سے کربلا تک",
                                    ar: "نزولٌ عبر ثلاثة ألسنة - من القرآن إلى كربلاء"),
            available: true, dive: .shukr,
            coverAssetName: "ShukrCover"
        ),
```

(`title`, `titleAr`, `sfSymbol`, `coverAssetName` are unchanged - only `subtitle`, `available`, `dive` change.)

---

### Task 5: What's New entry

**Files:**
- Modify: `Thaqalayn/Models/WhatsNewItem.swift`

Add to `WhatsNewCatalog.all`, following the `deepDives-tawakkul` entry's shape (~line 57). Insert as the newest entry (wherever the newest sits - match the file's existing ordering convention):

```swift
        WhatsNewItem(
            id: "deepDives-shukr",
            sfSymbol: "hands.clap",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 4).date ?? .distantPast,
            destination: .deepDive("shukr"),
            titleEN: "New Deep Dive",
            titleUR: "نیا گہرا غوطہ",
            titleAR: "غوصٌ عميقٌ جديد",
            blurbEN: "Shukr - Gratitude. A descent through the three tongues of thanks, from the first gifts to the praise in the dark of Ashura eve - ending with a count you will lose on purpose.",
            blurbUR: "شکر - شکرگزاری۔ شکر کی تین زبانوں میں اترتا ہوا ایک عمیق سفر، پہلی نعمتوں سے شبِ عاشورا کی حمد تک - جس کا اختتام ایک ایسی گنتی پر ہوتا ہے جو آپ جان بوجھ کر ہار جاتے ہیں۔",
            blurbAR: "الشكر - نزولٌ عبر ألسنة الشكر الثلاثة، من أولى العطايا إلى الثناء في ظلمة ليلة عاشوراء - يُختَم بعدٍّ تخسره عن قصد.",
            ctaEN: "Begin the descent",
            ctaUR: "نزول کا آغاز کریں",
            ctaAR: "ابدأ النزول"
        ),
```

`releaseDate` 2026-08-04 sorts it after the Tawakkul entry (2026-08-03); the user may adjust to the actual release date at ship time. `.deepDive` destination already exists (Tawakkul uses it) - no new `WhatsNewDestination` case and no `WhatsNewCard.open()` change needed.

---

### Task 6: Final build + handoff

**Step 1: Full build.** From the repo root (`/Users/muhammadimranali/Documents/development/thaqalyn`):

```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -n 4
```

Expected: `BUILD SUCCEEDED`. If `name=` is ambiguous, fall back to `id=<UDID>` from `xcrun simctl list devices booted`.

**Step 2: Behavior guardrails (read-only checks, no simctl).** Verify by inspection:
- `content(_:_:)` switch compiles exhaustively (no `default` added - a new beat must fail loudly if unhandled).
- No em dash anywhere in the new/edited files: `grep -n "—" Thaqalayn/Content/ShukrDeepDive.swift Thaqalayn/Models/DeepDive.swift Thaqalayn/Views/DeepDive/DeepDiveView.swift Thaqalayn/Services/DeepDiveCatalog.swift Thaqalayn/Models/WhatsNewItem.swift` returns nothing (the view file already had none).
- No transliteration diacritics in the English strings: `python3 scripts/strip_diacritics.py --report Thaqalayn/Content/ShukrDeepDive.swift` reports no changes.
- The count beat's fixed renderer strings are "Tap - each tap, one blessing" / "They outrun the count" / "And counting itself" (uppercased at the call site).
- Premium gating needs NO new code (engine-level, keyed off the catalog) - confirm no `lock.fill` was introduced anywhere.

**Step 3: Stop.** Do NOT run the simulator, install, or screenshot - the user tests the simulator themselves. Do NOT commit - the user commits. Report the build result and the file list.

---

## Task order & dependencies

1. Tasks 1+2 are one atomic unit (the project doesn't compile between them) - same worker, build gate after Task 2.
2. Task 3 depends on Tasks 1+2 (uses `.count`). Build gate after.
3. Tasks 4+5 are independent of each other, depend on Task 3 (`.shukr` must exist). May run as one wave of two.
4. Task 6 last.
