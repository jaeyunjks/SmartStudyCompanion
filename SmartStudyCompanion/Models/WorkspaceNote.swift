import Foundation

enum WorkspaceNoteTextAlignment: String, Codable, CaseIterable {
    case left
    case center
    case right
}

struct WorkspaceNote: Identifiable, Codable, Hashable {
    let id: UUID
    let workspaceID: UUID
    var title: String
    var content: String
    var isBoldEnabled: Bool
    var textSize: Double
    var textAlignment: WorkspaceNoteTextAlignment
    var bulletListEnabled: Bool
    var numberedListEnabled: Bool
    var imagePaths: [String]
    let createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        workspaceID: UUID,
        title: String = "Untitled Note",
        content: String = "",
        isBoldEnabled: Bool = false,
        textSize: Double = 18,
        textAlignment: WorkspaceNoteTextAlignment = .left,
        bulletListEnabled: Bool = false,
        numberedListEnabled: Bool = false,
        imagePaths: [String] = [],
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.workspaceID = workspaceID
        self.title = title
        self.content = content
        self.isBoldEnabled = isBoldEnabled
        self.textSize = textSize
        self.textAlignment = textAlignment
        self.bulletListEnabled = bulletListEnabled
        self.numberedListEnabled = numberedListEnabled
        self.imagePaths = imagePaths
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case workspaceID
        case title
        case content
        case isBoldEnabled
        case textSize
        case textAlignment
        case bulletListEnabled
        case numberedListEnabled
        case imagePaths
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        workspaceID = try container.decode(UUID.self, forKey: .workspaceID)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? "Untitled Note"
        content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        isBoldEnabled = try container.decodeIfPresent(Bool.self, forKey: .isBoldEnabled) ?? false
        textSize = try container.decodeIfPresent(Double.self, forKey: .textSize) ?? 18
        textAlignment = try container.decodeIfPresent(WorkspaceNoteTextAlignment.self, forKey: .textAlignment) ?? .left
        bulletListEnabled = try container.decodeIfPresent(Bool.self, forKey: .bulletListEnabled) ?? false
        numberedListEnabled = try container.decodeIfPresent(Bool.self, forKey: .numberedListEnabled) ?? false
        imagePaths = try container.decodeIfPresent([String].self, forKey: .imagePaths) ?? []
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? createdAt
    }
}

extension WorkspaceNote {
    var displayTitle: String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Untitled Note" : trimmed
    }

    var createdDisplayText: String {
        let seconds = Int(Date().timeIntervalSince(createdAt))
        if seconds < 60 {
            return "Created just now"
        }
        if seconds < 3600 {
            return "Created \(seconds / 60) min ago"
        }
        if seconds < 86_400 {
            return "Created \(seconds / 3600) hours ago"
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return "Created \(formatter.string(from: createdAt))"
    }
}
