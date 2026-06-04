//
//  AuthenticationView.swift
//  Thaqalayn
//
//  Modern authentication interface with glassmorphism design
//

import SwiftUI
import AuthenticationServices

struct AuthenticationView: View {
    @StateObject private var supabaseService = SupabaseService.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isSignUp = false
    @State private var showingForgotPassword = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Group {
            if themeManager.isMidnightEmerald {
                emeraldBody
            } else {
                legacyBody
            }
        }
        .navigationBarHidden(true)
        .preferredColorScheme(themeManager.colorScheme)
        .darkScreenAura(starCount: 0)
        .alert("Reset Password", isPresented: $showingForgotPassword) {
            TextField("Email", text: $email)
            Button("Send Reset Link") {
                Task {
                    await sendPasswordReset()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Enter your email address to receive a password reset link.")
        }
    }

    private var legacyBody: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    themeManager.primaryBackground,
                    themeManager.secondaryBackground,
                    themeManager.tertiaryBackground
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating gradient orbs
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[0],
                    Color.clear
                ],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 200
            )
            
            RadialGradient(
                colors: [
                    themeManager.floatingOrbColors[1],
                    Color.clear
                ],
                center: .bottomLeading,
                startRadius: 0,
                endRadius: 250
            )
            
            ScrollView {
                VStack(spacing: 32) {
                    Spacer(minLength: 60)
                    
                    // Header
                    VStack(spacing: 16) {
                        Text("ثقلين")
                            .font(.system(size: 48, weight: .light, design: .default))
                            .foregroundColor(themeManager.primaryText)
                            .shadow(color: themeManager.semanticBlue.opacity(0.5), radius: 20)
                        
                        Text(isSignUp ? "Create Your Account" : "Welcome Back")
                            .font(.system(size: 24, weight: .semibold))
                            .foregroundColor(themeManager.primaryText)
                        
                        Text(isSignUp ? "Join thousands of users exploring Shia commentary" : "Continue your Quranic journey")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Authentication form
                    VStack(spacing: 20) {
                        // Email field
                        ModernTextField(
                            text: $email,
                            placeholder: "Email",
                            icon: "envelope",
                            keyboardType: .emailAddress
                        )
                        
                        // Password field
                        ModernSecureField(
                            text: $password,
                            placeholder: "Password",
                            icon: "lock"
                        )
                        
                        // Confirm password for sign up
                        if isSignUp {
                            ModernSecureField(
                                text: $confirmPassword,
                                placeholder: "Confirm Password",
                                icon: "lock.fill"
                            )
                        }
                        
                        // Error message
                        if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.red)
                                .padding(.horizontal, 16)
                                .multilineTextAlignment(.center)
                        }
                        
                        // Sign in/up button
                        Button(action: performAuthentication) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Text(isSignUp ? "Create Account" : "Sign In")
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(themeManager.purpleGradient)
                            )
                            .shadow(color: themeManager.semanticBlue.opacity(0.3), radius: 8)
                        }
                        .disabled(isLoading || !isFormValid)
                        .opacity(isFormValid ? 1.0 : 0.6)
                        
                        // Forgot password
                        if !isSignUp {
                            Button("Forgot Password?") {
                                showingForgotPassword = true
                            }
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(themeManager.glassEffect)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(themeManager.strokeColor, lineWidth: 1)
                            )
                    )
                    .padding(.horizontal, 20)
                    
                    // Divider
                    HStack {
                        Rectangle()
                            .fill(themeManager.strokeColor)
                            .frame(height: 1)
                        
                        Text("or")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.tertiaryText)
                            .padding(.horizontal, 16)
                        
                        Rectangle()
                            .fill(themeManager.strokeColor)
                            .frame(height: 1)
                    }
                    .padding(.horizontal, 40)
                    
                    // Social sign in options
                    VStack(spacing: 16) {
                        // Apple Sign In
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: handleAppleSignIn
                        )
                        .signInWithAppleButtonStyle(.whiteOutline)
                        .frame(height: 50)
                        
                        // Authentication required message
                        VStack(spacing: 8) {
                            HStack {
                                Image(systemName: "lock.shield")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                                
                                Text("Secure Access Required")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(themeManager.primaryText)
                            }
                            
                            Text("Sign in to access Quranic commentary and sync bookmarks across your devices.")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(themeManager.glassEffect.opacity(0.5))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(themeManager.strokeColor.opacity(0.5), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    // Toggle sign up/in
                    HStack {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)
                        
                        Button(isSignUp ? "Sign In" : "Sign Up") {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isSignUp.toggle()
                                clearForm()
                            }
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(themeManager.semanticBlue)
                    }
                    
                    Spacer(minLength: 40)
                }
            }
        }
    }

    // MARK: - Midnight Emerald

    private var emeraldBody: some View {
        ZStack {
            EmeraldBackground()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 52)

                    // Header
                    VStack(spacing: 14) {
                        Text("ثقلين")
                            .font(EmType.arabic(56))
                            .foregroundColor(themeManager.accentBright)
                            .shadow(color: themeManager.accentColor.opacity(0.35), radius: 24)

                        EmDivider()
                            .frame(width: 120)

                        VStack(spacing: 8) {
                            Text(isSignUp ? "Create Your Account" : "Welcome Back")
                                .font(EmType.serif(38, .semiBold))
                                .foregroundColor(themeManager.primaryText)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)

                            Text(isSignUp ? "Join thousands exploring Shia commentary" : "Continue your Qur'anic journey")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(themeManager.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Authentication form
                    EmCard {
                        VStack(spacing: 16) {
                            EmAuthTextField(
                                text: $email,
                                placeholder: "Email",
                                icon: "envelope",
                                keyboardType: .emailAddress
                            )

                            EmAuthSecureField(
                                text: $password,
                                placeholder: "Password",
                                icon: "lock"
                            )

                            if isSignUp {
                                EmAuthSecureField(
                                    text: $confirmPassword,
                                    placeholder: "Confirm Password",
                                    icon: "lock.fill"
                                )
                            }

                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.system(size: 13.5, weight: .medium))
                                    .foregroundColor(Color(red: 0.86, green: 0.49, blue: 0.45))
                                    .padding(.horizontal, 4)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                            }

                            // Sign in/up button
                            Button(action: performAuthentication) {
                                HStack(spacing: 9) {
                                    if isLoading {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(themeManager.onAccentText)
                                    } else {
                                        Text(isSignUp ? "Create Account" : "Sign In")
                                            .font(.system(size: 15.5, weight: .bold)).tracking(0.3)
                                    }
                                }
                                .foregroundColor(themeManager.onAccentText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    RoundedRectangle(cornerRadius: 15, style: .continuous)
                                        .fill(themeManager.accentGradient)
                                )
                                .shadow(color: themeManager.accentColor.opacity(0.28), radius: 28, x: 0, y: 10)
                            }
                            .buttonStyle(EmPressStyle())
                            .disabled(isLoading || !isFormValid)
                            .opacity(isFormValid ? 1.0 : 0.55)

                            // Forgot password
                            if !isSignUp {
                                Button("Forgot Password?") {
                                    showingForgotPassword = true
                                }
                                .font(.system(size: 13.5, weight: .semibold))
                                .foregroundColor(themeManager.accentColor)
                            }
                        }
                        .padding(22)
                    }
                    .padding(.horizontal, 20)

                    // Divider
                    EmDivider(label: "or")
                        .padding(.horizontal, 40)

                    // Social sign in options
                    VStack(spacing: 16) {
                        // Apple Sign In
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: handleAppleSignIn
                        )
                        .signInWithAppleButtonStyle(.whiteOutline)
                        .frame(height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                        // Authentication required message
                        EmCard(cornerRadius: 16) {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {
                                    Image(systemName: "lock.shield")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundColor(themeManager.accentColor)

                                    Text("Secure Access Required")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(themeManager.primaryText)
                                }

                                Text("Sign in to access Qur'anic commentary and sync bookmarks across your devices.")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(themeManager.secondaryText)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 16)
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal, 20)

                    // Toggle sign up/in
                    HStack(spacing: 5) {
                        Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(themeManager.secondaryText)

                        Button(isSignUp ? "Sign In" : "Sign Up") {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isSignUp.toggle()
                                clearForm()
                            }
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(themeManager.accentColor)
                    }

                    Spacer(minLength: 40)
                }
            }
        }
    }

    private var isFormValid: Bool {
        if isSignUp {
            return !email.isEmpty && 
                   !password.isEmpty && 
                   !confirmPassword.isEmpty &&
                   password.count >= 6 &&
                   password == confirmPassword &&
                   email.contains("@")
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        errorMessage = nil
    }
    
    private func performAuthentication() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                if isSignUp {
                    try await supabaseService.signUp(email: email, password: password)
                    
                    await MainActor.run {
                        if supabaseService.isAuthenticated {
                            // User is confirmed and signed in
                            dismiss()
                        } else {
                            // User needs to confirm email
                            errorMessage = "Please check your email and click the confirmation link to complete signup."
                            isLoading = false
                        }
                    }
                } else {
                    try await supabaseService.signIn(email: email, password: password)
                    await MainActor.run {
                        dismiss()
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                Task {
                    do {
                        try await supabaseService.signInWithApple(credential: appleIDCredential)
                        await MainActor.run {
                            dismiss()
                        }
                    } catch {
                        await MainActor.run {
                            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
                        }
                    }
                }
            }
        case .failure(let error):
            errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
        }
    }
    
    
    private func sendPasswordReset() async {
        guard !email.isEmpty else { return }
        
        do {
            try await supabaseService.resetPassword(email: email)
            // Show success message
        } catch {
            errorMessage = "Failed to send reset email: \(error.localizedDescription)"
        }
    }
}

