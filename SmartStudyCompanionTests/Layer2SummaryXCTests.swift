import XCTest
@testable import SmartStudyCompanion

final class Layer2SummaryXCTests: XCTestCase {
    private var sut: APIService!
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        MockURLProtocol.requestHandler = nil

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        sut = APIService(baseURL: URL(string: "https://example.com/api")!, session: session)
    }

    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        session = nil
        sut = nil
        super.tearDown()
    }

    func test_fetchSummary_success_decodesSummary() async throws {
        let json = """
        {
          "id": "sum-1",
          "user_id": "user-1",
          "pdf_file_id": "pdf-1",
          "title": "Chapter Summary",
          "content": "This is a generated summary.",
          "key_points": ["Point A", "Point B"],
          "generated_at": "2026-05-09T10:00:00Z",
          "word_count": 120,
          "reading_time": 2
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertTrue(request.url?.absoluteString.contains("summary") == true)
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let summary = try await sut.fetchSummary(for: "pdf-1")

        XCTAssertEqual(summary.id, "sum-1")
        XCTAssertEqual(summary.pdfFileId, "pdf-1")
        XCTAssertEqual(summary.title, "Chapter Summary")
        XCTAssertEqual(summary.keyPoints.count, 2)
        XCTAssertEqual(summary.wordCount, 120)
        XCTAssertEqual(summary.readingTime, 2)
    }

    func test_fetchSummary_notFound_returnsNil() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let summary = try await sut.fetchSummary(for: "missing-pdf")
        XCTAssertNil(summary)
    }

    func test_fetchSummary_malformedResponse_throwsDecodingError() async {
        let badJSON = Data("{ \"broken\": true }".utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, badJSON)
        }

        do {
            _ = try await sut.fetchSummary(for: "pdf-1")
            XCTFail("Expected decoding failure")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_generateSummary_serverError_throws() async {
        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            _ = try await sut.generateSummary(for: "pdf-1")
            XCTFail("Expected failure")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_generateSummary_placeholderLikePayload_stillDecodes() async throws {
        let json = """
        {
          "id": "sum-placeholder",
          "user_id": "user-1",
          "pdf_file_id": "pdf-1",
          "title": "Quick Summary",
          "content": "Placeholder summary content for MVP demo.",
          "key_points": ["Placeholder point 1", "Placeholder point 2"],
          "generated_at": "2026-05-09T10:00:00Z",
          "word_count": 42,
          "reading_time": 1
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let response = HTTPURLResponse(url: request.url!, statusCode: 201, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let summary = try await sut.generateSummary(for: "pdf-1")
        XCTAssertEqual(summary.title, "Quick Summary")
        XCTAssertTrue(summary.content.contains("Placeholder"))
    }
}
