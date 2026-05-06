import Foundation

protocol FlashcardSessionServiceProtocol {
    func generateSessionFlashcards(request: FlashcardGenerationRequest) async throws -> FlashcardGenerationResponse
}

enum FlashcardSessionServiceError: LocalizedError {
    case noFlashcards

    var errorDescription: String? {
        switch self {
        case .noFlashcards:
            return "No flashcards available for this module."
        }
    }
}
