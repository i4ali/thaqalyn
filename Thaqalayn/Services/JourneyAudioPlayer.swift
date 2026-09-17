//
//  JourneyAudioPlayer.swift
//  Thaqalayn
//
//  Plays a whole journey's narration as ONE continuous timeline - English narrator
//  speech (bundled mp3), real Arabic recitation (verse reciter / captured dua), and
//  reflective pauses - stitched from `JourneyNarration.annotatedTimeline(for:)`.
//
//  The correctness-critical part is the PURE `buildPlaylist(for:)`: it turns the
//  beat-attributed timeline into an ordered list of PlayableClips with no I/O, so it is
//  unit-tested (JourneyPlaylistTests). Playback is a sequential coordinator around a
//  single AVPlayer - it streams remote verse URLs, plays bundled speech/dua files, times
//  the pauses, and skips clips whose audio is missing so a gap never stalls the journey.
//  The playback loop is verified on-device, so it need only be correct and readable here.
//
//  Only one narration plays at a time, and starting it stops the other audio services
//  (verse recitation, dua audio, TTS) - and starting those stops narration (reciprocal
//  `stop()` calls in AudioManager / DuaAudioPlayer / TafsirReader).
//

import Foundation
import AVFoundation
import MediaPlayer
import UIKit

/// One playable unit of a journey's continuous narration, tagged with the
/// `dive.sections` beatIndex it belongs to. Pure data - URLs are resolved at play time.
struct PlayableClip: Equatable {
    enum Source: Equatable {
        case speech(String)                 // -> JourneyAudioKey.recordingURL(for:)  (bundled narrator mp3)
        case verse(surah: Int, ayah: Int)   // -> reciter URL (streamed for now)
        case dua(String)                    // -> DuaAudioKey.recordingURL(for:)      (captured dua mp3)
        case pause(TimeInterval)            // -> silence
    }
    let source: Source
    let beatIndex: Int
}

@MainActor
final class JourneyAudioPlayer: ObservableObject {
    static let shared = JourneyAudioPlayer()

    // MARK: - Published state
    @Published private(set) var isPlaying: Bool = false
    @Published private(set) var currentBeatIndex: Int = 0
    /// Display name of the current beat (English), kept in sync with `currentBeatIndex` /
    /// `currentDive` - e.g. "The First Depth", "The Court", "He Answers". Drives the
    /// now-playing subtitle and is read by the Phase 3 narration UI.
    @Published private(set) var currentBeatTitle: String = ""
    /// Progress WITHIN the current clip (used internally for resume offsets, and as a
    /// fallback for the UI before the whole-journey durations resolve).
    @Published private(set) var currentTime: TimeInterval = 0
    @Published private(set) var duration: TimeInterval = 0
    /// The whole-journey timeline (all clips stitched into one): cumulative elapsed and the
    /// total length. `journeyDuration` is 0 until the clip durations resolve - the first
    /// play measures the streamed verses, then everything is cached - after which the Listen
    /// scrubber and mini-player track the entire journey rather than the current clip.
    @Published private(set) var journeyElapsed: TimeInterval = 0
    @Published private(set) var journeyDuration: TimeInterval = 0
    @Published private(set) var playbackRate: Float = 1.0
    /// Remaining time on the optional sleep timer, or nil when none is armed. Counts down
    /// once a second and calls `stop()` at zero; surfaced on the Listen screen. Mirrors the
    /// `AudioManager.sleepTimerTimeRemaining` pattern.
    @Published private(set) var sleepTimerTimeRemaining: TimeInterval?
    private(set) var currentDive: DeepDive?

