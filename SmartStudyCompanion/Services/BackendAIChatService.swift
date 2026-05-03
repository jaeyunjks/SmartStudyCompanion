import Foundation

struct BackendAIChatService: AIChatServiceProtocol {
    private let apiService: APIService

    init(apiService: APIService = .shared) {
        self.apiService = apiService
    }

    func sendMessage(
        message: String,
        context: WorkspaceContext,
        mode: ChatMode,
        chatHistoryId: String?,
        conversationTitle: String?,
        conversationHistory: [ChatMessage]
    ) async throws -> AIChatResponse {
        let trimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw AIChatServiceError.emptyMessage
        }

        let lastAssistantMessage = conversationHistory.last(where: { $0.role == .assistant })?.text
        let modeInstruction = modeInstructionText(for: mode)
        let composedPrompt = [modeInstruction, trimmed]
            .compactMap { $0 }
            .joined(separator: "\n\n")

        let contextText = buildWorkspaceContextText(from: context)

        let response = try await apiService.chatWithWorkspaceContext(
            workspaceTitle: context.workspaceTitle,
            prompt: composedPrompt,
            workspaceContext: contextText
        )

        let finalText = response.assistantMessage
            .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        guard !finalText.isEmpty else {
            throw AIChatServiceError.unavailable
        }

        return AIChatResponse(
            assistantMessage: finalText,
            followUpQuestion: lastAssistantMessage == finalText ? "Would you like a more detailed breakdown?" : nil,
            suggestedMode: response.suggestedMode,
            chatHistoryId: chatHistoryId
        )
    }

    private func modeInstructionText(for mode: ChatMode) -> String? {
        switch mode {
        case .hint:
            return "Answer with concise hints first. Avoid giving the full answer immediately."
        case .guide:
            return "Answer as a tutor with clear, structured guidance."
        case .challenge:
            return "Ask a short challenge question after your explanation."
        case .explain:
            return "Explain in simple terms with one concrete example."
        }
    }

    private func buildWorkspaceContextText(from context: WorkspaceContext) -> String {
        let selectedMaterials = context.referencedMaterials
            .filter(\.isSelected)
            .map { "\($0.type.displayName): \($0.title)" }

        let materialsBlock = selectedMaterials.isEmpty
            ? "No selected materials."
            : selectedMaterials.joined(separator: "\n")

        return """
        Source title: \(context.sourceTitle)
        Source type: \(context.sourceType)
        Description: \(context.description)

        Selected materials:
        \(materialsBlock)
        """
    }
}
