//
//  PDFFile.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Represents an uploaded PDF or document
struct PDFFile: Identifiable, Codable {
    let id: String
    var userId: String
    var fileName: String
    var fileSize: Int
    var fileURL: String
    var uploadedAt: Date
    var processedAt: Date?
    var status: ProcessingStatus
    
    enum ProcessingStatus: String, Codable {
        case pending = "pending"
        case processing = "processing"
        case completed = "completed"
        case failed = "failed"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case fileName = "file_name"
        case fileSize = "file_size"
        case fileURL = "file_url"
        case uploadedAt = "uploaded_at"
        case processedAt = "processed_at"
        case status
    }
}

/// Upload request for PDF files
struct PDFUploadRequest {
    let fileName: String
    let fileData: Data
    let fileType: String // "pdf" or "image"
}
