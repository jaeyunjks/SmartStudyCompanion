import Foundation

struct BackendAIChatService: AIChatServiceProtocol {
    func sendMessage(
        message: String,
        context: WorkspaceContext,
        mode: ChatMode,
        conversationHistory: [ChatMessage]
    ) async throws -> AIChatResponse {
        // Real implementation placeholder.
        // Architecture requirement: iOS app -> your backend -> OpenAI API.
        // Do not ship API keys in the iOS app. Keep keys and model routing on backend only.
        // Backend can start with gpt-5-nano for lowest cost testing, and later switch
        // to gpt-5.4-nano or gpt-5.4-mini without changing the SwiftUI view layer.

        throw AIChatServiceError.unavailable
    }
}
