import XCTest
@testable import SmartStudyCompanion

final class Layer2QuizXCTests: XCTestCase {
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

    func test_fetchQuiz_success_decodesQuiz() async throws {
        let json = """
        {
          "id": "quiz-1",
          "user_id": "user-1",
          "pdf_file_id": "pdf-1",
          "title": "Swift Basics Quiz",
          "created_at": "2026-05-09T10:00:00Z",
          "time_limit": 300,
          "passing_score": 70,
          "questions": [
            {
              "id": "q1",
              "question": "Which framework is declarative?",
              "options": ["UIKit", "SwiftUI", "AppKit", "CoreData"],
              "correct_answer": 1,
              "explanation": "SwiftUI is declarative."
            }
          ]
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let quiz = try await sut.fetchQuiz(for: "pdf-1")
        XCTAssertEqual(quiz.title, "Swift Basics Quiz")
        XCTAssertEqual(quiz.questions.count, 1)
        XCTAssertEqual(quiz.questions.first?.options.count, 4)
    }

    func test_fetchQuiz_emptyQuestions_decodesButHasNoQuestions() async throws {
        let json = """
        {
          "id": "quiz-1",
          "user_id": "user-1",
          "pdf_file_id": "pdf-1",
          "title": "Empty Quiz",
          "created_at": "2026-05-09T10:00:00Z",
          "time_limit": 300,
          "passing_score": 70,
          "questions": []
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let quiz = try await sut.fetchQuiz(for: "pdf-1")
        XCTAssertTrue(quiz.questions.isEmpty)
    }

    func test_fetchQuiz_malformedQuestion_throws() async {
        let badJSON = Data("{\"id\":\"quiz-1\",\"questions\":[{\"id\":\"q1\"}]}".utf8)

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, badJSON)
        }

        do {
            _ = try await sut.fetchQuiz(for: "pdf-1")
            XCTFail("Expected decode failure")
        } catch {
            XCTAssertTrue(true)
        }
    }

    func test_submitQuiz_success_returnsResult() async throws {
        let json = """
        {
          "quiz_id": "quiz-1",
          "score": 80,
          "total_questions": 5,
          "correct_answers": 4,
          "passed": true,
          "feedback": "Great job!"
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            let body = try XCTUnwrap(request.httpBody)
            let bodyString = String(decoding: body, as: UTF8.self)
            XCTAssertTrue(bodyString.contains("answers"))
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let result = try await sut.submitQuiz(quizId: "quiz-1", answers: [1, 2, 3, 1])
        XCTAssertEqual(result.score, 80)
        XCTAssertTrue(result.passed)
        XCTAssertEqual(result.correctAnswers, 4)
    }

    func test_submitQuiz_failure_throws() async {
        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        do {
            _ = try await sut.submitQuiz(quizId: "quiz-1", answers: [0, 1])
            XCTFail("Expected submission failure")
        } catch {
            XCTAssertTrue(true)
        }
    }
}