    // MARK: - Playback internals (a sequential coordinator; tuned on-device)
    private let player = AVPlayer()
    private var clips: [PlayableClip] = []
    private var index: Int = 0
    /// Per-clip durations aligned to `clips`, and their prefix start offsets in the whole
    /// journey - the map between clip-local time and journey-global time. Empty until the
    /// async duration resolve completes (see `resolveJourneyDurations`).
    private var clipDurations: [TimeInterval] = []
    private var clipStarts: [TimeInterval] = []
    private var durationsResolved = false
    private var endObserver: NSObjectProtocol?
    private var failObserver: NSObjectProtocol?
    private var statusObserver: NSKeyValueObservation?
    private var timeObserver: Any?
    /// The next audio clip, warmed ahead of time so speech -> recitation transitions don't gap.
    private var preloaded: (clipIndex: Int, asset: AVURLAsset)?
    /// A one-shot seek applied when the resumed clip becomes ready - the offset saved on the
    /// listener's last exit. Tied to a clip index so it never leaks onto a later clip.
    private var pendingResumeSeek: (clipIndex: Int, offset: TimeInterval)?
    /// True once the timeline ran to the end (finish cleared the saved position). It blocks a
    /// late `stop()` from re-saving the final beat, so a completed journey reopens at the top.
    private var didFinish = false
    /// A `.pause` clip is a timed gap, not audio - this is its pending advance.
    private var pauseWork: DispatchWorkItem?
    private var pauseDeadline: Date?
    private var pauseRemaining: TimeInterval?

    // MARK: - Lock screen / Control Center
    /// Lock-screen transport is wired once, lazily, the first time narration starts.
    private var remoteCommandsConfigured = false
    /// Cover `UIImage` cache, keyed by `dive.id`, so the asset catalog is hit at most once
    /// per dive and never on the now-playing hot path.
    private var coverImageCache: [String: UIImage] = [:]

    private init() {
        player.actionAtItemEnd = .pause
        addTimeObserver()
    }

    // MARK: - Pure seam (unit-tested)

    /// Turn a whole dive into its ordered clip list. No I/O, no Bundle access - the
    /// beat-attributed timeline mapped 1:1 onto PlayableClips. This is the tested seam,
    /// `nonisolated` so it's callable off the main actor (unit tests, background prep).
    nonisolated static func buildPlaylist(for dive: DeepDive) -> [PlayableClip] {
        JourneyNarration.annotatedTimeline(for: dive).map { a in
            let src: PlayableClip.Source
            switch a.segment {
            case .speech(let t): src = .speech(t)
            case .recitation(.verse(let s, let ay)): src = .verse(surah: s, ayah: ay)
            case .recitation(.dua(let ar)): src = .dua(ar)
            case .pause(let d): src = .pause(d)
            }
            return PlayableClip(source: src, beatIndex: a.beatIndex)
        }
    }

    /// Remote reciter URL for a verse (default reciter Yasser Al-Dosari, everyayah). The first
    /// play streams this; `VerseAudioCache` saves it to disk so later plays (and offline replay)
    /// read the local copy - see `url(for:)`.
    nonisolated static func verseURL(surah: Int, ayah: Int) -> URL? {
        let s = String(format: "%03d", surah)
        let a = String(format: "%03d", ayah)
        return URL(string: "https://www.everyayah.com/data/Yasser_Ad-Dussary_128kbps/\(s)\(a).mp3")
    }

