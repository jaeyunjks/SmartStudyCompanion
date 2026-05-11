# SmartStudyCompanion Testing

## 1. Testing Strategy

Testing is split across three levels:

- unit tests for models, view models, and mapping logic
- backend controller/service tests
- manual app smoke tests for end-to-end user flows

The goal is to verify the MVP path first: auth, workspace creation, notes, uploads, summary, and chat.

## 2. Unit Testing Scope

### iOS

The Swift test target includes coverage for:

- model mapping and normalization
- library sorting and filtering
- unsupported social sign-in behavior
- summary simplification logic
- future-tool gating behavior

### Backend

The backend includes Jest specs for:

- auth
- user
- study space
- file
- note
- AI and service behavior

## 3. Integration Testing Scope

Integration testing should cover:

- login and token persistence
- workspace creation and editing
- file upload plus summary generation
- chat against workspace context
- backend responses for protected routes

## 4. UI and Manual Testing Scope

Manual testing should verify:

- cold app launch
- authentication flow
- home dashboard navigation
- library navigation
- workspace creation and edit sheet layout
- note add/edit/delete
- file and photo upload
- AI summary generation
- AI chat response display
- coming-soon modal for future tools

## 5. Smoke Testing Checklist

1. Launch the app.
2. Sign in or sign up.
3. Open the dashboard.
4. Create a workspace.
5. Add a note.
6. Upload a file or photo.
7. Generate a summary.
8. Ask AI chat a question.
9. Tap Quiz, Flashcards, or Action Plan and confirm the coming-soon modal appears.

## 6. Key Test Scenarios

- valid workspace creation
- empty workspace name rejection
- successful note save
- note delete failure handling
- file upload success
- file import failure handling
- summary generation with readable sources
- summary generation with no sources selected
- chat with persisted conversation history
- coming-soon modal dismissal

## 7. Known Environment Limitations

- Local command-line Xcode verification may fail if simulator runtimes are unavailable.
- SwiftUI preview macros can fail in environments without the expected Xcode plugin/runtime support.
- Backend e2e verification depends on a running backend plus consistent database state.

## 8. How to Run Tests

### Frontend

From the repo root:

```bash
xcodebuild test \
  -project SmartStudyCompanion.xcodeproj \
  -scheme SmartStudyCompanion \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO
```

### Backend

From `backend/smart-study-companion`:

```bash
npm install
npm run test
npm run test:e2e
```

## 9. What Has Been Verified

In the source tree, the following coverage exists:

- Swift frontend unit tests in `SmartStudyCompanionTests`
- backend controller and service specs in `backend/smart-study-companion/src`
- backend e2e scaffold in `backend/smart-study-companion/test`
- clear coming-soon gating for future study tools in the active UI

This documentation pass did not re-run the full app build, so command-line pass/fail status should be verified locally in Xcode.

## 10. What Still Requires Manual Verification

- the app build in the local Xcode environment
- simulator-based UI navigation
- backend/frontend port alignment
- full summary and chat smoke flow against the running backend
- any remaining warning banner or runtime behavior that only appears in a live simulator session
