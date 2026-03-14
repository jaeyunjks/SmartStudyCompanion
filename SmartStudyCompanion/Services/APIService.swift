//
//  APIService.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Main API service for communicating with the FastAPI backend
class APIService {
    // MARK: - Singleton
    static let shared = APIService()
    
    // MARK: - Properties
    private let session: URLSession
    private let baseURL: URL
    private var authToken: String?
    private var refreshToken: String?
    
    // MARK: - Configuration
    private let timeoutInterval: TimeInterval = 30.0
    private let lock = NSLock()
    
    init(
        baseURL: URL = URL(string: "http://localhost:8000/api")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
        
        // Load tokens from secure storage if available
        loadStoredTokens()
    }
    
    // MARK: - Authentication Methods
    
    /// Sign up a new user
    /// - Parameters:
    ///   - signUpRequest: The sign-up request containing email, password, username, and full name
    /// - Returns: AuthResponse containing user info and authentication tokens
    func signUp(signUpRequest: SignUpRequest) async throws -> AuthResponse {
        let endpoint = "/auth/signup"
        let response: AuthResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: signUpRequest
        )
        
        // Store tokens after successful signup
        setTokens(accessToken: response.token, refreshToken: response.refreshToken)
        
        return response
    }
    
    /// Log in an existing user
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    /// - Returns: AuthResponse containing user info and authentication tokens
    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "/auth/login"
        let authRequest = AuthRequest(email: email, password: password)
        let response: AuthResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: authRequest
        )
        
        // Store tokens after successful login
        setTokens(accessToken: response.token, refreshToken: response.refreshToken)
        
        return response
    }
    
    /// Refresh the authentication token
    /// - Returns: New AuthResponse with updated tokens
    func refreshAuthToken() async throws -> AuthResponse {
        guard let token = refreshToken else {
            throw NetworkError.unauthorized
        }
        
        let endpoint = "/auth/refresh"
        let tokenRequest = ["refresh_token": token]
        let response: AuthResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: tokenRequest
        )
        
        setTokens(accessToken: response.token, refreshToken: response.refreshToken)
        return response
    }
    
    /// Log out the current user
    func logout() {
        authToken = nil
        refreshToken = nil
        clearStoredTokens()
    }
    
    // MARK: - PDF Upload Methods
    
    /// Upload a PDF or image file
    /// - Parameters:
    ///   - fileData: The file data to upload
    ///   - fileName: Name of the file
    ///   - fileType: Type of file ("pdf" or "image")
    /// - Returns: PDFFile object with upload details
    func uploadPDF(fileData: Data, fileName: String, fileType: String) async throws -> PDFFile {
        let endpoint = "/files/upload"
        
        // Create multipart form data request
        let boundary = UUID().uuidString
        var body = Data()
        
        // Add file data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: application/octet-stream\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)
        
        // Add file type
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file_type\"\r\n\r\n".data(using: .utf8)!)
        body.append(fileType.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        // Create request
        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        addAuthHeaders(to: &request)
        request.timeoutInterval = timeoutInterval
        
        let (data, response) = try await session.data(for: request)
        try validateResponse(response)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(PDFFile.self, from: data)
    }
    
    /// Fetch list of user's uploaded PDFs
    /// - Returns: Array of PDFFile objects
    func fetchUserPDFs() async throws -> [PDFFile] {
        let endpoint = "/files/list"
        let files: [PDFFile] = try await performRequest(endpoint: endpoint, method: .get)
        return files
    }
    
    // MARK: - Summary Methods
    
    /// Fetch AI-generated summary for a PDF
    /// - Parameters:
    ///   - pdfFileId: ID of the PDF file
    ///   - summaryLength: Desired length of summary
    /// - Returns: Summary object
    func fetchSummary(pdfFileId: String, summaryLength: SummaryRequest.SummaryLength) async throws -> Summary {
        let endpoint = "/summaries/generate"
        let summaryRequest = SummaryRequest(pdfFileId: pdfFileId, summaryLength: summaryLength)
        let summary: Summary = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: summaryRequest
        )
        return summary
    }
    
    /// Get existing summary for a PDF
    /// - Parameters:
    ///   - pdfFileId: ID of the PDF file
    /// - Returns: Summary object or nil if not yet generated
    func getSummary(for pdfFileId: String) async throws -> Summary? {
        let endpoint = "/summaries/\(pdfFileId)"
        do {
            let summary: Summary = try await performRequest(endpoint: endpoint, method: .get)
            return summary
        } catch NetworkError.notFound {
            return nil
        }
    }
    
    // MARK: - Flashcard Methods
    
    /// Generate flashcards from a PDF
    /// - Parameters:
    ///   - pdfFileId: ID of the PDF file
    ///   - count: Number of flashcards to generate
    ///   - difficulty: Difficulty level
    /// - Returns: Array of generated flashcards
    func generateFlashcards(pdfFileId: String, count: Int, difficulty: Flashcard.Difficulty) async throws -> [Flashcard] {
        let endpoint = "/flashcards/generate"
        let flashcardRequest = FlashcardGenerationRequest(pdfFileId: pdfFileId, count: count, difficulty: difficulty)
        let flashcards: [Flashcard] = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: flashcardRequest
        )
        return flashcards
    }
    
    /// Fetch all flashcards for a PDF
    /// - Parameters:
    ///   - pdfFileId: ID of the PDF file
    /// - Returns: Array of flashcards
    func fetchFlashcards(for pdfFileId: String) async throws -> [Flashcard] {
        let endpoint = "/flashcards/\(pdfFileId)"
        let flashcards: [Flashcard] = try await performRequest(endpoint: endpoint, method: .get)
        return flashcards
    }
    
    /// Update a flashcard
    /// - Parameters:
    ///   - flashcardId: ID of the flashcard
    ///   - updatedFlashcard: Updated flashcard object
    /// - Returns: Updated flashcard
    func updateFlashcard(id: String, updatedFlashcard: Flashcard) async throws -> Flashcard {
        let endpoint = "/flashcards/\(id)"
        let flashcard: Flashcard = try await performRequest(
            endpoint: endpoint,
            method: .put,
            body: updatedFlashcard
        )
        return flashcard
    }
    
    // MARK: - Quiz Methods
    
    /// Generate a quiz for a PDF
    /// - Parameters:
    ///   - pdfFileId: ID of the PDF file
    ///   - questionCount: Number of questions
    ///   - difficulty: Difficulty level
    /// - Returns: Quiz object with questions
    func generateQuiz(pdfFileId: String, questionCount: Int, difficulty: String) async throws -> Quiz {
        let endpoint = "/quizzes/generate"
        let quizRequest = QuizGenerationRequest(pdfFileId: pdfFileId, questionCount: questionCount, difficulty: difficulty)
        let quiz: Quiz = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: quizRequest
        )
        return quiz
    }
    
    /// Fetch quiz by ID
    /// - Parameters:
    ///   - quizId: ID of the quiz
    /// - Returns: Quiz object
    func fetchQuiz(id: String) async throws -> Quiz {
        let endpoint = "/quizzes/\(id)"
        let quiz: Quiz = try await performRequest(endpoint: endpoint, method: .get)
        return quiz
    }
    
    /// Submit quiz answers and get results
    /// - Parameters:
    ///   - quizId: ID of the quiz
    ///   - answers: Dictionary of question ID to user answer
    /// - Returns: QuizSubmissionResponse with scores and feedback
    func submitQuizAnswers(quizId: String, answers: [String: String]) async throws -> QuizSubmissionResponse {
        let endpoint = "/quizzes/\(quizId)/submit"
        let submissionRequest = ["answers": answers]
        let response: QuizSubmissionResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: submissionRequest
        )
        return response
    }
    
    // MARK: - Progress Methods
    
    /// Update user progress
    /// - Parameters:
    ///   - pdfFileId: ID of the PDF file
    ///   - timeSpent: Time spent in minutes
    ///   - cardsReviewed: Number of cards reviewed
    ///   - correctAnswers: Number of correct answers
    /// - Returns: Updated Progress object
    func updateProgress(pdfFileId: String, timeSpent: Int, cardsReviewed: Int, correctAnswers: Int) async throws -> Progress {
        let endpoint = "/progress/update"
        let progressRequest = ProgressUpdateRequest(pdfFileId: pdfFileId, timeSpent: timeSpent, cardsReviewed: cardsReviewed, correctAnswers: correctAnswers)
        let progress: Progress = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: progressRequest
        )
        return progress
    }
    
    /// Fetch user progress for a PDF
    /// - Parameters:
    ///   - pdfFileId: ID of the PDF file
    /// - Returns: Progress object
    func fetchProgress(for pdfFileId: String) async throws -> Progress {
        let endpoint = "/progress/\(pdfFileId)"
        let progress: Progress = try await performRequest(endpoint: endpoint, method: .get)
        return progress
    }
    
    /// Fetch daily statistics
    /// - Parameters:
    ///   - days: Number of past days to fetch (default: 7)
    /// - Returns: Array of daily statistics
    func fetchDailyStatistics(days: Int = 7) async throws -> [DailyStatistics] {
        let endpoint = "/progress/statistics?days=\(days)"
        let statistics: [DailyStatistics] = try await performRequest(endpoint: endpoint, method: .get)
        return statistics
    }
    
    // MARK: - Private Helper Methods
    
    /// Generic request method using async/await
    private func performRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        body: Encodable? = nil
    ) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint)
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.timeoutInterval = timeoutInterval
        
        // Add headers
        addAuthHeaders(to: &urlRequest)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add body if present
        if let body = body {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            urlRequest.httpBody = try encoder.encode(body)
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        let (data, response) = try await session.data(for: urlRequest)
        try validateResponse(response)
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Add authorization headers to request
    private func addAuthHeaders(to request: inout URLRequest) {
        lock.lock()
        let token = authToken
        lock.unlock()
        
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
    }
    
    /// Validate HTTP response
    private func validateResponse(_ response: URLResponse) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            logout()
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: "Server error")
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: "HTTP \(httpResponse.statusCode)")
        }
    }
    
    /// Store authentication tokens
    private func setTokens(accessToken: String, refreshToken: String) {
        lock.lock()
        defer { lock.unlock() }
        self.authToken = accessToken
        self.refreshToken = refreshToken
        saveTokensToKeychain(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    /// Load stored tokens from secure storage
    private func loadStoredTokens() {
        // TODO: Implement Keychain access for secure token storage
        // For now, tokens are stored in memory only
    }
    
    /// Save tokens to Keychain
    private func saveTokensToKeychain(accessToken: String, refreshToken: String) {
        // TODO: Implement Keychain save for secure token storage
    }
    
    /// Clear stored tokens
    private func clearStoredTokens() {
        // TODO: Implement Keychain delete for secure token removal
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
