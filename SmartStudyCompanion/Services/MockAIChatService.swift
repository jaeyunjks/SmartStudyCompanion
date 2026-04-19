import Foundation

struct MockAIChatService: AIChatServiceProtocol {
    func sendMessage(
        message: String,
        context: WorkspaceContext,
        mode: ChatMode,
        conversationHistory: [ChatMessage]
    ) async throws -> AIChatResponse {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AIChatServiceError.emptyMessage
        }

        try await Task.sleep(nanoseconds: 900_000_000)

        let lowercased = trimmed.lowercased()

        if lowercased.contains("cost") || lowercased.contains("aws") || lowercased.contains("azure") {
            return guidedCloudResponse(mode: mode)
        }

        if lowercased.contains("database") || lowercased.contains("sql") || lowercased.contains("acid") {
            return guidedDatabaseResponse(mode: mode)
        }

        if lowercased.contains("system") || lowercased.contains("latency") || lowercased.contains("scal") {
            return guidedSystemsResponse(mode: mode)
        }

        let messageCount = conversationHistory.filter { $0.role == .user }.count
        if messageCount % 3 == 0 {
            return AIChatResponse(
                assistantMessage: "Before I explain, what do you already think is the key idea here? We can build from your current understanding and then verify it against your notes.",
                followUpQuestion: "What is your current hypothesis?",
                suggestedMode: .guide
            )
        }

        return AIChatResponse(
            assistantMessage: "I can help with that. First hint: identify the trade-off being discussed in your material. Then we can test your answer with one concrete example from your notes.",
            followUpQuestion: "Which trade-off stands out most to you?",
            suggestedMode: .hint
        )
    }

    private func guidedCloudResponse(mode: ChatMode) -> AIChatResponse {
        switch mode {
        case .hint:
            return AIChatResponse(
                assistantMessage: "Hint first: compare these in order: pricing model, hybrid integration, and service breadth. Start by listing one strength for AWS and one for Azure from your notes.",
                followUpQuestion: "Which platform looked stronger for hybrid setups in your table?",
                suggestedMode: .guide
            )
        case .challenge:
            return AIChatResponse(
                assistantMessage: "Challenge: if your company already runs Microsoft identity + licensing, would AWS still be cheaper over 24 months? Defend your answer using two criteria from the table.",
                followUpQuestion: "What two criteria would you use to justify that decision?",
                suggestedMode: .guide
            )
        case .explain:
            return AIChatResponse(
                assistantMessage: "From your cloud comparison notes: AWS usually provides broader specialized services, while Azure often has stronger enterprise integration for Windows-heavy environments. A practical way to decide is to compare workload pattern + existing ecosystem lock-in + projected operational cost.",
                followUpQuestion: "Want a simpler explanation in 3 bullet points?",
                suggestedMode: .hint
            )
        case .guide:
            return AIChatResponse(
                assistantMessage: "Good question. Let us reason it out together instead of jumping to a final answer. Step 1: what workload are we optimizing for? Step 2: check how each platform scores on cost predictability and hybrid support in your notes.",
                followUpQuestion: "What workload type did your notes emphasize: steady, bursty, or enterprise hybrid?",
                suggestedMode: .guide
            )
        }
    }

    private func guidedDatabaseResponse(mode: ChatMode) -> AIChatResponse {
        switch mode {
        case .hint:
            return AIChatResponse(
                assistantMessage: "Hint: ACID is not just a definition question. Ask yourself which failure scenario each property protects against.",
                followUpQuestion: "Can you map Atomicity and Durability to one real failure case each?",
                suggestedMode: .challenge
            )
        case .challenge:
            return AIChatResponse(
                assistantMessage: "Challenge prompt: if isolation is reduced to improve throughput, which anomaly becomes acceptable for your workload, and why?",
                followUpQuestion: "Would you accept non-repeatable reads in this case?",
                suggestedMode: .guide
            )
        case .explain:
            return AIChatResponse(
                assistantMessage: "Database performance depends on schema quality, transaction design, and indexes. In your notes, normalization improves data integrity, while targeted indexing improves query speed. The real skill is balancing both without over-indexing writes.",
                followUpQuestion: "Want a quick checklist for choosing indexes?",
                suggestedMode: .hint
            )
        case .guide:
            return AIChatResponse(
                assistantMessage: "Let us work through it: first identify the query pattern, then decide whether schema or indexing is the current bottleneck. We can evaluate your query example step by step.",
                followUpQuestion: "Do you want to start from schema design or from query optimization?",
                suggestedMode: .guide
            )
        }
    }

    private func guidedSystemsResponse(mode: ChatMode) -> AIChatResponse {
        switch mode {
        case .hint:
            return AIChatResponse(
                assistantMessage: "Hint: split the problem into latency, throughput, and consistency. Most systems trade one of these under load.",
                followUpQuestion: "Which metric becomes unstable first in your scenario?",
                suggestedMode: .guide
            )
        case .challenge:
            return AIChatResponse(
                assistantMessage: "Challenge: design a fault-tolerant path for one node failure without increasing p95 latency too much.",
                followUpQuestion: "What redundancy strategy would you pick first?",
                suggestedMode: .explain
            )
        case .explain:
            return AIChatResponse(
                assistantMessage: "In distributed systems, lower latency often comes from locality and caching, while resilience comes from replication and failover. Your design choices should align with which failure you can tolerate and which delay users will notice.",
                followUpQuestion: "Need a simplified architecture sketch in words?",
                suggestedMode: .hint
            )
        case .guide:
            return AIChatResponse(
                assistantMessage: "I can coach you through this. Start by describing where latency appears in your pipeline. Then we will decide whether to reduce hops, cache responses, or adjust consistency guarantees.",
                followUpQuestion: "Which step in your request path feels slowest?",
                suggestedMode: .guide
            )
        }
    }
}
