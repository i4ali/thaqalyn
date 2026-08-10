# Ikhlas Deep Dive - Implementation Plan

**Date:** 2026-08-05
**Design source of truth:** `docs/plans/2026-07-29-ikhlas-deep-dive-design.md` (Status: APPROVED 2026-08-05, Gate 2 verdict "build it"; subtitle "Qur'an to the house of Fatima" kept; Last Light prompt kept; no copy edits).
**Mock:** `docs/mockups/ikhlas_mock.html` + `.png`.

This plan carries the **complete code** for all three waves. Content strings are transcribed
**verbatim** from design doc section 4 - do not rewrite. Execute in order; each wave ends in a
build gate (`xcodebuild ... | tail -n 4`). Then Stage 4 (own build + guardrail greps) and Stage 5
(four-auditor audit). Never commit - the user commits.

Reference implementation for every pattern: the **Shukr** dive (`count` beat is `extinguish`'s
conceptual inverse). Exhaustive switches over `DeepDiveSection` (all three must gain the new case
in Wave 1, or nothing compiles): `DeepDive.swift` `act` (~L114), `DeepDiveView.swift` `placeInfo`
(~L397) and `content` (~L470).

---

## Wave 1 - Engine: the `extinguish` beat (ATOMIC: both files together)

`DeepDive.swift` (the enum case + act mapping) and `DeepDiveView.swift` (state, struct, two switch
cases, renderer block, Begin-again reset) are one compile unit - the exhaustive switch will not build
between them.

### 1a. `Thaqalayn/Models/DeepDive.swift`

