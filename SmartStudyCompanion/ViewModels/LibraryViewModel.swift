import Foundation
import Combine

final class LibraryViewModel: ObservableObject {
    @Published var studySpaces: [StudySpace]
    @Published var searchText: String
    @Published var selectedFilter: String

    private let store: StudySpaceStore
    private var cancellables = Set<AnyCancellable>()

    init(store: StudySpaceStore = .shared) {
        self.store = store
        studySpaces = store.studySpaces
        searchText = ""
        selectedFilter = "Recently Updated"

        store.$studySpaces
            .sink { [weak self] spaces in
                self?.studySpaces = spaces
            }
            .store(in: &cancellables)
    }

    var filteredStudySpaces: [StudySpace] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = query.isEmpty
            ? studySpaces
            : studySpaces.filter {
                $0.title.localizedCaseInsensitiveContains(query) ||
                $0.description.localizedCaseInsensitiveContains(query)
            }

        if selectedFilter == "Alphabetical" {
            return filtered.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        }

        return filtered
    }

    func addStudySpace(title: String, iconName: String, category: String, description: String) {
        store.addStudySpace(title: title, iconName: iconName, category: category, description: description)
    }
}
