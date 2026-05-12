import XCTest
@testable import SmartStudyCompanion

final class Layer2IntegrationXCTests: XCTestCase {
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

    func test_generatedStudyMaterials_shareSamePDFFileId() async throws {
        var callCount = 0

        MockURLProtocol.requestHandler = { request in
            callCount += 1
            let path = request.url?.path ?? ""

            if path.contains("summary") {
                let json = """
                {
                  "id": "sum-1",
                  "user_id": "user-1",
                  "pdf_file_id": "pdf-1",
                  "title": "Summary",
                  "content": "Summary body",
                  "key_points": ["A"],
                  "generated_at": "2026-05-09T10:00:00Z",
                  "word_count": 10,
                  "reading_time": 1
                }
                """.data(using: .utf8)!
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, json)
            }

            if path.contains("flashcards") {
                let json = """
                [
                  {
                    "id": "fc-1",
                    "user_id": "user-1",
                    "pdf_file_id": "pdf-1",
                    "set_id": "set-1",
                    "front": "Front",
                    "back": "Back",
                    "difficulty": "easy",
                    "created_at": "2026-05-09T10:00:00Z",
                    "last_reviewed_at": null,
                    "review_count": 0,
                    "correct_count": 0
                  }
                ]
                """.data(using: .utf8)!
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, json)
            }

            let json = """
            {
              "id": "quiz-1",
              "user_id": "user-1",
              "pdf_file_id": "pdf-1",
              "title": "Quiz",
              "created_at": "2026-05-09T10:00:00Z",
              "time_limit": 60,
              "passing_score": 70,
              "questions": []
            }
            """.data(using: .utf8)!
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let summary = try await sut.fetchSummary(for: "pdf-1")
        let flashcards = try await sut.fetchFlashcards(for: "pdf-1")
        let quiz = try await sut.fetchQuiz(for: "pdf-1")

        XCTAssertEqual(summary?.pdfFileId, "pdf-1")
        XCTAssertEqual(flashcards.first?.pdfFileId, "pdf-1")
        XCTAssertEqual(quiz.pdfFileId, "pdf-1")
        XCTAssertEqual(callCount, 3)
    }

    func test_quizCompletion_canBeFollowedByProgressRefresh() async throws {
        var didSubmitQuiz = false
        var didUpdateProgress = false

        MockURLProtocol.requestHandler = { request in
            let path = request.url?.path ?? ""

            if path.contains("submit") {
                didSubmitQuiz = true
                let json = """
                {
                  "quiz_id": "quiz-1",
                  "score": 90,
                  "total_questions": 10,
                  "correct_answers": 9,
                  "passed": true,
                  "feedback": "Excellent"
                }
                """.data(using: .utf8)!
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, json)
            }

            if path.contains("progress") {
                didUpdateProgress = true
                let json = """
                {
                  "id": "prog-1",
                  "user_id": "user-1",
                  "pdf_file_id": "pdf-1",
                  "total_time_spent": 45,
                  "cards_studied": 12,
                  "cards_remaining": 8,
                  "quizzes_completed": 3,
                  "average_score": 90,
                  "last_study_date": "2026-05-09T10:00:00Z",
                  "study_streak": 4,
                  "total_cards": 20,
                  "mastered_cards": 11
                }
                """.data(using: .utf8)!
                let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
                return (response, json)
            }

            let response = HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        let result = try await sut.submitQuiz(quizId: "quiz-1", answers: [1, 1, 1])
        let progress = try await sut.updateProgress(pdfFileId: "pdf-1", timeSpent: 15, cardsReviewed: 0, correctAnswers: result.correctAnswers)

        XCTAssertTrue(didSubmitQuiz)
        XCTAssertTrue(didUpdateProgress)
        XCTAssertEqual(progress.quizzesCompleted, 3)
        XCTAssertEqual(progress.averageScore, 90)
    }

    func test_flashcardStudy_canBeFollowedByProgressRefresh() async throws {
        var progressRequestCount = 0

        MockURLProtocol.requestHandler = { request in
            let json = """
            {
              "id": "prog-1",
              "user_id": "user-1",
              "pdf_file_id": "pdf-1",
              "total_time_spent": 25,
              "cards_studied": 15,
              "cards_remaining": 5,
              "quizzes_completed": 1,
              "average_score": 80,
              "last_study_date": "2026-05-09T10:00:00Z",
              "study_streak": 2,
              "total_cards": 20,
              "mastered_cards": 9
            }
            """.data(using: .utf8)!
            progressRequestCount += 1
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, json)
        }

        let progress = try await sut.updateProgress(pdfFileId: "pdf-1", timeSpent: 5, cardsReviewed: 3, correctAnswers: 2)
        XCTAssertEqual(progress.cardsStudied, 15)
        XCTAssertEqual(progressRequestCount, 1)
    }
}
