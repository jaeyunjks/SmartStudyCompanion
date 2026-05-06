import Foundation

struct WorkspaceSummaryHistorySnapshot: Codable {
    var versions: [SummaryVersion]
    var selectedVersionID: UUID?
}

final class WorkspaceSummaryHistoryStorageService {
    static let shared = WorkspaceSummaryHistoryStorageService()

    private let fileManager = FileManager.default

    private init() {}

    func loadHistory(workspaceID: UUID) throws -> WorkspaceSummaryHistorySnapshot {
        let url = try historyFileURL(workspaceID: workspaceID)
        guard fileManager.fileExists(atPath: url.path) else {
            return WorkspaceSummaryHistorySnapshot(versions: [], selectedVersionID: nil)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(WorkspaceSummaryHistorySnapshot.self, from: data)
    }

    func saveHistory(_ snapshot: WorkspaceSummaryHistorySnapshot, workspaceID: UUID) throws {
        let url = try historyFileURL(workspaceID: workspaceID)
        let data = try JSONEncoder().encode(snapshot)
        try data.write(to: url, options: .atomic)
    }

    private func historyFileURL(workspaceID: UUID) throws -> URL {
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

        return workspaceFolder.appendingPathComponent("summary_history.json")
    }
}
