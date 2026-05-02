import Foundation

struct StudySummary: Identifiable, Equatable, Codable {
    let id: UUID
    let category: String
    let estimatedReadTime: String
    var title: String
    let overview: String
    let mainIdeas: [SummaryMainIdea]
    let keyConcepts: [KeyConcept]
    let importantPoints: [ImportantPoint]
    let examples: [String]
    let quickTakeaways: [String]
    let suggestedNextActions: [String]
    var isBookmarked: Bool

    func simplifiedVersion() -> StudySummary {
        StudySummary(
            id: UUID(),
            category: category,
            estimatedReadTime: "Quick read",
            title: "\(title) (Simplified)",
            overview: overview.shortened(maxWords: 45),
            mainIdeas: mainIdeas.prefix(4).map { SummaryMainIdea(text: $0.text.shortened(maxWords: 14)) },
            keyConcepts: keyConcepts.prefix(4).map {
                KeyConcept(term: $0.term, definition: $0.definition.shortened(maxWords: 14))
            },
            importantPoints: importantPoints.prefix(5).map {
                ImportantPoint(text: $0.text.shortened(maxWords: 16), highlights: [])
            },
            examples: examples.prefix(2).map { $0.shortened(maxWords: 18) },
            quickTakeaways: quickTakeaways.prefix(5).map { $0.shortened(maxWords: 12) },
            suggestedNextActions: suggestedNextActions.prefix(5).map { $0.shortened(maxWords: 12) },
            isBookmarked: isBookmarked
        )
    }

    var shareText: String {
        let keyPoints = mainIdeas.map { "- \($0.text)" }.joined(separator: "\n")
        let concepts = keyConcepts.map { "- \($0.term): \($0.definition)" }.joined(separator: "\n")
        let takeaways = quickTakeaways.map { "- \($0)" }.joined(separator: "\n")
        let actions = suggestedNextActions.map { "- \($0)" }.joined(separator: "\n")
        let exampleText = examples.isEmpty ? "" : "\nExamples\n" + examples.map { "- \($0)" }.joined(separator: "\n")

        return """
        \(title)

        Overview
        \(overview)

        Key Points
        \(keyPoints)

        Key Concepts
        \(concepts)\(exampleText)

        Quick Takeaways
        \(takeaways)

        Suggested Next Actions
        \(actions)
        """
    }
}

struct SummaryMainIdea: Identifiable, Equatable, Codable {
    let id: UUID
    let text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

struct KeyConcept: Identifiable, Equatable, Codable {
    let id: UUID
    let term: String
    let definition: String

    init(id: UUID = UUID(), term: String, definition: String) {
        self.id = id
        self.term = term
        self.definition = definition
    }
}

struct ImportantPoint: Identifiable, Equatable, Codable {
    let id: UUID
    let text: String
    let highlights: [String]

    init(id: UUID = UUID(), text: String, highlights: [String]) {
        self.id = id
        self.text = text
        self.highlights = highlights
    }
}

extension StudySummary {
    static let previewSummaries: [StudySummary] = [
        StudySummary(
            id: UUID(),
            category: "Workspace",
            estimatedReadTime: "3 min read",
            title: "Cloud Architecture Notes",
            overview: "Cloud architecture separates concerns across compute, networking, and data layers. This helps teams scale safely and maintain reliability as demand changes.",
            mainIdeas: [
                SummaryMainIdea(text: "Service models define which layer you manage: IaaS, PaaS, or SaaS."),
                SummaryMainIdea(text: "Resilience comes from redundancy, failover, and observability."),
                SummaryMainIdea(text: "Cost control depends on right-sizing and usage monitoring.")
            ],
            keyConcepts: [
                KeyConcept(term: "Scalability", definition: "Ability to handle more workload by adding resources."),
                KeyConcept(term: "Elasticity", definition: "Automatically scale resources up or down based on demand."),
                KeyConcept(term: "High Availability", definition: "Design to reduce downtime through redundancy and recovery.")
            ],
            importantPoints: [
                ImportantPoint(text: "Shared responsibility defines provider vs customer security duties.", highlights: []),
                ImportantPoint(text: "Monitoring and alerting reduce incident response time.", highlights: [])
            ],
            examples: [
                "Use autoscaling groups to absorb sudden traffic spikes.",
                "Deploy databases across zones for failover."
            ],
            quickTakeaways: [
                "Pick the right cloud service model.",
                "Design for failure from day one.",
                "Track cost and performance together."
            ],
            suggestedNextActions: [
                "Review your current architecture diagram.",
                "List single points of failure.",
                "Set basic SLA and alert thresholds."
            ],
            isBookmarked: false
        )
    ]
}

private extension String {
    func shortened(maxWords: Int) -> String {
        let words = split(separator: " ")
        guard words.count > maxWords else { return self }
        return words.prefix(maxWords).joined(separator: " ") + "…"
    }
}
