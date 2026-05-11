# SmartStudyCompanion

SmartStudyCompanion is a SwiftUI + MVVM iOS study companion app with a NestJS backend. It helps users create study spaces, write and manage notes, upload files and photos, generate AI summaries, and chat with study content.

## Problem Statement

Students often keep learning materials in separate places: notes in one app, files in another, and revision questions somewhere else. SmartStudyCompanion brings the workflow together so a user can move from a workspace, to uploaded material, to summary, to chat without leaving the app.

## Key Features

- Workspace creation and editing
- Notes inside a workspace
- File and photo uploads
- AI summary generation
- AI chat grounded in workspace content
- Home dashboard and library navigation
- Local persistence for workspace materials, notes, summary history, and chat history
- Planned study tools for future updates

## Completed MVP Scope

The current active MVP focuses on:

- creating and editing study spaces
- adding, editing, and deleting notes
- uploading files and photos into a workspace
- generating AI summaries from workspace content
- chatting with the AI about the active workspace
- browsing workspaces from the home dashboard and library

## Future Scope

The repo still contains additional study-tool surfaces that are intentionally future-gated:

- Quiz
- Flashcards
- Action Plan

These tools are surfaced as planned features for a future update and should not be treated as finished MVP scope.

## Tech Stack

- Frontend: SwiftUI, Swift concurrency, MVVM
- iOS data flow: `@StateObject`, `@Published`, `@EnvironmentObject`
- Backend: NestJS, TypeScript
- Database: PostgreSQL via Prisma
- AI integration: backend AI module with `openai`
- File handling: local storage services plus backend file/image routes

## Frontend Overview

The iOS app is organized into:

- `SmartStudyCompanionApp.swift` for app entry and root navigation
- Authentication screens in `Views/Authentication`
- Dashboard and library screens in `Views/Home` and `Views/Library`
- Workspace screens in `Views/Workspace`
- Summary and AI chat screens in `Views/Summary` and `Views/AIChat`
- View models in `ViewModels`
- Shared models in `Models`
- Network and storage services in `Services`

The active runtime flow is:

1. Launch app
2. Check authentication
3. Show `AuthenticationFlowView` or `HomeDashboardView`
4. Open a workspace from the home or library flow
5. Add notes or uploads
6. Generate summary or chat with workspace content

## Backend Overview

The backend lives in `backend/smart-study-companion` and is a NestJS application with modules for:

- auth
- user
- study space
- note
- file
- image
- ai
- mail
- file storage

It uses Prisma with PostgreSQL and exposes REST routes under `/api/*`.

## Testing Overview

Testing is split across:

- Swift unit tests in `SmartStudyCompanionTests`
- backend Jest unit and controller tests in `backend/smart-study-companion/src/**/*.spec.ts`
- backend e2e tests in `backend/smart-study-companion/test`
- manual app flows for workspace creation, uploads, summary, chat, and the future-tool modal

See `TESTING.md` for the current testing strategy and environment notes.

## Setup

### Frontend

1. Open `SmartStudyCompanion.xcodeproj` in Xcode.
2. Choose an available iPhone simulator or device.
3. Build and run the `SmartStudyCompanion` scheme.

### Backend

1. Open a terminal in `backend/smart-study-companion`.
2. Install dependencies with `npm install`.
3. Generate Prisma artifacts if needed with `npx prisma generate`.
4. Start the backend with `npm run start:dev`.

### API Alignment

The frontend API client defaults to:

- `http://localhost:8000/api`

The backend `main.ts` listens on:

- `process.env.API_PORT ?? 1234`

Make sure both sides point to the same local port before running the app.

## Known Limitations

- Quiz, Flashcards, and Action Plan are currently planned features and are shown with a calm coming-soon modal.
- Some local persistence uses file-backed services rather than a single CoreData path.
- The command-line build/test experience can be limited by local simulator availability.
- Backend and frontend port settings must be aligned manually in local development.

## Project Status

The core MVP is in place and the codebase is organized for submission:

- workspace creation works
- notes work
- uploads work
- AI summary works
- AI chat works
- planned study tools are clearly marked as future scope

For the design and implementation plan, see `PRD.md`. For system structure, see `ARCHITECTURE.md`. For testing coverage and verification notes, see `TESTING.md`.
