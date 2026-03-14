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
                    MainTabView()
                        .environmentObject(authViewModel)
                } else {
                    LoginView()
                        .environmentObject(authViewModel)
                }
            }
            .onAppear {
                // Initialize CoreData
                _ = coreDataManager
                
                // Check for existing authentication tokens
                // This would load from secure storage in a real app
            }
        }
    }
}
