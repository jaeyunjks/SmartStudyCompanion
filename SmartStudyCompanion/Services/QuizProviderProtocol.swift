import Foundation

protocol QuizProviderProtocol {
    func generateQuiz(request: QuizGenerationRequest) async throws -> QuizGenerationResponse
}

enum QuizProviderError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Unable to load quiz questions right now."
        }
    }
}
