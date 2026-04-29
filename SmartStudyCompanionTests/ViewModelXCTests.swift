import XCTest
@testable import SmartStudyCompanion

@MainActor
final class ViewModelXCTests: XCTestCase {
    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        APIService.shared.logout()
        _ = URLProtocol.registerClass(MockURLProtocol.self)
    }

    override func tearDown() {
        URLProtocol.unregisterClass(MockURLProtocol.self)
        MockURLProtocol.reset()
        APIService.shared.logout()
        super.tearDown()
    }

    func testAuthViewModelLoginSuccessUpdatesAuthenticationState() async throws {
        let responseData = try makeJSON([
            "user": sampleUser(),
            "token": "access-token-123",
            "refresh_token": "refresh-token-123"
        ])

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertTrue(request.url?.path.contains("/auth/login") == true)
            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let viewModel = AuthViewModel()
        await viewModel.login(email: "student@example.com", password: "Password123")

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.user?.email, "student@example.com")
    }

    func testAuthViewModelLoginFailureShowsUserFacingError() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 401, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }

        let viewModel = AuthViewModel()
        await viewModel.login(email: "wrong@example.com", password: "wrong")

        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, NetworkError.unauthorized.localizedDescription)
        XCTAssertNil(viewModel.user)
    }

    func testAuthViewModelSignUpSuccessUpdatesAuthenticatedUser() async throws {
        let responseData = try makeJSON([
            "user": sampleUser(),
            "token": "access-token-123",
            "refresh_token": "refresh-token-123"
        ])

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertTrue(request.url?.path.contains("/auth/signup") == true)

            let body = try XCTUnwrap(request.httpBody)
            let payload = try XCTUnwrap(try JSONSerialization.jsonObject(with: body) as? [String: Any])
            XCTAssertEqual(payload["email"] as? String, "student@example.com")
            XCTAssertEqual(payload["username"] as? String, "thanhlam")
            XCTAssertEqual(payload["full_name"] as? String, "Thanh Lam Nguyen")

            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let viewModel = AuthViewModel()
        await viewModel.signUp(email: "student@example.com", password: "Password123", username: "thanhlam", fullName: "Thanh Lam Nguyen")

        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.user?.username, "thanhlam")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testAuthViewModelLogoutClearsState() async {
        let responseData = try! makeJSON([
            "user": sampleUser(),
            "token": "access-token-123",
            "refresh_token": "refresh-token-123"
        ])

        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let viewModel = AuthViewModel()
        await viewModel.login(email: "student@example.com", password: "Password123")
        XCTAssertTrue(viewModel.isAuthenticated)

        viewModel.logout()
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.user)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testUploadViewModelUploadPDFAppendsUploadedFileAndResetsTransientState() async throws {
        let responseData = try makeJSON(samplePDFFile())

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertTrue(request.url?.path.contains("/files/upload") == true)
            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let viewModel = UploadViewModel()
        await viewModel.uploadPDF(fileName: "lecture-notes.pdf", fileData: Data("fake-pdf".utf8))

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.uploadedPDFs.count, 1)
        XCTAssertEqual(viewModel.uploadedPDFs.first?.fileName, "lecture-notes.pdf")
        XCTAssertNil(viewModel.currentlyUploading)
        XCTAssertEqual(viewModel.uploadProgress, 0.0)
    }

    func testUploadViewModelUploadImageAppendsUploadedFile() async throws {
        let imageResponse = try makeJSON([
            "id": "img-1",
            "user_id": "user-1",
            "file_name": "board-photo.jpg",
            "file_size": 1024,
            "file_url": "https://example.com/files/board-photo.jpg",
            "uploaded_at": "2026-04-28T00:00:00Z",
            "processed_at": NSNull(),
            "status": "pending"
        ])

        MockURLProtocol.requestHandler = { request in
            let bodyString = String(data: try XCTUnwrap(request.httpBody), encoding: .utf8)
            XCTAssertTrue(bodyString?.contains("image") == true)
            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                imageResponse
            )
        }

        let viewModel = UploadViewModel()
        await viewModel.uploadImage(fileName: "board-photo.jpg", imageData: Data("fake-image".utf8))

        XCTAssertEqual(viewModel.uploadedPDFs.count, 1)
        XCTAssertEqual(viewModel.uploadedPDFs.first?.fileName, "board-photo.jpg")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testUploadViewModelFetchUserPDFsReplacesCurrentList() async throws {
        let responseData = try makeJSON([
            samplePDFFile(),
            [
                "id": "pdf-2",
                "user_id": "user-1",
                "file_name": "week-5-summary.pdf",
                "file_size": 4096,
                "file_url": "https://example.com/files/week-5-summary.pdf",
                "uploaded_at": "2026-04-28T00:00:00Z",
                "processed_at": "2026-04-28T00:01:00Z",
                "status": "completed"
            ]
        ])

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "GET")
            return (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 200, httpVersion: nil, headerFields: nil)!,
                responseData
            )
        }

        let viewModel = UploadViewModel()
        await viewModel.fetchUserPDFs()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.uploadedPDFs.count, 2)
        XCTAssertEqual(viewModel.uploadedPDFs[1].fileName, "week-5-summary.pdf")
    }

    func testUploadViewModelUploadFailureShowsReadableError() async {
        MockURLProtocol.requestHandler = { request in
            (
                HTTPURLResponse(url: try XCTUnwrap(request.url), statusCode: 500, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }

        let viewModel = UploadViewModel()
        await viewModel.uploadPDF(fileName: "lecture-notes.pdf", fileData: Data("fake-pdf".utf8))

        XCTAssertTrue(viewModel.uploadedPDFs.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, NetworkError.serverError(statusCode: 500, message: "Server error").localizedDescription)
        XCTAssertNil(viewModel.currentlyUploading)
        XCTAssertEqual(viewModel.uploadProgress, 0.0)
    }
}
