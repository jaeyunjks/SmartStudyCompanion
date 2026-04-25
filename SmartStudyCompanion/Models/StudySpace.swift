import Foundation
import SwiftUI

struct StudySpace: Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let category: String
    let status: String
    let workspaceColorHex: String
    let documentCount: Int
    let noteCount: Int
    let lastUpdated: String
    let lastOpened: String
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
            status: "Active",
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
            status: "Inactive",
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
            status: "Active",
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
            status: "Active",
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
            status: "Inactive",
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
    var workspaceAccentColor: Color {
        Color(hex: workspaceColorHex) ?? Color(red: 0.22, green: 0.53, blue: 0.40)
    }

    var normalizedStatus: String {
        status.caseInsensitiveCompare("inactive") == .orderedSame ? "Inactive" : "Active"
    }

    var statusForegroundColor: Color {
        normalizedStatus == "Inactive"
            ? Color(red: 0.76, green: 0.25, blue: 0.30)
            : Color(red: 0.22, green: 0.58, blue: 0.38)
    }

    var statusBackgroundColor: Color {
        statusForegroundColor.opacity(0.14)
    }
}
