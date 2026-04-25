import SwiftUI
import PhotosUI
import UIKit

enum HomeTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)
    static let cardBackground = Color(.systemBackground)
    static let mutedText = Color(.secondaryLabel)
    static let secondaryBackground = Color(.secondarySystemBackground)

    static let horizontalPadding: CGFloat = 24
    static let sectionSpacing: CGFloat = 22
    static let cardCornerRadius: CGFloat = 22
    static let chipCornerRadius: CGFloat = 18
    static let smallCornerRadius: CGFloat = 16
    static let glassBorder = accent.opacity(0.10)
    static let glassShadow = accent.opacity(0.08)
}

struct HomeDashboardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var selectedTab: HomeNavItem = .home
    @State private var showCreateStudySpaceSheet = false
    @State private var selectedStudySpace: StudySpace?
    @State private var animateGreeting = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let bottomInset = geometry.safeAreaInsets.bottom

                ZStack(alignment: .bottom) {
                    HomeTheme.background.ignoresSafeArea()

                    ZStack {
                        if selectedTab == .home {
                            VStack(spacing: 0) {
                                HomeTopBarView(
                                    greetingText: authViewModel.welcomeBackText,
                                    userInitials: authViewModel.userInitials,
                                    animateGreeting: animateGreeting,
                                    onSettingsTap: {}
                                )
                                .padding(.top, 8)

                                ScrollView {
                                    LazyVStack(alignment: .leading, spacing: HomeTheme.sectionSpacing) {
                                        HeroSectionView(
                                            onCreateStudySpace: {
                                                showCreateStudySpaceSheet = true
                                            }
                                        )
                                        ContinueLearningSectionView(spaces: viewModel.featuredStudySpaces) { space in
                                            selectedStudySpace = space
                                        }
                                        RecentStudySpacesSectionView(spaces: viewModel.recentStudySpaces) { space in
                                            selectedStudySpace = space
                                        }
                                    }
                                    .padding(.horizontal, HomeTheme.horizontalPadding)
                                    .padding(.top, 10)
                                    .padding(.bottom, 96 + bottomInset)
                                }
                            }
                        } else if selectedTab == .profile {
                            ProfileAccountView()
                                .environmentObject(authViewModel)
                        } else if selectedTab == .library {
                            LibraryView(
                                isEmbeddedInHome: true,
                                onNavigateHome: { selectedTab = .home }
                            )
                        }
                    }

                    HomeBottomNavBarView(selected: selectedTab) { tab in
                        selectedTab = tab
                    }
                    .padding(.bottom, max(bottomInset, 8))
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .sheet(isPresented: $showCreateStudySpaceSheet) {
                CreateStudySpaceView(onCreate: { title, icon, category, description, status, workspaceColorHex in
                    viewModel.addStudyWorkspace(
                        title: title,
                        iconName: icon,
                        category: category,
                        description: description,
                        status: status,
                        workspaceColorHex: workspaceColorHex
                    )
                    showCreateStudySpaceSheet = false
                })
            }
            .navigationDestination(item: $selectedStudySpace) { space in
                ActiveWorkspaceView(studySpace: space)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                withAnimation(.easeOut(duration: 0.35)) {
                    animateGreeting = true
                }
            }
        }
    }
}

#Preview {
    HomeDashboardView()
        .environmentObject(AuthViewModel())
}

private enum ProfileTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)
    static let cardBackground = Color.white.opacity(0.9)
    static let textPrimary = Color(red: 0.12, green: 0.15, blue: 0.20)
    static let textSecondary = Color(red: 0.12, green: 0.15, blue: 0.20).opacity(0.62)
}