    /// A short English display name for a beat, mapped from its section family: the
    /// section's `tag` where it carries one (verse/depths/narration/climax/refrain, the
    /// reflection prompt, the interactive closes, dua, closing), with sensible fallbacks
    /// for the cases that don't - the opening title, the orientation eyebrow, the movement
    /// name, and the fixed "He Answers" of a call-and-response reply. Pure, so the player
    /// and the Phase 3 UI compute it the same way. English-only (the audio journey is EN).
    nonisolated static func beatTitle(for section: DeepDiveSection, in dive: DeepDive) -> String {
        // A tag's English text, falling back to the dive title when it is empty.
        func tagged(_ tag: LocalizedText) -> String {
            let s = tag.text
            return s.isEmpty ? dive.titleEn : s
        }
        switch section {
        case let .open(_, _, titleEn, _, _):
            return titleEn.isEmpty ? "Opening" : titleEn
        case let .orientation(eyebrow, _, _):
            let s = eyebrow.text
            return s.isEmpty ? "Before you begin" : s
        case let .act(act, _, _, _):
            let name = dive.actInfo(act)?.name.text ?? ""
            return name.isEmpty ? "Movement" : name
        case .response:
            return "He Answers"                                          // no tag; matches the beat's header
        case let .verse(_, tag, _, _, _, _, _, _):                        return tagged(tag)
        case let .depths(_, tag, _, _):                                   return tagged(tag)
        case let .narration(_, tag, _, _, _):                             return tagged(tag)
        case let .climax(_, tag, _, _, _, _, _):                          return tagged(tag)
        case let .refrain(_, tag, _, _, _, _, _, _, _, _, _, _, _):       return tagged(tag)
        case let .reflectionPrompt(tag, _, _, _, _):                      return tagged(tag)
        case let .release(tag, _, _, _, _, _, _, _):                      return tagged(tag)
        case let .count(tag, _, _, _, _, _, _, _):                        return tagged(tag)
        case let .sujud(tag, _, _, _, _, _, _, _):                        return tagged(tag)
        case let .extinguish(tag, _, _, _, _, _, _, _):                   return tagged(tag)
        case let .door(tag, _, _, _, _, _, _, _):                         return tagged(tag)
        case let .salawat(tag, _, _, _, _, _, _, _):                      return tagged(tag)
        case let .dua(tag, _, _, _, _, _, _):                             return tagged(tag)
        case let .closing(tag, _, _, _):                                  return tagged(tag)
        }
    }

    // MARK: - Transport

    /// Start a dive's narration. By default it resumes where the listener left off (the
    /// saved beat, best-effort into the clip); pass `restart: true` to force a fresh start
    /// from the top. A stale/out-of-range saved beat (content changed) falls back to 0.
    func play(dive: DeepDive, restart: Bool = false) {
        // Mutual exclusion: narration and the other audio services never overlap.
        TafsirReader.shared.stop()
        DuaAudioPlayer.shared.stop()
        DuaStreamPlayer.shared.stop()                    // mutual exclusion with streamed recitation
        AudioManager.shared.stop()

        configureSession()
        configureRemoteCommandsIfNeeded()
        UIApplication.shared.beginReceivingRemoteControlEvents()

        currentDive = dive
        clips = Self.buildPlaylist(for: dive)
        resolveJourneyDurations()          // async: fills the whole-journey timeline (cached after first play)
        preloaded = nil
        didFinish = false

        // Resume from the saved position unless asked to restart. `resumeStart` returns the
        // first clip of the saved beat (+ offset), or nil to start at 0.
        let start = restart ? nil : resumeStart(for: dive)
        index = start?.clipIndex ?? 0
        pendingResumeSeek = start.map { (clipIndex: $0.clipIndex, offset: $0.offset) }
        currentBeatIndex = clips.indices.contains(index) ? clips[index].beatIndex : 0
        isPlaying = true
        playClip(at: index)   // sets the beat title + full now-playing info (incl. artwork)
    }

    func pause() {
        guard isPlaying else { return }
        isPlaying = false
        if let work = pauseWork {                 // paused mid reflective-gap
            work.cancel()
            pauseWork = nil
            if let deadline = pauseDeadline { pauseRemaining = max(0, deadline.timeIntervalSinceNow) }
        } else {
            player.pause()
        }
        updateNowPlayingProgress()                // rate -> 0 on the lock screen
        saveResumePosition()                      // remember where we paused
    }

    func resume() {
        guard !isPlaying, currentDive != nil, !clips.isEmpty else { return }
        isPlaying = true
        if let remaining = pauseRemaining {       // finish out the interrupted gap
            pauseRemaining = nil
            schedulePause(after: remaining)
        } else {
            player.rate = playbackRate
        }
        updateNowPlayingProgress()                // rate -> playbackRate on the lock screen
    }

