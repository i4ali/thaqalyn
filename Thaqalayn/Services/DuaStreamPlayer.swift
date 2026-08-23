//
//  DuaStreamPlayer.swift
//  Thaqalayn
//
//  Streams a remote dua/ziyarat recitation via AVPlayer (for the Duas & Ziyarat
//  library, whose long recitations are streamed rather than bundled). Mirrors
//  DuaAudioPlayer's Listen / Pause / Resume state and enforces single playback:
//  starting a stream cancels TTS, bundled dua audio, verse recitation, and journey
//  narration (and each of those cancels the stream in turn). Exposes buffering +
//  progress so the UI can show a loading state and a scrubbing bar for these longer
//  recitations. Playback persists across screens (like verse audio and journey
//  narration): the reader can navigate anywhere while the recitation continues, the
//  docked DuaMiniPlayer keeps the controls in reach, and the lock screen / Control
//  Center shows the recitation with play/pause/scrub transport.
//

import Foundation
import AVFoundation
import Combine
import MediaPlayer
import UIKit

@MainActor
final class DuaStreamPlayer: NSObject, ObservableObject {
    static let shared = DuaStreamPlayer()

    @Published var isPlaying = false
    @Published var isPaused = false
    /// True while the stream is buffering enough to begin/continue playback.
    @Published var isLoading = false
    /// Id of the dua currently loaded (nil = idle). Buttons compare their own id.
    @Published var currentID: String?
    /// The dua currently loaded (nil = idle) - drives the docked mini-player and the
    /// lock-screen now-playing metadata after the reader leaves the detail screen.
    @Published private(set) var currentDua: SpecialDua?
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    /// Set when the stream fails to load (e.g. no connection). Cleared on the next play.
    @Published var failed = false

    private var player: AVPlayer?
    private var timeObserver: Any?
    private var statusObs: NSKeyValueObservation?
    private var endObserver: NSObjectProtocol?

    /// Lock-screen transport is wired once, lazily, the first time a stream starts.
    private var remoteCommandsConfigured = false
    /// The library's cover art for the lock screen, loaded from the asset catalog at
    /// most once.
    private static let coverImage = UIImage(named: "DuasZiyaratCover")

    /// Start streaming a dua's recitation, or resume if it's the same dua paused.
    func play(dua: SpecialDua) {
        guard let url = dua.audioURL else { return }
        play(id: dua.id, url: url, dua: dua)
    }

    /// Start streaming `url` (identified by `id`), or resume if it's the same id paused.
    private func play(id: String, url: URL, dua: SpecialDua) {
        if currentID == id, isPaused, let player {          // resume this paused stream
            player.play(); isPlaying = true; isPaused = false
            updateNowPlayingProgress()
            return
        }
        if currentID == id, isPlaying { return }            // already playing this one

        stopOthers()                                        // mutual exclusion
        teardown()
        failed = false
        currentID = id
        currentDua = dua
        isLoading = true
        currentTime = 0
        duration = 0

        configureRemoteCommandsIfNeeded()
        UIApplication.shared.beginReceivingRemoteControlEvents()

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("DuaStreamPlayer: audio session error \(error)")
            #endif
        }

        let item = AVPlayerItem(url: url)
        let newPlayer = AVPlayer(playerItem: item)
        newPlayer.automaticallyWaitsToMinimizeStalling = true
        player = newPlayer

