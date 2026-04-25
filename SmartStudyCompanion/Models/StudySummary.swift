import Foundation

struct StudySummary: Identifiable, Equatable {
    let id: UUID
    let category: String
    let estimatedReadTime: String
    let title: String
    let overview: String
    let mainIdeas: [SummaryMainIdea]
    let visualReferenceTitle: String
    let visualReferenceCaption: String
    let imageName: String?
    let imageSystemName: String
    let keyConcepts: [KeyConcept]
    let importantPoints: [ImportantPoint]
    var isBookmarked: Bool

    func simplifiedVersion() -> StudySummary {
        StudySummary(
            id: id,
            category: category,
            estimatedReadTime: "5 min read",
            title: "\(title) (Simplified)",
            overview: simplifiedOverview,
            mainIdeas: mainIdeas.prefix(2).map { idea in
                SummaryMainIdea(text: idea.text.shortened(maxWords: 16))
            },
            visualReferenceTitle: visualReferenceTitle,
            visualReferenceCaption: visualReferenceCaption,
            imageName: imageName,
            imageSystemName: imageSystemName,
            keyConcepts: keyConcepts.prefix(3).map { concept in
                KeyConcept(term: concept.term, definition: concept.definition.shortened(maxWords: 14))
            },
            importantPoints: importantPoints.prefix(2).map { point in
                ImportantPoint(text: point.text.shortened(maxWords: 22), highlights: point.highlights)
            },
            isBookmarked: isBookmarked
        )
    }

    var shareText: String {
        let ideas = mainIdeas.map { "- \($0.text)" }.joined(separator: "\n")
        let concepts = keyConcepts.map { "- \($0.term): \($0.definition)" }.joined(separator: "\n")
        let points = importantPoints.map { "- \($0.text)" }.joined(separator: "\n")

        return """
        \(title)
        \(category) • \(estimatedReadTime)

        Overview
        \(overview)

        Main Ideas
        \(ideas)

        Key Concepts
        \(concepts)

        Important Points
        \(points)
        """
    }

    private var simplifiedOverview: String {
        let sentence = overview.split(separator: ".").first.map(String.init) ?? overview
        return sentence.trimmingCharacters(in: .whitespacesAndNewlines) + "."
    }
}

struct SummaryMainIdea: Identifiable, Equatable {
    let id: UUID
    let text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}

struct KeyConcept: Identifiable, Equatable {
    let id: UUID
    let term: String
    let definition: String

    init(id: UUID = UUID(), term: String, definition: String) {
        self.id = id
        self.term = term
        self.definition = definition
    }
}

struct ImportantPoint: Identifiable, Equatable {
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
    /// Development-only sample summaries for SwiftUI previews.
    static let previewSummaries: [StudySummary] = [
        StudySummary(
            id: UUID(),
            category: "Computer Science",
            estimatedReadTime: "10 min read",
            title: "Cloud Computing Architecture",
            overview: "A comprehensive look at service models, deployment options, and infrastructure abstractions that power scalable cloud-native systems.",
            mainIdeas: [
                SummaryMainIdea(text: "Service models segment cloud offerings into IaaS, PaaS, and SaaS, each abstracting a different layer of responsibility."),
                SummaryMainIdea(text: "Deployment models define governance boundaries across public, private, and hybrid environments."),
                SummaryMainIdea(text: "Virtualization and orchestration enable efficient resource pooling and workload portability across distributed infrastructure.")
            ],
            visualReferenceTitle: "Distributed Network Topology",
            visualReferenceCaption: "Visual Reference",
            imageName: nil,
            imageSystemName: "point.3.connected.trianglepath.dotted",
            keyConcepts: [
                KeyConcept(term: "Scalability", definition: "The ability to handle increased workloads by adding compute, storage, or networking resources."),
                KeyConcept(term: "Elasticity", definition: "Automatic expansion and contraction of resources based on real-time demand."),
                KeyConcept(term: "High Availability", definition: "System design that minimizes downtime through redundancy, failover, and resilient architecture."),
                KeyConcept(term: "Fault Tolerance", definition: "A system's capacity to continue functioning correctly even when some components fail.")
            ],
            importantPoints: [
                ImportantPoint(text: "The Shared Responsibility Model separates provider duties for cloud security from customer duties for workload and data protection.", highlights: ["Shared Responsibility Model"]),
                ImportantPoint(text: "Pay-as-you-go pricing shifts infrastructure costs from CapEx to OpEx and improves financial flexibility.", highlights: ["Pay-as-you-go pricing", "CapEx", "OpEx"]),
                ImportantPoint(text: "Edge Computing reduces latency by processing data closer to users and connected devices.", highlights: ["Edge Computing"])
            ],
            isBookmarked: false
        ),
        StudySummary(
            id: UUID(),
            category: "Information Systems",
            estimatedReadTime: "9 min read",
            title: "Database Systems Fundamentals",
            overview: "An organized summary of relational design, transaction control, and indexing strategies used to build reliable data platforms.",
            mainIdeas: [
                SummaryMainIdea(text: "Normalization reduces redundancy and update anomalies by structuring data into well-defined relational forms."),
                SummaryMainIdea(text: "ACID transactions enforce consistency through atomicity, isolation, and durable commit protocols."),
                SummaryMainIdea(text: "Index design and query planning are major determinants of read performance at scale.")
            ],
            visualReferenceTitle: "Relational Data Flow",
            visualReferenceCaption: "Visual Reference",
            imageName: nil,
            imageSystemName: "cylinder.split.1x2",
            keyConcepts: [
                KeyConcept(term: "Normalization", definition: "A schema design process that organizes attributes and tables to minimize redundancy."),
                KeyConcept(term: "ACID", definition: "Transaction guarantees that preserve correctness during concurrent operations and failures."),
                KeyConcept(term: "Index", definition: "Auxiliary data structure that accelerates lookup and filtering without scanning full tables."),
                KeyConcept(term: "Query Optimizer", definition: "Engine component that selects the lowest-cost execution plan for SQL statements.")
            ],
            importantPoints: [
                ImportantPoint(text: "The Isolation level directly impacts contention, read phenomena, and throughput under concurrency.", highlights: ["Isolation level"]),
                ImportantPoint(text: "Composite indexes should match common filter and sort patterns to avoid expensive scans.", highlights: ["Composite indexes"]),
                ImportantPoint(text: "Backup and replication policies are mandatory for recovery objectives and business continuity.", highlights: ["Backup", "replication"])
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
