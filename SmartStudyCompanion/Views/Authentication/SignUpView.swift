//
//  SignUpView.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI

private enum SignUpTheme {
    static let outline = Color(red: 0.17, green: 0.19, blue: 0.22)
    static let textPrimary = Color(red: 0.12, green: 0.15, blue: 0.20)
    static let textSecondary = Color(red: 0.12, green: 0.15, blue: 0.20).opacity(0.62)

    static let backgroundMint = Color(red: 0.90, green: 0.97, blue: 0.95)
    static let backgroundBlue = Color(red: 0.91, green: 0.95, blue: 0.99)
    static let backgroundCream = Color(red: 0.97, green: 0.97, blue: 0.94)

    static let fieldBackground = Color.white.opacity(0.9)
    static let cardBackground = Color.white.opacity(0.92)

    static let primaryGradient = LinearGradient(
        colors: [Color(red: 0.44, green: 0.80, blue: 0.74), Color(red: 0.43, green: 0.71, blue: 0.92)],
        startPoint: .leading,
        endPoint: .trailing
    )
}

/// Sign up screen for new users
struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isShowingSignUp: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var fullName = ""
    @State private var agreeToTerms = false

    var isFormValid: Bool {
        !email.isEmpty && !password.isEmpty && !fullName.isEmpty &&
        password == confirmPassword && password.count >= 6 &&
        email.contains("@") && agreeToTerms
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SignUpTheme.backgroundMint, SignUpTheme.backgroundBlue, SignUpTheme.backgroundCream],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.26))
                    .frame(width: 220, height: 220)
                    .offset(x: -120, y: -270)
                Circle()
                    .fill(Color(red: 0.82, green: 0.91, blue: 0.98).opacity(0.22))
                    .frame(width: 180, height: 180)
                    .offset(x: 80, y: -250)
                Ellipse()
                    .fill(Color(red: 0.86, green: 0.97, blue: 0.94).opacity(0.22))
                    .frame(width: 240, height: 140)
                    .rotationEffect(.degrees(-14))
                    .offset(x: 120, y: -210)
            }
            .ignoresSafeArea()

            VStack(spacing: 18) {
                VStack(spacing: 8) {
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold, design: .default))
                        .foregroundStyle(SignUpTheme.textPrimary)

                    Text("Start your learning journey with SmartStudy")
                        .font(.system(size: 16, weight: .regular, design: .default))
                        .foregroundStyle(SignUpTheme.textSecondary)
                }
                .padding(.top, 24)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        VStack(spacing: 18) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Full Name")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundStyle(SignUpTheme.textPrimary)

                                TextField("John Doe", text: $fullName)
                                    .textInputAutocapitalization(.words)
                                    .padding(.horizontal, 14)
                                    .frame(height: 52)
                                    .background(SignUpTheme.fieldBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(SignUpTheme.outline.opacity(0.18), lineWidth: 1.6)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Email")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundStyle(SignUpTheme.textPrimary)

                                TextField("john@example.com", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .keyboardType(.emailAddress)
                                    .padding(.horizontal, 14)
                                    .frame(height: 52)
                                    .background(SignUpTheme.fieldBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(SignUpTheme.outline.opacity(0.18), lineWidth: 1.6)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Password")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundStyle(SignUpTheme.textPrimary)

                                SecureField("At least 6 characters", text: $password)
                                    .textInputAutocapitalization(.never)
                                    .padding(.horizontal, 14)
                                    .frame(height: 52)
                                    .background(SignUpTheme.fieldBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(SignUpTheme.outline.opacity(0.18), lineWidth: 1.6)
                                    )
                            }

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Confirm Password")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundStyle(SignUpTheme.textPrimary)

                                SecureField("••••••••", text: $confirmPassword)
                                    .textInputAutocapitalization(.never)
                                    .padding(.horizontal, 14)
                                    .frame(height: 52)
                                    .background(SignUpTheme.fieldBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .stroke(SignUpTheme.outline.opacity(0.18), lineWidth: 1.6)
                                    )
                            }

                            HStack(spacing: 10) {
                                Button(action: { agreeToTerms.toggle() }) {
                                    Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(agreeToTerms ? SignUpTheme.textPrimary : SignUpTheme.textSecondary)
                                }

                                HStack(spacing: 4) {
                                    Text("I agree to")
                                        .font(.system(size: 13, weight: .regular, design: .default))
                                        .foregroundStyle(SignUpTheme.textSecondary)

                                    Button(action: {}) {
                                        Text("Terms")
                                            .font(.system(size: 13, weight: .semibold, design: .default))
                                            .foregroundStyle(SignUpTheme.textPrimary)
                                    }

                                    Text("&")
                                        .font(.system(size: 13, weight: .regular, design: .default))
                                        .foregroundStyle(SignUpTheme.textSecondary)

                                    Button(action: {}) {
                                        Text("Privacy")
                                            .font(.system(size: 13, weight: .semibold, design: .default))
                                            .foregroundStyle(SignUpTheme.textPrimary)
                                    }
                                }

                                Spacer()
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
                                    await authViewModel.signUp(email: email, password: password, username: fullName, fullName: fullName)
                                }
                            }) {
                                HStack(spacing: 8) {
                                    if authViewModel.isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    }
                                    Text(authViewModel.isLoading ? "Creating account..." : "Sign Up")
                                        .font(.system(size: 17, weight: .semibold, design: .default))
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: 56)
                                .foregroundColor(.white)
                                .background(SignUpTheme.primaryGradient)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule().stroke(SignUpTheme.outline.opacity(0.18), lineWidth: 1.3)
                                )
                                .shadow(color: Color(red: 0.60, green: 0.74, blue: 0.88).opacity(0.25), radius: 8, x: 0, y: 4)
                            }
                            .disabled(!isFormValid || authViewModel.isLoading)
                            .opacity(!isFormValid || authViewModel.isLoading ? 0.6 : 1.0)

                            HStack(spacing: 12) {
                                Rectangle()
                                    .fill(SignUpTheme.outline.opacity(0.14))
                                    .frame(height: 1)

                                Text("or continue with")
                                    .font(.system(size: 13, weight: .semibold, design: .default))
                                    .foregroundStyle(SignUpTheme.textSecondary)

                                Rectangle()
                                    .fill(SignUpTheme.outline.opacity(0.14))
                                    .frame(height: 1)
                            }

                            VStack(spacing: 10) {
                                socialButton(title: "Continue with Google", icon: "globe")
                                socialButton(title: "Continue with Apple", icon: "apple.logo")
                            }
                        }
                        .padding(20)
                        .background(SignUpTheme.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 30, style: .continuous)
                                .stroke(SignUpTheme.outline.opacity(0.14), lineWidth: 2)
                        )
                        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 10)
                        .padding(.horizontal, 20)

                        HStack(spacing: 4) {
                            Text("Already have an account?")
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .foregroundStyle(SignUpTheme.textSecondary)

                            Button(action: { isShowingSignUp = false }) {
                                Text("Log In")
                                    .font(.system(size: 14, weight: .semibold, design: .default))
                                    .foregroundStyle(SignUpTheme.textPrimary)
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
    private func socialButton(title: String, icon: String) -> some View {
        Button(action: {}) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(SignUpTheme.textPrimary)
                    .frame(width: 22)

                Text(title)
                    .font(.system(size: 15, weight: .semibold, design: .default))
                    .foregroundStyle(SignUpTheme.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 14)
            .frame(height: 50)
            .background(Color.white.opacity(0.82))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(SignUpTheme.outline.opacity(0.16), lineWidth: 1.4)
            )
        }
    }
}

#Preview {
    @State var isShowingSignUp = true
    return SignUpView(isShowingSignUp: $isShowingSignUp)
        .environmentObject(AuthViewModel())
}
