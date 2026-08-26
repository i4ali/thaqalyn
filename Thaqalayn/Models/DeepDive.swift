//
//  DeepDive.swift
//  Thaqalayn
//
//  Data for one immersive "deep dive": a themed, single-sitting descent rendered
//  by DeepDiveView. Section cases mirror the `type`s in MajlisYaqeen.jsx.
//
//  Prose is carried by `LocalizedText` (English displayed; legacy ur/ar decode fields
//  are ignored). Qur'an Arabic, references, and surah/ayah numbers are single-string.
//

import SwiftUI

// `LocalizedText` (en + optional ur/ar decode fields, displayed via `.text`) is defined once in
// DailyChallengeModels.swift and reused here - no duplicate type. These additive conveniences
// let the deep-dive content read ergonomically:
extension LocalizedText {
    /// Resolve like a function: `field()` == `field.text`.
    func callAsFunction() -> String { text }
    /// Text identical in every language (proper nouns, transliterations, symbols).
    init(_ shared: String) { self.init(en: shared, ur: shared, ar: shared) }
    /// English + Urdu only; Arabic falls back to English. For copy localized to Urdu
    /// but not Arabic (e.g. Journey-tab deep-dive card text).
    init(en: String, ur: String) { self.init(en: en, ur: ur, ar: nil) }
}

extension LocalizedText: ExpressibleByStringLiteral {
    /// A plain string literal is treated as English-only (ur/ar fall back to en). Keeps
    /// not-yet-localized dive content compiling - `subtitle: "…"` works alongside
    /// `LocalizedText(en:ur:ar:)`.
    init(stringLiteral value: String) { self.init(en: value, ur: nil, ar: nil) }
}

/// The three-part structure metadata (Ilm / Ayn / Haqq al-Yaqin for the Yaqin dive).
struct ActInfo: Identifiable {
    let number: Int
    let ar: String
    let tr: String
    let name: LocalizedText
    var id: Int { number }
}

/// One row in the "three depths" interactive map.
struct Depth: Identifiable {
    let ar: String
    let tr: String
    let label: LocalizedText
    let desc: LocalizedText
    let reference: String?
    let embodies: LocalizedText
    var id: String { tr }
}

/// A short bridge verse carried by an `act` (movement) section.
struct BridgeVerse {
    let surah: Int
    let ayah: Int
    let arabic: String
    let translation: LocalizedText
    let reference: String
}

