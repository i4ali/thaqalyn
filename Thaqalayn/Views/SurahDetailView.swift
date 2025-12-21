//
//  SurahDetailView.swift
//  Thaqalayn
//
//  Dark modern verse display with glassmorphism
//

import SwiftUI

struct SurahDetailView: View {
    let surahWithTafsir: SurahWithTafsir
    let targetVerse: Int?
    @State private var selectedVerse: VerseWithTafsir?
    @State private var showingTafsir = false
    @State private var fullScreenCommentaryData: (verse: VerseWithTafsir, layer: TafsirLayer)?
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @Environment(\.dismiss) private var dismiss
    
    init(surahWithTafsir: SurahWithTafsir, targetVerse: Int? = nil) {
        self.surahWithTafsir = surahWithTafsir
        self.targetVerse = targetVerse
    }
    
    private var showingFullScreenCommentary: Binding<Bool> {
        Binding<Bool>(
            get: { fullScreenCommentaryData != nil },
            set: { if !$0 { fullScreenCommentaryData = nil } }
        )
    }
    
    var body: some View {
        ZStack {
            // Adaptive gradient background
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
            
            VStack(spacing: 0) {
                // Modern header
                ModernSurahHeader(
                    surah: surahWithTafsir.surah,
                    verses: surahWithTafsir.verses,
                    onBack: { dismiss() }
                )
                
                // Verses scroll view
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(surahWithTafsir.verses) { verse in
                                ModernVerseCard(
                                    verse: verse,
                                    surah: surahWithTafsir.surah,
                                    bookmarkManager: bookmarkManager
                                ) {
                                    selectedVerse = verse
                                    fullScreenCommentaryData = (verse: verse, layer: .foundation)
                                }
                                .id("verse_\(verse.number)")
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 40)
                    }
                    .onAppear {
                        if let targetVerse = targetVerse {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.8)) {
                                    proxy.scrollTo("verse_\(targetVerse)", anchor: .center)
                                }
                            }
                        }
                    }
                    .onChange(of: audioManager.currentPlayback?.verseNumber) { _, newVerse in
                        // Auto-scroll to currently playing verse
                        if let verseNumber = newVerse {
                            withAnimation(.easeInOut(duration: 0.5)) {
                                proxy.scrollTo("verse_\(verseNumber)", anchor: .center)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(themeManager.colorScheme)
        .overlay(alignment: .bottom) {
            if audioManager.currentPlayback != nil {
                SurahAudioPlayerView()
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: audioManager.currentPlayback != nil)
            }
        }
        .fullScreenCover(isPresented: showingFullScreenCommentary) {
            if let data = fullScreenCommentaryData {
                FullScreenCommentaryView(
                    verse: data.verse, 
                    surah: surahWithTafsir.surah, 
                    initialLayer: data.layer
                )
            }
        }
    }
}

struct ModernSurahHeader: View {
    let surah: Surah
    let verses: [VerseWithTafsir]
    let onBack: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var audioManager = AudioManager.shared

