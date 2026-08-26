//
//  PersonalizeScreen.swift
//  Thaqalayn
//
//  Onboarding Screen 10: Personalize - display name.
//

import SwiftUI

struct PersonalizeScreen: View {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var profile = UserProfileManager.shared
    @Binding var currentPage: Int
    @State private var isVisible = false
    @FocusState private var nameFieldFocused: Bool

    private let maxNameLength = 30

    var body: some View {
        ZStack {
            OnboardingBackground(tilt: .peach)

            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 60)

                    VStack(spacing: 30) {
                        header
                        nameField
                        continueButton
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 60)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear { isVisible = true }
        .onTapGesture { nameFieldFocused = false }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Text("Make it yours")
                .onbFinalTitle()
                .foregroundColor(themeManager.primaryText)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : -20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: isVisible)

            Text("Add your name so the app can greet you. You can change it anytime in Settings.")
                .onbBody()
                .foregroundColor(themeManager.secondaryText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .opacity(isVisible ? 1 : 0)
                .animation(.easeOut(duration: 0.6).delay(0.3), value: isVisible)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("YOUR NAME")
                .onbEyebrow()
                .foregroundColor(themeManager.accentColor)

            HStack(spacing: 12) {
                Image(systemName: "person.fill")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(themeManager.accentColor)
                TextField("Your name", text: $profile.displayName)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .focused($nameFieldFocused)
                    .submitLabel(.done)
                    .onSubmit { nameFieldFocused = false }
                    .onChange(of: profile.displayName) { _, newValue in
                        if newValue.count > maxNameLength {
                            profile.displayName = String(newValue.prefix(maxNameLength))
                        }
                    }
            }
            .onboardingCard(padding: 16)
        }
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 20)
        .animation(.easeOut(duration: 0.6).delay(0.45), value: isVisible)
    }

    private var continueButton: some View {
        Button(action: advance) {
            Text("Continue")
                .font(.system(size: 18, weight: .semibold))
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
        .opacity(isVisible ? 1 : 0)
        .animation(.easeOut(duration: 0.6).delay(0.6), value: isVisible)
    }

    private func advance() {
        nameFieldFocused = false
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) { currentPage += 1 }
    }
}

#Preview {
    PersonalizeScreen(currentPage: .constant(9))
}
