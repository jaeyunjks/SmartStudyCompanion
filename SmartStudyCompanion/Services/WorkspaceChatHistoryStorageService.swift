import Foundation

struct WorkspaceChatHistorySnapshot: Codable {
    let conversations: [ChatConversation]
    let activeConversationID: UUID?
}

final class WorkspaceChatHistoryStorageService {
    static let shared = WorkspaceChatHistoryStorageService()

    private let fileManager = FileManager.default

    private init() {}

    func loadHistory(workspaceID: UUID) throws -> WorkspaceChatHistorySnapshot {
        let url = try historyFileURL(workspaceID: workspaceID)
        guard fileManager.fileExists(atPath: url.path) else {
            return WorkspaceChatHistorySnapshot(conversations: [], activeConversationID: nil)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(WorkspaceChatHistorySnapshot.self, from: data)
    }

    func saveHistory(_ snapshot: WorkspaceChatHistorySnapshot, workspaceID: UUID) throws {
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

        return workspaceFolder.appendingPathComponent("chat_history.json")
    }
}
