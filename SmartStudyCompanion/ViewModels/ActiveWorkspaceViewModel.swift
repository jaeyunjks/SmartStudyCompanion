import Foundation
import SwiftUI
import Combine

struct WorkspaceActivityRecord: Identifiable {
    enum Kind {
        case note
        case material
        case summary
    }

    let id: UUID
    let kind: Kind
    let iconName: String
    let title: String
    let detail: String
    let occurredAt: Date
}

@MainActor
final class ActiveWorkspaceViewModel: ObservableObject {
    @Published var workspace: StudySpace
    @Published var materials: [StudyMaterial] = []
    @Published var isImporting = false
    @Published var importErrorMessage: String?
    @Published var selectedMaterialForPreview: StudyMaterial?
    @Published var isWorkspaceDeleted = false
    @Published var notes: [WorkspaceNote] = []
    @Published private(set) var cachedSummarySourceItems: [SummarySourceItem] = []
    @Published private(set) var cachedChatSourceContents: [WorkspaceContextSourceContent] = []

    private let store: StudySpaceStore
    private let storageService: WorkspaceMaterialStorageService
    private let noteStorageService: WorkspaceNoteStorageService
    private let summaryHistoryStorageService: WorkspaceSummaryHistoryStorageService
    private let apiService: APIService
    private var summaryVersions: [SummaryVersion] = []
    private var materialContentCache: [UUID: String] = [:]
    private var aiReadableContentTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()

    init(
        studySpace: StudySpace,
        storageService: WorkspaceMaterialStorageService? = nil,
        noteStorageService: WorkspaceNoteStorageService? = nil,
        summaryHistoryStorageService: WorkspaceSummaryHistoryStorageService? = nil,
        store: StudySpaceStore? = nil,
        apiService: APIService? = nil
    ) {
        self.workspace = studySpace
        self.store = store ?? Self.makeDefaultStudySpaceStore()
        self.storageService = storageService ?? Self.makeDefaultMaterialStorageService()
        self.noteStorageService = noteStorageService ?? Self.makeDefaultNoteStorageService()
        self.summaryHistoryStorageService = summaryHistoryStorageService ?? .shared
        self.apiService = apiService ?? .shared
        bindWorkspaceUpdates()
        loadMaterials()
        loadNotes()
        loadSummaryHistory()
        rebuildAIContentSnapshots()
        refreshAIReadableContent()
        Task { [weak self] in
            await self?.syncAllMaterialsToBackendBestEffort()
        }
    }

    deinit {
        aiReadableContentTask?.cancel()
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

    func workspaceSummaryRequest(selectedSourceIDs: Set<UUID>? = nil) -> WorkspaceAISummaryRequest {
        WorkspaceAISummaryRequest(
            workspaceId: workspaceID.uuidString,
            workspaceTitle: workspace.title,
            workspaceContent: buildWorkspaceSummaryContent(selectedSourceIDs: selectedSourceIDs) ?? ""
        )
    }

    func summarySourceItems() -> [SummarySourceItem] {
        cachedSummarySourceItems
    }

    func chatSourceContents() -> [WorkspaceContextSourceContent] {
        cachedChatSourceContents
    }

    private func rebuildAIContentSnapshots() {
        let noteItems: [SummarySourceItem] = notes.map { note in
            let content = extractNoteTextForSummary(note).trimmingCharacters(in: .whitespacesAndNewlines)
            return SummarySourceItem(
                id: note.id,
                name: note.displayTitle,
                kind: .note,
                content: content,
                isReadable: !content.isEmpty
            )
        }

        let materialItems: [SummarySourceItem] = materials.map { material in
            let content = cachedMaterialContent(for: material)
            return SummarySourceItem(
                id: material.id,
                name: material.title,
                kind: material.type == .image ? .photo : .file,
                content: content,
                isReadable: !content.isEmpty
            )
        }

        cachedSummarySourceItems = (noteItems + materialItems)
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }

        let noteSources = notes.map { note in
            WorkspaceContextSourceContent(
                id: note.id,
                title: note.displayTitle,
                sourceType: "Note",
                content: extractNoteTextForSummary(note).trimmingCharacters(in: .whitespacesAndNewlines),
                isSelected: true
            )
        }

        let materialSources = materials.map { material in
            return WorkspaceContextSourceContent(
                id: material.id,
                title: material.title,
                sourceType: chatSourceType(for: material),
                content: cachedMaterialContent(for: material),
                isSelected: material.isSelectedForAIContext
            )
        }

        cachedChatSourceContents = (noteSources + materialSources)
            .sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
    }

