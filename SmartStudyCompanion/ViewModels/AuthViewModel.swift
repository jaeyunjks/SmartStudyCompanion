//
//  AuthViewModel.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation
import Combine
import LocalAuthentication

/// ViewModel for authentication operations (login, signup, logout)
class AuthViewModel: ObservableObject {
    struct SessionProfile: Codable {
        var displayName: String
        var username: String
        var email: String
        var profileImageData: Data?

        private enum CodingKeys: String, CodingKey {
            case displayName
            case username
            case email
            case profileImageData
        }

        init(displayName: String, username: String, email: String, profileImageData: Data?) {
            self.displayName = displayName
            self.username = username
            self.email = email
            self.profileImageData = profileImageData
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let decodedDisplayName = try container.decodeIfPresent(String.self, forKey: .displayName) ?? "Learner"
            let decodedEmail = try container.decodeIfPresent(String.self, forKey: .email) ?? ""
            let fallbackUsername = decodedEmail.split(separator: "@").first.map(String.init) ?? "learner"
            self.displayName = decodedDisplayName
            self.username = try container.decodeIfPresent(String.self, forKey: .username) ?? fallbackUsername
            self.email = decodedEmail
            self.profileImageData = try container.decodeIfPresent(Data.self, forKey: .profileImageData)
        }
    }

    @Published var user: User?
    @Published var sessionProfile: SessionProfile?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var rememberMeEnabled = UserDefaults.standard.bool(forKey: "auth.rememberMe")
    
    private let apiService = APIService.shared
    private static let loggedInKey = "auth.loggedIn"
    private static let profileDataKey = "auth.profileData"
    private static let rememberedEmailKey = "auth.remembered.email"
    private static let rememberedPasswordKey = "auth.remembered.password"
    private static let rememberMeKey = "auth.rememberMe"

    init() {
        restorePersistedSession()
    }

    var displayName: String {
        if let stored = sessionProfile?.displayName, !stored.isEmpty {
            return stored
        }
        return "Learner"
    }

    var emailAddress: String {
        sessionProfile?.email ?? ""
    }

    var username: String {
        let stored = sessionProfile?.username.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !stored.isEmpty {
            return stored
        }
        let local = emailAddress.split(separator: "@").first.map(String.init) ?? "learner"
        return local.lowercased().replacingOccurrences(of: " ", with: "")
    }

    var profileImageData: Data? {
        sessionProfile?.profileImageData
    }

    var userInitials: String {
        let parts = displayName
            .split(separator: " ")
            .prefix(2)
            .map { String($0.prefix(1)).uppercased() }
        return parts.isEmpty ? "SC" : parts.joined()
    }

    var welcomeBackText: String {
        "Welcome back, \(displayName)"
    }
    
    // MARK: - Sign Up
    
    /// Sign up a new user
    @MainActor
    func signUp(email: String, password: String, username: String, fullName: String, rememberMe: Bool = true) async {
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
            let response = try await apiService.signUp(signUpRequest: signUpRequest)
            let backendProfile = response.user
            
            self.user = nil
            completeAuthentication(
                displayName: backendProfile?.fullname ?? (fullName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? deriveDisplayName(from: email) : fullName),
                username: backendProfile?.username ?? (sanitizedUsername.isEmpty ? deriveUsername(from: email) : sanitizedUsername),
                email: backendProfile?.email ?? email,
                rememberMe: rememberMe,
                passwordForBiometrics: password,
                profileImageData: decodeBase64Image(backendProfile?.profileImage)
            )
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
    func login(email: String, password: String, rememberMe: Bool) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.login(email: email, password: password)
            let backendProfile = response.user
            
            self.user = nil
            completeAuthentication(
                displayName: backendProfile?.fullname ?? deriveDisplayName(from: email),
                username: backendProfile?.username ?? deriveUsername(from: email),
                email: backendProfile?.email ?? email,
                rememberMe: rememberMe,
                passwordForBiometrics: password,
                profileImageData: decodeBase64Image(backendProfile?.profileImage)
            )
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }

    // MARK: - Biometric Login

    @MainActor
    func loginWithBiometrics() async {
        errorMessage = nil

        guard rememberMeEnabled else {
            errorMessage = "Enable Remember me first to use Face ID / Touch ID."
            return
        }

        guard
            let email = UserDefaults.standard.string(forKey: Self.rememberedEmailKey),
            let password = UserDefaults.standard.string(forKey: Self.rememberedPasswordKey)
        else {
            errorMessage = "No remembered credentials found. Log in once with Remember me enabled."
            return
        }

        let context = LAContext()
        var authError: NSError?
        let reason = "Unlock Smart Study Companion"

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) else {
            errorMessage = "Biometric authentication is unavailable on this device. Use email and password."
            return
        }

