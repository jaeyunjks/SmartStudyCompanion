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

    var body: some Scene {
        WindowGroup {
            Group {
                if authViewModel.isAuthenticated {
                    // Persisted authenticated user -> Open main app directly
                    HomeDashboardView()
                        .environmentObject(authViewModel)
                } else {
                    // No saved session -> Show login/signup
                    AuthenticationFlowView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                // Initialize CoreData
                _ = coreDataManager
            }
        }
    }
}
