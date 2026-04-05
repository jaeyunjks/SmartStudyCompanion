import SwiftUI

enum HomeTheme {
    static let accent = Color(red: 0.22, green: 0.53, blue: 0.40)
    static let accentSoft = Color(red: 0.86, green: 0.94, blue: 0.89)
    static let background = Color(red: 0.97, green: 0.98, blue: 0.97)
    static let cardBackground = Color(.systemBackground)
    static let mutedText = Color(.secondaryLabel)
    static let secondaryBackground = Color(.secondarySystemBackground)

    static let horizontalPadding: CGFloat = 20
    static let sectionSpacing: CGFloat = 22
    static let cardCornerRadius: CGFloat = 20
    static let chipCornerRadius: CGFloat = 18
    static let smallCornerRadius: CGFloat = 14
}

struct HomeDashboardView: View {
    @StateObject private var viewModel = HomeDashboardViewModel()
    @State private var selectedTab: HomeNavItem = .home
    @State private var selectedQuickAction: String?
    @State private var showQuickActionAlert = false
    @State private var showCreateStudySpaceSheet = false
    @State private var selectedStudySpace: StudySpace?

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: HomeTheme.sectionSpacing) {
                    HeroSectionView(onCreateStudySpace: {
                        showCreateStudySpaceSheet = true
                    })
                    QuickActionsChipsView(actions: viewModel.quickActions) { action in
                        selectedQuickAction = action
                        showQuickActionAlert = true
                    }
                    ContinueLearningSectionView(spaces: viewModel.featuredStudySpaces) { space in
                        selectedStudySpace = space
                    }
                    RecentStudySpacesSectionView(spaces: viewModel.recentStudySpaces) { space in
                        selectedStudySpace = space
                    }
                }
                .padding(.horizontal, HomeTheme.horizontalPadding)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(HomeTheme.background.ignoresSafeArea())
            .safeAreaInset(edge: .top) {
                HomeTopBarView()
            }
            .safeAreaInset(edge: .bottom) {
                HomeBottomNavBarView(selected: selectedTab) { tab in
                    selectedTab = tab
                }
            }
            .sheet(isPresented: $showCreateStudySpaceSheet) {
                CreateStudySpaceView(onCreate: { title, icon, category, description in
                    viewModel.addStudySpace(title: title, iconName: icon, category: category, description: description)
                    showCreateStudySpaceSheet = false
                })
            }
            .alert("Quick Action", isPresented: $showQuickActionAlert, presenting: selectedQuickAction) { _ in
                Button("OK", role: .cancel) {}
            } message: { action in
                Text("Selected: \(action)")
            }
            .navigationDestination(item: $selectedStudySpace) { space in
                ActiveWorkspaceView(studySpace: space)
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    HomeDashboardView()
}
