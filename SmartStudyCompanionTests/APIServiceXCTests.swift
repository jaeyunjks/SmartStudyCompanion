import XCTest
@testable import SmartStudyCompanion

final class APIServiceXCTests: XCTestCase {
    private var session: URLSession!
    private var service: APIService!
    private let baseURL = URL(string: "http://localhost:8000/api")!

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: configuration)
        service = APIService(baseURL: baseURL, session: session)
    }

    override func tearDown() {
        MockURLProtocol.reset()
        service = nil
        session = nil
        super.tearDown()
    }

    func testLoginSuccessDecodesUserAndStoresBearerTokenForNextRequest() async throws {
        let loginData = try makeJSON([
            "user": sampleUser(),
            "token": "access-token-123",
            "refresh_token": "refresh-token-123"
        ])

        MockURLProtocol.requestHandler = { [baseURL] request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, baseURL.appendingPathComponent("/auth/login").path)

            let body = try XCTUnwrap(request.httpBody)
            let payload = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(payload["email"] as? String, "student@example.com")
            XCTAssertEqual(payload["password"] as? String, "Password123")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                loginData
            )
        }

        let authResponse = try await service.login(email: "student@example.com", password: "Password123")
        XCTAssertEqual(authResponse.user.email, "student@example.com")
        XCTAssertEqual(authResponse.user.fullName, "Thanh Lam Nguyen")
        XCTAssertEqual(authResponse.token, "access-token-123")

        MockURLProtocol.requestHandler = { [baseURL] request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, baseURL.appendingPathComponent("/files/list").path)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer access-token-123")

            let filesData = try makeJSON([samplePDFFile()])
            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                filesData
            )
        }

        let files = try await service.fetchUserPDFs()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files.first?.fileName, "lecture-notes.pdf")
    }

    func testLoginUnauthorizedThrowsUnauthorizedError() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 401, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }

        do {
            _ = try await service.login(email: "wrong@example.com", password: "wrong")
            XCTFail("Expected login to throw NetworkError.unauthorized")
        } catch let error as NetworkError {
            XCTAssertEqual(error.localizedDescription, NetworkError.unauthorized.localizedDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testGetSummaryReturnsNilWhenServerResponds404() async throws {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 404, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }

        let summary = try await service.getSummary(for: "missing-pdf-id")
        XCTAssertNil(summary)
    }

    func testFetchSummaryDecodesISO8601DatesAndKeyPoints() async throws {
        let summaryData = try makeJSON(sampleSummary())

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let body = try XCTUnwrap(request.httpBody)
            let payload = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(payload["pdf_file_id"] as? String, "pdf-1")
            XCTAssertEqual(payload["summary_length"] as? String, "medium")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                summaryData
            )
        }

        let summary = try await service.fetchSummary(pdfFileId: "pdf-1", summaryLength: .medium)
        XCTAssertEqual(summary.id, "summary-1")
        XCTAssertEqual(summary.keyPoints.count, 3)
        XCTAssertEqual(summary.wordCount, 180)
        XCTAssertEqual(summary.readingTime, 3)
    }

    func testUploadPDFBuildsMultipartRequestAndDecodesUploadedFile() async throws {
        let expectedResponseData = try makeJSON(samplePDFFile())
        let fileData = Data("Sample PDF bytes".utf8)

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.contains("multipart/form-data; boundary=") == true)

            let bodyString = String(data: try XCTUnwrap(request.httpBody), encoding: .utf8)
            XCTAssertNotNil(bodyString)
            XCTAssertTrue(bodyString?.contains("name=\"file\"; filename=\"lecture-notes.pdf\"") == true)
            XCTAssertTrue(bodyString?.contains("name=\"file_type\"") == true)
            XCTAssertTrue(bodyString?.contains("pdf") == true)

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                expectedResponseData
            )
        }

        let uploadedFile = try await service.uploadPDF(fileData: fileData, fileName: "lecture-notes.pdf", fileType: "pdf")
        XCTAssertEqual(uploadedFile.id, "pdf-1")
        XCTAssertEqual(uploadedFile.fileName, "lecture-notes.pdf")
        XCTAssertEqual(uploadedFile.status, .completed)
    }

    func testGenerateFlashcardsPostsCorrectRequestBodyAndDecodesArray() async throws {
        let responseData = try makeJSON([sampleFlashcard(id: "card-1"), sampleFlashcard(id: "card-2")])

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let body = try XCTUnwrap(request.httpBody)
            let payload = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(payload["pdf_file_id"] as? String, "pdf-1")
            XCTAssertEqual(payload["count"] as? Int, 2)
            XCTAssertEqual(payload["difficulty"] as? String, "medium")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let flashcards = try await service.generateFlashcards(pdfFileId: "pdf-1", count: 2, difficulty: .medium)
        XCTAssertEqual(flashcards.count, 2)
        XCTAssertEqual(flashcards[0].front, "What is MVVM?")
    }

    func testFetchQuizDecodesNestedQuestions() async throws {
        let responseData = try makeJSON(sampleQuiz())

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let quiz = try await service.fetchQuiz(id: "quiz-1")
        XCTAssertEqual(quiz.title, "iOS Architecture Quiz")
        XCTAssertEqual(quiz.questions.count, 2)
        XCTAssertEqual(quiz.questions[0].questionType, .multipleChoice)
        XCTAssertEqual(quiz.questions[1].questionType, .shortAnswer)
    }

    func testSubmitQuizAnswersPostsAnswersDictionaryAndParsesScore() async throws {
        let responseData = try makeJSON(sampleQuizSubmissionResponse())

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let body = try XCTUnwrap(request.httpBody)
            let payload = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])
            let answers = payload["answers"] as? [String: String]
            XCTAssertEqual(answers?["question-1"], "2")
            XCTAssertEqual(answers?["question-2"], "Model View ViewModel")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let response = try await service.submitQuizAnswers(
            quizId: "quiz-1",
            answers: [
                "question-1": "2",
                "question-2": "Model View ViewModel"
            ]
        )

        XCTAssertEqual(response.score, 100)
        XCTAssertTrue(response.passed)
        XCTAssertEqual(response.feedback.count, 2)
    }

    func testFetchDailyStatisticsUsesDaysQueryParameter() async throws {
        let responseData = try makeJSON([sampleDailyStatistic()])

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.query, "days=14")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let stats = try await service.fetchDailyStatistics(days: 14)
        XCTAssertEqual(stats.count, 1)
        XCTAssertEqual(stats.first?.totalTimeSpent, 45)
    }

    func testServerErrorThrowsServerErrorWithStatusCode() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 500, httpVersion: nil, headerFields: nil)!,
                Data("{}".utf8)
            )
        }

        do {
            _ = try await service.fetchUserPDFs()
            XCTFail("Expected server error")
        } catch let error as NetworkError {
            XCTAssertEqual(error.localizedDescription, NetworkError.serverError(statusCode: 500, message: "Server error").localizedDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

// MARK: - Fixtures
private func makeJSON(_ object: Any) throws -> Data {
    try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
}

private func sampleUser() -> [String: Any] {
    [
        "id": "user-1",
        "email": "student@example.com",
        "username": "thanhlam",
        "full_name": "Thanh Lam Nguyen",
        "created_at": "2026-04-28T00:00:00Z",
        "updated_at": "2026-04-28T00:00:00Z"
    ]
}

private func samplePDFFile() -> [String: Any] {
    [
        "id": "pdf-1",
        "user_id": "user-1",
        "file_name": "lecture-notes.pdf",
        "file_size": 2048,
        "file_url": "https://example.com/files/lecture-notes.pdf",
        "uploaded_at": "2026-04-28T00:00:00Z",
        "processed_at": "2026-04-28T00:05:00Z",
        "status": "completed"
    ]
}

private func sampleSummary() -> [String: Any] {
    [
        "id": "summary-1",
        "user_id": "user-1",
        "pdf_file_id": "pdf-1",
        "title": "MVVM Summary",
        "content": "This summary explains the MVVM pattern used in SwiftUI apps.",
        "key_points": [
            "Views should stay lightweight.",
            "ViewModels handle presentation logic.",
            "Models store business data."
        ],
        "generated_at": "2026-04-28T00:10:00Z",
        "word_count": 180,
        "reading_time": 3
    ]
}

private func sampleFlashcard(id: String) -> [String: Any] {
    [
        "id": id,
        "user_id": "user-1",
        "pdf_file_id": "pdf-1",
        "set_id": "set-1",
        "front": "What is MVVM?",
        "back": "A UI architecture separating Model, View and ViewModel.",
        "difficulty": "medium",
        "created_at": "2026-04-28T00:15:00Z",
        "last_reviewed_at": NSNull(),
        "review_count": 0,
        "correct_count": 0
    ]
}

private func sampleQuiz() -> [String: Any] {
    [
        "id": "quiz-1",
        "user_id": "user-1",
        "pdf_file_id": "pdf-1",
        "title": "iOS Architecture Quiz",
        "questions": [
            [
                "id": "question-1",
                "question_text": "Which layer manages UI state?",
                "question_type": "multiple_choice",
                "options": ["Model", "ViewModel", "Database", "Router"],
                "correct_answer_index": 1,
                "correct_answer": NSNull()
            ],
            [
                "id": "question-2",
                "question_text": "What does MVVM stand for?",
                "question_type": "short_answer",
                "options": NSNull(),
                "correct_answer_index": NSNull(),
                "correct_answer": "Model View ViewModel"
            ]
        ],
        "created_at": "2026-04-28T00:20:00Z",
        "time_limit": 15,
        "passing_score": 70
    ]
}

private func sampleQuizSubmissionResponse() -> [String: Any] {
    [
        "quiz_id": "quiz-1",
        "score": 100,
        "total_questions": 2,
        "correct_answers": 2,
        "passed": true,
        "feedback": [
            [
                "question_id": "question-1",
                "is_correct": true,
                "user_answer": "2",
                "explanation": "ViewModel owns the presentation state."
            ],
            [
                "question_id": "question-2",
                "is_correct": true,
                "user_answer": "Model View ViewModel",
                "explanation": "Correct expansion of the acronym."
            ]
        ]
    ]
}

private func sampleDailyStatistic() -> [String: Any] {
    [
        "id": "day-1",
        "user_id": "user-1",
        "date": "2026-04-27T00:00:00Z",
        "total_time_spent": 45,
        "cards_reviewed": 30,
        "quizzes_completed": 2,
        "average_score": 88.5
    ]
}
