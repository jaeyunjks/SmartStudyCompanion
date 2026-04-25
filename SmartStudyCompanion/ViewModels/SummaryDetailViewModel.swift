import Foundation
import SwiftUI
import Combine

@MainActor
final class SummaryDetailViewModel: ObservableObject {
    @Published var summary: StudySummary?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let workspaceId: String
    private let workspaceTitle: String
    private let workspaceContent: String
    private let apiService: APIService
    private let shouldAutoRequestOnLoad: Bool
    private var hasRequestedInitialSummary = false

    init(
        workspaceId: String,
        workspaceTitle: String,
        workspaceContent: String,
        apiService: APIService? = nil,
        initialSummary: StudySummary? = nil,
        shouldAutoRequestOnLoad: Bool = true
    ) {
        self.summary = initialSummary
        self.workspaceId = workspaceId
        self.workspaceTitle = workspaceTitle
        self.workspaceContent = workspaceContent
        self.apiService = apiService ?? APIService.shared
        self.shouldAutoRequestOnLoad = shouldAutoRequestOnLoad
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
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            self.summary = summary.simplifiedVersion()
        }
    }

    func regenerateSummary() {
        guard !isLoading else { return }
        let trimmedContent = workspaceContent.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedContent.isEmpty else {
            errorMessage = "Add some notes to this workspace before generating a summary."
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            defer { isLoading = false }

            do {
                let generated = try await apiService.generateWorkspaceSummary(
                    workspaceId: workspaceId,
                    workspaceTitle: workspaceTitle,
                    workspaceContent: trimmedContent
                )
                withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
                    summary = generated
                }
            } catch let error as NetworkError {
                errorMessage = userFriendlyErrorMessage(for: error)
            } catch {
                errorMessage = "Unable to generate a summary right now. Please try again."
            }
        }
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
        default:
            return "Unable to generate a summary right now. Please try again."
        }
    }
}
