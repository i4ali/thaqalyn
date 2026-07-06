//
//  DeepDive.swift
//  Thaqalayn
//
//  Data for one immersive "deep dive": a themed, single-sitting descent rendered
//  by DeepDiveView. Section cases mirror the `type`s in MajlisYaqeen.jsx.
//

import SwiftUI

/// The three-part structure metadata (ʿIlm / ʿAyn / Ḥaqq al-Yaqīn for the Yaqīn dive).
struct ActInfo: Identifiable {
    let number: Int
    let ar: String
    let tr: String
    let name: String
    var id: Int { number }
}

/// One row in the "three depths" interactive map.
struct Depth: Identifiable {
    let ar: String
    let tr: String
    let label: String
    let desc: String
    let reference: String?
    let embodies: String
    var id: String { tr }
}

/// A short bridge verse carried by an `act` (movement) section.
struct BridgeVerse {
    let surah: Int
    let ayah: Int
    let arabic: String
    let translation: String
    let reference: String
}

/// One full-screen beat in the descent. Cases mirror the section `type`s in
/// MajlisYaqeen.jsx.
enum DeepDiveSection {
    case open(kicker: String, titleAr: String, titleEn: String, subtitle: String, line: String)
    /// A guiding "how this works + the promise" beat, shown right after the open.
    case orientation(eyebrow: String, promise: String, leaveWith: String)
    case verse(act: Int, tag: String, surah: Int, ayah: Int, arabic: String, translation: String, reference: String, reflection: String)
    case depths(act: Int, tag: String, reference: String, items: [Depth])
    /// A movement divider. `connector` names the thread back to the prior movement
    /// (e.g. "You have known it by proof.") so the KNOW → SEE → LIVE arc is explicit.
    case act(act: Int, connector: String?, line: String, bridge: BridgeVerse?)
    case narration(act: Int, tag: String, source: String, body: String, reflection: String)
    case climax(act: Int, tag: String, source: String, arabic: String, translation: String, body: String, reflection: String)
    case reflectionPrompt(tag: String, prompt: String, placeholder: String)
    case dua(tag: String, intro: String, arabic: String, translation: String, source: String, note: String)

    /// Act number for the persistent depth stepper (0 = opening, 4 = reflection/dua close).
    var act: Int {
        switch self {
        case .open, .orientation:                          return 0
        case .verse(let a, _, _, _, _, _, _, _):           return a
        case .depths(let a, _, _, _):                      return a
        case .act(let a, _, _, _):                         return a
        case .narration(let a, _, _, _, _):                return a
        case .climax(let a, _, _, _, _, _, _):             return a
        case .reflectionPrompt, .dua:                      return 4
        }
    }
}

/// One immersive deep dive. Data-driven so future dives (Ṣabr, Tawakkul, …) are
/// pure content additions rendered by the same `DeepDiveView`.
struct DeepDive: Identifiable {
    let id: String
    let titleEn: String
    let titleAr: String
    let subtitle: String
    let sfSymbol: String
    let estMinutes: Int
    let acts: [ActInfo]
    let sections: [DeepDiveSection]

    func actInfo(_ n: Int) -> ActInfo? { acts.first { $0.number == n } }

    /// First section index of each act — drives the persistent depth stepper.
    func firstIndex(ofAct n: Int) -> Int? { sections.firstIndex { $0.act == n } }
}
