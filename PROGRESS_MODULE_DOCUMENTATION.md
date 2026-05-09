# Progress Module Documentation

## Overview
The Progress module is responsible for showing the user's learning progress in the app. It displays study-related statistics, handles loading and error states, and supports offline cached fallback when the latest API data cannot be loaded.

## Main Components
- `ProgressTrackingView`
- `ProgressViewModel`
- `Progress` model
- `DailyStatistics` model

## Features Implemented
- Progress screen header and statistics layout
- Loading state
- Error state with retry action
- Empty state when no progress data exists
- Offline cached fallback for progress data
- Cached fallback notice shown in the UI
- Basic achievement / badge section

## Data Flow
1. `ProgressTrackingView` requests data through `ProgressViewModel`
2. `ProgressViewModel` calls `APIService`
3. On success, progress data is updated and cached using `CoreDataManager`
4. On failure, the ViewModel attempts to load cached progress
5. The view displays either:
   - loading UI
   - error UI
   - empty UI
   - content UI with stats and achievements

## Cached Fallback Behavior
If the latest progress data cannot be fetched from the API, the app attempts to load previously cached progress from Core Data. If cached data is available:
- the progress screen still shows previous progress data
- a cached fallback notice is displayed to the user

If cached data is not available:
- an error message is shown

## Achievement / Badge Logic
The current MVP achievement logic is simple and UI-focused:
- **First Session**: unlocked if total study time is greater than 0
- **3-Day Streak**: unlocked if study streak is at least 3
- **10 Cards**: unlocked if cards studied is at least 10

## Known Limitations
- The current screen uses a placeholder `pdfFileId` for testing and UI wiring
- Achievement rules are currently basic and can be expanded later
- Daily statistics caching is not yet implemented
- Final verification still needs to be run in Xcode on Mac

## Testing Scope
The Progress module should be tested for:
- successful progress loading
- empty state
- error state
- retry behavior
- cached fallback behavior
- statistics display
- achievement badge display

## Next Improvements
- connect real selected document / user progress source
- improve badge logic and design
- add deeper automated tests for ProgressViewModel
- verify the full flow in Xcode simulator