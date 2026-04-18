import SwiftUI

enum LibraryTheme {
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

/// Home/Library screen showing recent documents and quick actions
struct LibraryView: View {
    @StateObject private var viewModel = LibraryViewModel()
    @State private var selectedTab: LibraryNavItem = .library
    @State private var showFilterSheet = false
    @State private var showCreateStudySpaceSheet = false
    @State private var selectedStudySpace: StudySpace?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                LibraryTheme.background.ignoresSafeArea()

                ScrollView {
                    LazyVStack(alignment: .leading, spacing: LibraryTheme.sectionSpacing) {
                        LibraryHeroHeaderView()
                        LibrarySearchBarView(query: $viewModel.searchText)
                        LibraryFilterChipsView(
                            selectedSort: $viewModel.selectedSort,
                            hasActiveAdvancedFilters: viewModel.hasActiveAdvancedFilters,
                            onFilterTap: { showFilterSheet = true }
                        )
                        StudySpacesSectionView(spaces: viewModel.filteredStudySpaces) { space in
                            selectedStudySpace = space
                        }
                    }
                    .padding(.horizontal, LibraryTheme.horizontalPadding)
                    .padding(.top, 14)
                    .padding(.bottom, 22)
                }
                .safeAreaInset(edge: .top) {
                    LibraryTopBarView()
                }
                .safeAreaInset(edge: .bottom) {
                    LibraryBottomNavBarView(selected: selectedTab) { tab in
                        withAnimation(.easeInOut(duration: 0.22)) {
                            selectedTab = tab
                        }
                    }
                    .padding(.bottom, 2)
                }

                LibraryFloatingAddButtonView {
                    showCreateStudySpaceSheet = true
                }
                .padding(.trailing, LibraryTheme.horizontalPadding)
                .padding(.bottom, 84)
            }
            .sheet(isPresented: $showFilterSheet) {
                LibraryAdvancedFilterSheetView(
                    selectedStatus: $viewModel.selectedStatus,
                    selectedSort: $viewModel.selectedSort,
                    selectedCategory: $viewModel.selectedCategory,
                    statuses: ["All", "Active", "In Progress", "Priority", "Review", "Completed"],
                    sorts: ["Recently Updated", "Alphabetical"],
                    categories: ["All", "Cloud", "AI", "Data", "Ethics", "Neuroscience"]
                )
                .presentationDetents([.fraction(0.45), .medium])
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
        }
    }
}

#Preview {
    LibraryView()
}
