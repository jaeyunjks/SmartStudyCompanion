import XCTest
@testable import SmartStudyCompanion

@MainActor
final class Layer1ViewModelXCTests: XCTestCase {
    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        APIService.shared.logout()
        _ = URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        APIService.shared.logout()
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testLayer1_authViewModel_loginSuccess_updatesAuthenticatedState() async throws {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON(sampleAuthResponse())
            )
        }

        let viewModel = AuthViewModel()
        await viewModel.login(email: "student@example.com", password: "Password123")

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.user?.username, "thanhlam")
    }

    func testLayer1_authViewModel_signUpSuccess_setsUserAndAuthentication() async throws {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON(sampleAuthResponse(email: "new@example.com", username: "newuser", fullName: "New User"))
            )
        }

        let viewModel = AuthViewModel()
        await viewModel.signUp(email: "new@example.com", password: "Password123", username: "newuser", fullName: "New User")

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.user?.email, "new@example.com")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLayer1_authViewModel_loginFailure_setsErrorWithoutAuthenticating() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }

        let viewModel = AuthViewModel()
        await viewModel.login(email: "wrong@example.com", password: "wrong")

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.user)
        XCTAssertEqual(viewModel.errorMessage, NetworkError.unauthorized.localizedDescription)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLayer1_authViewModel_logout_clearsState() async throws {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON(sampleAuthResponse())
            )
        }

        let viewModel = AuthViewModel()
        await viewModel.login(email: "student@example.com", password: "Password123")
        viewModel.logout()

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.user)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLayer1_uploadViewModel_uploadPDF_successAppendsUploadedFile() async throws {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON(samplePDFFile())
            )
        }

        let viewModel = UploadViewModel()
        await viewModel.uploadPDF(fileName: "lecture-notes.pdf", fileData: Data("fake-pdf".utf8))

        XCTAssertEqual(viewModel.uploadedPDFs.count, 1)
        XCTAssertEqual(viewModel.uploadedPDFs.first?.fileName, "lecture-notes.pdf")
        XCTAssertNil(viewModel.currentlyUploading)
        XCTAssertEqual(viewModel.uploadProgress, 0.0)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isLoading)
    }

    func testLayer1_uploadViewModel_fetchUserPDFs_replacesList() async throws {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                try makeJSON([samplePDFFile()])
            )
        }

        let viewModel = UploadViewModel()
        await viewModel.fetchUserPDFs()

        XCTAssertEqual(viewModel.uploadedPDFs.count, 1)
        XCTAssertEqual(viewModel.uploadedPDFs[0].status, .completed)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLayer1_uploadViewModel_uploadFailure_showsReadableError() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }

        let viewModel = UploadViewModel()
        await viewModel.uploadPDF(fileName: "lecture-notes.pdf", fileData: Data("fake-pdf".utf8))

        XCTAssertTrue(viewModel.uploadedPDFs.isEmpty)
        XCTAssertEqual(viewModel.errorMessage, NetworkError.serverError(statusCode: 500, message: "Server error").localizedDescription)
        XCTAssertNil(viewModel.currentlyUploading)
        XCTAssertEqual(viewModel.uploadProgress, 0.0)
        XCTAssertFalse(viewModel.isLoading)
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
