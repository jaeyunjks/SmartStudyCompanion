import Foundation
import Combine

@MainActor
final class AIChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage]
    @Published var inputText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedContext: WorkspaceContext
    @Published var selectedMode: ChatMode
    @Published var suggestedPrompts: [SuggestedPrompt]

    private let service: AIChatServiceProtocol

    init(
        service: AIChatServiceProtocol,
        selectedContext: WorkspaceContext,
        selectedMode: ChatMode,
        suggestedPrompts: [SuggestedPrompt]
    ) {
        self.service = service
        self.selectedContext = selectedContext
        self.selectedMode = selectedMode
        self.suggestedPrompts = suggestedPrompts
        self.messages = Self.initialMessages
    }

    convenience init() {
        self.init(
            service: MockAIChatService(),
            selectedContext: .mockCloudContext,
            selectedMode: .guide,
            suggestedPrompts: SuggestedPrompt.defaultPrompts
        )
    }

    convenience init(selectedContext: WorkspaceContext) {
        self.init(
            service: MockAIChatService(),
            selectedContext: selectedContext,
            selectedMode: .guide,
            suggestedPrompts: SuggestedPrompt.defaultPrompts
        )
    }

    func sendCurrentMessage() {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        inputText = ""
        sendMessage(text)
    }

    func sendSuggestedPrompt(_ prompt: SuggestedPrompt) {
        sendMessage(prompt.message)
    }

    private func sendMessage(_ text: String) {
        guard !isLoading else { return }

        errorMessage = nil
        let userMessage = ChatMessage(role: .user, text: text)
        messages.append(userMessage)

        let typingID = UUID()
        messages.append(ChatMessage(id: typingID, role: .assistant, text: "", isTyping: true))
        isLoading = true

        Task {
            do {
                let response = try await service.sendMessage(
                    message: text,
                    context: selectedContext,
                    mode: selectedMode,
                    conversationHistory: messages.filter { !$0.isTyping }
                )

                removeTypingMessage(with: typingID)

                let finalText: String
                if let followUp = response.followUpQuestion {
                    finalText = "\(response.assistantMessage)\n\n\(followUp)"
                } else {
                    finalText = response.assistantMessage
                }

                if let suggestedMode = response.suggestedMode {
                    selectedMode = suggestedMode
                }

                messages.append(ChatMessage(role: .assistant, text: finalText))
                isLoading = false
            } catch {
                removeTypingMessage(with: typingID)
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong while sending your message."
                isLoading = false
            }
        }
    }

    private func removeTypingMessage(with id: UUID) {
        messages.removeAll { $0.id == id }
    }
}

private extension AIChatViewModel {
    static let initialMessages: [ChatMessage] = [
        ChatMessage(
            role: .user,
            text: "Can you explain the main differences between AWS and Azure as discussed in my notes?",
            timestamp: Date().addingTimeInterval(-240)
        ),
        ChatMessage(
            role: .assistant,
            text: "Great starting point. Before I give a full comparison, what differences do you already remember from your notes?\n\nHint: focus on service breadth, enterprise integration, and cost structure.",
            timestamp: Date().addingTimeInterval(-180)
        )
    ]
}
