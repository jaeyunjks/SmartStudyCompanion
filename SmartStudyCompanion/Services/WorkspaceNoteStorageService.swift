import Foundation
import UIKit
import ImageIO

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
        let optimized = try optimizedJPEGData(from: data, maxPixelSize: 1200, quality: 0.75)
        try optimized.write(to: fileURL, options: .atomic)
        return fileURL.path
    }

    func deleteNoteImageIfExists(path: String) {
        guard fileManager.fileExists(atPath: path) else { return }
        try? fileManager.removeItem(atPath: path)
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

    private func optimizedJPEGData(from data: Data, maxPixelSize: CGFloat, quality: CGFloat) throws -> Data {
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCache: false,
            kCGImageSourceThumbnailMaxPixelSize: Int(maxPixelSize)
        ]

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, options as CFDictionary) else {
            throw CocoaError(.fileReadCorruptFile)
        }

        let image = UIImage(cgImage: cgImage)
        guard let jpeg = image.jpegData(compressionQuality: quality) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return jpeg
    }
}
