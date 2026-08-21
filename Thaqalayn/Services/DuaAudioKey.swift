//
//  DuaAudioKey.swift
//  Thaqalayn
//
//  Content-hash key mapping a dua's Arabic string to its bundled recording file.
//
//  ⚠️ MUST stay byte-identical to scripts/dua_audio_key.py: NFC-normalize, trim the
//  same whitespace set (space, tab, newline, CR), SHA256, first 20 hex chars
//  (lowercase). If these diverge, recordings silently stop resolving and every dua
//  falls back to TTS. Recordings live in the bundled `DuaAudio/` folder as <key>.mp3.
//

import Foundation
import CryptoKit

enum DuaAudioKey {
    private static let trim = CharacterSet(charactersIn: " \t\n\r")

    /// Stable key for an Arabic supplication string.
    static func key(for arabic: String) -> String {
        let norm = arabic
            .precomposedStringWithCanonicalMapping        // NFC
            .trimmingCharacters(in: trim)
        let digest = SHA256.hash(data: Data(norm.utf8))
        let hex = digest.map { String(format: "%02x", $0) }.joined()
        return String(hex.prefix(20))
    }

    /// URL of the bundled recording for this Arabic, or nil if none is shipped.
    /// The app's synchronized-folder build flattens resources into the bundle root,
    /// so look up flat first; the subdirectory form is a harmless fallback in case a
    /// future build preserves the `DuaAudio/` folder.
    static func recordingURL(for arabic: String) -> URL? {
        let k = key(for: arabic)
        return Bundle.main.url(forResource: k, withExtension: "mp3")
            ?? Bundle.main.url(forResource: k, withExtension: "mp3", subdirectory: "DuaAudio")
    }
}