/// One full-screen beat in the descent. Cases mirror the section `type`s in
/// MajlisYaqeen.jsx.
enum DeepDiveSection {
    case open(kicker: LocalizedText, titleAr: String, titleEn: String, subtitle: LocalizedText, line: LocalizedText)
    /// A guiding "how this works + the promise" beat, shown right after the open.
    case orientation(eyebrow: LocalizedText, promise: LocalizedText, leaveWith: LocalizedText)
    case verse(act: Int, tag: LocalizedText, surah: Int, ayah: Int, arabic: String, translation: LocalizedText, reference: String, reflection: LocalizedText)
    case depths(act: Int, tag: LocalizedText, reference: String, items: [Depth])
    /// A movement divider. `connector` names the thread back to the prior movement
    /// (e.g. "You have known it by proof.") so the KNOW → SEE → LIVE arc is explicit.
    case act(act: Int, connector: LocalizedText?, line: LocalizedText, bridge: BridgeVerse?)
    case narration(act: Int, tag: LocalizedText, source: LocalizedText, body: LocalizedText, reflection: LocalizedText)
    /// A hadith-qudsi "reply" beat: after a verse the servant has recited, God's answer
    /// in the division of the prayer (Uyun Akhbar al-Rida). Distinct from `narration`
    /// so it renders as a call-and-response reply ("He answers"), not a story block.
    /// `replyingTo` names the line He is answering; `arabic` is the anchor of His words.
    case response(act: Int, replyingTo: LocalizedText, arabic: String, words: LocalizedText, source: LocalizedText, reflection: LocalizedText)
    case climax(act: Int, tag: LocalizedText, source: LocalizedText, arabic: String, translation: LocalizedText, body: LocalizedText, reflection: LocalizedText)
    /// The recurring question of al-Rahman: the refrain verse glows, and the reader
    /// answers it in the words the Ahl al-Bayt taught - the reply rising as an
    /// ascending thread of light, the deliberate inverse of `response`'s descending
    /// one (there He answers you; here He asks and you answer). `teachSource` is
    /// non-nil on the first occurrence only, where the reply is being taught;
    /// `replyArabic` is a taught devotional phrase, not Qur'an (no byte-check).
    case refrain(act: Int, tag: LocalizedText, surah: Int, ayah: Int, arabic: String, translation: LocalizedText, reference: String, intro: LocalizedText, teachSource: LocalizedText?, replyArabic: String, replyTransliteration: String, replyTranslation: LocalizedText, reflection: LocalizedText)
    case reflectionPrompt(tag: LocalizedText, prompt: LocalizedText, placeholder: LocalizedText, subline: LocalizedText, nextLabel: LocalizedText)
    /// The interactive close of a dive built on entrustment (Tawakkul): the reader names
    /// what they are gripping - in their heart - presses and holds the ring (that is the
    /// grip), and the lifting of the finger IS the release, resolving into the entrusting
    /// verse. Replaces `reflectionPrompt` for such dives.
    case release(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText, arabic: String, translation: LocalizedText, reference: String, note: LocalizedText, nextLabel: LocalizedText)
    /// The interactive close of a dive built on gratitude (Shukr): the reader taps to
    /// count blessings - each tap births a point of light - until the lights begin
    /// multiplying on their own, outrunning the finger, and the screen resolves into
    /// the verse: the count cannot be finished. Replaces `reflectionPrompt` for such dives.
    case count(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText, arabic: String, translation: LocalizedText, reference: String, note: LocalizedText, nextLabel: LocalizedText)
    /// The interactive close of a dive built on prayer and nearness. The reader presses
    /// and holds - the held stillness IS the prostration: a point of light sinks to the
    /// earth-line while the screen draws close, and the verse resolves while still held.
    /// Lifting the finger afterward is the rising from sujud, into the closing dua.
    case sujud(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText, arabic: String, translation: LocalizedText, reference: String, note: LocalizedText, nextLabel: LocalizedText)
    /// The interactive close of a dive built on sincerity (Ikhlas): a fixed scatter of
    /// small lights - the audiences the reader has performed for. Tapping a light puts it
    /// out; the last light cannot be put out - tapping it only makes it flare - and the
    /// screen resolves into the verse: everything perishes except His Face. The gesture is
    /// subtraction to the one unremovable Watcher, the meaning-inverse of `count`. Replaces
    /// `reflectionPrompt` for such dives.
    case extinguish(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
                    arabic: String, translation: LocalizedText, reference: String,
                    note: LocalizedText, nextLabel: LocalizedText)
    /// The interactive close of a dive built on the guarding fear (Taqwa): a warm "forbidden"
    /// opening rests, then drifts across the screen and away. The reader must WITHHOLD - not
    /// touch it - and let it pass; holding still until it has passed resolves into the verse,
    /// while reaching for it (a tap) gently resets the drift ("it opens again"). The one
    /// interactive close in the series where acting is the failure - restraint itself is the
    /// gesture, the meaning-inverse of every tap/press/hold beat. Replaces `reflectionPrompt`.
    case door(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
              arabic: String, translation: LocalizedText, reference: String,
              note: LocalizedText, nextLabel: LocalizedText)
    /// The interactive close of a dive built on the gathering's answer (al-Kisa): five dim
    /// lights in a low arc - one for each soul beneath the cloak. Each tap lights the next
    /// name in the order the cloak gathered them (Muhammad ﷺ, Hasan, Husayn, Ali, Fatima);
    /// at five the arc joins into a single glow and resolves into the salawat formula. A
    /// count that COMPLETES at exactly five - the meaning-inverse of `count` (blessings
    /// cannot be counted; the beloved can). Replaces `reflectionPrompt` for such dives.
    case salawat(tag: LocalizedText, prompt: LocalizedText, subline: LocalizedText,
                 arabic: String, translation: LocalizedText, reference: String,
                 note: LocalizedText, nextLabel: LocalizedText)
    /// `close` is the theme-specific final clause shown after "The descent ends." in the
    /// Amin block (e.g. "The certainty is yours to keep." for Yaqin) — per-dive so it never
    /// carries another dive's theme.
    case dua(tag: LocalizedText, intro: LocalizedText, arabic: String, translation: LocalizedText, source: LocalizedText, note: LocalizedText, close: LocalizedText)
    /// The final beat of a surah experience: restates the surah's essence and
    /// hands off to reading the full surah. Replaces `dua` for surah dives -
    /// a surah experience is an understanding journey, not a devotional close.
    case closing(tag: LocalizedText, titleAr: String, essence: LocalizedText, line: LocalizedText)