    private func cachedMaterialContent(for material: StudyMaterial) -> String {
        (materialContentCache[material.id] ?? material.previewText ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func refreshAIReadableContent() {
        rebuildAIContentSnapshots()
        aiReadableContentTask?.cancel()

        let materialsSnapshot = materials
        guard !materialsSnapshot.isEmpty else {
            materialContentCache = [:]
            rebuildAIContentSnapshots()
            return
        }

        let storageService = storageService
        aiReadableContentTask = Task.detached(priority: .utility) { [materialsSnapshot, storageService, weak self] in
            let extractedContent = Self.buildReadableContentSnapshot(
                materials: materialsSnapshot,
                storageService: storageService
            )

            await MainActor.run { [weak self, extractedContent] in
                guard let self else { return }
                guard !Task.isCancelled else { return }
                let currentIDs = Set(self.materials.map(\.id))
                self.materialContentCache = extractedContent.filter { currentIDs.contains($0.key) }
                self.rebuildAIContentSnapshots()
            }
        }
    }

    private func chatSourceType(for material: StudyMaterial) -> String {
        switch material.type {
        case .image: return "Photo/Image OCR"
        case .pdf: return "PDF"
        case .document: return "Document"
        case .text: return "Text file"
        case .other: return "File"
        }
    }

    private static func makeDefaultMaterialStorageService() -> WorkspaceMaterialStorageService {
        WorkspaceMaterialStorageService.shared
    }

    private static func makeDefaultNoteStorageService() -> WorkspaceNoteStorageService {
        WorkspaceNoteStorageService.shared
    }

    private static func makeDefaultStudySpaceStore() -> StudySpaceStore {
        StudySpaceStore.shared
    }

    func editWorkspace(
        title: String,
        iconName: String,
        category: String,
        description: String,
        status: StudySpaceStatus,
        workspaceColorHex: String
    ) {
        store.updateStudyWorkspace(
            id: workspace.id,
            title: title,
            iconName: iconName,
            category: category,
            description: description,
            status: status,
            workspaceColorHex: workspaceColorHex
        )
    }

    func updateWorkspaceStatus(_ status: StudySpaceStatus) {
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
            rebuildAIContentSnapshots()
            refreshAIReadableContent()
        } catch {
            importErrorMessage = "Could not load workspace materials."
            materials = []
            rebuildAIContentSnapshots()
        }
    }

    func loadNotes() {
        do {
            notes = try noteStorageService.loadNotes(workspaceID: workspaceID)
                .sorted { $0.updatedAt > $1.updatedAt }
            rebuildAIContentSnapshots()
        } catch {
            notes = []
            rebuildAIContentSnapshots()
        }
    }

    func makeDraftNote() -> WorkspaceNote {
        WorkspaceNote(workspaceID: workspaceID)
    }

    func saveNote(_ note: WorkspaceNote) {
        var updated = note
        let trimmedTitle = updated.title.trimmingCharacters(in: .whitespacesAndNewlines)
        updated.title = trimmedTitle.isEmpty ? "Untitled Note" : String(trimmedTitle.prefix(80))
        updated.updatedAt = Date()

        if let index = notes.firstIndex(where: { $0.id == updated.id }) {
            notes[index] = updated
        } else {
            notes.insert(updated, at: 0)
        }

        do {
            try noteStorageService.saveNotes(notes, workspaceID: workspaceID)
            rebuildAIContentSnapshots()
        } catch {
            importErrorMessage = "Could not save note. Please try again."
        }
    }

    func deleteNote(_ note: WorkspaceNote) {
        notes.removeAll { $0.id == note.id }
        do {
            try noteStorageService.saveNotes(notes, workspaceID: workspaceID)
            rebuildAIContentSnapshots()
        } catch {
            importErrorMessage = "Could not delete note. Please try again."
        }
    }

    func importPhoto(data: Data, fileName: String?) async {
        isImporting = true
        defer { isImporting = false }

        do {
            let storageService = storageService
            let workspaceID = workspaceID
            let material = try await Task.detached(priority: .userInitiated) {
                try Self.persistPhotoMaterial(
                    data: data,
                    workspaceID: workspaceID,
                    suggestedFileName: fileName,
                    using: storageService
                )
            }.value
            materials.insert(material, at: 0)
            materialContentCache[material.id] = material.previewText ?? ""
            rebuildAIContentSnapshots()
            try persistMaterials()
            do {
                try await syncMaterialToBackend(material)
            } catch {
                importErrorMessage = "Photo was saved locally but backend sync failed, so AI may not use it yet."
            }
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
            let storageService = storageService
            let workspaceID = workspaceID
            let material = try await Task.detached(priority: .userInitiated) {
                try Self.persistDocumentMaterial(
                    at: sourceURL,
                    workspaceID: workspaceID,
                    using: storageService
                )
            }.value

            materials.insert(material, at: 0)
            materialContentCache[material.id] = material.previewText ?? ""
            rebuildAIContentSnapshots()
            try persistMaterials()
            refreshAIReadableContent()
            do {
                try await syncMaterialToBackend(material)
            } catch {
                importErrorMessage = "File was saved locally but backend sync failed, so AI may not use it yet."
            }
        } catch {
            importErrorMessage = "File import failed. Please try a different document."
        }
    }

    func toggleMaterialSelectionForAI(_ materialID: UUID) {
        guard let index = materials.firstIndex(where: { $0.id == materialID }) else { return }
        materials[index].isSelectedForAIContext.toggle()
        do {
            try persistMaterials()
            rebuildAIContentSnapshots()
        } catch {
            importErrorMessage = "Could not update AI source selection."
        }
    }

    func openPreview(for material: StudyMaterial) {
        selectedMaterialForPreview = material
    }

    func renameMaterial(_ material: StudyMaterial, to newTitle: String) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        guard let index = materials.firstIndex(where: { $0.id == material.id }) else { return }

        var updated = materials[index]
        let ext = URL(fileURLWithPath: material.storedPath).pathExtension
        updated = StudyMaterial(
            id: updated.id,
            workspaceID: updated.workspaceID,
            title: String(trimmed.prefix(80)),
            type: updated.type,
            storedPath: updated.storedPath,
            createdAt: updated.createdAt,
            previewText: updated.previewText,
            thumbnailPath: updated.thumbnailPath,
            isUsableForAIContext: updated.isUsableForAIContext,
            isSelectedForAIContext: updated.isSelectedForAIContext,
            fileSizeInBytes: updated.fileSizeInBytes
        )

        if !ext.isEmpty {
            let currentURL = URL(fileURLWithPath: material.storedPath)
            let newFileName = "\(String(trimmed.prefix(80))).\(ext)"
            let destinationURL = currentURL.deletingLastPathComponent().appendingPathComponent(newFileName)

            if destinationURL.path != currentURL.path {
                do {
                    try FileManager.default.moveItem(at: currentURL, to: destinationURL)
                    updated = StudyMaterial(
                        id: updated.id,
                        workspaceID: updated.workspaceID,
                        title: updated.title,
                        type: updated.type,
                        storedPath: destinationURL.path,
                        createdAt: updated.createdAt,
                        previewText: updated.previewText,
                        thumbnailPath: updated.thumbnailPath,
                        isUsableForAIContext: updated.isUsableForAIContext,
                        isSelectedForAIContext: updated.isSelectedForAIContext,
                        fileSizeInBytes: updated.fileSizeInBytes
                    )
                } catch {
                    importErrorMessage = "Could not rename material file."
                    return
                }
            }
        }

        materials[index] = updated
        do {
            try persistMaterials()
            rebuildAIContentSnapshots()
            refreshAIReadableContent()
        } catch {
            importErrorMessage = "Could not save material rename."
        }
    }

