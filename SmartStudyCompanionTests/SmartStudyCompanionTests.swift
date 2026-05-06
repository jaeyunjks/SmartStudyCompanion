import Foundation
import XCTest
@testable import SmartStudyCompanion

final class SmartStudyCompanionTests: XCTestCase {

    override func setUp() {
        super.setUp()
        URLProtocolMock.reset()
    }

    override func tearDown() {
        URLProtocolMock.reset()
        super.tearDown()
    }

    func testGenerateWorkspaceSummaryResolvesWorkspaceByExactTitle() async throws {
        let service = makeService()
        try await login(service)

        URLProtocolMock.setStub(method: "GET", path: "/api/study-space/local-space") {
            .json(statusCode: 404, body: ["message": "Not found"])
        }
        URLProtocolMock.setStub(method: "GET", path: "/api/study-space/user/user-1") {
            .json(statusCode: 200, body: [
                "isOwner": true,
                "studySpaces": [self.studySpace(id: "remote-space", title: "Biology")]
            ])
        }
        URLProtocolMock.setStub(method: "GET", path: "/api/file/study-space/remote-space") {
            .json(statusCode: 200, body: [
                "isOwner": true,
                "files": [[
                    "file": [
                        "id": "file-1",
                        "name": "lecture-notes.pdf",
                        "mimeType": "application/pdf",
                        "size": 1200,
                        "userId": "user-1",
                        "spaceId": "remote-space",
                        "createdAt": "2026-05-02T00:00:00.000Z",
                    ],
                    "url": "storage/path/lecture-notes.pdf",
                ]],
            ])
        }
        URLProtocolMock.setStub(method: "POST", path: "/api/ai/study-space/remote-space/summary") {
            .json(statusCode: 200, body: [
                "summary": [
                    "overview": "Cells are the basic unit of life.",
                    "keyConcepts": ["cell theory"],
                    "importantDetails": ["all organisms are made of cells"],
                ],
            ])
        }

        let summary = try await service.generateWorkspaceSummary(
            workspaceId: "local-space",
            workspaceTitle: "Biology",
            workspaceContent: "unused",
            preferredFileNames: ["lecture-notes.pdf"]
        )

        XCTAssertTrue(summary.title.contains("Biology"))
        XCTAssertTrue(summary.overview.contains("basic unit of life"))
        XCTAssertTrue(URLProtocolMock.didRequest(method: "POST", path: "/api/ai/study-space/remote-space/summary"))
    }

    func testGenerateWorkspaceSummaryRequiresBackendFiles() async throws {
        let service = makeService()
        try await login(service)

        URLProtocolMock.setStub(method: "GET", path: "/api/study-space/space-1") {
            .json(statusCode: 200, body: [
                "isOwner": true,
                "studySpace": self.studySpace(id: "space-1", title: "Physics"),
            ])
        }
        URLProtocolMock.setStub(method: "GET", path: "/api/file/study-space/space-1") {
            .json(statusCode: 200, body: [
                "isOwner": true,
                "files": [],
            ])
        }

        do {
            _ = try await service.generateWorkspaceSummary(
                workspaceId: "space-1",
                workspaceTitle: "Physics",
                workspaceContent: "unused"
            )
            XCTFail("Expected missing files error")
        } catch let error as NetworkError {
            switch error {
            case .serverError(let code, let message):
                XCTAssertEqual(code, 400)
                XCTAssertTrue(message.localizedCaseInsensitiveContains("no backend files"))
            default:
                XCTFail("Unexpected error: \(error)")
            }
        }
    }

