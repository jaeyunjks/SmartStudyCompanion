import Foundation
import SwiftUI
import Combine

enum SummarySourceKind: String, Codable, Hashable, CaseIterable {
    case note
    case file
    case photo
}

struct SummarySourceItem: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let kind: SummarySourceKind
    let content: String
}

struct SummaryVersion: Identifiable {
    let id: UUID
    var name: String
    let createdAt: Date
    let sourceIDs: Set<UUID>
    let summary: StudySummary
}

enum SummaryGenerationMode {
    case normal
    case regenerate
}

@MainActor
final class SummaryDetailViewModel: ObservableObject {
    @Published var summary: StudySummary?
    @Published var versions: [SummaryVersion] = []
    @Published var selectedVersionID: UUID?
    @Published var selectedSourceIDs: Set<UUID> = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    let availableSources: [SummarySourceItem]

    private let workspaceId: String
    private let workspaceTitle: String
    private let workspaceContent: String
    private let apiService: APIService
    private let shouldAutoRequestOnLoad: Bool
    private let onSummarySaved: () -> Void
    private var hasRequestedInitialSummary = false

    init(
        workspaceId: String,
        workspaceTitle: String,
        workspaceContent: String,
        sourceItems: [SummarySourceItem] = [],
        apiService: APIService? = nil,
        initialSummary: StudySummary? = nil,
        shouldAutoRequestOnLoad: Bool = true,
        onSummarySaved: @escaping () -> Void = {}
    ) {
        self.summary = initialSummary
        self.workspaceId = workspaceId
        self.workspaceTitle = workspaceTitle
        self.workspaceContent = workspaceContent
        self.availableSources = sourceItems
        self.apiService = apiService ?? APIService.shared
        self.shouldAutoRequestOnLoad = shouldAutoRequestOnLoad
        self.onSummarySaved = onSummarySaved

        self.selectedSourceIDs = Set(sourceItems.map(\.id))

        if let initialSummary {
            let version = SummaryVersion(
                id: UUID(),
                name: "Initial Summary",
                createdAt: Date(),
                sourceIDs: selectedSourceIDs,
                summary: initialSummary
            )
            self.versions = [version]
            self.selectedVersionID = version.id
        }
    }

    func loadIfNeeded() {
        guard shouldAutoRequestOnLoad else { return }
        guard !hasRequestedInitialSummary else { return }
        hasRequestedInitialSummary = true
        regenerateSummary()
    }

