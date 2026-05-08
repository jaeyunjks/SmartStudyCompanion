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
    let quickTakeaways: [String]
    let suggestedNextActions: [String]

    func toStudySummary(workspaceTitle: String) -> StudySummary {
        let cleanedOverview = overview.trimmingCharacters(in: .whitespacesAndNewlines)

        let keyPoints = importantDetails
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

            return KeyConcept(term: trimmed, definition: "Review this concept from your selected materials.")
        }

        let takeaways = quickTakeaways
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        let nextActions = suggestedNextActions
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        return StudySummary(
            id: UUID(),
            category: "Workspace Notes",
            estimatedReadTime: "Auto summary",
            title: "\(workspaceTitle) Summary",
            overview: cleanedOverview,
            mainIdeas: keyPoints.prefix(6).map { SummaryMainIdea(text: $0) },
            keyConcepts: concepts,
            importantPoints: keyPoints.map { ImportantPoint(text: $0, highlights: []) },
            examples: [],
            quickTakeaways: Array(takeaways.prefix(5)),
            suggestedNextActions: Array(nextActions.prefix(5)),
            isBookmarked: false
        )
    }
}
