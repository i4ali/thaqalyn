//
//  ProgressTrackingScreen.swift
//  Thaqalayn
//
//  Onboarding screen: progress tracking. Reading is counted by passage now, not
//  by ticking verses. The mock is a slice of the real surah passage list
//  (al-Baqarah, three rows) that replays the list's own gesture: a finger drags
//  the passage being read to the right, the gold "Read" swipe action slides out
//  from the card's leading edge, the row springs back with a checkmark, the
//  surah's read count follows, and the home surah card appears with the same
//  count. The paged TabView builds this screen before it is shown, so the demo
//  starts only when the page becomes current (isActive), always from the
//  unchecked state, and loops every seven seconds while it stays current.
//

import SwiftUI

struct ProgressTrackingScreen: View {
    /// True while this page is the one on screen. The demo runs only then.
    var isActive: Bool = true

    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isVisible = false
    @State private var swipeOffset: CGFloat = 0   // the row's drag, 0 to swipeReveal (rightward)
    @State private var touchVisible = false       // the finger that drags it
    @State private var actionPressed = false      // the action's press flash on release
    @State private var adamRead = false           // "Adam and the angels" flips from reading to read
    @State private var showSurahCard = false
    @State private var readCount = 3              // the surah's read passages, 3 then 4
    @State private var demoOpacity: Double = 1    // dips between loops so the reset is not seen
    @State private var loopToken = UUID()         // invalidates scheduled steps when the page leaves

    /// How far the row travels to reveal the swipe action (iOS reveals about this much).
    static let swipeReveal: CGFloat = 84

    var body: some View {
        VStack(spacing: 0) {
            // Header with animated icon
            VStack(spacing: 20) {
                HeroChip(palette: ThemeManager.chipGold, pulseDuration: 2.0) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 38, weight: .semibold))
                }
                .opacity(isVisible ? 1 : 0)
                .scaleEffect(isVisible ? 1 : 0.5)
                .animation(Animation.spring(response: 0.6, dampingFraction: 0.7).delay(0.2), value: isVisible)

                Text("Track Your Progress")
                    .onbHeroTitle()
                    .foregroundColor(themeManager.primaryText)
                    .opacity(isVisible ? 1 : 0)
                    .offset(y: isVisible ? 0 : -20)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.4), value: isVisible)

                Text("The Quran, passage by passage")
                    .onbBody()
                    .foregroundColor(themeManager.secondaryText)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
            }
            .padding(.top, 60)
            .padding(.bottom, 24)

            // Demo content
            VStack(spacing: 16) {
                DemoPassageList(swipeOffset: swipeOffset, touchVisible: touchVisible,
                                actionPressed: actionPressed, adamRead: adamRead,
                                readCount: readCount, isVisible: isVisible)

                DemoSurahCard(showCard: showSurahCard, readCount: readCount)
            }
            .padding(.horizontal, 20)
            .opacity(demoOpacity)

            Spacer()

            // Bottom message
            Text("Swipe a passage to mark it read, or simply reach its end. Your progress syncs across all your devices.")
                .onbCaption()
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 40)
                .padding(.bottom, 100)
                .opacity(showSurahCard ? 1 : 0)
                .animation(Animation.easeOut(duration: 0.6).delay(0.3), value: showSurahCard)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .sage))
        .onAppear {
            isVisible = true
            if reduceMotion {
                // No replayed gesture: land on the end state.
                adamRead = true
                readCount = 4
                showSurahCard = true
            }
        }
        .onChange(of: isActive, initial: true) { _, active in
            guard !reduceMotion else { return }
            if active { startLoop() } else { stopLoop() }
        }
    }

    // MARK: - The replayed gesture

    private func startLoop() {
        let token = UUID()
        loopToken = token
        resetToBefore()
        runCycle(token)
    }

    private func stopLoop() {
        loopToken = UUID()
        resetToBefore()
    }

    /// The unchecked state the demo always starts from, set without animation.
    private func resetToBefore() {
        var t = Transaction(); t.disablesAnimations = true
        withTransaction(t) {
            swipeOffset = 0
            touchVisible = false
            actionPressed = false
            adamRead = false
            readCount = 3
            showSurahCard = false
            demoOpacity = 1
        }
    }

    /// Runs one pass of the demo, then schedules the next. Every step checks the
    /// token so a page that has been left (or re-entered) does not double up.
    private func runCycle(_ token: UUID) {
        func at(_ seconds: Double, _ step: @escaping () -> Void) {
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                guard loopToken == token else { return }
                step()
            }
        }

        // Finger lands mid-row, after the unchecked row has had a moment to register.
        at(1.4) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { touchVisible = true }
        }
        // Drags right, decelerating like a real swipe; the Read action follows it out.
        at(1.7) {
            withAnimation(.easeOut(duration: 0.5)) { swipeOffset = Self.swipeReveal }
        }
        // Lifts, and the action takes the tap: a brief flash.
        at(2.45) {
            withAnimation(.easeOut(duration: 0.15)) { touchVisible = false }
        }
        at(2.55) {
            withAnimation(.easeOut(duration: 0.08)) { actionPressed = true }
        }
        // The row springs home read.
        at(2.7) {
            actionPressed = false
            withAnimation(.spring(response: 0.42, dampingFraction: 0.8)) {
                swipeOffset = 0
                adamRead = true
            }
        }
        // The surah's count follows, then the home card appears with the same count.
        at(3.3) {
            withAnimation(.easeOut(duration: 0.45)) { readCount = 4 }
        }
        at(3.7) {
            withAnimation(.easeOut(duration: 0.4)) { showSurahCard = true }
        }
        // Dip, reset unseen, and go again.
        at(6.9) {
            withAnimation(.easeOut(duration: 0.3)) { demoOpacity = 0 }
        }
        at(7.25) {
            resetToBefore()
            demoOpacity = 0
            withAnimation(.easeIn(duration: 0.3)) { demoOpacity = 1 }
        }
        at(7.3) { runCycle(token) }
    }
}

