//
//  JourneyListenView.swift
//  Thaqalayn
//
//  A full-screen, audio-only surface for a journey's narration. The listener is already
//  hearing it - JourneyAudioPlayer.shared drives playback; this view is only the visual
//  player: the journey's cover blurred behind a frosted-glass panel, the title and the
//  current beat, and the transport controls.
//
//  The surface is deliberately always-dark - a darkened, blurred cover in BOTH app themes,
//  matching the immersive Deep Dive experience it belongs to (DeepDivePalette, gold-on-ink).
//  The app-theme identity still shows through: the accent (gold in Midnight Emerald, blue in
//  the legacy theme), the serif-vs-system title, and the play-button icon - selected via the
//  same `isMidnightEmerald { emeraldBody } else { legacyBody }` split the surah player uses.
//

import SwiftUI

struct JourneyListenView: View {
    let dive: DeepDive
    var onClose: () -> Void

    @StateObject private var player = JourneyAudioPlayer.shared
    @StateObject private var themeManager = ThemeManager.shared
    /// Drives the "Preparing this journey…" state while a premium journey's on-demand pack
    /// downloads before playback can start. The presenter owns starting playback (after the
    /// download); this view only reflects it.
    @ObservedObject private var presenter = JourneyListenPresenter.shared

    /// The scrubber's own value. Driven from the player's live `journeyElapsed` via an
    /// explicit subscription (see `scrubber`), except while the user is dragging - so it
    /// tracks playback and can never stick at a stale position after a seek.
    @State private var isScrubbing = false
    @State private var scrubValue: TimeInterval = 0

    /// The narrator rates offered (matches JourneyAudioPlayer.setRate's live-applied values).
    private let rates: [Float] = [1.0, 1.25, 1.5]
    /// Timed sleep options only - "End of Surah" carries no interval and is mislabeled for a journey.
    private let sleepOptions = SleepTimerDuration.allCases.filter { $0.timeInterval != nil }

    /// Cover art for this dive, matched across both experience catalogs - the same lookup the
    /// player uses for its lock-screen artwork. nil only if a dive somehow has no cover.
    private var coverAssetName: String? {
        DeepDiveDescriptor.all.first { $0.dive?.id == dive.id }?.coverAssetName
            ?? SurahExperienceDescriptor.all.first { $0.dive?.id == dive.id }?.coverAssetName
    }

