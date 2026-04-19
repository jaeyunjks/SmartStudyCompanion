import Foundation
import Combine

final class HomeDashboardViewModel: ObservableObject {
    @Published var featuredStudySpaces: [StudySpace]
    @Published var recentStudySpaces: [StudySpace]
    @Published var quickActions: [String]
    @Published var currentUser: User?

    private let store: StudySpaceStore
    private var cancellables = Set<AnyCancellable>()

    init(store: StudySpaceStore = .shared) {
        self.store = store
        featuredStudySpaces = Array(store.studySpaces.prefix(2))
        recentStudySpaces = Array(store.studySpaces.prefix(3))
        quickActions = ["Review Flashcards", "Continue Summary", "Take a Quiz", "AI Insights"]
        currentUser = User(
            id: UUID().uuidString,
            email: "yafie@example.com",
            username: "yafie",
            fullName: "Yafie",
            createdAt: Date(),
            updatedAt: Date()
        )

        store.$studySpaces
            .sink { [weak self] spaces in
                self?.featuredStudySpaces = Array(spaces.prefix(2))
                self?.recentStudySpaces = Array(spaces.prefix(3))
            }
            .store(in: &cancellables)
    }

    func addStudySpace(title: String, iconName: String, category: String, description: String, status: String) {
        store.addStudySpace(title: title, iconName: iconName, category: category, description: description, status: status)
    }

    var greetingText: String {
        let name = currentUser?.fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasName = !(name?.isEmpty ?? true)
        let firstName = hasName ? (name?.components(separatedBy: " ").first ?? "") : ""

        let hour = Calendar.current.component(.hour, from: Date())
        if (5..<12).contains(hour), hasName {
            return "Good morning, \(firstName)"
        }
        if (12..<17).contains(hour), hasName {
            return "Good afternoon, \(firstName)"
        }
        if (17..<22).contains(hour), hasName {
            return "Good evening, \(firstName)"
        }
        return "Welcome back"
    }

    var greetingSupportText: String {
        "\(completedSpacesCount) spaces in progress today"
    }

    var userInitials: String {
        guard let fullName = currentUser?.fullName, !fullName.isEmpty else { return "SC" }
        let parts = fullName.split(separator: " ").prefix(2)
        return parts.map { String($0.prefix(1)).uppercased() }.joined()
    }

    var completedSpacesCount: Int {
        featuredStudySpaces.filter { $0.progress >= 0.5 }.count
    }
}
