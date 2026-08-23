import Foundation
import CryptoKit

/// Content-hash key mapping a journey narration string to its bundled recording file.
///
/// ⚠️ MUST stay byte-identical to scripts/journey_audio_key.py: NFC-normalize, trim the
/// same whitespace set (space, tab, newline, CR), SHA256, first 20 hex chars (lowercase).
/// If these diverge, narration silently stops resolving. Recordings live in the bundled
/// `JourneyAudio/` folder (or downloaded packs) as <key>.mp3.
enum JourneyAudioKey {
    private static let trim = CharacterSet(charactersIn: " \t\n\r")

    /// Stable key for a narration string.
    static func key(for text: String) -> String {
        let norm = text
            .precomposedStringWithCanonicalMapping        // NFC
            .trimmingCharacters(in: trim)
        let digest = SHA256.hash(data: Data(norm.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return String(hex.prefix(20))
    }

    /// URL of the recording for this narration string, or nil if none is available.
    /// Resolution order: the bundled free-tier clips (flattened into the bundle root by the
    /// synchronized-folder build), then - for a premium journey - its On-Demand Resources
    /// pack, whose folder reference preserves a subdirectory named for the journey id (only
    /// resolvable while JourneyAudioAvailability holds the ODR request accessing). The trailing
    /// "JourneyAudio" form is a harmless fallback for non-flattened builds.
    ///
    /// - Parameter packSubdirectory: the active premium journey's id (its ODR pack subdir), or
    ///   nil for a bundled/free journey.
    static func recordingURL(for text: String, packSubdirectory: String? = nil) -> URL? {
        let k = key(for: text)
        if let url = Bundle.main.url(forResource: k, withExtension: "mp3") { return url }
        if let sub = packSubdirectory,
           let url = Bundle.main.url(forResource: k, withExtension: "mp3", subdirectory: sub) { return url }
        return Bundle.main.url(forResource: k, withExtension: "mp3", subdirectory: "JourneyAudio")
    }
}
