//
//  LifeMomentsView.swift
//  Thaqalayn
//
//  Quranic guidance for life situations with modern glassmorphism design
//

import SwiftUI

struct LifeMomentsView: View {
    @StateObject private var lifeMomentsManager = LifeMomentsManager.shared
    @StateObject private var dataManager = DataManager.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMoment: LifeMoment?
    @State private var navigateToVerse = false

    var body: some View {
        NavigationView {
            ZStack {
                // Adaptive background with floating elements
                AdaptiveModernBackground()

                VStack(spacing: 0) {
                    // Modern header
                    VStack(spacing: 12) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Life Moments")
                                    .font(.system(size: themeManager.selectedTheme == .warmInviting ? 34 : 32, weight: .bold, design: themeManager.selectedTheme == .warmInviting ? .rounded : .default))
                                    .foregroundColor(themeManager.primaryText)

                                Text("Find guidance for any situation")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                            }

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    .background {
                        if themeManager.selectedTheme != .warmInviting {
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
                        }
                    }

                    // Moments list
                    if lifeMomentsManager.isLoading {
                        LoadingSection()
                    } else if let error = lifeMomentsManager.errorMessage {
                        ErrorSection(message: error)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(lifeMomentsManager.moments) { moment in
                                    MomentCard(moment: moment)
                                        .onTapGesture {
                                            selectedMoment = moment
                                            navigateToVerse = true
                                        }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 20)
                        }
                    }
                }

                // Hidden NavigationLink for verse navigation
                if let moment = selectedMoment,
                   let surahData = dataManager.availableSurahs.first(where: { $0.surah.number == moment.surahNumber }) {
                    NavigationLink(
                        destination: SurahDetailView(surahWithTafsir: surahData, targetVerse: moment.verseNumber),
                        isActive: $navigateToVerse
                    ) {
                        EmptyView()
                    }
                    .frame(width: 0, height: 0)
                    .hidden()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                        .foregroundColor(themeManager.accentColor)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(themeManager.colorScheme)
    }
}

struct MomentCard: View {
    let moment: LifeMoment
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            // Category icon
            ZStack {
                Circle()
                    .fill(themeManager.accentGradient)
                    .frame(width: 50, height: 50)
                    .shadow(
                        color: themeManager.accentColor.opacity(0.3),
                        radius: 8
                    )

                Image(systemName: moment.categoryIcon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.white)
            }

            // Situation text
            VStack(alignment: .leading, spacing: 4) {
                Text(moment.situation)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.primaryText)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)

                // Verse reference
                Text(moment.verseReference)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(themeManager.secondaryText)
            }

            Spacer()

            // Chevron
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
        }
        .padding(20)
        .background {
            if themeManager.selectedTheme == .warmInviting {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 1.0, green: 1.0, blue: 1.0).opacity(1.0))
                    .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
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
                                        themeManager.floatingOrbColors[0].opacity(0.5),
                                        themeManager.floatingOrbColors[1].opacity(0.5)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
            }
        }
        .contentShape(Rectangle())
    }
}

private struct LoadingSection: View {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(themeManager.accentColor)

            Text("Loading moments...")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

struct ErrorSection: View {
    let message: String
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(.red)
                .shadow(color: Color.red.opacity(0.3), radius: 20)

            Text("Error")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(themeManager.primaryText)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

#Preview {
    LifeMomentsView()
}
