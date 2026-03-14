//
//  NetworkError.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Custom error types for network operations
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidRequest
    case invalidResponse
    case decodingError(Error)
    case serverError(statusCode: Int, message: String)
    case noData
    case unauthorized
    case notFound
    case timeout
    case offline
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .invalidRequest:
            return "The request could not be created."
        case .invalidResponse:
            return "The server response was invalid."
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let statusCode, let message):
            return "Server error (\(statusCode)): \(message)"
        case .noData:
            return "No data received from server."
        case .unauthorized:
            return "Unauthorized. Please log in again."
        case .notFound:
            return "The requested resource was not found."
        case .timeout:
            return "The request timed out."
        case .offline:
            return "No internet connection."
        case .unknown(let error):
            return "An unknown error occurred: \(error.localizedDescription)"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .offline:
            return "Please check your internet connection and try again."
        case .unauthorized:
            return "Please log in with valid credentials."
        case .timeout:
            return "Please try again later."
        default:
            return "Please try again."
        }
    }
}
