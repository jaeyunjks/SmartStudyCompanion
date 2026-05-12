import Foundation
import Combine

final class LibraryViewModel: ObservableObject {
    @Published var studySpaces: [StudySpace]
    @Published var searchText: String
    @Published var selectedSort: LibrarySortOption
    @Published var selectedStatus: StudySpaceFilterStatus
    @Published var selectedCategory: String

    private let store: StudySpaceStore
    private var cancellables = Set<AnyCancellable>()

    init(store: StudySpaceStore? = nil) {
        self.store = store ?? Self.makeDefaultStore()
        studySpaces = self.store.studySpaces
        searchText = ""
        selectedSort = .recentlyUpdated
        selectedStatus = .all
        selectedCategory = "All"

        self.store.$studySpaces
            .sink { [weak self] spaces in
                self?.studySpaces = spaces
            }
            .store(in: &cancellables)
    }

    var filteredStudySpaces: [StudySpace] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let queryFiltered = query.isEmpty
            ? studySpaces
            : studySpaces.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                $0.description.localizedCaseInsensitiveContains(query)
            }

        let statusFiltered = selectedStatus == .all
            ? queryFiltered
            : queryFiltered.filter { selectedStatus.matches($0.status) }

        let categoryFiltered = selectedCategory == "All"
            ? statusFiltered
            : statusFiltered.filter { space in
                space.title.localizedCaseInsensitiveContains(selectedCategory) ||
                space.description.localizedCaseInsensitiveContains(selectedCategory)
            }

        if selectedSort == .alphabetical {
            return categoryFiltered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return categoryFiltered
    }

    func addStudyWorkspace(
        title: String,
        iconName: String,
        category: String,
        description: String,
        status: StudySpaceStatus,
        workspaceColorHex: String
    ) {
        store.addStudyWorkspace(
            title: title,
            iconName: iconName,
            category: category,
            description: description,
            status: status,
            workspaceColorHex: workspaceColorHex
        )
    }

    var hasActiveAdvancedFilters: Bool {
        selectedStatus != .all || selectedCategory != "All"
    }

    private static func makeDefaultStore() -> StudySpaceStore {
        StudySpaceStore.shared
    }
}
