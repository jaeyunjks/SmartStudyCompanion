import Foundation
import Combine

final class StudySpaceStore: ObservableObject {
    static let shared = StudySpaceStore()

    @Published private(set) var studySpaces: [StudySpace]

    init(seed: [StudySpace] = StudySpace.sampleData) {
        studySpaces = seed
    }

    func addStudySpace(title: String, iconName: String, category: String, description: String) {
        let newSpace = StudySpace(
            id: UUID(),
            title: title.isEmpty ? "Untitled Space" : title,
            description: description.isEmpty ? "No description yet." : description,
            iconName: iconName,
            status: "Active",
            documentCount: 0,
            noteCount: 0,
            lastUpdated: "Just now",
            progress: 0.0
        )
        studySpaces.insert(newSpace, at: 0)
    }
}
