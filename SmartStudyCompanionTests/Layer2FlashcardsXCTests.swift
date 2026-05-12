import XCTest
@testable import SmartStudyCompanion

final class Layer2FlashcardsXCTests: XCTestCase {
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

    func test_generateFlashcards_success_returnsCards() async throws {
        let json = """
        [
          {
            "id": "fc-1",
            "user_id": "user-1",
            "pdf_file_id": "pdf-1",
            "set_id": "set-1",
            "front": "What is SwiftUI?",
            "back": "A declarative UI framework by Apple.",
            "difficulty": "easy",
            "created_at": "2026-05-09T10:00:00Z",
            "last_reviewed_at": null,
            "review_count": 0,
            "correct_count": 0
          },
          {
            "id": "fc-2",
            "user_id": "user-1",
            "pdf_file_id": "pdf-1",
            "set_id": "set-1",
            "front": "What is MVVM?",
            "back": "Model-View-ViewModel.",
            "difficulty": "medium",
            "created_at": "2026-05-09T10:00:00Z",
            "last_reviewed_at": null,
            "review_count": 0,
            "correct_count": 0
          }
        ]
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let response = HTTPURLResponse(url: request.url!, statusCode: 201, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let cards = try await sut.generateFlashcards(for: "pdf-1")
        XCTAssertEqual(cards.count, 2)
        XCTAssertEqual(cards.first?.front, "What is SwiftUI?")
        XCTAssertEqual(cards.last?.back, "Model-View-ViewModel.")
    }

    func test_generateFlashcards_emptyArray_returnsEmptyCollection() async throws {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, Data("[]".utf8))
        }

        let cards = try await sut.generateFlashcards(for: "pdf-1")
        XCTAssertTrue(cards.isEmpty)
    }

    func test_fetchFlashcards_malformedCard_throws() async {
        let badJSON = Data("[{\"id\":\"fc-1\",\"front\":\"Only front\"}]".utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, badJSON)
        }

        do {
            _ = try await sut.fetchFlashcards(for: "pdf-1")
            XCTFail("Expected malformed response failure")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_fetchFlashcards_serverFailure_throws() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            _ = try await sut.fetchFlashcards(for: "pdf-1")
            XCTFail("Expected failure")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_updateProgress_afterFlashcardStudy_sendsRequest() async throws {
        let json = """
        {
          "id": "prog-1",
          "user_id": "user-1",
          "pdf_file_id": "pdf-1",
          "total_time_spent": 30,
          "cards_studied": 12,
          "cards_remaining": 8,
          "quizzes_completed": 1,
          "average_score": 85.0,
          "last_study_date": "2026-05-09T10:00:00Z",
          "study_streak": 3,
          "total_cards": 20,
          "mastered_cards": 10
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "PUT")
            let body = try XCTUnwrap(request.httpBody)
            let bodyString = String(decoding: body, as: UTF8.self)
            XCTAssertTrue(bodyString.contains("cards_reviewed"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let progress = try await sut.updateProgress(pdfFileId: "pdf-1", timeSpent: 10, cardsReviewed: 5, correctAnswers: 4)
        XCTAssertEqual(progress.cardsStudied, 12)
        XCTAssertEqual(progress.masteredCards, 10)
    }
}
