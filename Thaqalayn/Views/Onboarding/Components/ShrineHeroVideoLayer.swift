//
//  ShrineHeroVideoLayer.swift
//  Thaqalayn
//
//  Full-bleed cinematic hero loop for onboarding screen 1: doves wheeling
//  over the floodlit shrine of Imam Husayn at night (bundled 7.25s seamless
//  HEVC loop, muted). A soft scrim keeps the hadith card legible. Callers
//  gate on `isAvailable` + Reduce Motion and fall back to the procedural
//  ShrineDovesLayer; this view also guards internally as a last resort.
//

import AVFoundation
import SwiftUI
import UIKit

struct ShrineHeroVideoLayer: View {
    /// Pause playback when the screen is off-page or the app is backgrounded.
    let isActive: Bool

    @Environment(\.scenePhase) private var scenePhase

    private static let videoURL = Bundle.main.url(
        forResource: "shrine_hero_loop", withExtension: "mp4"
    )

    static var isAvailable: Bool { videoURL != nil }

    var body: some View {
        if let url = Self.videoURL {
            ZStack {
                LoopingVideoView(url: url, isPlaying: isActive && scenePhase == .active)

                // Soft scrim: gently darken the title zone and the bottom
                // "tap to continue" zone; the mid sky is already dark.
                LinearGradient(
                    stops: [
                        .init(color: .black.opacity(0.28), location: 0),
                        .init(color: .black.opacity(0.04), location: 0.22),
                        .init(color: .black.opacity(0.04), location: 0.58),
                        .init(color: .black.opacity(0.40), location: 1),
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            }
            .allowsHitTesting(false)
            .ignoresSafeArea()
        } else {
            // Defensive fallback; callers normally check `isAvailable`.
            ShrineDovesLayer()
        }
    }
}

// MARK: - Looping player (AVPlayerLayer + AVPlayerLooper)

private struct LoopingVideoView: UIViewRepresentable {
    let url: URL
    let isPlaying: Bool

    func makeUIView(context: Context) -> PlayerContainerView {
        PlayerContainerView(url: url)
    }

    func updateUIView(_ view: PlayerContainerView, context: Context) {
        view.setPlaying(isPlaying)
    }
}

private final class PlayerContainerView: UIView {
    private let player: AVQueuePlayer
    private var looper: AVPlayerLooper?

    override class var layerClass: AnyClass { AVPlayerLayer.self }
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }

    init(url: URL) {
        let queue = AVQueuePlayer()
        queue.isMuted = true
        queue.preventsDisplaySleepDuringVideoPlayback = false
        player = queue
        super.init(frame: .zero)

        // Silent ambient video must never interrupt the user's own audio.
        // AudioManager reconfigures the session whenever real playback starts.
        try? AVAudioSession.sharedInstance().setCategory(
            .ambient, mode: .default, options: [.mixWithOthers]
        )

        looper = AVPlayerLooper(player: queue, templateItem: AVPlayerItem(url: url))
        playerLayer.player = queue
        playerLayer.videoGravity = .resizeAspectFill
        queue.play()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func setPlaying(_ playing: Bool) {
        if playing {
            if player.timeControlStatus != .playing { player.play() }
        } else {
            player.pause()
        }
    }
}

#if DEBUG
#Preview {
    ZStack {
        OnboardingBackground(tilt: .peach)
        ShrineHeroVideoLayer(isActive: true)
    }
}
#endif
