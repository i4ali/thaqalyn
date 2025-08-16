//
//  WelcomeView.swift
//  Thaqalayn
//
//  Beautiful first launch welcome screen with authentication options
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showingAuthentication = false
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Background gradient with floating orbs
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
            
            // Floating gradient orbs
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[0],
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 250
            )
            
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[1],
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 300
            )
            
            ScrollView {
                VStack(spacing: 40) {
                    Spacer(minLength: 80)
                    
                    // Welcome content
                    VStack(spacing: 32) {
                        // App icon and name
                        VStack(spacing: 20) {
                            // Animated floating circles
                            ZStack {
                                ForEach(0..<3) { index in
                                    Circle()
                                        .fill(themeManager.accentGradient.opacity(0.4))
                                        .frame(width: 80 - CGFloat(index * 15), height: 80 - CGFloat(index * 15))
                                        .blur(radius: 3)
                                        .offset(y: isAnimating ? -10 : 10)
                                        .animation(
                                            Animation.easeInOut(duration: 2.5)
                                                .repeatForever(autoreverses: true)
                                                .delay(Double(index) * 0.4),
                                            value: isAnimating
                                        )
                                }
                            }
                            .frame(height: 100)
                            
                            Text("ثقلين")
                                .font(.system(size: 64, weight: .light, design: .default))
                                .foregroundColor(themeManager.primaryText)
                                .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.6), radius: 25)
                        }
                        
                        // Welcome message
                        VStack(spacing: 16) {
                            Text("Welcome to Thaqalayn")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                                .multilineTextAlignment(.center)
                            
                            Text("Discover the profound depths of the Quran through AI-powered Shia commentary with four layers of scholarly wisdom.")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineLimit(nil)
                        }
                        .padding(.horizontal, 20)
                        
                        // Features highlight
                        VStack(spacing: 16) {
                            FeatureRow(
                                icon: "🏛️",
                                title: "Foundation Layer",
                                description: "Simple explanations and historical context"
                            )
                            
                            FeatureRow(
                                icon: "📚",
                                title: "Classical Shia Commentary",
                                description: "Tabatabai, Tabrisi, and traditional scholars"
                            )
                            
                            FeatureRow(
                                icon: "🌍",
                                title: "Contemporary Insights",
                                description: "Modern perspectives and scientific analysis"
                            )
                            
                            FeatureRow(
                                icon: "⭐",
                                title: "Ahlul Bayt Wisdom",
                                description: "Hadith from the 14 Infallibles"
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Authentication options
                    VStack(spacing: 20) {
                        // Sign up button
                        Button(action: {
                            showingAuthentication = true
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Create Account")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.purpleGradient)
                            )
                            .shadow(color: Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.4), radius: 12)
                        }
                        
                        // Sign in button
                        Button(action: {
                            showingAuthentication = true
                        }) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Sign In")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(themeManager.primaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(themeManager.glassEffect)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(themeManager.strokeColor, lineWidth: 1.5)
                                    )
                            )
                        }
                        
                        // Note about authentication requirement
                        VStack(spacing: 8) {
                            Text("Authentication Required")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                            
                            Text("Please sign in or create an account to access Quranic commentary and sync your bookmarks across devices.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(themeManager.colorScheme)
        .onAppear {
            isAnimating = true
        }
        .fullScreenCover(isPresented: $showingAuthentication) {
            AuthenticationView()
                .onDisappear {
                    // If user completed authentication, dismiss welcome screen
                    if supabaseService.isAuthenticated {
                        markWelcomeAsShown()
                        dismiss()
                    }
                }
        }
    }
    
    private func markWelcomeAsShown() {
        UserDefaults.standard.set(true, forKey: "hasShownWelcome")
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 24))
                .frame(width: 32, height: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                
                Text(description)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.strokeColor, lineWidth: 0.5)
                )
        )
    }
}

#Preview {
    WelcomeView()
}