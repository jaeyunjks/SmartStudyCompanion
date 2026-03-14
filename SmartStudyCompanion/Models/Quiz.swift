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
struct QuizQuestion: Identifiable, Codable {
    let id: String
    var questionText: String
    var questionType: QuestionType
    var options: [String]? // For multiple choice
    var correctAnswerIndex: Int? // For multiple choice
    var correctAnswer: String? // For short answer
    
    enum QuestionType: String, Codable {
        case multipleChoice = "multiple_choice"
        case shortAnswer = "short_answer"
        case trueOrFalse = "true_false"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case questionText = "question_text"
        case questionType = "question_type"
        case options
        case correctAnswerIndex = "correct_answer_index"
        case correctAnswer = "correct_answer"
    }
}

/// Request to generate a quiz
struct QuizGenerationRequest: Codable {
    let pdfFileId: String
    let questionCount: Int
    let difficulty: String // "easy", "medium", "hard"
    
    enum CodingKeys: String, CodingKey {
        case pdfFileId = "pdf_file_id"
        case questionCount = "question_count"
        case difficulty
    }
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