    /// Act number for the persistent depth stepper (0 = opening, 4 = reflection/dua close).
    var act: Int {
        switch self {
        case .open, .orientation:                          return 0
        case .verse(let a, _, _, _, _, _, _, _):           return a
        case .depths(let a, _, _, _):                      return a
        case .act(let a, _, _, _):                         return a
        case .narration(let a, _, _, _, _):                return a
        case .response(let a, _, _, _, _, _):              return a
        case .climax(let a, _, _, _, _, _, _):             return a
        case .refrain(let a, _, _, _, _, _, _, _, _, _, _, _, _): return a
        case .reflectionPrompt, .release, .count, .sujud, .extinguish, .door, .salawat, .dua, .closing: return 4
        }
    }
}

// MARK: - Narration (audio journey)

/// A real Arabic recitation woven into the narration. `verse` is Qur'an, played
/// with reciter audio (cache-on-play, a later task); `dua` is a captured devotional
/// recording resolved through `DuaAudioKey.recordingURL(for:)`. When no recording
/// exists the player skips the segment gracefully - the narrator never speaks Arabic.
enum Recitation: Equatable {
    case verse(surah: Int, ayah: Int)   // reciter audio (cache-on-play, later task)
    case dua(arabic: String)            // DuaAudioKey.recordingURL(for:) - captured dua recordings
}

/// A unit of journey narration. `speech` is English narrator audio (pre-rendered);
/// `recitation` is real Arabic audio (verse reciter or captured dua recording);
/// `pause` is reflective silence (interactive/close beats).
enum NarrationSegment: Equatable {
    case speech(String)
    case recitation(Recitation)
    case pause(TimeInterval)
}

