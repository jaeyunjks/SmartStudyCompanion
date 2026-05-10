# Layer 2 Documentation

## Overview
Layer 2 extends the current testing scope of Smart Study Companion beyond the initial MVP and Progress module integration. It focuses on the app’s advanced learning features and the interactions between them.

This layer is intended to improve confidence that the app not only launches and navigates correctly, but also supports its main study workflow:
- upload content
- generate study materials
- interact with learning features
- update user progress
- remain stable under incomplete or failing backend/AI conditions

## Purpose
The purpose of Layer 2 is to document and test the advanced parts of the app that are essential to the study experience, especially:
- AI Summary
- Flashcards
- Quiz
- Action Plan
- cross-feature integration
- negative and edge-case behavior

Layer 2 complements:
- the original automated frontend test foundation
- Layer 1 MVP testing
- Progress module testing and documentation

## Coverage Areas

### 1. AI Summary
Layer 2 includes tests for:
- successful summary generation
- loading state during summary generation
- empty summary responses
- malformed summary responses
- failed summary generation
- retry behavior
- placeholder/fallback summary behavior

### 2. Flashcards
Layer 2 includes tests for:
- successful flashcard generation
- loading state during generation
- empty flashcard sets
- malformed flashcard data
- front/back flashcard display
- flashcard navigation
- study/review actions
- flashcard-related progress updates

### 3. Quiz
Layer 2 includes tests for:
- successful quiz loading
- loading state during fetch
- empty quiz responses
- malformed quiz data
- answer selection and quiz submission
- validation for missing answers
- score correctness
- submission failure handling
- quiz-related progress updates

### 4. Action Plan
Layer 2 includes tests for:
- successful action plan generation/loading
- loading state
- empty or malformed action plan responses
- retry behavior
- placeholder/fallback action plan behavior

### 5. Cross-Feature Integration
Layer 2 documents tests for how features work together, including:
- upload to summary flow
- upload to flashcards flow
- upload to quiz flow
- consistency across generated study materials
- progress updates after study actions
- navigation consistency across Home, Library, and study spaces
- logout/login continuity
- cached progress fallback behavior

### 6. Negative and Edge Cases
Layer 2 also accounts for higher-risk scenarios such as:
- very large PDFs
- corrupted PDFs
- network timeouts
- duplicate taps/actions
- empty study content states
- expired authentication tokens

## Automated Test Files
The following automated frontend test files were added as part of Layer 2:

- `SmartStudyCompanionTests/Layer2SummaryXCTests.swift`
- `SmartStudyCompanionTests/Layer2FlashcardsXCTests.swift`
- `SmartStudyCompanionTests/Layer2QuizXCTests.swift`
- `SmartStudyCompanionTests/Layer2IntegrationXCTests.swift`

These tests continue the existing testing style used in earlier automation work, using mocked API responses to verify app-side logic and state handling.

## Test Strategy
Layer 2 uses a mixed testing strategy:

### Automated Tests
Automated tests focus on frontend logic and mocked API interactions, including:
- response handling
- error handling
- state changes
- data mapping
- cross-feature relationships

### Manual Test Cases
`LAYER2_TEST_CASES.md` documents the expected runtime behavior of advanced features and is intended to support:
- manual QA
- teammate testing
- demo preparation
- contribution evidence
- fallback testing where backend/AI features are not yet fully stable

## Current Status
Layer 2 should be understood as a practical and realistic testing layer for a near-deadline project.

### Ready to test now
- final smoke testing
- some cross-feature checks
- any advanced feature that is already stable in the latest app build

### Partially testable
- AI Summary
- Flashcards
- Quiz
- cross-feature integration
- negative case handling

### Pending or dependent on backend/AI stability
- Action Plan
- full AI-generated correctness checks
- end-to-end validation requiring fully stable backend responses

## Limitations
Layer 2 improves testing coverage significantly, but it does not by itself mean the app is fully tested end-to-end.

Current limitations include:
- some advanced features may still depend on unstable or incomplete backend/AI responses
- automated tests use mocked responses rather than a real live backend
- some runtime states must still be verified manually on Mac/Xcode
- backend/database integration depth may still require separate testing by the backend owner
- complete end-to-end flows still depend on all connected modules being stable simultaneously

## How Layer 2 Supports Full App Testing
Layer 2 is a major step toward full app testing because it adds coverage for the core learning experience of the app.

To approach full app testing, the project should combine:
1. automated frontend logic tests
2. Layer 1 MVP testing
3. Layer 2 advanced feature testing
4. Progress module verification
5. backend endpoint/service testing
6. runtime testing on Mac/Xcode
7. final smoke testing before submission/demo

## Recommended Final Testing Workflow
Before final submission or presentation, the recommended testing workflow is:

1. Confirm the latest frontend branch builds successfully
2. Confirm navigation and core tabs work correctly
3. Run available XCTest targets
4. Review `LAYER2_TEST_CASES.md`
5. Manually test the stable advanced features
6. Confirm Progress remains reachable and stable
7. Run final smoke checklist for the whole app

## Notes
Layer 2 was created to strengthen both technical testing coverage and documentation quality close to the deadline. It is intended to show clear testing ownership, realistic QA planning, and structured contribution to the overall project quality.