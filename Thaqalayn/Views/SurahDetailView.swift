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
            // Navigation and title
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
            
            // Surah info card
            VStack(spacing: 12) {
                Text(surah.arabicName)
                    .font(.system(size: 28, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .multilineTextAlignment(.center)
                
                Text(surah.englishNameTranslation)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
                    .italic()
                
                HStack(spacing: 20) {
                    HStack(spacing: 6) {
                        Image(systemName: "book")
                            .font(.system(size: 12))
                        Text("\(surah.versesCount) verses")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(themeManager.tertiaryText)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "location")
                            .font(.system(size: 12))
                        Text(surah.revelationType)
                            .font(.system(size: 14, weight: .medium))
                    }
                    .foregroundColor(themeManager.tertiaryText)
                }
                
                // Play Sequence button (verse-by-verse)
                Button(action: {
                    Task {
                        await audioManager.playVerseSequence(verses, in: surah, startingFrom: 0)
                    }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Play Sequence")
                            .font(.system(size: 16, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.purpleGradient)
                            .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), radius: 8)
                    )
                }
                .padding(.top, 8)
            }
            .padding(20)
            .background(
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
            )
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
        .background(
            Rectangle()
                .fill(themeManager.glassEffect)
        )
    }
}

struct ModernVerseCard: View {
    let verse: VerseWithTafsir
    let surah: Surah
    let bookmarkManager: BookmarkManager
    let onTafsirTap: () -> Void
    @State private var isPressed = false
    @State private var showingBookmarkFeedback = false
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var audioManager = AudioManager.shared
    
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Verse number and actions
            HStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Text("\(verse.number)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)
                
                Spacer()
                
                HStack(spacing: 8) {
                    // Play button
                    Button(action: {
                        Task {
                            await audioManager.playVerse(verse, in: surah)
                        }
                    }) {
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
                    .animation(.easeInOut(duration: 0.2), value: isCurrentlyPlaying)
                    
                    // Bookmark button
                    Button(action: toggleBookmark) {
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
                    .scaleEffect(showingBookmarkFeedback ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showingBookmarkFeedback)
                    
                    // Commentary button
                    if verse.tafsir != nil {
                        Button(action: onTafsirTap) {
                            HStack(spacing: 6) {
                                Image(systemName: "book.fill")
                                    .font(.system(size: 12))
                                Text("Commentary")
                                    .font(.system(size: 13, weight: .medium))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(themeManager.purpleGradient)
                            )
                            .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), radius: 4)
                        }
                    }
                }
            }
            
            // Arabic text
            Text(verse.arabicText)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .multilineTextAlignment(.trailing)
                .frame(maxWidth: .infinity, alignment: .trailing)
                .lineSpacing(8)
            
            // English translation
            Text(verse.translation)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .lineSpacing(4)
        }
        .padding(24)
        .background(
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
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .animation(.easeInOut(duration: 0.3), value: isCurrentlyPlaying)
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
                ModernTafsirTabs(selectedLayer: $selectedLayer) { layer in
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
    let onDoubleTap: (TafsirLayer) -> Void
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TafsirLayer.allCases, id: \.self) { layer in
                    VStack(spacing: 4) {
                        Text(layerIcon(for: layer))
                            .font(.system(size: 16))
                        Text(layerShortTitle(for: layer))
                            .font(.system(size: 12, weight: .semibold))
                            .multilineTextAlignment(.center)
                    }
                    .foregroundColor(selectedLayer == layer ? .white : themeManager.tertiaryText)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                                .fill(
                                    selectedLayer == layer ? 
                                    themeManager.purpleGradient :
                                    LinearGradient(colors: [.clear], startPoint: .leading, endPoint: .trailing)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedLayer == layer ? .clear : themeManager.strokeColor, lineWidth: 1)
                                )
                        )
                        .shadow(
                        color: selectedLayer == layer ? Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3) : .clear,
                        radius: 8
                    )
                    .onTapGesture {
                        selectedLayer = layer
                    }
                    .onTapGesture(count: 2) {
                        // Double-tap to open full-screen reader
                        onDoubleTap(layer)
                    }
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(themeManager.glassEffect)
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
        layer5_urdu: "**شیعہ تجزیہ**: الہی عدل اور امامت کے اصولوں پر توجہ۔ **سنی تجزیہ**: خلافت اور اجماع امت پر زور۔"
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