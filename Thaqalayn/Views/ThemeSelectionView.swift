//
//  ThemeSelectionView.swift
//  Thaqalayn
//
//  Theme selection interface with live preview cards
//

import SwiftUI

struct ThemeSelectionView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
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
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                            .frame(width: 40, height: 40)
                    }
                    
                    Spacer()
                    
                    Text("Choose Theme")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(themeManager.primaryText)
                    
                    Spacer()
                    
                    // Invisible spacer to balance the back button
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                .padding(.bottom, 20)
                
                // Theme selection grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 16),
                        GridItem(.flexible(), spacing: 16)
                    ], spacing: 20) {
                        ForEach(ThemeVariant.allCases, id: \.self) { theme in
                            ThemePreviewCard(
                                theme: theme,
                                isSelected: themeManager.selectedTheme == theme
                            )
                            .onTapGesture {
                                themeManager.setTheme(theme)
                                // Small haptic feedback
                                let impact = UIImpactFeedbackGenerator(style: .light)
                                impact.impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

struct ThemePreviewCard: View {
    let theme: ThemeVariant
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            // Preview content area
            ZStack {
                // Background based on theme
                getBackgroundColor(for: theme)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? getAccentColor(for: theme) : getStrokeColor(for: theme), lineWidth: isSelected ? 2 : 1)
                    )
                
                // Sample content
                VStack(spacing: 8) {
                    // Sample Arabic text
                    Text("بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(getTextColor(for: theme))
                        .multilineTextAlignment(.center)
                    
                    // Sample English text
                    Text("In the name of Allah")
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(getSecondaryTextColor(for: theme))
                    
                    // Sample verse number
                    HStack {
                        Circle()
                            .fill(getAccentColor(for: theme).opacity(0.2))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Text("1")
                                    .font(.system(size: 10, weight: .semibold))
                                    .foregroundColor(getTextColor(for: theme))
                            )
                        Spacer()
                    }
                }
                .padding(12)
            }
            .frame(height: 100)
            
            // Theme info
            VStack(spacing: 4) {
                Text(theme.displayName)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ThemeManager.shared.primaryText)
                
                Text(theme.description)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(ThemeManager.shared.secondaryText)
                    .multilineTextAlignment(.center)
            }
            
            // Selected indicator
            if isSelected {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(getAccentColor(for: theme))
                    
                    Text("Selected")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(getAccentColor(for: theme))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(ThemeManager.shared.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(ThemeManager.shared.strokeColor, lineWidth: 1)
                )
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    // Helper functions to get colors for preview
    private func getBackgroundColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .modernDark:
            return Color(red: 0.06, green: 0.09, blue: 0.16)
        case .modernLight:
            return Color(red: 0.98, green: 0.98, blue: 0.99)
        case .classicLight:
            return Color(red: 0.85, green: 0.92, blue: 0.78)
        case .sepia:
            return Color(red: 0.97, green: 0.94, blue: 0.83)
        case .nightMode:
            return Color(red: 0.0, green: 0.0, blue: 0.0)
        case .mushaf:
            return Color(red: 0.97, green: 0.96, blue: 0.91)
        case .desertSand:
            return Color(red: 0.96, green: 0.89, blue: 0.74)
        case .emeraldClassic:
            return Color(red: 0.94, green: 0.97, blue: 0.94)
        case .highContrast:
            return Color(red: 1.0, green: 1.0, blue: 1.0)
        case .blueLightFilter:
            return Color(red: 0.99, green: 0.96, blue: 0.89)
        }
    }
    
    private func getTextColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .modernDark:
            return .white
        case .modernLight:
            return Color(red: 0.06, green: 0.09, blue: 0.16)
        case .classicLight:
            return Color(red: 0.15, green: 0.10, blue: 0.05)
        case .sepia:
            return Color(red: 0.20, green: 0.15, blue: 0.08)
        case .nightMode:
            return Color(red: 0.96, green: 0.96, blue: 0.86)
        case .mushaf:
            return Color(red: 0.11, green: 0.11, blue: 0.23)
        case .desertSand:
            return Color(red: 0.29, green: 0.17, blue: 0.09)
        case .emeraldClassic:
            return Color(red: 0.11, green: 0.26, blue: 0.20)
        case .highContrast:
            return Color(red: 0.0, green: 0.0, blue: 0.0)
        case .blueLightFilter:
            return Color(red: 0.40, green: 0.26, blue: 0.13)
        }
    }
    
    private func getSecondaryTextColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .modernDark:
            return .white.opacity(0.7)
        case .modernLight:
            return Color(red: 0.2, green: 0.25, blue: 0.33).opacity(0.8)
        case .classicLight:
            return Color(red: 0.15, green: 0.10, blue: 0.05).opacity(0.75)
        case .sepia:
            return Color(red: 0.20, green: 0.15, blue: 0.08).opacity(0.8)
        case .nightMode:
            return Color(red: 0.96, green: 0.96, blue: 0.86).opacity(0.7)
        case .mushaf:
            return Color(red: 0.11, green: 0.11, blue: 0.23).opacity(0.8)
        case .desertSand:
            return Color(red: 0.29, green: 0.17, blue: 0.09).opacity(0.8)
        case .emeraldClassic:
            return Color(red: 0.11, green: 0.26, blue: 0.20).opacity(0.8)
        case .highContrast:
            return Color(red: 0.0, green: 0.0, blue: 0.0).opacity(0.7)
        case .blueLightFilter:
            return Color(red: 0.40, green: 0.26, blue: 0.13).opacity(0.8)
        }
    }
    
    private func getAccentColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .modernDark, .modernLight:
            return Color(red: 0.39, green: 0.4, blue: 0.95)
        case .classicLight:
            return Color(red: 0.2, green: 0.5, blue: 0.3)
        case .sepia:
            return Color(red: 0.55, green: 0.35, blue: 0.15)
        case .nightMode:
            return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .mushaf:
            return Color(red: 0.18, green: 0.35, blue: 0.52)
        case .desertSand:
            return Color(red: 0.80, green: 0.52, blue: 0.25)
        case .emeraldClassic:
            return Color(red: 0.31, green: 0.78, blue: 0.47)
        case .highContrast:
            return Color(red: 0.0, green: 0.4, blue: 0.8)
        case .blueLightFilter:
            return Color(red: 1.0, green: 0.55, blue: 0.0)
        }
    }
    
    private func getStrokeColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .modernDark:
            return .white.opacity(0.1)
        case .modernLight:
            return .black.opacity(0.1)
        case .classicLight:
            return Color(red: 0.15, green: 0.10, blue: 0.05).opacity(0.15)
        case .sepia:
            return Color(red: 0.20, green: 0.15, blue: 0.08).opacity(0.2)
        case .nightMode:
            return Color(red: 0.96, green: 0.96, blue: 0.86).opacity(0.1)
        case .mushaf:
            return Color(red: 0.11, green: 0.11, blue: 0.23).opacity(0.15)
        case .desertSand:
            return Color(red: 0.29, green: 0.17, blue: 0.09).opacity(0.2)
        case .emeraldClassic:
            return Color(red: 0.11, green: 0.26, blue: 0.20).opacity(0.2)
        case .highContrast:
            return Color(red: 0.0, green: 0.0, blue: 0.0).opacity(0.3)
        case .blueLightFilter:
            return Color(red: 0.40, green: 0.26, blue: 0.13).opacity(0.2)
        }
    }
}

#Preview {
    ThemeSelectionView()
}