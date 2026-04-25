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
    @State private var hasSeenOnboarding: Bool

    init() {
        _hasSeenOnboarding = State(initialValue: UserDefaults.standard.bool(forKey: "hasSeenOnboarding"))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if !hasSeenOnboarding {
                    // First time -> Show onboarding carousel
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                } else if authViewModel.isAuthenticated {
                    // User is logged in -> Go directly to the Home dashboard
                    HomeDashboardView()
                } else {
                    // User has seen onboarding -> Show login/signup
                    AuthenticationFlowView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                // Initialize CoreData
                _ = coreDataManager

                // Ensure latest persisted value drives launch routing
                hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
            }
        }
    }
}
