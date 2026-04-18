import Foundation
import SwiftUI
import Combine

@MainActor
final class ActiveWorkspaceViewModel: ObservableObject {
    @Published var materials: [StudyMaterial] = []
    @Published var isImporting = false
    @Published var importErrorMessage: String?
    @Published var selectedMaterialForPreview: StudyMaterial?

    private let studySpace: StudySpace
    private let storageService: WorkspaceMaterialStorageService

    init(studySpace: StudySpace, storageService: WorkspaceMaterialStorageService) {
        self.studySpace = studySpace
        self.storageService = storageService
        loadMaterials()
    }

    convenience init(studySpace: StudySpace) {
        self.init(studySpace: studySpace, storageService: .shared)
    }

    var workspaceID: UUID {
        studySpace.id
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
            workspaceTitle: studySpace.title,
            materials: referencedMaterials
        )
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
}
