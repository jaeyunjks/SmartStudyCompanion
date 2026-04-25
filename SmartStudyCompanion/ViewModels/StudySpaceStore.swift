import Foundation
import Combine

final class StudySpaceStore: ObservableObject {
    static let shared = StudySpaceStore()
    private static let storageKey = "studyspaces.saved.v1"
    private let apiService = APIService.shared

    @Published private(set) var studySpaces: [StudySpace]

    init(seed: [StudySpace] = []) {
        let persisted = Self.loadPersistedStudySpaces()
        studySpaces = persisted.isEmpty ? seed : persisted
        Task {
            await refreshFromBackend()
        }
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
            status: "Active",
            workspaceColorHex: workspaceColorHex,
            documentCount: 0,
            noteCount: 0,
            lastUpdated: "Just now",
            lastOpened: "Opened just now",
            aiOutputCount: 0,
            progress: 0.0
        )
        studySpaces.insert(newSpace, at: 0)
        persistStudySpaces()

        let temporaryId = newSpace.id
        Task { [weak self] in
            await self?.createWorkspaceOnBackend(localId: temporaryId, workspace: newSpace)
        }
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
        persistStudySpaces()

        let updatedSpace = studySpaces[index]
        Task { [weak self] in
            await self?.updateWorkspaceOnBackend(workspace: updatedSpace)
        }
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
        persistStudySpaces()

        let updatedSpace = studySpaces[index]
        Task { [weak self] in
            await self?.updateWorkspaceOnBackend(workspace: updatedSpace)
        }
    }

    func deleteStudySpace(id: UUID) {
        studySpaces.removeAll { $0.id == id }
        persistStudySpaces()

        Task { [weak self] in
            await self?.deleteWorkspaceOnBackend(id: id)
        }
    }

    func refreshFromBackend() async {
        do {
            let remote = try await apiService.fetchWorkspaces()
            await MainActor.run {
                self.studySpaces = remote.map(StudySpace.fromRemote(_:))
                self.persistStudySpaces()
            }
        } catch {
            // Keep local cached data when backend is unavailable or user is signed out.
        }
    }

    func clearLocalCache() {
        studySpaces = []
        persistStudySpaces()
    }

    private func persistStudySpaces() {
        guard let data = try? JSONEncoder().encode(studySpaces) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }

    private static func loadPersistedStudySpaces() -> [StudySpace] {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode([StudySpace].self, from: data)
        else {
            return []
        }
        return decoded
    }

    private func createWorkspaceOnBackend(localId: UUID, workspace: StudySpace) async {
        do {
            let remote = try await apiService.createWorkspace(request: workspace.createRequest)
            let mapped = StudySpace.fromRemote(remote)
            await MainActor.run {
                guard let index = self.studySpaces.firstIndex(where: { $0.id == localId }) else { return }
                self.studySpaces[index] = mapped
                self.persistStudySpaces()
            }
        } catch {
            // Keep local workspace if backend sync fails.
        }
    }

    private func updateWorkspaceOnBackend(workspace: StudySpace) async {
        do {
            _ = try await apiService.updateWorkspace(id: workspace.id, request: workspace.updateRequest)
        } catch {
            // Silent failure for now; local value is preserved and can be retried.
        }
    }

    private func deleteWorkspaceOnBackend(id: UUID) async {
        do {
            try await apiService.deleteWorkspace(id: id)
        } catch {
            // Silent failure for now; backend may already be in sync or unavailable.
        }
    }
}
