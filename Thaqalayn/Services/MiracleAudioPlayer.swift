//
//  MiracleAudioPlayer.swift
//  Thaqalayn
//
//  Recorded narration for Miracle Stories: one ElevenLabs clip per paragraph (English in
//  Bear, the Journey narrator; Urdu in Laksh, the dua voice), delivered as an On-Demand
//  Resources pack per story and language ("miracle-01-ur") that downloads on the first
//  Listen and stays cached for offline replay. Clips play back to back in an AVQueuePlayer;
//  because each clip is exactly one paragraph, `currentParagraphId` tells the reader which
//  paragraph to highlight and scroll to - no timing data needed.
//
//  Playback belongs to the story screen: the reader stops it on leaving the screen or
//  switching language. It keeps playing with the screen locked, with the story on the lock
//  screen and play/pause there. Starting it stops every other audio service, like theirs do.
//

import Foundation
import AVFoundation
import MediaPlayer
import UIKit

@MainActor
final class MiracleAudioPlayer: ObservableObject {
    static let shared = MiracleAudioPlayer()
    private init() {}

    enum Phase: Equatable {
        case idle
        case preparing(progress: Double)     // downloading the story's pack
        case playing
        case paused
        case failed                          // the pack could not be downloaded
    }

    @Published private(set) var phase: Phase = .idle
    /// The story and language loaded (nil = idle). Screens compare against their own.
    @Published private(set) var storyId: String?
    @Published private(set) var language: CommentaryLanguage?
    /// The paragraph being read ("body.3"), for the reader's highlight and follow-along.
    @Published private(set) var currentParagraphId: String?

    /// Packs whose every paragraph has a recording, from the bundled miracle_audio_ready.json
    /// (written by scripts/build_miracle_audio.py). Stories outside it fall back to TTS.
    static let readyTags: Set<String> = {
        guard let url = Bundle.main.url(forResource: "miracle_audio_ready", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let tags = try? JSONDecoder().decode([String].self, from: data) else { return [] }
        return Set(tags)
    }()

    static func hasRecording(_ story: MiracleStory, language: CommentaryLanguage) -> Bool {
        readyTags.contains(story.audioTag(for: language))
    }

    private var story: MiracleStory?
    private var tag: String?
    private var player: AVQueuePlayer?
    private var paragraphIds: [ObjectIdentifier: String] = [:]
    private var itemObservation: NSKeyValueObservation?
    private var preparing: Task<Void, Never>?
    private var remoteCommandsConfigured = false
    private static let coverImage = UIImage(named: "MiracleStoriesCover")

    func isCurrent(_ story: MiracleStory, language: CommentaryLanguage) -> Bool {
        storyId == story.id && self.language == language
    }

    // MARK: - Transport

    /// Listen / Pause / Resume / Retry for one story in one language.
    func toggle(_ story: MiracleStory, language: CommentaryLanguage) {
        if isCurrent(story, language: language) {
            switch phase {
            case .playing: pause(); return
            case .paused: resume(); return
            case .preparing: return
            case .idle, .failed: break
            }
        }
        start(story, language: language)
    }

    func pause() {
        guard phase == .playing else { return }
        player?.pause()
        phase = .paused
        updateNowPlayingRate()
    }

    func resume() {
        guard phase == .paused else { return }
        player?.play()
        phase = .playing
        updateNowPlayingRate()
    }

    func stop() {
        preparing?.cancel()
        preparing = nil
        itemObservation?.invalidate()
        itemObservation = nil
        player?.pause()
        player?.removeAllItems()
        player = nil
        paragraphIds = [:]
        if let tag { JourneyAudioAvailability.shared.release(journeyId: tag) }
        tag = nil
        story = nil
        storyId = nil
        language = nil
        currentParagraphId = nil
        phase = .idle
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    // MARK: - Internals

    private func start(_ story: MiracleStory, language: CommentaryLanguage) {
        stop()
        stopOthers()
        let tag = story.audioTag(for: language)
        self.story = story
        self.tag = tag
        storyId = story.id
        self.language = language
        phase = .preparing(progress: 0)

        preparing = Task { [weak self] in
            let ready = await JourneyAudioAvailability.shared.ensureAvailable(journeyId: tag) { progress in
                guard let self, self.tag == tag, case .preparing = self.phase else { return }
                self.phase = .preparing(progress: progress)
            }
            guard let self, !Task.isCancelled, self.tag == tag else { return }
            if ready {
                self.beginPlayback()
            } else {
                self.phase = .failed
            }
        }
    }

    private func beginPlayback() {
        guard let story, let language, let tag else { return }
        var items: [AVPlayerItem] = []
        var ids: [ObjectIdentifier: String] = [:]
        for paragraph in story.paragraphs(for: language) {
            // A missing clip is skipped rather than stalling the story.
            guard let url = JourneyAudioKey.recordingURL(for: paragraph.text, packSubdirectory: tag) else { continue }
            let item = AVPlayerItem(url: url)
            ids[ObjectIdentifier(item)] = paragraph.id
            items.append(item)
        }
        guard !items.isEmpty else {
            phase = .failed
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("MiracleAudioPlayer: audio session error \(error)")
            #endif
        }
        configureRemoteCommandsIfNeeded()
        UIApplication.shared.beginReceivingRemoteControlEvents()

        paragraphIds = ids
        let queue = AVQueuePlayer(items: items)
        player = queue
        itemObservation = queue.observe(\.currentItem, options: [.initial, .new]) { [weak self] queue, _ in
            let current = queue.currentItem.map(ObjectIdentifier.init)
            Task { @MainActor in
                guard let self, self.player === queue else { return }
                if let current {
                    self.currentParagraphId = self.paragraphIds[current]
                } else {
                    self.stop()                  // the last paragraph finished
                }
            }
        }
        queue.play()
        phase = .playing
        updateNowPlayingInfo()
    }

    private func stopOthers() {
        TafsirReader.shared.stop()
        DuaAudioPlayer.shared.stop()
        DuaStreamPlayer.shared.stop()
        AudioManager.shared.stop()
        JourneyListenPresenter.shared.close()
    }

    // MARK: - Lock screen

    private func updateNowPlayingInfo() {
        guard let story, let language else { return }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: story.title.text(for: language),
            MPMediaItemPropertyArtist: "Thaqalayn · Miracle Stories",
            MPNowPlayingInfoPropertyPlaybackRate: phase == .playing ? 1.0 : 0.0,
        ]
        if let image = Self.coverImage {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    private func updateNowPlayingRate() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyPlaybackRate] = phase == .playing ? 1.0 : 0.0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    /// Play/pause from the lock screen. Each handler returns `.commandFailed` when no story is
    /// playing, so it never hijacks the other players' sessions - the same coexistence pattern
    /// as JourneyAudioPlayer and DuaStreamPlayer.
    private func configureRemoteCommandsIfNeeded() {
        guard !remoteCommandsConfigured else { return }
        remoteCommandsConfigured = true
        let center = MPRemoteCommandCenter.shared()
        center.playCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.phase == .paused else { return .commandFailed }
                self.resume()
                return .success
            }
        }
        center.pauseCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.phase == .playing else { return .commandFailed }
                self.pause()
                return .success
            }
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self else { return .commandFailed }
                switch self.phase {
                case .playing: self.pause(); return .success
                case .paused: self.resume(); return .success
                default: return .commandFailed
                }
            }
        }
    }
}
