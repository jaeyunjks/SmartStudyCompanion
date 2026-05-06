import Foundation

enum StudyTaskPriority: String, Codable, CaseIterable {
    case low
    case medium
    case high
}

enum StudyTaskStatus: String, Codable {
    case pending
    case completed
}

enum StudyTaskDestination: String, Codable {
    case summary
    case quiz
    case flashcards
    case aiChat
    case none
}

struct StudyTask: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    var status: StudyTaskStatus
    let destination: StudyTaskDestination
    let priority: StudyTaskPriority
    let estimatedDurationMinutes: Int
    let recommendedOrder: Int
    let linkedWeaknessArea: String?

    init(
        id: UUID = UUID(),
        title: String,
        status: StudyTaskStatus = .pending,
        destination: StudyTaskDestination = .none,
        priority: StudyTaskPriority = .medium,
        estimatedDurationMinutes: Int,
        recommendedOrder: Int,
        linkedWeaknessArea: String? = nil
    ) {
        self.id = id
        self.title = title
        self.status = status
        self.destination = destination
        self.priority = priority
        self.estimatedDurationMinutes = estimatedDurationMinutes
        self.recommendedOrder = recommendedOrder
        self.linkedWeaknessArea = linkedWeaknessArea
    }

    var isCompleted: Bool {
        status == .completed
    }
}

struct StudyPlanSection: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    var tasks: [StudyTask]

    init(id: UUID = UUID(), title: String, tasks: [StudyTask]) {
        self.id = id
        self.title = title
        self.tasks = tasks
    }

    var completedCount: Int {
        tasks.filter(\.isCompleted).count
    }
}

struct StudyPlan: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let workspaceName: String
    let topicBadge: String
    let supportiveMessage: String
    var sections: [StudyPlanSection]

    init(
        id: UUID = UUID(),
        title: String,
        workspaceName: String,
        topicBadge: String,
        supportiveMessage: String,
        sections: [StudyPlanSection]
    ) {
        self.id = id
        self.title = title
        self.workspaceName = workspaceName
        self.topicBadge = topicBadge
        self.supportiveMessage = supportiveMessage
        self.sections = sections
    }

    var totalTaskCount: Int {
        sections.flatMap(\.tasks).count
    }

    var completedTaskCount: Int {
        sections.flatMap(\.tasks).filter(\.isCompleted).count
    }

    var completionPercentage: Double {
        guard totalTaskCount > 0 else { return 0 }
        return Double(completedTaskCount) / Double(totalTaskCount)
    }
}

struct StudyPlanGenerationRequest: Codable {
    let workspaceTitle: String
    let sourceSummaryIDs: [String]
    let sourceQuizIDs: [String]
    let sourceFlashcardIDs: [String]
    let weaknessAreas: [String]
}

struct StudyPlanGenerationResponse: Codable {
    let plan: StudyPlan
    let generatedAt: Date
}
