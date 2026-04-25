//
//  LoginView.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI

private enum LoginTheme {
    static let accent = Color(red: 0.25, green: 0.58, blue: 0.41)
    static let outline = Color(red: 0.17, green: 0.19, blue: 0.22)
    static let textPrimary = Color(red: 0.12, green: 0.15, blue: 0.20)
    static let textSecondary = Color(red: 0.12, green: 0.15, blue: 0.20).opacity(0.62)

    static let backgroundMint = Color(red: 0.90, green: 0.97, blue: 0.95)
    static let backgroundBlue = Color(red: 0.93, green: 0.97, blue: 0.94)
    static let backgroundCream = Color(red: 0.96, green: 0.97, blue: 0.93)

    static let fieldBackground = Color.white.opacity(0.9)
    static let cardBackground = Color.white.opacity(0.92)

    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.39, green: 0.78, blue: 0.58), Color(red: 0.24, green: 0.63, blue: 0.42)],
        startPoint: .leading,
        endPoint: .trailing
    )
}

/// Login screen for existing users
struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @AppStorage("auth.rememberMe") private var rememberMe = true
    @State private var authMode: AuthMode = .login

    private enum AuthMode: String, CaseIterable, Identifiable {
        case login = "Log In"
        case signUp = "Sign Up"
        var id: String { rawValue }
    }

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [LoginTheme.backgroundMint, LoginTheme.backgroundBlue, LoginTheme.backgroundCream],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Soft petal-like accents to echo onboarding visuals.
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.26))
                    .frame(width: 220, height: 220)
                    .offset(x: -120, y: -270)
                Circle()
                    .fill(Color(red: 0.84, green: 0.95, blue: 0.87).opacity(0.26))
                    .frame(width: 180, height: 180)
                    .offset(x: 80, y: -250)
                Ellipse()
                    .fill(Color(red: 0.87, green: 0.96, blue: 0.90).opacity(0.24))
                    .frame(width: 240, height: 140)
                    .rotationEffect(.degrees(-14))
                    .offset(x: 120, y: -210)
            }
            .ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text("Welcome Back")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundStyle(LoginTheme.textPrimary)

                    Text("Continue your learning journey")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(LoginTheme.textSecondary)
                }
                .padding(.top, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        VStack(spacing: 18) {
                            Picker("Auth Mode", selection: $authMode) {
                                ForEach(AuthMode.allCases) { mode in
                                    Text(mode.rawValue).tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .tint(LoginTheme.accent)
                            .onChange(of: authMode) { _, newValue in
                                if newValue == .signUp {
                                    isShowingSignUp = true
                                    authMode = .login
                                }
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundStyle(LoginTheme.textPrimary)

                                TextField("john@example.com", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .tint(LoginTheme.accent)
                                    .padding(.horizontal, 14)
                                    .frame(height: 52)
                                    .background(LoginTheme.fieldBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(LoginTheme.outline.opacity(0.18), lineWidth: 1.6)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundStyle(LoginTheme.textPrimary)

                                HStack(spacing: 10) {
                                    Group {
                                        if showPassword {
                                            TextField("••••••••", text: $password)
                                        } else {
                                            SecureField("••••••••", text: $password)
                                        }
                                    }
                                    .textInputAutocapitalization(.never)
                                    .tint(LoginTheme.accent)

                                    Button {
                                        showPassword.toggle()
                                    } label: {
                                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                            .font(.system(size: 15, weight: .semibold))
                                            .foregroundStyle(LoginTheme.textSecondary)
                                    }
                                }
                                .padding(.horizontal, 14)
                                .frame(height: 52)
                                .background(LoginTheme.fieldBackground)
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                                        .stroke(LoginTheme.outline.opacity(0.18), lineWidth: 1.6)
                                )
                            }

                            HStack {
                                Button {
                                    rememberMe.toggle()
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: rememberMe ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 18, weight: .semibold))
                                            .foregroundStyle(rememberMe ? LoginTheme.accent : LoginTheme.textSecondary)
                                        Text("Remember me")
                                            .font(.system(size: 14, weight: .semibold, design: .default))
                                            .foregroundStyle(LoginTheme.textSecondary)
                                    }
                                }

                                Spacer()

                                Button(action: {}) {
                                    Text("Forgot password?")
                                        .font(.system(size: 14, weight: .semibold, design: .default))
                                        .foregroundStyle(LoginTheme.accent.opacity(0.86))
                                }
                            }

                            if rememberMe {
                                Button(action: {
                                    Task {
                                        await authViewModel.loginWithBiometrics()
                                    }
                                }) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "faceid")
                                            .font(.system(size: 15, weight: .semibold))
                                        Text("Use Face ID / Touch ID")
                                            .font(.system(size: 14, weight: .semibold, design: .default))
                                    }
                                    .foregroundStyle(LoginTheme.accent)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 44)
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(LoginTheme.accent.opacity(0.22), lineWidth: 1.2)
                                    )
                                }
                                .buttonStyle(.plain)
                            }

                            if let error = authViewModel.errorMessage {
                                HStack(spacing: 10) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .foregroundColor(Color(red: 0.89, green: 0.33, blue: 0.40))
                                    Text(error)
                                        .font(.system(size: 13, weight: .medium, design: .default))
                                        .foregroundColor(Color(red: 0.53, green: 0.33, blue: 0.30))
                                    Spacer()
                                }
                                .padding(12)
                                .background(Color(red: 0.99, green: 0.94, blue: 0.90))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }

                            Button(action: {
                                Task {
                                    await authViewModel.login(email: email, password: password, rememberMe: rememberMe)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(authViewModel.isLoading ? "Logging in..." : "Log In")
                                        .font(.system(size: 17, weight: .semibold, design: .default))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .foregroundColor(.white)
                                .background(LoginTheme.primaryGradient)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(LoginTheme.outline.opacity(0.18), lineWidth: 1.3)
                                )
                                .shadow(color: Color(red: 0.60, green: 0.74, blue: 0.88).opacity(0.25), radius: 8, x: 0, y: 4)
                            }
                            .disabled(!isFormValid || authViewModel.isLoading)
                            .opacity(!isFormValid || authViewModel.isLoading ? 0.6 : 1)

                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(LoginTheme.outline.opacity(0.14))
                                    .frame(height: 1)

                                Text("or continue with")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundStyle(LoginTheme.textSecondary)

                                Rectangle()
                                    .fill(LoginTheme.outline.opacity(0.14))
                                    .frame(height: 1)
                            }

                            VStack(spacing: 10) {
                                socialButton(title: "Continue with Google", icon: "globe") {
                                    Task {
                                        await authViewModel.loginWithGooglePlaceholder()
                                    }
                                }
                                socialButton(title: "Continue with Apple", icon: "apple.logo") {
                                    Task {
                                        await authViewModel.loginWithApplePlaceholder()
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(LoginTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(LoginTheme.outline.opacity(0.14), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 10)
                        .padding(.horizontal, 20)

                        HStack(spacing: 4) {
                            Text("Don't have an account?")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundStyle(LoginTheme.textSecondary)

                            Button(action: { isShowingSignUp = true }) {
                                Text("Sign Up")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundStyle(LoginTheme.accent)
                            }
                        }
                        .padding(.bottom, 18)
                    }
                    .padding(.top, 6)
                }
            }
        }
        .navigationBarHidden(true)
    }

    @ViewBuilder
    private func socialButton(title: String, icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(LoginTheme.textPrimary)
                    .frame(width: 22)

                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundStyle(LoginTheme.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(Color.white.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(LoginTheme.outline.opacity(0.16), lineWidth: 1.4)
            )
        }
    }
}

#Preview {
    @State var isShowingSignUp = false
    return LoginView(isShowingSignUp: $isShowingSignUp)
        .environmentObject(AuthViewModel())
}
