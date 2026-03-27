//
//  SmartStudyCompanionApp.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI

@main
struct SmartStudyCompanionApp: App {
    // MARK: - Properties
    @StateObject private var authViewModel = AuthViewModel()
    @State private var coreDataManager = CoreDataManager.shared
    @State private var hasSeenOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    // User is logged in → Show main app with tabs
                    MainTabView()
                        .environmentObject(authViewModel)
                } else if hasSeenOnboarding {
                    // User has seen onboarding → Show login/signup
                    AuthenticationFlowView()
                        .environmentObject(authViewModel)
                } else {
                    // First time → Show onboarding carousel
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                }
            }
            .onAppear {
                // Initialize CoreData
                _ = coreDataManager
                
                // Check if user has seen onboarding before
                hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
                
                // In production: Check for existing authentication tokens from KeyChain
                // authViewModel.checkAuthStatus()
            }
        }
    }
}
