import SwiftUI

enum HomeTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)
    static let cardBackground = Color(.systemBackground)
    static let mutedText = Color(.secondaryLabel)
    static let secondaryBackground = Color(.secondarySystemBackground)

    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 24
    static let cardCornerRadius: CGFloat = 22
    static let chipCornerRadius: CGFloat = 18
    static let smallCornerRadius: CGFloat = 16
    static let glassBorder = accent.opacity(0.10)
    static let glassShadow = accent.opacity(0.08)
}

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var selectedTab: HomeNavItem = .home
    @State private var showCreateStudySpaceSheet = false
    @State private var selectedStudySpace: StudySpace?
    @State private var animateGreeting = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let topInset = geometry.safeAreaInsets.top
                let bottomInset = geometry.safeAreaInsets.bottom

                ZStack(alignment: .bottom) {
                    HomeTheme.background.ignoresSafeArea()

                    VStack(spacing: 0) {
                        HomeTopBarView(
                            greetingText: viewModel.greetingText,
                            userInitials: viewModel.userInitials,
                            animateGreeting: animateGreeting,
                            onSettingsTap: {}
                        )
                        .padding(.top, topInset + 2)

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
                            .padding(.top, 14)
                            .padding(.bottom, 120 + bottomInset)
                        }
                    }

                    HomeBottomNavBarView(selected: selectedTab) { tab in
                        withAnimation(.easeInOut(duration: 0.22)) {
                            selectedTab = tab
                        }
                    }
                    .padding(.bottom, max(bottomInset, 8))
                }
                .ignoresSafeArea(edges: [.top, .bottom])
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
}