**Insert the new case** immediately after the `sujud` case (ends `...nextLabel: LocalizedText)`,
just before the `/// \`close\` is the theme-specific...` doc comment for `dua`:

```swift
    /// The interactive close of a dive built on sincerity (Ikhlas): a fixed scatter of
    /// small lights - the audiences the reader has performed for. Tapping a light puts it
    /// out; the last light cannot be put out - tapping it only makes it flare - and the
    /// screen resolves into the verse: everything perishes except His Face. The gesture is
    /// subtraction to the one unremovable Watcher, the meaning-inverse of `count`. Replaces
    /// `reflectionPrompt` for such dives.
    case extinguish(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
                    arabic: String, translation: LocalizedText, reference: String,
                    note: LocalizedText, nextLabel: LocalizedText)
```

**Update the `act` computed property** - add `.extinguish` to the act-4 group:

```swift
        case .reflectionPrompt, .release, .count, .sujud, .extinguish, .dua, .closing: return 4
```

### 1b. `Thaqalayn/Views/DeepDive/DeepDiveView.swift`

**(i) State block** - insert after the sujud state machine block (after
`private let sujudStayDuration: TimeInterval = 2.0`), before `private var s: CGFloat`:

```swift
    /// The `extinguish` beat's state machine (Ikhlas). A fixed scatter of audience-lights;
    /// each tap puts one out (soft haptic), dimming it to a faint outline. The last light
    /// will not go out - tapping it flares it (light haptic) and the label turns; the verse
    /// then resolves. Subtraction to the one unremovable Watcher - the inverse of `count`.
    @State private var extinguishedLights: Set<Int> = []
    @State private var extinguishFlared = false      // the last light has been tapped and flared
    @State private var extinguishDone = false
    @State private var extinguishTimer: Timer? = nil

    /// One audience-light in the extinguish field, at a fixed position in unit space
    /// (stable across taps, unlike the count field's random births).
    private struct ExtinguishLight: Identifiable {
        let id: Int
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
    }
    /// The fixed scatter of eight audience-lights - each an eye the deed was performed for.
    private let extinguishLights: [ExtinguishLight] = [
        ExtinguishLight(id: 0, x: 0.16, y: 0.30, size: 6),
        ExtinguishLight(id: 1, x: 0.50, y: 0.15, size: 5),
        ExtinguishLight(id: 2, x: 0.84, y: 0.26, size: 6.5),
        ExtinguishLight(id: 3, x: 0.29, y: 0.63, size: 5.5),
        ExtinguishLight(id: 4, x: 0.68, y: 0.54, size: 6),
        ExtinguishLight(id: 5, x: 0.13, y: 0.82, size: 5),
        ExtinguishLight(id: 6, x: 0.52, y: 0.85, size: 6.5),
        ExtinguishLight(id: 7, x: 0.88, y: 0.74, size: 5.5),
    ]
```

**(ii) `placeInfo` case** - insert after the `.sujud` line (before `case .dua:`):

```swift
        case .extinguish(let tag, _, _, _, _, _, _, _): return (tag(lang), dive.acts.count)
```

**(iii) `content` switch case** - insert after the `.sujud` case (before `case let .dua`):

```swift
        case let .extinguish(_, prompt, subline, arabic, translation, reference, note, nextLabel):
            extinguishPage(prompt(lang), subline(lang), arabic, translation(lang), reference, note(lang), nextLabel(lang), show)
```

**(iv) Renderer block** - insert immediately before `private func duaPage(` (anchor: the
`duaPage` signature line). Three funcs + one computed property:

```swift
    // MARK: The extinguish (Ikhlas)

    /// The interactive extinguishing. Idle: the prompt and a fixed scatter of audience-
    /// lights. Each tap puts one out - soft haptic, the light dimming to a faint outline -
    /// and the prompt fades as the field empties. When one light remains it stands subtly
    /// larger; tapping it does not put it out - it flares (light haptic), the label turns to
    /// "This one does not go out", and the verse takes over: everything perishes except His
    /// Face. Subtraction to the one unremovable Watcher - the meaning-inverse of `count`.
    private func extinguishPage(_ prompt: String, _ subline: String, _ arabic: String, _ translation: String, _ reference: String, _ note: String, _ nextLabel: String, _ show: Bool) -> some View {
        let remaining = extinguishLights.count - extinguishedLights.count
        let promptOpacity: Double = extinguishFlared ? 0.35
            : 1.0 - 0.5 * (1.0 - Double(remaining) / Double(extinguishLights.count))
        return VStack(spacing: 0) {
            if extinguishDone {
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
                    .opacity(extinguishFlared ? 0.35 : 1)
                    .reveal(show, reduce: reduceMotion)
                Text(prompt).font(EmType.serif(34)).foregroundColor(DeepDivePalette.cream)
                    .multilineTextAlignment(.center).padding(.top, 20)
                    .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                    .opacity(promptOpacity)
                    .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: extinguishedLights)
                    .reveal(show, 0.15, reduce: reduceMotion)
                if extinguishedLights.isEmpty {
                    Text(subline).font(EmType.serifItalic(16 * s)).foregroundColor(Color(white: 0.72))
                        .multilineTextAlignment(.center).lineSpacing(3 * s).padding(.top, 14).frame(maxWidth: 320)
                        .environment(\.layoutDirection, lang.isRTL ? .rightToLeft : .leftToRight)
                        .reveal(show, 0.3, reduce: reduceMotion)
                }
                extinguishField
                    .padding(.top, extinguishedLights.isEmpty ? 34 : 14)
                    .reveal(show, 0.5, reduce: reduceMotion)
                Text((extinguishFlared ? "This one does not go out" : "Tap each light - put it out").uppercased())
                    .font(.system(size: extinguishFlared ? 12 : 10.5, weight: .semibold))
                    .tracking(extinguishFlared ? 4 : 3)
                    .foregroundColor(extinguishFlared ? DeepDivePalette.goldBright : DeepDivePalette.gold)
                    .shadow(color: extinguishFlared ? DeepDivePalette.goldBright.opacity(0.4) : .clear, radius: 12)
                    .padding(.top, 18)
                    .reveal(show, 0.6, reduce: reduceMotion)
            }
        }
        .background {
            if extinguishDone {
                RadialGradient(colors: [DeepDivePalette.goldBright.opacity(0.10), .clear],
                               center: .center, startRadius: 10, endRadius: 280)
                    .allowsHitTesting(false)
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.45), value: extinguishFlared)
        .onDisappear { extinguishTimer?.invalidate(); extinguishTimer = nil }
    }

    /// The fixed field of audience-lights. Tapping one puts it out; extinguished lights
    /// remain as faint outlines and stop taking taps. The last light standing is drawn
    /// larger, and tapping it flares rather than extinguishes.
    private var extinguishField: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(extinguishLights) { light in
                    extinguishDot(light)
                        .position(x: light.x * geo.size.width, y: light.y * geo.size.height)
                }
            }
        }
        .frame(maxWidth: 300)
        .frame(height: 190)
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.4), value: extinguishedLights)
        .animation(reduceMotion ? nil : .easeOut(duration: 0.5), value: extinguishFlared)
    }

    @ViewBuilder
    private func extinguishDot(_ light: ExtinguishLight) -> some View {
        let isOut = extinguishedLights.contains(light.id)
        let isLast = !isOut && (extinguishLights.count - extinguishedLights.count) == 1
        let flared = isLast && extinguishFlared
        ZStack {
            if isOut {
                Circle().stroke(DeepDivePalette.gold.opacity(0.16), lineWidth: 1)
                    .frame(width: light.size + 3, height: light.size + 3)
            } else {
                Circle().fill(DeepDivePalette.goldBright)
                    .frame(width: flared ? light.size * 2.6 : (isLast ? light.size * 1.5 : light.size),
                           height: flared ? light.size * 2.6 : (isLast ? light.size * 1.5 : light.size))
                    .shadow(color: DeepDivePalette.goldBright.opacity(flared ? 0.9 : (isLast ? 0.85 : 0.6)),
                            radius: flared ? 26 : (isLast ? 16 : 10))
            }
        }
        .frame(width: 40, height: 40)
        .contentShape(Circle())
        .allowsHitTesting(!isOut)
        .onTapGesture { tapExtinguish(light.id) }
    }
```

**(v) Tap + resolve handlers** - place them next to the count handlers (e.g. after
`beginCountOverflow()`), or immediately after the `extinguishDot` func above. Any private-method
location in the struct works:

```swift
    private func tapExtinguish(_ id: Int) {
        guard !extinguishDone, !extinguishedLights.contains(id) else { return }
        if extinguishLights.count - extinguishedLights.count > 1 {
            extinguishedLights.insert(id)
            UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        } else if !extinguishFlared {
            extinguishFlared = true
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            scheduleExtinguishResolve()
        } else {
            resolveExtinguish()
        }
    }

    /// After the last light flares, the verse resolves on its own (or on a second tap of it).
    private func scheduleExtinguishResolve() {
        extinguishTimer?.invalidate()
        extinguishTimer = Timer.scheduledTimer(withTimeInterval: reduceMotion ? 1.0 : 1.5, repeats: false) { _ in
            resolveExtinguish()
        }
    }

    private func resolveExtinguish() {
        guard !extinguishDone else { return }
        extinguishTimer?.invalidate(); extinguishTimer = nil
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        withAnimation(reduceMotion ? nil : .easeInOut(duration: 0.6)) { extinguishDone = true }
    }
```

**(vi) Begin-again reset** - inside `aminBlock`'s "Begin again" `withAnimation { ... }` block, add
(next to the sujud reset lines, before `answeredRefrains = []`):

```swift
                        extinguishTimer?.invalidate(); extinguishTimer = nil
                        extinguishedLights = []; extinguishFlared = false; extinguishDone = false
```

### Wave 1 build gate
```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -n 4
```
(The content file does not exist yet, so `.ikhlas` is not referenced anywhere; the engine change
compiles standalone.)

---

## Wave 2 - Content: `Thaqalayn/Content/IkhlasDeepDive.swift` (CREATE, verbatim)

Transcribe **exactly** as below (design doc section 4). Plain (non-Uthmani) Qur'an orthography;
`" - "` never an em dash; plain English spelling; curly quotes only where shown (climax + dua
translations wrap in `" "`, matching Shukr). 16 beats.

```swift
//
//  IkhlasDeepDive.swift
//  Thaqalayn
//
//  Fixed content for the "Ikhlas" deep dive - The Unmixing: a descent through the three
//  purities (al-Niyya / al-Tasfiya / al-Mukhlas), walking the root kh-l-s from the active
//  mukhlisin (98:5) through the passive mukhlasin (15:40). Summit: the three nights of
//  Surah al-Insan. Interactive close: the `extinguish` beat "The Last Light". Rendered by
//  DeepDiveView; see docs/plans/2026-07-29-ikhlas-deep-dive-design.md.
//

import SwiftUI

extension DeepDive {
    static let ikhlas: DeepDive = DeepDive(
        id: "ikhlas",
        titleEn: "Ikhlas",
        titleAr: "إِخْلَاص",
        subtitle: "Sincerity - a descent through three purities",
        sfSymbol: "drop.fill",
        estMinutes: 5,
        stageNoun: "Purity",
        stageWord: "Purity",
        acts: [
            ActInfo(number: 1, ar: "النِّيَّة", tr: "al-Niyya", name: "The Address"),
            ActInfo(number: 2, ar: "التَّصْفِيَة", tr: "al-Tasfiya", name: "The Straining"),
            ActInfo(number: 3, ar: "المُخْلَص", tr: "al-Mukhlas", name: "The Purified"),
        ],
        sections: [
            // 01. Opening
            .open(
                kicker: "A DEEP DIVE",
                titleAr: "إِخْلَاص",
                titleEn: "Ikhlas",
                subtitle: "Sincerity",
                line: "A descent through the Qur'an and the Ahl al-Bayt - the household of the Prophet ﷺ - whom the deed is for, how it is kept clean, and whose hand finishes the purifying."
            ),

            // 02. Before you descend
            .orientation(
                eyebrow: "Before you descend",
                promise: "Three purities lie below - the address every deed carries, the straining that keeps it clean, and the purity only He can finish.",
                leaveWith: "You'll leave with a map of sincerity - and a prayer that gathers all your scattered deeds into one."
            ),

            // 03. Threshold - The Three Purities
            .depths(
                act: 0,
                tag: "The Three Purities",
                reference: "al-Kafi · al-Hijr 15:40",
                items: [
                    Depth(
                        ar: "النِّيَّة",
                        tr: "al-Niyya",
                        label: "The Address",
                        desc: "Every deed travels to the one it was done for. Before the hands move, the heart has already addressed it.",
                        reference: nil,
                        embodies: "the heart that chooses its Witness"
                    ),
                    Depth(
                        ar: "التَّصْفِيَة",
                        tr: "al-Tasfiya",
                        label: "The Straining",
                        desc: "To keep the deed clean of every eye but His - even after it is done.",
                        reference: nil,
                        embodies: "the hand that hides its gift"
                    ),
                    Depth(
                        ar: "المُخْلَص",
                        tr: "al-Mukhlas",
                        label: "The Purified",
                        desc: "When the purifying passes out of your hands - and what He seals, no whisper can reach.",
                        reference: "15:40",
                        embodies: "the family He purified"
                    ),
                ]
            ),

            // 04. Purity I - The Address
            .act(
                act: 1,
                connector: nil,
                line: "It begins before the deed does. Two people kneel in the same row, give the same coin, say the same words - and the two deeds do not arrive at the same door. What separates them was settled earlier, in silence: whom it was for.",
                bridge: nil
            ),

            // 05. Purity I - The One Command (al-Bayyina 98:5)
            .verse(
                act: 1,
                tag: "The One Command",
                surah: 98,
                ayah: 5,
                arabic: "وَمَا أُمِرُوا إِلَّا لِيَعْبُدُوا اللَّهَ مُخْلِصِينَ لَهُ الدِّينَ",
                translation: "And they were not commanded except to worship God, making the religion pure for Him alone.",
                reference: "al-Bayyina · 98 : 5",
                reflection: "Not commanded except - as if every command ever sent folds into this one. And the word is mukhlisin: the ones doing the purifying. An active word; at this depth, the purifying is yours. Keep the sound of it - before the floor of this descent, one vowel of it will change."
            ),

            // 06. Purity I - The Soul of the Deed (al-Kafi)
            .narration(
                act: 1,
                tag: "The Soul of the Deed",
                source: "The Messenger of God ﷺ · al-Kafi, the chapter of intention",
                body: "The intention of the believer, said the Prophet ﷺ, is better than his deed. And every doer acts upon his intention.",
                reflection: "Better than the deed - because the deed is only the body, and the intention is its soul. Imam al-Sadiq pressed it further: the intention is the deed. The hands build the visible half; whom it was for is the half that decides."
            ),

            // 07. Purity II - The Straining
            .act(
                act: 2,
                connector: "You have addressed the deed.",
                line: "Now - guard it. The deed takes a moment; keeping it His is the long work. The wish to be seen does not come first - it comes after, quietly, for the deed you have already done.",
                bridge: nil
            ),

            // 08. Purity II - The Stone Left Bare (al-Baqarah 2:264)
            .verse(
                act: 2,
                tag: "The Stone Left Bare",
                surah: 2,
                ayah: 264,
                arabic: "فَمَثَلُهُ كَمَثَلِ صَفْوَانٍ عَلَيْهِ تُرَابٌ فَأَصَابَهُ وَابِلٌ فَتَرَكَهُ صَلْدًا",
                translation: "[The one who spends his wealth to be seen by people -] his likeness is a smooth stone with soil upon it: a downpour struck it, and left it bare.",
                reference: "al-Baqarah · 2 : 264",
                reflection: "The soil was real - the coin was given, the deed was done. But it lay on rock, not in ground. One hard rain, and nothing had ever taken root: a deed done for eyes has no earth under it."
            ),

            // 09. Purity II - The Ledger That Moves (al-Kafi)
            .narration(
                act: 2,
                tag: "The Ledger That Moves",
                source: "Imam Muhammad al-Baqir · al-Kafi, the chapter on riya",
                body: "Keeping the deed, said the Imam, is harder than the deed. He was asked: what is keeping the deed? He said: a man gives, and spends for God alone, who has no partner - and it is written for him: a secret. Then he mentions it, and it is erased - and written: done openly. Then he mentions it again, and it is erased - and written: riya, done to be seen.",
                reflection: "Nothing changed but the telling - and the telling moved the deed, ledger by ledger, from His eyes toward theirs. Some deeds stay pure the way secrets stay secrets: untold."
            ),

            // 10. Purity II - He Answers (hadith qudsi, al-Kafi)
            .response(
                act: 2,
                replyingTo: "To the one who worked for Him - and for other eyes too",
                arabic: "أَنَا خَيْرُ شَرِيكٍ",
                words: "I am the best of partners: whoever joins another with Me in a deed he does, I do not accept it - except what was purely Mine.",
                source: "His word, related by Imam al-Sadiq · al-Kafi",
                reflection: "Every partner on earth quarrels over the shares. He does not - He withdraws. A deed with two addresses is not split with Him; it is left, whole, to the other name on it. Only the undivided arrives."
            ),

            // 11. Purity III - The Purified + bridge al-Zumar 39:3
            .act(
                act: 3,
                connector: "You have strained what is yours to strain.",
                line: "Now - the turn. The first depth gave you mukhlis: the one who purifies. The Qur'an keeps a second form, one vowel away - mukhlas: the one who has been purified. No one climbs into that word. At this depth the purifying changes hands.",
                bridge: BridgeVerse(
                    surah: 39,
                    ayah: 3,
                    arabic: "أَلَا لِلَّهِ الدِّينُ الْخَالِصُ",
                    translation: "Truly - to God belongs the religion made pure.",
                    reference: "al-Zumar · 39 : 3"
                )
            ),

            // 12. Purity III - The Whisperer's Exception (al-Hijr 15:40)
            .verse(
                act: 3,
                tag: "The Whisperer's Exception",
                surah: 15,
                ayah: 40,
                arabic: "إِلَّا عِبَادَكَ مِنْهُمُ الْمُخْلَصِينَ",
                translation: "[Iblis swore: I will make evil fair to them on earth, and I will mislead them, all of them -] except, among them, Your servants - the purified.",
                reference: "al-Hijr · 15 : 40",
                reflection: "He does not say: except the careful, or the strong-willed. He names the one ground his feet cannot cross - the mukhlasin, the ones God has purified. The whisperer trades in audiences: be seen, be praised, be remembered. A heart emptied of every audience but One has walked out of his market."
            ),

            // 13. Purity III - The Forty Days (al-Kafi)
            .narration(
                act: 3,
                tag: "The Forty Days",
                source: "Imam Muhammad al-Baqir · al-Kafi, the chapter of ikhlas",
                body: "No servant keeps his faith pure for God forty days, said the Imam, but God turns his heart from the world - shows him its sickness and its cure - and sets wisdom firm in his heart, and lets his tongue speak it.",
                reflection: "The forty days are yours. Everything after them is His - the sight, the wisdom, the clean spring under the words. You bring the purifying you can manage; He answers with the purifying you cannot. Mukhlis is a labor. Mukhlas is a gift."
            ),

            // 14. Purity III - The Three Nights (al-Insan summit)
            .climax(
                act: 3,
                tag: "The Three Nights",
                source: "The household of the Prophet ﷺ · al-Insan 76:9 · Majma' al-Bayan · al-Amali of al-Saduq",
                arabic: "إِنَّمَا نُطْعِمُكُمْ لِوَجْهِ اللَّهِ لَا نُرِيدُ مِنكُمْ جَزَاءً وَلَا شُكُورًا",
                translation: "“We feed you only for the Face of God - we desire from you no repayment, and no thanks.”",
                body: "Hasan and Husayn lie ill, and the household vows three fasts for their healing - Ali, Fatima, and Fidda who serves them. The boys recover; the fasting begins. Ali brings home three measures of barley, and Fatima grinds one each day and bakes it. At sunset a poor man calls at the door. The second sunset, an orphan. The third, a captive. Three nights the whole meal passes out at the door; three nights the family breaks its fast on water. On the fourth day Ali brings the weakened boys to their grandfather - and the Prophet ﷺ weeps. Then Jibril comes down with a surah.",
                reflection: "They refused even thanks from the ones they fed - and some of the early commentators say the words were never spoken at all: God knew what was in their hearts, and praised them for it. The family kept the secret; He published it in a surah recited to the end of time. A deed so hidden, only He could tell the story."
            ),

            // 15. The Last Light (new interactive beat)
            .extinguish(
                tag: "The Last Light",
                prompt: "Who else were you doing it for?",
                subline: "The praiser, the critic, the rival - the audience you carry in your head. Small lights, each one an eye. Put them out, one by one.",
                arabic: "كُلُّ شَيْءٍ هَالِكٌ إِلَّا وَجْهَهُ",
                translation: "Everything perishes - except His Face.",
                reference: "al-Qasas · 28 : 88",
                note: "Every audience leaves the theater in the end. The gaze you could not put out was the first one on your deed - and the only one that keeps it.",
                nextLabel: "And one prayer"
            ),

            // 16. The Close - A Prayer of One Litany (Dua Kumayl)
            .dua(
                tag: "A Prayer of One Litany",
                intro: "After the stone, after the three nights - one prayer, in the voice of the first Imam, taught by night to Kumayl ibn Ziyad: that the scattered deeds become one.",
                arabic: "أَنْ تَجْعَلَ أَوْقَاتِي فِي اللَّيْلِ وَالنَّهَارِ بِذِكْرِكَ مَعْمُورَةً، وَبِخِدْمَتِكَ مَوْصُولَةً، وَأَعْمَالِي عِنْدَكَ مَقْبُولَةً، حَتَّىٰ تَكُونَ أَعْمَالِي وَأَوْرَادِي كُلُّهَا وِرْدًا وَاحِدًا، وَحَالِي فِي خِدْمَتِكَ سَرْمَدًا",
                translation: "“That You make my times, by night and by day, filled with Your remembrance, joined to Your service, my works accepted with You - until my works and my litanies become all one litany, and my state in Your service everlasting.”",
                source: "Imam Ali · Dua Kumayl - Misbah al-Mutahajjid of al-Tusi",
                note: "A whole lifetime, gathered to a single address. Begin smaller tonight: one deed with the door shut and no one told - aimed, start to finish, at the One who was watching before you began.",
                close: "The intention is yours to keep."
            ),
        ]
    )
}
```

### Wave 2 build gate
Same `xcodebuild` command. `.ikhlas` now exists but is not yet referenced by the catalog - it must
still compile.

---

## Wave 3 - Catalog flip + What's New entry

### 3a. `Thaqalayn/Services/DeepDiveCatalog.swift` - the `ikhlas` descriptor

Replace the `subtitle:` and the `available:/dive:` line:

```swift
            subtitle: LocalizedText(en: "A descent through three purities - Qur'an to the house of Fatima",
                                    ur: "تین پاکیزگیوں میں اترتا ایک سفر - قرآن سے خانۂ فاطمہؑ تک",
                                    ar: "نزولٌ عبر ثلاث صفاءات - من القرآن إلى بيت فاطمة عليها السلام"),
            available: true, dive: .ikhlas,
```

(Leave `id`, `title`, `titleAr`, `sfSymbol`, `coverAssetName: "IkhlasCover"` unchanged.)

### 3b. `Thaqalayn/Models/WhatsNewItem.swift` - new entry at the TOP of `WhatsNewCatalog.all`

Insert as the first element (newest-first; `releaseDate` is a **placeholder** - adjust at ship):

```swift
        WhatsNewItem(
            id: "deepDives-ikhlas",
            sfSymbol: "drop.fill",
            releaseDate: DateComponents(calendar: .current, year: 2026, month: 8, day: 17).date ?? .distantPast,
            destination: .deepDive("ikhlas"),
            titleEN: "New Deep Dive",
            titleUR: "نیا گہرا غوطہ",
            titleAR: "غوصٌ عميقٌ جديد",
            blurbEN: "Ikhlas - The Unmixing. A descent through three purities, from the address every deed carries to the three hidden nights of Surah al-Insan - ending with one light that will not go out.",
            blurbUR: "اخلاص - خالص کرنے کا سفر۔ تین پاکیزگیوں میں اترتا ہوا ایک عمیق سفر، ہر عمل کے پتے سے سورۂ انسان کی تین پوشیدہ راتوں تک - اختتام اُس ایک روشنی پر جو بجھتی نہیں۔",
            blurbAR: "الإخلاص - التصفية. نزولٌ عبر ثلاث صفاءات، من العنوان الذي يحمله كل عمل إلى ليالي سورة الإنسان الثلاث الخفية - يُختَم بنورٍ واحدٍ لا ينطفئ.",
            ctaEN: "Begin the descent",
            ctaUR: "نزول کا آغاز کریں",
            ctaAR: "ابدأ النزول"
        ),
```

### Wave 3 build gate
Same `xcodebuild` command; expect green.

---

## Stage 4 - Own build + guardrail greps (run myself)

```bash
# Final independent build:
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build 2>&1 | tail -n 4

FILES="Thaqalayn/Content/IkhlasDeepDive.swift Thaqalayn/Models/DeepDive.swift Thaqalayn/Views/DeepDive/DeepDiveView.swift Thaqalayn/Services/DeepDiveCatalog.swift Thaqalayn/Models/WhatsNewItem.swift"
git diff -U0 -- $FILES | grep "^+" | grep "—"                 # em dashes in added lines -> expect empty
grep -c "—" Thaqalayn/Content/IkhlasDeepDive.swift            # expect 0
python3 scripts/strip_diacritics.py --report Thaqalayn/Content/IkhlasDeepDive.swift   # expect 0
grep -n "lock.fill" $FILES                                    # expect empty
grep -o "\.\(open\|orientation\|depths\|act\|verse\|narration\|response\|climax\|extinguish\|dua\)(" \
  Thaqalayn/Content/IkhlasDeepDive.swift | sort | uniq -c     # census: 1 open,1 orientation,1 depths,3 act,3 verse,3 narration,1 response,1 climax,1 extinguish,1 dua = 16 beats
# fixed renderer strings present:
grep -n "Tap each light - put it out\|This one does not go out" Thaqalayn/Views/DeepDive/DeepDiveView.swift
```

Ignore SourceKit "cannot find type in scope" on the new file - stale index; the green xcodebuild is
the truth. No XCTest, no simulator launch (user does the device pass).

## Stage 5 - Four-auditor audit (flag-only)

Two waves of two, all Opus, report-only (no edits): A flow/ledger, B theology/sourcing/Arabic,
C readability, D voice/reverence. Consolidate -> ranked list -> present -> STOP for the user to pick
fixes. Note for auditors: the vowel-turn readability of beats 05 & 11 was flagged at Gate 2 and
deferred to Auditor C on purpose.

## Out of scope / notes
- UR/AR dive content (EN-first; localize later). Catalog subtitle + What's New ARE trilingual.
- `releaseDate` 2026-08-17 is a placeholder - adjust at ship.
- No persistence of the extinguish interaction; no new audio assets; `IkhlasCover` already exists.