    func togglePlayPause() {
        if isPlaying { pause() } else { resume() }
    }

    func stop() {
        let wasActive = isPlaying || player.currentItem != nil
        saveResumePosition()                      // capture position before we tear down state
        cancelPause()
        stopSleepTimer()                          // clear any armed sleep timer
        pauseRemaining = nil
        clearItemObservers()
        player.pause()
        player.replaceCurrentItem(with: nil)
        preloaded = nil
        pendingResumeSeek = nil
        didFinish = false
        isPlaying = false
        currentTime = 0
        duration = 0
        journeyElapsed = 0
        journeyDuration = 0
        clipDurations = []
        clipStarts = []
        durationsResolved = false
        clips = []
        index = 0
        currentBeatIndex = 0
        currentBeatTitle = ""
        currentDive = nil
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil   // clear the lock screen
        if wasActive { deactivateSession() }      // only release the session we were using
    }

    /// Jump to the first clip of the next distinct beatIndex.
    func nextBeat() {
        guard !clips.isEmpty, let j = clips.firstIndex(where: { $0.beatIndex > currentBeatIndex }) else { return }
        restart(at: j)
    }

    /// Jump to the first clip of the previous distinct beatIndex (or restart the current
    /// beat when there is no earlier one).
    func previousBeat() {
        guard !clips.isEmpty else { return }
        let prev = clips.map { $0.beatIndex }.filter { $0 < currentBeatIndex }.max() ?? currentBeatIndex
        guard let j = clips.firstIndex(where: { $0.beatIndex == prev }) else { return }
        restart(at: j)
    }

    /// Seek within the current audio clip (reflective pauses are not seekable).
    func seek(to time: TimeInterval) {
        let t = max(0, time)
        player.seek(to: CMTime(seconds: t, preferredTimescale: 600))
        currentTime = t
        updateJourneyElapsed()
        updateNowPlayingProgress()                // move the lock-screen scrubber
    }

    // MARK: - Whole-journey timeline (all clips stitched into one seekable track)

    /// Measure every clip's length (cached; only the first play of new material touches the
    /// network, for streamed verses), then publish the total and the prefix start offsets so
    /// the UI can show a whole-journey scrubber. Runs async; until it lands, `journeyDuration`
    /// stays 0 and the UI falls back to the per-clip readout.
    private func resolveJourneyDurations() {
        durationsResolved = false
        clipDurations = []
        clipStarts = []
        journeyDuration = 0
        journeyElapsed = 0
        let snapshot = clips
        guard !snapshot.isEmpty else { return }
        Task { [weak self] in
            guard let self else { return }
            let durs = await JourneyDurationStore.shared.resolveDurations(for: snapshot) { source in
                self.url(for: source)
            }
            guard self.clips == snapshot else { return }   // a different journey started meanwhile
            self.clipDurations = durs
            var starts = [TimeInterval](); starts.reserveCapacity(durs.count)
            var acc: TimeInterval = 0
            for d in durs { starts.append(acc); acc += d }
            self.clipStarts = starts
            self.journeyDuration = acc
            self.durationsResolved = true
            self.updateJourneyElapsed()
            self.updateNowPlayingInfo()            // refresh the lock screen with the real total
        }
    }

    /// Recompute cumulative elapsed = (this clip's start in the journey) + (offset into it).
    /// Before durations resolve, falls back to the clip-local time so the readout isn't blank.
    private func updateJourneyElapsed() {
        guard durationsResolved, clipStarts.indices.contains(index) else {
            journeyElapsed = currentTime
            return
        }
        journeyElapsed = clipStarts[index] + max(0, currentTime)
    }

