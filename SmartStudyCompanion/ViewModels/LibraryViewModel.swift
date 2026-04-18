import Foundation
import Combine

final class LibraryViewModel: ObservableObject {
    @Published var studySpaces: [StudySpace]
    @Published var searchText: String
    @Published var selectedSort: String
    @Published var selectedStatus: String
    @Published var selectedCategory: String

    private let store: StudySpaceStore
    private var cancellables = Set<AnyCancellable>()

    init(store: StudySpaceStore = .shared) {
        self.store = store
        studySpaces = store.studySpaces
        searchText = ""
        selectedSort = "Recently Updated"
        selectedStatus = "All"
        selectedCategory = "All"

        store.$studySpaces
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

        let statusFiltered = selectedStatus == "All"
            ? queryFiltered
            : queryFiltered.filter { $0.status == selectedStatus }

        let categoryFiltered = selectedCategory == "All"
            ? statusFiltered
            : statusFiltered.filter { space in
                space.title.localizedCaseInsensitiveContains(selectedCategory) ||
                space.description.localizedCaseInsensitiveContains(selectedCategory)
            }

        if selectedSort == "Alphabetical" {
            return categoryFiltered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return categoryFiltered
    }

    func addStudySpace(title: String, iconName: String, category: String, description: String) {
        store.addStudySpace(title: title, iconName: iconName, category: category, description: description)
    }

    var hasActiveAdvancedFilters: Bool {
        selectedStatus != "All" || selectedCategory != "All"
    }
}
