//
//  DuaKaraokeEngine.swift
//  Thaqalayn
//
//  Drives the golden word highlight in SpecialDuaDetailView: follows
//  DuaStreamPlayer's playback clock through a dua's aligned word timeline
//  (SpecialDuaTimings) and publishes the word/segment being recited, only when
//  it changes, so segment rows re-render exactly at word boundaries. Also the
//  gate for tap-to-seek. Goes inert when another dua (or nothing) is playing,
//  and when the streamed file's duration no longer matches the recording the
//  alignment was made against (stale timings after a duas.org file swap).
//

import Foundation
import Combine

@MainActor
final class DuaKaraokeEngine: ObservableObject {
    @Published private(set) var currentWord: DuaWordPosition?
    @Published private(set) var currentSegment: Int?

    private(set) var timings: DuaTimings?
    private var duaID: String?
    private var durationMismatch = false
    private var cancellables = Set<AnyCancellable>()
    private let stream = DuaStreamPlayer.shared

    /// Streamed duration may differ slightly from the aligned file's (VBR
    /// estimation); beyond this the recording itself must have changed.
    private static let durationTolerance: TimeInterval = 5.0

    /// Bind the engine to one dua for the lifetime of its detail view.
    func configure(duaID: String) {
        guard self.duaID != duaID else { return }
        self.duaID = duaID
        self.timings = SpecialDuaTimingsStore.shared.timings(for: duaID)
        durationMismatch = false
        cancellables.removeAll()
        clear()
        guard timings != nil else { return }

        stream.$currentTime
            .sink { [weak self] time in self?.update(time: time) }
            .store(in: &cancellables)
        stream.$currentID
            .sink { [weak self] id in
                guard let self else { return }
                self.durationMismatch = false
                if id != self.duaID { self.clear() }
            }
            .store(in: &cancellables)
    }

    /// Whether tapping a segment may seek the stream there: this dua is the
    /// one loaded, its timings exist and match the streamed recording.
    var canSeek: Bool {
        timings != nil && stream.currentID == duaID && !durationMismatch
    }

    private func update(time: TimeInterval) {
        guard let timings, stream.currentID == duaID else {
            clear()
            return
        }
        if stream.duration > 0,
           abs(stream.duration - timings.audioDuration) > Self.durationTolerance {
            durationMismatch = true
        }
        guard !durationMismatch else {
            clear()
            return
        }
        let pos = timings.position(at: time)
        if pos != currentWord {
            currentWord = pos
            if pos?.segment != currentSegment { currentSegment = pos?.segment }
        }
    }

    private func clear() {
        if currentWord != nil { currentWord = nil }
        if currentSegment != nil { currentSegment = nil }
    }
}
