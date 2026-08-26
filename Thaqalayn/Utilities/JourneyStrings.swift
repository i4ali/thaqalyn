//
//  JourneyStrings.swift
//  Thaqalayn
//
//  Copy for the Journey tab - hub, the seasonal journeys
//  (Ramadan, Dhul-Hijjah/Hajj, Muharram, Fatimiyya, Arbaeen), their day lists and
//  day-detail screens.
//

import Foundation

enum JourneyStrings {
    // MARK: - Hub
    static let sacredSeasons = "Sacred Seasons"
    static let journeys = "Journeys"
    static let journeysSub = "Live a sacred season, or descend into a theme."
    static let grow = "Grow"
    static let deepDives = "Deep Dives"
    static let deepDivesSub = "explore anytime"
    static let comingSoon = "Coming soon"
    static func deepDiveOnItsWay(_ title: String) -> String { "\(title) is on its way." }
    // Deep Dive card chrome - shared across every dive card. `premium` is the shared
    // Premium chip label, kept consistent across the app.
    static let deepDiveEyebrow = "Deep Dive"
    static let soon = "SOON"
    static let premium = "Premium"

    // MARK: - Shelf status eyebrows (compact hub cards)
    // Short status words shown in the eyebrow slot of the horizontal-shelf cards.
    // Longer, full-sentence variants (comingSoonInDays / endedReturns) still drive
    // the full-width "All N" list cards.
    static let live = "LIVE"
    static let ready = "READY"
    static func inDaysShort(_ days: Int) -> String { "IN \(days) DAY\(days == 1 ? "" : "S")" }
    static let endedShort = "ENDED"
    /// "See all" link on a shelf header - count is that section's live total.
    static func allCount(_ n: Int) -> String { "All \(n)" }
    // Surah experiences ("Inside the Surah") - hub section, card eyebrow, closing CTA.
    static let insideTheSurah = "Inside the Surah"
    static let anImmersiveJourney = "An immersive journey"
    static let surahJourneyEyebrow = "Surah Journey"

    // MARK: - The veil (a gated descent, previewed)

    /// Copy for the beat a non-subscriber reaches when the descent is gated. House rule:
    /// name what lies behind the veil, and never show a lock.
    static let veilEyebrow = "The descent continues"
    static let veilCta = "Continue the descent"
    static let veilNote = "One payment. Yours for life."

    // The veil, extended to a locked journey day. Same rule: name what waits, never a
    // lock. The day's theme and opening line are shown for real; these name the rest.
    // `station: true` swaps the unit noun for Arbaeen (stations, not days).
    static func dayVeilEyebrow(station: Bool = false) -> String {
        station ? "The station continues" : "The day continues"
    }
    static let dayVeilDua = "The supplication, with translation and audio"
    static func dayVeilVerses(_ count: Int) -> String {
        "\(count) verse\(count == 1 ? "" : "s"), each with a reflection"
    }
    static func dayVeilReflection(station: Bool = false) -> String {
        station ? "A reflection to close the station" : "A reflection to close the day"
    }
    static func dayVeilCta(station: Bool = false) -> String {
        station ? "Open the full station" : "Open the full day"
    }
    static let readTheFullSurah = "Read the full surah"
    // Surah-card mode toggle: Read & Tafsir | Journey.
    static let readAndTafsir = "Read & Tafsir"
    static let journey = "Journey"
    static let nextUp = "NEXT UP"
    static func comingSoonInDays(_ days: Int) -> String {
        "Coming soon · in \(days) day\(days == 1 ? "" : "s")"
    }
    static func endedReturns(_ returnsLabel: String) -> String { "Ended · \(returnsLabel)" }
    static let gotIt = "Got it"

    // Locked-journey alert
    static func hasEnded(_ title: String) -> String { "\(title) has ended" }
    static func notOpenYet(_ title: String) -> String { "\(title) isn't open yet" }
    static func upNextInDays(_ title: String, _ days: Int) -> String {
        "Up next: \(title) · in \(days) day\(days == 1 ? "" : "s")"
    }
    static func upNextToday(_ title: String) -> String { "Up next: \(title) · today" }
    static func isOpenNow(_ title: String) -> String { "\(title) is open now" }
    static func begins(_ date: String) -> String { "Begins \(date)" }
    static func returns(_ date: String) -> String { "Returns \(date)" }
    static func firstFatimiyya(_ date: String) -> String { "First Fatimiyya · \(date)" }
    static func secondFatimiyya(_ date: String) -> String { "Second Fatimiyya · \(date)" }

    // MARK: - Journey identity (by descriptor id) - used in hub + journey headers
    static func title(_ id: String) -> String {
        switch id {
        case "ramadan":  return "Ramadan"
        case "hajj":     return "Dhul-Hijjah"
        case "muharram": return "Muharram"
        case "fatimiyya":return "Fatimiyya"
        case "arbaeen":  return "Arbaeen"
        default:         return id.capitalized
        }
    }
    static func eyebrow(_ id: String, _ english: String) -> String { english }
    /// Short evocative tagline for a seasonal journey - shown as the description
    /// line on the compact hub shelf card (not the full-width "All" list, which
    /// keeps the status detail line).
    static func seasonTagline(_ id: String) -> String {
        switch id {
        case "ramadan":  return "Thirty nights of nearness"
        case "hajj":     return "The best ten days"
        case "muharram": return "The stand at Karbala"
        case "arbaeen":  return "The road to Arbaeen"
        case "fatimiyya":return "Mourning of az-Zahra (AS)"
        default:         return ""
        }
    }

    /// Legacy in-screen header title, e.g. "Muharram Journey".
    static func screenTitle(_ id: String) -> String { "\(title(id)) Journey" }

    // MARK: - Day list / progress
    static func daysObserved(_ done: Int, _ total: Int) -> String {
        "\(done) of \(total) days observed"
    }
    static func stationsObserved(_ done: Int, _ total: Int) -> String {
        "\(done) of \(total) stations observed"
    }
    static func daysCompleted(_ done: Int, _ total: Int) -> String {
        "\(done) of \(total) days completed"
    }
    static func dayN(_ n: Int) -> String { "Day \(n)" }
    static func stationN(_ n: Int) -> String { "Station \(n)" }
    static let today = "TODAY"
    static let loadingJourney = "Loading journey..."
    static let errorLoadingJourney = "Error Loading Journey"

    // MARK: - Day detail section labels & buttons
    static let todaysVerses = "Today's Verses"
    static let tafsirFocus = "Tafsir Focus"
    static let reflection = "Reflection"
    static let duaZiyarat = "Dua / Ziyarat"
    static let fullTafsir = "Full Tafsir"
    static let readFullZiyarat = "Read the full ziyarat"
    static let fullZiyaratTitle = "Ziyarat of Arbaeen"
    static let done = "Done"
    static let backToJourney = "Journey"
    static let ashura = "Ashura"

    // Toggle button - mourning journeys ("observed") vs others ("completed")
    static let observed = "Observed"
    static let markObserved = "Mark as observed"
    static let completed = "Completed"
    static let markComplete = "Mark as complete"
}
