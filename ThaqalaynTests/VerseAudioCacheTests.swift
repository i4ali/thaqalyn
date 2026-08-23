import XCTest
@testable import Thaqalayn

/// Pure, offline coverage for the verse recitation disk cache (Phase 4.3). The actual
/// network download + offline replay is a device-verified step; here we lock down the two
/// pieces that must be exactly right: the everyayah-style filename and the cached-file lookup.
final class VerseAudioCacheTests: XCTestCase {

    /// The on-disk name must match everyayah's `sssaaa.mp3` zero-padded layout, so a verse
    /// resolves to the same key regardless of how many digits its surah/ayah have.
    func test_fileName_zeroPadsSurahAndAyah() {
        XCTAssertEqual(VerseAudioCache.fileName(surah: 1, ayah: 1), "001001.mp3")
        XCTAssertEqual(VerseAudioCache.fileName(surah: 2, ayah: 255), "002255.mp3")
        XCTAssertEqual(VerseAudioCache.fileName(surah: 114, ayah: 6), "114006.mp3")
    }

    /// `cachedURL` is nil until the verse has been saved, then returns exactly that file -
    /// this is the branch the player relies on to prefer local audio (and to replay offline).
    func test_cachedURL_nilUntilPresent_thenReturnsTheFile() throws {
        let dir = FileManager.default.temporaryDirectory
            .appendingPathComponent("VerseCacheTest-\(UUID().uuidString)", isDirectory: true)
        defer { try? FileManager.default.removeItem(at: dir) }

        let cache = VerseAudioCache(directory: dir)
        XCTAssertNil(cache.cachedURL(surah: 1, ayah: 1))

        // Simulate a finished download landing in the cache dir.
        let dest = dir.appendingPathComponent("001001.mp3")
        try Data("mp3".utf8).write(to: dest)

        XCTAssertEqual(cache.cachedURL(surah: 1, ayah: 1)?.standardizedFileURL, dest.standardizedFileURL)
        XCTAssertNil(cache.cachedURL(surah: 1, ayah: 2))   // a different verse is still uncached
    }
}
