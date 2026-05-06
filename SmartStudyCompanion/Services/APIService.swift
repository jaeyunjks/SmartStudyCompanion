//
//  APIService.swift
//  SmartStudyCompanion
//
//  Created by Yafie Farabi on 14/3/2026.
//

import Foundation

/// Main API service for communicating with the backend
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
    private let accessTokenDefaultsKey = "auth.token.access"
    private let refreshTokenDefaultsKey = "auth.token.refresh"
    private let defaultUploadWorkspaceTitle = "General Uploads"
    private static let iso8601FormatterWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    private static let iso8601Formatter: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()
    
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
    ///   - signUpRequest: The sign-up request payload
    /// - Returns: AuthResponse containing backend auth token
    func signUp(signUpRequest: SignUpRequest) async throws -> AuthResponse {
        let endpoint = "/auth/signup"
        let response: AuthResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: signUpRequest
        )
        
        // Store token after successful signup
        setTokens(accessToken: response.accessToken)
        
        return response
    }
    
    /// Log in an existing user
    /// - Parameters:
    ///   - email: User's email
    ///   - password: User's password
    /// - Returns: AuthResponse containing backend auth token
    func login(email: String, password: String) async throws -> AuthResponse {
        let endpoint = "/auth/login"
        let authRequest = AuthRequest(email: email, password: password)
        let response: AuthResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: authRequest
        )
        
        // Store token after successful login
        setTokens(accessToken: response.accessToken)
        
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
        
        setTokens(accessToken: response.accessToken)
        return response
    }
    
    /// Log out the current user
    func logout() {
        authToken = nil
        refreshToken = nil
        clearStoredTokens()
    }

    // MARK: - User Profile Methods

    /// Update the current user's profile details
    /// - Parameters:
    ///   - currentUsername: Existing username used by backend route
    ///   - fullname: Optional new full name
    ///   - username: Optional new username
    ///   - profileImage: Optional Base64-encoded profile image
    /// - Returns: Updated user profile
    func updateUserProfile(
        currentUsername: String,
        fullname: String?,
        username: String?,
        profileImage: String?
    ) async throws -> UserProfileResponse {
        let endpoint = "/user/\(currentUsername)"
        let payload = UpdateProfileRequest(
            fullname: fullname,
            username: username,
            profileImage: profileImage
        )
        let response: UserProfileResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: payload
        )
        return response
    }

    // MARK: - Workspace Methods

    func fetchWorkspaces() async throws -> [RemoteStudySpace] {
        guard let userId = currentUserIDFromAccessToken() else {
            throw NetworkError.unauthorized
        }
        let endpoint = "/study-space/user/\(userId)"
        let response: LegacyStudySpaceListResponse = try await performRequest(endpoint: endpoint, method: .get)
        return response.studySpaces
    }

    func createWorkspace(request: CreateWorkspaceRequest) async throws -> RemoteStudySpace {
        let endpoint = "/study-space/add"
        let payload = LegacyCreateStudySpaceRequest(
            title: request.title,
            color: request.workspaceColorHex,
            tag: request.category
        )
        let response: RemoteStudySpace = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: payload
        )
        return response
    }

    func updateWorkspace(id: UUID, request: UpdateWorkspaceRequest) async throws -> RemoteStudySpace {
        let endpoint = "/study-space/update"
        let payload = LegacyUpdateStudySpaceRequest(
            id: id.uuidString.lowercased(),
            title: request.title,
            color: request.workspaceColorHex,
            tag: request.category
        )
        let response: RemoteStudySpace = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: payload
        )
        return response
    }

    func deleteWorkspace(id: UUID) async throws {
        let endpoint = "/study-space/delete"
        struct DeleteStudySpaceRequest: Encodable {
            let id: String
        }
        struct EmptyResponse: Decodable {}
        _ = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: DeleteStudySpaceRequest(id: id.uuidString.lowercased())
        ) as EmptyResponse
    }
    
    // MARK: - PDF Upload Methods
    
    /// Upload a PDF or image file
    /// - Parameters:
    ///   - fileData: The file data to upload
    ///   - fileName: Name of the file
    ///   - fileType: Type of file ("pdf" or "image")
    /// - Returns: PDFFile object with upload details
    func uploadPDF(fileData: Data, fileName: String, fileType: String) async throws -> PDFFile {
        _ = fileType
        let studySpaceId = try await ensureDefaultUploadWorkspaceID()
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension((fileName as NSString).pathExtension.isEmpty ? "bin" : (fileName as NSString).pathExtension)

        try fileData.write(to: tempURL, options: .atomic)
        defer { try? FileManager.default.removeItem(at: tempURL) }

        let uploaded = try await uploadStudySpaceFile(
            fileURL: tempURL,
            studySpaceId: studySpaceId,
            fallbackWorkspaceTitle: defaultUploadWorkspaceTitle
        )
        return Self.mapLegacyUploadToPDFFile(uploaded)
    }
    
    /// Fetch list of user's uploaded PDFs
    /// - Returns: Array of PDFFile objects
    func fetchUserPDFs() async throws -> [PDFFile] {
        guard let workspaceId = try await resolveStudySpaceIdByTitle(defaultUploadWorkspaceTitle) else {
            return []
        }
        let files = try await fetchStudySpaceFiles(
            studySpaceId: workspaceId,
            fallbackWorkspaceTitle: defaultUploadWorkspaceTitle
        )
        return files.map(Self.mapLegacyFileItemToPDFFile(_:))
    }

    /// Upload one study-space file to legacy backend endpoint.
    func uploadStudySpaceFile(
        fileURL: URL,
        studySpaceId: String,
        fallbackWorkspaceTitle: String? = nil
    ) async throws -> LegacyUploadedStudySpaceFileResponse {
        let resolvedStudySpaceId = try await resolveStudySpaceIDIfNeeded(
            preferredId: studySpaceId,
            fallbackWorkspaceTitle: fallbackWorkspaceTitle
        )
        let endpoint = "/file/add-one"
        let boundary = UUID().uuidString
        var body = Data()

        let fileData = try Data(contentsOf: fileURL)
        let fileName = fileURL.lastPathComponent
        let mimeType = guessedMimeType(for: fileURL.pathExtension)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"studySpaceId\"\r\n\r\n".data(using: .utf8)!)
        body.append(resolvedStudySpaceId.data(using: .utf8)!)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        let url = baseURL.appendingPathComponent(endpoint)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        addAuthHeaders(to: &request)
        request.timeoutInterval = timeoutInterval

        let (data, response) = try await session.data(for: request)
        try validateResponse(response, data: data)

        return try decodeResponse(LegacyUploadedStudySpaceFileResponse.self, from: data)
    }

    /// Fetch backend files for a study space.
    func fetchStudySpaceFiles(studySpaceId: String, fallbackWorkspaceTitle: String? = nil) async throws -> [LegacyStudySpaceFileItem] {
        let resolvedStudySpaceId = try await resolveStudySpaceIDIfNeeded(
            preferredId: studySpaceId,
            fallbackWorkspaceTitle: fallbackWorkspaceTitle
        )
        let endpoint = "/file/study-space/\(resolvedStudySpaceId)"
        let response: LegacyStudySpaceFilesResponse = try await performRequest(endpoint: endpoint, method: .get)
        return response.files
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

    /// Generate AI summary for a workspace from aggregated note text
    func generateWorkspaceSummary(
        workspaceId: String,
        workspaceTitle: String,
        workspaceContent: String,
        preferredFileNames: [String] = []
    ) async throws -> StudySummary {
        _ = workspaceContent
        let resolvedWorkspaceId = try await resolveStudySpaceIDIfNeeded(
            preferredId: workspaceId,
            fallbackWorkspaceTitle: workspaceTitle
        )
        let backendFiles: [LegacyStudySpaceFileItem]
        do {
            backendFiles = try await fetchStudySpaceFiles(
                studySpaceId: resolvedWorkspaceId,
                fallbackWorkspaceTitle: workspaceTitle
            )
        } catch let error as NetworkError {
            switch error {
            case .notFound:
                backendFiles = []
            case .serverError(let statusCode, _ ) where statusCode >= 500:
                backendFiles = []
            default:
                throw error
            }
        }
        let selectedFiles = selectedBackendFiles(
            from: backendFiles,
            preferredFileNames: preferredFileNames
        )
        let fileIds = selectedFiles.map { $0.file.id }

        guard !fileIds.isEmpty else {
            throw NetworkError.serverError(
                statusCode: 400,
                message: "No backend files found for this workspace. Please upload at least one document first."
            )
        }

        let endpoint = "/ai/study-space/\(resolvedWorkspaceId)/summary"
        let request = SummarizeStudySpaceRequest(
            fileIds: fileIds,
            title: workspaceTitle
        )
        let response: LegacyStudySpaceSummaryEnvelope = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: request
        )

        let dto = WorkspaceAISummaryDTO(
            overview: response.summary.overview,
            keyConcepts: response.summary.keyConcepts,
            importantDetails: response.summary.importantDetails,
            reviewNext: Array(response.summary.importantDetails.prefix(5))
        )
        return dto.toStudySummary(workspaceTitle: workspaceTitle)
    }

    /// Chat with AI using a workspace-backed context on the backend.
    func chatWithStudySpace(
        workspaceId: String,
        workspaceTitle: String?,
        prompt: String,
        chatHistoryId: String?,
        title: String?
    ) async throws -> StudySpaceChatResponse {
        let resolvedWorkspaceId = try await resolveStudySpaceIDIfNeeded(
            preferredId: workspaceId,
            fallbackWorkspaceTitle: workspaceTitle
        )
        let endpoint = "/ai/study-space/\(resolvedWorkspaceId)/chat"
        let request = StudySpaceChatRequest(
            prompt: prompt,
            chatHistoryId: chatHistoryId,
            title: title
        )
        let response: StudySpaceChatResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: request
        )
        return response
    }

    /// Chat with AI using workspace title + context payload (does not require study-space id).
    func chatWithWorkspaceContext(
        workspaceTitle: String,
        prompt: String,
        workspaceContext: String?,
        conversationHistory: [WorkspaceContextChatHistoryMessage] = []
    ) async throws -> WorkspaceContextChatResponse {
        let endpoint = "/ai/workspace/chat"
        let request = WorkspaceContextChatRequest(
            workspaceTitle: workspaceTitle,
            prompt: prompt,
            workspaceContext: workspaceContext,
            conversationHistory: conversationHistory
        )
        let response: WorkspaceContextChatResponse = try await performRequest(
            endpoint: endpoint,
            method: .post,
            body: request
        )
        return response
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
        
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch let urlError as URLError {
            switch urlError.code {
            case .timedOut:
                throw NetworkError.timeout
            case .notConnectedToInternet, .networkConnectionLost:
                throw NetworkError.offline
            case .cannotConnectToHost, .cannotFindHost, .dnsLookupFailed:
                throw NetworkError.serverError(
                    statusCode: 0,
                    message: "Cannot connect to backend at \(baseURL.absoluteString)"
                )
            default:
                throw NetworkError.unknown(urlError)
            }
        } catch {
            throw NetworkError.unknown(error)
        }
        try validateResponse(response, data: data)
        
        return try decodeResponse(T.self, from: data)
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
    private func validateResponse(_ response: URLResponse, data: Data?) throws {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        let serverMessage = parseServerMessage(from: data)
        
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 401:
            logout()
            throw NetworkError.unauthorized
        case 404:
            throw NetworkError.notFound
        case 500...599:
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: serverMessage ?? "Server error"
            )
        default:
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: serverMessage ?? "HTTP \(httpResponse.statusCode)"
            )
        }
    }

    private func parseServerMessage(from data: Data?) -> String? {
        guard let data, !data.isEmpty else { return nil }

        if let messageObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let message = messageObject["message"] as? String {
                return message
            }
            if let messages = messageObject["message"] as? [String], !messages.isEmpty {
                return messages.joined(separator: ", ")
            }
            if let error = messageObject["error"] as? String {
                return error
            }
        }

        return nil
    }

    private func resolveStudySpaceIDIfNeeded(
        preferredId: String,
        fallbackWorkspaceTitle: String?
    ) async throws -> String {
        let trimmedPreferredId = preferredId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPreferredId.isEmpty else {
            if let fallbackWorkspaceTitle,
               let resolved = try await resolveStudySpaceIdByTitle(fallbackWorkspaceTitle) {
                return resolved
            }
            return trimmedPreferredId
        }

        guard let fallbackWorkspaceTitle else {
            return trimmedPreferredId
        }

        let filesEndpoint = "/file/study-space/\(trimmedPreferredId)"
        do {
            let _: LegacyStudySpaceFilesResponse = try await performRequest(endpoint: filesEndpoint, method: .get)
            return trimmedPreferredId
        } catch let error as NetworkError {
            switch error {
            case .notFound, .serverError:
                if let resolved = try await resolveStudySpaceIdByTitle(fallbackWorkspaceTitle) {
                    return resolved
                }
                if let created = try await createWorkspaceFallbackIfMissing(title: fallbackWorkspaceTitle) {
                    return created
                }
                return trimmedPreferredId
            default:
                return trimmedPreferredId
            }
        } catch {
            return trimmedPreferredId
        }
    }

    private func resolveStudySpaceIdByTitle(_ workspaceTitle: String) async throws -> String? {
        let normalizedTitle = normalizeWorkspaceTitle(workspaceTitle)
        guard !normalizedTitle.isEmpty else { return nil }

        let workspaces = try await fetchWorkspaces()
        if let exact = workspaces.first(where: {
            normalizeWorkspaceTitle($0.title) == normalizedTitle
        }) {
            return exact.id
        }

        return workspaces.first(where: {
            normalizeWorkspaceTitle($0.title).contains(normalizedTitle) ||
            normalizedTitle.contains(normalizeWorkspaceTitle($0.title))
        })?.id
    }

    private func ensureDefaultUploadWorkspaceID() async throws -> String {
        if let existingId = try await resolveStudySpaceIdByTitle(defaultUploadWorkspaceTitle) {
            return existingId
        }

        let created = try await createWorkspace(
            request: CreateWorkspaceRequest(
                title: defaultUploadWorkspaceTitle,
                description: "Auto-created workspace for generic uploads.",
                iconName: "doc",
                category: "General",
                status: "Active",
                workspaceColorHex: "#388767",
                documentCount: 0,
                noteCount: 0,
                aiOutputCount: 0,
                progress: 0
            )
        )
        return created.id
    }

    private func createWorkspaceFallbackIfMissing(title: String) async throws -> String? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let created = try await createWorkspace(
            request: CreateWorkspaceRequest(
                title: trimmed,
                description: "Auto-created to complete backend sync.",
                iconName: "book.closed",
                category: "General",
                status: "Active",
                workspaceColorHex: "#388767",
                documentCount: 0,
                noteCount: 0,
                aiOutputCount: 0,
                progress: 0
            )
        )
        return created.id
    }

    private func normalizeWorkspaceTitle(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func currentUserIDFromAccessToken() -> String? {
        lock.lock()
        let token = authToken
        lock.unlock()

        guard let token else { return nil }
        let segments = token.split(separator: ".")
        guard segments.count == 3 else { return nil }

        var payload = String(segments[1])
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        while payload.count % 4 != 0 {
            payload.append("=")
        }

        guard
            let data = Data(base64Encoded: payload),
            let object = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return nil
        }

        if let sub = object["sub"] as? String, !sub.isEmpty {
            return sub
        }
        if let userId = object["userId"] as? String, !userId.isEmpty {
            return userId
        }
        return nil
    }

    private func guessedMimeType(for fileExtension: String) -> String {
        switch fileExtension.lowercased() {
        case "pdf":
            return "application/pdf"
        case "txt":
            return "text/plain"
        case "md":
            return "text/markdown"
        case "csv":
            return "text/csv"
        case "json":
            return "application/json"
        case "xml":
            return "application/xml"
        case "png":
            return "image/png"
        case "jpg", "jpeg":
            return "image/jpeg"
        case "heic":
            return "image/heic"
        default:
            return "application/octet-stream"
        }
    }

    private func selectedBackendFiles(
        from files: [LegacyStudySpaceFileItem],
        preferredFileNames: [String]
    ) -> [LegacyStudySpaceFileItem] {
        let trimmedPreferred = preferredFileNames
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !trimmedPreferred.isEmpty else { return files }

        let preferredKeys = Set(trimmedPreferred.map(normalizedFileKey(_:)))
        let matched = files.filter { file in
            preferredKeys.contains(normalizedFileKey(file.file.name))
        }

        return matched.isEmpty ? files : matched
    }

    private func normalizedFileKey(_ value: String) -> String {
        let lastPath = URL(fileURLWithPath: value).lastPathComponent
        let withoutExtension = URL(fileURLWithPath: lastPath).deletingPathExtension().lastPathComponent
        return withoutExtension
            .lowercased()
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "-", with: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func mapLegacyFileRecordToPDFFile(_ file: LegacyFileRecord, url: String) -> PDFFile {
        PDFFile(
            id: file.id,
            userId: file.userId,
            fileName: file.name,
            fileSize: file.size,
            fileURL: url,
            uploadedAt: file.createdAt ?? Date(),
            processedAt: nil,
            status: .completed
        )
    }

    private static func mapLegacyUploadToPDFFile(_ upload: LegacyUploadedStudySpaceFileResponse) -> PDFFile {
        mapLegacyFileRecordToPDFFile(upload.file, url: upload.url)
    }

    private static func mapLegacyFileItemToPDFFile(_ item: LegacyStudySpaceFileItem) -> PDFFile {
        mapLegacyFileRecordToPDFFile(item.file, url: item.url)
    }
    
    /// Store authentication tokens
    private func setTokens(accessToken: String, refreshToken: String? = nil) {
        lock.lock()
        defer { lock.unlock() }
        self.authToken = accessToken
        self.refreshToken = refreshToken
        saveTokensToKeychain(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    /// Load stored tokens from secure storage
    private func loadStoredTokens() {
        lock.lock()
        defer { lock.unlock() }
        authToken = UserDefaults.standard.string(forKey: accessTokenDefaultsKey)
        refreshToken = UserDefaults.standard.string(forKey: refreshTokenDefaultsKey)
    }
    
    /// Save tokens to Keychain
    private func saveTokensToKeychain(accessToken: String, refreshToken: String?) {
        UserDefaults.standard.set(accessToken, forKey: accessTokenDefaultsKey)
        if let refreshToken {
            UserDefaults.standard.set(refreshToken, forKey: refreshTokenDefaultsKey)
        } else {
            UserDefaults.standard.removeObject(forKey: refreshTokenDefaultsKey)
        }
    }
    
    /// Clear stored tokens
    private func clearStoredTokens() {
        UserDefaults.standard.removeObject(forKey: accessTokenDefaultsKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenDefaultsKey)
    }

    private func decodeResponse<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)

            if let date = APIService.iso8601FormatterWithFractionalSeconds.date(from: rawValue) {
                return date
            }
            if let date = APIService.iso8601Formatter.date(from: rawValue) {
                return date
            }

            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Invalid ISO-8601 date: \(rawValue)"
            )
        }

        do {
            return try decoder.decode(type, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

private struct LegacyStudySpaceListResponse: Decodable {
    let isOwner: Bool?
    let studySpaces: [RemoteStudySpace]
}

private struct LegacyCreateStudySpaceRequest: Encodable {
    let title: String
    let color: String?
    let tag: String?
}

private struct LegacyUpdateStudySpaceRequest: Encodable {
    let id: String
    let title: String?
    let color: String?
    let tag: String?
}

struct LegacyUploadedStudySpaceFileResponse: Decodable {
    let file: LegacyFileRecord
    let url: String
}

struct LegacyStudySpaceFilesResponse: Decodable {
    let isOwner: Bool?
    let files: [LegacyStudySpaceFileItem]
}

struct LegacyStudySpaceFileItem: Decodable {
    let file: LegacyFileRecord
    let url: String
}

struct LegacyFileRecord: Decodable {
    let id: String
    let name: String
    let mimeType: String
    let size: Int
    let userId: String
    let spaceId: String
    let createdAt: Date?
}

private struct SummarizeStudySpaceRequest: Encodable {
    let fileIds: [String]
    let title: String?
}

private struct LegacyStudySpaceSummaryEnvelope: Decodable {
    let summary: LegacyStudySpaceSummaryContent

    private enum CodingKeys: String, CodingKey {
        case summary
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let directSummary = try? container.decode(LegacyStudySpaceSummaryContent.self, forKey: .summary) {
            summary = directSummary
            return
        }

        let wrappedSummary = try container.decode(LegacyStudySpaceSummaryRecord.self, forKey: .summary)
        summary = wrappedSummary.content
    }
}

private struct LegacyStudySpaceSummaryRecord: Decodable {
    let content: LegacyStudySpaceSummaryContent
}

private struct LegacyStudySpaceSummaryContent: Decodable {
    let overview: String
    let keyConcepts: [String]
    let importantDetails: [String]
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}