extension DeepDiveSection {
    /// This beat as an ordered list of narrator segments (English).
    /// Only reading content is spoken; chrome (tags, references, sources, placeholders,
    /// titles, next-labels) is dropped. Guaranteed-audio verse recitations are framed
    /// "The Qur'an says:" → recitation → "which means:" → the translation. The intro and
    /// per-movement announcements are added at the timeline level, not here.
    func narrationSegments() -> [NarrationSegment] {
        // Text → a speech segment, or nil when empty/absent (so it drops out).
        func s(_ text: LocalizedText?) -> NarrationSegment? {
            guard let str = text?.text, !str.isEmpty else { return nil }
            return .speech(str)
        }
        // Framed recitation of a guaranteed-audio Qur'an verse.
        func verse(_ surah: Int, _ ayah: Int, _ translation: LocalizedText) -> [NarrationSegment?] {
            [.speech(JourneyNarration.verseLeadIn),
             .recitation(.verse(surah: surah, ayah: ayah)),
             .pause(0.8),
             .speech(JourneyNarration.meaning),
             s(translation)]
        }
        let gap: NarrationSegment = .pause(JourneyNarration.beatGap)

        let raw: [NarrationSegment?]
        switch self {
        case let .open(_, _, _, _, line):
            raw = [s(line), gap]

        case let .orientation(_, promise, leaveWith):
            raw = [s(promise), s(leaveWith), gap]

        case let .depths(_, _, _, items):
            var segs: [NarrationSegment?] = []
            for (i, d) in items.enumerated() {
                segs += [s(d.label), s(d.desc), s(d.embodies)]
                if i < items.count - 1 { segs.append(.pause(0.6)) }
            }
            segs.append(gap)
            raw = segs

        case let .act(_, connector, line, bridge):
            var segs: [NarrationSegment?] = [s(connector), s(line)]
            if let b = bridge { segs += verse(b.surah, b.ayah, b.translation) }
            segs.append(gap)
            raw = segs

        case let .verse(_, _, surah, ayah, _, translation, _, reflection):
            raw = verse(surah, ayah, translation) + [s(reflection), gap]

        case let .narration(_, _, _, body, reflection):
            raw = [s(body), s(reflection), gap]

        case let .response(_, _, arabic, words, _, reflection):
            // Optimistic dua recitation: this hadith-qudsi Arabic has no recording yet,
            // so the player skips it - emitting it keeps the narrator from speaking Arabic
            // and future-proofs the beat. No `meaning` connector: `words` is not its gloss.
            raw = [.recitation(.dua(arabic: arabic)), s(words), s(reflection), gap]

        case let .climax(_, _, _, arabic, _, body, reflection):
            // Optimistic dua recitation (same reasoning as `response`). `translation` is
            // skipped: the iconic line already lives inside `body`, so it would be redundant.
            raw = [.recitation(.dua(arabic: arabic)), s(body), s(reflection), gap]

        case let .refrain(_, _, surah, ayah, _, translation, _, intro, _, replyArabic, _, replyTranslation, reflection):
            raw = [s(intro)]
                + verse(surah, ayah, translation)
                + [.recitation(.dua(arabic: replyArabic)), s(replyTranslation), s(reflection), gap]

        case let .reflectionPrompt(_, prompt, _, subline, _):
            raw = [s(prompt), s(subline), .pause(4.0)]

        // The interactive closes all share the same shape: name the gesture, recite the
        // resolving verse (optimistic - no captured audio yet, player skips), then its
        // meaning and note, ending on a reflective pause. No `meaning` connector.
        case let .release(_, prompt, subline, arabic, translation, _, note, _),
             let .count(_, prompt, subline, arabic, translation, _, note, _),
             let .sujud(_, prompt, subline, arabic, translation, _, note, _),
             let .extinguish(_, prompt, subline, arabic, translation, _, note, _),
             let .door(_, prompt, subline, arabic, translation, _, note, _),
             let .salawat(_, prompt, subline, arabic, translation, _, note, _):
            raw = [s(prompt), s(subline),
                   .recitation(.dua(arabic: arabic)),
                   s(translation), s(note), .pause(3.0)]

        case let .dua(_, intro, arabic, translation, _, note, close):
            raw = [s(intro),
                   .recitation(.dua(arabic: arabic)),
                   .speech(JourneyNarration.meaning),
                   s(translation), s(note), s(close), gap]

        case let .closing(_, _, essence, line):
            raw = [s(essence), s(line), gap]
        }
        return raw.compactMap { $0 }
    }
}

/// One immersive deep dive. Data-driven so future dives (Sabr, Tawakkul, …) are
/// pure content additions rendered by the same `DeepDiveView`.
struct DeepDive: Identifiable {
    let id: String
    let titleEn: String
    let titleAr: String
    let subtitle: LocalizedText
    let sfSymbol: String
    let estMinutes: Int
    /// Noun in the movement-card chrome ("THE ENDURING · STATION 1 OF 3") - each
    /// dive's own spine vocabulary: Depth (Yaqin), Station (Sabr), Motion (Tawakkul), Tongue (Shukr).
    var stageNoun: String = "Depth"
    /// CTA under the open beat. "Descend" for the classic dives; "Ascend" for Salah.
    var descendCta: String = "Descend"
    /// CTA under the orientation beat.
    var beginCta: String = "Begin the descent"
    /// Subline under the threshold-map title.
    var mapLine: String = "The map for everything below."
    /// The big label on movement cards and the place-bar noun ("Movement I · ...").
    var stageWord: String = "Movement"
    /// The line in the Amin block before the dive's `close` clause.
    var endLine: String = "The descent ends."
    /// The orientation beat's scroll hint row - the journey metaphor, not the gesture.
    var scrollHint: String = "Scroll to sink deeper"
    var scrollHintIcon: String = "arrow.down"
    let acts: [ActInfo]
    let sections: [DeepDiveSection]

    func actInfo(_ n: Int) -> ActInfo? { acts.first { $0.number == n } }

    /// First section index of each act — drives the persistent depth stepper.
    func firstIndex(ofAct n: Int) -> Int? { sections.firstIndex { $0.act == n } }
}
