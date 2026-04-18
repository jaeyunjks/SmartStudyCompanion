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
            ZStack {
                HomeTheme.background.ignoresSafeArea()

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
                    .padding(.bottom, 20)
                }
            }
            .safeAreaInset(edge: .top) {
                HomeTopBarView(
                    greetingText: viewModel.greetingText,
                    userInitials: viewModel.userInitials,
                    animateGreeting: animateGreeting,
                    onSettingsTap: {}
                )
                .padding(.top, 2)
            }
            .safeAreaInset(edge: .bottom) {
                HomeBottomNavBarView(selected: selectedTab) { tab in
                    withAnimation(.easeInOut(duration: 0.22)) {
                        selectedTab = tab
                    }
                }
                .padding(.bottom, 2)
            }
            .sheet(isPresented: $showCreateStudySpaceSheet) {
                CreateStudySpaceView(onCreate: { title, icon, category, description in
                    viewModel.addStudySpace(title: title, iconName: icon, category: category, description: description)
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
