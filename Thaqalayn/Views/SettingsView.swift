//
//  SettingsView.swift
//  Thaqalayn
//
//  Centralized settings hub for the app
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var bookmarkManager = BookmarkManager.shared
    @StateObject private var premiumManager = PremiumManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var showingThemeSelection = false
    @State private var showingAuthentication = false
    @State private var showingPremiumPurchase = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background
                themeManager.primaryBackground
                    .ignoresSafeArea()
                
                // Content
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)
                                .frame(width: 40, height: 40)
                        }
                        
                        Spacer()
                        
                        Text("Settings")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Spacer()
                        
                        // Invisible spacer to balance the close button
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 40, height: 40)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 20)
                    
                    // Settings content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Appearance Section
                            SettingsSection(title: "Appearance") {
                                VStack(spacing: 12) {
                                    // Theme selection
                                    SettingsRow(
                                        icon: "paintbrush.fill",
                                        title: "Theme",
                                        subtitle: themeManager.selectedTheme.displayName,
                                        iconColor: .purple
                                    ) {
                                        showingThemeSelection = true
                                    }
                                    
                                    // Quick dark/light toggle for modern themes
                                    if themeManager.selectedTheme == .modernDark || themeManager.selectedTheme == .modernLight {
                                        SettingsRow(
                                            icon: themeManager.selectedTheme == .modernDark ? "sun.max.fill" : "moon.fill",
                                            title: "Quick Toggle",
                                            subtitle: themeManager.selectedTheme == .modernDark ? "Switch to Light" : "Switch to Dark",
                                            iconColor: .orange
                                        ) {
                                            themeManager.toggleTheme()
                                        }
                                    }
                                }
                            }
                            
                            // Account Section
                            SettingsSection(title: "Account") {
                                VStack(spacing: 12) {
                                    if bookmarkManager.isAuthenticated {
                                        SettingsRow(
                                            icon: "person.circle.fill",
                                            title: "Account",
                                            subtitle: "Signed in",
                                            iconColor: .green
                                        ) {
                                            // Could navigate to account details
                                        }
                                        
                                        SettingsRow(
                                            icon: "icloud.fill",
                                            title: "Sync Status",
                                            subtitle: "Cloud sync enabled",
                                            iconColor: .blue
                                        ) {
                                            // Could show sync details
                                        }
                                    } else {
                                        SettingsRow(
                                            icon: "person.badge.plus",
                                            title: "Sign In",
                                            subtitle: "Enable cloud sync for bookmarks",
                                            iconColor: .blue
                                        ) {
                                            showingAuthentication = true
                                        }
                                    }
                                    
                                    // Premium Status
                                    SettingsRow(
                                        icon: premiumManager.isPremiumUnlocked ? "crown.fill" : "lock.fill",
                                        title: "Premium Status",
                                        subtitle: premiumManager.isPremiumUnlocked ? "Premium Unlocked" : "Free Version",
                                        iconColor: premiumManager.isPremiumUnlocked ? .yellow : .orange
                                    ) {
                                        if !premiumManager.isPremiumUnlocked {
                                            showingPremiumPurchase = true
                                        }
                                    }
                                }
                            }
                            
                            // Audio Section
                            SettingsSection(title: "Audio") {
                                VStack(spacing: 12) {
                                    SettingsRow(
                                        icon: "speaker.wave.2.fill",
                                        title: "Audio Quality",
                                        subtitle: "High Quality (128kbps)",
                                        iconColor: .indigo
                                    ) {
                                        // Could implement audio quality settings
                                    }
                                    
                                    SettingsRow(
                                        icon: "crown.fill",
                                        title: "Premium Reciters",
                                        subtitle: premiumManager.isPremiumUnlocked ? 
                                                 "\(premiumManager.getPremiumReciters().count) Premium Reciters Unlocked" : 
                                                 "Unlock \(premiumManager.getPremiumReciters().count) additional reciters",
                                        iconColor: .yellow
                                    ) {
                                        if !premiumManager.isPremiumUnlocked {
                                            showingPremiumPurchase = true
                                        }
                                    }
                                }
                            }
                            
                            // App Info Section
                            SettingsSection(title: "About") {
                                VStack(spacing: 12) {
                                    SettingsRow(
                                        icon: "info.circle.fill",
                                        title: "Version",
                                        subtitle: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
                                        iconColor: .gray
                                    ) {
                                        // Could show app info
                                    }
                                    
                                    SettingsRow(
                                        icon: "heart.fill",
                                        title: "Support",
                                        subtitle: "Rate or review the app",
                                        iconColor: .red
                                    ) {
                                        // Could open App Store review
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingThemeSelection) {
            ThemeSelectionView()
        }
        .sheet(isPresented: $showingAuthentication) {
            // You can replace this with your actual AuthenticationView
            Text("Authentication View")
        }
        .sheet(isPresented: $showingPremiumPurchase) {
            PremiumPurchaseSheet()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: () -> Content
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)
                .padding(.horizontal, 4)
            
            VStack(spacing: 0) {
                content()
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.secondaryBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(themeManager.strokeColor, lineWidth: 1)
                    )
            )
        }
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    let action: () -> Void
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(iconColor.opacity(0.2))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(iconColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(themeManager.secondaryText)
                }
                
                Spacer()
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(16)
            .background(
                Rectangle()
                    .fill(Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    SettingsView()
}