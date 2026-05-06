//
//  Quiz.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Represents a quiz session
struct Quiz: Identifiable, Codable {
    let id: String
    var userId: String
    var pdfFileId: String
    var title: String
    var questions: [QuizQuestion]
    var createdAt: Date
    var timeLimit: Int? // in minutes
    var passingScore: Int // percentage
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case pdfFileId = "pdf_file_id"
        case title
        case questions
        case createdAt = "created_at"
        case timeLimit = "time_limit"
        case passingScore = "passing_score"
    }
}

/// Represents a single question in a quiz
struct QuizQuestion: Identifiable, Codable, Equatable {
    let id: String
    var questionText: String
    var options: [QuizOption]
    var correctOptionID: String
    var explanation: String
    var topic: String?

    enum CodingKeys: String, CodingKey {
        case id
        case questionText = "question_text"
        case options
        case correctOptionID = "correct_option_id"
        case correctAnswerIndex = "correct_answer_index"
        case explanation
        case topic
    }

    init(
        id: String = UUID().uuidString,
        questionText: String,
        options: [QuizOption],
        correctOptionID: String,
        explanation: String,
        topic: String? = nil
    ) {
        self.id = id
        self.questionText = questionText
        self.options = options
        self.correctOptionID = correctOptionID
        self.explanation = explanation
        self.topic = topic
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        questionText = try container.decode(String.self, forKey: .questionText)
        explanation = try container.decodeIfPresent(String.self, forKey: .explanation) ?? ""
        topic = try container.decodeIfPresent(String.self, forKey: .topic)

        if let decodedOptions = try? container.decode([QuizOption].self, forKey: .options) {
            options = decodedOptions
        } else {
            let legacyOptions = try container.decodeIfPresent([String].self, forKey: .options) ?? []
            options = legacyOptions.enumerated().map { index, text in
                QuizOption(label: String(UnicodeScalar(65 + index) ?? "A"), text: text)
            }
        }

        if let optionID = try container.decodeIfPresent(String.self, forKey: .correctOptionID) {
            correctOptionID = optionID
        } else if
            let correctIndex = try container.decodeIfPresent(Int.self, forKey: .correctAnswerIndex),
            options.indices.contains(correctIndex)
        {
            correctOptionID = options[correctIndex].id
        } else {
            correctOptionID = options.first?.id ?? ""
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(questionText, forKey: .questionText)
        try container.encode(options, forKey: .options)
        try container.encode(correctOptionID, forKey: .correctOptionID)
        try container.encode(explanation, forKey: .explanation)
        try container.encodeIfPresent(topic, forKey: .topic)

        if let correctIndex = options.firstIndex(where: { $0.id == correctOptionID }) {
            try container.encode(correctIndex, forKey: .correctAnswerIndex)
        }
    }
}

struct QuizOption: Identifiable, Codable, Equatable {
    let id: String
    let label: String
    let text: String

    init(id: String = UUID().uuidString, label: String, text: String) {
        self.id = id
        self.label = label
        self.text = text
    }
}

enum QuizAnswerState: Equatable {
    case unanswered
    case selected
    case correct
    case incorrect
}

struct QuizProgress: Equatable {
    let current: Int
    let total: Int

    var fractionCompleted: Double {
        guard total > 0 else { return 0 }
        return Double(current) / Double(total)
    }
}

/// Request to generate a quiz
struct QuizGenerationRequest: Codable {
    let pdfFileId: String
    let questionCount: Int
    let difficulty: String // "easy", "medium", "hard"
    let workspaceTitle: String?
    let preferredTopics: [String]

    init(
        pdfFileId: String,
        questionCount: Int,
        difficulty: String,
        workspaceTitle: String? = nil,
        preferredTopics: [String] = []
    ) {
        self.pdfFileId = pdfFileId
        self.questionCount = questionCount
        self.difficulty = difficulty
        self.workspaceTitle = workspaceTitle
        self.preferredTopics = preferredTopics
    }
    
    enum CodingKeys: String, CodingKey {
        case pdfFileId = "pdf_file_id"
        case questionCount = "question_count"
        case difficulty
        case workspaceTitle = "workspace_title"
        case preferredTopics = "preferred_topics"
    }
}

struct QuizGenerationResponse: Codable {
    let quizTitle: String
    let questions: [QuizQuestion]
}

/// Response after submitting quiz answers
struct QuizSubmissionResponse: Codable {
    let quizId: String
    let score: Int
    let totalQuestions: Int
    let correctAnswers: Int
    let passed: Bool
    let feedback: [QuestionFeedback]
    
    enum CodingKeys: String, CodingKey {
        case quizId = "quiz_id"
        case score
        case totalQuestions = "total_questions"
        case correctAnswers = "correct_answers"
        case passed
        case feedback
    }
}

/// Feedback for each question
struct QuestionFeedback: Codable {
    let questionId: String
    let isCorrect: Bool
    let userAnswer: String
    let explanation: String?
    
    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case isCorrect = "is_correct"
        case userAnswer = "user_answer"
        case explanation
    }
}
