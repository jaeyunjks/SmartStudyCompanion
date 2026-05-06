# Tester Smoke Checklist (Frontend + Backend Combined)

Use this checklist before merging `frontend-backend-combined` into `main`.

## Preconditions
- Backend is running and reachable from the app base URL.
- Tester has a valid user account or can sign up.
- At least one sample PDF/text document is available for upload.

## Core Flow
1. Log in.
2. Create a workspace named `Biology` (or open an existing one).
3. Upload one document inside that workspace.
4. Open summary and generate AI summary.
5. Open AI chat and ask: `Explain the key points from this file`.

## Expected Results
- Upload completes without app crash.
- File is visible in workspace materials.
- Summary screen returns populated content:
  - overview
  - key concepts
  - important details
- Chat returns an assistant response and keeps chat history.

## Regression Checks
- Workspace create/update/delete still works.
- Reopen app and verify workspace + materials still load.
- Non-AI screens (home/library/profile) open without crashes.

## Known Errors and Interpretation
- `No backend files found for this workspace...`
  - The workspace exists locally but no backend file record was found for that workspace ID.
- `Unauthorized. Please log in again.`
  - Access token invalid/expired.
- `Cannot connect to backend at ...`
  - Backend not running or port mismatch.
