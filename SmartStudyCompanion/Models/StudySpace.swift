import Foundation
import SwiftUI

struct StudySpace: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let category: String
    let status: StudySpaceStatus
    let workspaceColorHex: String
    let documentCount: Int
    let noteCount: Int
    let lastUpdated: String
    let lastOpened: String
    let aiOutputCount: Int
    let progress: Double
}

struct RemoteStudySpace: Codable {
    let id: String
    let userId: String
    let title: String
    let description: String?
    let iconName: String?
    let category: String?
    let status: String?
    let workspaceColorHex: String?
    let color: String?
    let tag: String?
    let documentCount: Int?
    let noteCount: Int?
    let aiOutputCount: Int?
    let progress: Double?
    let createdAt: Date?
    let updatedAt: Date?
    let summaries: [RemoteStudySpaceSummary]?
}

struct RemoteStudySpaceSummary: Codable {
    let id: String?
}

struct CreateWorkspaceRequest: Codable {
    let title: String
    let description: String
    let iconName: String
    let category: String
    let status: StudySpaceStatus
    let workspaceColorHex: String
    let documentCount: Int
    let noteCount: Int
    let aiOutputCount: Int
    let progress: Double
}

struct UpdateWorkspaceRequest: Codable {
    let title: String
    let description: String
    let iconName: String
    let category: String
    let status: StudySpaceStatus
    let workspaceColorHex: String
    let documentCount: Int
    let noteCount: Int
    let aiOutputCount: Int
    let progress: Double
}

extension StudySpace {
    static let sampleData: [StudySpace] = [
        .init(
            id: UUID(),
            title: "41001 Cloud Computing",
            description: "Infrastructure as service, virtualization techniques, and distributed systems architecture.",
            iconName: "cloud",
            category: "IT",
            status: .active,
            workspaceColorHex: "#388767",
            documentCount: 3,
            noteCount: 2,
            lastUpdated: "Last updated 2h ago",
            lastOpened: "Opened just now",
            aiOutputCount: 4,
            progress: 0.74
        ),
        .init(
            id: UUID(),
            title: "Cognitive Neuroscience",
            description: "Exploring neural mechanisms of thought, memory, and spatial navigation.",
            iconName: "brain.head.profile",
            category: "Science",
            status: .inactive,
            workspaceColorHex: "#4B85E5",
            documentCount: 12,
            noteCount: 8,
            lastUpdated: "Last updated 5h ago",
            lastOpened: "Opened yesterday",
            aiOutputCount: 7,
            progress: 0.42
        ),
        .init(
            id: UUID(),
            title: "Advanced AI Ethics",
            description: "Algorithmic bias, regulatory frameworks, and future safety.",
            iconName: "sparkles",
            category: "AI",
            status: .active,
            workspaceColorHex: "#8E68D8",
            documentCount: 5,
            noteCount: 6,
            lastUpdated: "Last updated yesterday",
            lastOpened: "Opened 2d ago",
            aiOutputCount: 3,
            progress: 0.55
        ),
        .init(
            id: UUID(),
            title: "Data Structures & Algo",
            description: "B-Trees, graph theory, and complexity analysis for final prep.",
            iconName: "tray.full",
            category: "IT",
            status: .active,
            workspaceColorHex: "#E58A39",
            documentCount: 5,
            noteCount: 14,
            lastUpdated: "Last updated yesterday",
            lastOpened: "Opened 3h ago",
            aiOutputCount: 9,
            progress: 0.63
        ),
        .init(
            id: UUID(),
            title: "Modern Ethics 101",
            description: "Readings on utilitarianism, deontology, and virtual ethics frameworks.",
            iconName: "book.closed",
            category: "Humanities",
            status: .inactive,
            workspaceColorHex: "#D7669D",
            documentCount: 2,
            noteCount: 1,
            lastUpdated: "Completed Oct 24",
            lastOpened: "Opened 1w ago",
            aiOutputCount: 2,
            progress: 1.0
        )
    ]
}

extension StudySpace {
    static func fromRemote(_ remote: RemoteStudySpace) -> StudySpace? {
        func firstNonEmpty(_ values: String?...) -> String? {
            values
                .compactMap { $0?.trimmingCharacters(in: .whitespacesAndNewlines) }
                .first { !$0.isEmpty }
        }

        guard let id = UUID(uuidString: remote.id.trimmingCharacters(in: .whitespacesAndNewlines)) else {
            return nil
        }

        let resolvedDescription = remote.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedIcon = remote.iconName?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedCategory = remote.category?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedTag = remote.tag?.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedColor = remote.workspaceColorHex?.trimmingCharacters(in: .whitespacesAndNewlines)
            ?? remote.color?.trimmingCharacters(in: .whitespacesAndNewlines)

        return StudySpace(
            id: id,
            title: remote.title,
            description: firstNonEmpty(resolvedDescription) ?? "No description yet.",
            iconName: firstNonEmpty(resolvedIcon) ?? "book.closed",
            category: firstNonEmpty(resolvedCategory, resolvedTag) ?? "General",
            status: .init(normalizing: remote.status),
            workspaceColorHex: firstNonEmpty(resolvedColor) ?? "#388767",
            documentCount: remote.documentCount ?? 0,
            noteCount: remote.noteCount ?? 0,
            lastUpdated: Self.relativeTimeLabel(from: remote.updatedAt ?? remote.createdAt),
            lastOpened: "Opened just now",
            aiOutputCount: remote.aiOutputCount ?? remote.summaries?.count ?? 0,
            progress: remote.progress ?? 0
        )
    }

    var createRequest: CreateWorkspaceRequest {
        CreateWorkspaceRequest(
            title: title,
            description: description,
            iconName: iconName,
            category: category,
            status: status,
            workspaceColorHex: workspaceColorHex,
            documentCount: documentCount,
            noteCount: noteCount,
            aiOutputCount: aiOutputCount,
            progress: progress
        )
    }

    var updateRequest: UpdateWorkspaceRequest {
        UpdateWorkspaceRequest(
            title: title,
            description: description,
            iconName: iconName,
            category: category,
            status: status,
            workspaceColorHex: workspaceColorHex,
            documentCount: documentCount,
            noteCount: noteCount,
            aiOutputCount: aiOutputCount,
            progress: progress
        )
    }

    private static func relativeTimeLabel(from date: Date?) -> String {
        guard let date else { return "Just now" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        let value = formatter.localizedString(for: date, relativeTo: Date())
        if value.lowercased() == "now" {
            return "Just now"
        }
        return "Last updated \(value)"
    }
}

extension StudySpace {
    var workspaceAccentColor: Color {
        Color(hex: workspaceColorHex) ?? Color(red: 0.22, green: 0.53, blue: 0.40)
    }

    var normalizedStatus: String {
        status.displayName
    }

    var statusForegroundColor: Color {
        status.foregroundColor
    }

    var statusBackgroundColor: Color {
        status.backgroundColor
    }
}
