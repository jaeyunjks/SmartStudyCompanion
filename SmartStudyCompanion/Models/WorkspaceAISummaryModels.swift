import Foundation

struct WorkspaceAISummaryRequest: Codable, Hashable {
    let workspaceId: String
    let workspaceTitle: String
    let workspaceContent: String
}

struct WorkspaceAISummaryResponse: Codable {
    let summary: WorkspaceAISummaryDTO
}

struct WorkspaceAISummaryDTO: Codable {
    let overview: String
    let keyConcepts: [String]
    let importantDetails: [String]
    let reviewNext: [String]

    func toStudySummary(workspaceTitle: String) -> StudySummary {
        let mergedMainIdeas = (importantDetails + reviewNext)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let concepts: [KeyConcept] = keyConcepts.compactMap { item in
            let trimmed = item.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }

            if let separatorIndex = trimmed.firstIndex(where: { $0 == ":" || $0 == "-" }) {
                let term = trimmed[..<separatorIndex].trimmingCharacters(in: .whitespacesAndNewlines)
                let definition = trimmed[trimmed.index(after: separatorIndex)...].trimmingCharacters(in: .whitespacesAndNewlines)
                if !term.isEmpty, !definition.isEmpty {
                    return KeyConcept(term: term, definition: definition)
                }
            }

            return KeyConcept(term: trimmed, definition: "Review this concept in your workspace notes.")
        }

        let points = importantDetails.map {
            ImportantPoint(
                text: $0.trimmingCharacters(in: .whitespacesAndNewlines),
                highlights: []
            )
        }.filter { !$0.text.isEmpty }

        return StudySummary(
            id: UUID(),
            category: "Workspace Notes",
            estimatedReadTime: "Auto summary",
            title: "\(workspaceTitle) Summary",
            overview: overview.trimmingCharacters(in: .whitespacesAndNewlines),
            mainIdeas: mergedMainIdeas.prefix(3).map { SummaryMainIdea(text: $0) },
            visualReferenceTitle: "Generated from workspace notes",
            visualReferenceCaption: "AI Summary",
            imageName: nil,
            imageSystemName: "text.book.closed.fill",
            keyConcepts: concepts,
            importantPoints: points,
            isBookmarked: false
        )
    }
}
