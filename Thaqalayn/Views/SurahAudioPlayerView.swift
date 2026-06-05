//
//  SurahAudioPlayerView.swift
//  Thaqalayn
//
//  Modern glassmorphism audio player for surah-level audio controls
//

import SwiftUI

struct SurahAudioPlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @ObservedObject private var tabBarVisibility = TabBarVisibility.shared
    @State private var showingFullPlayer = false
    @State private var isExpanded = false

    // The mini player is a global bottom overlay (ContentView). On screens that show
    // the floating EmeraldTabBar it must clear it; on tab-bar-hidden screens (the
    // reader) it drops back down just above the home indicator. Keyed to the same
    // TabBarVisibility signal that drives the tab bar itself.
    private var bottomInset: CGFloat {
        tabBarVisibility.isHidden ? 16 : 110
    }

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldBody
            } else {
                legacyBody
            }
        }
        .sheet(isPresented: $showingFullPlayer) {
            FullScreenAudioPlayerView()
        }
    }

    @ViewBuilder
    private var emeraldBody: some View {
        if let currentPlayback = audioManager.currentPlayback {
            VStack(spacing: 0) {
                // Mini player bar
                HStack(spacing: 12) {
                    // Play/Pause button (gold gradient circle)
                    Button(action: {
                        audioManager.togglePlayPause()
                    }) {
                        Image(systemName: audioManager.playerState == .playing ? "pause.fill" : "play.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.onAccentText)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(themeManager.accentGradient)
                                    .shadow(color: themeManager.accentColor.opacity(0.35), radius: 12, y: 4)
                            )
                    }
                    .buttonStyle(EmPressStyle())
                    .scaleEffect(audioManager.playerState == .loading ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: audioManager.playerState)

                    // Track info
                    VStack(alignment: .leading, spacing: 3) {
                        Text(currentPlayback.surahName)
                            .font(EmType.serif(19, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .lineLimit(1)

                        Text(currentPlayback.reciter.nameEnglish)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .lineLimit(1)
                    }

                    Spacer()

                    // Progress circle
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.10), lineWidth: 2)
                            .frame(width: 32, height: 32)

                        Circle()
                            .trim(from: 0, to: currentPlayback.progress)
                            .stroke(
                                themeManager.accentGradient,
                                style: StrokeStyle(lineWidth: 2, lineCap: .round)
                            )
                            .frame(width: 32, height: 32)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.5), value: currentPlayback.progress)

                        Text("\(Int(currentPlayback.progress * 100))%")
                            .font(.system(size: 8, weight: .semibold))
                            .foregroundColor(themeManager.accentBright)
                    }

                    // Expand button
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.accentColor)
                            .frame(width: 28, height: 28)
                    }

                    // Close button
                    Button(action: {
                        audioManager.stop()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.tertiaryText)
                            .frame(width: 28, height: 28)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(themeManager.glassSurfaceElevated)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                        .shadow(color: Color.black.opacity(0.45), radius: 24, x: 0, y: 8)
                )
                .onTapGesture {
                    showingFullPlayer = true
                }

                // Expanded controls
                if isExpanded {
                    ExpandedAudioControls()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, bottomInset)
        }
    }

    @ViewBuilder
    private var legacyBody: some View {
        if let currentPlayback = audioManager.currentPlayback {
            VStack(spacing: 0) {
                // Mini player bar
                HStack(spacing: 12) {
                    // Play/Pause button
                    Button(action: {
                        audioManager.togglePlayPause()
                    }) {
                        Image(systemName: audioManager.playerState == .playing ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle()
                                    .fill(themeManager.accentGradient)
                                    .shadow(color: themeManager.semanticBlue.opacity(0.4), radius: 8)
                            )
                    }
                    .scaleEffect(audioManager.playerState == .loading ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.3), value: audioManager.playerState)
                    
                    // Track info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(currentPlayback.surahName)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text(currentPlayback.reciter.nameEnglish)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    // Progress circle
                    ZStack {
                        Circle()
                            .stroke(themeManager.strokeColor.opacity(0.3), lineWidth: 2)
                            .frame(width: 32, height: 32)
                        
                        Circle()
                            .trim(from: 0, to: currentPlayback.progress)
                            .stroke(
                                themeManager.accentGradient,
                                style: StrokeStyle(lineWidth: 2, lineCap: .round)
                            )
                            .frame(width: 32, height: 32)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.5), value: currentPlayback.progress)
                        
                        Text("\(Int(currentPlayback.progress * 100))%")
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    
                    // Expand button
                    Button(action: {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }) {
                        Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .frame(width: 28, height: 28)
                    }

                    // Close button
                    Button(action: {
                        audioManager.stop()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(themeManager.secondaryText)
                            .frame(width: 28, height: 28)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                        .shadow(color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.1), radius: 10, y: -5)
                )
                .onTapGesture {
                    showingFullPlayer = true
                }
                
                // Expanded controls
                if isExpanded {
                    ExpandedAudioControls()
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, bottomInset)
            .darkScreenAura()
        }
    }
}

