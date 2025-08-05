//
//  ContentView.swift
//  Thaqalayn
//
//  Main app interface with dark modern design
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background with floating elements
                AdaptiveModernBackground()
                
                Group {
                    if dataManager.isLoading {
                        LoadingView()
                    } else if let errorMessage = dataManager.errorMessage {
                        ErrorView(message: errorMessage)
                    } else {
                        SurahListView()
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Force stack style for iPhone
        .preferredColorScheme(themeManager.colorScheme)
    }
}

struct AdaptiveModernBackground: View {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.secondaryBackground,
                    themeManager.tertiaryBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating gradient orbs
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[0],
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[1],
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[2],
                    Color.clear
                ],
                center: .center,
                startRadius: 0,
                endRadius: 200
            )
        }
        .ignoresSafeArea()
    }
}

struct LoadingView: View {
    @State private var isAnimating = false
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 24) {
            // Floating circles animation
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(themeManager.accentGradient.opacity(0.3))
                        .frame(width: 60 - CGFloat(index * 10), height: 60 - CGFloat(index * 10))
                        .blur(radius: 5)
                        .offset(y: isAnimating ? -20 : 20)
                        .animation(
                            Animation.easeInOut(duration: 2.0)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.3),
                            value: isAnimating
                        )
                }
            }
            .frame(height: 80)
            
            Text("ثقلين")
                .font(.system(size: 56, weight: .light, design: .default))
                .foregroundColor(themeManager.primaryText)
                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.5), radius: 30)
            
            Text("Experience the Quran like never before\nwith AI-powered Shia commentary")
                .font(.system(size: 18, weight: .light))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(Color(red: 0.39, green: 0.4, blue: 0.95))
                
                Text("Initializing AI Commentary...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .padding(60)
        .onAppear {
            isAnimating = true
        }
    }
}

struct ErrorView: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(red: 0.93, green: 0.28, blue: 0.6))
                .shadow(color: Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.3), radius: 20)
            
            Text("Error")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(themeManager.primaryText)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct SurahListView: View {
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @State private var searchText = ""
    @State private var showingBookmarks = false
    @State private var navigateToSurah: SurahWithTafsir?
    @State private var targetVerse: Int?
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern header with glassmorphism
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Surahs")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text("AI-powered Shia Commentary")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    HStack(spacing: 12) {
                        // Bookmarks button
                        Button(action: { showingBookmarks = true }) {
                            ZStack {
                                Image(systemName: "heart")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(themeManager.primaryText)
                                
                                if bookmarkManager.bookmarks.count > 0 {
                                    Circle()
                                        .fill(Color.pink)
                                        .frame(width: 12, height: 12)
                                        .overlay(
                                            Text("\(bookmarkManager.bookmarks.count)")
                                                .font(.system(size: 8, weight: .bold))
                                                .foregroundColor(.white)
                                        )
                                        .offset(x: 12, y: -12)
                                }
                            }
                            .frame(width: 40, height: 40)
                            .background(
                                Circle()
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        Circle()
                                            .stroke(themeManager.strokeColor, lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Theme toggle button
                        Button(action: {
                            themeManager.toggleTheme()
                        }) {
                            Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(themeManager.glassEffect)
                                        .overlay(
                                            Circle()
                                                .stroke(themeManager.strokeColor, lineWidth: 1)
                                        )
                                )
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        // Profile avatar with gradient
                        Circle()
                            .fill(themeManager.accentGradient)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Text("AA")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                            )
                            .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)
                    }
                }
                
                // Search bar with glassmorphism
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(themeManager.tertiaryText)
                    
                    TextField("Search surahs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(themeManager.primaryText)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(themeManager.glassEffect)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(themeManager.strokeColor, lineWidth: 1)
                        )
                )
                
                // Stats cards
                HStack(spacing: 12) {
                    StatCard(number: "7", label: "Available")
                    StatCard(number: "\(dataManager.availableSurahs.reduce(0) { $0 + $1.surah.versesCount })", label: "Verses")
                    StatCard(number: "4", label: "Layers")
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 20)
            .background(
                Rectangle()
                    .fill(themeManager.glassEffect)
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        themeManager.isDarkMode ? Color.white.opacity(0.05) : Color.black.opacity(0.05)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                    )
            )
            
            // Surah list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(dataManager.availableSurahs.filter { surah in
                        searchText.isEmpty || 
                        surah.surah.englishName.localizedCaseInsensitiveContains(searchText) ||
                        surah.surah.arabicName.contains(searchText)
                    }) { surahWithTafsir in
                        NavigationLink(destination: SurahDetailView(surahWithTafsir: surahWithTafsir, targetVerse: nil)) {
                            ModernSurahCard(surah: surahWithTafsir.surah)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            
            // Hidden NavigationLink for programmatic navigation from bookmarks
            NavigationLink(
                destination: navigateToSurah.map { SurahDetailView(surahWithTafsir: $0, targetVerse: targetVerse) },
                isActive: Binding(
                    get: { navigateToSurah != nil },
                    set: { if !$0 { navigateToSurah = nil; targetVerse = nil } }
                )
            ) {
                EmptyView()
            }
            .hidden()
        }
        .sheet(isPresented: $showingBookmarks) {
            BookmarksView(selectedSurahForNavigation: $navigateToSurah, targetVerse: $targetVerse)
        }
    }
}

struct StatCard: View {
    let number: String
    let label: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(themeManager.accentGradient)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
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

struct ModernSurahCard: View {
    let surah: Surah
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Surah number with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(themeManager.purpleGradient)
                    .frame(width: 48, height: 48)
                    .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)
                
                Text("\(surah.number)")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(surah.englishName)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text(surah.englishNameTranslation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                    }
                    
                    Spacer()
                    
                    Text(surah.arabicName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeManager.primaryText)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "book")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.tertiaryText)
                        Text("\(surah.versesCount) verses")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.system(size: 12))
                            .foregroundColor(themeManager.tertiaryText)
                        Text(surah.revelationType)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                    }
                    
                    Spacer()
                }
            }
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
                                    themeManager.floatingOrbColors[0].opacity(0.5),
                                    themeManager.floatingOrbColors[1].opacity(0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
    }
}

#Preview {
    ContentView()
}
