import Foundation
import SwiftUI
import Combine

@MainActor
final class SummaryDetailViewModel: ObservableObject {
    @Published var summary: StudySummary
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let summaries: [StudySummary]
    private var currentIndex: Int

    init(summary: StudySummary, summaries: [StudySummary]) {
        self.summary = summary
        self.summaries = summaries
        self.currentIndex = summaries.firstIndex(where: { $0.id == summary.id }) ?? 0
    }

    convenience init(summary: StudySummary) {
        self.init(summary: summary, summaries: StudySummary.mockSummaries)
    }

    func simplifySummary() {
        guard !isLoading else { return }
        errorMessage = nil
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            summary = summary.simplifiedVersion()
        }
    }

    func regenerateSummary() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        Task {
            try? await Task.sleep(nanoseconds: 1_100_000_000)

            let nextIndex = summaries.isEmpty ? 0 : (currentIndex + 1) % summaries.count
            currentIndex = nextIndex

            if summaries.indices.contains(nextIndex) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.88)) {
                    summary = summaries[nextIndex]
                }
            } else {
                errorMessage = "Unable to generate a new summary right now."
            }

            isLoading = false
        }
    }

    func toggleBookmark() {
        withAnimation(.easeInOut(duration: 0.2)) {
            summary.isBookmarked.toggle()
        }
    }

    func shareSummaryText() -> String {
        summary.shareText
    }
}
