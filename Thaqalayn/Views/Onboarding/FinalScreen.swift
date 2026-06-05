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
    @State private var showingAuthentication = false
    @State private var isVisible = false

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
                        // Continue as Guest (primary)
                        Button(action: onComplete) {
                            HStack {
                                Image(systemName: "book.closed")
                                    .font(.system(size: 18, weight: .semibold))
                                Text("Continue as Guest")
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
                            .foregroundColor(themeManager.onAccentText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color(red: 31/255, green: 22/255, blue: 18/255).opacity(0.07), lineWidth: 1)
                                    )
                            )
                        }
                        .buttonStyle(EmPressStyle())

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
                            .foregroundColor(themeManager.onAccentText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color(red: 31/255, green: 22/255, blue: 18/255).opacity(0.07), lineWidth: 1)
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

#Preview {
    FinalScreen(onComplete: {})
}
