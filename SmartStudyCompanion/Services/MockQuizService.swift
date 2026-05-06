import Foundation

struct MockQuizService: QuizProviderProtocol {
    func generateQuiz(request: QuizGenerationRequest) async throws -> QuizGenerationResponse {
        try await Task.sleep(nanoseconds: 250_000_000)

        let allQuestions = Self.mockQuestions
        let count = max(1, min(request.questionCount, allQuestions.count))

        return QuizGenerationResponse(
            quizTitle: request.workspaceTitle.map { "\($0) Quiz" } ?? "Knowledge Quiz",
            questions: Array(allQuestions.prefix(count))
        )
    }
}

private extension MockQuizService {
    static let mockQuestions: [QuizQuestion] = [
        QuizQuestion(
            questionText: "Which of the following is a key characteristic of Cloud Computing?",
            options: [
                QuizOption(label: "A", text: "On-demand self-service"),
                QuizOption(label: "B", text: "Static infrastructure"),
                QuizOption(label: "C", text: "Manual resource allocation"),
                QuizOption(label: "D", text: "Limited accessibility")
            ],
            correctOptionID: "A",
            explanation: "Cloud platforms let users provision resources on demand without waiting for manual infrastructure setup.",
            topic: "Cloud Computing"
        ).resolvedCorrectOptionByLabel,
        QuizQuestion(
            questionText: "In relational databases, what is the primary purpose of normalization?",
            options: [
                QuizOption(label: "A", text: "Increase data duplication"),
                QuizOption(label: "B", text: "Reduce redundancy and update anomalies"),
                QuizOption(label: "C", text: "Replace SQL indexes"),
                QuizOption(label: "D", text: "Store all data in one table")
            ],
            correctOptionID: "B",
            explanation: "Normalization organizes data into structured relations so updates stay consistent and duplication is reduced.",
            topic: "Databases"
        ).resolvedCorrectOptionByLabel,
        QuizQuestion(
            questionText: "Which ACID property ensures committed transactions are preserved after a failure?",
            options: [
                QuizOption(label: "A", text: "Atomicity"),
                QuizOption(label: "B", text: "Consistency"),
                QuizOption(label: "C", text: "Isolation"),
                QuizOption(label: "D", text: "Durability")
            ],
            correctOptionID: "D",
            explanation: "Durability guarantees that once a transaction commits, the data remains persisted even if the system crashes.",
            topic: "Databases"
        ).resolvedCorrectOptionByLabel,
        QuizQuestion(
            questionText: "In distributed systems, what usually helps lower latency for repeated reads?",
            options: [
                QuizOption(label: "A", text: "Frequent full-table scans"),
                QuizOption(label: "B", text: "Adding network hops"),
                QuizOption(label: "C", text: "Caching near consumers"),
                QuizOption(label: "D", text: "Serializing all requests")
            ],
            correctOptionID: "C",
            explanation: "Caching data closer to users avoids repeated remote calls and typically reduces response time.",
            topic: "Distributed Systems"
        ).resolvedCorrectOptionByLabel,
        QuizQuestion(
            questionText: "Which statement best describes Infrastructure as a Service (IaaS)?",
            options: [
                QuizOption(label: "A", text: "Complete applications delivered to end users"),
                QuizOption(label: "B", text: "Managed runtime and deployment platform only"),
                QuizOption(label: "C", text: "Virtualized compute, storage, and networking resources"),
                QuizOption(label: "D", text: "Physical server ownership for all tenants")
            ],
            correctOptionID: "C",
            explanation: "IaaS provides infrastructure building blocks so teams can configure operating systems, networking, and compute resources.",
            topic: "Cloud Computing"
        ).resolvedCorrectOptionByLabel
    ]
}

private extension QuizQuestion {
    var resolvedCorrectOptionByLabel: QuizQuestion {
        guard let resolved = options.first(where: { $0.label == correctOptionID }) else {
            return self
        }

        return QuizQuestion(
            id: id,
            questionText: questionText,
            options: options,
            correctOptionID: resolved.id,
            explanation: explanation,
            topic: topic
        )
    }
}
