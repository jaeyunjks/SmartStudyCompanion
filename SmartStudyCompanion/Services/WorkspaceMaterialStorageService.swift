import Foundation
import ImageIO
import PDFKit
import Vision

final class WorkspaceMaterialStorageService: @unchecked Sendable {
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
        let extractedText = readImageText(at: fileURL)?.trimmingCharacters(in: .whitespacesAndNewlines)
        let previewText = extractedText.flatMap { $0.isEmpty ? nil : String($0.prefix(1200)) }

        return StudyMaterial(
            workspaceID: workspaceID,
            title: titleFromFileName(fileName),
            type: .image,
            storedPath: fileURL.path,
            previewText: previewText,
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

    func extractSummaryContent(for material: StudyMaterial) -> String? {
        let url = URL(fileURLWithPath: material.storedPath)
        let raw: String?

        switch material.type {
        case .text, .document, .other:
            raw = try? readTextDocument(at: url)
        case .pdf:
            raw = readPDFText(at: url)
        case .image:
            raw = readImageText(at: url)
        }

        guard let raw, !raw.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        let cleaned = sanitizeExtractedText(raw)
        if material.type == .image {
            return cleaned.isEmpty ? nil : cleaned
        }

        guard !isLowQualityExtraction(cleaned) else { return nil }
        return cleaned
    }

    private func sanitizeExtractedText(_ text: String) -> String {
        text
            .replacingOccurrences(of: "\u{00a0}", with: " ")
            .replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\b[a-zA-Z0-9_\\-./]+\\.xml\\b", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\b(_rels|word|docProps|styles|webSettings|numbering|theme)\\b", with: " ", options: .regularExpression)
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func isLowQualityExtraction(_ text: String) -> Bool {
        let lowered = text.lowercased()
        let manifestSignals = [
            "document.xml", "styles.xml", "websettings.xml", "numbering.xml",
            "[content_types].xml", "_rels", "docprops", "word/"
        ]
        let signalCount = manifestSignals.reduce(0) { partial, signal in
            partial + (lowered.contains(signal) ? 1 : 0)
        }

        let words = lowered
            .split(whereSeparator: { !$0.isLetter && !$0.isNumber })
            .map(String.init)
            .filter { $0.count > 2 }
        let uniqueWords = Set(words)

        if signalCount >= 2 { return true }
        if words.count < 20 { return true }
        if uniqueWords.count < 12 { return true }
        return false
    }

    private func readTextDocument(at url: URL) throws -> String? {
        let ext = url.pathExtension.lowercased()

        if ext == "txt" || ext == "md" {
            return try String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if ext == "rtf" {
            if let richText = extractRichText(from: url), !richText.isEmpty {
                return richText
            }
            return try? String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        if ext == "docx" || ext == "doc" || ext == "pages" {
            if let richTextFromURL = extractRichTextFromURL(url), !richTextFromURL.isEmpty {
                return richTextFromURL
            }
            if let richText = extractRichText(from: url), !richText.isEmpty {
                return richText
            }
        }

        return try? String(contentsOf: url, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func extractRichText(from url: URL) -> String? {
        guard let data = try? Data(contentsOf: url), !data.isEmpty else { return nil }

        let optionSets: [[NSAttributedString.DocumentReadingOptionKey: Any]] = [
            [:], // auto-detect first
            [.documentType: NSAttributedString.DocumentType.rtf],
            [.documentType: NSAttributedString.DocumentType.rtfd],
            [.documentType: NSAttributedString.DocumentType.html],
            [.documentType: NSAttributedString.DocumentType.plain]
        ]

        for var options in optionSets {
            options[.characterEncoding] = String.Encoding.utf8.rawValue

            if let attributed = try? NSAttributedString(
                data: data,
                options: options,
                documentAttributes: nil
            ) {
                let text = attributed.string
                    .replacingOccurrences(of: "\u{00a0}", with: " ")
                    .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if text.count > 40 {
                    return text
                }
            }
        }

        return nil
    }

    private func extractRichTextFromURL(_ url: URL) -> String? {
        let optionSets: [[NSAttributedString.DocumentReadingOptionKey: Any]] = [
            [:], // auto-detect first
            [.documentType: NSAttributedString.DocumentType.rtf],
            [.documentType: NSAttributedString.DocumentType.rtfd],
            [.documentType: NSAttributedString.DocumentType.html],
            [.documentType: NSAttributedString.DocumentType.plain]
        ]

        for options in optionSets {
            if let attributed = try? NSAttributedString(
                url: url,
                options: options,
                documentAttributes: nil
            ) {
                let text = attributed.string
                    .replacingOccurrences(of: "\u{00a0}", with: " ")
                    .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if text.count > 80 {
                    return text
                }
            }
        }

        return nil
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
        request.minimumTextHeight = 0.01
        request.recognitionLanguages = ["en-US", "en-GB"]

        let handler = VNImageRequestHandler(
            cgImage: cgImage,
            orientation: imageOrientation(from: cgImageSource),
            options: [:]
        )
        do {
            try handler.perform([request])
            let observations = request.results ?? []
            let text = observations
                .sorted(by: readingOrder)
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        } catch {
            return nil
        }
    }

    private func readingOrder(_ lhs: VNRecognizedTextObservation, _ rhs: VNRecognizedTextObservation) -> Bool {
        let verticalDifference = abs(lhs.boundingBox.midY - rhs.boundingBox.midY)
        if verticalDifference > 0.02 {
            return lhs.boundingBox.midY > rhs.boundingBox.midY
        }
        return lhs.boundingBox.minX < rhs.boundingBox.minX
    }

    private func imageOrientation(from source: CGImageSource) -> CGImagePropertyOrientation {
        guard let properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any],
              let rawValue = properties[kCGImagePropertyOrientation] else {
            return .up
        }

        if let number = rawValue as? NSNumber {
            return CGImagePropertyOrientation(rawValue: number.uint32Value) ?? .up
        }

        if let raw = rawValue as? UInt32 {
            return CGImagePropertyOrientation(rawValue: raw) ?? .up
        }

        return .up
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