private struct ProfileAccountView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showEditProfileSheet = false

    private let accountRows: [(String, String)] = [
        ("Account Security", "lock.shield"),
        ("Connected Providers", "link"),
        ("Billing & Plan", "creditcard")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("Profile")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(ProfileTheme.accent)
                .padding(.top, 8)

            VStack(spacing: 14) {
                profileImageView(size: 82)

                VStack(spacing: 4) {
                    Text(authViewModel.displayName)
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundStyle(ProfileTheme.textPrimary)
                    Text("@\(authViewModel.username)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(ProfileTheme.accent.opacity(0.9))
                    Text(authViewModel.emailAddress)
                        .font(.system(size: 14, weight: .medium, design: .default))
                        .foregroundStyle(ProfileTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(18)
            .background(ProfileTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(ProfileTheme.accent.opacity(0.12), lineWidth: 1.2)
            )

            VStack(spacing: 10) {
                ForEach(accountRows, id: \.0) { title, icon in
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(ProfileTheme.accent)
                            .frame(width: 26)
                        Text(title)
                            .font(.system(size: 15, weight: .semibold, design: .default))
                            .foregroundStyle(ProfileTheme.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(ProfileTheme.textSecondary)
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 52)
                    .background(Color.white.opacity(0.82))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(ProfileTheme.accent.opacity(0.12), lineWidth: 1.1)
                    )
                }
            }

            Button(action: {
                showEditProfileSheet = true
            }) {
                HStack(spacing: 10) {
                    Image(systemName: "pencil.circle.fill")
                        .font(.system(size: 16, weight: .semibold))
                    Text("Edit Profile")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                }
                .foregroundStyle(ProfileTheme.accent)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(ProfileTheme.accentSoft.opacity(0.75))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(ProfileTheme.accent.opacity(0.18), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Button(action: {
                authViewModel.logout()
            }) {
                Text("Logout")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.78, green: 0.35, blue: 0.40), Color(red: 0.66, green: 0.24, blue: 0.30)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer(minLength: 12)
        }
        .padding(.horizontal, HomeTheme.horizontalPadding)
        .padding(.bottom, 96)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(ProfileTheme.background)
        .sheet(isPresented: $showEditProfileSheet) {
            EditProfileSheet(isPresented: $showEditProfileSheet)
                .environmentObject(authViewModel)
        }
    }

    @ViewBuilder
    private func profileImageView(size: CGFloat) -> some View {
        if
            let data = authViewModel.profileImageData,
            let image = UIImage(data: data)
        {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(ProfileTheme.accent.opacity(0.15), lineWidth: 1.2)
                )
        } else {
            Circle()
                .fill(ProfileTheme.accentSoft)
                .frame(width: size, height: size)
                .overlay(
                    Text(authViewModel.userInitials)
                        .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                        .foregroundStyle(ProfileTheme.accent)
                )
        }
    }
}

private struct EditProfileSheet: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var isPresented: Bool

    @State private var displayName = ""
    @State private var username = ""
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var pendingImageData: Data?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(spacing: 12) {
                        profilePreview(size: 96)
                        PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                            Label("Change Profile Photo", systemImage: "photo")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundStyle(ProfileTheme.accent)
                                .padding(.horizontal, 14)
                                .frame(height: 40)
                                .background(ProfileTheme.accentSoft.opacity(0.72))
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Name")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ProfileTheme.textSecondary)
                        TextField("Enter your name", text: $displayName)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(ProfileTheme.accent.opacity(0.12), lineWidth: 1)
                            )
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(ProfileTheme.textSecondary)
                        TextField("Enter username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding(.horizontal, 14)
                            .frame(height: 48)
                            .background(Color.white.opacity(0.92))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(ProfileTheme.accent.opacity(0.12), lineWidth: 1)
                            )
                    }

                    Text("Your email stays linked to your account and cannot be changed here.")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(ProfileTheme.textSecondary)

                    Button(action: saveProfile) {
                        ZStack {
                            Text("Save Changes")
                                .font(.system(size: 16, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                                .opacity(authViewModel.isLoading ? 0 : 1)
                            if authViewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.33, green: 0.71, blue: 0.52), Color(red: 0.24, green: 0.60, blue: 0.44)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .disabled(authViewModel.isLoading)
                    .padding(.top, 6)
                }
                .padding(.horizontal, HomeTheme.horizontalPadding)
                .padding(.top, 18)
                .padding(.bottom, 24)
            }
            .background(ProfileTheme.background.ignoresSafeArea())
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundStyle(ProfileTheme.textSecondary)
                }
            }
            .overlay(alignment: .top) {
                if let errorMessage = authViewModel.errorMessage, !errorMessage.isEmpty {
                    Text(errorMessage)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Color(red: 0.67, green: 0.22, blue: 0.30))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.95))
                        .clipShape(Capsule())
                        .padding(.top, 10)
                }
            }
            .onAppear {
                authViewModel.errorMessage = nil
                displayName = authViewModel.displayName
                username = authViewModel.username
                pendingImageData = authViewModel.profileImageData
            }
            .onChange(of: selectedPhotoItem) { newItem in
                guard let newItem else { return }
                Task {
                    if let data = try? await newItem.loadTransferable(type: Data.self) {
                        await MainActor.run {
                            pendingImageData = data
                        }
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }

    @ViewBuilder
    private func profilePreview(size: CGFloat) -> some View {
        if let data = pendingImageData, let image = UIImage(data: data) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: size, height: size)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(ProfileTheme.accent.opacity(0.2), lineWidth: 1.2)
                )
        } else {
            Circle()
                .fill(ProfileTheme.accentSoft)
                .frame(width: size, height: size)
                .overlay(
                    Text(authViewModel.userInitials)
                        .font(.system(size: size * 0.30, weight: .bold, design: .rounded))
                        .foregroundStyle(ProfileTheme.accent)
                )
        }
    }

    private func saveProfile() {
        Task {
            await authViewModel.updateProfile(
                displayName: displayName,
                username: username,
                profileImageData: pendingImageData
            )
            if authViewModel.errorMessage == nil {
                isPresented = false
            }
        }
    }
}
