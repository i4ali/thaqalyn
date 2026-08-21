//
//  DuaAudioPlayer.swift
//  Thaqalayn
//
//  Plays a bundled dua/ziyarat recitation via AVAudioPlayer. Mirrors TafsirReader's
//  Listen / Pause / Resume state so DuaListenButton can drive its UI identically
//  whether a dua has a real recording or falls back to TTS. Only one dua plays at a
//  time; starting playback cancels any TTS in progress (and vice versa).
//

import Foundation
import AVFoundation

@MainActor
final class DuaAudioPlayer: NSObject, ObservableObject {
    static let shared = DuaAudioPlayer()

    @Published var isPlaying = false
    @Published var isPaused = false
    /// Key of the recording currently loaded (nil = idle). Buttons compare their own key.
    @Published var currentKey: String?

    private var player: AVAudioPlayer?

    /// Start playback of `url` (identified by `key`), or resume if it's the same key paused.
    func play(key: String, url: URL) {
        TafsirReader.shared.stop()                       // mutual exclusion with TTS
        if currentKey == key, let p = player, isPaused {
            p.play(); isPlaying = true; isPaused = false; return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
            let p = try AVAudioPlayer(contentsOf: url)
            p.delegate = self
            p.prepareToPlay()
            p.play()
            player = p
            currentKey = key
            isPlaying = true
            isPaused = false
        } catch {
            #if DEBUG
            print("DuaAudioPlayer: failed to play \(key): \(error)")
            #endif
            reset()
        }
    }

    func pause() {
        guard isPlaying else { return }
        player?.pause(); isPlaying = false; isPaused = true
    }

    func resume() {
        guard isPaused else { return }
        player?.play(); isPlaying = true; isPaused = false
    }

    func stop() {
        player?.stop(); player = nil; reset()
    }

    func togglePlayPause() {
        if isPlaying { pause() } else if isPaused { resume() }
    }

    private func reset() {
        isPlaying = false; isPaused = false; currentKey = nil
    }
}

extension DuaAudioPlayer: AVAudioPlayerDelegate {
    nonisolated func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        Task { @MainActor in
            self.player = nil
            self.reset()
        }
    }
}
