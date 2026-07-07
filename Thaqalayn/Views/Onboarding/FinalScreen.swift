//
//  FinalScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 10: Account Setup
//

import SwiftUI

struct FinalScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var supabaseService = SupabaseService.shared
    let onComplete: () -> Void
    @State private var authMode: AuthMode?
    @State private var isVisible = false

    /// Which mode to open the auth screen in. Carried by the cover's `item` so
    /// the presented view is always built with the correct mode (an isPresented
    /// flag plus a separate mode state races and can read the stale value).
    private enum AuthMode: Identifiable {
        case signIn, signUp
        var id: Int { self == .signIn ? 0 : 1 }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 60)

                VStack(spacing: 40) {
                    // Header
                    VStack(spacing: 16) {
                        Text("Begin Your Journey")
                            .onbFinalTitle()
                            .foregroundColor(themeManager.primaryText)
                            .opacity(isVisible ? 1 : 0)
                            .offset(y: isVisible ? 0 : -20)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.2), value: isVisible)

                        Text("Sync your reading progress and bookmarks across devices")
                            .onbBody()
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                            .opacity(isVisible ? 1 : 0)
                            .animation(Animation.easeOut(duration: 0.6).delay(0.3), value: isVisible)
                    }

                    // Account buttons
                    VStack(spacing: 16) {
                        // Create Account (primary)
                        Button(action: {
                            authMode = .signUp
                        }) {
                            HStack {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Create Account")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "1A1408"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(LinearGradient(colors: [Color(hex: "ECD49A"), Color(hex: "D6B25E")],
                                                         startPoint: .topLeading, endPoint: .bottomTrailing))
                            )
                            .shadow(color: Color(hex: "ECD49A").opacity(0.35), radius: 14, y: 10)
                        }
                        .buttonStyle(EmPressStyle())

                        // Sign In (secondary)
                        Button(action: {
                            authMode = .signIn
                        }) {
                            HStack {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Sign In")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(Color(hex: "ECD49A"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color(hex: "ECD49A").opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color(hex: "ECD49A").opacity(0.5), lineWidth: 1.5)
                                    )
                            )
                        }
                        .buttonStyle(EmPressStyle())

                        // Account benefits note
                        VStack(spacing: 8) {
                            HStack(spacing: 8) {
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(ThemeManager.chipGold.fg)
                                    .frame(width: 24, height: 24)
                                    .background(RoundedRectangle(cornerRadius: 8).fill(ThemeManager.chipGold.bg))
                                Text("Account Benefits")
                                    .onbCardTitle()
                                    .foregroundColor(themeManager.primaryText)
                            }

                            Text("Sync bookmarks across devices and save your reading progress")
                                .onbCaption()
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .onboardingCard(padding: 16)
                        .padding(.top, 8)

                        // Continue as Guest (quiet opt-out)
                        Button(action: onComplete) {
                            HStack(spacing: 7) {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Continue as Guest")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                            .foregroundColor(themeManager.secondaryText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                        }
                        .buttonStyle(EmPressStyle())
                        .padding(.top, 4)
                    }
                    .padding(.horizontal, 24)
                    .opacity(isVisible ? 1 : 0)
                    .animation(Animation.easeOut(duration: 0.6).delay(0.5), value: isVisible)
                }

                Spacer(minLength: 60)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(OnboardingBackground(tilt: .peach))
        .onAppear {
            isVisible = true
        }
        .fullScreenCover(item: $authMode) { mode in
            AuthenticationView(startInSignUp: mode == .signUp)
                .onDisappear {
                    if supabaseService.isAuthenticated {
                        onComplete()
                    }
                }
        }
    }
}

#Preview {
    FinalScreen(onComplete: {})
}
