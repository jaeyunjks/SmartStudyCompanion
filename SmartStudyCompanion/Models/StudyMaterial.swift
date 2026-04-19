import Foundation

enum StudyMaterialType: String, Codable, CaseIterable {
    case image
    case pdf
    case document
    case text
    case other

    var displayName: String {
        rawValue.capitalized
    }

    var systemIconName: String {
        switch self {
        case .image: return "photo"
        case .pdf: return "doc.richtext"
        case .document: return "doc.text"
        case .text: return "text.alignleft"
        case .other: return "doc"
        }
    }
}

struct StudyMaterial: Identifiable, Codable, Equatable {
    let id: UUID
    let workspaceID: UUID
    let title: String
    let type: StudyMaterialType
    let storedPath: String
    let createdAt: Date
    let previewText: String?
    let thumbnailPath: String?
    var isUsableForAIContext: Bool
    var isSelectedForAIContext: Bool
    let fileSizeInBytes: Int64

    init(
        id: UUID = UUID(),
        workspaceID: UUID,
        title: String,
        type: StudyMaterialType,
        storedPath: String,
        createdAt: Date = Date(),
        previewText: String? = nil,
        thumbnailPath: String? = nil,
        isUsableForAIContext: Bool = true,
        isSelectedForAIContext: Bool = true,
        fileSizeInBytes: Int64 = 0
    ) {
        self.id = id
        self.workspaceID = workspaceID
        self.title = title
        self.type = type
        self.storedPath = storedPath
        self.createdAt = createdAt
        self.previewText = previewText
        self.thumbnailPath = thumbnailPath
        self.isUsableForAIContext = isUsableForAIContext
        self.isSelectedForAIContext = isSelectedForAIContext
        self.fileSizeInBytes = fileSizeInBytes
    }

    var localURL: URL {
        URL(fileURLWithPath: storedPath)
    }
}

struct ReferencedMaterial: Identifiable, Codable, Equatable {
    let id: UUID
    let materialID: UUID
    let title: String
    let type: StudyMaterialType
    let localPath: String
    var isSelected: Bool

    init(id: UUID = UUID(), materialID: UUID, title: String, type: StudyMaterialType, localPath: String, isSelected: Bool) {
        self.id = id
        self.materialID = materialID
        self.title = title
        self.type = type
        self.localPath = localPath
        self.isSelected = isSelected
    }
}

struct AIContextSource: Identifiable, Codable, Equatable {
    let id: UUID
    let workspaceID: UUID
    let workspaceTitle: String
    let materials: [ReferencedMaterial]

    init(id: UUID = UUID(), workspaceID: UUID, workspaceTitle: String, materials: [ReferencedMaterial]) {
        self.id = id
        self.workspaceID = workspaceID
        self.workspaceTitle = workspaceTitle
        self.materials = materials
    }
}
