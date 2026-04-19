import Foundation
import SwiftUI
import Combine

@MainActor
final class ActiveWorkspaceViewModel: ObservableObject {
    @Published var workspace: StudySpace
    @Published var materials: [StudyMaterial] = []
    @Published var isImporting = false
    @Published var importErrorMessage: String?
    @Published var selectedMaterialForPreview: StudyMaterial?
    @Published var isWorkspaceDeleted = false
    @Published var notes: [WorkspaceNote] = []

    private let store: StudySpaceStore
    private let storageService: WorkspaceMaterialStorageService
    private let noteStorageService: WorkspaceNoteStorageService
    private var cancellables = Set<AnyCancellable>()

    init(
        studySpace: StudySpace,
        storageService: WorkspaceMaterialStorageService,
        noteStorageService: WorkspaceNoteStorageService,
        store: StudySpaceStore
    ) {
        self.workspace = studySpace
        self.store = store
        self.storageService = storageService
        self.noteStorageService = noteStorageService
        bindWorkspaceUpdates()
        loadMaterials()
        loadNotes()
    }

    var workspaceID: UUID {
        workspace.id
    }

    var materialCount: Int {
        materials.count
    }

    var noteCount: Int {
        notes.count
    }

    var aiOutputCount: Int {
        workspace.aiOutputCount
    }

    var referencedMaterials: [ReferencedMaterial] {
        materials.map {
            ReferencedMaterial(
                materialID: $0.id,
                title: $0.title,
                type: $0.type,
                localPath: $0.storedPath,
                isSelected: $0.isSelectedForAIContext
            )
        }
    }

    var aiContextSource: AIContextSource {
        AIContextSource(
            workspaceID: workspaceID,
            workspaceTitle: workspace.title,
            materials: referencedMaterials
        )
    }

    func editWorkspace(title: String, iconName: String, category: String, description: String, status: String) {
        store.updateStudySpace(
            id: workspace.id,
            title: title,
            iconName: iconName,
            category: category,
            description: description,
            status: status
        )
    }

    func updateWorkspaceStatus(_ status: String) {
        store.updateStatus(for: workspace.id, status: status)
    }

    func deleteWorkspace() {
        store.deleteStudySpace(id: workspace.id)
        isWorkspaceDeleted = true
    }

    func loadMaterials() {
        do {
            materials = try storageService.loadMaterials(workspaceID: workspaceID)
                .sorted { $0.createdAt > $1.createdAt }
        } catch {
            importErrorMessage = "Could not load workspace materials."
            materials = []
        }
    }

    func loadNotes() {
        do {
            notes = try noteStorageService.loadNotes(workspaceID: workspaceID)
                .sorted { $0.updatedAt > $1.updatedAt }
        } catch {
            notes = []
        }
    }

    func makeDraftNote() -> WorkspaceNote {
        WorkspaceNote(workspaceID: workspaceID)
    }

    func saveNote(_ note: WorkspaceNote) {
        var updated = note
        let trimmedContent = updated.content.trimmingCharacters(in: .whitespacesAndNewlines)
        let firstLine = trimmedContent.split(separator: "\n").first.map(String.init) ?? ""
        updated.title = firstLine.isEmpty ? "Untitled Note" : String(firstLine.prefix(52))
        updated.updatedAt = Date()

        if let index = notes.firstIndex(where: { $0.id == updated.id }) {
            notes[index] = updated
        } else {
            notes.insert(updated, at: 0)
        }

        do {
            try noteStorageService.saveNotes(notes, workspaceID: workspaceID)
        } catch {
            importErrorMessage = "Could not save note. Please try again."
        }
    }

    func importPhoto(data: Data, fileName: String?) async {
        isImporting = true
        defer { isImporting = false }

        do {
            let material = try storageService.persistPhotoData(data, workspaceID: workspaceID, suggestedFileName: fileName)
            materials.insert(material, at: 0)
            try persistMaterials()
        } catch {
            importErrorMessage = "Photo import failed. Please try again."
        }
    }

    func importDocument(from sourceURL: URL) async {
        isImporting = true
        defer { isImporting = false }

        let didStartAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if didStartAccess { sourceURL.stopAccessingSecurityScopedResource() }
        }

        do {
            let material = try storageService.persistDocument(at: sourceURL, workspaceID: workspaceID)

            guard isSupportedType(material.type) else {
                importErrorMessage = "Unsupported file type. Please import PDF, TXT, DOC, or DOCX."
                return
            }

            materials.insert(material, at: 0)
            try persistMaterials()
        } catch {
            importErrorMessage = "File import failed. Please try a different document."
        }
    }

    func toggleMaterialSelectionForAI(_ materialID: UUID) {
        guard let index = materials.firstIndex(where: { $0.id == materialID }) else { return }
        materials[index].isSelectedForAIContext.toggle()
        do {
            try persistMaterials()
        } catch {
            importErrorMessage = "Could not update AI source selection."
        }
    }

    func openPreview(for material: StudyMaterial) {
        selectedMaterialForPreview = material
    }

    private func persistMaterials() throws {
        try storageService.saveMaterials(materials, workspaceID: workspaceID)
    }

    private func isSupportedType(_ type: StudyMaterialType) -> Bool {
        switch type {
        case .image, .pdf, .document, .text:
            return true
        case .other:
            return false
        }
    }

    private func bindWorkspaceUpdates() {
        store.$studySpaces
            .receive(on: DispatchQueue.main)
            .sink { [weak self] spaces in
                guard let self else { return }
                if let updated = spaces.first(where: { $0.id == self.workspace.id }) {
                    self.workspace = updated
                } else {
                    self.isWorkspaceDeleted = true
                }
            }
            .store(in: &cancellables)
    }
}
