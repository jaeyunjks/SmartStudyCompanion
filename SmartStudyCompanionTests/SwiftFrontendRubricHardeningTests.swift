import XCTest
@testable import SmartStudyCompanion

@MainActor
final class SwiftFrontendRubricHardeningTests: XCTestCase {
    private let authKeys = [
        "auth.loggedIn",
        "auth.profileData",
        "auth.rememberMe",
        "auth.remembered.email",
        "auth.remembered.password"
    ]
    private let workspaceCacheKey = "studyspaces.saved.v1"

    override func setUp() {
        super.setUp()
        clearUserDefaults()
    }

    override func tearDown() {
        clearUserDefaults()
        super.tearDown()
    }

    func testStudySpaceFromRemote_returnsNilForInvalidIdentifier() {
        let remote = RemoteStudySpace(
            id: "not-a-uuid",
            userId: "user-1",
            title: "History",
            description: nil,
            iconName: nil,
            category: nil,
            status: nil,
            workspaceColorHex: nil,
            color: nil,
            tag: nil,
            documentCount: nil,
            noteCount: nil,
            aiOutputCount: nil,
            progress: nil,
            createdAt: nil,
            updatedAt: nil,
            summaries: nil
        )

        XCTAssertNil(StudySpace.fromRemote(remote))
    }

    func testStudySpaceFromRemote_defaultsUnknownStatusToActive() {
        let remote = RemoteStudySpace(
            id: UUID().uuidString,
            userId: "user-1",
            title: "History",
            description: "Ancient history notes",
            iconName: "book.closed",
            category: "Humanities",
            status: "maybe",
            workspaceColorHex: "#111111",
            color: nil,
            tag: nil,
            documentCount: 3,
            noteCount: 1,
            aiOutputCount: 2,
            progress: 0.4,
            createdAt: Date(),
            updatedAt: Date(),
            summaries: nil
        )

        let mapped = StudySpace.fromRemote(remote)

        XCTAssertEqual(mapped?.status, .active)
        XCTAssertEqual(mapped?.normalizedStatus, "Active")
        XCTAssertEqual(mapped?.workspaceColorHex, "#111111")
    }

    func testStudySpaceStore_updateStatus_usesTypedStatus() {
        let space = StudySpace(
            id: UUID(),
            title: "Physics",
            description: "Mechanics",
            iconName: "atom",
            category: "Science",
            status: .active,
            workspaceColorHex: "#22C55E",
            documentCount: 0,
            noteCount: 0,
            lastUpdated: "Just now",
            lastOpened: "Opened just now",
            aiOutputCount: 0,
            progress: 0
        )

        let store = StudySpaceStore(seed: [space])
        store.updateStatus(for: space.id, status: .inactive)

        XCTAssertEqual(store.studySpaces.first?.status, .inactive)
        XCTAssertEqual(store.studySpaces.first?.normalizedStatus, "Inactive")
    }

    func testGooglePlaceholderDoesNotAuthenticate() async {
        let viewModel = AuthViewModel()

        await viewModel.loginWithGooglePlaceholder()

        XCTAssertEqual(viewModel.errorMessage, "This sign-in option is planned for a future update.")
        XCTAssertFalse(viewModel.isAuthenticated)
    }

    func testApplePlaceholderDoesNotAuthenticate() async {
        let viewModel = AuthViewModel()

        await viewModel.loginWithApplePlaceholder()

        XCTAssertEqual(viewModel.errorMessage, "This sign-in option is planned for a future update.")
        XCTAssertFalse(viewModel.isAuthenticated)
    }

    func testWelcomeBackText_usesSessionProfileDisplayName() {
        let viewModel = AuthViewModel()
        viewModel.sessionProfile = AuthViewModel.SessionProfile(
            displayName: "Avery Chen",
            username: "avery",
            email: "avery@example.com",
            profileImageData: nil
        )

        XCTAssertEqual(viewModel.welcomeBackText, "Welcome back, Avery Chen")
    }

    func testLibraryViewModel_alphabeticalSortOrdersSpacesByTitle() {
        let alpha = StudySpace(
            id: UUID(),
            title: "Algebra",
            description: "Math notes",
            iconName: "function",
            category: "Science",
            status: .active,
            workspaceColorHex: "#22C55E",
            documentCount: 0,
            noteCount: 0,
            lastUpdated: "Just now",
            lastOpened: "Opened just now",
            aiOutputCount: 0,
            progress: 0
        )
        let zulu = StudySpace(
            id: UUID(),
            title: "Zoology",
            description: "Biology notes",
            iconName: "leaf",
            category: "Science",
            status: .active,
            workspaceColorHex: "#22C55E",
            documentCount: 0,
            noteCount: 0,
            lastUpdated: "Just now",
            lastOpened: "Opened just now",
            aiOutputCount: 0,
            progress: 0
        )

        let viewModel = LibraryViewModel(store: StudySpaceStore(seed: [zulu, alpha]))
        viewModel.selectedSort = .alphabetical

        XCTAssertEqual(viewModel.filteredStudySpaces.map(\.title), ["Algebra", "Zoology"])
    }

    func testStudySummary_simplifiedVersion_isShorterAndMarked() {
        let summary = StudySummary.previewSummaries[0]
        let simplified = summary.simplifiedVersion()

        XCTAssertTrue(simplified.title.contains("Simplified"))
        XCTAssertLessThan(simplified.mainIdeas.count, summary.mainIdeas.count)
        XCTAssertLessThanOrEqual(simplified.keyConcepts.count, summary.keyConcepts.count)
        XCTAssertLessThanOrEqual(simplified.examples.count, summary.examples.count)
    }

    private func clearUserDefaults() {
        authKeys.forEach { UserDefaults.standard.removeObject(forKey: $0) }
        UserDefaults.standard.removeObject(forKey: workspaceCacheKey)
    }
}
