import Foundation
import Combine

final class StudySpaceStore: ObservableObject {
    static let shared = StudySpaceStore()

    @Published private(set) var studySpaces: [StudySpace]

    init(seed: [StudySpace] = StudySpace.sampleData) {
        studySpaces = seed
    }

    func addStudyWorkspace(
        title: String,
        iconName: String,
        category: String,
        description: String,
        status: String = "Active",
        workspaceColorHex: String = "#388767"
    ) {
        let newSpace = StudySpace(
            id: UUID(),
            title: title.isEmpty ? "Untitled Workspace" : title,
            description: description.isEmpty ? "No description yet." : description,
            iconName: iconName,
            category: category,
            status: status,
            workspaceColorHex: workspaceColorHex,
            documentCount: 0,
            noteCount: 0,
            lastUpdated: "Just now",
            lastOpened: "Opened just now",
            aiOutputCount: 0,
            progress: 0.0
        )
        studySpaces.insert(newSpace, at: 0)
    }

    func updateStudyWorkspace(
        id: UUID,
        title: String,
        iconName: String,
        category: String,
        description: String,
        status: String,
        workspaceColorHex: String
    ) {
        guard let index = studySpaces.firstIndex(where: { $0.id == id }) else { return }
        let existing = studySpaces[index]
        studySpaces[index] = StudySpace(
            id: existing.id,
            title: title.isEmpty ? existing.title : title,
            description: description.isEmpty ? existing.description : description,
            iconName: iconName,
            category: category,
            status: status,
            workspaceColorHex: workspaceColorHex,
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
            category: existing.category,
            status: status,
            workspaceColorHex: existing.workspaceColorHex,
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
