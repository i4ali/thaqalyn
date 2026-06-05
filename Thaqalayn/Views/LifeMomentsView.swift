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
                            if themeManager.isMidnightEmerald {
                                VStack(alignment: .leading, spacing: 7) {
                                    Text("GUIDANCE").font(.system(size: 11, weight: .bold)).tracking(3).foregroundColor(themeManager.accentColor)
                                    Text("Life Moments").font(EmType.serif(40, .semiBold)).foregroundColor(themeManager.primaryText)
                                    Text("Find guidance for any situation").font(.system(size: 13.5)).foregroundColor(themeManager.secondaryText)
                                }
                            } else {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Life Moments")
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundColor(themeManager.primaryText)

                                    Text("Find guidance for any situation")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(themeManager.secondaryText)
                                }
                            }

                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

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
                                        .pressable {
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
        .darkScreenAura()
    }
}

struct MomentCard: View {
    let moment: LifeMoment
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        if themeManager.isMidnightEmerald { emeraldBody } else { legacyBody }
    }

    private var emeraldBody: some View {
        EmCard {
            HStack(spacing: 14) {
                EmIconChip(sfSymbol: moment.categoryIcon, size: 46)
                VStack(alignment: .leading, spacing: 4) {
                    Text(moment.situation)
                        .font(EmType.serif(20, .semiBold))
                        .foregroundColor(themeManager.primaryText)
                        .lineLimit(2).multilineTextAlignment(.leading)
                    Text(moment.verseReference.uppercased())
                        .font(.system(size: 11, weight: .bold)).tracking(1)
                        .foregroundColor(themeManager.accentColor)
                }
                Spacer(minLength: 8)
                Image(systemName: "chevron.right")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(themeManager.tertiaryText)
            }
            .padding(16)
        }
        .contentShape(Rectangle())
    }

    private var legacyBody: some View {
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
            RoundedRectangle(cornerRadius: 20)
                .fill(themeManager.selectedTheme == .nightSanctuary ? themeManager.glassSurface : Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
                .shadow(
                    color: themeManager.selectedTheme == .nightSanctuary ? Color.black.opacity(0.45) : Color.black.opacity(0.04),
                    radius: 12, x: 0, y: 4
                )
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