    func simplifySummary() {
        guard !isLoading, let summary else { return }
        errorMessage = nil

        let simplified = summary.simplifiedVersion()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            self.summary = simplified
            appendVersion(summary: simplified, fallbackName: "Simplified")
        }
    }

    func regenerateSummary() {
        requestSummary(mode: .regenerate)
    }

    func generateSummaryFromSelectedSources() {
        requestSummary(mode: .normal)
    }

    func renameVersion(_ id: UUID, to newName: String) {
        let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, let index = versions.firstIndex(where: { $0.id == id }) else { return }
        versions[index].name = String(trimmed.prefix(60))
    }

    func deleteVersion(_ id: UUID) {
        versions.removeAll { $0.id == id }
        if selectedVersionID == id {
            selectedVersionID = versions.first?.id
            summary = versions.first?.summary
        }
    }

    func selectVersion(_ id: UUID) {
        guard let version = versions.first(where: { $0.id == id }) else { return }
        selectedVersionID = id
        selectedSourceIDs = version.sourceIDs
        summary = version.summary
    }

    func toggleBookmark() {
        guard var summary else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            summary.isBookmarked.toggle()
            self.summary = summary
        }
    }

    func shareSummaryText() -> String {
        summary?.shareText ?? "No summary available yet."
    }

    private func requestSummary(mode: SummaryGenerationMode) {
        guard !isLoading else { return }

        let selectedContent = buildContentFromSelectedSources().trimmingCharacters(in: .whitespacesAndNewlines)
        let contentToSend = selectedContent.isEmpty ? workspaceContent.trimmingCharacters(in: .whitespacesAndNewlines) : selectedContent

        guard !contentToSend.isEmpty else {
            errorMessage = "Select at least one source with content before generating summary."
            return
        }

        isLoading = true
        errorMessage = nil

        let promptPrefix: String
        switch mode {
        case .normal:
            promptPrefix = ""
        case .regenerate:
            promptPrefix = "Rewrite the summary from a different perspective while preserving core meaning.\n\n"
        }

        Task {
            defer { isLoading = false }

            do {
                let generated = try await apiService.generateWorkspaceSummary(
                    workspaceId: workspaceId,
                    workspaceTitle: workspaceTitle,
                    workspaceContent: promptPrefix + contentToSend
                )

                let normalized = normalize(generated)

                withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
                    summary = normalized
                    appendVersion(summary: normalized, fallbackName: mode == .regenerate ? "Regenerated" : "Summary")
                }

                do {
                    try await apiService.saveWorkspaceSummaryOutput(
                        workspaceId: workspaceId,
                        title: normalized.title,
                        content: normalized.shareText
                    )
                } catch {
                    // Non-blocking: UI summary is already generated.
                }

                if let workspaceUUID = UUID(uuidString: workspaceId) {
                    StudySpaceStore.shared.incrementAIOutputCount(for: workspaceUUID)
                }
                onSummarySaved()
            } catch let error as NetworkError {
                errorMessage = userFriendlyErrorMessage(for: error)
            } catch {
                errorMessage = "Unable to generate a summary right now. Please try again."
            }
        }
    }

    private func normalize(_ summary: StudySummary) -> StudySummary {
        StudySummary(
            id: summary.id,
            category: summary.category,
            estimatedReadTime: summary.estimatedReadTime,
            title: summary.title,
            overview: summary.overview,
            mainIdeas: Array(summary.mainIdeas.prefix(6)),
            keyConcepts: Array(summary.keyConcepts.prefix(8)),
            importantPoints: Array(summary.importantPoints.prefix(8)),
            examples: Array(summary.examples.prefix(3)),
            quickTakeaways: Array(summary.quickTakeaways.prefix(5)),
            suggestedNextActions: Array(summary.suggestedNextActions.prefix(6)),
            isBookmarked: summary.isBookmarked
        )
    }

    private func appendVersion(summary: StudySummary, fallbackName: String) {
        let name = "\(fallbackName) \(versions.count + 1)"
        let version = SummaryVersion(
            id: UUID(),
            name: name,
            createdAt: Date(),
            sourceIDs: selectedSourceIDs,
            summary: summary
        )
        versions.insert(version, at: 0)
        selectedVersionID = version.id
    }

    private func buildContentFromSelectedSources() -> String {
        let selected = availableSources.filter { selectedSourceIDs.contains($0.id) }
        guard !selected.isEmpty else { return "" }

        let chunks = selected.map {
            "[\($0.kind.rawValue.capitalized)] \($0.name)\n\($0.content)"
        }

        return """
        Workspace: \(workspaceTitle)

        Selected sources:
        \(chunks.joined(separator: "\n\n"))
        """
    }

    private func userFriendlyErrorMessage(for error: NetworkError) -> String {
        switch error {
        case .offline:
            return "No internet connection. Please check your connection and try again."
        case .timeout:
            return "The request timed out. Please try again."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .decodingError:
            return "We received an unexpected summary response. Please try again."
        case .serverError(let statusCode, let message):
            if statusCode == 429 {
                return "Your OpenAI API quota is exceeded or rate-limited. Please check billing/usage, then try again."
            }
            if message.localizedCaseInsensitiveContains("insufficient_quota") {
                return "Your OpenAI API quota is exceeded. Please check billing/usage and try again."
            }
            return "Unable to generate summary: \(message)"
        default:
            return "Unable to generate a summary right now. Please try again."
        }
    }
}
