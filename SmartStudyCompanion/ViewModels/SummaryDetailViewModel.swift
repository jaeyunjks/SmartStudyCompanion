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
    let isReadable: Bool
}

struct SummaryVersion: Identifiable, Codable {
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
    private let summaryHistoryStorageService: WorkspaceSummaryHistoryStorageService
    private let shouldAutoRequestOnLoad: Bool
    private let onSummarySaved: () -> Void
    private var hasRequestedInitialSummary = false

    init(
        workspaceId: String,
        workspaceTitle: String,
        workspaceContent: String,
        sourceItems: [SummarySourceItem] = [],
        apiService: APIService? = nil,
        summaryHistoryStorageService: WorkspaceSummaryHistoryStorageService = .shared,
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
        self.summaryHistoryStorageService = summaryHistoryStorageService
        self.shouldAutoRequestOnLoad = shouldAutoRequestOnLoad
        self.onSummarySaved = onSummarySaved

        self.selectedSourceIDs = Set(sourceItems.filter(\.isReadable).map(\.id))

        loadPersistedHistory()

        if versions.isEmpty, let initialSummary {
            let version = SummaryVersion(
                id: UUID(),
                name: "Initial Summary",
                createdAt: Date(),
                sourceIDs: selectedSourceIDs,
                summary: initialSummary
            )
            self.versions = [version]
            self.selectedVersionID = version.id
            self.summary = initialSummary
            persistHistory()
        }
    }

    func loadIfNeeded() {
        guard shouldAutoRequestOnLoad else { return }
        guard !hasRequestedInitialSummary else { return }
        hasRequestedInitialSummary = true
        if summary == nil, let selectedID = selectedVersionID {
            selectVersion(selectedID)
        }
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
        persistHistory()
    }

    func deleteVersion(_ id: UUID) {
        versions.removeAll { $0.id == id }
        if selectedVersionID == id {
            selectedVersionID = versions.first?.id
            summary = versions.first?.summary
        }
        persistHistory()
    }

    func selectVersion(_ id: UUID) {
        guard let version = versions.first(where: { $0.id == id }) else { return }
        selectedVersionID = id
        selectedSourceIDs = version.sourceIDs
        summary = version.summary
        persistHistory()
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

    var shouldPromptForSourceSelection: Bool {
        summary == nil && versions.isEmpty
    }

    func selectAllSources() {
        selectedSourceIDs = Set(availableSources.filter(\.isReadable).map(\.id))
    }

    func clearAllSources() {
        selectedSourceIDs.removeAll()
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
                let contextualized = applySourceContext(to: normalized)

                withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
                    summary = contextualized
                    appendVersion(summary: contextualized, fallbackName: mode == .regenerate ? "Regenerated" : "Summary")
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
        persistHistory()
    }

    private func applySourceContext(to summary: StudySummary) -> StudySummary {
        let selected = availableSources.filter { selectedSourceIDs.contains($0.id) && $0.isReadable }
        guard !selected.isEmpty else { return summary }

        let notesCount = selected.filter { $0.kind == .note }.count
        let filesCount = selected.filter { $0.kind == .file }.count
        let photosCount = selected.filter { $0.kind == .photo }.count

        let sourceLabel: String
        if filesCount > 0 && notesCount == 0 && photosCount == 0 {
            sourceLabel = filesCount == 1 ? "this document" : "these documents"
        } else if photosCount > 0 && notesCount == 0 && filesCount == 0 {
            sourceLabel = photosCount == 1 ? "this picture" : "these pictures"
        } else if notesCount > 0 && filesCount == 0 && photosCount == 0 {
            sourceLabel = notesCount == 1 ? "this note" : "these notes"
        } else {
            sourceLabel = "the combined materials"
        }

        let names = selected.prefix(3).map(\.name).joined(separator: ", ")
        let sourceSuffix = selected.count > 3 ? ", and \(selected.count - 3) more" : ""

        let contextualTitle = summary.title.contains(workspaceTitle)
            ? "\(workspaceTitle) Summary from \(sourceLabel.capitalized)"
            : "\(summary.title) • \(sourceLabel.capitalized)"

        let contextualOverview = "This summary is generated from \(sourceLabel) (\(names)\(sourceSuffix)).\n\n\(summary.overview)"

        return StudySummary(
            id: summary.id,
            category: summary.category,
            estimatedReadTime: summary.estimatedReadTime,
            title: contextualTitle,
            overview: contextualOverview,
            mainIdeas: summary.mainIdeas,
            keyConcepts: summary.keyConcepts,
            importantPoints: summary.importantPoints,
            examples: summary.examples,
            quickTakeaways: summary.quickTakeaways,
            suggestedNextActions: summary.suggestedNextActions,
            isBookmarked: summary.isBookmarked
        )
    }

    private func buildContentFromSelectedSources() -> String {
        let selected = availableSources.filter {
            selectedSourceIDs.contains($0.id) &&
            $0.isReadable &&
            !$0.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
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

    private func loadPersistedHistory() {
        guard let workspaceUUID = UUID(uuidString: workspaceId) else { return }
        do {
            let snapshot = try summaryHistoryStorageService.loadHistory(workspaceID: workspaceUUID)
            versions = snapshot.versions.sorted { $0.createdAt > $1.createdAt }
            selectedVersionID = snapshot.selectedVersionID

            if let selectedID = selectedVersionID,
               let selectedVersion = versions.first(where: { $0.id == selectedID }) {
                summary = selectedVersion.summary
                selectedSourceIDs = selectedVersion.sourceIDs
            } else if let latest = versions.first {
                summary = latest.summary
                selectedVersionID = latest.id
                selectedSourceIDs = latest.sourceIDs
            }
        } catch {
            versions = []
            selectedVersionID = nil
        }
    }

    private func persistHistory() {
        guard let workspaceUUID = UUID(uuidString: workspaceId) else { return }
        let snapshot = WorkspaceSummaryHistorySnapshot(
            versions: versions.sorted { $0.createdAt > $1.createdAt },
            selectedVersionID: selectedVersionID
        )

        do {
            try summaryHistoryStorageService.saveHistory(snapshot, workspaceID: workspaceUUID)
        } catch {
            // Best effort persistence.
        }
    }
}
