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

        let contextText = buildWorkspaceContextText(from: context, prompt: trimmed)
        let historyPayload = conversationHistory
            .filter { !$0.isTyping }
            .dropLast()
            .suffix(8)
            .map {
                WorkspaceContextChatHistoryMessage(
                    role: $0.role == .user ? "user" : "assistant",
                    content: capped($0.text, limit: 1_200)
                )
            }

        let response = try await apiService.chatWithWorkspaceContext(
            workspaceTitle: context.workspaceTitle,
            prompt: composedPrompt,
            workspaceContext: contextText,
            conversationHistory: Array(historyPayload)
        )

        let finalText = response.assistantMessage
            .trimmingCharacters(in: .whitespacesAndNewlines)

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

    private func buildWorkspaceContextText(from context: WorkspaceContext, prompt: String) -> String {
        let selectedMaterials = context.referencedMaterials
            .filter(\.isSelected)
            .map { "\($0.type.displayName): \($0.title)" }

        let materialsBlock = selectedMaterials.isEmpty
            ? "No selected materials."
            : selectedMaterials.joined(separator: "\n")

        let mentionedSourceIDs = mentionedSources(in: prompt, from: context.sourceContents)
        let orderedSources = orderedSourceContents(context.sourceContents, mentionedSourceIDs: mentionedSourceIDs)
        let sourceContentBlock = buildSourceContentBlock(from: orderedSources, mentionedSourceIDs: mentionedSourceIDs)

        return """
        Source title: \(context.sourceTitle)
        Source type: \(context.sourceType)
        Description: \(context.description)

        Selected materials:
        \(materialsBlock)

        Readable workspace source content:
        \(sourceContentBlock)
        """
    }

    private func orderedSourceContents(
        _ sources: [WorkspaceContextSourceContent],
        mentionedSourceIDs: Set<UUID>
    ) -> [WorkspaceContextSourceContent] {
        let mentioned = sources.filter { mentionedSourceIDs.contains($0.id) }
        let selected = sources.filter { !mentionedSourceIDs.contains($0.id) && $0.isSelected }
        let remaining = sources.filter { !mentionedSourceIDs.contains($0.id) && !$0.isSelected }
        return mentioned + selected + remaining
    }

    private func buildSourceContentBlock(
        from sources: [WorkspaceContextSourceContent],
        mentionedSourceIDs: Set<UUID>
    ) -> String {
        guard !sources.isEmpty else {
            return "No readable notes, files, or photos were found in this workspace yet."
        }

        var remainingBudget = 18_000
        var blocks: [String] = []

        for source in sources {
            guard remainingBudget > 0 else { break }
            let trimmed = source.content.trimmingCharacters(in: .whitespacesAndNewlines)
            let mentionLabel = mentionedSourceIDs.contains(source.id) ? "Mentioned with @" : "Workspace source"
            let readableText = trimmed.isEmpty
                ? "[No readable text has been extracted from this source yet.]"
                : capped(trimmed, limit: min(4_000, remainingBudget))
            let block = """
            --- \(mentionLabel) ---
            Title: \(source.title)
            Type: \(source.sourceType)
            Content:
            \(readableText)
            """
            blocks.append(block)
            remainingBudget -= block.count
        }

        return blocks.joined(separator: "\n\n")
    }

    private func mentionedSources(in prompt: String, from sources: [WorkspaceContextSourceContent]) -> Set<UUID> {
        let tokens = prompt
            .split(whereSeparator: \.isWhitespace)
            .compactMap { rawToken -> String? in
                guard rawToken.hasPrefix("@") else { return nil }
                let cleaned = rawToken
                    .dropFirst()
                    .trimmingCharacters(in: CharacterSet(charactersIn: ".,!?;:()[]{}\"'"))
                    .replacingOccurrences(of: "_", with: " ")
                return cleaned.isEmpty ? nil : normalizedMentionKey(cleaned)
            }

        guard !tokens.isEmpty else { return [] }

        return Set(sources.compactMap { source in
            let titleKey = normalizedMentionKey(source.title)
            return tokens.contains(where: { token in
                titleKey.contains(token) || token.contains(titleKey)
            }) ? source.id : nil
        })
    }

    private func normalizedMentionKey(_ value: String) -> String {
        value
            .lowercased()
            .filter { $0.isLetter || $0.isNumber }
    }

    private func capped(_ text: String, limit: Int) -> String {
        guard text.count > limit else { return text }
        return String(text.prefix(limit)) + "\n[Content truncated for chat context.]"
    }
}
