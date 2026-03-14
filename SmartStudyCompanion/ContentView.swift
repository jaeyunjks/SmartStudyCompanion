//
//  ContentView.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import SwiftUI

/// Main tab view for authenticated users
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Tab = .home
    
    enum Tab {
        case home
        case upload
        case study
        case progress
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .tag(Tab.home)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            // Upload Tab
            UploadView()
                .tag(Tab.upload)
                .tabItem {
                    Label("Upload", systemImage: "doc.badge.plus")
                }
            
            // Study Tab
            StudyView()
                .tag(Tab.study)
                .tabItem {
                    Label("Study", systemImage: "book.fill")
                }
            
            // Progress Tab
            ProgressTrackingView()
                .tag(Tab.progress)
                .tabItem {
                    Label("Progress", systemImage: "chart.bar.fill")
                }
            
            // Profile Tab
            ProfileView()
                .tag(Tab.profile)
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    @StateObject private var uploadViewModel = UploadViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Welcome back!")
                        .font(.headlineLarge)
                    Text("Continue your learning journey")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        if uploadViewModel.uploadedPDFs.isEmpty {
                            EmptyState(
                                icon: "doc.text",
                                title: "No Documents Yet",
                                message: "Upload a PDF or image to get started with AI-powered learning",
                                actionText: "Upload Document",
                                action: {
                                    // Navigate to upload
                                }
                            )
                        } else {
                            // Display recent documents
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Your Documents")
                                    .font(.headline)
                                
                                ForEach(uploadViewModel.uploadedPDFs.prefix(3)) { pdf in
                                    HStack(spacing: 12) {
                                        Image(systemName: "doc.text.fill")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(pdf.fileName)
                                                .font(.caption)
                                                .lineLimit(1)
                                            
                                            Text(pdf.status.rawValue.capitalized)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                    }
                                    .padding(12)
                                    .background(Color.secondaryBackground)
                                    .cornerRadius(8)
                                }
                            }
                            .padding(16)
                        }
                    }
                }
            }
            .navigationTitle("Smart Study Companion")
            .onAppear {
                Task {
                    await uploadViewModel.fetchUserPDFs()
                }
            }
        }
    }
}

// MARK: - Upload View
struct UploadView: View {
    @StateObject private var uploadViewModel = UploadViewModel()
    @State private var showingFilePicker = false
    @State private var showingImagePicker = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Upload Documents")
                        .font(.headlineLarge)
                    Text("PDF files or images to generate summaries and flashcards")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Upload buttons
                        VStack(spacing: 12) {
                            Button(action: { showingFilePicker = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "doc.badge.plus")
                                        .font(.headline)
                                    Text("Upload PDF")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(Color.blue.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.blue)
                            }
                            
                            Button(action: { showingImagePicker = true }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.badge.plus")
                                        .font(.headline)
                                    Text("Upload Image")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(20)
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(12)
                                .foregroundColor(.green)
                            }
                        }
                        .padding(16)
                        
                        // Recent uploads
                        if !uploadViewModel.uploadedPDFs.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Recent Uploads")
                                    .font(.headline)
                                    .padding(.horizontal, 16)
                                
                                ForEach(uploadViewModel.uploadedPDFs) { pdf in
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(pdf.fileName)
                                                .font(.caption)
                                                .lineLimit(1)
                                            Spacer()
                                            Badge(text: pdf.status.rawValue, color: .blue)
                                        }
                                        
                                        HStack(spacing: 16) {
                                            Text("Size: \(formatFileSize(pdf.fileSize))")
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                            
                                            Spacer()
                                            
                                            Text(pdf.uploadedAt.formatted(date: .abbreviated, time: .shortened))
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(12)
                                    .background(Color.secondaryBackground)
                                    .cornerRadius(8)
                                }
                                .padding(16)
                            }
                        }
                    }
                }
                
                Spacer()
                
                if uploadViewModel.isLoading {
                    LoadingOverlay(isLoading: true, message: "Uploading...")
                }
                
                if let error = uploadViewModel.errorMessage {
                    ErrorBanner(message: error) {
                        uploadViewModel.errorMessage = nil
                    }
                }
            }
            .navigationTitle("Upload")
            .onAppear {
                Task {
                    await uploadViewModel.fetchUserPDFs()
                }
            }
        }
    }
    
    private func formatFileSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Study View
struct StudyView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Study Materials")
                        .font(.headlineLarge)
                    Text("Flashcards and quizzes generated from your documents")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                List {
                    Section(header: Text("Study Options")) {
                        NavigationLink(destination: Text("Flashcards")) {
                            HStack(spacing: 12) {
                                Image(systemName: "square.and.pencil")
                                    .font(.headline)
                                    .foregroundColor(.orange)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Flashcards")
                                        .font(.subheadline)
                                    Text("Review and memorize key concepts")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        NavigationLink(destination: Text("Quizzes")) {
                            HStack(spacing: 12) {
                                Image(systemName: "questionmark.circle")
                                    .font(.headline)
                                    .foregroundColor(.purple)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Quizzes")
                                        .font(.subheadline)
                                    Text("Test your knowledge with AI-generated quizzes")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        
                        NavigationLink(destination: Text("Summaries")) {
                            HStack(spacing: 12) {
                                Image(systemName: "doc.text")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("AI Summaries")
                                        .font(.subheadline)
                                    Text("Quick summaries of your documents")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Study")
            }
        }
    }
}

// MARK: - Progress Tracking View
struct ProgressTrackingView: View {
    @StateObject private var progressViewModel = ProgressViewModel()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Progress")
                        .font(.headlineLarge)
                    Text("Track your learning achievements")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Overall stats placeholder
                        VStack(spacing: 16) {
                            Text("Daily Statistics")
                                .font(.headline)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 16)
                            
                            HStack(spacing: 16) {
                                StatCard(title: "Cards Studied", value: "0", icon: "square.and.pencil", color: .blue)
                                StatCard(title: "Quizzes Done", value: "0", icon: "checkmark.circle", color: .green)
                                StatCard(title: "Accuracy", value: "0%", icon: "chart.bar", color: .orange)
                            }
                            .padding(.horizontal, 16)
                        }
                    }
                }
                .navigationTitle("Progress")
                .onAppear {
                    Task {
                        await progressViewModel.fetchDailyStatistics()
                    }
                }
            }
        }
    }
}

// MARK: - Profile View
struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let user = authViewModel.user {
                    VStack(spacing: 16) {
                        // Profile header
                        VStack(spacing: 8) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 64))
                                .foregroundColor(.blue)
                            
                            Text(user.fullName)
                                .font(.headline)
                            
                            Text(user.email)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(24)
                        .background(Color.secondaryBackground)
                        .cornerRadius(12)
                        
                        List {
                            Section(header: Text("Account")) {
                                HStack {
                                    Text("Username")
                                        .font(.caption)
                                    Spacer()
                                    Text(user.username)
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }
                            }
                            
                            Section(header: Text("Settings")) {
                                NavigationLink(destination: Text("Settings")) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "gear")
                                        Text("Settings")
                                    }
                                }
                            }
                            
                            Section {
                                Button(role: .destructive, action: {
                                    authViewModel.logout()
                                }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "arrow.left.circle")
                                        Text("Logout")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(Color.secondaryBackground)
        .cornerRadius(8)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