    /// Seek to an absolute position on the whole-journey timeline, mapping it to the right
    /// clip + in-clip offset and preserving play/pause state. Falls back to a clip-local seek
    /// until the durations have resolved.
    func seekJourney(to globalTime: TimeInterval) {
        guard durationsResolved, journeyDuration > 0,
              clipStarts.count == clips.count, !clips.isEmpty else {
            seek(to: globalTime)
            return
        }
        let t = max(0, min(globalTime, journeyDuration))
        // Target clip = the last whose start offset is <= t.
        var k = clips.count - 1
        for i in clips.indices where clipStarts[i] > t { k = i - 1; break }
        k = max(0, k)
        let offset = t - clipStarts[k]
        let wasPlaying = isPlaying

        if case .pause = clips[k].source {
            restart(at: k)                          // into a reflective gap: restart it (<=~1s slack)
        } else if k == index, player.currentItem != nil {
            seek(to: offset)                        // same audio clip: precise in-clip seek
        } else {
            pendingResumeSeek = (clipIndex: k, offset: offset)
            restart(at: k)                          // jump to clip k; offset applied when it's ready
        }
        if !wasPlaying { pause() }                  // a seek must not start playback that was paused
        journeyElapsed = t                          // reflect the target immediately
        updateNowPlayingProgress()
    }

    /// Set the narrator playback rate (1.0 / 1.25 / 1.5). Applied live to the current clip.
    func setRate(_ rate: Float) {
        playbackRate = rate
        player.currentItem?.audioTimePitchAlgorithm = .timeDomain   // keep the voice natural above 1x
        if isPlaying, pauseWork == nil { player.rate = rate }
        updateNowPlayingProgress()                // reflect the new rate on the lock screen
    }

    // MARK: - Sequential coordinator (device-tuned)

    private func restart(at i: Int) {
        cancelPause()
        pauseRemaining = nil
        isPlaying = true
        playClip(at: i)
    }

    /// Play the clip at `i`, advancing `currentBeatIndex`. A clip whose audio URL doesn't
    /// resolve is skipped so a gap in the recording pack never stalls the journey; a
    /// `.pause` is a timed gap between items.
    private func playClip(at i: Int) {
        clearItemObservers()
        cancelPause()

        guard i < clips.count else { finish(); return }
        index = i
        // A resume seek belongs to exactly one clip; drop it the moment we play any other.
        if let p = pendingResumeSeek, p.clipIndex != i { pendingResumeSeek = nil }
        let clip = clips[i]
        let beatChanged = clip.beatIndex != currentBeatIndex
        currentBeatIndex = clip.beatIndex
        refreshCurrentBeatTitle()

        switch clip.source {
        case .pause(let d):
            duration = d
            currentTime = 0
            schedulePause(after: d)
            updateNowPlayingInfo()               // beat/clip change: full refresh incl. artwork

        case .speech, .verse, .dua:
            guard let url = url(for: clip.source) else { advance(); return }   // skip missing gracefully
            let asset = (preloaded?.clipIndex == i ? preloaded?.asset : nil) ?? AVURLAsset(url: url)
            preloaded = nil
            let item = AVPlayerItem(asset: asset)
            item.audioTimePitchAlgorithm = .timeDomain
            observe(item)
            player.replaceCurrentItem(with: item)
            currentTime = 0
            duration = 0
            player.rate = playbackRate           // a non-zero rate starts playback
            preloadNextAudio(after: i)
            updateNowPlayingInfo()               // beat/clip change: full refresh incl. artwork
        }

        updateJourneyElapsed()                   // snap the whole-journey clock to this clip's start
        if beatChanged { saveResumePosition() }  // beat-granular checkpoint (offset now 0)
    }

    private func advance() { playClip(at: index + 1) }

    /// End of the timeline: settle into a stopped-but-loaded state (a replay just calls play again).
    private func finish() {
        if let dive = currentDive { JourneyResumeStore.clear(for: dive.id) }   // finished -> next open starts fresh
        didFinish = true                                                       // block a late stop() from re-saving the end
        pendingResumeSeek = nil
        clearItemObservers()
        player.replaceCurrentItem(with: nil)
        preloaded = nil
        isPlaying = false
    }

