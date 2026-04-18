import Foundation
import SwiftUI
import Combine

@MainActor
final class FlashcardSessionViewModel: ObservableObject {
    @Published var flashcards: [FlashcardItem] = []
    @Published var filteredFlashcards: [FlashcardItem] = []
    @Published var sessionCards: [FlashcardItem] = []
    @Published var currentIndex: Int = 0
    @Published var isRevealed = false
    @Published var selectedDifficulty: FlashcardDifficulty = .showAll
    @Published var knownCardIDs: Set<String> = []
    @Published var reviewAgainCardIDs: Set<String> = []
    @Published var sessionState: FlashcardSessionState = .loading

    private var reviewRepeatCount: [String: Int] = [:]
    private let service: FlashcardSessionServiceProtocol
    private let requestBase: FlashcardGenerationRequest

    init(
        service: FlashcardSessionServiceProtocol,
        requestBase: FlashcardGenerationRequest
    ) {
        self.service = service
        self.requestBase = requestBase
    }

    convenience init(workspaceTitle: String) {
        self.init(
            service: MockFlashcardService(),
            requestBase: FlashcardGenerationRequest(
                pdfFileId: "mock_pdf",
                count: 10,
                difficulty: .medium,
                workspaceTitle: workspaceTitle
            )
        )
    }

    var currentCard: FlashcardItem? {
        guard sessionCards.indices.contains(currentIndex) else { return nil }
        return sessionCards[currentIndex]
    }

    var progressText: String {
        "\(min(currentIndex + 1, max(sessionCards.count, 1))) of \(max(sessionCards.count, 1))"
    }

    var progressValue: Double {
        guard !sessionCards.isEmpty else { return 0 }
        return Double(min(currentIndex + 1, sessionCards.count)) / Double(sessionCards.count)
    }

    var moduleLabel: String {
        currentCard?.module ?? requestBase.workspaceTitle ?? "Study Module"
    }

    var canReviewActions: Bool {
        isRevealed && currentCard != nil && sessionState.isActive
    }

    var completionSummary: FlashcardSessionSummary {
        FlashcardSessionSummary(
            totalCards: Set(flashcards.map(\.id)).count,
            knownCards: knownCardIDs.count,
            reviewAgainCards: reviewAgainCardIDs.count
        )
    }

    func loadSession() async {
        sessionState = .loading

        do {
            let request = FlashcardGenerationRequest(
                pdfFileId: requestBase.pdfFileId,
                count: requestBase.count,
                difficulty: selectedDifficulty.apiDifficulty,
                workspaceTitle: requestBase.workspaceTitle,
                sourceDocumentIDs: requestBase.sourceDocumentIDs,
                preferredTopics: selectedDifficulty == .showAll ? ["show_all"] : requestBase.preferredTopics
            )

            let response = try await service.generateSessionFlashcards(request: request)

            flashcards = response.flashcards
            applyDifficultyFilter(resetProgress: true)
            sessionState = .active
        } catch {
            sessionState = .error((error as? LocalizedError)?.errorDescription ?? "Failed to load flashcards.")
        }
    }

    func selectDifficulty(_ difficulty: FlashcardDifficulty) {
        selectedDifficulty = difficulty
        applyDifficultyFilter(resetProgress: true)
    }

    func toggleReveal() {
        guard currentCard != nil else { return }
        withAnimation(.spring(response: 0.38, dampingFraction: 0.86)) {
            isRevealed.toggle()
        }
    }

    func markKnown() {
        guard let card = currentCard, canReviewActions else { return }
        knownCardIDs.insert(card.id)
        reviewAgainCardIDs.remove(card.id)
        moveNext()
    }

    func markReviewAgain() {
        guard let card = currentCard, canReviewActions else { return }
        reviewAgainCardIDs.insert(card.id)

        if reviewRepeatCount[card.id, default: 0] < 1 {
            sessionCards.append(card)
            reviewRepeatCount[card.id, default: 0] += 1
        }

        moveNext()
    }

    func restartSession() {
        knownCardIDs.removeAll()
        reviewAgainCardIDs.removeAll()
        reviewRepeatCount.removeAll()
        currentIndex = 0
        isRevealed = false
        sessionCards = filteredFlashcards
        sessionState = sessionCards.isEmpty ? .error("No flashcards available.") : .active
    }

    private func applyDifficultyFilter(resetProgress: Bool) {
        filteredFlashcards = flashcards.filter { card in
            switch selectedDifficulty {
            case .showAll: return true
            case .beginner, .intermediate, .advanced:
                return card.difficulty == selectedDifficulty
            }
        }

        sessionCards = filteredFlashcards.isEmpty ? flashcards : filteredFlashcards

        if resetProgress {
            currentIndex = 0
            isRevealed = false
            reviewRepeatCount.removeAll()
        }

        if sessionCards.isEmpty {
            sessionState = .error("No cards found for this difficulty.")
        } else {
            sessionState = .active
        }
    }

    private func moveNext() {
        if currentIndex + 1 < sessionCards.count {
            withAnimation(.easeInOut(duration: 0.25)) {
                currentIndex += 1
                isRevealed = false
            }
        } else {
            sessionState = .completed(completionSummary)
        }
    }
}

private extension FlashcardSessionState {
    var isActive: Bool {
        if case .active = self { return true }
        return false
    }
}
