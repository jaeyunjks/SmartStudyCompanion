//
//  AuthViewModel.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import Combine

/// ViewModel for authentication operations (login, signup, logout)
class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let apiService = APIService.shared
    
    // MARK: - Sign Up
    
    /// Sign up a new user
    @MainActor
    func signUp(email: String, password: String, username: String, fullName: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let sanitizedUsername = username
                .lowercased()
                .replacingOccurrences(of: " ", with: "")
            let signUpRequest = SignUpRequest(
                email: email,
                password: password,
                confirmPassword: password,
                username: sanitizedUsername.isEmpty ? email.components(separatedBy: "@").first ?? "user" : sanitizedUsername,
                fullname: fullName
            )
            _ = try await apiService.signUp(signUpRequest: signUpRequest)
            
            self.user = nil
            self.isAuthenticated = true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Login
    
    /// Log in an existing user
    @MainActor
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await apiService.login(email: email, password: password)
            
            self.user = nil
            self.isAuthenticated = true
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    // MARK: - Logout
    
    /// Log out the current user
    func logout() {
        apiService.logout()
        user = nil
        isAuthenticated = false
        errorMessage = nil
    }
}