        statusObs = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                guard let self else { return }
                switch item.status {
                case .readyToPlay:
                    self.isLoading = false
                    let d = item.duration.seconds
                    if d.isFinite, d > 0 { self.duration = d }
                    self.updateNowPlayingProgress()          // real duration -> lock screen
                case .failed:
                    self.isLoading = false
                    self.failed = true
                    self.teardown()
                    self.reset()
                default:
                    break
                }
            }
        }

        // 0.15 s tick: fine enough for the karaoke word highlight to land on
        // word boundaries (words run ~0.3 s+), still trivial for the slider.
        timeObserver = newPlayer.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.15, preferredTimescale: 600), queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                guard let self else { return }
                self.currentTime = time.seconds.isFinite ? time.seconds : 0
                if self.duration == 0, let d = self.player?.currentItem?.duration.seconds, d.isFinite, d > 0 {
                    self.duration = d
                }
                // Buffering hint: if playing but time isn't advancing and buffer is empty.
                if self.isPlaying, let it = self.player?.currentItem {
                    self.isLoading = it.isPlaybackBufferEmpty && !it.isPlaybackLikelyToKeepUp
                }
                self.updateNowPlayingProgress()
            }
        }

        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in
            Task { @MainActor in self?.stop() }
        }

        newPlayer.play()
        isPlaying = true
        isPaused = false
        updateNowPlayingInfo()
    }

    func pause() {
        guard isPlaying else { return }
        player?.pause(); isPlaying = false; isPaused = true
        updateNowPlayingProgress()                // rate -> 0 on the lock screen
    }

    func resume() {
        guard isPaused else { return }
        player?.play(); isPlaying = true; isPaused = false
        updateNowPlayingProgress()
    }

    func togglePlayPause() {
        if isPlaying { pause() } else if isPaused { resume() }
    }

    func stop() {
        player?.pause()
        teardown()
        reset()
    }

    /// Seek to an absolute position (seconds).
    func seek(to seconds: TimeInterval) {
        guard let player, duration > 0 else { return }
        let clamped = max(0, min(seconds, duration))
        player.seek(to: CMTime(seconds: clamped, preferredTimescale: 600))
        currentTime = clamped
        updateNowPlayingProgress()                // move the lock-screen scrubber
    }

    // MARK: - Internals

    private func stopOthers() {
        TafsirReader.shared.stop()
        DuaAudioPlayer.shared.stop()
        AudioManager.shared.stop()                     // verse recitation
        // Ends the whole journey Listen session (narration + docked mini-player), so
        // the dua's own mini-player never stacks under a dead journey bar.
        JourneyListenPresenter.shared.close()
    }

    private func teardown() {
        if let timeObserver { player?.removeTimeObserver(timeObserver) }
        timeObserver = nil
        statusObs?.invalidate(); statusObs = nil
        if let endObserver { NotificationCenter.default.removeObserver(endObserver) }
        endObserver = nil
        player = nil
    }

    private func reset() {
        isPlaying = false
        isPaused = false
        isLoading = false
        currentID = nil
        currentDua = nil
        currentTime = 0
        duration = 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil   // clear the lock screen
    }

    // MARK: - Now Playing (Lock Screen / Control Center)

    /// Full now-playing refresh - title, reciter, cover artwork, and progress. Called
    /// once per play; the high-frequency tick only touches progress (see below).
    private func updateNowPlayingInfo() {
        guard let dua = currentDua else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: dua.titleEn,
            MPMediaItemPropertyArtist: dua.reciterEn.map { "Thaqalayn · \($0)" } ?? "Thaqalayn",
            MPMediaItemPropertyPlaybackDuration: duration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: currentTime,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? 1.0 : 0.0,
        ]
        if let image = Self.coverImage {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    /// Progress-only update - elapsed, duration, and rate on the existing info, leaving
    /// the title and artwork untouched so the cover is never re-sent every tick.
    private func updateNowPlayingProgress() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = currentTime
        info[MPMediaItemPropertyPlaybackDuration] = duration
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Remote commands (Lock Screen / Control Center)

    /// Wire the lock-screen / control-center transport to the stream. Runs once (the
    /// first time a stream starts). Each handler no-ops with `.commandFailed` when no
    /// dua is loaded, so it never hijacks the other audio services' now-playing
    /// session - the same coexistence pattern as JourneyAudioPlayer's handlers.
    private func configureRemoteCommandsIfNeeded() {
        guard !remoteCommandsConfigured else { return }
        remoteCommandsConfigured = true
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.currentID != nil else { return .commandFailed }
                self.resume()
                return .success
            }
        }
        center.pauseCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.currentID != nil else { return .commandFailed }
                self.pause()
                return .success
            }
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.currentID != nil else { return .commandFailed }
                self.togglePlayPause()
                return .success
            }
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            MainActor.assumeIsolated {
                guard let self, self.currentID != nil,
                      let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
                self.seek(to: event.positionTime)
                return .success
            }
        }
    }
}
