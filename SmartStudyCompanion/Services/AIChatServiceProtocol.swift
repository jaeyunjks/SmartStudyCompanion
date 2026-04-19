import Foundation

protocol AIChatServiceProtocol {
    func sendMessage(
        message: String,
        context: WorkspaceContext,
        mode: ChatMode,
        conversationHistory: [ChatMessage]
    ) async throws -> AIChatResponse
}

enum AIChatServiceError: LocalizedError {
    case emptyMessage
    case unavailable

    var errorDescription: String? {
        switch self {
        case .emptyMessage:
            return "Please enter a message first."
        case .unavailable:
            return "The AI assistant is unavailable right now. Please try again."
        }
    }
}
