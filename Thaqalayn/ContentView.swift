//
//  ContentView.swift
//  Thaqalayn
//
//  Main app interface with dark modern design
//

import SwiftUI

struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark gradient background with floating elements
                DarkModernBackground()
                
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
        .preferredColorScheme(.dark)
    }
}

struct DarkModernBackground: View {
    var body: some View {
        ZStack {
            // Base gradient background
            LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16), // #0f172a
                    Color(red: 0.12, green: 0.16, blue: 0.23), // #1e293b
                    Color(red: 0.2, green: 0.25, blue: 0.33)   // #334155
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            
            // Floating gradient orbs
            RadialGradient(
                colors: [
                    Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3), // #6366f1
                    Color.clear
                ],
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [
                    Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.3), // #ec4899
                    Color.clear
                ],
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
            
            RadialGradient(
                colors: [
                    Color(red: 0.55, green: 0.36, blue: 0.96).opacity(0.3), // #8b5cf6
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
    
    var body: some View {
        VStack(spacing: 24) {
            // Floating circles animation
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3),
                                    Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
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
                .foregroundColor(.white)
                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.5), radius: 30)
            
            Text("Experience the Quran like never before\nwith AI-powered Shia commentary")
                .font(.system(size: 18, weight: .light))
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
            
            VStack(spacing: 12) {
                ProgressView()
                    .scaleEffect(1.2)
                    .tint(Color(red: 0.39, green: 0.4, blue: 0.95))
                
                Text("Initializing AI Commentary...")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
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
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 64))
                .foregroundColor(Color(red: 0.93, green: 0.28, blue: 0.6))
                .shadow(color: Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.3), radius: 20)
            
            Text("Error")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .lineLimit(nil)
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 20)
    }
}

struct SurahListView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Modern header with glassmorphism
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Surahs")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("AI-powered Shia Commentary")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    // Profile avatar with gradient
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.39, green: 0.4, blue: 0.95),
                                    Color(red: 0.93, green: 0.28, blue: 0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay(
                            Text("AA")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                        )
                        .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 8)
                }
                
                // Search bar with glassmorphism
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.white.opacity(0.5))
                    
                    TextField("Search surahs...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(.white)
                }
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(.white.opacity(0.1), lineWidth: 1)
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
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.clear,
                                        Color.white.opacity(0.05)
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
                        NavigationLink(destination: SurahDetailView(surahWithTafsir: surahWithTafsir)) {
                            ModernSurahCard(surah: surahWithTafsir.surah)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
        }
    }
}

struct StatCard: View {
    let number: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(number)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [
                            Color(red: 0.39, green: 0.4, blue: 0.95),
                            Color(red: 0.93, green: 0.28, blue: 0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ModernSurahCard: View {
    let surah: Surah
    
    var body: some View {
        HStack(spacing: 16) {
            // Surah number with gradient
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.39, green: 0.4, blue: 0.95),
                                Color(red: 0.55, green: 0.36, blue: 0.96)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
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
                            .foregroundColor(.white)
                        
                        Text(surah.englishNameTranslation)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Text(surah.arabicName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "book")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        Text("\(surah.versesCount) verses")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "location")
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))
                        Text(surah.revelationType)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.05),
                                    Color(red: 0.93, green: 0.28, blue: 0.6).opacity(0.05)
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
