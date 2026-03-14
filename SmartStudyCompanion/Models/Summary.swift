//
//  Summary.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Represents an AI-generated summary of a document
struct Summary: Identifiable, Codable {
    let id: String
    var userId: String
    var pdfFileId: String
    var title: String
    var content: String
    var keyPoints: [String]
    var generatedAt: Date
    var wordCount: Int
    var readingTime: Int // in minutes
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case pdfFileId = "pdf_file_id"
        case title
        case content
        case keyPoints = "key_points"
        case generatedAt = "generated_at"
        case wordCount = "word_count"
        case readingTime = "reading_time"
    }
}

/// Request to generate a summary
struct SummaryRequest: Codable {
    let pdfFileId: String
    let summaryLength: SummaryLength // "short", "medium", "long"
    
    enum SummaryLength: String, Codable {
        case short = "short"
        case medium = "medium"
        case long = "long"
    }
    
    enum CodingKeys: String, CodingKey {
        case pdfFileId = "pdf_file_id"
        case summaryLength = "summary_length"
    }
}
