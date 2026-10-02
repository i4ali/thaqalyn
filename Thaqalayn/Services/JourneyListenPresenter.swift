//
//  JourneyListenPresenter.swift
//  Thaqalayn
//
//  App-wide coordinator for the journey Listen experience: which journey is active,
//  whether the full-screen player or the docked mini-player is showing, and premium
//  gating. Every "Listen" entry routes through `requestListen`; the root (MainTabView)
//  hosts the full player, the mini-player, and the paywall from this single source of
//  truth, so narration stays controllable app-wide even after the full player is closed.
//
//  It also owns the narration language. A journey opens in the listener's preferred
//  language (their last choice in the player, else Urdu when the app's language is Urdu,
//  else English) when that language is recorded for it; `setLanguage` switches mid-journey
//  and carries on from the same beat.
//

import SwiftUI

@MainActor
final class JourneyListenPresenter: ObservableObject {
    static let shared = JourneyListenPresenter()
    private init() {}

    @Published var dive: DeepDive?          // the journey being listened to (nil = nothing active)
    /// The narration language of the active journey.
    @Published private(set) var language: CommentaryLanguage = .english
    @Published var expanded = false         // true = full-screen player; false + dive != nil = mini
    @Published var paywall: PaywallContext? // non-nil = show the paywall (locked tap)
    /// Non-nil while a premium journey's on-demand audio pack is being fetched before playback
    /// can start (the "Preparing this journey…" state); nil once it's ready or for bundled ones.
    @Published var preparing: Preparing?

    enum Preparing: Equatable {
        case downloading(progress: Double)  // ODR pack downloading; progress 0...1
        case failed                         // download failed - offer a retry
    }

    /// Free -> open the player; locked -> raise the paywall.
    func requestListen(_ dive: DeepDive, isFree: Bool, paywall context: PaywallContext) {
        if isFree { open(dive) } else { paywall = context }
    }

    /// Open the player on a journey, narrating in the listener's preferred language, or in
    /// `language` when given (e.g. a What's New card inviting them to listen in Urdu) and the
    /// journey is recorded in it.
    func open(_ dive: DeepDive, language requested: CommentaryLanguage? = nil) {
        // Reopening another journey: free the previous one's on-demand pack first.
        if let previous = self.dive, previous.id != dive.id {
            JourneyAudioAvailability.shared.release(journeyId: previous.id, language: language)
        }
        self.dive = dive
        if let requested, JourneyAudioAvailability.isAudioReady(dive.id, language: requested) {
            language = requested
        } else {
            language = Self.preferredLanguage(for: dive)
        }
        expanded = true
        preparing = nil
        start(dive)
    }

    /// Switch the active journey's narration language. Playback picks up at the start of the
    /// beat playing now, after the language's pack downloads if this is its first Listen. The
    /// choice is remembered for every journey.
    func setLanguage(_ newLanguage: CommentaryLanguage) {
        guard let dive, newLanguage != language,
              JourneyAudioAvailability.isAudioReady(dive.id, language: newLanguage) else { return }
        Self.chosenLanguage = newLanguage
        JourneyAudioPlayer.shared.stopForLanguageSwitch()
        JourneyAudioAvailability.shared.release(journeyId: dive.id, language: language)
        language = newLanguage
        preparing = nil
        start(dive)
    }

    /// Bundled narration (free journeys' English) plays immediately. Anything else first
    /// ensures its on-demand pack is on device (download-on-first-Listen, then cached),
    /// showing progress meanwhile. Playback resumes from the saved position.
    private func start(_ dive: DeepDive) {
        if JourneyAudioAvailability.isBundled(dive.id, language: language) {
            JourneyAudioPlayer.shared.play(dive: dive, language: language)
            return
        }
        startDownloadAndPlay(dive)
    }

    /// Fetch the active journey's ODR pack in the active language, then start playback. Guards
    /// against the user switching journey or language mid-download. On failure it parks in
    /// `.failed` for a retry.
    private func startDownloadAndPlay(_ dive: DeepDive) {
        preparing = .downloading(progress: 0)
        let id = dive.id, lang = language
        Task { [weak self] in
            let ok = await JourneyAudioAvailability.shared.ensureAvailable(journeyId: id, language: lang) { p in
                guard let self, self.dive?.id == id, self.language == lang else { return }
                if case .downloading = self.preparing { self.preparing = .downloading(progress: p) }
            }
            // The user moved on to another journey or language - drop this result.
            guard let self, self.dive?.id == id, self.language == lang else { return }
            if ok {
                self.preparing = nil
                JourneyAudioPlayer.shared.play(dive: dive, language: lang)
            } else {
                self.preparing = .failed
            }
        }
    }

    /// Retry a failed on-demand download for the active journey.
    func retryPreparing() { if let dive { startDownloadAndPlay(dive) } }

    // MARK: - Narration language preference

    private static let languageKey = "journeyNarrationLanguage"

    /// The language the listener last picked in the player, or nil before their first pick.
    private static var chosenLanguage: CommentaryLanguage? {
        get { UserDefaults.standard.string(forKey: languageKey).flatMap(CommentaryLanguage.init(rawValue:)) }
        set { UserDefaults.standard.set(newValue?.rawValue, forKey: languageKey) }
    }

    /// The language a journey opens in: the listener's last pick, else Urdu when the app's
    /// language is Urdu, else English - and English whenever the journey isn't recorded in it.
    static func preferredLanguage(for dive: DeepDive) -> CommentaryLanguage {
        let wanted = chosenLanguage
            ?? (CommentaryLanguageManager.shared.selectedLanguage == .urdu ? .urdu : .english)
        return JourneyAudioAvailability.isAudioReady(dive.id, language: wanted) ? wanted : .english
    }

    func minimize() { expanded = false }              // full -> mini (audio keeps playing)
    func expand()   { if dive != nil { expanded = true } }
    func close() {
        expanded = false
        preparing = nil
        if let id = dive?.id { JourneyAudioAvailability.shared.release(journeyId: id, language: language) }  // free the ODR hold
        dive = nil
        JourneyAudioPlayer.shared.stop()
    }
}
