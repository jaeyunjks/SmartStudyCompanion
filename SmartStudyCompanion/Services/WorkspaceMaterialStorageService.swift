import Foundation

final class WorkspaceMaterialStorageService {
    static let shared = WorkspaceMaterialStorageService()

    private let fileManager = FileManager.default

    private init() {}

    func loadMaterials(workspaceID: UUID) throws -> [StudyMaterial] {
        let metadataURL = try metadataFileURL(workspaceID: workspaceID)
        guard fileManager.fileExists(atPath: metadataURL.path) else { return [] }

        let data = try Data(contentsOf: metadataURL)
        return try JSONDecoder().decode([StudyMaterial].self, from: data)
    }

    func saveMaterials(_ materials: [StudyMaterial], workspaceID: UUID) throws {
        let metadataURL = try metadataFileURL(workspaceID: workspaceID)
        let data = try JSONEncoder().encode(materials)
        try data.write(to: metadataURL, options: .atomic)
    }

    func persistPhotoData(_ data: Data, workspaceID: UUID, suggestedFileName: String?) throws -> StudyMaterial {
        let directory = try materialsDirectoryURL(workspaceID: workspaceID)
        let fileName = sanitizedFileName(suggestedFileName ?? "photo_\(Int(Date().timeIntervalSince1970)).jpg")
        let fileURL = directory.appendingPathComponent(fileName)
        try data.write(to: fileURL, options: .atomic)

        return StudyMaterial(
            workspaceID: workspaceID,
            title: titleFromFileName(fileName),
            type: .image,
            storedPath: fileURL.path,
            previewText: nil,
            fileSizeInBytes: Int64(data.count)
        )
    }

    func persistDocument(at sourceURL: URL, workspaceID: UUID) throws -> StudyMaterial {
        let directory = try materialsDirectoryURL(workspaceID: workspaceID)
        let targetName = sanitizedFileName(sourceURL.lastPathComponent)
        let targetURL = directory.appendingPathComponent(targetName)

        if fileManager.fileExists(atPath: targetURL.path) {
            try fileManager.removeItem(at: targetURL)
        }

        try fileManager.copyItem(at: sourceURL, to: targetURL)

        let attributes = try fileManager.attributesOfItem(atPath: targetURL.path)
        let size = (attributes[.size] as? NSNumber)?.int64Value ?? 0
        let materialType = materialTypeForFileExtension(targetURL.pathExtension)
        let previewText = try previewTextIfAvailable(for: targetURL, type: materialType)

        return StudyMaterial(
            workspaceID: workspaceID,
            title: titleFromFileName(targetName),
            type: materialType,
            storedPath: targetURL.path,
            previewText: previewText,
            fileSizeInBytes: size
        )
    }

    private func materialsDirectoryURL(workspaceID: UUID) throws -> URL {
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

        return workspaceFolder
    }

    private func metadataFileURL(workspaceID: UUID) throws -> URL {
        try materialsDirectoryURL(workspaceID: workspaceID).appendingPathComponent("materials.json")
    }

    private func materialTypeForFileExtension(_ ext: String) -> StudyMaterialType {
        switch ext.lowercased() {
        case "pdf": return .pdf
        case "txt", "md", "rtf": return .text
        case "doc", "docx", "pages": return .document
        case "png", "jpg", "jpeg", "heic", "gif": return .image
        default: return .other
        }
    }

    private func titleFromFileName(_ fileName: String) -> String {
        URL(fileURLWithPath: fileName).deletingPathExtension().lastPathComponent
    }

    private func sanitizedFileName(_ input: String) -> String {
        let cleaned = input.replacingOccurrences(of: "/", with: "_")
        return cleaned.isEmpty ? UUID().uuidString : cleaned
    }

    private func previewTextIfAvailable(for url: URL, type: StudyMaterialType) throws -> String? {
        guard type == .text else { return nil }
        let content = try String(contentsOf: url, encoding: .utf8)
        return String(content.prefix(240))
    }
}
