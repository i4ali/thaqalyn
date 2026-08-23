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

import SwiftUI

@MainActor
final class JourneyListenPresenter: ObservableObject {
    static let shared = JourneyListenPresenter()
    private init() {}

    @Published var dive: DeepDive?          // the journey being listened to (nil = nothing active)
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

    func open(_ dive: DeepDive) {
        self.dive = dive
        expanded = true
        preparing = nil

        // Bundled free journeys play immediately. A premium journey first ensures its on-demand
        // pack is on device (download-on-first-Listen, then cached), showing progress meanwhile.
        if JourneyAudioAvailability.isBundled(dive.id) {
            JourneyAudioPlayer.shared.play(dive: dive)   // resumes from saved position
            return
        }
        startDownloadAndPlay(dive)
    }

    /// Fetch a premium journey's ODR pack, then start playback. Guards against the user
    /// switching journeys mid-download. On failure it parks in `.failed` for a retry.
    private func startDownloadAndPlay(_ dive: DeepDive) {
        preparing = .downloading(progress: 0)
        let id = dive.id
        Task { [weak self] in
            let ok = await JourneyAudioAvailability.shared.ensureAvailable(journeyId: id) { p in
                guard let self, self.dive?.id == id else { return }
                if case .downloading = self.preparing { self.preparing = .downloading(progress: p) }
            }
            guard let self, self.dive?.id == id else { return }  // user moved on - drop this result
            if ok {
                self.preparing = nil
                JourneyAudioPlayer.shared.play(dive: dive)
            } else {
                self.preparing = .failed
            }
        }
    }

    /// Retry a failed on-demand download for the active journey.
    func retryPreparing() { if let dive { startDownloadAndPlay(dive) } }

    func minimize() { expanded = false }              // full -> mini (audio keeps playing)
    func expand()   { if dive != nil { expanded = true } }
    func close() {
        expanded = false
        preparing = nil
        if let id = dive?.id { JourneyAudioAvailability.shared.release(journeyId: id) }  // free the ODR hold
        dive = nil
        JourneyAudioPlayer.shared.stop()
    }
}
