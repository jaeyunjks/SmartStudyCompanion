import Foundation

struct MockStudyPlanService: StudyPlanServiceProtocol {
    func generateStudyPlan(request: StudyPlanGenerationRequest) async throws -> StudyPlanGenerationResponse {
        try await Task.sleep(nanoseconds: 250_000_000)

        let plan = StudyPlan(
            title: "Study Plan",
            workspaceName: request.workspaceTitle,
            topicBadge: "Cloud Fundamentals",
            supportiveMessage: "Great momentum. Finish the practice block to lock in your weak areas.",
            sections: [
                StudyPlanSection(
                    title: "Understand",
                    tasks: [
                        StudyTask(title: "Summarize cloud service models (IaaS, PaaS, SaaS)", destination: .summary, priority: .high, estimatedDurationMinutes: 15, recommendedOrder: 1, linkedWeaknessArea: "service models"),
                        StudyTask(title: "Compare scalability vs elasticity in your notes", destination: .summary, priority: .medium, estimatedDurationMinutes: 12, recommendedOrder: 2),
                        StudyTask(title: "Ask AI tutor to clarify shared responsibility model", destination: .aiChat, priority: .high, estimatedDurationMinutes: 10, recommendedOrder: 3, linkedWeaknessArea: "security")
                    ]
                ),
                StudyPlanSection(
                    title: "Practice",
                    tasks: [
                        StudyTask(title: "Complete a 5-question cloud architecture quiz", destination: .quiz, priority: .high, estimatedDurationMinutes: 10, recommendedOrder: 4),
                        StudyTask(title: "Run flashcard session on deployment models", destination: .flashcards, priority: .medium, estimatedDurationMinutes: 12, recommendedOrder: 5),
                        StudyTask(title: "Answer one challenge prompt on cost trade-offs", destination: .aiChat, priority: .medium, estimatedDurationMinutes: 8, recommendedOrder: 6)
                    ]
                ),
                StudyPlanSection(
                    title: "Review Later",
                    tasks: [
                        StudyTask(title: "Revisit ACID transaction guarantees", destination: .summary, priority: .low, estimatedDurationMinutes: 8, recommendedOrder: 7, linkedWeaknessArea: "database durability"),
                        StudyTask(title: "Retry incorrect quiz questions", destination: .quiz, priority: .medium, estimatedDurationMinutes: 10, recommendedOrder: 8),
                        StudyTask(title: "Generate comparison flashcards for AWS vs Azure", destination: .flashcards, priority: .low, estimatedDurationMinutes: 10, recommendedOrder: 9)
                    ]
                )
            ]
        )

        return StudyPlanGenerationResponse(plan: plan, generatedAt: Date())
    }
}
