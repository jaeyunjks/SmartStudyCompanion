import Foundation

enum ChatRole: String, Codable {
    case user
    case assistant
}

enum ChatMode: String, Codable, CaseIterable, Identifiable {
    case hint
    case guide
    case challenge
    case explain

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hint: return "Hint"
        case .guide: return "Guide"
        case .challenge: return "Challenge"
        case .explain: return "Explain"
        }
    }
}

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let role: ChatRole
    let text: String
    let timestamp: Date
    let isTyping: Bool

    init(
        id: UUID = UUID(),
        role: ChatRole,
        text: String,
        timestamp: Date = Date(),
        isTyping: Bool = false
    ) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
        self.isTyping = isTyping
    }
}

struct SuggestedPrompt: Identifiable, Equatable {
    let id: UUID
    let title: String
    let message: String

    init(id: UUID = UUID(), title: String, message: String) {
        self.id = id
        self.title = title
        self.message = message
    }
}

struct WorkspaceContext: Identifiable, Codable, Equatable {
    let id: UUID
    let workspaceTitle: String
    let sourceTitle: String
    let sourceType: String
    let description: String
    let visualLabel: String
    let previewSystemImage: String
    let referencedMaterials: [ReferencedMaterial]
    let aiContextSource: AIContextSource?

    init(
        id: UUID = UUID(),
        workspaceTitle: String,
        sourceTitle: String,
        sourceType: String,
        description: String,
        visualLabel: String,
        previewSystemImage: String,
        referencedMaterials: [ReferencedMaterial] = [],
        aiContextSource: AIContextSource? = nil
    ) {
        self.id = id
        self.workspaceTitle = workspaceTitle
        self.sourceTitle = sourceTitle
        self.sourceType = sourceType
        self.description = description
        self.visualLabel = visualLabel
        self.previewSystemImage = previewSystemImage
        self.referencedMaterials = referencedMaterials
        self.aiContextSource = aiContextSource
    }
}

struct AIChatRequest: Codable {
    let userMessage: String
    let selectedMode: ChatMode
    let context: WorkspaceContext
    let conversationHistory: [ChatMessage]
}

struct AIChatResponse: Codable {
    let assistantMessage: String
    let followUpQuestion: String?
    let suggestedMode: ChatMode?
}

extension WorkspaceContext {
    static let mockCloudContext = WorkspaceContext(
        workspaceTitle: "41001 Cloud Computing",
        sourceTitle: "Cloud Architecture Comparison Table",
        sourceType: "PDF",
        description: "Comparison of AWS, Azure, and GCP across cost, hybrid support, and managed services.",
        visualLabel: "Context: Cloud Architecture Comparison Table from your PDF",
        previewSystemImage: "point.3.connected.trianglepath.dotted"
    )
}

extension SuggestedPrompt {
    static let defaultPrompts: [SuggestedPrompt] = [
        SuggestedPrompt(
            title: "Compare Cost",
            message: "Can you compare the cost implications of AWS and Azure for a medium-scale app based on my notes?"
        ),
        SuggestedPrompt(
            title: "Summarize Table",
            message: "Please summarize the key takeaways from the cloud architecture comparison table."
        ),
        SuggestedPrompt(
            title: "Generate Flashcards",
            message: "Generate flashcards from the key differences in the comparison table."
        )
    ]
}
