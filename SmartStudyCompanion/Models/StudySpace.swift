import Foundation

struct StudySpace: Identifiable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let iconName: String
    let status: String
    let documentCount: Int
    let noteCount: Int
    let lastUpdated: String
    let progress: Double
}

extension StudySpace {
    static let sampleData: [StudySpace] = [
        .init(
            id: UUID(),
            title: "41001 Cloud Computing",
            description: "Infrastructure as service, virtualization techniques, and distributed systems architecture.",
            iconName: "cloud",
            status: "Active",
            documentCount: 3,
            noteCount: 2,
            lastUpdated: "Last updated 2h ago",
            progress: 0.74
        ),
        .init(
            id: UUID(),
            title: "Cognitive Neuroscience",
            description: "Exploring neural mechanisms of thought, memory, and spatial navigation.",
            iconName: "brain.head.profile",
            status: "In Progress",
            documentCount: 12,
            noteCount: 8,
            lastUpdated: "Last updated 5h ago",
            progress: 0.42
        ),
        .init(
            id: UUID(),
            title: "Advanced AI Ethics",
            description: "Algorithmic bias, regulatory frameworks, and future safety.",
            iconName: "sparkles",
            status: "Priority",
            documentCount: 5,
            noteCount: 6,
            lastUpdated: "Last updated yesterday",
            progress: 0.55
        ),
        .init(
            id: UUID(),
            title: "Data Structures & Algo",
            description: "B-Trees, graph theory, and complexity analysis for final prep.",
            iconName: "tray.full",
            status: "Review",
            documentCount: 5,
            noteCount: 14,
            lastUpdated: "Last updated yesterday",
            progress: 0.63
        ),
        .init(
            id: UUID(),
            title: "Modern Ethics 101",
            description: "Readings on utilitarianism, deontology, and virtual ethics frameworks.",
            iconName: "book.closed",
            status: "Completed",
            documentCount: 2,
            noteCount: 1,
            lastUpdated: "Completed Oct 24",
            progress: 1.0
        )
    ]
}