    var body: some View {
        VStack(spacing: 16) {
            // Navigation (different for warm theme)
            if themeManager.selectedTheme == .warmInviting {
                // Warm theme: Simple back button
                HStack {
                    Button(action: onBack) {
                        Text("←")
                            .font(.system(size: 20))
                            .foregroundColor(Color(red: 0.176, green: 0.145, blue: 0.125))
                            .frame(width: 40, height: 40)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.black.opacity(0.1))
                            )
                    }
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)
            } else {
                // Other themes: Original centered title style
                HStack {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                            .frame(width: 36, height: 36)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(themeManager.strokeColor, lineWidth: 1)
                                    )
                            )
                    }

                    Spacer()

                    Text(surah.englishName)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)

                    Spacer()
                }
            }

            // Surah info card
            VStack(spacing: themeManager.selectedTheme == .warmInviting ? 16 : 12) {
                Text(surah.arabicName)
                    .font(.system(size: themeManager.selectedTheme == .warmInviting ? 32 : 28, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center)

                Text(surah.englishNameTranslation)
                    .font(.system(size: themeManager.selectedTheme == .warmInviting ? 18 : 16, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .italic()

                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        if themeManager.selectedTheme == .warmInviting {
                            Text("📖")
                                .font(.system(size: 14))
                        } else {
                            Image(systemName: "book")
                                .font(.system(size: 12))
                        }
                        Text("\(surah.versesCount) verses")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(themeManager.selectedTheme == .warmInviting ? Color(red: 0.608, green: 0.561, blue: 0.749) : themeManager.tertiaryText)

                    HStack(spacing: 6) {
                        if themeManager.selectedTheme == .warmInviting {
                            Text("📍")
                                .font(.system(size: 14))
                        } else {
                            Image(systemName: "location")
                                .font(.system(size: 12))
                        }
                        Text(surah.revelationType)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(themeManager.selectedTheme == .warmInviting ? Color(red: 0.608, green: 0.561, blue: 0.749) : themeManager.tertiaryText)
                }

                // Play Sequence button (verse-by-verse)
                Button(action: {
                    Task {
                        await audioManager.playVerseSequence(verses, in: surah, startingFrom: 0)
                    }
                }) {
                    HStack(spacing: 8) {
                        if themeManager.selectedTheme == .warmInviting {
                            Text("▶")
                                .font(.system(size: 16))
                        } else {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        Text("Play Sequence")
                            .font(.system(size: themeManager.selectedTheme == .warmInviting ? 17 : 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, themeManager.selectedTheme == .warmInviting ? 32 : 20)
                    .padding(.vertical, themeManager.selectedTheme == .warmInviting ? 14 : 10)
                    .background {
                        if themeManager.selectedTheme == .warmInviting {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.91, green: 0.604, blue: 0.435), Color(red: 0.847, green: 0.541, blue: 0.373)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .shadow(color: Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.3), radius: 12)
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(themeManager.purpleGradient)
                                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), radius: 8)
                        }
                    }
                }
                .padding(.top, 8)
            }
            .padding(themeManager.selectedTheme == .warmInviting ? 28 : 20)
            .background {
                if themeManager.selectedTheme == .warmInviting {
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white)
                        .shadow(color: Color.black.opacity(0.06), radius: 16, x: 0, y: 6)
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            themeManager.floatingOrbColors[0].opacity(0.7),
                                            themeManager.floatingOrbColors[1].opacity(0.7)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                }
            }
        }
        .padding(.horizontal, themeManager.selectedTheme == .warmInviting ? 24 : 20)
        .padding(.top, themeManager.selectedTheme == .warmInviting ? 20 : 60)
        .padding(.bottom, themeManager.selectedTheme == .warmInviting ? 24 : 20)
        .background {
            if themeManager.selectedTheme != .warmInviting {
                Rectangle()
                    .fill(themeManager.glassEffect)
            }
        }
    }
}

struct ModernVerseCard: View {
    let verse: VerseWithTafsir
    let surah: Surah
    let bookmarkManager: BookmarkManager
    let onTafsirTap: () -> Void
    @State private var isPressed = false
    @State private var showingBookmarkFeedback = false
    @State private var showingPaywall = false
    @State private var showingSummary = false
    @State private var canAccessTafsir = false
    @State private var canAccessOverview = false
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var audioManager = AudioManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @StateObject private var progressManager = ProgressManager.shared

    private var isBookmarked: Bool {
        bookmarkManager.isBookmarked(surahNumber: surah.number, verseNumber: verse.number)
    }
    
    private var isCurrentlyPlaying: Bool {
        audioManager.currentPlayback?.verseNumber == verse.number && audioManager.playerState == .playing
    }
    
