//
//  User.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Represents a user in the Smart Study Companion app
struct User: Identifiable, Codable {
    let id: String
    var email: String
    var username: String
    var fullName: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case username
        case fullName = "full_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// Request model for user authentication
struct AuthRequest: Codable {
    let email: String
    let password: String
}

/// Response model for authentication
struct AuthResponse: Codable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

/// User registration request
struct SignUpRequest: Codable {
    let email: String
    let password: String
    let confirmPassword: String
    let username: String
    let fullname: String
}