    func registerGeneratedSummaryOutput() {
        store.incrementAIOutputCount(for: workspace.id)
        loadSummaryHistory()
    }

    func summaryActivityRecords(limit: Int = 3) -> [WorkspaceActivityRecord] {
        summaryVersions
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(limit)
            .map { version in
                WorkspaceActivityRecord(
                    id: version.id,
                    kind: .summary,
                    iconName: "sparkles",
                    title: version.name,
                    detail: "AI summary generated from selected sources.",
                    occurredAt: version.createdAt
                )
            }
    }

    func latestSummaryVersions(limit: Int = 3) -> [SummaryVersion] {
        Array(summaryVersions.sorted { $0.createdAt > $1.createdAt }.prefix(limit))
    }

    func refreshSummaryHistory() {
        loadSummaryHistory()
    }

    func deleteMaterial(_ material: StudyMaterial) {
        guard let index = materials.firstIndex(where: { $0.id == material.id }) else { return }
        materials.remove(at: index)
        materialContentCache.removeValue(forKey: material.id)
        rebuildAIContentSnapshots()

        do {
            if FileManager.default.fileExists(atPath: material.storedPath) {
                try FileManager.default.removeItem(atPath: material.storedPath)
            }
            try persistMaterials()
        } catch {
            importErrorMessage = "Could not delete material."
        }
    }