// MARK: - Demo passage list (a slice of the real surah screen)

/// Built like an inset-grouped list: the rows run edge to edge inside the card
/// and the card clips them, so a swiped row slides under the card's edge the way
/// a real row slides under the screen's, and the Read action sits flush with the
/// leading edge at exactly the row's height, as the list's leading swipe does.
private struct DemoPassageList: View {
    @StateObject private var themeManager = ThemeManager.shared
    let swipeOffset: CGFloat
    let touchVisible: Bool
    let actionPressed: Bool
    let adamRead: Bool
    let readCount: Int
    let isVisible: Bool

    private let gold = Color(hex: "ECD49A")
    private let night = Color(hex: "0A1512")
    private let inset: CGFloat = 20

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Al-Baqarah")
                    .font(EmType.serif(22, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                Text("The Cow · Medinan · 40 passages · \(readCount) read")
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .contentTransition(.numericText())
            }
            .padding(.horizontal, inset)
            .padding(.top, 18)
            .padding(.bottom, 10)

            row(title: "The call to worship", range: "21 to 29", state: .read)
            divider
            swipedRow
            divider
            row(title: "Children of Israel and the covenant", range: "40 to 46", state: .unread)
        }
        .padding(.bottom, 8)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .onboardingCard(padding: 0)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 40)
        .animation(Animation.easeOut(duration: 0.7).delay(0.6), value: isVisible)
    }

    private enum RowState { case read, unread }

    private var divider: some View {
        Rectangle()
            .fill(gold.opacity(0.10))
            .frame(height: 1)
            .padding(.leading, inset + 38)
    }

    /// The list's real leading swipe, replayed: the row slides right and the Read
    /// action grows out of the card's leading edge behind it, at the row's height.
    private var swipedRow: some View {
        row(title: "Adam and the angels", range: "30 to 39", state: adamRead ? .read : .unread)
            .offset(x: swipeOffset)
            .background(alignment: .leading) {
                VStack(spacing: 5) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 17, weight: .semibold))
                    Text("Read")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(night)
                .frame(width: ProgressTrackingScreen.swipeReveal)
                .frame(maxHeight: .infinity)
                .background(actionPressed ? Color(hex: "FFF1CB") : gold)
                .frame(width: max(0, swipeOffset), alignment: .trailing)
                .clipped()
            }
            .overlay(alignment: .center) {
                // The finger: lands mid-row, drags with it, lifts.
                Circle()
                    .fill(Color.white.opacity(0.22))
                    .overlay(Circle().stroke(Color.white.opacity(0.55), lineWidth: 1.2))
                    .frame(width: 28, height: 28)
                    .shadow(color: .black.opacity(0.35), radius: 6, x: 0, y: 3)
                    .offset(x: -30 + swipeOffset)
                    .scaleEffect(touchVisible ? 1 : 0.6)
                    .opacity(touchVisible ? 1 : 0)
                    .allowsHitTesting(false)
            }
    }

    private func row(title: String, range: String, state: RowState) -> some View {
        HStack(alignment: .center, spacing: 12) {
            Text("ع")
                .font(EmType.arabic(19))
                .foregroundColor(gold)
                .frame(width: 26)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(EmType.serif(16, .semiBold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(range)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer(minLength: 8)

            ZStack {
                switch state {
                case .read:
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(gold)
                        .transition(.scale(scale: 0.4).combined(with: .opacity))
                case .unread:
                    EmptyView()
                }
            }
            .frame(minWidth: 52, alignment: .trailing)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, inset)
        .animation(.spring(response: 0.35, dampingFraction: 0.6), value: state == .read)
    }
}

// MARK: - Demo surah card (the home tab's surah row)

private struct DemoSurahCard: View {
    @StateObject private var themeManager = ThemeManager.shared
    let showCard: Bool
    let readCount: Int

    private let gold = Color(hex: "ECD49A")

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(gold)
                    .frame(width: 48, height: 48)
                Text("2")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "0A1512"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Al-Baqarah")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)

                Text("\(readCount) of 40 passages")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
                    .contentTransition(.numericText())
            }

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "book.fill")
                    .font(.system(size: 14))
                    .foregroundColor(gold)

                Text("\(readCount) of 40")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(gold)
                    .contentTransition(.numericText())
            }
        }
        .onboardingCard(padding: 16)
        .opacity(showCard ? 1 : 0)
        .offset(y: showCard ? 0 : 20)
        .animation(Animation.easeOut(duration: 0.5), value: showCard)
    }
}

#Preview {
    ProgressTrackingScreen()
}
