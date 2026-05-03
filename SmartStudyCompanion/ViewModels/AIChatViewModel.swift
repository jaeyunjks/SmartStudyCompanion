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
    @Published var mentionSuggestions: [ReferencedMaterial] = []

    private let service: AIChatServiceProtocol
    private let chatHistoryStorageService: WorkspaceChatHistoryStorageService
    private var hasPreparedLanding = false

    init(
        service: AIChatServiceProtocol,
        selectedContext: WorkspaceContext,
        selectedMode: ChatMode,
        suggestedPrompts: [SuggestedPrompt],
        chatHistoryStorageService: WorkspaceChatHistoryStorageService = .shared
    ) {
        self.service = service
        self.selectedContext = selectedContext
        self.selectedMode = selectedMode
        self.suggestedPrompts = suggestedPrompts
        self.chatHistoryStorageService = chatHistoryStorageService
        let initialConversation = ChatConversation(
            title: "New conversation",
            messages: []
        )
        self.conversations = [initialConversation]
        self.activeConversationID = initialConversation.id
        self.messages = initialConversation.messages
        self.mentionSuggestions = selectedContext.referencedMaterials.sorted {
            $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
        }
        loadPersistedHistory()
    }

    convenience init() {
        self.init(
            service: BackendAIChatService(),
            selectedContext: .mockCloudContext,
            selectedMode: .guide,
            suggestedPrompts: SuggestedPrompt.defaultPrompts
        )
    }

    convenience init(selectedContext: WorkspaceContext) {
        self.init(
            service: BackendAIChatService(),
            selectedContext: selectedContext,
            selectedMode: .guide,
            suggestedPrompts: SuggestedPrompt.defaultPrompts
        )
    }

    func ensureCleanLandingIfNeeded() {
        guard !hasPreparedLanding else { return }
        hasPreparedLanding = true

        if !conversations.isEmpty {
            if conversations.contains(where: { $0.id == activeConversationID }) {
                selectConversation(activeConversationID)
            } else if let first = conversations.first {
                selectConversation(first.id)
            }
            return
        }

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
        persistHistory()
    }

    func selectConversation(_ id: UUID) {
        guard let conversation = conversations.first(where: { $0.id == id }) else { return }
        withAnimation(.easeInOut(duration: 0.22)) {
            activeConversationID = conversation.id
            messages = conversation.messages
            errorMessage = nil
        }
        persistHistory()
    }

    func renameConversation(_ id: UUID, title: String) {
        let normalized = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return }
        guard let index = conversations.firstIndex(where: { $0.id == id }) else { return }
        conversations[index].title = normalized
        conversations[index].updatedAt = Date()
        persistHistory()
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
            persistHistory()
            return
        }

        withAnimation(.easeInOut(duration: 0.2)) {
            conversations.removeAll { $0.id == id }
            if activeConversationID == id, let first = conversations.first {
                activeConversationID = first.id
                messages = first.messages
            }
        }
        persistHistory()
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
                    chatHistoryId: currentConversationBackendHistoryID(),
                    conversationTitle: currentConversationTitle(),
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
                if let chatHistoryId = response.chatHistoryId {
                    setCurrentConversationBackendHistoryID(chatHistoryId)
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
        persistHistory()
    }

    private func updateActiveConversationTitleIfNeeded(using text: String) {
        guard let index = conversations.firstIndex(where: { $0.id == activeConversationID }) else { return }
        let currentTitle = conversations[index].title
        guard currentTitle == "New conversation" || currentTitle.isEmpty else { return }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        conversations[index].title = String(trimmed.prefix(36))
        persistHistory()
    }

    private func currentConversationBackendHistoryID() -> String? {
        conversations.first(where: { $0.id == activeConversationID })?.backendChatHistoryId
    }

    private func currentConversationTitle() -> String? {
        let title = conversations.first(where: { $0.id == activeConversationID })?.title ?? ""
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed == "New conversation" ? nil : trimmed
    }

    private func setCurrentConversationBackendHistoryID(_ id: String) {
        guard let index = conversations.firstIndex(where: { $0.id == activeConversationID }) else { return }
        conversations[index].backendChatHistoryId = id
        persistHistory()
    }

    func insertMention(_ material: ReferencedMaterial) {
        let token = "@\(material.title.replacingOccurrences(of: " ", with: "_")) "
        if inputText.isEmpty {
            inputText = token
        } else {
            inputText += token
        }
    }

    func filteredMentionSuggestions() -> [ReferencedMaterial] {
        guard let token = currentMentionToken() else { return [] }
        if token.isEmpty { return mentionSuggestions.prefix(6).map { $0 } }
        return mentionSuggestions.filter {
            $0.title.localizedCaseInsensitiveContains(token)
        }.prefix(6).map { $0 }
    }

    private func currentMentionToken() -> String? {
        guard let atRange = inputText.range(of: "@", options: .backwards) else { return nil }
        let suffix = inputText[atRange.upperBound...]
        if suffix.contains(" ") { return nil }
        return suffix.replacingOccurrences(of: "_", with: " ")
    }

    private func loadPersistedHistory() {
        guard let workspaceID = selectedContext.aiContextSource?.workspaceID else { return }
        guard let snapshot = try? chatHistoryStorageService.loadHistory(workspaceID: workspaceID) else { return }
        guard !snapshot.conversations.isEmpty else { return }
        conversations = snapshot.conversations.sorted { $0.updatedAt > $1.updatedAt }
        activeConversationID = snapshot.activeConversationID ?? conversations[0].id
        messages = conversations.first(where: { $0.id == activeConversationID })?.messages ?? []
    }

    private func persistHistory() {
        guard let workspaceID = selectedContext.aiContextSource?.workspaceID else { return }
        let snapshot = WorkspaceChatHistorySnapshot(
            conversations: conversations.sorted { $0.updatedAt > $1.updatedAt },
            activeConversationID: activeConversationID
        )
        try? chatHistoryStorageService.saveHistory(snapshot, workspaceID: workspaceID)
    }
}
