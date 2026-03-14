//
//  Progress.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Represents user study progress and statistics
struct Progress: Identifiable, Codable {
    let id: String
    var userId: String
    var pdfFileId: String
    var totalTimeSpent: Int // in minutes
    var cardsStudied: Int
    var cardsRemaining: Int
    var quizzesCompleted: Int
    var averageScore: Double // percentage
    var lastStudyDate: Date?
    var studyStreak: Int // consecutive days
    var totalCards: Int
    var masteredCards: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case pdfFileId = "pdf_file_id"
        case totalTimeSpent = "total_time_spent"
        case cardsStudied = "cards_studied"
        case cardsRemaining = "cards_remaining"
        case quizzesCompleted = "quizzes_completed"
        case averageScore = "average_score"
        case lastStudyDate = "last_study_date"
        case studyStreak = "study_streak"
        case totalCards = "total_cards"
        case masteredCards = "mastered_cards"
    }
}

/// Request to update progress
struct ProgressUpdateRequest: Codable {
    let pdfFileId: String
    let timeSpent: Int // minutes
    let cardsReviewed: Int
    let correctAnswers: Int
    
    enum CodingKeys: String, CodingKey {
        case pdfFileId = "pdf_file_id"
        case timeSpent = "time_spent"
        case cardsReviewed = "cards_reviewed"
        case correctAnswers = "correct_answers"
    }
}

/// Daily study statistics
struct DailyStatistics: Identifiable, Codable {
    let id: String
    var userId: String
    var date: Date
    var totalTimeSpent: Int // in minutes
    var cardsReviewed: Int
    var quizzesCompleted: Int
    var averageScore: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case date
        case totalTimeSpent = "total_time_spent"
        case cardsReviewed = "cards_reviewed"
        case quizzesCompleted = "quizzes_completed"
        case averageScore = "average_score"
    }
}
