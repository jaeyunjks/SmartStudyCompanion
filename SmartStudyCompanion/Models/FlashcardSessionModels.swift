import Foundation

enum FlashcardType: String, Codable, CaseIterable {
    case definition = "Definition"
    case concept = "Concept"
    case comparison = "Comparison"

    var iconName: String {
        switch self {
        case .definition: return "book.closed"
        case .concept: return "lightbulb"
        case .comparison: return "arrow.left.arrow.right"
        }
    }
}

enum FlashcardDifficulty: String, Codable, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case showAll = "Show All"

    var id: String { rawValue }

    var apiDifficulty: Flashcard.Difficulty {
        switch self {
        case .beginner: return .easy
        case .intermediate: return .medium
        case .advanced: return .hard
        case .showAll: return .medium
        }
    }
}

struct FlashcardItem: Identifiable, Codable, Equatable {
    let id: String
    let type: FlashcardType
    let frontText: String
    let backText: String
    let difficulty: FlashcardDifficulty
    let module: String

    init(
        id: String = UUID().uuidString,
        type: FlashcardType,
        frontText: String,
        backText: String,
        difficulty: FlashcardDifficulty,
        module: String
    ) {
        self.id = id
        self.type = type
        self.frontText = frontText
        self.backText = backText
        self.difficulty = difficulty
        self.module = module
    }
}

enum FlashcardSessionState: Equatable {
    case loading
    case active
    case completed(FlashcardSessionSummary)
    case error(String)
}

struct FlashcardSessionSummary: Equatable {
    let totalCards: Int
    let knownCards: Int
    let reviewAgainCards: Int
}
