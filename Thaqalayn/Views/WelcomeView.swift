//
//  WelcomeView.swift
//  Thaqalayn
//
//  First-launch welcome screen. The shrine hero loop (doves over the floodlit
//  shrine at night) greets the user before anything else - wordmark and welcome
//  set in the art's dark sky, feature rows and the account options on emerald
//  below. Reduce Motion / missing video falls back to the procedural doves.
//

import SwiftUI

struct WelcomeView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var showingAuthentication = false

    // The screen is fixed emerald-night regardless of the active theme,
    // matching the onboarding flow it leads into.
    private let gold = Color(hex: "ECD49A")
    private let cream = Color(hex: "F0EDE4")
    private let night = Color(hex: "0A1512")

    var body: some View {
        ZStack {
            OnboardingBackground(tilt: .peach)

            hero

            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 64)

                    Text("ثقلين")
                        .font(.system(size: 54, weight: .light))
                        .foregroundColor(cream)
                        .shadow(color: .black.opacity(0.55), radius: 18, x: 0, y: 2)

                    Text("Welcome to Thaqalayn")
                        .font(EmType.serif(27, .semiBold))
                        .foregroundColor(cream)
                        .shadow(color: .black.opacity(0.5), radius: 12, x: 0, y: 2)
                        .padding(.top, 12)

                    Text("The Qur'an and the Ahlul Bayt, together.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(cream.opacity(0.82))
                        .shadow(color: .black.opacity(0.5), radius: 10, x: 0, y: 1)
                        .padding(.top, 8)

                    Color.clear.frame(height: 150)

                    VStack(spacing: 9) {
                        featureRow(icon: "ph-books-fill",
                                   title: "Five layers of tafsir",
                                   description: "From foundation to Ahlul Bayt wisdom")
                        featureRow(icon: "ph-moon-stars-fill",
                                   title: "Journeys and Deep Dives",
                                   description: "Sacred seasons, surahs, and themes")
                    }

                    continueButton
                        .padding(.top, 20)

                    accountButton
                        .padding(.top, 12)

                    Text("An account syncs your bookmarks and progress across devices.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(cream.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(.dark)
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

    // MARK: - Hero

    private var hero: some View {
        VStack(spacing: 0) {
            Group {
                if ShrineHeroVideoLayer.isAvailable && !reduceMotion {
                    ShrineHeroVideoLayer(isActive: true)
                } else {
                    ShrineDovesLayer()
                }
            }
            .frame(height: 440)
            .clipped()
            .mask(
                LinearGradient(
                    stops: [
                        .init(color: .black, location: 0),
                        .init(color: .black, location: 0.62),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .overlay(
                // Legibility scrim for the wordmark zone; the loop's own scrim
                // is tuned for the hadith card, not a top-set title.
                LinearGradient(
                    stops: [
                        .init(color: night.opacity(0.55), location: 0),
                        .init(color: night.opacity(0.28), location: 0.55),
                        .init(color: .clear, location: 1),
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )

            Spacer(minLength: 0)
        }
        .ignoresSafeArea(edges: .top)
        .allowsHitTesting(false)
    }

    // MARK: - Rows + buttons

    private func featureRow(icon: String, title: String, description: String) -> some View {
        HStack(spacing: 14) {
            PhosphorIcon(name: icon, size: 20)
                .foregroundColor(gold)
                .frame(width: 28, height: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(cream)
                Text(description)
                    .font(.system(size: 12.5, weight: .medium))
                    .foregroundColor(cream.opacity(0.55))
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.07), lineWidth: 1)
                )
        )
    }

    private var continueButton: some View {
        Button(action: {
            markWelcomeAsShown()
            dismiss()
        }) {
            Text("Continue as Guest")
                .font(.system(size: 16.5, weight: .bold))
                .foregroundColor(night)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(LinearGradient(colors: [Color(hex: "F3DFA6"), Color(hex: "E3C078")],
                                             startPoint: .top, endPoint: .bottom))
                )
                .shadow(color: gold.opacity(0.25), radius: 24, x: 0, y: 10)
        }
        .buttonStyle(EmPressStyle())
    }

    private var accountButton: some View {
        Button(action: {
            showingAuthentication = true
        }) {
            Text("Create Account or Sign In")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(cream)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.white.opacity(0.14), lineWidth: 1.5)
                        )
                )
        }
        .buttonStyle(EmPressStyle())
    }

    private func markWelcomeAsShown() {
        UserDefaults.standard.set(true, forKey: "hasShownWelcome")
    }
}

#Preview {
    WelcomeView()
}
