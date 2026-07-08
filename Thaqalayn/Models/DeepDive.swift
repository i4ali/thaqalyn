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

/// The three-part structure metadata (ʿIlm / ʿAyn / Ḥaqq al-Yaqīn for the Yaqīn dive).
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
    /// A ḥadīth-qudsī "reply" beat: after a verse the servant has recited, God's answer
    /// in the division of the prayer (ʿUyūn Akhbār al-Riḍā). Distinct from `narration`
    /// so it renders as a call-and-response reply ("He answers"), not a story block.
    /// `replyingTo` names the line He is answering; `arabic` is the anchor of His words.
    case response(act: Int, replyingTo: LocalizedText, arabic: String, words: LocalizedText, source: LocalizedText, reflection: LocalizedText)
    case climax(act: Int, tag: LocalizedText, source: LocalizedText, arabic: String, translation: LocalizedText, body: LocalizedText, reflection: LocalizedText)
    case reflectionPrompt(tag: LocalizedText, prompt: LocalizedText, placeholder: LocalizedText, subline: LocalizedText, nextLabel: LocalizedText)
    /// `close` is the theme-specific final clause shown after "The descent ends." in the
    /// Āmīn block (e.g. "The certainty is yours to keep." for Yaqīn) — per-dive so it never
    /// carries another dive's theme.
    case dua(tag: LocalizedText, intro: LocalizedText, arabic: String, translation: LocalizedText, source: LocalizedText, note: LocalizedText, close: LocalizedText)
    /// The final beat of a sūrah experience: restates the sūrah's essence and
    /// hands off to reading the full sūrah. Replaces `dua` for sūrah dives -
    /// a sūrah experience is an understanding journey, not a devotional close.
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
        case .reflectionPrompt, .dua, .closing:            return 4
        }
    }
}

/// One immersive deep dive. Data-driven so future dives (Ṣabr, Tawakkul, …) are
/// pure content additions rendered by the same `DeepDiveView`.
struct DeepDive: Identifiable {
    let id: String
    let titleEn: String
    let titleAr: String
    let subtitle: LocalizedText
    let sfSymbol: String
    let estMinutes: Int
    let acts: [ActInfo]
    let sections: [DeepDiveSection]

    func actInfo(_ n: Int) -> ActInfo? { acts.first { $0.number == n } }

    /// First section index of each act — drives the persistent depth stepper.
    func firstIndex(ofAct n: Int) -> Int? { sections.firstIndex { $0.act == n } }
}