    // MARK: - Body (theme split: accent / title font / play-icon differ; the dark surface is shared)

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
        }
        // The surface is a darkened, blurred cover in BOTH themes, so it stays dark like a
        // now-playing screen - fixed rather than themeManager.colorScheme so the status bar and
        // neutral text remain legible even under the legacy (light) theme.
        .preferredColorScheme(.dark)
        .onAppear {
            // The presenter owns starting playback (for a premium journey it must wait for the
            // on-demand pack). Only self-start in the plain case: nothing is preparing and a
            // different dive is loaded - e.g. re-expanding is a no-op since the guard matches.
            if presenter.preparing == nil, player.currentDive?.id != dive.id {
                player.play(dive: dive)
            }
        }
    }

    private var emeraldBody: some View {
        playerSurface(tint: themeManager.accentColor, playIcon: themeManager.onAccentText, serifTitle: true)
    }

    private var legacyBody: some View {
        playerSurface(tint: themeManager.semanticBlue, playIcon: .white, serifTitle: false)
    }

    // MARK: - Surface

    private func playerSurface(tint: Color, playIcon: Color, serifTitle: Bool) -> some View {
        ZStack {
            blurredCover
            VStack(spacing: 0) {
                topBar
                Spacer(minLength: 8)
                panel(tint: tint, playIcon: playIcon, serifTitle: serifTitle)
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 24)
            // While a premium journey's on-demand pack downloads, the transport is dimmed and a
            // "Preparing…" overlay covers the panel until playback can begin.
            .opacity(presenter.preparing == nil ? 1 : 0.15)

            if let prep = presenter.preparing {
                preparingOverlay(prep, tint: tint)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: presenter.preparing)
    }

    /// Covers the transport while a premium journey's narration downloads on first Listen
    /// (Apple-hosted on-demand), then clears itself when playback starts. On failure it offers
    /// a retry. Bundled journeys never show this.
    @ViewBuilder
    private func preparingOverlay(_ prep: JourneyListenPresenter.Preparing, tint: Color) -> some View {
        VStack(spacing: 16) {
            switch prep {
            case .downloading(let progress):
                ProgressView(value: progress > 0 ? progress : nil)
                    .progressViewStyle(.circular)
                    .tint(tint)
                Text("Preparing this journey…")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                if progress > 0 {
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.55))
                        .monospacedDigit()
                }
            case .failed:
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 30, weight: .light))
                    .foregroundColor(.white.opacity(0.85))
                Text("Couldn't download this journey")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.9))
                Text("Check your connection and try again.")
                    .font(.system(size: 13))
                    .foregroundColor(.white.opacity(0.55))
                Button { presenter.retryPreparing() } label: {
                    Text("Retry")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(tint)
                        .padding(.horizontal, 24).padding(.vertical, 10)
                        .background(Capsule().fill(.white.opacity(0.12)))
                }
                .padding(.top, 4)
            }
        }
        .padding(28)
        .frame(maxWidth: 300)
    }

    // MARK: - Background - the cover blurred until only its shape survives, darkened for legibility.

    @ViewBuilder
    private var blurredCover: some View {
        GeometryReader { geo in
            Group {
                if let cover = coverAssetName {
                    Image(cover)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        // Overscan before blurring: a blur samples past its bounds, so without
                        // the extra material the frame picks up a dark vignette at every edge.
                        .scaleEffect(1.22)
                        .blur(radius: 44, opaque: true)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipped()
                        .overlay(Color.black.opacity(0.55))
                } else {
                    DeepDivePalette.bg(0.4)
                }
            }
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }

    // MARK: - Top bar - minimize (audio keeps playing) + a quiet context eyebrow.

    private var topBar: some View {
        ZStack {
            Text("NOW LISTENING")
                .font(.system(size: 12, weight: .bold))
                .tracking(1.5)
                .foregroundColor(.white.opacity(0.55))

            HStack {
                Button { onClose() } label: {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(DeepDivePalette.cream)
                        .frame(width: 40, height: 40)
                        .background(
                            Circle()
                                .fill(.ultraThinMaterial)
                                .overlay(Circle().stroke(Color.white.opacity(0.14), lineWidth: 1))
                        )
                }
                .buttonStyle(EmPressStyle())
                Spacer()
            }
        }
        .frame(height: 44)
    }

    // MARK: - Glass panel

    private func panel(tint: Color, playIcon: Color, serifTitle: Bool) -> some View {
        VStack(spacing: 24) {
            coverThumbnail
            titleBlock(serifTitle: serifTitle)
            scrubber(tint: tint)
            transportRow(tint: tint, playIcon: playIcon)
            secondaryRow(tint: tint)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 26)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .stroke(Color.white.opacity(0.14), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.45), radius: 34, y: 16)
        )
    }

    /// Crisp, rounded cover (falls back to the dive's SF Symbol on a gold chip).
    private var coverThumbnail: some View {
        Group {
            if let cover = coverAssetName {
                Image(cover).resizable().scaledToFill()
            } else {
                DeepDivePalette.gold.opacity(0.16)
                    .overlay(
                        Image(systemName: dive.sfSymbol)
                            .font(.system(size: 46, weight: .light))
                            .foregroundColor(DeepDivePalette.goldBright)
                    )
            }
        }
        .frame(width: 188, height: 235)   // 4:5, the cover's native composition
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.5), radius: 26, y: 12)
    }

    private func titleBlock(serifTitle: Bool) -> some View {
        VStack(spacing: 6) {
            Text(dive.titleEn)
                .font(serifTitle ? EmType.serif(30, .semiBold) : .system(size: 26, weight: .bold))
                .foregroundColor(DeepDivePalette.cream)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            // Subtle context, not a blank blur: the beat currently playing.
            if !player.currentBeatTitle.isEmpty {
                Text(player.currentBeatTitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(DeepDivePalette.mute)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: player.currentBeatTitle)
    }

    /// Scrubber over the WHOLE journey - cumulative elapsed on the left, the journey's total
    /// length on the right - seeking anywhere across all the stitched clips. Until the clip
    /// durations resolve (first play measures the streamed verses, then they're cached) it
    /// falls back to the current clip's readout. Dragging commits the seek on release.
    private func scrubber(tint: Color) -> some View {
        let total = player.journeyDuration > 0 ? player.journeyDuration : max(player.duration, 1)
        return VStack(spacing: 8) {
            Slider(
                value: $scrubValue,
                in: 0...max(total, 1),
                onEditingChanged: { editing in
                    isScrubbing = editing
                    if !editing {
                        if player.journeyDuration > 0 { player.seekJourney(to: scrubValue) }
                        else { player.seek(to: scrubValue) }
                    }
                }
            )
            .tint(tint)

            HStack {
                Text(formatTime(scrubValue))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
                Spacer()
                Text(formatTime(total))
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.55))
            }
        }
        // Track live playback via an explicit subscription (never a captured value), so the
        // scrubber follows `journeyElapsed` and can't freeze after a seek. Paused only while
        // the user is actively dragging.
        .onReceive(player.$journeyElapsed) { v in
            guard !isScrubbing else { return }
            let cap = player.journeyDuration > 0 ? player.journeyDuration : max(player.duration, 1)
            scrubValue = min(max(v, 0), max(cap, 1))
        }
    }

    private func transportRow(tint: Color, playIcon: Color) -> some View {
        HStack(spacing: 44) {
            Button { player.previousBeat() } label: {
                Image(systemName: "backward.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(tint)
            }
            .buttonStyle(EmPressStyle())

            Button { player.togglePlayPause() } label: {
                Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundColor(playIcon)
                    .frame(width: 78, height: 78)
                    .background(
                        Circle()
                            .fill(themeManager.accentGradient)
                            .shadow(color: themeManager.accentColor.opacity(0.4), radius: 20, y: 8)
                    )
            }
            .buttonStyle(EmPressStyle())

            Button { player.nextBeat() } label: {
                Image(systemName: "forward.fill")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundColor(tint)
            }
            .buttonStyle(EmPressStyle())
        }
    }

    /// Speed + sleep-timer chips.
    private func secondaryRow(tint: Color) -> some View {
        HStack(spacing: 12) {
            speedControl(tint: tint)
            sleepControl(tint: tint)
        }
    }

    private func speedControl(tint: Color) -> some View {
        Menu {
            ForEach(rates, id: \.self) { rate in
                Button { player.setRate(rate) } label: {
                    if player.playbackRate == rate {
                        Label(rateLabel(rate), systemImage: "checkmark")
                    } else {
                        Text(rateLabel(rate))
                    }
                }
            }
        } label: {
            controlChip(icon: "speedometer", text: rateLabel(player.playbackRate), tint: tint)
        }
    }

    private func sleepControl(tint: Color) -> some View {
        Menu {
            if player.sleepTimerTimeRemaining != nil {
                Button(role: .destructive) {
                    player.setSleepTimer(nil)
                } label: {
                    Label("Turn off", systemImage: "moon.zzz")
                }
            }
            ForEach(sleepOptions, id: \.self) { option in
                Button { player.setSleepTimer(option) } label: { Text(option.title) }
            }
        } label: {
            controlChip(
                icon: "moon.zzz.fill",
                text: player.sleepTimerTimeRemaining.map { formatTime($0) } ?? "Sleep",
                tint: tint
            )
        }
    }

    private func controlChip(icon: String, text: String, tint: Color) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon).font(.system(size: 13, weight: .semibold))
            Text(text).font(.system(size: 14, weight: .semibold))
        }
        .foregroundColor(tint)
        .padding(.horizontal, 16)
        .frame(height: 40)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay(Capsule().stroke(Color.white.opacity(0.14), lineWidth: 1))
        )
    }

    private func rateLabel(_ rate: Float) -> String {
        "\(String(format: "%g", Double(rate)))×"
    }

    private func formatTime(_ time: TimeInterval) -> String {
        guard time.isFinite, time >= 0 else { return "0:00" }
        let total = Int(time)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}

#if DEBUG
#Preview {
    JourneyListenView(dive: .yaqin, onClose: {})
}
#endif
