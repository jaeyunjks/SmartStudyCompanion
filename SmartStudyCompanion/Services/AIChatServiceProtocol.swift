import Foundation

protocol AIChatServiceProtocol {
    func sendMessage(
        message: String,
        context: WorkspaceContext,
        mode: ChatMode,
        chatHistoryId: String?,
        conversationTitle: String?,
        conversationHistory: [ChatMessage]
    ) async throws -> AIChatResponse
}

enum AIChatServiceError: LocalizedError {
    case emptyMessage
    case unavailable
    case workspaceNotFound

    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            return "Please enter a message first."
        case .unavailable:
            return "The AI assistant is unavailable right now. Please try again."
        case .workspaceNotFound:
            return "This workspace is not synced with backend yet. Please refresh workspaces and try again."
        }
    }
}
