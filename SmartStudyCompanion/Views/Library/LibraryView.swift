import SwiftUI

enum LibraryTheme {
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
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: LibraryTheme.sectionSpacing) {
                        LibraryHeroHeaderView()
                        LibrarySearchBarView(query: $viewModel.searchText)
                        LibraryFilterChipsView(selectedFilter: $viewModel.selectedFilter, onFilterTap: {
                            showFilterSheet = true
                        })
                        StudySpacesSectionView(spaces: viewModel.filteredStudySpaces) { space in
                            selectedStudySpace = space
                        }
                    }
                    .padding(.horizontal, LibraryTheme.horizontalPadding)
                    .padding(.top, 12)
                    .padding(.bottom, 90)
                }
                .background(LibraryTheme.background.ignoresSafeArea())
                .safeAreaInset(edge: .top) {
                    LibraryTopBarView()
                }
                .safeAreaInset(edge: .bottom) {
                    LibraryBottomNavBarView(selected: selectedTab) { tab in
                        selectedTab = tab
                    }
                }

                LibraryFloatingAddButtonView {
                    showCreateStudySpaceSheet = true
                }
                .padding(.trailing, LibraryTheme.horizontalPadding)
                .padding(.bottom, 92)
            }
            .sheet(isPresented: $showFilterSheet) {
                LibraryPlaceholderSheetView(title: "Advanced Filters")
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

private struct LibraryPlaceholderSheetView: View {
    let title: String

    var body: some View {
        VStack(spacing: 16) {
            Text(title)
                .font(.title2.weight(.bold))
            Text("This is a placeholder screen.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    LibraryView()
}
