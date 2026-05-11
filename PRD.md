# SmartStudyCompanion PRD

## 1. Product Overview

SmartStudyCompanion is a study workflow app that combines workspace organization, note taking, file uploads, AI summaries, and AI chat in one SwiftUI iOS experience.

## 2. Background and Motivation

Students frequently switch between note apps, cloud storage, and AI tools. This creates friction when studying because the learning context is fragmented. The product goal is to keep study materials, notes, and AI assistance in one place.

## 3. Target Users

- University and college students
- Self-directed learners
- Anyone organizing study materials into focused workspaces

## 4. User Problems

- Study content is scattered across multiple apps
- It is hard to turn raw materials into useful revision notes
- Uploads, summaries, and chat are often disconnected
- Users need a simple flow from workspace creation to revision

## 5. Product Goals

- Make it easy to create a study workspace
- Support notes, uploads, summaries, and chat in one flow
- Keep the UI calm and easy to navigate
- Preserve study data locally so the app remains useful across sessions
- Use AI to reduce manual summarizing work

## 6. Non-Goals

- Full learning-management-system feature parity
- Social collaboration or shared workspaces
- Complex offline-first synchronization architecture
- A generic AI chat product unrelated to study content
- Overly technical user-facing messaging

## 7. MVP Scope

The MVP should include:

- authentication
- home dashboard and workspace listing
- create/edit workspace
- notes inside a workspace
- file and photo upload
- AI summary generation
- AI chat grounded in workspace content
- library browsing and search/filtering

## 8. Future Scope

Planned future enhancements include:

- Quiz generation and study sessions
- Flashcard generation and review
- Action plan / next-step study guidance
- stronger analytics and progress surfaces
- richer sync/status feedback

These future tools should remain clearly separated from the completed MVP until fully implemented.

## 9. User Stories

- As a user, I want to sign in so my study data is available on my account.
- As a user, I want to create a workspace so I can separate topics.
- As a user, I want to add notes so I can capture ideas quickly.
- As a user, I want to upload files and photos so the app can use my study material.
- As a user, I want an AI summary so I can review the main points quickly.
- As a user, I want AI chat so I can ask questions about my workspace.
- As a user, I want to browse my workspaces from a clean dashboard and library.

## 10. Core User Flows

1. Launch app
2. Authenticate
3. Open home dashboard or library
4. Create a workspace
5. Add notes or uploads
6. Generate a summary
7. Ask AI chat follow-up questions
8. Return to the workspace or library

## 11. Functional Requirements

- Users can create, edit, and delete study spaces.
- Users can create, edit, and delete notes.
- Users can upload files and photos into a study space.
- Users can request an AI summary from workspace content.
- Users can chat with the AI using the selected workspace context.
- Users can browse and search study spaces from the library.
- Planned tools should be visibly labeled as future features rather than pretending to be complete.

## 12. Non-Functional Requirements

- Clear and calm UI
- Responsive SwiftUI layout
- Swift 6-safe concurrency boundaries
- Testable view models and services
- Friendly error messages
- No invented runtime behavior

## 13. UX Principles

- Keep the main study path obvious
- Minimize technical language
- Show honest states for loading, empty, and future features
- Keep action surfaces easy to scan
- Do not overwhelm the user with too many simultaneous choices

## 14. AI Feature Requirements

- AI summaries should be grounded in workspace content
- AI chat should use the active workspace context
- AI responses should be returned from the backend rather than invented in the UI
- Failures should be surfaced with user-friendly copy
- Empty or incomplete source content should not produce silent invented output

## 15. Data Requirements

- Study spaces need stable IDs, title, color, tag metadata, and clear local UI state in the frontend
- Notes need persistent IDs, titles, content blocks, and timestamps
- Uploaded files need file metadata, storage paths, and workspace association
- Summary history should keep versioned results
- Chat history should persist across sessions where available

## 16. Backend/API Requirements

- Authentication must support login and signup
- Study space routes must support add, update, delete, and fetch flows
- File routes must support add and list flows
- Note routes must support add, update, delete, and fetch flows
- AI routes must support summary and chat flows
- The frontend and backend must agree on base URL and port settings

## 17. Testing Requirements

- View models should be covered by focused unit tests
- Mapping and normalization logic should be tested
- Backend controller/service behavior should have unit coverage
- Manual smoke testing should cover auth, workspace creation, uploads, summary, chat, and future-tool modals

## 18. Success Criteria

- A new user can sign in and reach the dashboard
- A user can create a workspace and add notes/uploads
- A user can generate an AI summary successfully
- A user can chat with workspace context successfully
- Future tools are clearly marked and do not look broken
- The codebase is clean enough for submission and merge review

## 19. Risks and Mitigations

- Risk: future tools appear incomplete
  - Mitigation: show a calm coming-soon modal and keep them out of the MVP claim
- Risk: local backend and frontend ports differ
  - Mitigation: document the required alignment and keep setup explicit
- Risk: build/test environment may lack simulator runtimes
  - Mitigation: verify on a local machine with working Xcode simulator support
- Risk: technical copy leaks into user-facing screens
  - Mitigation: keep user-facing messages simple and non-technical

## 20. Assumptions and Constraints

- The current assignment values a strong MVP more than a perfect future feature set.
- The backend remains a separate NestJS app.
- The frontend should not invent AI content locally when the backend fails.
- The project should remain honest about what is finished and what is planned.
