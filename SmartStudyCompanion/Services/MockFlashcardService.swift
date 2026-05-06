import Foundation

struct MockFlashcardService: FlashcardSessionServiceProtocol {
    func generateSessionFlashcards(request: FlashcardGenerationRequest) async throws -> FlashcardGenerationResponse {
        try await Task.sleep(nanoseconds: 250_000_000)

        let allCards = Self.mockCards
        let filteredByDifficulty: [FlashcardItem]

        if request.preferredTopics.contains("show_all") {
            filteredByDifficulty = allCards
        } else {
            let target = request.difficulty
            filteredByDifficulty = allCards.filter { card in
                switch card.difficulty {
                case .beginner: return target == .easy
                case .intermediate: return target == .medium
                case .advanced: return target == .hard
                case .showAll: return true
                }
            }
        }

        let cards = Array((filteredByDifficulty.isEmpty ? allCards : filteredByDifficulty).prefix(request.count))

        guard !cards.isEmpty else {
            throw FlashcardSessionServiceError.noFlashcards
        }

        return FlashcardGenerationResponse(flashcards: cards, generatedAt: Date())
    }
}

private extension MockFlashcardService {
    static let mockCards: [FlashcardItem] = [
        FlashcardItem(type: .definition, frontText: "Define elasticity in cloud computing.", backText: "Elasticity is the ability to automatically scale resources up or down in response to workload demand.", difficulty: .beginner, module: "Cloud Infrastructure Module"),
        FlashcardItem(type: .concept, frontText: "Why does normalization matter in relational databases?", backText: "Normalization reduces redundancy and update anomalies by organizing data into well-structured tables.", difficulty: .intermediate, module: "Database Systems Module"),
        FlashcardItem(type: .comparison, frontText: "Compare horizontal scaling and vertical scaling.", backText: "Horizontal scaling adds more machines; vertical scaling adds more power to a single machine.", difficulty: .beginner, module: "Systems Module"),
        FlashcardItem(type: .concept, frontText: "What is eventual consistency?", backText: "Eventual consistency means distributed nodes may temporarily diverge, but will converge to the same state over time.", difficulty: .advanced, module: "Distributed Systems Module"),
        FlashcardItem(type: .definition, frontText: "What does ACID stand for in databases?", backText: "Atomicity, Consistency, Isolation, and Durability.", difficulty: .beginner, module: "Database Systems Module"),
        FlashcardItem(type: .comparison, frontText: "AWS vs Azure: key enterprise distinction?", backText: "AWS offers broader service breadth; Azure often integrates more directly with Microsoft enterprise environments.", difficulty: .intermediate, module: "Cloud Infrastructure Module"),
        FlashcardItem(type: .concept, frontText: "Why use caching near users?", backText: "It reduces repeated network trips and lowers latency for frequently accessed data.", difficulty: .beginner, module: "Systems Module"),
        FlashcardItem(type: .definition, frontText: "What is a container orchestration platform?", backText: "A system like Kubernetes that automates deployment, scaling, and management of containerized applications.", difficulty: .advanced, module: "Software Development Module"),
        FlashcardItem(type: .comparison, frontText: "Monolith vs microservices architecture.", backText: "Monoliths are single deployable units; microservices split functionality into independently deployable services.", difficulty: .intermediate, module: "Software Development Module"),
        FlashcardItem(type: .concept, frontText: "What problem does replication solve?", backText: "Replication improves availability and fault tolerance by keeping data copies on multiple nodes.", difficulty: .advanced, module: "Distributed Systems Module")
    ]
}