    /// Warm the asset of the next audio clip (skipping pauses / missing recordings) so its
    /// AVPlayerItem is ready the moment the current clip ends.
    private func preloadNextAudio(after i: Int) {
        var j = i + 1
        while j < clips.count {
            if case .pause = clips[j].source { j += 1; continue }
            guard let url = url(for: clips[j].source) else { j += 1; continue }
            let asset = AVURLAsset(url: url)
            preloaded = (j, asset)
            Task { _ = try? await asset.load(.isPlayable) }
            return
        }
        preloaded = nil
    }

    // MARK: - Resume (persisted position, best-effort)

    /// Persist where the listener is now (current beat + offset into the current clip) for
    /// the active dive, so reopening this journey resumes here. Cheap; called at the beat
    /// checkpoints, on pause, and on stop. No-op when no dive is active.
    private func saveResumePosition() {
        guard let dive = currentDive, !didFinish else { return }
        JourneyResumeStore.save(
            JourneyResumePosition(beatIndex: currentBeatIndex, offset: currentTime),
            for: dive.id
        )
    }

    /// Resolve a dive's saved position into a concrete start clip: the FIRST clip of the
    /// saved beat, plus the offset to seek into it. Returns nil (start at 0) when nothing is
    /// saved or the saved beat is no longer present in the current content (stale/out of range).
    private func resumeStart(for dive: DeepDive) -> (clipIndex: Int, offset: TimeInterval)? {
        guard let saved = JourneyResumeStore.load(for: dive.id),
              let clipIndex = clips.firstIndex(where: { $0.beatIndex == saved.beatIndex })
        else { return nil }
        return (clipIndex, saved.offset)
    }

    /// Once the resumed clip is ready, seek to the saved offset - at most once, and only for
    /// the exact clip we resumed into. Bounded to the clip so a stale offset can't overrun it.
    private func applyPendingResumeSeek() {
        guard let pending = pendingResumeSeek, pending.clipIndex == index else { return }
        pendingResumeSeek = nil
        guard pending.offset > 0 else { return }
        if let d = player.currentItem?.duration.seconds, d.isFinite, d > 0 {
            seek(to: min(pending.offset, max(0, d - 0.5)))
        } else {
            seek(to: pending.offset)
        }
    }

    // MARK: - URL resolution (at play time, never in buildPlaylist)

    private func url(for source: PlayableClip.Source) -> URL? {
        switch source {
        case .speech(let text):
            // Bundled free journeys resolve flat; a premium journey's narration resolves from
            // its downloaded ODR pack (subdirectory named for the journey id).
            return JourneyAudioKey.recordingURL(for: text, packSubdirectory: currentDive?.id)
        case .dua(let arabic):      return DuaAudioKey.recordingURL(for: arabic)
        case .verse(let s, let ay):
            // Prefer the on-disk copy (offline, and after relaunch); otherwise stream the
            // remote once and cache it in the background so the next play - and any offline
            // replay - reads it locally.
            if let cached = VerseAudioCache.shared.cachedURL(surah: s, ayah: ay) { return cached }
            guard let remote = Self.verseURL(surah: s, ayah: ay) else { return nil }
            VerseAudioCache.shared.ensureCached(surah: s, ayah: ay, remote: remote)
            return remote
        case .pause:                return nil
        }
    }

    // MARK: - Reflective pauses (timed gaps, no audio)

