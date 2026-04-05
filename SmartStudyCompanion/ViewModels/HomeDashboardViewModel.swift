import Foundation
import Combine

final class HomeDashboardViewModel: ObservableObject {
    @Published var featuredStudySpaces: [StudySpace]
    @Published var recentStudySpaces: [StudySpace]
    @Published var quickActions: [String]

    private let store: StudySpaceStore
    private var cancellables = Set<AnyCancellable>()

    init(store: StudySpaceStore = .shared) {
        self.store = store
        featuredStudySpaces = Array(store.studySpaces.prefix(2))
        recentStudySpaces = Array(store.studySpaces.prefix(3))
        quickActions = ["Review Flashcards", "Continue Summary", "Take a Quiz", "AI Insights"]

        store.$studySpaces
            .sink { [weak self] spaces in
                self?.featuredStudySpaces = Array(spaces.prefix(2))
                self?.recentStudySpaces = Array(spaces.prefix(3))
            }
            .store(in: &cancellables)
    }

    func addStudySpace(title: String, iconName: String, category: String, description: String) {
        store.addStudySpace(title: title, iconName: iconName, category: category, description: description)
    }
}
