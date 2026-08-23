//
//  VerseAudioCache.swift
//  Thaqalayn
//
//  On-disk cache for the Qur'an verse recitations woven into a narrated journey (Phase 4.3).
//  A journey streams a verse from everyayah.com the first time it's heard; this cache saves
//  that mp3 to disk (keyed by surah:ayah), so every later play - offline, and after the app
//  relaunches - reads the local file instead of the network. The narrator speech and dua
//  clips are already on disk (bundled); the verse recitation was the one streamed piece, so
//  this is what lets a bundled free journey (Yaqin, al-Fatiha) replay fully offline.
//
//  Files live in Application Support (persistent, unlike the OS-purgeable Caches dir) and are
//  excluded from iCloud backup - a verse is always re-downloadable, so it should never bloat
//  a backup. A missing download is never fatal: the player falls back to streaming the remote,
//  so a flaky network just means "no offline copy yet", not broken playback.
//

import Foundation

final class VerseAudioCache {
    static let shared = VerseAudioCache()

    private let dir: URL
    /// surah:ayah keys currently downloading, so a burst of lookups (duration measure + play +
    /// preload all resolve the same verse) fetches it once. Guarded by `lock`.
    private var inFlight: Set<String> = []
    private let lock = NSLock()

    /// Test seam: point the cache at any directory. `shared` uses Application Support.
    init(directory: URL) {
        dir = directory
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    private convenience init() {
        let base = (try? FileManager.default.url(for: .applicationSupportDirectory,
                                                 in: .userDomainMask, appropriateFor: nil, create: true))
            ?? FileManager.default.temporaryDirectory
        self.init(directory: base.appendingPathComponent("VerseAudioCache", isDirectory: true))
    }

    /// Stable on-disk name for a verse: zero-padded `sssaaa.mp3`, matching everyayah's layout.
    static func fileName(surah: Int, ayah: Int) -> String {
        String(format: "%03d%03d.mp3", surah, ayah)
    }

    private func fileURL(surah: Int, ayah: Int) -> URL {
        dir.appendingPathComponent(Self.fileName(surah: surah, ayah: ayah))
    }

    /// The cached local file for a verse, or nil if it hasn't been saved yet. A cheap stat;
    /// the player calls this on the playback path to prefer local audio over the network.
    func cachedURL(surah: Int, ayah: Int) -> URL? {
        let u = fileURL(surah: surah, ayah: ayah)
        return FileManager.default.fileExists(atPath: u.path) ? u : nil
    }

    /// Download `remote` into the cache if this verse isn't saved yet. Fire-and-forget and
    /// deduplicated: a verse already on disk or already downloading is a no-op. Any failure
    /// (offline, 404, write race) is swallowed - the next play simply retries and streams
    /// meanwhile.
    func ensureCached(surah: Int, ayah: Int, remote: URL) {
        let dest = fileURL(surah: surah, ayah: ayah)
        if FileManager.default.fileExists(atPath: dest.path) { return }

        let key = "\(surah):\(ayah)"
        lock.lock()
        if inFlight.contains(key) { lock.unlock(); return }
        inFlight.insert(key)
        lock.unlock()

        let task = URLSession.shared.downloadTask(with: remote) { [weak self] tmp, response, _ in
            guard let self else { return }
            defer { self.lock.lock(); self.inFlight.remove(key); self.lock.unlock() }

            guard let tmp,
                  let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode),
                  let size = try? FileManager.default.attributesOfItem(atPath: tmp.path)[.size] as? Int,
                  size > 0
            else { return }

            // Move the temp file into place synchronously (it's deleted once this block returns).
            // Lost a race to a concurrent writer -> the file already exists, which is fine.
            guard !FileManager.default.fileExists(atPath: dest.path) else { return }
            do {
                try FileManager.default.moveItem(at: tmp, to: dest)
                var u = dest
                var values = URLResourceValues(); values.isExcludedFromBackup = true
                try? u.setResourceValues(values)
            } catch { /* leave uncached; the next play retries */ }
        }
        task.resume()
    }
}
