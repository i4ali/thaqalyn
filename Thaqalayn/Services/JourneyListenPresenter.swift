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

    /// Free -> open the player; locked -> raise the paywall.
    func requestListen(_ dive: DeepDive, isFree: Bool, paywall context: PaywallContext) {
        if isFree { open(dive) } else { paywall = context }
    }

    func open(_ dive: DeepDive) {
        self.dive = dive
        expanded = true
        JourneyAudioPlayer.shared.play(dive: dive)   // resumes from saved position
    }

    func minimize() { expanded = false }              // full -> mini (audio keeps playing)
    func expand()   { if dive != nil { expanded = true } }
    func close()    { expanded = false; dive = nil; JourneyAudioPlayer.shared.stop() }
}
