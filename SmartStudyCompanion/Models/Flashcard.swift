//
//  Flashcard.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Represents a single flashcard for studying
struct Flashcard: Identifiable, Codable {
    let id: String
    var userId: String
    var pdfFileId: String
    var setId: String?
    var front: String // Question or term
    var back: String // Answer or definition
    var difficulty: Difficulty
    var createdAt: Date
    var lastReviewedAt: Date?
    var reviewCount: Int
    var correctCount: Int
    
    enum Difficulty: String, Codable {
        case easy = "easy"
        case medium = "medium"
        case hard = "hard"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case pdfFileId = "pdf_file_id"
        case setId = "set_id"
        case front
        case back
        case difficulty
        case createdAt = "created_at"
        case lastReviewedAt = "last_reviewed_at"
        case reviewCount = "review_count"
        case correctCount = "correct_count"
    }
}

/// Request to generate flashcards
struct FlashcardGenerationRequest: Codable {
    let pdfFileId: String
    let count: Int // Number of flashcards to generate
    let difficulty: Flashcard.Difficulty
    
    enum CodingKeys: String, CodingKey {
        case pdfFileId = "pdf_file_id"
        case count
        case difficulty
    }
}

/// Flashcard set for organizing flashcards
struct FlashcardSet: Identifiable, Codable {
    let id: String
    var userId: String
    var name: String
    var description: String?
    var cardCount: Int
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case cardCount = "card_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
