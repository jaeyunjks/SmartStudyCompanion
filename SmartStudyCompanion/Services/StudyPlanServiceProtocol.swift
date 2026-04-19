import Foundation

protocol StudyPlanServiceProtocol {
    func generateStudyPlan(request: StudyPlanGenerationRequest) async throws -> StudyPlanGenerationResponse
}

enum StudyPlanServiceError: LocalizedError {
    case unavailable

    var errorDescription: String? {
        switch self {
        case .unavailable:
            return "Unable to load study plan at the moment."
        }
    }
}
