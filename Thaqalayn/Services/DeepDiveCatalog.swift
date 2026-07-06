//
//  DeepDiveCatalog.swift
//  Thaqalayn
//
//  Static registry of the immersive "deep dives" shown in the Journeys tab,
//  alongside the seasonal journeys. Mirrors JourneyCatalog's shape but carries no
//  calendar logic — a dive is simply available or coming soon.
//

import SwiftUI

/// One deep dive in the hub. Static registry — see `DeepDiveDescriptor.all`.
struct DeepDiveDescriptor: Identifiable {
    /// Stable id — matches the deep-link id if/when deep dives get deep links.
    let id: String
    let eyebrow: String        // e.g. "Deep Dive"
    let titleEn: String        // e.g. "Yaqīn · Certainty"
    let titleAr: String        // e.g. "يَقِين"
    let sfSymbol: String       // card icon
    let subtitle: String       // one-line descriptor
    /// True when the dive is built and openable. False = "coming soon" placeholder.
    let available: Bool
    /// The dive content, present only when `available`.
    let dive: DeepDive?

    static let all: [DeepDiveDescriptor] = [
        DeepDiveDescriptor(
            id: "yaqin", eyebrow: "Deep Dive",
            titleEn: "Yaqīn · Certainty", titleAr: "يَقِين",
            sfSymbol: "eye",
            subtitle: "A descent through three depths - Qur'an to Karbala",
            available: true, dive: .yaqin
        ),
        DeepDiveDescriptor(
            id: "sabr", eyebrow: "Deep Dive",
            titleEn: "Ṣabr · Patience", titleAr: "صَبْر",
            sfSymbol: "hourglass",
            subtitle: "Standing firm through trial",
            available: false, dive: nil
        ),
        DeepDiveDescriptor(
            id: "tawakkul", eyebrow: "Deep Dive",
            titleEn: "Tawakkul · Reliance", titleAr: "تَوَكُّل",
            sfSymbol: "hands.and.sparkles",
            subtitle: "Trusting God with the outcome",
            available: false, dive: nil
        ),
    ]

    static func byId(_ id: String) -> DeepDiveDescriptor? { all.first { $0.id == id } }
}
