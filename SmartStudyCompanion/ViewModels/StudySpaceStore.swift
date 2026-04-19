import Foundation
import Combine

final class StudySpaceStore: ObservableObject {
    static let shared = StudySpaceStore()

    @Published private(set) var studySpaces: [StudySpace]

    init(seed: [StudySpace] = StudySpace.sampleData) {
        studySpaces = seed
    }

    func addStudySpace(title: String, iconName: String, category: String, description: String, status: String = "Active") {
        let newSpace = StudySpace(
            id: UUID(),
            title: title.isEmpty ? "Untitled Space" : title,
            description: description.isEmpty ? "No description yet." : description,
            iconName: iconName,
            status: status,
            documentCount: 0,
            noteCount: 0,
            lastUpdated: "Just now",
            lastOpened: "Opened just now",
            aiOutputCount: 0,
            progress: 0.0
        )
        studySpaces.insert(newSpace, at: 0)
    }

    func updateStudySpace(
        id: UUID,
        title: String,
        iconName: String,
        category: String,
        description: String,
        status: String
    ) {
        guard let index = studySpaces.firstIndex(where: { $0.id == id }) else { return }
        let existing = studySpaces[index]
        studySpaces[index] = StudySpace(
            id: existing.id,
            title: title.isEmpty ? existing.title : title,
            description: description.isEmpty ? existing.description : description,
            iconName: iconName,
            status: status,
            documentCount: existing.documentCount,
            noteCount: existing.noteCount,
            lastUpdated: "Last updated just now",
            lastOpened: "Opened just now",
            aiOutputCount: existing.aiOutputCount,
            progress: existing.progress
        )
    }

    func updateStatus(for id: UUID, status: String) {
        guard let index = studySpaces.firstIndex(where: { $0.id == id }) else { return }
        let existing = studySpaces[index]
        studySpaces[index] = StudySpace(
            id: existing.id,
            title: existing.title,
            description: existing.description,
            iconName: existing.iconName,
            status: status,
            documentCount: existing.documentCount,
            noteCount: existing.noteCount,
            lastUpdated: "Last updated just now",
            lastOpened: "Opened just now",
            aiOutputCount: existing.aiOutputCount,
            progress: existing.progress
        )
    }

    func deleteStudySpace(id: UUID) {
        studySpaces.removeAll { $0.id == id }
    }
}