    private func persistMaterials() throws {
        try storageService.saveMaterials(materials, workspaceID: workspaceID)
    }

    private nonisolated static func buildReadableContentSnapshot(
        materials: [StudyMaterial],
        storageService: WorkspaceMaterialStorageService
    ) -> [UUID: String] {
        materials.reduce(into: [UUID: String]()) { result, material in
            let extracted = storageService.extractSummaryContent(for: material)?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let fallback = material.previewText?
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let content = [extracted, fallback]
                .compactMap { $0 }
                .first { !$0.isEmpty } ?? ""
            result[material.id] = content
        }
    }

    private nonisolated static func persistPhotoMaterial(
        data: Data,
        workspaceID: UUID,
        suggestedFileName: String?,
        using storageService: WorkspaceMaterialStorageService
    ) throws -> StudyMaterial {
        try storageService.persistPhotoData(
            data,
            workspaceID: workspaceID,
            suggestedFileName: suggestedFileName
        )
    }

    private nonisolated static func persistDocumentMaterial(
        at sourceURL: URL,
        workspaceID: UUID,
        using storageService: WorkspaceMaterialStorageService
    ) throws -> StudyMaterial {
        try storageService.persistDocument(at: sourceURL, workspaceID: workspaceID)
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

    private func buildWorkspaceSummaryContent(selectedSourceIDs: Set<UUID>? = nil) -> String? {
        let selected = selectedSourceIDs ?? Set(summarySourceItems().map(\.id))
        let chosenSources = summarySourceItems().filter { selected.contains($0.id) }

        guard !chosenSources.isEmpty else { return nil }

        let chunks = chosenSources.compactMap { source -> String? in
            let body = source.content.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !body.isEmpty else { return nil }
            return "[\(source.kind.rawValue.capitalized)] \(source.name)\n\(body)"
        }

        guard !chunks.isEmpty else { return nil }

        return """
        Workspace: \(workspace.title)

        Selected sources:

        \(chunks.joined(separator: "\n\n"))
        """
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractNoteTextForSummary(_ note: WorkspaceNote) -> String {
        if !note.blocks.isEmpty {
            let extracted = note.blocks.compactMap { block -> String? in
                switch block.kind {
                case .text:
                    let text = block.attributedText().string.trimmingCharacters(in: .whitespacesAndNewlines)
                    return text.isEmpty ? nil : text
                case .checklist:
                    let checklistText = block.checklist?.items
                        .map { item in
                            let prefix = item.isChecked ? "[x]" : "[ ]"
                            return "\(prefix) \(item.text)"
                        }
                        .joined(separator: "\n")
                        .trimmingCharacters(in: .whitespacesAndNewlines)
                    guard let checklistText, !checklistText.isEmpty else { return nil }
                    return checklistText
                case .image, .table:
                    return nil
                }
            }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)

            if !extracted.isEmpty {
                return extracted
            }
        }

        return note.content
    }

    private func loadSummaryHistory() {
        do {
            let snapshot = try summaryHistoryStorageService.loadHistory(workspaceID: workspaceID)
            summaryVersions = snapshot.versions
        } catch {
            summaryVersions = []
        }
    }

    private func syncMaterialToBackend(_ material: StudyMaterial) async throws {
        let fileURL = URL(fileURLWithPath: material.storedPath)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        // Some backend versions return 500 when no files exist yet.
        // Fall back to an empty list and proceed with upload.
        let existing = (try? await apiService.fetchStudySpaceFiles(
            studySpaceId: workspaceID.uuidString,
            fallbackWorkspaceTitle: workspace.title
        )) ?? []
        let alreadySynced = existing.contains {
            $0.file.name.caseInsensitiveCompare(fileURL.lastPathComponent) == .orderedSame
        }
        if alreadySynced {
            return
        }
        _ = try await apiService.uploadStudySpaceFile(
            fileURL: fileURL,
            studySpaceId: workspaceID.uuidString,
            fallbackWorkspaceTitle: workspace.title
        )
    }

    private func syncAllMaterialsToBackendBestEffort() async {
        for material in materials {
            do {
                try await syncMaterialToBackend(material)
            } catch {
                continue
            }
        }
    }

}