    func testChatWithStudySpaceUsesResolvedWorkspaceIdAndParsesResponse() async throws {
        let service = makeService()
        try await login(service)

        URLProtocolMock.setStub(method: "GET", path: "/api/study-space/local-space") {
            .json(statusCode: 404, body: ["message": "Not found"])
        }
        URLProtocolMock.setStub(method: "GET", path: "/api/study-space/user/user-1") {
            .json(statusCode: 200, body: [
                "isOwner": true,
                "studySpaces": [self.studySpace(id: "remote-space", title: "Biology")]
            ])
        }
        URLProtocolMock.setStub(method: "POST", path: "/api/ai/study-space/remote-space/chat") {
            .json(statusCode: 200, body: [
                "chatHistoryId": "history-1",
                "messages": [[
                    "id": "msg-1",
                    "chatHistoryId": "history-1",
                    "role": "assistant",
                    "content": "Photosynthesis turns light into chemical energy.",
                    "createdAt": "2026-05-02T00:00:00.000Z",
                ]],
            ])
        }

        let response = try await service.chatWithStudySpace(
            workspaceId: "local-space",
            workspaceTitle: "Biology",
            prompt: "Explain photosynthesis",
            chatHistoryId: nil,
            title: nil
        )

        XCTAssertEqual(response.chatHistoryId, "history-1")
        XCTAssertEqual(response.messages.last?.content, "Photosynthesis turns light into chemical energy.")
        XCTAssertTrue(URLProtocolMock.didRequest(method: "POST", path: "/api/ai/study-space/remote-space/chat"))
    }

    // MARK: - Helpers

    private func makeService() -> APIService {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolMock.self]
        let session = URLSession(configuration: configuration)
        return APIService(baseURL: URL(string: "http://localhost:8000/api")!, session: session)
    }

    private func login(_ service: APIService) async throws {
        URLProtocolMock.setStub(method: "POST", path: "/api/auth/login") {
            .json(statusCode: 200, body: [
                "access_token": Self.makeJWT(sub: "user-1"),
                "user": [
                    "id": "user-1",
                    "email": "test@example.com",
                    "fullname": "Test User",
                    "username": "tester",
                    "createdAt": "2026-05-02T00:00:00.000Z",
                ],
            ])
        }
        _ = try await service.login(email: "test@example.com", password: "password")
    }

    private func studySpace(id: String, title: String) -> [String: Any] {
        [
            "id": id,
            "title": title,
            "userId": "user-1",
            "color": "#22C55E",
            "tag": "science",
            "summary": NSNull(),
            "createdAt": "2026-05-02T00:00:00.000Z",
        ]
    }

    private static func makeJWT(sub: String) -> String {
        let header = ["alg": "HS256", "typ": "JWT"]
        let payload = ["sub": sub]
        func encode(_ object: [String: String]) -> String {
            let data = try! JSONSerialization.data(withJSONObject: object)
            return data.base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")
        }
        return "\(encode(header)).\(encode(payload)).signature"
    }
}

private struct StubbedResponse {
    let statusCode: Int
    let bodyData: Data

    static func json(statusCode: Int, body: Any) -> StubbedResponse {
        let data = try! JSONSerialization.data(withJSONObject: body, options: [])
        return StubbedResponse(statusCode: statusCode, bodyData: data)
    }
}

private struct RequestKey: Hashable {
    let method: String
    let path: String
}

private final class URLProtocolMock: URLProtocol {
    private static var lock = NSLock()
    private static var stubs: [RequestKey: () -> StubbedResponse] = [:]
    private static var requests: [RequestKey] = []

    static func reset() {
        lock.lock()
        stubs.removeAll()
        requests.removeAll()
        lock.unlock()
    }

    static func setStub(method: String, path: String, response: @escaping () -> StubbedResponse) {
        lock.lock()
        stubs[RequestKey(method: method, path: path)] = response
        lock.unlock()
    }

    static func didRequest(method: String, path: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return requests.contains(RequestKey(method: method, path: path))
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.badURL))
            return
        }
        let method = request.httpMethod ?? "GET"
        let key = RequestKey(method: method, path: url.path)

        URLProtocolMock.lock.lock()
        URLProtocolMock.requests.append(key)
        let responseProvider = URLProtocolMock.stubs[key]
        URLProtocolMock.lock.unlock()

        guard let responseProvider else {
            client?.urlProtocol(self, didFailWithError: URLError(.resourceUnavailable))
            return
        }

        let stub = responseProvider()
        let response = HTTPURLResponse(
            url: url,
            statusCode: stub.statusCode,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: stub.bodyData)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
