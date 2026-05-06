import Foundation
import UIKit

enum WorkspaceNoteTextAlignment: String, Codable, CaseIterable {
    case left
    case center
    case right
}

enum WorkspaceNoteBlockKind: String, Codable, CaseIterable {
    case text
    case image
    case table
    case checklist
}

enum WorkspaceImageDisplaySize: String, Codable, CaseIterable {
    case small
    case medium
    case full
}

struct WorkspaceTableBlock: Codable, Hashable {
    var rows: Int
    var columns: Int
    var cells: [[String]]

    init(rows: Int, columns: Int) {
        self.rows = max(1, rows)
        self.columns = max(1, columns)
        self.cells = Array(
            repeating: Array(repeating: "", count: self.columns),
            count: self.rows
        )
    }
}

struct WorkspaceChecklistItem: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var isChecked: Bool

    init(id: UUID = UUID(), text: String = "", isChecked: Bool = false) {
        self.id = id
        self.text = text
        self.isChecked = isChecked
    }
}

struct WorkspaceChecklistBlock: Codable, Hashable {
    var items: [WorkspaceChecklistItem]

    init(items: [WorkspaceChecklistItem] = [WorkspaceChecklistItem(text: "")]) {
        self.items = items
    }
}

struct WorkspaceNoteBlock: Identifiable, Codable, Hashable {
    let id: UUID
    var kind: WorkspaceNoteBlockKind
    var textDataBase64: String?
    var imagePath: String?
    var imageDisplaySize: WorkspaceImageDisplaySize?
    var table: WorkspaceTableBlock?
    var checklist: WorkspaceChecklistBlock?

    init(
        id: UUID = UUID(),
        kind: WorkspaceNoteBlockKind,
        textDataBase64: String? = nil,
        imagePath: String? = nil,
        imageDisplaySize: WorkspaceImageDisplaySize? = nil,
        table: WorkspaceTableBlock? = nil,
        checklist: WorkspaceChecklistBlock? = nil
    ) {
        self.id = id
        self.kind = kind
        self.textDataBase64 = textDataBase64
        self.imagePath = imagePath
        self.imageDisplaySize = imageDisplaySize
        self.table = table
        self.checklist = checklist
    }

    static func text(_ plain: String = "") -> WorkspaceNoteBlock {
        var block = WorkspaceNoteBlock(kind: .text)
        block.storeAttributedText(NSAttributedString(string: plain))
        return block
    }

    static func image(path: String) -> WorkspaceNoteBlock {
        WorkspaceNoteBlock(kind: .image, imagePath: path, imageDisplaySize: .medium)
    }

    static func table(rows: Int, columns: Int) -> WorkspaceNoteBlock {
        WorkspaceNoteBlock(kind: .table, table: WorkspaceTableBlock(rows: rows, columns: columns))
    }

    static func checklist() -> WorkspaceNoteBlock {
        WorkspaceNoteBlock(kind: .checklist, checklist: WorkspaceChecklistBlock())
    }

    func attributedText() -> NSAttributedString {
        guard let textDataBase64,
              let data = Data(base64Encoded: textDataBase64),
              let attributed = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: data) else {
            return NSAttributedString(string: "")
        }
        return attributed
    }

    mutating func storeAttributedText(_ text: NSAttributedString) {
        let archived = try? NSKeyedArchiver.archivedData(withRootObject: text, requiringSecureCoding: true)
        textDataBase64 = archived?.base64EncodedString()
    }

    var plainTextSummary: String {
        switch kind {
        case .text:
            return attributedText().string
        case .image:
            return "[Image]"
        case .table:
            return "[Table]"
        case .checklist:
            return checklist?.items.map { ($0.isChecked ? "[x] " : "[ ] ") + $0.text }.joined(separator: "\n") ?? "[Checklist]"
        }
    }
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
    var blocks: [WorkspaceNoteBlock]
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
        blocks: [WorkspaceNoteBlock] = [WorkspaceNoteBlock.text()],
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
        self.blocks = blocks.isEmpty ? [WorkspaceNoteBlock.text(content)] : blocks
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
        case blocks
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
        let decodedBlocks = try container.decodeIfPresent([WorkspaceNoteBlock].self, forKey: .blocks) ?? []
        blocks = decodedBlocks.isEmpty ? [WorkspaceNoteBlock.text(content)] : decodedBlocks
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
