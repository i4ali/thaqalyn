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

    /// URL of the bundled recording for this narration string, or nil if none is shipped.
    /// The app's synchronized-folder build flattens resources into the bundle root, so
    /// look up flat first; the subdirectory form is a harmless fallback.
    /// Downloaded (on-demand) packs are resolved by JourneyAudioAvailability (a later task), not here.
    static func recordingURL(for text: String) -> URL? {
        let k = key(for: text)
        return Bundle.main.url(forResource: k, withExtension: "mp3")
            ?? Bundle.main.url(forResource: k, withExtension: "mp3", subdirectory: "JourneyAudio")
    }
}