    private func schedulePause(after seconds: TimeInterval) {
        pauseDeadline = Date().addingTimeInterval(seconds)
        let work = DispatchWorkItem { [weak self] in
            guard let self else { return }
            self.pauseWork = nil
            self.pauseDeadline = nil
            self.advance()
        }
        pauseWork = work
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: work)
    }

    private func cancelPause() {
        pauseWork?.cancel()
        pauseWork = nil
        pauseDeadline = nil
    }

    // MARK: - Item observers (advance on end; never stall on a failed load)

    private func observe(_ item: AVPlayerItem) {
        endObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in Task { @MainActor in self?.advance() } }
        failObserver = NotificationCenter.default.addObserver(
            forName: .AVPlayerItemFailedToPlayToEndTime, object: item, queue: .main
        ) { [weak self] _ in Task { @MainActor in self?.advance() } }
        // A verse that 404s (or a corrupt file) never plays to end - skip on failure. When a
        // clip becomes ready, apply any pending resume seek (best-effort, one clip only).
        statusObserver = item.observe(\.status) { [weak self] item, _ in
            switch item.status {
            case .failed:      Task { @MainActor in self?.advance() }
            case .readyToPlay: Task { @MainActor in self?.applyPendingResumeSeek() }
            default:           break
            }
        }
    }

    private func clearItemObservers() {
        if let o = endObserver { NotificationCenter.default.removeObserver(o); endObserver = nil }
        if let o = failObserver { NotificationCenter.default.removeObserver(o); failObserver = nil }
        statusObserver?.invalidate(); statusObserver = nil
    }

    // MARK: - Time observer (publishes progress within the current audio clip)

    private func addTimeObserver() {
        timeObserver = player.addPeriodicTimeObserver(
            forInterval: CMTime(seconds: 0.2, preferredTimescale: 600), queue: .main
        ) { [weak self] time in
            Task { @MainActor in
                guard let self, self.pauseWork == nil else { return }
                self.currentTime = time.seconds
                if let d = self.player.currentItem?.duration.seconds, d.isFinite { self.duration = d }
                self.updateJourneyElapsed()      // advance the whole-journey clock
                self.updateNowPlayingProgress()  // elapsed/duration only - artwork stays out of the tick
            }
        }
    }

    // MARK: - Current beat title

    /// Recompute `currentBeatTitle` from the live dive + beat index. Called wherever the
    /// beat changes (playClip); cleared to empty when there is no active dive.
    private func refreshCurrentBeatTitle() {
        guard let dive = currentDive, dive.sections.indices.contains(currentBeatIndex) else {
            currentBeatTitle = ""
            return
        }
        currentBeatTitle = Self.beatTitle(for: dive.sections[currentBeatIndex], in: dive)
    }

    // MARK: - Now Playing (Lock Screen / Control Center)

    /// The dive's cover `UIImage`, matched by `dive.id` across both experience catalogs and
    /// cached so the asset catalog is read at most once per dive. Nil when a dive has no
    /// cover (every shipped dive has one, so this is only a safety fallback).
    private func coverImage(for dive: DeepDive) -> UIImage? {
        if let cached = coverImageCache[dive.id] { return cached }
        let assetName = DeepDiveDescriptor.all.first { $0.dive?.id == dive.id }?.coverAssetName
            ?? SurahExperienceDescriptor.all.first { $0.dive?.id == dive.id }?.coverAssetName
        guard let assetName, let image = UIImage(named: assetName) else { return nil }
        coverImageCache[dive.id] = image
        return image
    }

    /// Lock-screen duration/elapsed: the whole journey once resolved, else the current clip.
    private var nowPlayingDuration: TimeInterval { journeyDuration > 0 ? journeyDuration : duration }
    private var nowPlayingElapsed: TimeInterval { journeyDuration > 0 ? journeyElapsed : currentTime }

    /// Full now-playing refresh - title, current beat, cover artwork, and progress. Called
    /// on play and every beat/clip change only; the artwork is deliberately kept off the
    /// 0.2s tick (see `updateNowPlayingProgress`).
    private func updateNowPlayingInfo() {
        guard let dive = currentDive else {
            MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
            return
        }
        var info: [String: Any] = [
            MPMediaItemPropertyTitle: dive.titleEn,
            MPMediaItemPropertyArtist: "Thaqalayn · \(currentBeatTitle)",
            MPMediaItemPropertyPlaybackDuration: nowPlayingDuration,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: nowPlayingElapsed,
            MPNowPlayingInfoPropertyPlaybackRate: isPlaying ? playbackRate : 0,
        ]
        if let image = coverImage(for: dive) {
            info[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(boundsSize: image.size) { _ in image }
        }
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    /// Progress-only update - elapsed, duration, and rate on the existing info, leaving the
    /// title and artwork untouched. Used by the high-frequency tick and the transport
    /// toggles (pause/resume/seek/setRate) so the cover is never re-sent every tick.
    private func updateNowPlayingProgress() {
        guard var info = MPNowPlayingInfoCenter.default().nowPlayingInfo else { return }
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = nowPlayingElapsed
        info[MPMediaItemPropertyPlaybackDuration] = nowPlayingDuration
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? playbackRate : 0
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    // MARK: - Remote commands (Lock Screen / Control Center)

    /// Wire the lock-screen / control-center transport to the player's methods. Runs once
    /// (the first time narration starts). Each handler no-ops with `.commandFailed` when no
    /// dive is active, so it never hijacks the other audio services' now-playing session.
    /// Handlers are delivered on the main thread, so `MainActor.assumeIsolated` lets them
    /// touch main-actor state and report an accurate status synchronously.
    private func configureRemoteCommandsIfNeeded() {
        guard !remoteCommandsConfigured else { return }
        remoteCommandsConfigured = true
        let center = MPRemoteCommandCenter.shared()

        center.playCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.currentDive != nil else { return .commandFailed }
                self.resume()
                return .success
            }
        }
        center.pauseCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.currentDive != nil else { return .commandFailed }
                self.pause()
                return .success
            }
        }
        center.togglePlayPauseCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.currentDive != nil else { return .commandFailed }
                self.togglePlayPause()
                return .success
            }
        }
        center.nextTrackCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.currentDive != nil else { return .commandFailed }
                self.nextBeat()
                return .success
            }
        }
        center.previousTrackCommand.addTarget { [weak self] _ in
            MainActor.assumeIsolated {
                guard let self, self.currentDive != nil else { return .commandFailed }
                self.previousBeat()
                return .success
            }
        }
        center.changePlaybackPositionCommand.addTarget { [weak self] event in
            MainActor.assumeIsolated {
                guard let self, self.currentDive != nil,
                      let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
                self.seekJourney(to: event.positionTime)
                return .success
            }
        }

        let commands: [MPRemoteCommand] = [
            center.playCommand, center.pauseCommand, center.togglePlayPauseCommand,
            center.nextTrackCommand, center.previousTrackCommand, center.changePlaybackPositionCommand,
        ]
        commands.forEach { $0.isEnabled = true }
    }

    // MARK: - Sleep timer (optional auto-stop)

    /// The repeating 1s countdown; nil when no timer is armed.
    private var sleepTimer: Timer?

    /// Arm (or clear) a sleep timer. A non-nil duration stops narration when it elapses;
    /// nil cancels any running timer. Mirrors `AudioManager.setSleepTimer(_:)`, without the
    /// persisted configuration - the journey player keeps no saved config. `.endOfSurah`
    /// (no interval) is simply ignored here; the Listen UI offers only the timed options.
    func setSleepTimer(_ duration: SleepTimerDuration?) {
        stopSleepTimer()
        guard let seconds = duration?.timeInterval else { return }
        sleepTimerTimeRemaining = seconds
        sleepTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self, let remaining = self.sleepTimerTimeRemaining else { return }
                if remaining <= 1 {
                    self.stop()                       // clears the timer via stopSleepTimer()
                } else {
                    self.sleepTimerTimeRemaining = remaining - 1
                }
            }
        }
    }

    private func stopSleepTimer() {
        sleepTimer?.invalidate()
        sleepTimer = nil
        sleepTimerTimeRemaining = nil
    }

    // MARK: - Session

    private func configureSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .spokenAudio)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            #if DEBUG
            print("JourneyAudioPlayer: session setup failed: \(error)")
            #endif
        }
    }

    private func deactivateSession() {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
    }
}
