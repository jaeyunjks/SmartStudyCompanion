import XCTest
@testable import SmartStudyCompanion

final class Layer1APIServiceXCTests: XCTestCase {
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
        session.invalidateAndCancel()
        service.logout()
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testLayer1_loginSuccess_decodesUserAndTokens() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/api/auth/login")

            let body = try XCTUnwrap(request.httpBody)
            let payload = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(payload["email"] as? String, "student@example.com")
            XCTAssertEqual(payload["password"] as? String, "Password123")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON(sampleAuthResponse())
            )
        }

        let response = try await service.login(email: "student@example.com", password: "Password123")
        XCTAssertEqual(response.user.email, "student@example.com")
        XCTAssertEqual(response.token, "access-token-123")
        XCTAssertEqual(response.refreshToken, "refresh-token-123")
    }

    func testLayer1_signUpSuccess_postsExpectedBody() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/api/auth/signup")

            let body = try XCTUnwrap(request.httpBody)
            let payload = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(payload["email"] as? String, "new@example.com")
            XCTAssertEqual(payload["username"] as? String, "newuser")
            XCTAssertEqual(payload["full_name"] as? String, "New User")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON(sampleAuthResponse(email: "new@example.com", username: "newuser", fullName: "New User"))
            )
        }

        let response = try await service.signUp(
            signUpRequest: SignUpRequest(email: "new@example.com", password: "Password123", username: "newuser", fullName: "New User")
        )

        XCTAssertEqual(response.user.username, "newuser")
        XCTAssertEqual(response.user.fullName, "New User")
    }

    func testLayer1_fetchUserPDFs_includesAuthorizationAfterLogin() async throws {
        var callCount = 0
        MockURLProtocol.requestHandler = { request in
            callCount += 1
            if callCount == 1 {
                return (
                    HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                    try makeJSON(sampleAuthResponse())
                )
            }

            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/api/files/list")
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer access-token-123")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON([samplePDFFile()])
            )
        }

        _ = try await service.login(email: "student@example.com", password: "Password123")
        let files = try await service.fetchUserPDFs()
        XCTAssertEqual(files.count, 1)
        XCTAssertEqual(files.first?.fileName, "lecture-notes.pdf")
    }

    func testLayer1_uploadPDF_buildsMultipartRequest() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/api/files/upload")
            XCTAssertTrue(request.value(forHTTPHeaderField: "Content-Type")?.contains("multipart/form-data; boundary=") == true)

            let body = String(data: try XCTUnwrap(request.httpBody), encoding: .utf8)
            XCTAssertTrue(body?.contains("filename=\"lecture-notes.pdf\"") == true)
            XCTAssertTrue(body?.contains("name=\"file_type\"") == true)
            XCTAssertTrue(body?.contains("pdf") == true)

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON(samplePDFFile())
            )
        }

        let file = try await service.uploadPDF(fileData: Data("fake-pdf".utf8), fileName: "lecture-notes.pdf", fileType: "pdf")
        XCTAssertEqual(file.id, "pdf-1")
        XCTAssertEqual(file.status, .completed)
    }

    func testLayer1_fetchProgress_decodesProgressModel() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/api/progress/pdf-1")
            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON(sampleProgress())
            )
        }

        let progress = try await service.fetchProgress(for: "pdf-1")
        XCTAssertEqual(progress.pdfFileId, "pdf-1")
        XCTAssertEqual(progress.totalTimeSpent, 95)
        XCTAssertEqual(progress.masteredCards, 12)
    }

    func testLayer1_fetchDailyStatistics_usesDaysQueryParameter() async throws {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            XCTAssertEqual(request.url?.path, "/api/progress/statistics")
            XCTAssertEqual(URLComponents(url: try XCTUnwrap(request.url), resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "days" })?.value, "14")
            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON([sampleDailyStatistic()])
            )
        }

        let stats = try await service.fetchDailyStatistics(days: 14)
        XCTAssertEqual(stats.count, 1)
        XCTAssertEqual(stats.first?.cardsReviewed, 20)
    }

    func testLayer1_loginUnauthorized_throwsReadableError() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }

        do {
            _ = try await service.login(email: "wrong@example.com", password: "wrong")
            XCTFail("Expected unauthorized error")
        } catch let error as NetworkError {
            XCTAssertEqual(error.localizedDescription, NetworkError.unauthorized.localizedDescription)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private func makeJSON(_ object: Any) throws -> Data {
    try JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
}

private func sampleAuthResponse(email: String = "student@example.com", username: String = "thanhlam", fullName: String = "Thanh Lam Nguyen") -> [String: Any] {
    [
        "user": [
            "id": "user-1",
            "email": email,
            "username": username,
            "full_name": fullName,
            "created_at": "2026-04-28T00:00:00Z",
            "updated_at": "2026-04-28T00:00:00Z"
        ],
        "token": "access-token-123",
        "refresh_token": "refresh-token-123"
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
        "processed_at": "2026-04-28T00:01:00Z",
        "status": "completed"
    ]
}

private func sampleProgress() -> [String: Any] {
    [
        "id": "progress-1",
        "user_id": "user-1",
        "pdf_file_id": "pdf-1",
        "total_time_spent": 95,
        "cards_studied": 18,
        "cards_remaining": 7,
        "quizzes_completed": 3,
        "average_score": 84.5,
        "last_study_date": "2026-04-28T00:00:00Z",
        "study_streak": 4,
        "total_cards": 25,
        "mastered_cards": 12
    ]
}

private func sampleDailyStatistic() -> [String: Any] {
    [
        "id": "daily-1",
        "user_id": "user-1",
        "date": "2026-04-28T00:00:00Z",
        "total_time_spent": 45,
        "cards_reviewed": 20,
        "quizzes_completed": 1,
        "average_score": 87.0
    ]
}