struct ExpandedAudioControls: View {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        VStack(spacing: 16) {
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)

                    Spacer()

                    Text(formatTime(audioManager.duration))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }

                Slider(
                    value: Binding(
                        get: { audioManager.currentTime },
                        set: { audioManager.seek(to: $0) }
                    ),
                    in: 0...max(audioManager.duration, 1)
                )
                .tint(themeManager.accentColor)
            }

            // Control buttons
            HStack(spacing: 24) {
                // Previous button
                Button(action: {
                    audioManager.skipToPrevious()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(themeManager.accentChip)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(EmPressStyle())

                Spacer()

                // Next button
                Button(action: {
                    audioManager.skipToNext()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeManager.accentColor)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(themeManager.accentChip)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                }
                .buttonStyle(EmPressStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(themeManager.glassSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }

    private var legacyBody: some View {
        VStack(spacing: 16) {
            // Progress bar
            VStack(spacing: 8) {
                HStack {
                    Text(formatTime(audioManager.currentTime))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                    
                    Spacer()
                    
                    Text(formatTime(audioManager.duration))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
                
                Slider(
                    value: Binding(
                        get: { audioManager.currentTime },
                        set: { audioManager.seek(to: $0) }
                    ),
                    in: 0...max(audioManager.duration, 1)
                )
                .tint(themeManager.semanticBlue)
            }
            
            // Control buttons
            HStack(spacing: 24) {
                // Previous button
                Button(action: {
                    audioManager.skipToPrevious()
                }) {
                    Image(systemName: "backward.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                }
                
                Spacer()
                
                // Speed control (disabled for accurate verse timing)
                /*
                Menu {
                    ForEach([0.75, 1.0, 1.25, 1.5], id: \.self) { speed in
                        Button("\(speed, specifier: "%.2f")x") {
                            audioManager.updatePlaybackSpeed(speed)
                        }
                    }
                } label: {
                    Text("\(audioManager.configuration.playbackSpeed, specifier: "%.2f")x")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                }
                */
                
                Spacer()
                
                // Next button
                Button(action: {
                    audioManager.skipToNext()
                }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                        .frame(width: 44, height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.glassEffect)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct FullScreenAudioPlayerView: View {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingReciterSelection = false

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldBody
            } else {
                legacyBody
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .sheet(isPresented: $showingReciterSelection) {
            ReciterSelectionView()
        }
    }

    private var emeraldBody: some View {
        NavigationView {
            ZStack {
                EmeraldBackground()

                VStack(spacing: 30) {
                    if let currentPlayback = audioManager.currentPlayback {
                        // Large album art
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .fill(themeManager.glassSurfaceElevated)
                            .frame(height: 280)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                            .overlay(
                                VStack(spacing: 18) {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 60, weight: .light))
                                        .foregroundColor(themeManager.accentColor)
                                    Text("Surah \(currentPlayback.surahNumber)")
                                        .font(EmType.serif(26, .semiBold))
                                        .foregroundColor(themeManager.accentBright)
                                }
                            )
                            .shadow(color: Color.black.opacity(0.45), radius: 40, x: 0, y: 16)

                        // Track info
                        VStack(spacing: 8) {
                            Text(currentPlayback.surahName)
                                .font(EmType.serif(34, .semiBold))
                                .foregroundColor(themeManager.primaryText)
                                .multilineTextAlignment(.center)

                            Button(action: {
                                showingReciterSelection = true
                            }) {
                                HStack(spacing: 6) {
                                    Text(currentPlayback.reciter.nameEnglish)
                                        .font(.system(size: 16, weight: .medium))
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(themeManager.secondaryText)
                            }
                        }

                        // Progress section
                        VStack(spacing: 14) {
                            Slider(
                                value: Binding(
                                    get: { audioManager.currentTime },
                                    set: { audioManager.seek(to: $0) }
                                ),
                                in: 0...max(audioManager.duration, 1)
                            )
                            .tint(themeManager.accentColor)

                            HStack {
                                Text(formatTime(audioManager.currentTime))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(themeManager.tertiaryText)
                                Spacer()
                                Text(formatTime(audioManager.duration))
                                    .font(.system(size: 13, weight: .medium))
                                    .foregroundColor(themeManager.tertiaryText)
                            }
                        }

                        // Main controls
                        HStack(spacing: 40) {
                            // Previous
                            Button(action: {
                                audioManager.skipToPrevious()
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(themeManager.accentColor)
                            }
                            .buttonStyle(EmPressStyle())

                            // Play/Pause (gold gradient circle)
                            Button(action: {
                                audioManager.togglePlayPause()
                            }) {
                                Image(systemName: audioManager.playerState == .playing ? "pause.fill" : "play.fill")
                                    .font(.system(size: 30, weight: .semibold))
                                    .foregroundColor(themeManager.onAccentText)
                                    .frame(width: 80, height: 80)
                                    .background(
                                        Circle()
                                            .fill(themeManager.accentGradient)
                                            .shadow(color: themeManager.accentColor.opacity(0.4), radius: 20, y: 8)
                                    )
                            }
                            .buttonStyle(EmPressStyle())
                            .scaleEffect(audioManager.playerState == .loading ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: audioManager.playerState)

                            // Next
                            Button(action: {
                                audioManager.skipToNext()
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 30, weight: .medium))
                                    .foregroundColor(themeManager.accentColor)
                            }
                            .buttonStyle(EmPressStyle())
                        }

                        // Additional controls
                        HStack(spacing: 24) {
                            // Repeat mode
                            Button(action: {
                                let modes: [RepeatMode] = [.off, .verse, .surah, .continuous]
                                if let currentIndex = modes.firstIndex(of: audioManager.configuration.repeatMode) {
                                    let nextIndex = (currentIndex + 1) % modes.count
                                    audioManager.updateRepeatMode(modes[nextIndex])
                                }
                            }) {
                                Image(systemName: audioManager.configuration.repeatMode.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(audioManager.configuration.repeatMode == .off ? themeManager.tertiaryText : themeManager.accentColor)
                            }

                            Spacer()

                            // Stop button
                            Button(action: {
                                audioManager.stop()
                                dismiss()
                            }) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(Color(red: 0.86, green: 0.49, blue: 0.45))
                            }
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(EmType.serif(18, .semiBold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    private var legacyBody: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground,
                        themeManager.tertiaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    if let currentPlayback = audioManager.currentPlayback {
                        // Large album art placeholder
                        RoundedRectangle(cornerRadius: 24)
                            .fill(themeManager.accentGradient)
                            .frame(height: 280)
                            .overlay(
                                VStack(spacing: 16) {
                                    Image(systemName: "book.fill")
                                        .font(.system(size: 64, weight: .light))
                                        .foregroundColor(.white)
                                    
                                    Text("Surah \(currentPlayback.surahNumber)")
                                        .font(.system(size: 24, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                            )
                            .shadow(color: themeManager.semanticBlue.opacity(0.3), radius: 20)
                        
                        // Track info
                        VStack(spacing: 8) {
                            Text(currentPlayback.surahName)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(themeManager.primaryText)
                            
                            Button(action: {
                                showingReciterSelection = true
                            }) {
                                Text(currentPlayback.reciter.nameEnglish)
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }
                        }
                        
                        // Progress section
                        VStack(spacing: 16) {
                            Slider(
                                value: Binding(
                                    get: { audioManager.currentTime },
                                    set: { audioManager.seek(to: $0) }
                                ),
                                in: 0...max(audioManager.duration, 1)
                            )
                            .tint(themeManager.semanticBlue)
                            
                            HStack {
                                Text(formatTime(audioManager.currentTime))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.tertiaryText)
                                
                                Spacer()
                                
                                Text(formatTime(audioManager.duration))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(themeManager.tertiaryText)
                            }
                        }
                        
                        // Main controls
                        HStack(spacing: 40) {
                            // Previous
                            Button(action: {
                                audioManager.skipToPrevious()
                            }) {
                                Image(systemName: "backward.fill")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(themeManager.primaryText)
                            }
                            
                            // Play/Pause
                            Button(action: {
                                audioManager.togglePlayPause()
                            }) {
                                Image(systemName: audioManager.playerState == .playing ? "pause.circle.fill" : "play.circle.fill")
                                    .font(.system(size: 72, weight: .medium))
                                    .foregroundStyle(themeManager.accentGradient)
                                    .shadow(color: themeManager.semanticBlue.opacity(0.4), radius: 12)
                            }
                            .scaleEffect(audioManager.playerState == .loading ? 1.1 : 1.0)
                            .animation(.easeInOut(duration: 0.3), value: audioManager.playerState)
                            
                            // Next
                            Button(action: {
                                audioManager.skipToNext()
                            }) {
                                Image(systemName: "forward.fill")
                                    .font(.system(size: 32, weight: .medium))
                                    .foregroundColor(themeManager.primaryText)
                            }
                        }
                        
                        // Additional controls
                        HStack(spacing: 24) {
                            // Repeat mode
                            Button(action: {
                                let modes: [RepeatMode] = [.off, .verse, .surah, .continuous]
                                if let currentIndex = modes.firstIndex(of: audioManager.configuration.repeatMode) {
                                    let nextIndex = (currentIndex + 1) % modes.count
                                    audioManager.updateRepeatMode(modes[nextIndex])
                                }
                            }) {
                                Image(systemName: audioManager.configuration.repeatMode.icon)
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(audioManager.configuration.repeatMode == .off ? themeManager.tertiaryText : .blue)
                            }
                            
                            Spacer()
                            
                            // Speed control (disabled for accurate verse timing)
                            /*
                            Menu {
                                ForEach([0.75, 1.0, 1.25, 1.5], id: \.self) { speed in
                                    Button("\(speed, specifier: "%.2f")x") {
                                        audioManager.updatePlaybackSpeed(speed)
                                    }
                                }
                            } label: {
                                Text("\(audioManager.configuration.playbackSpeed, specifier: "%.2f")x")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(themeManager.primaryText)
                            }
                            */
                            
                            Spacer()
                            
                            // Stop button
                            Button(action: {
                                audioManager.stop()
                                dismiss()
                            }) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            }
            .navigationTitle("Now Playing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.semanticBlue)
                }
            }
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct ReciterSelectionView: View {
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldBody
            } else {
                legacyBody
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
    }

    private var emeraldBody: some View {
        NavigationView {
            ZStack {
                EmeraldBackground()

                ScrollView {
                    VStack(spacing: 18) {
                        EmHeading(eyebrow: "Recitation", title: "Select Reciter", center: true)

                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                            ForEach(Reciter.popularReciters) { reciter in
                                ReciterCard(
                                    reciter: reciter,
                                    isSelected: reciter.id == audioManager.configuration.selectedReciter.id
                                ) {
                                    audioManager.updateReciter(reciter)
                                    dismiss()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 12)
                    .padding(.bottom, 40)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") { dismiss() }
                        .font(EmType.serif(18, .semiBold))
                        .foregroundColor(themeManager.accentColor)
                }
            }
        }
    }

    private var legacyBody: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        themeManager.primaryBackground,
                        themeManager.secondaryBackground
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(Reciter.popularReciters) { reciter in
                            ReciterCard(
                                reciter: reciter,
                                isSelected: reciter.id == audioManager.configuration.selectedReciter.id
                            ) {
                                audioManager.updateReciter(reciter)
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Select Reciter")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.semanticBlue)
                }
            }
        }
    }
}

struct ReciterCard: View {
    let reciter: Reciter
    let isSelected: Bool
    let onSelect: () -> Void
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        Button(action: onSelect) {
            EmCard(elevated: isSelected, cornerRadius: 16) {
                VStack(spacing: 12) {
                    // Reciter avatar
                    ZStack {
                        Circle()
                            .fill(isSelected ? AnyShapeStyle(themeManager.accentGradient) : AnyShapeStyle(themeManager.accentChip))
                            .frame(width: 76, height: 76)
                            .overlay(Circle().stroke(themeManager.strokeColor, lineWidth: 1))
                            .overlay(
                                Text(String(reciter.nameEnglish.prefix(2)).uppercased())
                                    .font(EmType.serif(24, .semiBold))
                                    .foregroundColor(isSelected ? themeManager.onAccentText : themeManager.accentColor)
                            )
                            .shadow(color: isSelected ? themeManager.accentColor.opacity(0.35) : .clear, radius: 12, y: 4)
                    }

                    VStack(spacing: 4) {
                        Text(reciter.nameEnglish)
                            .font(EmType.serif(18, .semiBold))
                            .foregroundColor(themeManager.primaryText)
                            .multilineTextAlignment(.center)

                        if !reciter.description.isEmpty {
                            Text(reciter.description)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.tertiaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(16)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? themeManager.accentColor : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(EmPressStyle())
    }

    private var legacyBody: some View {
        Button(action: onSelect) {
            VStack(spacing: 12) {
                // Reciter avatar placeholder
                ZStack {
                    Circle()
                        .fill(themeManager.accentGradient)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(String(reciter.nameEnglish.prefix(2)).uppercased())
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: themeManager.semanticBlue.opacity(0.4), radius: 8)
                    
                }
                
                VStack(spacing: 4) {
                    Text(reciter.nameEnglish)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.center)
                    
                    if !reciter.description.isEmpty {
                        Text(reciter.description)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    }
                    
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(
                                isSelected ? themeManager.semanticBlue : themeManager.strokeColor,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

