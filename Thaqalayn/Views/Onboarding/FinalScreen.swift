//
//  FinalScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 5: Theme Selection & Account Setup
//

import SwiftUI

struct FinalScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    @Binding var selectedTheme: ThemeVariant?
    let onComplete: () -> Void
    @State private var showingAuthentication = false
    @State private var isVisible = false

    private let themes: [(theme: ThemeVariant, name: String, description: String)] = [
        (.modernDark, "Modern Dark", "Sleek dark design with floating orbs"),
        (.modernLight, "Modern Light", "Clean light interface"),
        (.classicLight, "Manuscript", "Traditional Islamic manuscript style"),
        (.sepia, "Sepia", "Warm, easy-on-eyes reading mode")
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Begin Your Journey")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(themeManager.primaryText)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : -20)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                        Text("Choose your preferred theme")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .opacity(isVisible ? 1 : 0)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.3), value: isVisible)
                    }

                    // Theme selection grid
                    VStack(spacing: 12) {
                        ForEach(Array(themes.enumerated()), id: \.offset) { index, item in
                            ThemeCard(
                                theme: item.theme,
                                name: item.name,
                                description: item.description,
                                isSelected: selectedTheme == item.theme,
                                isVisible: isVisible,
                                delay: 0.5 + Double(index) * 0.1,
                                onSelect: {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        selectedTheme = item.theme
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 24)

                    // Divider
                    HStack {
                        Rectangle()
                            .fill(themeManager.strokeColor)
                            .frame(height: 1)

                        Text("Account Options")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(themeManager.tertiaryText)
                            .padding(.horizontal, 12)

                        Rectangle()
                            .fill(themeManager.strokeColor)
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.9), value: isVisible)

                    // Account buttons
                    VStack(spacing: 16) {
                        // Continue as Guest (primary)
                        Button(action: onComplete) {
                            HStack {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Continue as Guest")
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

                        // Sign Up
                        Button(action: {
                            showingAuthentication = true
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Create Account")
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

                        // Sign In
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

                        // Account benefits note
                        VStack(spacing: 8) {
                            Text("Account Benefits")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(themeManager.primaryText)

                            Text("Sync bookmarks across devices and save your reading progress")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)
                    }
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(1.0), value: isVisible)
                }

                Spacer(minLength: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.primaryBackground)
        .onAppear {
            isVisible = true
        }
        .fullScreenCover(isPresented: $showingAuthentication) {
            AuthenticationView()
                .onDisappear {
                    if supabaseService.isAuthenticated {
                        onComplete()
                    }
                }
        }
    }
}

// MARK: - Theme Card

struct ThemeCard: View {
    @StateObject private var themeManager = ThemeManager.shared
    let theme: ThemeVariant
    let name: String
    let description: String
    let isSelected: Bool
    let isVisible: Bool
    let delay: Double
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Theme preview circle
                ZStack {
                    Circle()
                        .fill(themePreviewGradient)
                        .frame(width: 50, height: 50)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(themeManager.primaryText)

                    Text(description)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(themeManager.secondaryText)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(Color(red: 0.39, green: 0.4, blue: 0.95))
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(themeManager.glassEffect)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isSelected ? Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.8) : themeManager.strokeColor,
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .shadow(
                color: isSelected ? Color(red: 0.39, green: 0.4, blue: 0.95).opacity(0.3) : Color.clear,
                radius: isSelected ? 12 : 0
            )
        }
        .buttonStyle(PlainButtonStyle())
        .opacity(isVisible ? 1 : 0)
        .offset(x: isVisible ? 0 : -30)
        .animation(Animation.easeOut(duration: 0.6).delay(delay), value: isVisible)
    }

    private var themePreviewGradient: LinearGradient {
        switch theme {
        case .modernDark:
            return LinearGradient(
                colors: [Color(red: 0.1, green: 0.1, blue: 0.15), Color(red: 0.15, green: 0.15, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .modernLight:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.95, blue: 0.97), Color(red: 0.9, green: 0.9, blue: 0.92)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .classicLight:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.94, blue: 0.89), Color(red: 0.91, green: 0.89, blue: 0.82)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .sepia:
            return LinearGradient(
                colors: [Color(red: 0.96, green: 0.94, blue: 0.88), Color(red: 0.92, green: 0.88, blue: 0.78)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .nightMode:
            return LinearGradient(
                colors: [Color.black, Color(white: 0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .mushaf:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.97, blue: 0.92), Color(red: 0.95, green: 0.93, blue: 0.87)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .desertSand:
            return LinearGradient(
                colors: [Color(red: 0.93, green: 0.87, blue: 0.73), Color(red: 0.88, green: 0.81, blue: 0.65)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .emeraldClassic:
            return LinearGradient(
                colors: [Color(red: 0.2, green: 0.4, blue: 0.3), Color(red: 0.15, green: 0.35, blue: 0.25)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .highContrast:
            return LinearGradient(
                colors: [Color.white, Color(white: 0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .blueLightFilter:
            return LinearGradient(
                colors: [Color(red: 1.0, green: 0.95, blue: 0.85), Color(red: 0.98, green: 0.92, blue: 0.80)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .royalAmethyst:
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.2, blue: 0.6), Color(red: 0.3, green: 0.15, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .warmInviting:
            return LinearGradient(
                colors: [Color(red: 0.97, green: 0.96, blue: 1.0), Color(red: 1.0, green: 0.98, blue: 0.96)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

#Preview {
    FinalScreen(selectedTheme: .constant(.modernDark), onComplete: {})
}