        do {
            let didAuthenticate = try await context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            guard didAuthenticate else {
                errorMessage = "Biometric authentication failed. Please use email and password."
                return
            }
            await login(email: email, password: password, rememberMe: true)
        } catch {
            errorMessage = "Biometric authentication failed. Please use email and password."
        }
    }

    // MARK: - Social Placeholder Login

    @MainActor
    func loginWithGooglePlaceholder() async {
        // TODO: Replace with official Google Sign-In SDK flow and backend token verification.
        completeAuthentication(
            displayName: "Google User",
            username: "google_user",
            email: "google_user@placeholder.smartstudy",
            rememberMe: true,
            passwordForBiometrics: nil,
            profileImageData: nil
        )
    }

    @MainActor
    func loginWithApplePlaceholder() async {
        // TODO: Replace with Sign in with Apple + backend identity token validation.
        completeAuthentication(
            displayName: "Apple User",
            username: "apple_user",
            email: "apple_user@placeholder.smartstudy",
            rememberMe: true,
            passwordForBiometrics: nil,
            profileImageData: nil
        )
    }
    
    // MARK: - Logout
    
    /// Log out the current user
    func logout() {
        apiService.logout()
        user = nil
        sessionProfile = nil
        isAuthenticated = false
        errorMessage = nil
        rememberMeEnabled = false

        UserDefaults.standard.removeObject(forKey: Self.loggedInKey)
        UserDefaults.standard.removeObject(forKey: Self.profileDataKey)
        UserDefaults.standard.removeObject(forKey: Self.rememberedEmailKey)
        UserDefaults.standard.removeObject(forKey: Self.rememberedPasswordKey)
        UserDefaults.standard.set(false, forKey: Self.rememberMeKey)
    }

    // MARK: - Helpers

    @MainActor
    private func completeAuthentication(
        displayName: String,
        username: String,
        email: String,
        rememberMe: Bool,
        passwordForBiometrics: String?,
        profileImageData: Data?
    ) {
        let profile = SessionProfile(
            displayName: displayName,
            username: username,
            email: email,
            profileImageData: profileImageData
        )
        sessionProfile = profile
        isAuthenticated = true
        rememberMeEnabled = rememberMe

        UserDefaults.standard.set(true, forKey: Self.loggedInKey)
        UserDefaults.standard.set(rememberMe, forKey: Self.rememberMeKey)
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: Self.profileDataKey)
        }

        if rememberMe, let passwordForBiometrics {
            UserDefaults.standard.set(email, forKey: Self.rememberedEmailKey)
            UserDefaults.standard.set(passwordForBiometrics, forKey: Self.rememberedPasswordKey)
        } else {
            UserDefaults.standard.removeObject(forKey: Self.rememberedEmailKey)
            UserDefaults.standard.removeObject(forKey: Self.rememberedPasswordKey)
        }
    }

    @MainActor
    func updateProfile(displayName: String, username: String, profileImageData: Data?) async {
        guard let current = sessionProfile else { return }
        isLoading = true
        errorMessage = nil

        let trimmedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let rawUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedUsername = rawUsername
            .lowercased()
            .replacingOccurrences(of: " ", with: "")

        do {
            let response = try await apiService.updateUserProfile(
                currentUsername: current.username,
                fullname: trimmedName.isEmpty ? nil : trimmedName,
                username: cleanedUsername.isEmpty ? nil : cleanedUsername,
                profileImage: encodeBase64Image(profileImageData)
            )

            let updated = SessionProfile(
                displayName: response.fullname,
                username: response.username,
                email: response.email,
                profileImageData: decodeBase64Image(response.profileImage)
            )
            sessionProfile = updated

            if let encoded = try? JSONEncoder().encode(updated) {
                UserDefaults.standard.set(encoded, forKey: Self.profileDataKey)
            }
        } catch let error as NetworkError {
            self.errorMessage = error.localizedDescription
        } catch {
            self.errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func restorePersistedSession() {
        let defaults = UserDefaults.standard
        isAuthenticated = defaults.bool(forKey: Self.loggedInKey)
        rememberMeEnabled = defaults.bool(forKey: Self.rememberMeKey)

        guard
            let data = defaults.data(forKey: Self.profileDataKey),
            let decoded = try? JSONDecoder().decode(SessionProfile.self, from: data)
        else {
            return
        }
        sessionProfile = decoded
    }

    private func deriveDisplayName(from email: String) -> String {
        let local = email.split(separator: "@").first.map(String.init) ?? "Learner"
        let readable = local.replacingOccurrences(of: ".", with: " ").replacingOccurrences(of: "_", with: " ")
        return readable
            .split(separator: " ")
            .map { $0.prefix(1).uppercased() + $0.dropFirst().lowercased() }
            .joined(separator: " ")
    }

    private func deriveUsername(from email: String) -> String {
        let local = email.split(separator: "@").first.map(String.init) ?? "learner"
        return local
            .lowercased()
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ".", with: "")
    }

    private func encodeBase64Image(_ data: Data?) -> String? {
        guard let data else { return nil }
        return data.base64EncodedString()
    }

    private func decodeBase64Image(_ string: String?) -> Data? {
        guard let string, !string.isEmpty else { return nil }
        return Data(base64Encoded: string)
    }
}
