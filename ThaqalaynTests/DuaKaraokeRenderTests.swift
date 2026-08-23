import XCTest
import SwiftUI
@testable import Thaqalayn

/// Diagnostic coverage for the karaoke gold highlight, headless-runnable on any
/// simulator/OS: (1) does a per-run AttributedString foregroundColor survive the
/// view's `.foregroundColor()` modifier when rendered to pixels, and (2) does the
/// live engine publish word positions from the stream player's published state.
final class DuaKaraokeRenderTests: XCTestCase {

    /// Mirror of SpecialDuaDetailView.segmentRow's Arabic text stack: one run
    /// colored gold inside a cream `.foregroundColor` modifier, RTL layout.
    @MainActor
    private func renderArabicLine(goldToken: Int) -> UIImage {
        let ar = "اَللَّهُمَّ رَبَّ النُّورِ الْعَظِيمِ"
        let tokens = DuaArabicTokenizer.tokens(ar)
        var line = AttributedString()
        for (i, token) in tokens.enumerated() {
            if i > 0 { line += AttributedString(" ") }
            var word = AttributedString(token)
            if i == goldToken { word.foregroundColor = Color(red: 0.925, green: 0.831, blue: 0.604) } // ECD49A
            line += word
        }
        let view = Text(line)
            .font(.system(size: 26))
            .foregroundColor(Color(red: 0.945, green: 0.910, blue: 0.839)) // F1E8D6 cream
            .multilineTextAlignment(.center)
            .frame(width: 350)
            .environment(\.layoutDirection, .rightToLeft)
            .background(Color.black)

        let host = UIHostingController(rootView: view)
        host.view.bounds = CGRect(x: 0, y: 0, width: 350, height: 120)
        host.view.backgroundColor = .black
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(bounds: host.view.bounds, format: format).image { ctx in
            host.view.drawHierarchy(in: host.view.bounds, afterScreenUpdates: true)
        }
    }

    /// Count pixels close to the gold (ECD49A) vs cream (F1E8D6) — they differ
    /// strongly in the blue channel relative to red.
    private func goldPixelCount(in image: UIImage) -> Int {
        guard let cg = image.cgImage else { return 0 }
        let w = cg.width, h = cg.height
        var data = [UInt8](repeating: 0, count: w * h * 4)
        let ctx = CGContext(data: &data, width: w, height: h, bitsPerComponent: 8,
                            bytesPerRow: w * 4, space: CGColorSpaceCreateDeviceRGB(),
                            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        ctx.draw(cg, in: CGRect(x: 0, y: 0, width: w, height: h))
        var gold = 0
        for p in stride(from: 0, to: data.count, by: 4) {
            let r = Int(data[p]), g = Int(data[p + 1]), b = Int(data[p + 2])
            // gold: warm, red well above blue; cream: near-neutral warm white
            if r > 150, g > 120, r - b > 60, g - b > 30 { gold += 1 }
        }
        return gold
    }

    /// The gold run must actually render gold — if the outer `.foregroundColor`
    /// modifier overrides per-run attributes on this OS, this fails.
    @MainActor
    func test_goldWordSurvivesForegroundColorModifier() {
        let with = goldPixelCount(in: renderArabicLine(goldToken: 0))
        let without = goldPixelCount(in: renderArabicLine(goldToken: -1))
        XCTAssertLessThan(without, 40, "control render should have almost no gold pixels")
        XCTAssertGreaterThan(with, 200,
            "gold word did not render gold (per-run color lost, only \(with) gold px)")
    }

    /// The engine must publish a word position from published player state alone
    /// (no real audio): configure for a real bundled dua, fake the stream state.
    @MainActor
    func test_engine_publishesWordFromStreamState() throws {
        let timings = try XCTUnwrap(SpecialDuaTimingsStore.shared.timings(for: "ahad"))
        let stream = DuaStreamPlayer.shared
        stream.currentID = "ahad"
        stream.duration = timings.audioDuration
        defer { stream.currentID = nil; stream.duration = 0; stream.currentTime = 0 }

        let engine = DuaKaraokeEngine()
        engine.configure(duaID: "ahad")

        // Pick a time squarely inside some word.
        let mid = timings.words[10]
        stream.currentTime = (mid.start + mid.end) / 2

        XCTAssertEqual(engine.currentWord, mid.position,
                       "engine did not follow published stream time")
        XCTAssertEqual(engine.currentSegment, mid.position.segment)
    }
}
