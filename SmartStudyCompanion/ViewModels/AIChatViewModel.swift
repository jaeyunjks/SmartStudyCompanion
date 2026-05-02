import Foundation
import Combine
import SwiftUI

@MainActor
final class AIChatViewModel: ObservableObject {
    @Published var conversations: [ChatConversation]
    @Published var activeConversationID: UUID
    @Published var messages: [ChatMessage]
    @Published var inputText: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedContext: WorkspaceContext
    @Published var selectedMode: ChatMode
    @Published var suggestedPrompts: [SuggestedPrompt]

    private let service: AIChatServiceProtocol
    private var hasPreparedLanding = false

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
        let initialConversation = ChatConversation(
            title: "New conversation",
            messages: []
        )
        self.conversations = [initialConversation]
        self.activeConversationID = initialConversation.id
        self.messages = initialConversation.messages
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

    func ensureCleanLandingIfNeeded() {
        guard !hasPreparedLanding else { return }
        hasPreparedLanding = true

        if let emptyConversation = conversations.first(where: { $0.messages.isEmpty }) {
            selectConversation(emptyConversation.id)
            return
        }

        startNewConversation()
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

    func startNewConversation() {
        let conversation = ChatConversation(
            title: "New conversation",
            messages: []
        )
        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            conversations.insert(conversation, at: 0)
            activeConversationID = conversation.id
            messages = []
            errorMessage = nil
        }
    }

    func selectConversation(_ id: UUID) {
        guard let conversation = conversations.first(where: { $0.id == id }) else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            activeConversationID = conversation.id
            messages = conversation.messages
            errorMessage = nil
        }
    }

    func renameConversation(_ id: UUID, title: String) {
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].title = normalized
        conversations[index].updatedAt = Date()
    }

    func deleteConversation(_ id: UUID) {
        if conversations.count <= 1 {
            guard let firstID = conversations.first?.id else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                conversations[0].title = "New conversation"
                conversations[0].messages = []
                conversations[0].updatedAt = Date()
                activeConversationID = firstID
                messages = []
            }
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            conversations.removeAll { $0.id == id }
            if activeConversationID == id, let first = conversations.first {
                activeConversationID = first.id
                messages = first.messages
            }
        }
    }

    func regenerateFromAssistantMessage(_ messageID: UUID) {
        guard let assistantIndex = messages.firstIndex(where: { $0.id == messageID }) else { return }
        guard assistantIndex > 0 else { return }
        guard let userMessage = messages[..<assistantIndex].last(where: { $0.role == .user }) else { return }
        sendMessage(userMessage.text)
    }

    private func sendMessage(_ text: String) {
        guard !isLoading else { return }

        errorMessage = nil
        let userMessage = ChatMessage(role: .user, text: text)
        messages.append(userMessage)
        updateActiveConversationTitleIfNeeded(using: text)
        syncActiveConversation()

        let typingID = UUID()
        messages.append(ChatMessage(id: typingID, role: .assistant, text: "", isTyping: true))
        syncActiveConversation()
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
                syncActiveConversation()
                isLoading = false
            } catch {
                removeTypingMessage(with: typingID)
                errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong while sending your message."
                syncActiveConversation()
                isLoading = false
            }
        }
    }

    private func removeTypingMessage(with id: UUID) {
        messages.removeAll { $0.id == id }
        syncActiveConversation()
    }

    private func syncActiveConversation() {
        guard let index = conversations.firstIndex(where: { $0.id == activeConversationID }) else { return }
        conversations[index].messages = messages
        conversations[index].updatedAt = Date()
    }

    private func updateActiveConversationTitleIfNeeded(using text: String) {
        guard let index = conversations.firstIndex(where: { $0.id == activeConversationID }) else { return }
        let currentTitle = conversations[index].title
        guard currentTitle == "New conversation" || currentTitle.isEmpty else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        conversations[index].title = String(trimmed.prefix(36))
    }
}
