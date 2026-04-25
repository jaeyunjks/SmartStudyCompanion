import Foundation

final class WorkspaceNoteStorageService {
    static let shared = WorkspaceNoteStorageService()

    private let fileManager = FileManager.default

    private init() {}

    func loadNotes(workspaceID: UUID) throws -> [WorkspaceNote] {
        let url = try notesFileURL(workspaceID: workspaceID)
        guard fileManager.fileExists(atPath: url.path) else { return [] }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([WorkspaceNote].self, from: data)
    }

    func saveNotes(_ notes: [WorkspaceNote], workspaceID: UUID) throws {
        let url = try notesFileURL(workspaceID: workspaceID)
        let data = try JSONEncoder().encode(notes)
        try data.write(to: url, options: .atomic)
    }

    func persistNoteImage(data: Data, workspaceID: UUID, noteID: UUID) throws -> String {
        let baseFolder = try noteImagesFolderURL(workspaceID: workspaceID, noteID: noteID)
        if !fileManager.fileExists(atPath: baseFolder.path) {
            try fileManager.createDirectory(at: baseFolder, withIntermediateDirectories: true)
        }

        let fileURL = baseFolder.appendingPathComponent("\(UUID().uuidString).jpg")
        try data.write(to: fileURL, options: .atomic)
        return fileURL.path
    }

    private func notesFileURL(workspaceID: UUID) throws -> URL {
        let documents = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let root = documents.appendingPathComponent("WorkspaceMaterials", isDirectory: true)
        let workspaceFolder = root.appendingPathComponent(workspaceID.uuidString, isDirectory: true)

        if !fileManager.fileExists(atPath: workspaceFolder.path) {
            try fileManager.createDirectory(at: workspaceFolder, withIntermediateDirectories: true)
        }

        return workspaceFolder.appendingPathComponent("notes.json")
    }

    private func noteImagesFolderURL(workspaceID: UUID, noteID: UUID) throws -> URL {
        let documents = try fileManager.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        return documents
            .appendingPathComponent("WorkspaceMaterials", isDirectory: true)
            .appendingPathComponent(workspaceID.uuidString, isDirectory: true)
            .appendingPathComponent("NoteImages", isDirectory: true)
            .appendingPathComponent(noteID.uuidString, isDirectory: true)
    }
}
