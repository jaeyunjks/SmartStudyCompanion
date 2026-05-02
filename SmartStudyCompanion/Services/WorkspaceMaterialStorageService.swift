import Foundation
import PDFKit
import Vision

final class WorkspaceMaterialStorageService {
    static let shared = WorkspaceMaterialStorageService()

    private let fileManager = FileManager.default

    private init() {}

    func loadMaterials(workspaceID: UUID) throws -> [StudyMaterial] {
        let metadataURL = try metadataFileURL(workspaceID: workspaceID)
        guard fileManager.fileExists(atPath: metadataURL.path) else { return [] }

        let data = try Data(contentsOf: metadataURL)
        let decoded = try JSONDecoder().decode([StudyMaterial].self, from: data)
        let normalized = try normalizeLoadedMaterials(decoded, workspaceID: workspaceID)

        if normalized != decoded {
            try saveMaterials(normalized, workspaceID: workspaceID)
        }

        return normalized
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
        switch type {
        case .text:
            if let text = try readTextDocument(at: url), !text.isEmpty {
                return String(text.prefix(1200))
            }
            return nil
        case .pdf:
            if let text = readPDFText(at: url), !text.isEmpty {
                return String(text.prefix(1200))
            }
            return nil
        case .image:
            if let text = readImageText(at: url), !text.isEmpty {
                return String(text.prefix(1200))
            }
            return nil
        case .document, .other:
            if let text = try readTextDocument(at: url), !text.isEmpty {
                return String(text.prefix(1200))
            }
            return nil
        }
    }

    private func readTextDocument(at url: URL) throws -> String? {
        let ext = url.pathExtension.lowercased()

        if ext == "txt" || ext == "md" || ext == "rtf" {
            return try String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if ext == "docx" {
            // Native docx parsing is not available in this lightweight local flow.
            return nil
        }

        if ext == "doc" || ext == "pages" {
            return nil
        }

        return try? String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func readPDFText(at url: URL) -> String? {
        guard let doc = PDFDocument(url: url) else { return nil }
        let pages = (0..<doc.pageCount).compactMap { doc.page(at: $0)?.string?.trimmingCharacters(in: .whitespacesAndNewlines) }
        return pages.joined(separator: "\n\n")
    }

    private func readImageText(at url: URL) -> String? {
        guard let imageData = try? Data(contentsOf: url),
              let cgImageSource = CGImageSourceCreateWithData(imageData as CFData, nil),
              let cgImage = CGImageSourceCreateImageAtIndex(cgImageSource, 0, nil) else { return nil }

        let request = VNRecognizeTextRequest()
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
            let observations = request.results ?? []
            let text = observations.compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n")
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }

    private func normalizeLoadedMaterials(_ materials: [StudyMaterial], workspaceID: UUID) throws -> [StudyMaterial] {
        let workspaceFolder = try materialsDirectoryURL(workspaceID: workspaceID)
        let metadataPath = workspaceFolder.appendingPathComponent("materials.json").path

        return materials.map { material in
            guard !fileManager.fileExists(atPath: material.storedPath) else { return material }

            let originalURL = URL(fileURLWithPath: material.storedPath)
            let fallbackURL = workspaceFolder.appendingPathComponent(originalURL.lastPathComponent)

            guard fallbackURL.path != metadataPath,
                  fileManager.fileExists(atPath: fallbackURL.path)
            else {
                return material
            }

            return StudyMaterial(
                id: material.id,
                workspaceID: material.workspaceID,
                title: material.title,
                type: material.type,
                storedPath: fallbackURL.path,
                createdAt: material.createdAt,
                previewText: material.previewText,
                thumbnailPath: material.thumbnailPath,
                isUsableForAIContext: material.isUsableForAIContext,
                isSelectedForAIContext: material.isSelectedForAIContext,
                fileSizeInBytes: material.fileSizeInBytes
            )
        }
    }
}
