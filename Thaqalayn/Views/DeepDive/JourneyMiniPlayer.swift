//
//  JourneyMiniPlayer.swift
//  Thaqalayn
//
//  A compact, docked now-playing bar for journey narration. It sits just above the
//  EmeraldTabBar in BOTH themes whenever a journey is playing but the full-screen
//  JourneyListenView is minimized, so the listener always has pause / stop / reopen
//  within reach. Purely a control surface - JourneyAudioPlayer.shared drives audio;
//  JourneyListenPresenter.shared owns which journey is active and whether it's expanded.
//
//  Visually it echoes the EmeraldTabBar (the same frosted glass card + tint + stroke)
//  so the two read as one floating family, and follows the active app theme rather than
//  the always-dark full player it minimizes into.
//

import SwiftUI

struct JourneyMiniPlayer: View {
    @ObservedObject private var player = JourneyAudioPlayer.shared
    @ObservedObject private var presenter = JourneyListenPresenter.shared
    @ObservedObject private var tm = ThemeManager.shared

    /// Docked height, and the bottom inset that floats the bar just above the
    /// EmeraldTabBar (its ~68pt card + 30pt bottom padding + a small gap). Read by
    /// MainTabView, which owns the docking.
    static let barHeight: CGFloat = 64
    static let bottomInset: CGFloat = 110

    /// Cover art for a dive, matched across BOTH experience catalogs by `dive.id` - the
    /// same lookup the player uses for its lock-screen artwork and JourneyListenView uses.
    private func coverAssetName(for dive: DeepDive) -> String? {
        DeepDiveDescriptor.all.first { $0.dive?.id == dive.id }?.coverAssetName
            ?? SurahExperienceDescriptor.all.first { $0.dive?.id == dive.id }?.coverAssetName
    }

    /// Glass tint layered over `.ultraThinMaterial` - mirrors EmeraldTabBar so the bar
    /// reads as its sibling: deep emerald-black in Midnight Emerald, frosted white in Light.
    private var cardTint: Color {
        tm.isMidnightEmerald ? Color(hex: "0A1512").opacity(0.72) : Color.white.opacity(0.6)
    }

    /// Fraction of the current clip elapsed, clamped - drives the accent hairline.
    private var progress: CGFloat {
        guard player.duration > 0 else { return 0 }
        return min(max(CGFloat(player.currentTime / player.duration), 0), 1)
    }

    var body: some View {
        if let dive = presenter.dive {
            bar(dive)
        }
    }

    private func bar(_ dive: DeepDive) -> some View {
        HStack(spacing: 12) {
            // Leading tappable region (cover + text): reopens the full player. A separate
            // Button from the transport controls, so a tap on a control never expands.
            Button { presenter.expand() } label: {
                HStack(spacing: 12) {
                    cover(dive)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dive.titleEn)
                            .font(EmType.serif(18, .semiBold))
                            .foregroundColor(tm.primaryText)
                            .lineLimit(1)
                        Text(player.currentBeatTitle.isEmpty ? "Now listening" : player.currentBeatTitle)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(tm.secondaryText)
                            .lineLimit(1)
                            .animation(.easeInOut(duration: 0.25), value: player.currentBeatTitle)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Open \(dive.titleEn) player")

            playPauseButton
            stopButton
        }
        .padding(.horizontal, 12)
        .frame(height: Self.barHeight)
        .background(glass)
        .overlay(alignment: .bottom) { progressHairline }
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(tm.strokeColor, lineWidth: 1)
        )
        .shadow(color: tm.isMidnightEmerald ? Color.black.opacity(0.5) : Color.black.opacity(0.16),
                radius: tm.isMidnightEmerald ? 30 : 20, x: 0, y: 12)
        .padding(.horizontal, 18)   // match the EmeraldTabBar's horizontal inset
    }

    // MARK: - Pieces

    /// Crisp rounded cover (falls back to the dive's SF Symbol on an accent chip).
    private func cover(_ dive: DeepDive) -> some View {
        Group {
            if let asset = coverAssetName(for: dive) {
                Image(asset).resizable().scaledToFill()
            } else {
                tm.accentChip.overlay(
                    Image(systemName: dive.sfSymbol)
                        .font(.system(size: 18, weight: .light))
                        .foregroundColor(tm.accentColor)
                )
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(tm.strokeColor, lineWidth: 1)
        )
    }

    private var playPauseButton: some View {
        Button { player.togglePlayPause() } label: {
            Image(systemName: player.isPlaying ? "pause.fill" : "play.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(tm.onAccentText)
                .frame(width: 38, height: 38)
                .background(Circle().fill(tm.accentGradient))
                .shadow(color: tm.accentColor.opacity(0.35), radius: 10, y: 4)
        }
        .buttonStyle(EmPressStyle())
        .accessibilityLabel(player.isPlaying ? "Pause" : "Play")
    }

    private var stopButton: some View {
        Button { presenter.close() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(tm.secondaryText)
                .frame(width: 32, height: 32)
                .background(Circle().fill(tm.glassSurface))
                .overlay(Circle().stroke(tm.strokeColor, lineWidth: 1))
        }
        .buttonStyle(EmPressStyle())
        .accessibilityLabel("Stop")
    }

    private var glass: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(.ultraThinMaterial)
            RoundedRectangle(cornerRadius: 20, style: .continuous).fill(cardTint)
        }
    }

    /// A thin accent line along the bottom edge tracking progress through the current clip.
    private var progressHairline: some View {
        GeometryReader { geo in
            tm.accentColor
                .frame(width: geo.size.width * progress)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 2)
        .allowsHitTesting(false)
    }
}

#if DEBUG
#Preview {
    let _ = (ThemeManager.shared.selectedTheme = .nightSanctuary)
    let _ = (JourneyListenPresenter.shared.dive = .yaqin)
    return ZStack {
        EmeraldBackground()
        VStack {
            Spacer()
            JourneyMiniPlayer()
                .padding(.bottom, JourneyMiniPlayer.bottomInset)
        }
    }
}
#endif
