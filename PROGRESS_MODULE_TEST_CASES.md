# Progress Module Test Cases

## Scope
This document covers manual test cases for the Progress module, including:
- progress loading
- empty state
- error state
- retry behavior
- cached fallback behavior
- statistics display
- achievement / badge display

---

## TC-PROG-001 Load progress successfully
**Precondition:** Valid progress data exists for the selected PDF/user  
**Steps:**
1. Open the Progress screen
2. Wait for data to load  
**Expected Result:**
- Loading indicator appears first
- Progress data is displayed
- Overall stats show non-empty values
- Daily statistics section is visible

---

## TC-PROG-002 Show loading state
**Precondition:** API request is in progress  
**Steps:**
1. Open the Progress screen
2. Observe the UI before data finishes loading  
**Expected Result:**
- A loading indicator is visible
- A loading message is shown
- No broken or overlapping UI appears

---

## TC-PROG-003 Show empty state when no progress exists
**Precondition:** No progress data exists and no statistics are available  
**Steps:**
1. Open the Progress screen
2. Allow loading to finish  
**Expected Result:**
- Empty state UI is shown
- User sees a message such as “No progress yet”
- App does not crash

---

## TC-PROG-004 Show error state when fetch fails and no cache exists
**Precondition:** API fetch fails and no cached progress is available  
**Steps:**
1. Open the Progress screen
2. Simulate API failure
3. Ensure no cached data exists  
**Expected Result:**
- Error state is shown
- Error message is displayed
- Retry button is visible

---

## TC-PROG-005 Retry after error
**Precondition:** Error state is currently visible  
**Steps:**
1. Tap the Retry button
2. Allow the request to run again  
**Expected Result:**
- The app attempts to fetch progress again
- If successful, content UI is shown
- If still unsuccessful, error UI remains stable

---

## TC-PROG-006 Cached fallback when API fails
**Precondition:** API fetch fails, but cached progress data exists  
**Steps:**
1. Open the Progress screen
2. Simulate API failure
3. Ensure cached progress is available  
**Expected Result:**
- Cached progress data is displayed
- Cached fallback notice is visible
- App does not show blocking error UI

---

## TC-PROG-007 Cached fallback notice content
**Precondition:** Cached fallback mode is active  
**Steps:**
1. Trigger cached fallback behavior  
**Expected Result:**
- A visible notice explains that cached data is being shown
- Notice is readable and does not break layout

---

## TC-PROG-008 Statistics display correctly
**Precondition:** Valid progress data exists  
**Steps:**
1. Open the Progress screen
2. Review the stats cards  
**Expected Result:**
- Cards Studied displays the correct value
- Quizzes Done displays the correct value
- Accuracy displays the correct value
- Values match the underlying progress model

---

## TC-PROG-009 Overall progress cards display correctly
**Precondition:** Valid progress data exists  
**Steps:**
1. Open the Progress screen
2. Review overall progress cards  
**Expected Result:**
- Study Time is correctly formatted
- Streak matches study streak value
- Mastered value matches masteredCards / totalCards

---

## TC-PROG-010 Achievement badge unlock logic
**Precondition:** Progress data meets badge requirements  
**Steps:**
1. Open the Progress screen with progress data that satisfies badge thresholds  
**Expected Result:**
- “First Session” is unlocked when total study time > 0
- “3-Day Streak” is unlocked when study streak >= 3
- “10 Cards” is unlocked when cards studied >= 10

---

## TC-PROG-011 Achievement badge locked state
**Precondition:** Progress data does not meet badge requirements  
**Steps:**
1. Open the Progress screen with low or zero progress values  
**Expected Result:**
- Badges remain in locked/inactive visual state
- UI remains readable and consistent

---

## TC-PROG-012 Screen stability
**Precondition:** Progress screen is accessible  
**Steps:**
1. Open the Progress screen
2. Trigger loading, empty, error, and content states where possible  
**Expected Result:**
- Screen remains stable in all states
- No layout breakage occurs
- No crash occurs

---

## Notes
- Final runtime verification should be done in Xcode on Mac
- Current implementation uses a placeholder PDF ID for temporary wiring
- Badge logic is currently MVP-level and may be extended later