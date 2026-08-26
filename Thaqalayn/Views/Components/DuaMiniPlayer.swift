//
//  DuaMiniPlayer.swift
//  Thaqalayn
//
//  A compact, docked now-playing bar for a streamed dua/ziyarat recitation (the
//  Duas & Ziyarat library). It appears whenever a recitation is loaded but its
//  reader screen is not on top, so the listener always has pause / stop / reopen
//  within reach - the sibling of JourneyMiniPlayer, sharing its frosted-glass look.
//  Purely a control surface: DuaStreamPlayer.shared drives audio; the host decides
//  how "open" navigates back to the reader (push inside the library, full-screen
//  cover from the tab root) via `onOpen`.
//

import SwiftUI

struct DuaMiniPlayer: View {
    /// Reopen the dua's reader screen - supplied by the host (push or cover).
    let onOpen: () -> Void

    @ObservedObject private var stream = DuaStreamPlayer.shared
    @ObservedObject private var tm = ThemeManager.shared

    /// Glass tint layered over `.ultraThinMaterial` - mirrors JourneyMiniPlayer /
    /// EmeraldTabBar so the bars read as one floating family.
    private var cardTint: Color {
        tm.isMidnightEmerald ? Color(hex: "0A1512").opacity(0.72) : Color.white.opacity(0.6)
    }

    /// Fraction of the recitation elapsed, clamped - drives the accent hairline.
    private var progress: CGFloat {
        guard stream.duration > 0 else { return 0 }
        return min(max(CGFloat(stream.currentTime / stream.duration), 0), 1)
    }

    private var subtitle: String {
        if stream.isLoading { return "Loading" }
        guard stream.duration > 0 else { return "Now reciting" }
        return "\(timeString(stream.currentTime)) / \(timeString(stream.duration))"
    }

    var body: some View {
        if let dua = stream.currentDua {
            bar(dua)
        }
    }

    private func bar(_ dua: SpecialDua) -> some View {
        HStack(spacing: 12) {
            // Leading tappable region (cover + text): reopens the reader. A separate
            // Button from the transport controls, so a tap on a control never opens.
            Button(action: onOpen) {
                HStack(spacing: 12) {
                    cover(dua)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(dua.titleEn)
                            .font(EmType.serif(18, .semiBold))
                            .foregroundColor(tm.primaryText)
                            .lineLimit(1)
                        Text(subtitle)
                            .font(.system(size: 12, weight: .medium).monospacedDigit())
                            .foregroundColor(tm.secondaryText)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(EmPressStyle())
            .accessibilityLabel("Open \(dua.titleEn)")

            playPauseButton
            stopButton
        }
        .padding(.horizontal, 12)
        .frame(height: JourneyMiniPlayer.barHeight)
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

    /// The library's cover art as the thumb, with the dua's symbol as a fallback.
    private func cover(_ dua: SpecialDua) -> some View {
        Group {
            if UIImage(named: "DuasZiyaratCover") != nil {
                Image("DuasZiyaratCover").resizable().scaledToFill()
            } else {
                tm.accentChip.overlay(
                    Image(systemName: SpecialDuaIcon.symbol(for: dua.id))
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
        Button { stream.togglePlayPause() } label: {
            Group {
                if stream.isLoading {
                    ProgressView().controlSize(.small).tint(tm.onAccentText)
                } else {
                    Image(systemName: stream.isPlaying ? "pause.fill" : "play.fill")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .foregroundColor(tm.onAccentText)
            .frame(width: 38, height: 38)
            .background(Circle().fill(tm.accentGradient))
            .shadow(color: tm.accentColor.opacity(0.35), radius: 10, y: 4)
        }
        .buttonStyle(EmPressStyle())
        .accessibilityLabel(stream.isPlaying ? "Pause" : "Play")
    }

    private var stopButton: some View {
        Button { stream.stop() } label: {
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

    /// A thin accent line along the bottom edge tracking progress through the recitation.
    private var progressHairline: some View {
        GeometryReader { geo in
            tm.accentColor
                .frame(width: geo.size.width * progress)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 2)
        .allowsHitTesting(false)
    }

    private func timeString(_ t: TimeInterval) -> String {
        guard t.isFinite, t >= 0 else { return "0:00" }
        let total = Int(t)
        return String(format: "%d:%02d", total / 60, total % 60)
    }
}