struct ModernTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
                .frame(width: 20)
            
            TextField(placeholder, text: $text)
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .keyboardType(keyboardType)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
}

struct ModernSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @State private var isSecure = true
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.tertiaryText)
                .frame(width: 20)
            
            Group {
                if isSecure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .textFieldStyle(PlainTextFieldStyle())
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(themeManager.primaryText)
            .autocapitalization(.none)
            .disableAutocorrection(true)
            
            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(themeManager.glassEffect)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
}

// MARK: - Midnight Emerald text fields

/// Emerald-styled text field: glass surface fill, gold hairline border, cream text, gold-leaf
/// icon, and a tertiaryText placeholder. Used only on the emerald auth path.
struct EmAuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    var keyboardType: UIKeyboardType = .default
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 20)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
                TextField("", text: $text)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.primaryText)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.glassSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
}

/// Emerald-styled secure field with a show/hide toggle, matching `EmAuthTextField`'s styling.
struct EmAuthSecureField: View {
    @Binding var text: String
    let placeholder: String
    let icon: String
    @State private var isSecure = true
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.accentColor)
                .frame(width: 20)

            ZStack(alignment: .leading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(themeManager.tertiaryText)
                }
                Group {
                    if isSecure {
                        SecureField("", text: $text)
                    } else {
                        TextField("", text: $text)
                    }
                }
                .textFieldStyle(PlainTextFieldStyle())
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(themeManager.primaryText)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            }

            Button(action: { isSecure.toggle() }) {
                Image(systemName: isSecure ? "eye.slash" : "eye")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(themeManager.tertiaryText)
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(themeManager.glassSurface)
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(themeManager.strokeColor, lineWidth: 1)
                )
        )
    }
}

#Preview {
    AuthenticationView()
}