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
        case .warmInviting:
            return Color(red: 0.97, green: 0.96, blue: 1.0) // #F8F5FF
        case .royalAmethyst:
            return Color(red: 0.25, green: 0.14, blue: 0.26)
        case .modernDark:
            return Color(red: 0.06, green: 0.09, blue: 0.16)
        }
    }

    private func getTextColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125) // #2D2520
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70)
        case .modernDark:
            return .white
        }
    }

    private func getSecondaryTextColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .warmInviting:
            return Color(red: 0.42, green: 0.365, blue: 0.329) // #6B5D54
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.85)
        case .modernDark:
            return .white.opacity(0.7)
        }
    }

    private func getAccentColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .warmInviting:
            return Color(red: 0.608, green: 0.561, blue: 0.749) // #9B8FBF
        case .royalAmethyst:
            return Color(red: 0.88, green: 0.70, blue: 0.50)
        case .modernDark:
            return Color(red: 0.39, green: 0.4, blue: 0.95)
        }
    }

    private func getStrokeColor(for theme: ThemeVariant) -> Color {
        switch theme {
        case .warmInviting:
            return Color(red: 0.176, green: 0.145, blue: 0.125).opacity(0.1)
        case .royalAmethyst:
            return Color(red: 0.98, green: 0.91, blue: 0.70).opacity(0.15)
        case .modernDark:
            return .white.opacity(0.1)
        }
    }
}

#Preview {
    ThemeSelectionView()
}