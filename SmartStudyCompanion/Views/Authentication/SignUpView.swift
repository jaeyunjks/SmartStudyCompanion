//
//  SignUpView.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI

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
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.97, blue: 1.0),
                    Color(red: 0.98, green: 0.96, blue: 1.0)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Create Your Account")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.black)
                    
                    Text("Join thousands of smart learners")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.gray)
                }
                .padding(.top, 30)
                .padding(.bottom, 24)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Full Name
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Full Name")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("John Doe", text: $fullName)
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            TextField("john@example.com", text: $email)
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        
                        // Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            SecureField("At least 6 characters", text: $password)
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        
                        // Confirm Password
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm Password")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.black)
                            
                            SecureField("••••••••", text: $confirmPassword)
                                .padding(14)
                                .background(Color.white)
                                .cornerRadius(10)
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray.opacity(0.2), lineWidth: 1))
                        }
                        
                        // Error Message
                        if let error = authViewModel.errorMessage {
                            HStack(spacing: 10) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                
                                Text(error)
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.red)
                                
                                Spacer()
                            }
                            .padding(12)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(10)
                        }
                        
                        // Password Validation Hints
                        if !password.isEmpty && password.count < 6 {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.orange)
                                Text("At least 6 characters")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            .padding(10)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if !password.isEmpty && password == confirmPassword && password.count >= 6 {
                            HStack(spacing: 8) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Passwords match")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.green)
                                Spacer()
                            }
                            .padding(10)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        if !password.isEmpty && password != confirmPassword {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.circle")
                                    .foregroundColor(.orange)
                                Text("Passwords don't match")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.orange)
                                Spacer()
                            }
                            .padding(10)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Terms and Conditions
                        HStack(spacing: 10) {
                            Button(action: { agreeToTerms.toggle() }) {
                                Image(systemName: agreeToTerms ? "checkmark.square.fill" : "square")
                                    .foregroundColor(.blue)
                            }
                            
                            HStack(spacing: 4) {
                                Text("I agree to the")
                                    .font(.system(size: 13, weight: .regular))
                                    .foregroundColor(.gray)
                                
                                Button(action: {}) {
                                    Text("Terms & Conditions")
                                        .font(.system(size: 13, weight: .semibold))
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Spacer()
                        }
                        
                        Spacer()
                            .frame(height: 20)
                    }
                    .padding(.horizontal, 20)
                }
                
                // Sign Up Button
                VStack(spacing: 12) {
                    Button(action: {
                        Task {
                            await authViewModel.signUp(email: email, password: password, username: fullName, fullName: fullName)
                        }
                    }) {
                        if authViewModel.isLoading {
                            HStack(spacing: 8) {
                                ProgressView()
                                    .tint(.white)
                                Text("Creating account...")
                                    .font(.system(size: 16, weight: .semibold))
                            }
                        } else {
                            Text("Create Account")
                                .font(.system(size: 16, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(!isFormValid || authViewModel.isLoading)
                    .opacity(!isFormValid || authViewModel.isLoading ? 0.6 : 1.0)
                    
                    // Back to Login
                    HStack(spacing: 4) {
                        Text("Already have an account?")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                        
                        Button(action: { isShowingSignUp = false }) {
                            Text("Login")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 20)
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    @State var isShowingSignUp = true
    return SignUpView(isShowingSignUp: $isShowingSignUp)
        .environmentObject(AuthViewModel())
}
