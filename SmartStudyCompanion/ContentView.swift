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

    private enum HomeTheme {
        static let outline = Color(red: 0.17, green: 0.19, blue: 0.22)
        static let textPrimary = Color(red: 0.12, green: 0.15, blue: 0.20)
        static let textSecondary = Color(red: 0.12, green: 0.15, blue: 0.20).opacity(0.62)

        static let backgroundMint = Color(red: 0.90, green: 0.97, blue: 0.95)
        static let backgroundBlue = Color(red: 0.91, green: 0.95, blue: 0.99)
        static let backgroundCream = Color(red: 0.97, green: 0.97, blue: 0.94)

        static let card = Color.white.opacity(0.92)
        static let subtleCard = Color.white.opacity(0.86)

        static let primaryGradient = LinearGradient(
            colors: [Color(red: 0.44, green: 0.80, blue: 0.74), Color(red: 0.43, green: 0.71, blue: 0.92)],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private enum NoteType: String {
        case text = "Text"
        case pdf = "PDF"
        case video = "Video"
    }

    private struct StudyMode: Identifiable {
        let id = UUID()
        let title: String
        let icon: String
        let tint: Color
    }

    private struct NoteListItem: Identifiable {
        let id = UUID()
        let title: String
        let type: NoteType
        let progress: Double
        let status: String
    }

    private let createOptions: [(title: String, icon: String)] = [
        ("Text note", "square.and.pencil"),
        ("Upload PDF", "doc.fill"),
        ("YouTube video", "play.rectangle.fill"),
        ("Voice input", "waveform")
    ]

    private let studyModes: [StudyMode] = [
        .init(title: "Flashcards", icon: "rectangle.on.rectangle", tint: Color(red: 0.45, green: 0.72, blue: 0.94)),
        .init(title: "Quiz", icon: "checkmark.circle", tint: Color(red: 0.48, green: 0.78, blue: 0.66)),
        .init(title: "Summary", icon: "text.alignleft", tint: Color(red: 0.54, green: 0.69, blue: 0.94)),
        .init(title: "Chat", icon: "bubble.left.and.bubble.right", tint: Color(red: 0.50, green: 0.74, blue: 0.84))
    ]

    private var noteItems: [NoteListItem] {
        if uploadViewModel.uploadedPDFs.isEmpty {
            return [
                .init(title: "Biology Chapter 3 Notes", type: .text, progress: 0.42, status: "In progress"),
                .init(title: "Calculus Limits Breakdown", type: .video, progress: 0.18, status: "Just started")
            ]
        }

        return uploadViewModel.uploadedPDFs.prefix(6).map { pdf in
            NoteListItem(
                title: pdf.fileName.replacingOccurrences(of: ".pdf", with: "") + " Notes",
                type: .pdf,
                progress: progressForStatus(pdf.status.rawValue),
                status: displayStatus(pdf.status.rawValue)
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [HomeTheme.backgroundMint, HomeTheme.backgroundBlue, HomeTheme.backgroundCream],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 20) {
                            topSection
                            createNoteCard
                            continueLearningCard
                            studyModesSection
                            notesSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 18)
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                Task {
                    await uploadViewModel.fetchUserPDFs()
                }
            }
        }
    }

    private var topSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Hi Yafie \u{1F44B}")
                .font(.system(size: 30, weight: .bold, design: .default))
                .foregroundStyle(HomeTheme.textPrimary)

            Text("Ready to learn something today?")
                .font(.system(size: 16, weight: .regular, design: .default))
                .foregroundStyle(HomeTheme.textSecondary)
        }
    }

    private var createNoteCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Create new note")
                    .font(.system(size: 24, weight: .semibold, design: .default))
                    .foregroundStyle(HomeTheme.textPrimary)

                Text("Turn anything into study material")
                    .font(.system(size: 15, weight: .regular, design: .default))
                    .foregroundStyle(HomeTheme.textSecondary)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(createOptions, id: \.title) { option in
                    Button(action: {}) {
                        HStack(spacing: 8) {
                            Image(systemName: option.icon)
                                .font(.system(size: 15, weight: .semibold))

                            Text(option.title)
                                .font(.system(size: 14, weight: .medium, design: .default))
                                .lineLimit(1)
                        }
                        .foregroundStyle(HomeTheme.textPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.white.opacity(0.82))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(HomeTheme.outline.opacity(0.12), lineWidth: 1.2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(HomeTheme.primaryGradient)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(HomeTheme.outline.opacity(0.16), lineWidth: 1.5)
        )
        .shadow(color: Color(red: 0.60, green: 0.74, blue: 0.88).opacity(0.22), radius: 9, x: 0, y: 5)
    }

    private var continueLearningCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Continue learning")
                .font(.system(size: 19, weight: .semibold, design: .default))
                .foregroundStyle(HomeTheme.textPrimary)

            VStack(alignment: .leading, spacing: 10) {
                Text(noteItems.first?.title ?? "Start your first note")
                    .font(.system(size: 16, weight: .semibold, design: .default))
                    .foregroundStyle(HomeTheme.textPrimary)

                Text("Last accessed note")
                    .font(.system(size: 13, weight: .regular, design: .default))
                    .foregroundStyle(HomeTheme.textSecondary)

                ProgressView(value: noteItems.first?.progress ?? 0.0)
                    .tint(HomeTheme.outline.opacity(0.75))

                HStack(spacing: 10) {
                    Button("Resume", action: {})
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(HomeTheme.outline)
                        .clipShape(Capsule())

                    Button("Quiz", action: {})
                        .font(.system(size: 14, weight: .semibold, design: .default))
                        .foregroundStyle(HomeTheme.textPrimary)
                        .padding(.horizontal, 16)
                        .frame(height: 38)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(HomeTheme.outline.opacity(0.16), lineWidth: 1.2)
                        )
                }
            }
        }
        .padding(18)
        .background(HomeTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(HomeTheme.outline.opacity(0.12), lineWidth: 1.2)
        )
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 6)
    }

    private var studyModesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Study modes")
                .font(.system(size: 19, weight: .semibold, design: .default))
                .foregroundStyle(HomeTheme.textPrimary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(studyModes) { mode in
                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(mode.tint)

                        Text(mode.title)
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundStyle(HomeTheme.textPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(14)
                    .background(HomeTheme.subtleCard)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(HomeTheme.outline.opacity(0.10), lineWidth: 1.1)
                    )
                }
            }
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your notes")
                .font(.system(size: 19, weight: .semibold, design: .default))
                .foregroundStyle(HomeTheme.textPrimary)

            ForEach(noteItems) { note in
                HStack(spacing: 12) {
                    Image(systemName: icon(for: note.type))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(HomeTheme.outline.opacity(0.8))
                        .frame(width: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(note.title)
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundStyle(HomeTheme.textPrimary)
                            .lineLimit(1)

                        HStack(spacing: 8) {
                            Text(note.type.rawValue)
                            Text("•")
                            Text(note.status)
                        }
                        .font(.system(size: 12, weight: .regular, design: .default))
                        .foregroundStyle(HomeTheme.textSecondary)
                    }

                    Spacer()

                    Text("\(Int(note.progress * 100))%")
                        .font(.system(size: 12, weight: .semibold, design: .default))
                        .foregroundStyle(HomeTheme.textSecondary)
                }
                .padding(14)
                .background(HomeTheme.card)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(HomeTheme.outline.opacity(0.10), lineWidth: 1.1)
                )
            }
        }
        .padding(.bottom, 12)
    }

    private func icon(for type: NoteType) -> String {
        switch type {
        case .text: return "square.and.pencil"
        case .pdf: return "doc.text"
        case .video: return "play.rectangle"
        }
    }

    private func progressForStatus(_ status: String) -> Double {
        switch status.lowercased() {
        case "completed", "ready": return 1.0
        case "processing": return 0.45
        case "failed": return 0.1
        default: return 0.25
        }
    }

    private func displayStatus(_ status: String) -> String {
        status.capitalized
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