    private var highlightStroke: LinearGradient {
        if isCurrentlyPlaying {
            return LinearGradient(
                colors: [Color(red: 0.39, green: 0.4, blue: 0.95), Color(red: 0.93, green: 0.27, blue: 0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [themeManager.strokeColor],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
    
    private var shadowColor: Color {
        if isCurrentlyPlaying {
            return Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3)
        } else {
            return Color.black.opacity(0.1)
        }
    }
    
    private var backgroundFill: some ShapeStyle {
        if isCurrentlyPlaying {
            return AnyShapeStyle(themeManager.accentGradient.opacity(0.15))
        } else {
            return AnyShapeStyle(themeManager.glassEffect)
        }
    }
    
    
    private func toggleBookmark() {
        if isBookmarked {
            if let bookmark = bookmarkManager.getBookmark(surahNumber: surah.number, verseNumber: verse.number) {
                bookmarkManager.removeBookmark(id: bookmark.id)
            }
        } else {
            let success = bookmarkManager.addBookmark(
                surahNumber: surah.number,
                verseNumber: verse.number,
                surahName: surah.englishName,
                verseText: verse.arabicText,
                verseTranslation: verse.translation
            )

            if success {
                showingBookmarkFeedback = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    showingBookmarkFeedback = false
                }
            }
        }
    }

    private func toggleVerseRead() {
        let isRead = progressManager.isVerseRead(surahNumber: surah.number, verseNumber: verse.number)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
            if isRead {
                progressManager.unmarkVerseAsRead(surahNumber: surah.number, verseNumber: verse.number)
            } else {
                progressManager.markVerseAsRead(surahNumber: surah.number, verseNumber: verse.number)
            }
        }

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }

    private var verseReadCheckbox: some View {
        Button(action: toggleVerseRead) {
            if themeManager.selectedTheme == .warmInviting {
                warmThemeCheckbox
            } else {
                modernThemeCheckbox
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: progressManager.isVerseRead(surahNumber: surah.number, verseNumber: verse.number))
    }

    private var warmThemeCheckbox: some View {
        let isRead = progressManager.isVerseRead(surahNumber: surah.number, verseNumber: verse.number)

        return ZStack {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    isRead ? Color.green : Color(red: 0.608, green: 0.561, blue: 0.749),
                    lineWidth: 2
                )
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isRead ? Color.green.opacity(0.2) : Color.white)
                )

            if isRead {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 36, height: 36)
    }

    private var modernThemeCheckbox: some View {
        let isRead = progressManager.isVerseRead(surahNumber: surah.number, verseNumber: verse.number)

        return ZStack {
            RoundedRectangle(cornerRadius: 6)
                .strokeBorder(
                    isRead ? Color.green : themeManager.strokeColor,
                    lineWidth: 2
                )
                .frame(width: 24, height: 24)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(isRead ? AnyShapeStyle(Color.green.opacity(0.3)) : AnyShapeStyle(themeManager.glassEffect))
                )

            if isRead {
                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 36, height: 36)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: themeManager.selectedTheme == .warmInviting ? 20 : 16) {
            // Verse number and actions
            HStack {
                // Verse number circle
                if themeManager.selectedTheme == .warmInviting {
                    // Warm theme: Circle with purple border only
                    Circle()
                        .strokeBorder(Color(red: 0.608, green: 0.561, blue: 0.749), lineWidth: 2)
                        .frame(width: 36, height: 36)
                        .overlay(
                            Text("\(verse.number)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(Color(red: 0.608, green: 0.561, blue: 0.749))
                        )
                } else {
                    // Other themes: Filled circle
                    Circle()
                        .fill(themeManager.accentGradient)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("\(verse.number)")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)
                }

                Spacer()

                HStack(spacing: 12) {
                    // Play button
                    Button(action: {
                        Task {
                            await audioManager.playVerse(verse, in: surah)
                        }
                    }) {
                        if themeManager.selectedTheme == .warmInviting {
                            // Warm theme: Circular button with light purple background
                            Text(isCurrentlyPlaying ? "⏸" : "▶")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 0.608, green: 0.561, blue: 0.749))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.1))
                                )
                        } else {
                            // Other themes: Original style
                            Image(systemName: isCurrentlyPlaying ? "pause.fill" : "play.fill")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(isCurrentlyPlaying ? .white : themeManager.primaryText)
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isCurrentlyPlaying ? AnyShapeStyle(themeManager.accentGradient) : AnyShapeStyle(themeManager.glassEffect))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(isCurrentlyPlaying ? Color.clear : themeManager.strokeColor, lineWidth: 1)
                                        )
                                )
                                .shadow(color: isCurrentlyPlaying ? Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4) : Color.clear, radius: 8)
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: isCurrentlyPlaying)

                    // Bookmark button
                    Button(action: toggleBookmark) {
                        if themeManager.selectedTheme == .warmInviting {
                            // Warm theme: Circular button with light orange background
                            Text(isBookmarked ? "♥" : "♡")
                                .font(.system(size: 18))
                                .foregroundColor(Color(red: 0.91, green: 0.604, blue: 0.435))
                                .frame(width: 36, height: 36)
                                .background(
                                    Circle()
                                        .fill(Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.1))
                                )
                        } else {
                            // Other themes: Original style
                            Image(systemName: isBookmarked ? "heart.fill" : "heart")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(isBookmarked ? .pink : themeManager.secondaryText)
                                .frame(width: 36, height: 36)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(themeManager.glassEffect)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(themeManager.strokeColor, lineWidth: 1)
                                        )
                                )
                        }
                    }
                    .scaleEffect(showingBookmarkFeedback ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingBookmarkFeedback)

                    // Verse read checkbox
                    verseReadCheckbox
                }
            }
            .onAppear {
                // Check premium access when view appears (synchronous, works offline)
                canAccessTafsir = PremiumManager.shared.canAccessTafsir(surahNumber: surah.number)
                canAccessOverview = PremiumManager.shared.canAccessOverview(surahNumber: surah.number)
            }
            .onChange(of: premiumManager.isPremium) { _, _ in
                // Update access when premium status changes
                canAccessTafsir = PremiumManager.shared.canAccessTafsir(surahNumber: surah.number)
                canAccessOverview = PremiumManager.shared.canAccessOverview(surahNumber: surah.number)
            }

            // Arabic text
            Text(verse.arabicText)
                .font(.system(size: themeManager.selectedTheme == .warmInviting ? 26 : 24, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineSpacing(themeManager.selectedTheme == .warmInviting ? 26 : 8)  // line-height: 2 = lineSpacing equals font size

            // English translation
            Text(verse.translation)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .lineSpacing(4)

            // Commentary buttons (theme-adaptive for all themes)
            // Split button design: Summary (left) + Full Commentary (right)
            if themeManager.selectedTheme == .warmInviting {
                warmInvitingSplitButtons
            } else {
                modernSplitButtons
            }
        }
        .padding(themeManager.selectedTheme == .warmInviting ? 24 : 24)
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(backgroundFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                highlightStroke,
                                lineWidth: isCurrentlyPlaying ? 2 : 1
                            )
                    )
                    .shadow(
                        color: shadowColor,
                        radius: isCurrentlyPlaying ? 12 : 8,
                        y: 4
                    )
            }
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeInOut(duration: 0.3), value: isCurrentlyPlaying)
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingSummary) {
            VerseSummaryView(
                verse: verse,
                surah: surah,
                onViewFullCommentary: {
                    if !canAccessTafsir && surah.number > 1 {
                        showingPaywall = true
                    } else if verse.tafsir != nil {
                        onTafsirTap()
                    }
                }
            )
        }
    }

    // MARK: - Split Button Variations

    private var warmInvitingSplitButtons: some View {
        HStack(spacing: 12) {
            // Overview button (shows layer2 classical commentary)
            Button(action: {
                if !canAccessOverview && surah.number > 1 {
                    showingPaywall = true
                } else if verse.tafsir != nil {
                    showingSummary = true
                }
            }) {
                HStack(spacing: 6) {
                    Text("✨")
                        .font(.system(size: 15))
                    Text("Overview")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.91, green: 0.604, blue: 0.435))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.91, green: 0.604, blue: 0.435).opacity(0.1))
                )
            }
            .opacity(verse.tafsir != nil ? 1.0 : 0.5)
            .disabled(verse.tafsir == nil)

            // Full commentary button
            Button(action: {
                if !canAccessTafsir && surah.number > 1 {
                    showingPaywall = true
                } else if verse.tafsir != nil {
                    onTafsirTap()
                }
            }) {
                HStack(spacing: 6) {
                    Text("📖")
                        .font(.system(size: 15))
                    Text("In-Depth")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.608, green: 0.561, blue: 0.749))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.608, green: 0.561, blue: 0.749).opacity(0.1))
                )
            }
        }
    }

    private var modernSplitButtons: some View {
        HStack(spacing: 12) {
            // Overview button (shows layer2 classical commentary)
            Button(action: {
                if !canAccessOverview && surah.number > 1 {
                    showingPaywall = true
                } else if verse.tafsir != nil {
                    showingSummary = true
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Overview")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(verse.tafsir != nil ? themeManager.primaryText : themeManager.tertiaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                )
            }
            .opacity(verse.tafsir != nil ? 1.0 : 0.5)
            .disabled(verse.tafsir == nil)

            // Full commentary button
            Button(action: {
                if !canAccessTafsir && surah.number > 1 {
                    showingPaywall = true
                } else if verse.tafsir != nil {
                    onTafsirTap()
                }
            }) {
                HStack(spacing: 6) {
                    Image(systemName: "book.fill")
                        .font(.system(size: 14, weight: .semibold))
                    Text("In-Depth")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(themeManager.primaryText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
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
}

struct ModernTafsirDetailView: View {
    let verse: VerseWithTafsir
    let surah: Surah
    @State private var selectedLayer: TafsirLayer = .foundation
    @State private var showingFullScreenCommentary = false
    @State private var fullScreenLayer: TafsirLayer = .foundation
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // Adaptive gradient background
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
            
            VStack(spacing: 0) {
                // Header with verse info
                VStack(spacing: 16) {
                    // Navigation
                    HStack {
                        Button("Done") {
                            dismiss()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        
                        Spacer()
                        
                        Text("Commentary")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Spacer()
                        
                        Text("\(surah.englishName) \(verse.number)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    
                    // Verse display
                    VStack(spacing: 12) {
                        Text(verse.arabicText)
                            .font(.system(size: 22, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .lineSpacing(6)
                        
                        Text(verse.translation)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                    }
                    .padding(20)
                    .background(themeManager.purpleGradient)
                    .cornerRadius(16)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)
                .background(
                    Rectangle()
                        .fill(themeManager.glassEffect)
                )
                
                // Layer selector tabs
                ModernTafsirTabs(selectedLayer: $selectedLayer, surah: surah) { layer in
                    // Double-tap handler - open full-screen reader
                    fullScreenLayer = layer
                    showingFullScreenCommentary = true
                }
                
                // Commentary content
                ScrollView {
                    VStack(spacing: 16) {
                        if let tafsirText = DataManager.shared.getTafsirText(for: verse, layer: selectedLayer) {
                            ModernTafsirContent(text: tafsirText, layer: selectedLayer)
                        } else {
                            NoCommentaryView(layer: selectedLayer)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .preferredColorScheme(themeManager.colorScheme)
        .fullScreenCover(isPresented: $showingFullScreenCommentary) {
            FullScreenCommentaryView(
                verse: verse, 
                surah: surah, 
                initialLayer: fullScreenLayer
            )
        }
    }
}

struct ModernTafsirTabs: View {
    @Binding var selectedLayer: TafsirLayer
    let surah: Surah
    let onDoubleTap: (TafsirLayer) -> Void
    @State private var showingPaywall = false
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var premiumManager = PremiumManager.shared

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TafsirLayer.allCases, id: \.self) { layer in
                    layerTabButton(for: layer)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(themeManager.glassEffect)
        )
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView()
        }
    }

    private func layerTabButton(for layer: TafsirLayer) -> some View {
        let isLocked = !premiumManager.canAccessLayer(layer, surahNumber: surah.number)

        return VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text(layerIcon(for: layer))
                    .font(.system(size: 16))

                // Lock icon for locked layers
                if isLocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.yellow)
                }
            }

            Text(layerShortTitle(for: layer))
                .font(.system(size: 12, weight: .semibold))
                .multilineTextAlignment(.center)
        }
        .foregroundColor(
            isLocked ? themeManager.tertiaryText :
            (selectedLayer == layer ? .white : themeManager.tertiaryText)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(layerBackgroundFill(for: layer, isLocked: isLocked))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            layerStrokeColor(for: layer, isLocked: isLocked),
                            lineWidth: isLocked ? 1.5 : 1
                        )
                )
        )
        .shadow(
            color: selectedLayer == layer && !isLocked ? Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3) : .clear,
            radius: 8
        )
        .opacity(isLocked ? 0.6 : 1.0)
        .onTapGesture {
            if isLocked {
                showingPaywall = true
            } else {
                selectedLayer = layer
            }
        }
        .onTapGesture(count: 2) {
            if !isLocked {
                // Double-tap to open full-screen reader (only for unlocked layers)
                onDoubleTap(layer)
            }
        }
    }

    private func layerBackgroundFill(for layer: TafsirLayer, isLocked: Bool) -> AnyShapeStyle {
        if selectedLayer == layer && !isLocked {
            return AnyShapeStyle(themeManager.purpleGradient)
        } else if isLocked {
            return AnyShapeStyle(themeManager.tertiaryBackground.opacity(0.2))
        } else {
            return AnyShapeStyle(Color.clear)
        }
    }

    private func layerStrokeColor(for layer: TafsirLayer, isLocked: Bool) -> Color {
        if isLocked {
            return Color.yellow.opacity(0.4)
        } else if selectedLayer == layer {
            return .clear
        } else {
            return themeManager.strokeColor
        }
    }
    
    private func layerIcon(for layer: TafsirLayer) -> String {
        switch layer {
        case .foundation: return "🏛️"
        case .classical: return "📚"
        case .contemporary: return "🌍"
        case .ahlulBayt: return "⭐"
        case .comparative: return "⚖️"
        }
    }
    
    private func layerShortTitle(for layer: TafsirLayer) -> String {
        switch layer {
        case .foundation: return "Foundation"
        case .classical: return "Classical"
        case .contemporary: return "Modern"
        case .ahlulBayt: return "Ahlul Bayt"
        case .comparative: return "Comparative"
        }
    }
}

struct ModernTafsirContent: View {
    let text: String
    let layer: TafsirLayer
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Layer header
            layerHeaderView
            
            // Display tafsir text directly without section parsing
            simpleContentView
        }
        .padding(20)
        .background(backgroundView)
    }
    
    private var layerHeaderView: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(layerGradient(for: layer))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(layerIcon(for: layer))
                        .font(.system(size: 18))
                )
                .shadow(color: layerShadowColor(for: layer), radius: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(layer.title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Text(layer.description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
        }
    }
    
    private var simpleContentView: some View {
        ScrollView {
            Text(text)
                .font(.system(size: 15, weight: .regular))
                .foregroundColor(themeManager.primaryText)
                .lineSpacing(6)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxHeight: 300)
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(themeManager.glassEffect)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(themeManager.strokeColor, lineWidth: 1)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .fill(layerGradient(for: layer).opacity(0.05))
            )
    }
    
    private func layerIcon(for layer: TafsirLayer) -> String {
        switch layer {
        case .foundation: return "🏛️"
        case .classical: return "📚"
        case .contemporary: return "🌍"
        case .ahlulBayt: return "⭐"
        case .comparative: return "⚖️"
        }
    }
    
    private func layerGradient(for layer: TafsirLayer) -> LinearGradient {
        switch layer {
        case .foundation:
            return LinearGradient(colors: [Color.blue, Color.indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .classical:
            return LinearGradient(colors: [Color.green, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .contemporary:
            return LinearGradient(colors: [Color.orange, Color.yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .ahlulBayt:
            return LinearGradient(colors: [Color.purple, Color.pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .comparative:
            return LinearGradient(colors: [Color.indigo, Color.teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
    
    private func layerShadowColor(for layer: TafsirLayer) -> Color {
        switch layer {
        case .foundation: return .blue.opacity(0.3)
        case .classical: return .green.opacity(0.3)
        case .contemporary: return .orange.opacity(0.3)
        case .ahlulBayt: return .purple.opacity(0.3)
        case .comparative: return .indigo.opacity(0.3)
        }
    }
}

struct NoCommentaryView: View {
    let layer: TafsirLayer
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 48))
                .foregroundColor(themeManager.tertiaryText)
            
            Text("No commentary available")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
            
            Text("for \(layer.title)")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
}

// Legacy views kept for compatibility
struct SurahHeaderView: View {
    let surah: Surah
    
    var body: some View {
        VStack(spacing: 12) {
            Text(surah.arabicName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(surah.englishName)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(surah.englishNameTranslation)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .italic()
            
            HStack {
                Label("\(surah.versesCount) verses", systemImage: "text.alignleft")
                Spacer()
                Label(surah.revelationType, systemImage: "location")
            }
            .font(.caption)
            .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct VerseCardView: View {
    let verse: VerseWithTafsir
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Verse number
            HStack {
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 30, height: 30)
                    Text("\(verse.number)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
                Spacer()
                if verse.tafsir != nil {
                    Button(action: onTap) {
                        HStack(spacing: 4) {
                            Image(systemName: "book")
                            Text("Tafsir")
                        }
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    }
                }
            }
            
            // Arabic text
            Text(verse.arabicText)
                .font(.title2)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.horizontal)
            
            // Translation
            Text(verse.translation)
                .font(.body)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct TafsirDetailView: View {
    let verse: VerseWithTafsir
    let surah: Surah
    @State private var selectedLayer: TafsirLayer = .foundation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Verse header
                VStack(spacing: 8) {
                    Text("\(surah.englishName) - Verse \(verse.number)")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text(verse.arabicText)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text(verse.translation)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding()
                .background(Color(.systemGray6))
                
                // Layer selector
                TafsirLayerSelector(selectedLayer: $selectedLayer)
                
                // Tafsir content
                ScrollView {
                    if let tafsirText = DataManager.shared.getTafsirText(for: verse, layer: selectedLayer) {
                        Text(tafsirText)
                            .font(.body)
                            .padding()
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "book.closed")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No commentary available for this layer")
                                .foregroundColor(.secondary)
                                .italic()
                            Text("Layer: \(selectedLayer.title)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Tafsir")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TafsirLayerSelector: View {
    @Binding var selectedLayer: TafsirLayer
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(TafsirLayer.allCases, id: \.self) { layer in
                    Button(action: { selectedLayer = layer }) {
                        VStack(spacing: 4) {
                            Text(layer.title)
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(layer.description)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            selectedLayer == layer ? 
                                Color.accentColor : Color(.systemGray5)
                        )
                        .foregroundColor(
                            selectedLayer == layer ? .white : .primary
                        )
                        .cornerRadius(8)
                    }
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
        .background(Color(.systemGray6))
    }
}

#Preview {
    // Create sample data for preview
    let sampleSurah = Surah(
        number: 1,
        name: "الفاتحة",
        englishName: "Al-Fatiha",
        englishNameTranslation: "The Opening",
        arabicName: "الفاتحة",
        versesCount: 7,
        revelationType: "Meccan"
    )
    
    let sampleVerse = Verse(
        arabicText: "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ",
        translation: "In the name of Allah, the Entirely Merciful, the Especially Merciful.",
        juz: 1,
        manzil: 1,
        page: 1,
        ruku: 1,
        hizbQuarter: 1,
        sajda: SajdaInfo(hasSajda: false, id: nil, recommended: nil)
    )
    
    let sampleTafsir = TafsirVerse(
        layer1: "Foundation commentary...",
        layer2: "Classical commentary...",
        layer3: "Contemporary commentary...",
        layer4: "Ahlul Bayt commentary...",
        layer5: "**Shia Analysis**: Focus on divine justice and Imamate principles. **Sunni Analysis**: Emphasis on Caliphate and community consensus. **Common Ground**: Both traditions share core theological foundations while differing in leadership concepts and jurisprudential approaches.",
        layer1_urdu: "بنیادی تفسیر...",
        layer2_urdu: "کلاسیکی تفسیر...",
        layer3_urdu: "عصری تفسیر...",
        layer4_urdu: "اہل بیت کی تفسیر...",
        layer5_urdu: "**شیعہ تجزیہ**: الہی عدل اور امامت کے اصولوں پر توجہ۔ **سنی تجزیہ**: خلافت اور اجماع امت پر زور۔",
        layer1_ar: nil,
        layer2_ar: nil,
        layer3_ar: nil,
        layer4_ar: nil,
        layer5_ar: nil,
        layer1_fr: nil,
        layer2_fr: nil,
        layer3_fr: nil,
        layer4_fr: nil,
        layer5_fr: nil,
        layer2short: nil,
        layer2short_urdu: nil,
        layer2short_ar: nil,
        layer2short_fr: nil
    )
    
    let sampleVerseWithTafsir = VerseWithTafsir(
        number: 1,
        verse: sampleVerse,
        tafsir: sampleTafsir
    )
    
    let sampleSurahWithTafsir = SurahWithTafsir(
        surah: sampleSurah,
        verses: [sampleVerseWithTafsir]
    )
    
    SurahDetailView(surahWithTafsir: sampleSurahWithTafsir, targetVerse: nil)
}