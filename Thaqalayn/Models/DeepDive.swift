//
//  DeepDive.swift
//  Thaqalayn
//
//  Data for one immersive "deep dive": a themed, single-sitting descent rendered
//  by DeepDiveView. Section cases mirror the `type`s in MajlisYaqeen.jsx.
//
//  Prose is localized (EN / UR / AR) via `LocalizedText`. Qur'an Arabic, references,
//  and surah/ayah numbers stay single-string (identical across languages).
//

import SwiftUI

// `LocalizedText` (en + optional ur/ar, resolved via `.text(for:)`) is defined once in
// DailyChallengeModels.swift and reused here - no duplicate type. These additive conveniences
// let the deep-dive content read ergonomically:
extension LocalizedText {
    /// Resolve like a function: `field(lang)` == `field.text(for: lang)`.
    func callAsFunction(_ l: CommentaryLanguage) -> String { text(for: l) }
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
        case .reflectionPrompt, .release, .count, .sujud, .dua, .closing: return 4
        }
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
